#!/bin/bash

set -e

# Verbose mode
VERBOSE=0
if [ "${1:-}" = "-v" ] || [ "${1:-}" = "--verbose" ]; then
    VERBOSE=1
    set -x
fi

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
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

# Check Node.js version
check_node() {
    if ! command -v node >/dev/null 2>&1; then
        echo -e "${RED}✗ Node.js is not installed.${RESET}"
        echo -e "${YELLOW}Please install Node.js >= 18 and try again.${RESET}"
        exit 1
    fi

    NODE_VERSION=$(node -v | sed 's/v//')
    NODE_MAJOR=$(echo "$NODE_VERSION" | cut -d. -f1)

    if [ "$NODE_MAJOR" -lt 18 ]; then
        echo -e "${RED}✗ Node.js $NODE_VERSION found, but >= 18 is required.${RESET}"
        echo -e "${YELLOW}Please upgrade Node.js and try again.${RESET}"
        exit 1
    fi

    echo -e "${GREEN}✓ Node.js $NODE_VERSION detected${RESET}"
}

# Install npm dependencies if needed
ensure_deps() {
    cd "$INSTALL_DIR"

    if [ ! -d "node_modules" ] || [ "package.json" -nt "node_modules/.package-lock.json" ]; then
        echo -e "${YELLOW}📦 Installing Node.js dependencies...${RESET}"
        npm install
        echo -e "${GREEN}✓ Dependencies installed${RESET}"
    else
        echo -e "${GREEN}✓ Node.js dependencies already installed${RESET}"
    fi
}

# Compile TypeScript if needed
ensure_build() {
    cd "$INSTALL_DIR"

    if [ ! -f "dist/index.js" ] || [ "src/index.ts" -nt "dist/index.js" ]; then
        echo -e "${YELLOW}🔨 Building installer...${RESET}"
        npm run build
        echo -e "${GREEN}✓ Build complete${RESET}"
    else
        echo -e "${GREEN}✓ Build is up to date${RESET}"
    fi
}

# Run the Node.js installer
run_installer() {
    echo ""
    node "$INSTALL_DIR/dist/index.js"
}

# Main flow
main() {
    check_node
    ensure_deps
    ensure_build
    run_installer
}

main "$@"
