import url from "url";
import { spawn } from "child_process";
import path from "node:path";
import fs from "node:fs";
import { encode } from "punycode";

// Alfred translate script with streaming OpenAI
// 设为 true 时仅打印请求日志，不真实发出翻译请求
const DRY_RUN_TRANSLATE = false;
// 流式轮询间隔（秒）
const STREAM_POLL_INTERVAL = 0.15;

function maskSecret(secret) {
  if (!secret) return "(NOT SET)";
  if (secret.length <= 12) return `*** (len=${secret.length})`;
  return `${secret.slice(0, 8)}...${secret.slice(-4)} (len=${secret.length})`;
}

function logRequest(engine, req, { dryRun = false } = {}) {
  const proxyInfo = {
    HTTP_PROXY: process.env.HTTP_PROXY || process.env.http_proxy || "(unset)",
    HTTPS_PROXY: process.env.HTTPS_PROXY || process.env.https_proxy || "(unset)",
    ALL_PROXY: process.env.ALL_PROXY || process.env.all_proxy || "(unset)",
    NO_PROXY: process.env.NO_PROXY || process.env.no_proxy || "(unset)",
    NODE_USE_ENV_PROXY: process.env.NODE_USE_ENV_PROXY || "(unset)",
  };

  const title = dryRun
    ? `=== [DRY RUN] 未真实发出翻译请求 (${engine}) ===`
    : `=== 翻译请求 (${engine}) ===`;

  console.error(
    [
      title,
      `Method: ${req.method}`,
      `URL: ${req.endpoint}`,
      ...(req.rawEndpointEnv !== undefined
        ? [`Raw Endpoint Env: ${req.rawEndpointEnv}`]
        : []),
      `Proxy Env: ${JSON.stringify(proxyInfo, null, 2)}`,
      `Headers: ${JSON.stringify(req.maskedHeaders, null, 2)}`,
      `Body:\n${JSON.stringify(req.bodyObj, null, 2)}`,
      `=== END ===`,
    ].join("\n"),
  );
}

async function main() {
  const args = process.argv.slice(2);
  let sourceText = args[0];
  if (sourceText) {
    sourceText = sourceText.trim();
  } else {
    return;
  }
  let targetLanguage = args[1];

  if (!targetLanguage) {
    // check ascii
    const asciiCount = sourceText
      .split("")
      .filter((char) => char.charCodeAt(0) <= 127).length;
    const asciiRatio = asciiCount / sourceText.length;
    const isAscii = asciiRatio > 0.7;

    if (isAscii) {
      targetLanguage = "zh";
    } else {
      targetLanguage = "en";
    }
  }

  const isEnglishWord = /^[a-zA-Z]+$/.test(sourceText);

  if (sourceText.length > 4000 || (isEnglishWord && sourceText.length < 3)) {
    return;
  }

  // 检查是否是单词查询
  if (/^[a-zA-Z]+$/.test(sourceText)) {
    const icibaResult = await getIcibaWord(sourceText);
    const { items, response } = parseIcibaWordResult(icibaResult);
    if (items.length > 0) {
      const soundUrl = getSoundUrl(icibaResult);
      if (soundUrl) {
        const __dirname = url.fileURLToPath(new URL(".", import.meta.url));
        const child = spawn(
          process.execPath,
          [path.join(__dirname, "./play.mjs"), soundUrl],
          {
            detached: true,
            stdio: "ignore",
          },
        );
        child.unref();
      }

      console.log(
        JSON.stringify({
          response,
          footer: "Enter 复制, cmd+Enter 朗读并复制",
          variables: {
            url: items[0].action.url,
            type: "word",
            translation: response,
          },
        }),
      );
      return;
    }
  }

  // 翻译引擎: "deepl" 或 "openai"
  const engine = process.env.TRANSLATE_ENGINE || "openai";

  if (engine === "deepl") {
    // DeepL 直接翻译，无需流式
    try {
      if (DRY_RUN_TRANSLATE) {
        const req = buildDeeplRequest({
          to: targetLanguage,
          text: sourceText,
        });
        logRequest("deepl", req, { dryRun: true });
        console.log(
          JSON.stringify({
            response: `## 原文\n\n${sourceText}\n\n## 调试模式（未发送真实请求）\n\n- **引擎**: deepl\n- **请求地址**: \`${req.endpoint}\`\n\n完整请求内容已输出到 Alfred Debugger 日志。`,
            footer: "调试模式 - 未发送真实请求（请在 Alfred Debugger 查看日志）",
          }),
        );
        return;
      }

      const deeplResult = await translateWithDeepl({
        to: targetLanguage,
        text: sourceText,
      });
      console.log(
        JSON.stringify({
          response: `## 原文\n\n${sourceText}\n\n## DeepL 翻译\n\n${deeplResult.text}\n\n`,
          footer: "翻译完成 - Enter 复制",
          variables: {
            type: "sentence",
            openai_translation: deeplResult.text,
          },
        }),
      );
    } catch (error) {
      console.log(
        JSON.stringify({
          response: `翻译出错: ${error.message}`,
          footer: "请检查网络连接和 DeepL API 配置",
        }),
      );
    }
    return;
  }

  // OpenAI 流式翻译
  const cacheDir = process.env.alfred_workflow_cache || "/tmp";
  if (!fs.existsSync(cacheDir)) {
    fs.mkdirSync(cacheDir, { recursive: true });
  }

  const streamFile = path.join(cacheDir, "openai_stream.txt");
  const pidFile = path.join(cacheDir, "openai_pid.txt");
  const stateFile = path.join(cacheDir, "translate_state.json");

  if (DRY_RUN_TRANSLATE) {
    cleanup(streamFile, pidFile, stateFile);
    const req = buildOpenAIRequest(sourceText, targetLanguage);
    logRequest("openai", req, { dryRun: true });
    console.log(
      JSON.stringify({
        response: `## 原文\n\n${sourceText}\n\n## 调试模式（未发送真实请求）\n\n- **引擎**: openai\n- **请求地址**: \`${req.endpoint}\`\n- **模型**: \`${req.model}\`\n\n完整请求内容已输出到 Alfred Debugger 日志。`,
        footer: "调试模式 - 未发送真实请求（请在 Alfred Debugger 查看日志）",
      }),
    );
    return;
  }

  let isStreaming = process.env.streaming_now === "1";

  if (isStreaming) {
    const oldState = readState(stateFile);
    if (oldState && oldState.sourceText !== sourceText) {
      cleanup(streamFile, pidFile, stateFile);
      isStreaming = false;
    } else {
      const result = await readOpenAIStream(streamFile, pidFile, stateFile);
      return outputStreamingResult(result, streamFile);
    }
  }

  if (fs.existsSync(streamFile)) {
    const state = readState(stateFile);
    if (state) {
      console.log(
        JSON.stringify({
          rerun: STREAM_POLL_INTERVAL,
          variables: { streaming_now: "1" },
          response: formatResponse({
            sourceText: state.sourceText,
            openaiResult: { text: "⏳ 响应中..." },
            openaiFinished: false,
          }),
          behaviour: { scroll: "end" },
        }),
      );
      return;
    }
  }

  try {
    const state = {
      sourceText,
      targetLanguage,
      timestamp: Date.now(),
    };
    saveState(stateFile, state);

    console.log(
      JSON.stringify({
        rerun: STREAM_POLL_INTERVAL,
        variables: { streaming_now: "1" },
        response: formatResponse({
          sourceText,
          openaiResult: { text: "" },
          openaiFinished: false,
        }),
        behaviour: { scroll: "end" },
      }),
    );

    await startOpenAIStream(sourceText, targetLanguage, streamFile, pidFile);
  } catch (error) {
    console.log(
      JSON.stringify({
        response: `翻译出错: ${error.message}`,
        footer: "请检查网络连接和 API 配置",
      }),
    );
  }
}

// 兼容多种 base URL 写法（OpenAI / OpenRouter / 自建代理等）
function resolveChatCompletionsUrl(base) {
  if (!base) return "https://api.openai.com/v1/chat/completions";
  const trimmed = base.replace(/\/+$/, "");
  if (/\/chat\/completions$/.test(trimmed)) return trimmed;
  if (/\/v\d+$/.test(trimmed)) return `${trimmed}/chat/completions`;
  return `${trimmed}/v1/chat/completions`;
}

function buildOpenAIRequest(text, targetLang) {
  const systemPrompt =
    targetLang === "zh"
      ? "You are a professional translator. Translate the given text to Chinese. Only output the translation result, no explanations."
      : "You are a professional translator. Translate the given text to English. Only output the translation result, no explanations.";

  const messages = [
    { role: "system", content: systemPrompt },
    { role: "user", content: text },
  ];

  const model = process.env.OPENAI_MODEL || "gpt-5-mini";
  const endpoint = resolveChatCompletionsUrl(process.env.OPENAI_API_ENDPOINT);
  const bodyObj = {
    model,
    messages,
    stream: true,
  };

  // 默认关闭 reasoning/thinking 以显著降低翻译首字延迟（可通过 OPENAI_REASONING_EFFORT 覆盖，设为 default 可不传）
  const reasoningEffort = (process.env.OPENAI_REASONING_EFFORT ?? "none").trim();
  if (reasoningEffort && reasoningEffort !== "default") {
    if (/openrouter\.ai/i.test(endpoint)) {
      bodyObj.reasoning = { effort: reasoningEffort };
    } else {
      bodyObj.reasoning_effort = reasoningEffort;
    }
  }

  return {
    method: "POST",
    endpoint,
    rawEndpointEnv: process.env.OPENAI_API_ENDPOINT || "(unset)",
    model,
    headers: {
      "Content-Type": "application/json",
      Authorization: `Bearer ${process.env.OPENAI_API_KEY}`,
    },
    maskedHeaders: {
      "Content-Type": "application/json",
      Authorization: `Bearer ${maskSecret(process.env.OPENAI_API_KEY)}`,
    },
    bodyObj,
    bodyString: JSON.stringify(bodyObj),
  };
}

// 启动 OpenAI 流式翻译
async function startOpenAIStream(text, targetLang, streamFile, pidFile) {
  const req = buildOpenAIRequest(text, targetLang);
  const requestBody = req.bodyString;

  // 确保流文件存在
  fs.writeFileSync(streamFile, "");

  // 使用 curl 进行流式请求
  const errFile = streamFile + ".err";
  const endpoint = req.endpoint;
  const curlArgs = [
    endpoint,
    "--silent",
    "--show-error",
    "--no-buffer",
    "--speed-limit",
    "0",
    "--speed-time",
    "30",
    "--header",
    "Content-Type: application/json",
    "--header",
    `Authorization: ${req.headers.Authorization}`,
    "--data",
    requestBody,
    "--output",
    streamFile,
  ];

  logRequest("openai", req, { dryRun: false });

  try {
    const errFd = fs.openSync(errFile, "w");
    const curlProcess = spawn("curl", curlArgs, {
      detached: true,
      stdio: ["ignore", "ignore", errFd],
    });
    fs.closeSync(errFd);

    // 保存进程 ID
    fs.writeFileSync(pidFile, curlProcess.pid.toString());
    curlProcess.unref();
  } catch (error) {
    console.error("启动 curl 失败:", error.stack || error.message);
    throw new Error(`启动 OpenAI 流式翻译失败: ${error.message}`);
  }
}

// 读取 OpenAI 流式响应
async function readOpenAIStream(streamFile, pidFile, stateFile) {
  const state = readState(stateFile);
  if (!state) {
    return { error: "状态丢失", finished: true };
  }

  let streamContent = "";
  if (fs.existsSync(streamFile)) {
    try {
      streamContent = fs.readFileSync(streamFile, "utf8");
    } catch (e) {
      console.error("读取 streamFile 失败:", e.message);
    }
  }

  // 顺带把 curl 的 stderr 也打印出来，便于排查 OpenRouter 之类的问题
  const errFile = streamFile + ".err";
  let curlErrSnapshot = "";
  if (fs.existsSync(errFile)) {
    try {
      curlErrSnapshot = fs.readFileSync(errFile, "utf8").trim();
    } catch (e) {}
  }
  if (curlErrSnapshot) {
    console.error("=== curl stderr ===\n" + curlErrSnapshot);
  }

  // 检查是否是 API 错误
  if (streamContent.startsWith("{")) {
    try {
      const errorObj = JSON.parse(streamContent);
      if (errorObj.error) {
        console.error(
          "=== OpenAI/OpenRouter error response ===\n" + streamContent,
        );
        cleanup(streamFile, pidFile);
        return {
          sourceText: state.sourceText,
          // deeplResult: state.deeplResult,
          openaiResult: { error: `OpenAI 错误: ${errorObj.error.message}` },
          finished: true,
        };
      }
    } catch (e) {
      console.error(
        "响应以 { 开头但 JSON 解析失败:",
        e.message,
        "\n内容前 500 字符:",
        streamContent.slice(0, 500),
      );
    }
  }

  // 解析流式响应（按 SSE 规范跳过空行与 ":" 开头的注释/心跳行，如 ": OPENROUTER PROCESSING"）
  const rawLines = streamContent
    .split(/\r?\n/)
    .map((line) => line.trim())
    .filter((line) => line.startsWith("data:"));
  const parseFailures = [];
  const chunks = rawLines
    .map((line) => line.slice(5).trim())
    .filter((data) => data && data !== "[DONE]")
    .map((data) => {
      try {
        return JSON.parse(data);
      } catch (e) {
        parseFailures.push({ line: data, error: e.message });
        return null;
      }
    })
    .filter(Boolean);

  if (parseFailures.length) {
    console.error(
      "=== 流式响应中有",
      parseFailures.length,
      "行无法解析为 JSON ===\n",
      parseFailures.slice(0, 5),
    );
  }

  const responseText = chunks
    .map((chunk) => chunk.choices?.[0]?.delta?.content || "")
    .join("");

  const finishReason = chunks.slice(-1)[0]?.choices?.[0]?.finish_reason;
  const finished = !!finishReason;

  // 若 curl 已退出且有 stderr 错误且无任何响应内容，立即报错而不必等待超时
  if (!finished && curlErrSnapshot && streamContent.length === 0 && !isPidAlive(pidFile)) {
    cleanup(streamFile, pidFile, stateFile, errFile);
    return {
      sourceText: state.sourceText,
      openaiResult: { error: `连接失败: ${curlErrSnapshot}` },
      finished: true,
    };
  }

  // 检查连接是否超时
  if (!finished && fs.existsSync(streamFile)) {
    const stats = fs.statSync(streamFile);
    const stalled = Date.now() - stats.mtime.getTime() > 30000; // 30秒超时

    if (stalled && streamContent.length === 0) {
      console.error(
        "=== 翻译超时 ===\nstreamFile 30s 内无写入，curlErr:",
        curlErrSnapshot || "(空)",
      );
      cleanup(streamFile, pidFile, stateFile, errFile);
      return {
        sourceText: state.sourceText,
        openaiResult: {
          error: curlErrSnapshot
            ? `连接失败: ${curlErrSnapshot}`
            : "OpenAI 连接超时",
        },
        finished: true,
      };
    }
  }

  // 上游返回了 HTML（非 SSE），多半是 endpoint 错误（404 之类）—— 立刻报错并清理
  if (!finished && /^\s*<(?:!doctype|html|\?xml)/i.test(streamContent)) {
    console.error(
      "=== 上游返回 HTML 而不是 SSE，按错误处理 ===\n内容前 1000 字符:\n" +
        streamContent.slice(0, 1000),
    );
    cleanup(streamFile, pidFile, stateFile, errFile);
    return {
      sourceText: state.sourceText,
      openaiResult: {
        error: "上游返回了 HTML 而不是流式响应（多半是 endpoint 错误，比如 404）",
      },
      finished: true,
    };
  }

  if (finished) {
    // 保存原始响应副本供日志打印
    try {
      fs.copyFileSync(streamFile, streamFile + ".raw");
    } catch (e) {}
    cleanup(streamFile, pidFile, errFile);
  }

  return {
    sourceText: state.sourceText,
    openaiResult: { text: responseText },
    finished,
  };
}

// 输出流式结果
function outputStreamingResult(result, streamFile) {
  const response = formatResponse({
    sourceText: result.sourceText,
    // deeplResult: result.deeplResult,
    openaiResult: result.openaiResult,
    openaiFinished: result.finished,
  });

  const output = {
    response: response,
    behaviour: { scroll: "end" },
  };

  if (result.finished) {
    // 翻译完成，打印完整的原始响应和 curl 参数
    if (streamFile) {
      const rawFile = streamFile + ".raw";
      try {
        if (fs.existsSync(rawFile)) {
          console.error(
            "=== raw response ===\n" + fs.readFileSync(rawFile, "utf8"),
          );
          fs.unlinkSync(rawFile);
        }
      } catch (e) {}
    }
    console.error("=== result ===", JSON.stringify(result, null, 2));
    output.footer = "翻译完成 - Enter 复制 OpenAI 结果";
    output.variables = {
      type: "sentence",
      // translation: result.deeplResult.text,
      openai_translation:
        result.openaiResult.text || result.openaiResult.error || "",
    };
  } else {
    // 继续流式传输
    output.rerun = STREAM_POLL_INTERVAL;
    output.variables = { streaming_now: "1" };
    output.footer = "OpenAI 翻译生成中...";
  }

  console.log(JSON.stringify(output));
}

// 格式化显示响应
function formatResponse(options = {}) {
  const { sourceText, deeplResult, openaiResult, openaiFinished } = options;

  let response = `## 原文\n\n${sourceText}\n\n`;

  if (deeplResult) {
    // const deeplSiteUrl = `https://www.deepl.com/translator#auto/${deeplResult.source || "auto"}/${encodeURIComponent(sourceText)}`;
    response += `## DeepL 翻译\n\n${deeplResult.text}\n\n`;
  }
  response += `## OpenAI 翻译${openaiFinished ? "" : " (生成中...)"}\n\n`;

  if (openaiResult && openaiResult.error) {
    response += `❌ ${openaiResult.error}\n\n`;
  } else if (openaiResult && openaiResult.text) {
    response += `${openaiResult.text}${openaiFinished ? "" : "▊"}\n\n`;
  } else {
    response += `⏳ 正在生成...\n\n`;
  }

  return response;
}

// 状态管理
function saveState(stateFile, state) {
  try {
    // 确保目录存在
    const dir = path.dirname(stateFile);
    if (!fs.existsSync(dir)) {
      fs.mkdirSync(dir, { recursive: true });
    }
    fs.writeFileSync(stateFile, JSON.stringify(state));
  } catch (error) {
    console.error("保存状态失败:", error.message);
  }
}

function readState(stateFile) {
  if (!fs.existsSync(stateFile)) return null;
  try {
    return JSON.parse(fs.readFileSync(stateFile, "utf8"));
  } catch (error) {
    console.error("读取状态失败:", error.message);
    return null;
  }
}

function isPidAlive(pidFile) {
  if (!fs.existsSync(pidFile)) return false;
  try {
    const pid = Number(fs.readFileSync(pidFile, "utf8").trim());
    if (!Number.isInteger(pid) || pid <= 0) return false;
    process.kill(pid, 0);
    return true;
  } catch (e) {
    return false;
  }
}

// 清理文件
function cleanup(...files) {
  files.filter(Boolean).forEach((file) => {
    if (fs.existsSync(file)) {
      try {
        fs.unlinkSync(file);
      } catch (e) {
        // 忽略删除错误
      }
    }
  });
}

function buildDeeplRequest(options = {}) {
  let { to, text } = options;
  if (to.startsWith("zh")) {
    to = "ZH";
  }

  const requestUrl = process.env.DEEPL_API_ENDPOINT;
  if (!requestUrl) {
    throw new Error("DEEPL_API_ENDPOINT 未配置");
  }
  const bodyObj = {
    text: [text],
    source_lang: "auto",
    target_lang: to.toUpperCase(),
  };
  return {
    method: "POST",
    endpoint: requestUrl,
    headers: {
      "Content-Type": "application/json",
      token: process.env.DEEPL_AUTH_KEY,
    },
    maskedHeaders: {
      "Content-Type": "application/json",
      token: maskSecret(process.env.DEEPL_AUTH_KEY),
    },
    bodyObj,
    bodyString: JSON.stringify(bodyObj),
  };
}

// 保留原有的翻译函数
export async function translateWithDeepl(options = {}) {
  const req = buildDeeplRequest(options);
  const requestUrl = req.endpoint;
  const requestBody = req.bodyObj;
  const response = await fetch(requestUrl, {
    method: req.method,
    headers: req.headers,
    body: req.bodyString,
  });
  const statusCode = response.status;
  const responseText = await response.text();
  console.error(
    "=== DeepL ===\nURL:",
    requestUrl,
    "\nBody:",
    JSON.stringify(requestBody),
    "\nToken:",
    process.env.DEEPL_AUTH_KEY ? "set" : "not set",
    "\nStatus:",
    statusCode,
    "\nResponse:",
    responseText,
  );

  if (response.ok) {
    const json = JSON.parse(responseText);
    if (json.translations?.[0]?.text) {
      return {
        text: json.translations[0].text,
        remoteFrom: json.translations[0].detected_source_language || "",
      };
    }
    throw new Error("翻译结果为空: " + responseText);
  } else {
    throw new Error("翻译失败: " + statusCode + ", " + responseText);
  }
}

// 保留原有的单词查询功能
export function parseIcibaWordResult(icibaResult) {
  let items = [];
  let responseText = `## ${icibaResult.word_name}\n\n`;

  const siteUrl = `https://dictionary.cambridge.org/us/dictionary/english/${icibaResult.word_name}`;

  const symbols = icibaResult.symbols;
  if (symbols && symbols.length) {
    const symbol = symbols[0];
    const phAm = symbol.ph_am;
    const phEn = symbol.ph_en;

    let ph = "";
    if (phAm) {
      ph = `美音: [${phAm}]`;
    }
    if (phEn) {
      ph = ph + ` 英音: [${phEn}]`;
    }

    responseText += `${ph}\n\n`;

    const parts = symbol.parts;
    if (parts && parts.length) {
      for (const part of parts) {
        const means = part.means;
        if (means && means.length) {
          items = [
            ...items,
            {
              subtitle: part.part + " " + `[${ph}]`,
              title: means.join(", "),
              arg: means.join(", "),
              action: {
                url: siteUrl,
              },
            },
          ];
          responseText += `### ${part.part}\n${means.join(", ")}\n\n`;
        }
      }
    }
  }

  let exchanges = [];
  if (icibaResult.exchange) {
    const keys = Object.keys(icibaResult.exchange);
    for (const key of keys) {
      const value = icibaResult.exchange[key];
      if (value && Array.isArray(value) && value.length) {
        exchanges = [...exchanges, ...value];
      }
    }
  }
  if (exchanges.length) {
    items = [
      ...items,
      {
        subtitle: "变形",
        title: exchanges.join(", "),
        arg: exchanges.join(", "),
        action: {
          url: siteUrl,
        },
      },
    ];
    responseText += `### 变形\n${exchanges.join(", ")}\n\n`;
  }

  return { items, response: responseText };
}

export async function getIcibaWord(word) {
  const url = "http://dict-co.iciba.com/api/dictionary.php";
  const params = new URLSearchParams({
    key: "0EAE08A016D6688F64AB3EBB2337BFB0",
    type: "json",
    w: word,
  });
  const response = await fetch(url + "?" + params.toString());
  const statusCode = response.status;
  const responseText = await response.text();
  if (response.ok) {
    const json = JSON.parse(responseText);
    return json;
  } else {
    throw new Error("查询失败: " + statusCode + ", " + responseText);
  }
}

export function getSoundUrl(icibaResult) {
  const icibaDictionaryResult = icibaResult;
  if (!icibaDictionaryResult.symbols.length) {
    return;
  }
  const symbol = icibaDictionaryResult.symbols[0];
  const phoneticUrl = symbol.ph_am_mp3.length
    ? symbol.ph_am_mp3
    : symbol.ph_tts_mp3.length
      ? symbol.ph_tts_mp3
      : symbol.ph_en_mp3;
  if (phoneticUrl.length) {
    return phoneticUrl;
  }
}

if (import.meta.url === url.pathToFileURL(process.argv[1]).href) {
  main().catch((e) => {
    console.log(
      JSON.stringify({
        items: [
          {
            title: "发生错误",
            subtitle: e.message,
            arg: e.message,
          },
        ],
      }),
    );
  });
}
