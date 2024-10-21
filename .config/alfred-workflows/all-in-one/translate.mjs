import url from "url";
import { spawn } from "child_process";
import path from "node:path";
import fs from "node:fs";
import { encode } from "punycode";
// Alfred translate script
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
    // check ascci
    const isAscii = /^[\x00-\x7F]*$/.test(sourceText);
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

  // check if it is a word
  if (/^[a-zA-Z]+$/.test(sourceText)) {
    const icibaResult = await getIcibaWord(sourceText);
    const items = parseIcibaWordResult(icibaResult);
    // check is items empty
    if (items.length > 0) {
      const soundUrl = getSoundUrl(icibaResult);
      if (!soundUrl) {
        return;
      }
      const __dirname = url.fileURLToPath(new URL(".", import.meta.url));
      const nodePath = getNodeExecPath();
      if (!nodePath) {
        return;
      }

      // 在子进程异步播放
      const child = spawn(
        nodePath,
        [path.join(__dirname, "./play.mjs"), soundUrl],
        {
          detached: true,
          stdio: "ignore",
        },
      );
      child.unref(); // 允许主进程退出而不等待子进程

      console.log(
        JSON.stringify({
          items,
          variables: {
            url: items[0].action.url,
            type: "word",
          },
        }),
      );
      return;
    }
  }
  let items = [];

  const deeplResult = await translateWithDeepl({
    from: "auto",
    to: targetLanguage,
    text: sourceText,
  });

  const deeplTranslationText = deeplResult.text;

  const deeplSiteUrl = `https://www.deepl.com/translator#${
    deeplResult.remoteFrom
  }/${targetLanguage}/${encodeURIComponent(sourceText)}`;

  items = [
    {
      title: deeplTranslationText,
      subtitle:
        "By Deepl, Enter 复制, cmd+L 放大显示并复制, 右方向键 -> 更多操作",
      arg: deeplTranslationText,
      action: {
        url: deeplSiteUrl,
      },
      quicklookurl: deeplSiteUrl,
    },
  ];
  // const result = await translate({
  //   from: "auto",
  //   to: targetLanguage,
  //   text: sourceText,
  // });
  //
  // const translationText = result.text;
  //
  // const siteUrl = `https://translate.google.com/?sl=${
  //   result.remoteFrom
  // }&tl=${targetLanguage}&text=${encodeURIComponent(sourceText)}&op=translate`;
  //
  // items = [
  //   ...items,
  //   {
  //     title: translationText,
  //     subtitle:
  //       "By Google, Enter 复制, cmd+L 放大显示并复制,  右方向键 -> 更多操作",
  //     arg: translationText,
  //     action: {
  //       url: siteUrl,
  //     },
  //     quicklookurl: siteUrl,
  //   },
  // ];

  console.log(
    JSON.stringify({
      items,
      variables: {
        type: "sentence",
      },
    }),
  );
}

export async function translate(options = {}) {
  const { from, to, text } = options;

  const params = new URLSearchParams({
    client: "gtx",
    dt: "t",
    sl: from,
    tl: to,
    q: text,
  });
  const url =
    `https://translate.googleapis.com/translate_a/single?` + params.toString();
  const response = await fetch(url);
  const statusCode = response.status;
  const responseText = await response.text();
  let result = {
    text: "",
    remoteFrom: "",
  };
  if (response.ok) {
    const json = JSON.parse(responseText);
    result.text = json[0][0][0];
    result.remoteFrom = json[2];
    return result;
  } else {
    throw new Error("翻译失败: " + statusCode + ", " + responseText);
  }
}

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

export function parseIcibaWordResult(icibaResult) {
  let items = [];

  const siteUrl = `https://dictionary.cambridge.org/us/dictionary/english/${icibaResult.word_name}`;
  // 含义

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
  }
  return items;
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

/**
 * download icicba word audio file
 */
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
      break;
    }
  }
}
