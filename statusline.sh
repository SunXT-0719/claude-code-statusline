#!/bin/bash
# Claude Code statusline — three-line display:
#   Line 1: model name + git branch
#   Line 2: context window usage % + prompt cache hit rate %
#   Line 3: current working directory
#
# Install: copy this script to ~/.claude/statusline.sh, chmod +x, then add to
# ~/.claude/settings.json:
#   "statusLine": { "type": "command", "command": "bash ~/.claude/statusline.sh" }

input=$(cat)

MODEL=$(echo "$input" | jq -r '.model.display_name // "?"')
CWD=$(echo "$input" | jq -r '.cwd // .workspace.current_dir // ""')

# Get git branch
BRANCH=""
if [ -n "$CWD" ] && [ -d "$CWD/.git" ]; then
    BRANCH=$(git -C "$CWD" branch --show-current 2>/dev/null)
elif [ -n "$CWD" ]; then
    BRANCH=$(git -C "$CWD" rev-parse --abbrev-ref HEAD 2>/dev/null)
fi
[ -z "$BRANCH" ] && BRANCH="none"

# Context window usage percentage
CTX_PCT=$(echo "$input" | jq -r '.context_window.used_percentage // 0')
CTX_PCT=${CTX_PCT%.*}

# Cache hit rate
CACHE_READ=$(echo "$input" | jq -r '.context_window.current_usage.cache_read_input_tokens // 0')
CACHE_WRITE=$(echo "$input" | jq -r '.context_window.current_usage.cache_creation_input_tokens // 0')
INPUT_TOK=$(echo "$input" | jq -r '.context_window.current_usage.input_tokens // 0')

TOTAL_IN=$((CACHE_READ + CACHE_WRITE + INPUT_TOK))
if [ "$TOTAL_IN" -gt 0 ]; then
    HIT_RATE=$((CACHE_READ * 100 / TOTAL_IN))
else
    HIT_RATE=0
fi

# Output
echo "${MODEL} |  ${BRANCH}"
echo "ctx: ${CTX_PCT}% | cache: ${HIT_RATE}%"
echo "${CWD}"
