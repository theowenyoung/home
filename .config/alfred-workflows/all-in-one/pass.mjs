import { randomInt } from "node:crypto";
import path from "node:path";
import { pathToFileURL } from "node:url";

const CHARSET = "abcdefghijklmnopqrstuvwxyz0123456789";
const DEFAULT_LENGTH = 40;

function main() {
  const password = generatePassword(DEFAULT_LENGTH);

  console.log(
    JSON.stringify({
      items: [
        {
          title: password,
          subtitle: `${DEFAULT_LENGTH}位小写字母和数字密钥`,
          arg: password,
        },
      ],
    }),
  );
}

export function generatePassword(length = DEFAULT_LENGTH) {
  if (!Number.isInteger(length) || length <= 0) {
    return "";
  }

  let password = "";

  for (let index = 0; index < length; index += 1) {
    password += CHARSET[randomInt(CHARSET.length)];
  }

  return password;
}

const entryUrl = process.argv[1]
  ? pathToFileURL(path.resolve(process.argv[1])).href
  : "";

if (import.meta.url === entryUrl) {
  main();
}
