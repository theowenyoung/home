---
name: git-commit
description: Review the current Git working tree, choose safe commit boundaries, run proportionate verification, and create clean non-interactive commits with clear messages. Use when Codex is asked to commit current changes, prepare a commit message, split mixed edits into separate commits, or finish a task by making a Git commit in an existing repository.
---

# Git Commit

## Overview

Review the repository state before committing. Create focused, non-interactive commits that reflect the real change, preserve unrelated work, and leave a clear history entry.

## Workflow

1. Inspect the repository state.
   Run `git status --short`, `git diff --stat`, `git diff --cached --stat`, and `git log -5 --oneline`.
   Read local contribution rules such as `AGENTS.md`, `CONTRIBUTING.md`, or commit-message docs before deciding on the message format or required checks.
   Distinguish staged, unstaged, and untracked files. Stop instead of creating an empty commit unless the user explicitly asks for one.

2. Define the commit boundary.
   Group only files that serve one coherent purpose.
   Keep refactors, formatting-only edits, generated output, and behavior changes in separate commits unless they are inseparable.
   Do not sweep unrelated changes into the commit, especially when they were already present in the working tree.
   Stop and ask the user if the diff mixes concerns that cannot be separated safely.

3. Verify proportionally.
   Run the narrowest checks that match the changed surface area and the repository guidance.
   Prefer documented task runners or project scripts over ad-hoc commands.
   Fix failing checks before committing, or stop and report the failure.
   Do not bypass hooks with `--no-verify` unless the user explicitly asks.

4. Stage deliberately.
   Prefer explicit staging commands such as `git add path/to/file` and `git restore --staged path/to/file`.
   Use `git add -A` only when the entire working tree is intentionally part of the same commit.
   Avoid interactive staging flows when reliable non-interactive commands can express the same intent.

5. Write the commit message.
   Mirror repository conventions. Follow Conventional Commits only when the repo already uses them.
   Write the subject in imperative mood and keep it within 72 characters.
   Describe the outcome or behavior change, not the mechanics of editing files.
   Add a body only when extra context matters. Wrap body lines at 72 characters and explain why the change exists, important constraints, or follow-up work.

6. Create the commit non-interactively.
   Use `git commit -m "subject"` for subject-only commits.
   Use multiple `-m` flags for a body instead of opening an editor.
   Avoid `--amend`, rebases, force pushes, or other history rewrites unless the user explicitly asks.

7. Report the result.
   Show the new commit hash and subject.
   Summarize what was committed, what verification ran or was skipped, and whether changes remain in the working tree.

## Commit Message Rules

Use short, specific subjects such as:

- `Fix collection page pagination`
- `Add feed visibility setting`
- `Refactor post service slug handling`

Avoid vague subjects such as:

- `update files`
- `fix bug`
- `changes`
- `WIP`

## Decision Rules

- If only part of the current work should be committed, stage the smallest safe set and leave the rest unstaged.
- If staged content and working-tree content disagree, inspect both before committing.
- If the repository is in the middle of a merge, rebase, cherry-pick, or revert, stop and tell the user what state you found unless the task explicitly asks to finish that operation.
- If the selection would capture secrets, credentials, local env files, or machine-specific noise, stop and fix the staging set first.

## Command Pattern

```bash
git status --short
git diff --stat
git diff --cached --stat
git log -5 --oneline

# Stage only the intended files
git add path/to/file another/path

# Run repo-specific verification here

git commit -m "Add feed visibility setting" \
  -m "Hide private posts from generated feeds and update the settings UI."
```

## Output

Finish with:

- The commit hash and subject
- A concise summary of the committed change
- The verification that ran, or a clear note that checks were skipped
- Whether any files remain modified, staged, or untracked
