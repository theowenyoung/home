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

  // 获取缓存文件路径
  const cacheDir = process.env.alfred_workflow_cache || "/tmp";

  // 确保缓存目录存在
  if (!fs.existsSync(cacheDir)) {
    fs.mkdirSync(cacheDir, { recursive: true });
  }

  const streamFile = path.join(cacheDir, "openai_stream.txt");
  const pidFile = path.join(cacheDir, "openai_pid.txt");
  const stateFile = path.join(cacheDir, "translate_state.json");

  // 检查是否正在流式传输
  const isStreaming = process.env.streaming_now === "1";

  if (isStreaming) {
    // 继续读取流式传输
    const result = await readOpenAIStream(streamFile, pidFile, stateFile);
    return outputStreamingResult(result);
  }

  // 检查是否有遗留的流文件（窗口关闭后恢复）
  if (fs.existsSync(streamFile)) {
    const state = readState(stateFile);
    if (state) {
      // 恢复流式传输状态
      console.log(
        JSON.stringify({
          rerun: 0.5,
          variables: { streaming_now: "1" },
          response: formatResponse(
            state.sourceText,
            state.deeplResult,
            { text: "⏳ 恢复连接中..." },
            false,
          ),
          behaviour: { scroll: "end" },
        }),
      );
      return;
    }
  }

  // 新的翻译请求
  try {
    // 1. 立即开始 DeepL 翻译
    const deeplResult = await translateWithDeepl({
      from: "auto",
      to: targetLanguage,
      text: sourceText,
    });

    // // 2. 同时启动 OpenAI 流式翻译
    // await startOpenAIStream(sourceText, targetLanguage, streamFile, pidFile);
    //
    // // 3. 保存状态
    // const state = {
    //   sourceText,
    //   targetLanguage,
    //   deeplResult,
    //   timestamp: Date.now(),
    // };
    // saveState(stateFile, state);
    //
    // 4. 输出初始结果并开始流式传输
    const response = formatResponse(
      sourceText,
      deeplResult,
      { text: "" },
      false,
    );

    console.log(
      JSON.stringify({
        // rerun: 0.5,
        // variables: { streaming_now: "1" },
        variables: {
          type: "sentence",
          translation: deeplResult.text,
        },
        response: response,
        // footer: "DeepL 翻译完成，OpenAI 翻译生成中...",
        behaviour: { scroll: "end" },
      }),
    );
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
    model: process.env.OPENAI_MODEL || "gpt-4o-mini",
    messages: messages,
    stream: true,
    temperature: 0.1,
  });

  // 确保流文件存在
  fs.writeFileSync(streamFile, "");

  // 使用 curl 进行流式请求
  const curlArgs = [
    process.env.OPENAI_API_ENDPOINT ||
      "https://o.immersivetranslate.net/v1/chat/completions",
    "--silent",
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
    const curlProcess = spawn("curl", curlArgs, {
      detached: true,
      stdio: "ignore",
    });

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
          deeplResult: state.deeplResult,
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
      cleanup(streamFile, pidFile);
      return {
        sourceText: state.sourceText,
        deeplResult: state.deeplResult,
        openaiResult: { error: "OpenAI 连接超时" },
        finished: true,
      };
    }
  }

  if (finished) {
    cleanup(streamFile, pidFile);
  }

  return {
    sourceText: state.sourceText,
    deeplResult: state.deeplResult,
    openaiResult: { text: responseText },
    finished,
  };
}

// 输出流式结果
function outputStreamingResult(result) {
  const response = formatResponse(
    result.sourceText,
    result.deeplResult,
    result.openaiResult,
    result.finished,
  );

  const output = {
    response: response,
    behaviour: { scroll: "end" },
  };

  if (result.finished) {
    // 翻译完成
    output.footer =
      "翻译完成 - Enter 复制 DeepL 结果, option+Enter 复制 OpenAI 结果";
    output.variables = {
      type: "sentence",
      translation: result.deeplResult.text,
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
function formatResponse(sourceText, deeplResult, openaiResult, openaiFinished) {
  const deeplSiteUrl = `https://www.deepl.com/translator#auto/${deeplResult.source || "auto"}/${encodeURIComponent(sourceText)}`;

  let response = `## 原文\n\n${sourceText}\n\n`;
  response += `## DeepL 翻译\n\n${deeplResult.text}\n\n`;
  // response += `## OpenAI 翻译${openaiFinished ? "" : " (生成中...)"}\n\n`;

  if (openaiResult.error) {
    response += `❌ ${openaiResult.error}\n\n`;
  } else if (openaiResult.text) {
    response += `${openaiResult.text}${openaiFinished ? "" : "▊"}\n\n`;
  } else {
    // response += `⏳ 正在生成...\n\n`;
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
function cleanup(streamFile, pidFile) {
  [streamFile, pidFile].forEach((file) => {
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

  const url = `https://api.deepl.com/v2/translate`;
  const response = await fetch(url, {
    headers: {
      "Content-Type": "application/json",
      Authorization: "DeepL-Auth-Key " + process.env.DEEPL_AUTH_KEY,
    },
    method: "POST",
    body: JSON.stringify({
      text: [text],
      target_lang: to.toUpperCase(),
      model_type: "prefer_quality_optimized",
    }),
  });
  const statusCode = response.status;
  const responseText = await response.text();
  let result = {
    text: "",
    remoteFrom: "",
  };
  if (response.ok) {
    const json = JSON.parse(responseText);
    result.text = json.translations[0].text;
    result.remoteFrom = json.translations[0].detected_source_language;
    return result;
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
