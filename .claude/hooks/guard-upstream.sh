#!/bin/bash
# PreToolUse hook for the Bash tool (see .claude/settings.json).
# Lab rule: "Do not contribute to the upstream project."
# Exit code 2 blocks the command and shows the message below to the agent.
# Anything not matched here is allowed (exit 0).

UPSTREAM_OWNER="TheAlgorithms"
PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"

INPUT=$(cat)                                   # hook input is JSON on stdin
if command -v jq >/dev/null 2>&1; then
    COMMAND=$(printf '%s' "$INPUT" | jq -r '.tool_input.command // ""' 2>/dev/null)
else
    COMMAND="$INPUT"                           # no jq: fall back to scanning the raw JSON
fi
[[ -z "$COMMAND" ]] && exit 0

# "owner/repo" of the fork, read from the origin remote.
FORK=$(git -C "$PROJECT_DIR" remote get-url origin 2>/dev/null \
    | sed -E 's#^(git@github\.com:|https://github\.com/)##; s#\.git$##')

block() {
    echo "BLOCKED by guard-upstream.sh: $1" >&2
    exit 2
}
has() { printf '%s' "$COMMAND" | grep -Eiq -- "$1"; }

GH_WRITE='gh +(pr|issue) +(create|comment|edit|close|merge|review|reopen|ready)'

# 1. Pushing anywhere except the fork.
if has 'git +push'; then
    has "(upstream|$UPSTREAM_OWNER)" && block "git push must go to origin (the fork), never upstream."
    [[ "$FORK" == "$UPSTREAM_OWNER"/* ]] && block "origin points at $UPSTREAM_OWNER; fix the remote before pushing."
fi

# 2. Issues are an upstream thing; this lab never writes to them.
has 'gh +issue +(create|comment|edit|close|reopen)' && block "do not create or comment on issues."

# 3. Every PR write must name the fork explicitly, because gh defaults a fork's PRs to the parent repo.
if has "$GH_WRITE"; then
    [[ -z "$FORK" ]] && block "cannot read the origin remote, so the PR target cannot be verified."
    has "(--repo|-R)[ =]+$FORK( |\$)" || block "add '--repo $FORK' so the PR stays on the fork."
fi

# 4. Raw API writes to upstream.
if has "gh +api" && has "repos/$UPSTREAM_OWNER/" && has '(-X|--method|-f|-F|--field|--raw-field|--input)'; then
    block "no API writes to $UPSTREAM_OWNER."
fi

# 5. Text that makes GitHub post a mention on the upstream issue.
if has 'git +commit' || has "$GH_WRITE"; then
    has "($UPSTREAM_OWNER/[A-Za-z0-9_.-]+(#|/(issues|pull)/)[0-9]|(^|[^A-Za-z0-9&])#[0-9]+)" \
        && block "do not reference the upstream issue (URL, owner/repo#number or #number); write 'upstream issue <number>' in plain words."
fi

exit 0
