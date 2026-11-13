---
name: fork-and-pr
description: Checks the current fix branch against the project's contribution rules, pushes it to the fork, and opens a pull request against the fork's own master (never upstream). Use when asked to submit, push, open a PR, or finish the issue.
allowed-tools: Read, Grep, Glob, Bash, Write
---

# Fork and PR – submit a fix to the fork only

A repeatable procedure for turning a finished fix into a pull request on the fork. It does not
write or change algorithm code. If a check fails, stop and report; do not fix and continue silently.

## Steps

1. **Find the fork.** `git remote get-url origin` gives the fork as `OWNER/REPO`. If the owner
   is `TheAlgorithms`, stop: origin is not a fork.
2. **Check the branch.** `git branch --show-current` must not be `master`. If it is, stop and
   ask for a `fix-issue-<number>` branch.
3. **Check the scope.** `git diff --name-only master...HEAD` plus `git status --short`.
   The change must be exactly one `.py` algorithm file. Stop if `README.md`, `DIRECTORY.md`,
   `CLAUDE.md` or anything under `.claude/` appears.
4. **Run the project's checks on that file** (use `uvx`; if it is missing, use
   `python3 -m pip install ruff` and call `ruff` directly):
   - `python3 -m doctest -v path/to/file.py` – every doctest must pass.
   - `uvx ruff check path/to/file.py`
   - `uvx ruff format --check path/to/file.py`
   - `uvx pre-commit run --files path/to/file.py` – if it cannot run (no network or
     interpreter), say so in the report rather than skipping it silently.
5. **Commit** anything uncommitted with a short imperative message that describes the fix.
   No issue number, no URL.
6. **Push to the fork:** `git push -u origin <branch>`
7. **Write the PR body** to a temporary file outside the repo (for example
   `/tmp/pr-body.md`): copy `.github/pull_request_template.md`, tick `[x]` only for items that
   are true for this change (at least one box under "Describe your change"), add two or three
   sentences on what was wrong and how it was fixed, and end with `Fixes #<number>`.
   Do not link the upstream issue.
8. **Open the PR on the fork:**
   `gh pr create --repo OWNER/REPO --base master --head <branch> --title "<title>" --body-file /tmp/pr-body.md`
9. **Verify the target:** `gh pr view <url> --repo OWNER/REPO --json url,baseRefName,headRefName,files`
   The URL must start with `https://github.com/OWNER/REPO/` and `files` must list one file.

## Report format

### Checks
| Check | Result |
|---|---|
| Doctests | X passed / Y failed |
| ruff check | … |
| ruff format | … |
| pre-commit | … |

### Pull request
- URL
- Base ← head (must both be on the fork)
- Files changed

### Notes
1–3 bullets on anything the human should look at before recording the video.

## Rules
- Never push to `upstream` and never pass `--repo TheAlgorithms/...` to `gh`.
- Never merge the PR; the human decides that.
