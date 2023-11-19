import { exec } from "child_process";
import fs from "fs";
import os from "os";
import path from "path";
import { randomBytes } from "crypto";
import url from "url";
function createTempFile(prefix, extension) {
  const tempDir = os.tmpdir();
  const fileName = `${prefix}-${randomBytes(16).toString("hex")}.${extension}`;
  const filePath = path.join(tempDir, fileName);
  // 创建一个空文件
  fs.writeFileSync(filePath, "");
  return filePath;
}

export async function downloadAndPlayMP3(url) {
  try {
    const filename = createTempFile("alfred-workflow-all-in-one-temp", "mp3");
    const response = await fetch(url, {
      headers: {
        "User-Agent":
          "Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:109.0) Gecko/20100101 Firefox/119.0",
      },
    });

    if (!response.ok) {
      throw new Error(
        `Error fetching MP3:${response.status}, ${response.statusText}`,
      );
    }

    const buffer = await response.arrayBuffer();
    fs.writeFileSync(filename, Buffer.from(buffer));

    const playerCommand = getPlayerCommand();
    if (!playerCommand) {
      throw new Error("No suitable audio player found.");
    }

    return new Promise((resolve, reject) => {
      exec(`${playerCommand} ${filename}`, (err) => {
        // 删除临时文件
        fs.unlinkSync(filename);

        if (err) {
          const err = new Error(`Error executing play command: ${err}`);
          reject(err);
        } else {
          resolve();
        }
      });
    });
  } catch (err) {
    throw err; // 将错误向上抛出
  }
}

function getPlayerCommand() {
  // 这里检查不同操作系统上的常见音频播放软件
  if (process.platform === "darwin") {
    return "afplay"; // 对于 macOS
  } else if (process.platform === "win32") {
    return ""; // 可以填写 Windows 上的一个命令
  } else {
    // 对于 Linux 和其他系统，检查几个常见的播放器
    const players = ["aplay", "mpg123"];
    for (let player of players) {
      if (isCommandExists(player)) {
        return player;
      }
    }
  }
  return null;
}

function isCommandExists(command) {
  try {
    const result = exec(`which ${command}`);
    return !!result;
  } catch (e) {
    return false;
  }
}

const argvs = process.argv.slice(2);
console.log("argvs", argvs);
const sourceUrl = argvs[0];
if (sourceUrl) {
  downloadAndPlayMP3(sourceUrl);
}
