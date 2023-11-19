import { getIcibaWord, translate } from "./translate.mjs";
import assert from "node:assert";
import { test } from "node:test";
import { downloadAndPlayMP3 } from "./play.mjs";
test("test translate", async (t) => {
  const result = await translate({
    from: "en",
    to: "zh",
    text: "hello",
  });
  // This test passes because it does not throw an exception.
  assert.strictEqual(result.text, "你好");
});

test("test getIcibaWord", async (t) => {
  const result = await getIcibaWord("hello");
  // This test passes because it does not throw an exception.
  console.log("result", result.symbols[0].parts);
});

test("play mp3", async (t) => {
  const result = await downloadAndPlayMP3(
    "http://res.iciba.com/resource/amp3/1/0/5d/41/5d41402abc4b2a76b9719d911017c592.mp3",
  );
  // This test passes because it does not throw an exception.
  console.log("result", result);
});
