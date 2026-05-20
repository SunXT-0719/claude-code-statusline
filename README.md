# Claude Code Statusline

A minimal two-line status bar for Claude Code showing model name, git branch, context window usage, and prompt cache hit rate.

## Preview

```
Opus |  main
ctx: 12% | cache: 68%
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
| 3 | Working directory | `cwd` from stdin JSON (the project directory Claude Code is running in) |

> **Note:** Before the first API call (and after `/compact`), `current_usage` is `null` and the cache hit rate shows `0%`. This is expected.
