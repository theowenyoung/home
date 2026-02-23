import url from "url";
import { spawn } from "child_process";
import path from "node:path";
import fs from "node:fs";
import { encode } from "punycode";

// Alfred translate script with streaming OpenAI
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
        const nodePath = getNodeExecPath();
        if (nodePath) {
          const child = spawn(
            nodePath,
            [path.join(__dirname, "./play.mjs"), soundUrl],
            {
              detached: true,
              stdio: "ignore",
            },
          );
          child.unref();
        }
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
          rerun: 0.5,
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
        rerun: 0.5,
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

// 启动 OpenAI 流式翻译
async function startOpenAIStream(text, targetLang, streamFile, pidFile) {
  const systemPrompt =
    targetLang === "zh"
      ? "You are a professional translator. Translate the given text to Chinese. Only output the translation result, no explanations."
      : "You are a professional translator. Translate the given text to English. Only output the translation result, no explanations.";

  const messages = [
    { role: "system", content: systemPrompt },
    { role: "user", content: text },
  ];

  const requestBody = JSON.stringify({
    model: process.env.OPENAI_MODEL || "gpt-5-mini",
    messages: messages,
    stream: true,
  });

  // 确保流文件存在
  fs.writeFileSync(streamFile, "");

  // 使用 curl 进行流式请求
  const errFile = streamFile + ".err";
  const curlArgs = [
    process.env.OPENAI_API_ENDPOINT
      ? `${process.env.OPENAI_API_ENDPOINT}/v1/chat/completions`
      : "https://api.openai.com/v1/chat/completions",
    "--silent",
    "--show-error",
    "--no-buffer",
    "--speed-limit",
    "0",
    "--speed-time",
    "10",
    "--header",
    "Content-Type: application/json",
    "--header",
    `Authorization: Bearer ${process.env.OPENAI_API_KEY}`,
    "--data",
    requestBody,
    "--output",
    streamFile,
  ];

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
      // 文件可能正在写入中
    }
  }

  // 检查是否是 API 错误
  if (streamContent.startsWith("{")) {
    try {
      const errorObj = JSON.parse(streamContent);
      if (errorObj.error) {
        cleanup(streamFile, pidFile);
        return {
          sourceText: state.sourceText,
          // deeplResult: state.deeplResult,
          openaiResult: { error: `OpenAI 错误: ${errorObj.error.message}` },
          finished: true,
        };
      }
    } catch (e) {
      // 不是错误 JSON，继续处理
    }
  }

  // 解析流式响应
  const chunks = streamContent
    .split("\n")
    .filter((line) => line.trim())
    .map((line) => line.replace(/^data: /, ""))
    .filter((line) => line !== "[DONE]")
    .map((line) => {
      try {
        return JSON.parse(line);
      } catch {
        return null;
      }
    })
    .filter(Boolean);

  const responseText = chunks
    .map((chunk) => chunk.choices?.[0]?.delta?.content || "")
    .join("");

  const finishReason = chunks.slice(-1)[0]?.choices?.[0]?.finish_reason;
  const finished = !!finishReason;

  // 检查连接是否超时
  if (!finished && fs.existsSync(streamFile)) {
    const stats = fs.statSync(streamFile);
    const stalled = Date.now() - stats.mtime.getTime() > 10000; // 10秒超时

    if (stalled && streamContent.length === 0) {
      // 读取 curl 错误信息
      let curlErr = "";
      const errFile = streamFile + ".err";
      try {
        if (fs.existsSync(errFile)) {
          curlErr = fs.readFileSync(errFile, "utf8").trim();
        }
      } catch (e) {}
      cleanup(streamFile, pidFile, stateFile);
      return {
        sourceText: state.sourceText,
        openaiResult: {
          error: curlErr ? `连接失败: ${curlErr}` : "OpenAI 连接超时",
        },
        finished: true,
      };
    }
  }

  if (finished) {
    // 保存原始响应副本供日志打印
    try {
      fs.copyFileSync(streamFile, streamFile + ".raw");
    } catch (e) {}
    cleanup(streamFile, pidFile);
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
    output.rerun = 0.5;
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

// 清理文件
function cleanup(streamFile, pidFile, stateFile) {
  [streamFile, pidFile, stateFile].filter(Boolean).forEach((file) => {
    if (fs.existsSync(file)) {
      try {
        fs.unlinkSync(file);
      } catch (e) {
        // 忽略删除错误
      }
    }
  });
}

// 保留原有的翻译函数
export async function translateWithDeepl(options = {}) {
  let { to, text } = options;
  if (to.startsWith("zh")) {
    to = "ZH";
  }

  const requestUrl = process.env.DEEPL_API_ENDPOINT;
  if (!requestUrl) {
    throw new Error("DEEPL_API_ENDPOINT 未配置");
  }
  const requestBody = {
    text: [text],
    source_lang: "auto",
    target_lang: to.toUpperCase(),
  };
  const response = await fetch(requestUrl, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      token: process.env.DEEPL_AUTH_KEY,
    },
    body: JSON.stringify(requestBody),
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

function getNodeExecPath() {
  const nodePaths = [
    path.join(process.env.HOME, ".nix-profile", "bin", "node"),
    "/usr/local/bin/node",
    "/usr/bin/node",
    "/opt/local/bin/node",
  ];

  for (const nodePath of nodePaths) {
    if (fs.existsSync(nodePath)) {
      return nodePath;
    }
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
