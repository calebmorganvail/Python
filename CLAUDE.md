# Project Memory – Lab 6: contribute to TheAlgorithms/Python from a fork

<!-- Always loaded. Kept short on purpose: the contribution rules already live in
     CONTRIBUTING.md and AGENTS.md, so this file points at them instead of repeating them. -->

## Goal
Resolve ONE open issue from TheAlgorithms/Python inside this fork, following the project's
own contribution rules, and open the pull request **against this fork only**.

## Read first
- @AGENTS.md (short, imported here).
- `CONTRIBUTING.md` – read it in full before changing any code. It wins over this file
  whenever the two disagree about code style or tests.

## Non-negotiable rules
- **Never contribute upstream.** No pushes, pull requests, comments or issues on
  `TheAlgorithms/Python`. `origin` is the fork; `upstream` is read-only.
  A PreToolUse hook (`.claude/hooks/guard-upstream.sh`) blocks these commands.
- **Do not notify upstream by accident.** Never write the issue's URL,
  `TheAlgorithms/Python#<number>` or a bare `#<number>` in a commit message, PR title or PR
  body: in a fork, GitHub resolves all three to the upstream issue and posts a link on it.
  This is a deliberate exception to CONTRIBUTING.md's `Fixes #<number>` request, because the
  lab forbids contributing upstream. Refer to it in plain words: `upstream issue <number>`.
- **One algorithm file per PR.** The PR diff must contain only the fix.
  Never edit `README.md`, `DIRECTORY.md`, `CLAUDE.md` or anything under `.claude/` on a fix branch.
- **Do not edit existing doctests in a code-fix PR.** Add a new doctest only when the fix
  would otherwise be unverified, and say so in the PR description.
- **Never invent doctest output.** Run the code and paste the real result. When a standard
  library reference exists (for example `zlib`, `hashlib`, `base64`), compare against it.
- Work on a branch named `fix-issue-<number>`, never directly on `master`.

## Workflow
1. Read the issue and the affected file. State the bug and the smallest fix before editing.
2. Make the change on the fix branch.
3. Delegate a review to the `contribution-reviewer` sub-agent (paste the diff into its prompt).
4. Run the `fork-and-pr` skill to check, push and open the PR on the fork.

## Code features (and why)
- **Hook** – `guard-upstream.sh`: turns "do not contribute upstream" from advice into a hard block.
- **Skill** – `fork-and-pr`: one repeatable procedure for checks, push and PR, so the PR
  always targets the fork and always uses the project's PR template.
- **Sub-agent** – `contribution-reviewer`: a read-only second opinion with its own context,
  checking the diff against CONTRIBUTING.md before anything is pushed.
