# AI Shell Integration

## Quick Execute with Ctrl+Enter

### Option 1: Bash Function (Recommended)

Add to your `~/.bashrc`:

```bash
# AI quick execute function
tx() {
  ai -x "$@"
}

# Or keep the full name
ai-exec() {
  ai -x "$@"
}
```

Then reload:
```bash
source ~/.bashrc
```

Usage:
```bash
tx "lista los archivos"
# Same as: ai -x "lista los archivos"
```

### Option 2: Readline Binding (Advanced)

This creates a custom key binding that adds `-x` flag automatically.

Add to `~/.inputrc`:

```bash
# Bind Ctrl+X to insert "ai -x " at the beginning
"\C-x": "\C-aai -x \C-e"
```

Then reload:
```bash
bind -f ~/.inputrc
```

Usage:
1. Type: `lista los archivos`
2. Press `Ctrl+X`
3. Result: `ai -x lista los archivos`
4. Press Enter to execute

### Option 3: Bash Alias

Add to `~/.bashrc`:

```bash
alias tx='ai -x'
```

Usage:
```bash
tx "lista los archivos"
```

### Option 4: ZSH Widget (for ZSH users)

Add to `~/.zshrc`:

```zsh
# AI execute widget
ai-execute-widget() {
  BUFFER="ai -x \"$BUFFER\""
  zle accept-line
}

zle -N ai-execute-widget
bindkey '^X' ai-execute-widget  # Ctrl+X
```

Usage:
1. Type: `lista los archivos`
2. Press `Ctrl+X`
3. Automatically executes: `ai -x "lista los archivos"`

## Why Not Ctrl+Enter?

**Technical Limitation**: Most terminals don't send a distinct signal for Ctrl+Enter. It's usually interpreted as just Enter.

**Workaround**: Use Ctrl+X or another key combination that terminals can reliably detect.

## Recommended Setup

For the best experience, add this to your `~/.bashrc`:

```bash
# AI shortcuts
alias tx='ai -x'            # Quick execute mode
alias t='ai'                # Regular mode
alias tc='aic'              # Conversational mode

# Optional: Function with better error handling
ai-run() {
  if [ -z "$1" ]; then
    echo "Usage: ai-run \"your question\""
    return 1
  fi
  ai -x "$@"
}
```

Then:
```bash
source ~/.bashrc
```

Now you can use:
- `t "question"` - Generate command only
- `tx "question"` - Generate and prompt to execute
- `tc "question"` - Conversational mode
