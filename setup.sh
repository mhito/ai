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

# Configuration
INSTALL_DIR="$HOME/.ai"
REPO_URL="https://github.com/mhito/ai.git"

# Check if running from pipe (stdin is not a terminal)
if [ ! -t 0 ]; then
    echo -e "${YELLOW}Detected piped execution. Re-running with proper stdin...${RESET}"
    # Download script to temp file and execute it with proper stdin
    TEMP_SCRIPT=$(mktemp)
    curl -fsSL https://raw.githubusercontent.com/mhito/ai/main/setup.sh -o "$TEMP_SCRIPT"
    chmod +x "$TEMP_SCRIPT"
    exec "$TEMP_SCRIPT" < /dev/tty
    exit 0
fi

echo -e "${CYAN}${BOLD}"
echo "╔════════════════════════════════════════╗"
echo "║     AI (Terminal-AI) Setup            ║"
echo "╚════════════════════════════════════════╝"
echo -e "${RESET}"
echo ""

# Check if git is installed
if ! command -v git >/dev/null 2>&1; then
    echo -e "${RED}✗ Git is not installed${RESET}"
    echo -e "${YELLOW}Installing git...${RESET}"
    
    # Detect OS and install git
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        if ! command -v brew >/dev/null 2>&1; then
            echo -e "${YELLOW}Homebrew not found. Installing Homebrew...${RESET}"
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
            
            # Add Homebrew to PATH for Apple Silicon Macs
            ARCH=$(uname -m)
            if [[ "$ARCH" == "arm64" ]] && [ -f /opt/homebrew/bin/brew ]; then
                eval "$(/opt/homebrew/bin/brew shellenv)"
            fi
        fi
        brew install git
    elif [ -f /etc/os-release ]; then
        . /etc/os-release
        case "$ID" in
            ubuntu|debian|pop|linuxmint)
                sudo apt-get update -qq
                sudo apt-get install -y git
                ;;
            fedora|rhel|centos|rocky|almalinux)
                sudo dnf install -y git || sudo yum install -y git
                ;;
            arch|manjaro|endeavouros)
                sudo pacman -S --noconfirm git
                ;;
            opensuse*|sles)
                sudo zypper install -y git
                ;;
            *)
                echo -e "${RED}Please install git manually and run this script again${RESET}"
                exit 1
                ;;
        esac
    else
        echo -e "${RED}Could not detect OS. Please install git manually${RESET}"
        exit 1
    fi
    
    echo -e "${GREEN}✓ Git installed${RESET}"
    echo ""
fi

# Clone or update repository
echo -e "${YELLOW}📥 Downloading AI from GitHub...${RESET}"
echo ""

if [ -d "$INSTALL_DIR" ]; then
    echo "Directory $INSTALL_DIR already exists."
    echo -n "Do you want to update it? (y/n): "
    read -r update_choice
    
    if [ "$update_choice" = "y" ] || [ "$update_choice" = "Y" ]; then
        echo "Updating repository..."
        cd "$INSTALL_DIR"
        git pull origin main 2>/dev/null || git pull origin master 2>/dev/null || {
            echo -e "${YELLOW}Could not update. Removing and re-cloning...${RESET}"
            cd ~
            rm -rf "$INSTALL_DIR"
            git clone "$REPO_URL" "$INSTALL_DIR"
        }
    else
        echo "Using existing installation."
    fi
else
    echo "Cloning repository..."
    git clone "$REPO_URL" "$INSTALL_DIR"
fi

echo -e "${GREEN}✓ Repository downloaded to $INSTALL_DIR${RESET}"
echo ""

# Run installer
echo -e "${CYAN}${BOLD}Running installer...${RESET}"
echo ""

cd "$INSTALL_DIR"

if [ -f "install.sh" ]; then
    chmod +x install.sh
    ./install.sh
else
    echo -e "${RED}✗ install.sh not found in repository${RESET}"
    exit 1
fi
