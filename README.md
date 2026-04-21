# AI - Agnostic Intelligence. A minimal Terminal-AI utility

A minimalistic CLI tool that translates natural language into shell commands or provides quick AI responses directly in your terminal. Works on Linux and macOS.

## How to use

Ask directly in your terminal to generate shell commands ready to execute.

Example:
```bash
ai "how do I extract a tar.gz file"
# Output: tar -xzf archivo.tar.gz
```


## Features

- 🚀 **Fast & Lightweight** - No heavy dependencies, just bash and curl
- 🎯 **Two Modes** - Command generation (`ai`) and conversational queries (`aic`)
- 🔌 **Multiple Providers** - Support for Ollama (local), DeepSeek, Moonshot/Kimi, and OpenAI (API)
- 🧠 **Context-Aware** - Automatically detects your OS, kernel, and architecture for precise commands
- 📄 **File Analysis** - `aic` can read and analyze files via stdin (pipes)
- ⚙️ **Interactive Setup** - First-run configuration wizard
- 🎨 **Clean Output** - Minimal, distraction-free responses

## Installation

### One-Line Install (Recommended)

```bash
curl -fsSL https://raw.githubusercontent.com/mhito/ai/main/setup.sh | bash
```

The script will automatically detect piped execution and re-run with proper stdin for interactive prompts.

**Alternative methods:**

Download and run:
```bash
curl -fsSL https://raw.githubusercontent.com/mhito/ai/main/setup.sh -o setup.sh && bash setup.sh
```

Using wget:
```bash
wget https://raw.githubusercontent.com/mhito/ai/main/setup.sh && bash setup.sh
```

**The setup script will:**
- ✅ Install `git` if not present
- ✅ Clone the repository to `~/.ai`
- ✅ Run the installer automatically

The installer will:
- ✅ Ask for your preferred language (English/Español)
- ✅ Detect your OS and architecture (Linux/macOS)
- ✅ Install dependencies (`curl`, `jq`)
  - On macOS: Uses Homebrew (installs it if needed)
  - On Linux: Uses your package manager (apt, dnf, pacman, zypper)
- ✅ Configure language-specific prompts
- ✅ Configure LLM provider (Ollama, DeepSeek, Moonshot/Kimi, or OpenAI)
- ✅ Install `ai` and `aic` commands
- ✅ Guide you through the setup

### Manual Installation

```bash
# Clone the repository
git clone https://github.com/mhito/ai.git ~/.ai
cd ~/.ai

# Run the installer
chmod +x install.sh
./install.sh
```

### Supported Systems

- **macOS** (macOS 10.15+, both Intel and Apple Silicon)
- **Debian/Ubuntu** (Ubuntu, Pop!_OS, Linux Mint, Debian)
- **Red Hat** (Fedora, RHEL, CentOS, Rocky Linux, AlmaLinux)
- **Arch** (Arch Linux, Manjaro, EndeavourOS)
- **openSUSE** (openSUSE, SLES)
- **Other** (manual dependency installation required)

## Usage

### `ai` - Command Generator

Converts natural language into shell commands.

```bash
ai "how do I extract a tar.gz file"
# Output: tar -xzf archivo.tar.gz

ai "find all python files in current directory"
# Output: find . -name "*.py"

ai "show disk usage"
# Output: df -h
```

**Behavior:**
- Returns ONLY the command
- No explanations
- No extra text
- Ready to copy/paste or execute

**Execute Mode:**

There are three ways to enter execute mode:

1. **Using the `-x` or `--execute` flag:**
```bash
ai -x "show disk usage"
# Output: df -h
# run <df -h>? (Y/n): 
```

2. **Using `!` at the end of your question (recommended):**
```bash
ai "show disk usage!"
# Output: df -h
# run <df -h>? (Y/n): 
```

3. **Escape `!` with `\!` to prevent execution:**
```bash
ai "show disk usage\!"
# Output: df -h
# (no execution prompt)
```

Press Enter or type `Y` to execute, or type `n` to cancel.

### `aic` - Conversational Mode

Quick questions and answers with the LLM.

```bash
aic "what OS am I using"
# Output: You are using Ubuntu 24.04.4 LTS with kernel Linux 6.17.0-20-generic on x86_64 architecture.

aic "how do I shutdown my computer"
# Output: [Detailed explanation with multiple options]
```

**File Analysis (stdin support):**

`aic` can read content from stdin, allowing you to analyze files or command output:

```bash
# Analyze a file
cat script.sh | aic "explain what this script does"

# Analyze without specific question (auto-analysis)
cat config.json | aic

# Analyze command output
ls -la | aic "summarize the directory contents"

# Analyze logs
tail -n 50 /var/log/syslog | aic "are there any errors?"
```

**Note:** `aic` validates that piped content is not empty. If you pipe an empty file, you'll get an error message asking you to verify the file has content.

**Behavior:**
- Returns direct answers
- No command generation
- Brief but informative
- Plain text output (no markdown)
- **Supports stdin**: Can analyze piped content

## Configuration

### During Installation

The installer will guide you through the configuration process:

**1. Language Selection:**
```
🌍 Language Selection / Selección de Idioma

Select your preferred language for AI prompts:
1) English
2) Español
```

**2. Provider Selection:**
```
⚙️  Configuring LLM Provider...

Select LLM Provider:
1) Ollama (local)
2) DeepSeek (API)
3) Moonshot/Kimi (API)
4) OpenAI (API)
```

### Ollama Setup

If you choose Ollama:

```
🧠 Ollama Configuration

Ollama host (default: http://localhost:11434): 
Model (e.g., llama3, deepseek-r1:7b): deepseek-r1:7b
Does the model already have a system prompt? (y/n): n
```

**Note:** Make sure Ollama is already installed and running. To install Ollama:
```bash
curl -fsSL https://ollama.ai/install.sh | sh
```

### DeepSeek Setup

If you choose DeepSeek:

```
🧠 DeepSeek Configuration

API Key: sk-xxxxxxxxxxxxx
```

Default model: `deepseek-chat`

### OpenAI Setup

If you choose OpenAI:

```
🧠 OpenAI Configuration

API Key: sk-xxxxxxxxxxxxx
Model (default: gpt-4o-mini): 
```

Default model: `gpt-4o-mini`

### Configuration Files

Settings are stored in `~/.ai/`. The config file is created with `600` permissions to protect API keys.

**Provider configuration** (`~/.ai/config`):
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

The file stores all providers simultaneously. Switching providers only changes the global `provider=` line — other sections are preserved.

**Language prompts**:
- `~/.ai/ai_prompt.txt` - Command generator prompt
- `~/.ai/aic_prompt.txt` - Conversational assistant prompt

You can manually edit these files to change providers, settings, or customize prompts.

### Environment Variable Overrides

All config values can be set via environment variables (take precedence over the config file):

```bash
export AI_PROVIDER=deepseek
export AI_DEEPSEEK_API_KEY=sk-xxxxxxxxxxxxx
ai "list running containers"
```

| Variable | Description |
|----------|-------------|
| `AI_PROVIDER` | Active provider (`ollama`, `deepseek`, `moonshot`, `openai`) |
| `AI_OLLAMA_HOST` | Ollama server URL |
| `AI_OLLAMA_MODEL` | Ollama model name |
| `AI_OLLAMA_HAS_PROMPT` | Whether model has built-in system prompt (`y`/`n`) |
| `AI_DEEPSEEK_API_KEY` | DeepSeek API key |
| `AI_DEEPSEEK_MODEL` | DeepSeek model name |
| `AI_MOONSHOT_API_KEY` | Moonshot API key |
| `AI_MOONSHOT_MODEL` | Moonshot model name |
| `AI_OPENAI_API_KEY` | OpenAI API key |
| `AI_OPENAI_MODEL` | OpenAI model name |

### Language Support

AI supports multiple languages for prompts:

- **English** - Default language
- **Español** - Spanish language support

During installation, you'll be asked to select your preferred language. The system prompts will be configured accordingly.

To change the language after installation, run the installer again and select a new language, or copy the prompt files from the repository:

```bash
# Switch to Spanish (from the cloned repo directory)
cp /path/to/ai-repo/lang/ai_es.md ~/.ai/ai_prompt.txt
cp /path/to/ai-repo/lang/aic_es.md ~/.ai/aic_prompt.txt

# Switch to English
cp /path/to/ai-repo/lang/ai_en.md ~/.ai/ai_prompt.txt
cp /path/to/ai-repo/lang/aic_en.md ~/.ai/aic_prompt.txt
```

## Supported Providers

### Ollama (Local)

- **Pros:** Privacy, no API costs, works offline
- **Cons:** Requires local setup and resources
- **Setup:** Install [Ollama](https://ollama.ai/) and pull a model before running AI installer

```bash
# Install Ollama
curl -fsSL https://ollama.ai/install.sh | sh

# Pull a model
ollama pull deepseek-r1:7b

# Start Ollama (if not running)
ollama serve
```

The AI installer will ask for the Ollama host and port (default: `http://localhost:11434`).

### DeepSeek (API)

- **Pros:** No local resources needed, fast responses
- **Cons:** Requires API key, internet connection
- **Setup:** Get an API key from [DeepSeek](https://platform.deepseek.com/)

### Moonshot/Kimi (API)

- **Pros:** No local resources needed, strong reasoning capabilities
- **Cons:** Requires API key, internet connection
- **Default model:** `kimi-k2.5`
- **Setup:** Get an API key from [Moonshot](https://platform.moonshot.cn/)

### OpenAI (API)

- **Pros:** Industry-standard models, broad capability
- **Cons:** Requires API key, internet connection, paid usage
- **Default model:** `gpt-4o-mini`
- **Setup:** Get an API key from [OpenAI](https://platform.openai.com/)

## Design Principles

- **Minimalistic** - Do one thing well
- **Fast** - Instant responses, no bloat
- **Terminal-first** - Designed for CLI workflows
- **No chat interface** - Single query, single response
- **No unnecessary output** - Just what you need

## How It Works

1. **OS Detection** - Automatically detects your system info
2. **Prompt Construction** - Builds context-aware prompts
3. **LLM Query** - Sends request to configured provider
4. **Response Parsing** - Extracts and formats the answer
5. **Output** - Displays clean, actionable results

## Examples

### Command Generation

```bash
# File operations
ai "create a directory called projects"
# mkdir projects

ai "copy all jpg files to backup folder"
# cp *.jpg backup/

# System information
ai "check memory usage"
# free -h

ai "list running processes"
# ps aux

# Network
ai "check my IP address"
# curl ifconfig.me

ai "test connection to google.com"
# ping google.com
```

### Execute Mode Examples

```bash
# Quick execute with !
ai "list all files!"
# ls
# run <ls>? (Y/n): [Press Enter to execute]

ai "show current directory!"
# pwd
# run <pwd>? (Y/n): 

# Prevent execution with \!
ai "show files\!"
# ls
# (no execution prompt, just shows the command)

# Using -x flag
ai -x "check disk space"
# df -h
# run <df -h>? (Y/n):
```

### Conversational Queries

```bash
# Quick facts
aic "what is the capital of France"

# System help
aic "how do I check if a service is running"

# Explanations
aic "what does chmod 755 mean"
```

### File Analysis

```bash
# Analyze a bash script
cat install.sh | aic "what does this script do?"

# Review code
cat app.py | aic "find potential bugs or improvements"

# Understand configuration
cat nginx.conf | aic "explain this configuration"

# Analyze logs for errors
tail -100 /var/log/syslog | aic "are there any critical errors?"

# Auto-analyze (no specific question)
cat README.md | aic

# Analyze git diff
git diff | aic "summarize the changes"

# Check JSON structure
cat package.json | aic "what dependencies does this project have?"
```

## Uninstallation

To completely remove AI from your system:

```bash
ai --uninstall
```

This will:
- Remove `ai` and `aic` commands from `/usr/local/bin`
- Delete configuration files in `~/.ai/`
- Optionally remove PATH entries from `~/.bashrc`

## Troubleshooting

### Command not found

Make sure the scripts are executable and in your PATH:

```bash
chmod +x ai aic
echo 'export PATH="$PATH:/path/to/ai"' >> ~/.bashrc
source ~/.bashrc
```

### Ollama connection error

Check if Ollama is running:

```bash
systemctl status ollama
# or
ollama serve
```

### DeepSeek API error

Verify your API key in `~/.ai/config` and check your internet connection.

## Roadmap

- [x] Command execution (optional, with safety checks)
- [x] Support for multiple LLM providers (Ollama, DeepSeek, Moonshot/Kimi, OpenAI)
- [ ] History and learning from user preferences
- [ ] Multi-step command generation
- [ ] Shell integration (autocomplete, suggestions)
- [ ] Support for more LLM providers (Anthropic, Gemini, etc.)

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

MIT License - feel free to use this project however you want.

## Author

Created with ❤️ for terminal enthusiasts who want AI assistance without leaving the command line.

## Acknowledgments

- Inspired by the need for quick, context-aware command assistance
- Built on the shoulders of amazing projects like Ollama and DeepSeek
- Thanks to the open-source community

---

**Note:** This tool is designed to assist, not replace learning. Always understand commands before executing them, especially those requiring `sudo`.
