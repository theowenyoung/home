import assert from "node:assert";
import { test } from "node:test";
import { getBeijingTime, getUtcTime } from "./time.mjs";
test("test translate", async (t) => {
  const result = getBeijingTime(new Date("2021-09-13T03:05:16.000Z"));
  // This test passes because it does not throw an exception.
  assert.strictEqual(result, "2021-09-13 11:05:16 +0800");
});

test("test translate", async (t) => {
  const result = getUtcTime(new Date("2021-09-13T03:05:16.000Z"));

  // This test passes because it does not throw an exception.
  assert.strictEqual(result, "2021-09-13 03:05:16.000");
});
