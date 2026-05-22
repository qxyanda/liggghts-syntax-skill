#!/usr/bin/env bash
# ======================================================
# LIGGGHTS Syntax Skill Installer
# For Claude Code on Linux / macOS / WSL
# ======================================================
set -euo pipefail

SKILL_DIR="${HOME}/.claude/skills"
SKILL_NAME="liggghts-syntax"
REPO_URL="https://github.com/qxyanda/liggghts-syntax-skill.git"
RAW_URL="https://raw.githubusercontent.com/qxyanda/liggghts-syntax-skill/main"
VERSION="1.0.0"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}=== LIGGGHTS Syntax Skill Installer v${VERSION} ===${NC}"
echo ""

# Check for Claude Code
if [ ! -d "$HOME/.claude" ]; then
    echo -e "${YELLOW}Warning: ~/.claude directory not found. Creating...${NC}"
    mkdir -p "$HOME/.claude"
fi

# Create target directory: ~/.claude/skills/liggghts-syntax/
TARGET="$SKILL_DIR/$SKILL_NAME"
mkdir -p "$TARGET"

# Detect install method
if command -v git &> /dev/null && git rev-parse --git-dir &> /dev/null 2>&1; then
    # Running from inside the cloned repo
    echo "Detected local repo. Installing from $(pwd)..."
    INSTALL_DIR="$(pwd)"
elif command -v git &> /dev/null; then
    echo "Cloning from $REPO_URL..."
    TMP_DIR="$(mktemp -d)"
    trap "rm -rf $TMP_DIR" EXIT
    git clone --depth 1 "$REPO_URL" "$TMP_DIR" 2>/dev/null || {
        echo -e "${RED}Clone failed. Downloading SKILL.md directly...${NC}"
        curl -fsSL -o "$TARGET/SKILL.md" \
            "$RAW_URL/skills/liggghts-syntax/SKILL.md"
        echo -e "${GREEN}Done: $TARGET/SKILL.md${NC}"
        exit 0
    }
    INSTALL_DIR="$TMP_DIR"
else
    echo "Downloading SKILL.md directly..."
    curl -fsSL -o "$TARGET/SKILL.md" \
        "$RAW_URL/skills/liggghts-syntax/SKILL.md"
    echo -e "${GREEN}Done: $TARGET/SKILL.md${NC}"
    exit 0
fi

# Copy skill file from repo's skills/liggghts-syntax/ to ~/.claude/skills/liggghts-syntax/
if [ -f "$INSTALL_DIR/skills/liggghts-syntax/SKILL.md" ]; then
    cp "$INSTALL_DIR/skills/liggghts-syntax/SKILL.md" "$TARGET/SKILL.md"
    echo -e "${GREEN}Installed: $TARGET/SKILL.md${NC}"
else
    echo -e "${RED}Error: SKILL.md not found in repo${NC}"
    exit 1
fi

# Copy example script
if [ -d "$INSTALL_DIR/example" ]; then
    mkdir -p "$TARGET/example"
    cp "$INSTALL_DIR/example/"* "$TARGET/example/" 2>/dev/null || true
fi

echo ""
echo -e "${GREEN}Installation complete!${NC}"
echo "Trigger phrases: 'LIGGGHTS syntax', 'LIGGGHTS script', 'DEM script syntax'"
echo "Or use: /liggghts-syntax"
echo ""
echo -e "${YELLOW}Restart Claude Code or run /reload-skill to activate.${NC}"
