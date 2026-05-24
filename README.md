# Claude Code Statusline

A minimal status bar for Claude Code showing model name, git branch, context window usage, prompt cache hit rate, and session cost (CNY).

## Preview

```
Opus |  main
ctx: 12% | cache: 68% | ¥0.03
/home/user/projects/my-app
```

## Requirements

- `bash`
- `jq` — install with `apt install jq` / `brew install jq`
- `git` — for the branch display

## Install

### 1. Copy the script

```bash
cp statusline.sh ~/.claude/statusline.sh
chmod +x ~/.claude/statusline.sh
```

### 2. Update settings.json

Add the following to `~/.claude/settings.json` (global, applies to all projects):

```json
{
  "statusLine": {
    "type": "command",
    "command": "bash ~/.claude/statusline.sh"
  }
}
```

If you already have other settings, merge `statusLine` into the existing file rather than replacing it.

### 3. Restart

Open a new Claude Code session — the status bar appears immediately.

## What each line shows

| Line | Field | Source |
|---|---|---|
| 1 | Model name | `model.display_name` from stdin JSON |
| 1 | Git branch | `git branch --show-current` in the working directory |
| 2 | Context usage % | `context_window.used_percentage` — input tokens / context window size |
| 2 | Cache hit rate % | `cache_read / (input + cache_creation + cache_read)` from the last API call |
| 2 | Session cost (¥) | Estimated cost in CNY based on token usage and DeepSeek V4 Pro pricing |
| 3 | Working directory | `cwd` from stdin JSON (the project directory Claude Code is running in) |

> **Note:** Before the first API call (and after `/compact`), `current_usage` is `null`. Cache hit rate and session cost display `-` in this case.
