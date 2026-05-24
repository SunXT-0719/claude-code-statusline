#!/bin/bash
# Claude Code statusline — three-line display:
#   Line 1: model name + git branch
#   Line 2: context window usage % + prompt cache hit rate % + session cost
#   Line 3: current working directory

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

# Check if current_usage is available (null before first API call and after /compact)
HAS_USAGE=$(echo "$input" | jq -r '.context_window.current_usage != null')

if [ "$HAS_USAGE" = "true" ]; then
    CACHE_READ=$(echo "$input" | jq -r '.context_window.current_usage.cache_read_input_tokens // 0')
    CACHE_WRITE=$(echo "$input" | jq -r '.context_window.current_usage.cache_creation_input_tokens // 0')
    INPUT_TOK=$(echo "$input" | jq -r '.context_window.current_usage.input_tokens // 0')
    OUTPUT_TOK=$(echo "$input" | jq -r '.context_window.current_usage.output_tokens // 0')

    TOTAL_IN=$((CACHE_READ + CACHE_WRITE + INPUT_TOK))
    if [ "$TOTAL_IN" -gt 0 ]; then
        HIT_RATE=$((CACHE_READ * 100 / TOTAL_IN))
    else
        HIT_RATE=0
    fi

    # Cost estimate (CNY) — DeepSeek V4 Pro pricing per 1M tokens:
    #   cache hit:  ¥0.025 | cache miss: ¥3 | output: ¥6
    COST=$(awk -v cr="$CACHE_READ" -v cw="$CACHE_WRITE" -v it="$INPUT_TOK" -v ot="$OUTPUT_TOK" \
        'BEGIN { printf "%.2f", (cr * 0.025 + (cw + it) * 3 + ot * 6) / 1000000 }')

    echo "${MODEL} |  ${BRANCH}"
    echo "ctx: ${CTX_PCT}% | cache: ${HIT_RATE}% | ¥${COST}"
else
    echo "${MODEL} |  ${BRANCH}"
    echo "ctx: ${CTX_PCT}% | cache: - | ¥ -"
fi

echo "${CWD}"
