# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

AI (Terminal-AI) is a Bash CLI toolkit that translates natural language into Linux shell commands (`ai`) or answers conversational queries (`aic`). It supports multiple LLM backends and is designed to be installed system-wide.

## Commands

```bash
ai "your prompt"   # returns a single shell command, no explanation
aic "your prompt"  # returns a plain-text conversational answer
cat file | aic "question about file"  # analyze file content via stdin
cat file | aic     # auto-analyze file content
ai --uninstall     # interactive uninstaller
```

## Repository layout

| Path | Purpose |
|------|---------|
| `ai` | Command-generator script |
| `aic` | Conversational assistant script |
| `install.sh` | Interactive installer (language, provider, PATH setup) |
| `setup.sh` | One-liner bootstrap (installs git, clones repo, runs installer) |
| `lang/ai_en.md` / `lang/ai_es.md` | English/Spanish system prompts for `ai` |
| `lang/aic_en.md` / `lang/aic_es.md` | English/Spanish system prompts for `aic` |

## Runtime configuration (`~/.ai/`)

All config lives in `~/.ai/` (created by the installer):

| File | Content |
|------|---------|
| `config` | INI-style config: active provider + per-provider sections (perms: `600`) |
| `ai_prompt.txt` | Active system prompt for `ai` (copied from `lang/`) |
| `aic_prompt.txt` | Active system prompt for `aic` (copied from `lang/`) |

### Config format (INI-style sections)

`~/.ai/config` uses INI-style sections. File permissions are enforced as `600` (created and auto-corrected by the installer).

```ini
provider=ollama

[ollama]
model=deepseek-r1:7b
has_prompt=n
host=http://localhost:11434

[deepseek]
api_key=sk-xxxxxxxxxxxxx
model=deepseek-chat

[moonshot]
api_key=sk-xxxxxxxxxxxxx
model=kimi-k2.5

[openai]
api_key=sk-xxxxxxxxxxxxx
model=gpt-4o-mini
```

Switching providers only updates the global `provider=` key; all other sections are preserved.

### Environment variable overrides

All config values can be overridden via environment variables (checked before the INI file):

| Env var | INI equivalent |
|---------|---------------|
| `AI_PROVIDER` | `provider=` (global) |
| `AI_OLLAMA_HOST` | `[ollama] host` |
| `AI_OLLAMA_MODEL` | `[ollama] model` |
| `AI_OLLAMA_HAS_PROMPT` | `[ollama] has_prompt` |
| `AI_DEEPSEEK_API_KEY` | `[deepseek] api_key` |
| `AI_DEEPSEEK_MODEL` | `[deepseek] model` |
| `AI_MOONSHOT_API_KEY` | `[moonshot] api_key` |
| `AI_MOONSHOT_MODEL` | `[moonshot] model` |
| `AI_OPENAI_API_KEY` | `[openai] api_key` |
| `AI_OPENAI_MODEL` | `[openai] model` |

## Dependencies

`bash`, `curl`, `jq`, `mktemp`. The installer handles these for Debian, Red Hat, Arch, and openSUSE families.

## One-line install mechanism

`setup.sh` supports piped execution (`curl ... | bash`) via automatic detection and re-execution:

1. **Detection**: `[ ! -t 0 ]` checks if stdin is not a terminal (piped)
2. **Re-execution**: Downloads itself to a temp file and re-runs with `< /dev/tty`
3. **Result**: Interactive prompts work even when piped from curl

This allows the recommended one-line install to work without manual download.

## Stdin support (aic only)

`aic` can read content from stdin (pipes) for file/content analysis:

1. **Detection**: `[ ! -t 0 ]` checks if stdin is not a terminal (piped content available)
2. **Reading**: `STDIN_CONTENT=$(cat)` captures all piped content
3. **Validation**: `tr -d '[:space:]'` removes all whitespace to check if content is truly empty
4. **Error handling**: Exits with helpful message if stdin is empty or only whitespace
5. **Combination**: Merges stdin content with user prompt, or auto-analyzes if no prompt given
6. **Use cases**: Code review, log analysis, config explanation, diff summaries

Example flow:
- `cat script.sh | aic "explain"` → prompt becomes: `"explain\n\nContent:\n<script content>"`
- `cat script.sh | aic` → prompt becomes: `"Analyze this content:\n\n<script content>"`
- `cat empty.txt | aic` → exits with error: "El contenido recibido está vacío"

## Architecture (both scripts follow the same pattern)

1. **Config load** — `get_config()` checks env var first, then reads from the INI file via `get_ini_value()` (awk-based section parser)
2. **OS detection** — `get_os_info()` reads `/etc/os-release` + `uname` for context
3. **System prompt** — loaded from `~/.ai/*_prompt.txt`; falls back to a built-in default
4. **JSON construction** — `jq -n --arg` to safely escape all user input
5. **Async request** — `curl` runs in a background subshell writing to a `mktemp` file
6. **Spinner** — polls `ps -p $pid` until the request finishes, then clears the line
7. **Output** — `ai` extracts `.response` (Ollama) or `.choices[0].message.content` (DeepSeek/Moonshot); `aic` passes the result through `colorize_output`

### Provider dispatch

Both scripts use a `case $PROVIDER in ollama|deepseek|moonshot) ... esac` block. Adding a new provider requires:
- A `call_<provider>()` function in both `ai` and `aic`
- A new `case` branch in each script that calls `get_config` for its credentials
- A new branch in `install.sh`'s `configure_provider()` that calls `update_ini_value()`

### Config helpers (install.sh)

- `get_ini_value <section> <key>` — reads a value from a named section (or global if section is empty)
- `update_ini_value <section> <key> <value>` — upserts a value, creating the section if needed, then enforces `chmod 600`
