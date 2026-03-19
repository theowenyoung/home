---
name: git-commit
description: Summarize the current Git working tree and create a straightforward non-interactive commit. Use when Codex is asked to quickly commit the current work, commit everything currently changed, prepare a concise commit message from the diff, or avoid extra confirmation and commit splitting unless there is a real safety issue.
---

# Git Commit

Commit the current work with minimal ceremony. Default to summarizing the present working tree, staging it, and creating one clean commit.

## Workflow

1. Inspect the repository state.
   Run `git status --short`, `git diff --stat`, and `git log -5 --oneline`.
   Read local contribution rules such as `AGENTS.md`, `CONTRIBUTING.md`, or commit-message docs when they affect the message format or required safety checks.

2. Default to the current working tree.
   If the user asks to commit the current work and does not name a subset, treat all current staged, unstaged, and untracked changes as the intended commit.
   Prefer committing the full current diff over asking the user to split it.
   Only narrow the scope when the user explicitly asks for a partial commit.

3. Stop only for real blockers.
   Stop for an empty commit unless the user explicitly asks for one.
   Stop if Git is in the middle of a merge, rebase, cherry-pick, or revert.
   Stop if there are unresolved conflicts.
   Stop if the staging set would obviously include secrets, local env files, or machine-specific noise that should not be committed.

4. Keep verification lightweight by default.
   Do not proactively run extra checks just to create the commit unless the repository clearly requires them before every commit.
   Let existing Git hooks run normally.
   If a hook or required command fails, report the failure and stop.

5. Stage directly.
   Use `git add -A` by default when committing the full current working tree.
   Use explicit paths only when the user requested a partial commit.
   Avoid interactive staging flows unless there is no reliable non-interactive alternative.

6. Write a concise message from the diff.
   Summarize the outcome of the current working tree in plain, specific language.
   Keep the subject short, imperative, and concrete.
   Add a body only when it adds important context that is not obvious from the subject.

7. Create the commit non-interactively.
   Use `git commit -m "subject"` for subject-only commits.
   Use additional `-m` flags for a body when needed.
   Avoid `--amend` or other history rewrites unless the user explicitly asks.

8. Report the result.
   Show the new commit hash and subject.
   Summarize what was committed.
   State whether hooks or other checks ran, failed, or were skipped.
   State whether any changes remain in the working tree.

## Decision Rules

- If the user says "commit current changes" or equivalent, assume they want one commit for the full current diff.
- If the diff includes related source changes, tests, generated locale files, or formatting caused by the same task, keep them together.
- If unsure whether the user wants the whole diff, prefer the whole diff unless there is a concrete safety risk.
- Do not ask for confirmation just because the change touches multiple files or both code and tests.

## Command Pattern

```bash
git status --short
git diff --stat
git log -5 --oneline

git add -A
git commit -m "Update thread preview collection timeline"
```

## Output

Finish with:

- The commit hash and subject
- A concise summary of the committed change
- Whether hooks or checks ran, failed, or were skipped
- Whether any files remain modified, staged, or untracked
