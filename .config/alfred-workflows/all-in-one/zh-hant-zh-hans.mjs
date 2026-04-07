import * as OpenCC from "opencc-js";

const s2t = OpenCC.Converter({ from: "cn", to: "tw" });
const t2s = OpenCC.Converter({ from: "tw", to: "cn" });

function hasTraditional(text) {
  const simplified = t2s(text);
  return simplified !== text;
}

function main() {
  const query = process.argv[2];
  if (!query) {
    return;
  }

  const isTraditional = hasTraditional(query);
  const converted = isTraditional ? t2s(query) : s2t(query);
  const subtitle = isTraditional ? "繁體 → 简体" : "简体 → 繁體";

  console.log(
    JSON.stringify({
      items: [
        {
          title: converted,
          subtitle,
          arg: converted,
        },
      ],
    }),
  );
}

main();
