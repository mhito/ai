#!/bin/bash

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
RESET='\033[0m'

# Installation directory (current directory where install.sh is located)
INSTALL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo -e "${CYAN}${BOLD}"
echo "╔════════════════════════════════════════╗"
echo "║     AI (Terminal-AI) Installer        ║"
echo "╚════════════════════════════════════════╝"
echo -e "${RESET}"

# Detect OS and Architecture
detect_system() {
    OS="unknown"
    ARCH=$(uname -m)
    
    # Detect macOS
    if [[ "$OSTYPE" == "darwin"* ]]; then
        OS="macos"
        OS_VERSION=$(sw_vers -productVersion 2>/dev/null || echo "Unknown")
        OS_NAME="macOS $OS_VERSION"
    elif [ -f /etc/os-release ]; then
        . /etc/os-release
        OS=$ID
        OS_VERSION=$VERSION_ID
        OS_NAME=$PRETTY_NAME
    elif [ -f /etc/lsb-release ]; then
        . /etc/lsb-release
        OS=$DISTRIB_ID
        OS_VERSION=$DISTRIB_RELEASE
        OS_NAME=$DISTRIB_DESCRIPTION
    fi
    
    echo -e "${BLUE}📋 System Information:${RESET}"
    echo -e "   OS: ${GREEN}$OS_NAME${RESET}"
    echo -e "   Architecture: ${GREEN}$ARCH${RESET}"
    echo ""
}

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Select language
select_language() {
    echo -e "${CYAN}${BOLD}🌍 Language Selection / Selección de Idioma${RESET}"
    echo ""
    echo "Select your preferred language for AI prompts:"
    echo "Selecciona tu idioma preferido para los prompts de AI:"
    echo ""
    echo "1) English"
    echo "2) Español"
    echo ""
    echo -n "Select option / Selecciona opción [1-2]: "
    read -r lang_choice
    
    case $lang_choice in
        1)
            SELECTED_LANG="en"
            echo -e "${GREEN}✓ Language set to English${RESET}"
            ;;
        2)
            SELECTED_LANG="es"
            echo -e "${GREEN}✓ Idioma configurado a Español${RESET}"
            ;;
        *)
            echo -e "${YELLOW}Invalid option. Defaulting to English.${RESET}"
            SELECTED_LANG="en"
            ;;
    esac
    echo ""
}

# Install dependencies based on OS
install_dependencies() {
    echo -e "${YELLOW}📦 Installing dependencies...${RESET}"
    echo ""
    
    case "$OS" in
        macos)
            echo -e "${BLUE}Detected macOS${RESET}"
            
            # Check if Homebrew is installed
            if ! command_exists brew; then
                echo -e "${YELLOW}Homebrew not found. Installing Homebrew...${RESET}"
                /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
                
                # Add Homebrew to PATH for Apple Silicon Macs
                if [[ "$ARCH" == "arm64" ]] && [ -f /opt/homebrew/bin/brew ]; then
                    eval "$(/opt/homebrew/bin/brew shellenv)"
                fi
            fi
            
            if ! command_exists git; then
                echo "  Installing git..."
                brew install git
            fi
            
            if ! command_exists curl; then
                echo "  Installing curl..."
                brew install curl
            fi
            
            if ! command_exists jq; then
                echo "  Installing jq..."
                brew install jq
            fi
            ;;
            
        ubuntu|debian|pop|linuxmint)
            echo -e "${BLUE}Detected Debian-based system${RESET}"
            sudo apt-get update -qq
            
            if ! command_exists git; then
                echo "  Installing git..."
                sudo apt-get install -y git
            fi
            
            if ! command_exists curl; then
                echo "  Installing curl..."
                sudo apt-get install -y curl
            fi
            
            if ! command_exists jq; then
                echo "  Installing jq..."
                sudo apt-get install -y jq
            fi
            ;;
            
        fedora|rhel|centos|rocky|almalinux)
            echo -e "${BLUE}Detected Red Hat-based system${RESET}"
            
            if ! command_exists git; then
                echo "  Installing git..."
                sudo dnf install -y git || sudo yum install -y git
            fi
            
            if ! command_exists curl; then
                echo "  Installing curl..."
                sudo dnf install -y curl || sudo yum install -y curl
            fi
            
            if ! command_exists jq; then
                echo "  Installing jq..."
                sudo dnf install -y jq || sudo yum install -y jq
            fi
            ;;
            
        arch|manjaro|endeavouros)
            echo -e "${BLUE}Detected Arch-based system${RESET}"
            
            if ! command_exists git; then
                echo "  Installing git..."
                sudo pacman -S --noconfirm git
            fi
            
            if ! command_exists curl; then
                echo "  Installing curl..."
                sudo pacman -S --noconfirm curl
            fi
            
            if ! command_exists jq; then
                echo "  Installing jq..."
                sudo pacman -S --noconfirm jq
            fi
            ;;
            
        opensuse*|sles)
            echo -e "${BLUE}Detected openSUSE-based system${RESET}"
            
            if ! command_exists git; then
                echo "  Installing git..."
                sudo zypper install -y git
            fi
            
            if ! command_exists curl; then
                echo "  Installing curl..."
                sudo zypper install -y curl
            fi
            
            if ! command_exists jq; then
                echo "  Installing jq..."
                sudo zypper install -y jq
            fi
            ;;
            
        *)
            echo -e "${RED}⚠️  Unknown distribution: $OS${RESET}"
            echo -e "${YELLOW}Please install git, curl and jq manually${RESET}"
            
            if ! command_exists git || ! command_exists curl || ! command_exists jq; then
                echo -e "${RED}Missing dependencies. Exiting.${RESET}"
                exit 1
            fi
            ;;
    esac
    
    echo -e "${GREEN}✓ Dependencies installed${RESET}"
    echo ""
}

# Verify dependencies
verify_dependencies() {
    echo -e "${YELLOW}🔍 Verifying dependencies...${RESET}"
    
    MISSING_DEPS=()
    
    if ! command_exists bash; then
        MISSING_DEPS+=("bash")
    fi
    
    if ! command_exists git; then
        MISSING_DEPS+=("git")
    fi
    
    if ! command_exists curl; then
        MISSING_DEPS+=("curl")
    fi
    
    if ! command_exists jq; then
        MISSING_DEPS+=("jq")
    fi
    
    if [ ${#MISSING_DEPS[@]} -eq 0 ]; then
        echo -e "${GREEN}✓ All dependencies are installed${RESET}"
        echo ""
        return 0
    else
        echo -e "${RED}✗ Missing dependencies: ${MISSING_DEPS[*]}${RESET}"
        return 1
    fi
}

# Configure language prompts
configure_prompts() {
    echo -e "${YELLOW}📝 Configuring language prompts...${RESET}"
    echo ""
    
    # Create config directory if it doesn't exist
    mkdir -p "$HOME/.ai"
    
    # Copy prompt files based on selected language
    if [ -f "$INSTALL_DIR/lang/ai_${SELECTED_LANG}.md" ]; then
        cp "$INSTALL_DIR/lang/ai_${SELECTED_LANG}.md" "$HOME/.ai/ai_prompt.txt"
        echo -e "${GREEN}✓ AI prompt configured (${SELECTED_LANG})${RESET}"
    else
        echo -e "${RED}✗ AI prompt file not found for language: ${SELECTED_LANG}${RESET}"
    fi
    
    if [ -f "$INSTALL_DIR/lang/aic_${SELECTED_LANG}.md" ]; then
        cp "$INSTALL_DIR/lang/aic_${SELECTED_LANG}.md" "$HOME/.ai/aic_prompt.txt"
        echo -e "${GREEN}✓ AIC prompt configured (${SELECTED_LANG})${RESET}"
    else
        echo -e "${RED}✗ AIC prompt file not found for language: ${SELECTED_LANG}${RESET}"
    fi
    
    echo ""
}

# Helper function to read INI value
get_ini_value() {
    local section="$1"
    local key="$2"
    local config_file="$HOME/.ai/config"
    
    if [ ! -f "$config_file" ]; then
        return
    fi
    
    # If no section (global), read from top
    if [ -z "$section" ]; then
        grep "^${key}=" "$config_file" | head -n1 | cut -d'=' -f2-
    else
        # Read from specific section
        awk -v section="$section" -v key="$key" '
            /^\[.*\]$/ { in_section=0 }
            $0 == "["section"]" { in_section=1; next }
            in_section && $0 ~ "^"key"=" { sub("^"key"=", ""); print; exit }
        ' "$config_file"
    fi
}

# Helper function to update or add INI value
update_ini_value() {
    local section="$1"
    local key="$2"
    local value="$3"
    local config_file="$HOME/.ai/config"
    local temp_file="$HOME/.ai/config.tmp"
    
    # Create config directory if it doesn't exist
    mkdir -p "$HOME/.ai"
    
    # If config doesn't exist, create it with secure permissions
    if [ ! -f "$config_file" ]; then
        touch "$config_file"
        chmod 600 "$config_file"
    fi
    
    # If no section (global variable)
    if [ -z "$section" ]; then
        # Check if key exists at global level
        if grep -q "^${key}=" "$config_file"; then
            # Replace existing global key
            sed "s|^${key}=.*|${key}=${value}|" "$config_file" > "$temp_file"
            mv "$temp_file" "$config_file"
        else
            # Add to top of file
            echo "${key}=${value}" | cat - "$config_file" > "$temp_file"
            mv "$temp_file" "$config_file"
        fi
    else
        # Check if section exists
        if grep -q "^\[${section}\]$" "$config_file"; then
            # Section exists, update or add key
            awk -v section="$section" -v key="$key" -v value="$value" '
                /^\[.*\]$/ { 
                    if (in_section && !found) {
                        print key"="value
                    }
                    in_section=0 
                }
                $0 == "["section"]" { in_section=1; print; next }
                in_section && $0 ~ "^"key"=" { print key"="value; found=1; next }
                { print }
                END { 
                    if (in_section && !found) {
                        print key"="value
                    }
                }
            ' "$config_file" > "$temp_file"
            mv "$temp_file" "$config_file"
        else
            # Section doesn't exist, create it
            echo "" >> "$config_file"
            echo "[${section}]" >> "$config_file"
            echo "${key}=${value}" >> "$config_file"
        fi
    fi
    
    # Ensure secure permissions after update
    chmod 600 "$config_file"
}

# Configure provider
configure_provider() {
    echo -e "${YELLOW}⚙️  Configuring LLM Provider...${RESET}"
    echo ""
    
    # Check if config already exists and verify permissions
    if [ -f "$HOME/.ai/config" ]; then
        echo -e "${BLUE}Existing configuration found.${RESET}"
        
        # Check and fix permissions if needed
        if [[ "$OSTYPE" == "darwin"* ]]; then
            current_perms=$(stat -f "%OLp" "$HOME/.ai/config" 2>/dev/null)
        else
            current_perms=$(stat -c "%a" "$HOME/.ai/config" 2>/dev/null)
        fi
        
        if [ "$current_perms" != "600" ]; then
            echo -e "${YELLOW}⚠️  Fixing insecure permissions on config file...${RESET}"
            chmod 600 "$HOME/.ai/config"
            echo -e "${GREEN}✓ Permissions set to 600${RESET}"
        fi
        
        echo -n "Do you want to reconfigure? (y/n): "
        read -r reconfig
        
        if [ "$reconfig" != "y" ] && [ "$reconfig" != "Y" ]; then
            echo -e "${GREEN}✓ Using existing configuration${RESET}"
            echo ""
            return
        fi
        echo ""
    fi
    
    echo -e "${CYAN}${BOLD}Select LLM Provider:${RESET}"
    echo "1) Ollama (local)"
    echo "2) DeepSeek (API)"
    echo "3) Moonshot/Kimi (API)"
    echo "4) OpenAI (API)"
    echo ""
    echo -n "Select option [1-4]: "
    read -r provider_choice

    case $provider_choice in
        1)
            echo ""
            echo -e "${BLUE}🧠 Ollama Configuration${RESET}"
            echo ""
            
            # Check for existing Ollama host
            existing_host=$(get_ini_value "ollama" "host")
            if [ -n "$existing_host" ]; then
                echo -e "${YELLOW}Existing Ollama host found: ${existing_host}${RESET}"
                echo -n "Use existing host? (y/n): "
                read -r use_existing
                if [ "$use_existing" = "y" ] || [ "$use_existing" = "Y" ]; then
                    ollama_host="$existing_host"
                else
                    echo -n "Ollama host (default: http://localhost:11434): "
                    read -r ollama_host
                fi
            else
                echo -n "Ollama host (default: http://localhost:11434): "
                read -r ollama_host
            fi
            
            # Use default if empty
            if [ -z "$ollama_host" ]; then
                ollama_host="http://localhost:11434"
            fi
            
            echo -n "Model (e.g., llama3, deepseek-r1:7b): "
            read -r model_name
            
            echo -n "Does the model already have a system prompt? (y/n): "
            read -r has_prompt
            
            # Update only Ollama-specific values, preserve others
            update_ini_value "" "provider" "ollama"
            update_ini_value "ollama" "model" "$model_name"
            update_ini_value "ollama" "has_prompt" "$has_prompt"
            update_ini_value "ollama" "host" "$ollama_host"
            
            echo ""
            echo -e "${GREEN}✓ Ollama configured${RESET}"
            echo -e "${YELLOW}Note: Make sure Ollama is running at $ollama_host${RESET}"
            ;;
        2)
            echo ""
            echo -e "${BLUE}🧠 DeepSeek Configuration${RESET}"
            echo ""
            echo -e "${YELLOW}⚠️  Security Notice: Your API key will be stored in ~/.ai/config with 600 permissions${RESET}"
            echo ""
            
            # Check for existing DeepSeek API key
            existing_key=$(get_ini_value "deepseek" "api_key")
            if [ -n "$existing_key" ]; then
                echo -e "${YELLOW}Existing DeepSeek API key found${RESET}"
                echo -n "Use existing API key? (y/n): "
                read -r use_existing
                if [ "$use_existing" = "y" ] || [ "$use_existing" = "Y" ]; then
                    api_key="$existing_key"
                else
                    echo -n "API Key: "
                    read -r api_key
                fi
            else
                echo -n "API Key: "
                read -r api_key
            fi
            
            # Update only DeepSeek-specific values, preserve others
            update_ini_value "" "provider" "deepseek"
            update_ini_value "deepseek" "api_key" "$api_key"
            update_ini_value "deepseek" "model" "deepseek-chat"
            
            echo ""
            echo -e "${GREEN}✓ DeepSeek configured${RESET}"
            ;;
        3)
            echo ""
            echo -e "${BLUE}🧠 Moonshot/Kimi Configuration${RESET}"
            echo ""
            echo -e "${YELLOW}⚠️  Security Notice: Your API key will be stored in ~/.ai/config with 600 permissions${RESET}"
            echo ""
            
            # Check for existing Moonshot API key
            existing_key=$(get_ini_value "moonshot" "api_key")
            if [ -n "$existing_key" ]; then
                echo -e "${YELLOW}Existing Moonshot API key found${RESET}"
                echo -n "Use existing API key? (y/n): "
                read -r use_existing
                if [ "$use_existing" = "y" ] || [ "$use_existing" = "Y" ]; then
                    api_key="$existing_key"
                else
                    echo -n "API Key: "
                    read -r api_key
                fi
            else
                echo -n "API Key: "
                read -r api_key
            fi
            
            # Update only Moonshot-specific values, preserve others
            update_ini_value "" "provider" "moonshot"
            update_ini_value "moonshot" "api_key" "$api_key"
            update_ini_value "moonshot" "model" "kimi-k2.5"
            
            echo ""
            echo -e "${GREEN}✓ Moonshot/Kimi configured${RESET}"
            ;;
        4)
            echo ""
            echo -e "${BLUE}🧠 OpenAI Configuration${RESET}"
            echo ""
            echo -e "${YELLOW}⚠️  Security Notice: Your API key will be stored in ~/.ai/config with 600 permissions${RESET}"
            echo ""

            # Check for existing OpenAI API key
            existing_key=$(get_ini_value "openai" "api_key")
            if [ -n "$existing_key" ]; then
                echo -e "${YELLOW}Existing OpenAI API key found${RESET}"
                echo -n "Use existing API key? (y/n): "
                read -r use_existing
                if [ "$use_existing" = "y" ] || [ "$use_existing" = "Y" ]; then
                    api_key="$existing_key"
                else
                    echo -n "API Key: "
                    read -r api_key
                fi
            else
                echo -n "API Key: "
                read -r api_key
            fi

            echo -n "Model (default: gpt-4o-mini): "
            read -r openai_model
            if [ -z "$openai_model" ]; then
                openai_model="gpt-4o-mini"
            fi

            # Update only OpenAI-specific values, preserve others
            update_ini_value "" "provider" "openai"
            update_ini_value "openai" "api_key" "$api_key"
            update_ini_value "openai" "model" "$openai_model"

            echo ""
            echo -e "${GREEN}✓ OpenAI configured${RESET}"
            ;;
        *)
            echo -e "${RED}Invalid option${RESET}"
            echo -e "${YELLOW}Skipping provider configuration. You can configure it later by running the installer again.${RESET}"
            ;;
    esac
    
    # Ensure config file has secure permissions
    if [ -f "$HOME/.ai/config" ]; then
        chmod 600 "$HOME/.ai/config"
    fi
    
    echo ""
}

# Install AI scripts
install_ai() {
    echo -e "${YELLOW}🚀 Installing AI...${RESET}"
    echo ""
    
    # Make scripts executable
    chmod +x "$INSTALL_DIR/ai" "$INSTALL_DIR/aic"
    echo -e "${GREEN}✓ Made scripts executable${RESET}"
    
    # Ask for installation method
    echo ""
    echo -e "${CYAN}${BOLD}Installation Method:${RESET}"
    echo "1) Create symbolic links in /usr/local/bin (recommended)"
    echo "2) Copy scripts to /usr/local/bin"
    echo "3) Add to PATH in ~/.bashrc (no sudo required)"
    echo "4) Skip (manual installation)"
    echo ""
    echo -n "Select option [1-4]: "
    read -r install_method
    
    case $install_method in
        1)
            echo ""
            echo "Creating symbolic links..."
            sudo ln -sf "$INSTALL_DIR/ai" /usr/local/bin/ai
            sudo ln -sf "$INSTALL_DIR/aic" /usr/local/bin/aic
            echo -e "${GREEN}✓ Symbolic links created in /usr/local/bin${RESET}"
            ;;
        2)
            echo ""
            echo "Copying scripts..."
            sudo cp "$INSTALL_DIR/ai" /usr/local/bin/ai
            sudo cp "$INSTALL_DIR/aic" /usr/local/bin/aic
            sudo chmod +x /usr/local/bin/ai /usr/local/bin/aic
            echo -e "${GREEN}✓ Scripts copied to /usr/local/bin${RESET}"
            ;;
        3)
            echo ""
            echo "Adding to PATH..."
            if ! grep -q "export PATH=\"\$PATH:$INSTALL_DIR\"" ~/.bashrc; then
                echo "export PATH=\"\$PATH:$INSTALL_DIR\"" >> ~/.bashrc
                echo -e "${GREEN}✓ Added to ~/.bashrc${RESET}"
                echo -e "${YELLOW}⚠️  Run 'source ~/.bashrc' or restart your terminal${RESET}"
            else
                echo -e "${YELLOW}Already in PATH${RESET}"
            fi
            ;;
        4)
            echo ""
            echo -e "${YELLOW}Skipping installation. Scripts are in: $INSTALL_DIR${RESET}"
            ;;
        *)
            echo ""
            echo -e "${RED}Invalid option. Skipping installation.${RESET}"
            ;;
    esac
    
    echo ""
}

# Main installation flow
main() {
    detect_system
    
    # Select language
    select_language
    
    # Check and install dependencies
    if ! verify_dependencies; then
        install_dependencies
        verify_dependencies || {
            echo -e "${RED}Failed to install dependencies. Exiting.${RESET}"
            exit 1
        }
    fi
    
    # Configure language prompts
    configure_prompts
    
    # Configure provider (Ollama or DeepSeek)
    configure_provider
    
    # Install AI
    install_ai
    
    # Success message
    echo -e "${GREEN}${BOLD}"
    echo "╔════════════════════════════════════════╗"
    echo "║   Installation Complete! 🎉            ║"
    echo "╚════════════════════════════════════════╝"
    echo -e "${RESET}"
    echo ""
    echo -e "${CYAN}Next steps:${RESET}"
    echo -e "  1. Run ${GREEN}ai \"your question\"${RESET} to generate commands"
    echo -e "  2. Run ${GREEN}aic \"your question\"${RESET} for conversational queries"
    echo ""
    echo -e "${CYAN}Examples:${RESET}"
    echo -e "  ${YELLOW}ai \"list all files\"${RESET}"
    echo -e "  ${YELLOW}aic \"what is my IP address\"${RESET}"
    echo ""
    echo -e "${CYAN}Documentation:${RESET} https://github.com/mhito/ai"
    echo ""
    echo -e "${BOLD}Happy coding! 🚀${RESET}"
}

# Run main function
main
