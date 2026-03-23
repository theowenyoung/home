import assert from "node:assert";
import { test } from "node:test";
import { generatePassword } from "./pass.mjs";

test("generatePassword creates a 40-character lowercase alphanumeric string", () => {
  const password = generatePassword();

  assert.strictEqual(password.length, 40);
  assert.match(password, /^[a-z0-9]{40}$/);
});
