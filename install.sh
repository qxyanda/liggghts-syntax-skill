#!/usr/bin/env bash
# ======================================================
# LIGGGHTS Syntax Skill Installer
# For Claude Code on Linux / macOS / WSL
# ======================================================
set -euo pipefail

SKILL_DIR="${HOME}/.claude/skills"
SKILL_NAME="liggghts-syntax"
REPO_URL="https://github.com/qxyanda/liggghts-syntax-skill.git"
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

# Create skills directories
mkdir -p "$SKILL_DIR/skills/$SKILL_NAME"
mkdir -p "$SKILL_DIR/.claude-plugin"

# Detect install method
if command -v git &> /dev/null && [ -d .git ]; then
    echo "Detected git repo. Installing from local directory..."
    INSTALL_DIR="$(pwd)"
elif command -v git &> /dev/null; then
    echo "Using git clone..."
    TMP_DIR="$(mktemp -d)"
    git clone --depth 1 "$REPO_URL" "$TMP_DIR" 2>/dev/null || {
        echo -e "${RED}Error: Failed to clone $REPO_URL${NC}"
        echo "Falling back to direct download..."
        TMP_DIR="$(mktemp -d)"
        curl -fsSL -o "$TMP_DIR/skill.md" \
            "https://raw.githubusercontent.com/qxyanda/liggghts-syntax-skill/main/skills/liggghts-syntax/SKILL.md"
        cp "$TMP_DIR/skill.md" "$SKILL_DIR/skills/$SKILL_NAME/SKILL.md"
        rm -rf "$TMP_DIR"
        echo -e "${GREEN}Done.${NC}"
        exit 0
    }
    INSTALL_DIR="$TMP_DIR"
else
    echo "Using curl download..."
    TMP_DIR="$(mktemp -d)"
    curl -fsSL -o "$TMP_DIR/skill.md" \
        "https://raw.githubusercontent.com/qxyanda/liggghts-syntax-skill/main/skills/liggghts-syntax/SKILL.md"
    cp "$TMP_DIR/skill.md" "$SKILL_DIR/skills/$SKILL_NAME/SKILL.md"
    rm -rf "$TMP_DIR"
    echo -e "${GREEN}Done.${NC}"
    exit 0
fi

# Copy skill file
if [ -f "$INSTALL_DIR/skills/liggghts-syntax/SKILL.md" ]; then
    cp "$INSTALL_DIR/skills/liggghts-syntax/SKILL.md" \
        "$SKILL_DIR/skills/$SKILL_NAME/SKILL.md"
fi

# Copy plugin config
if [ -f "$INSTALL_DIR/.claude-plugin/plugin.json" ]; then
    cp "$INSTALL_DIR/.claude-plugin/plugin.json" \
        "$SKILL_DIR/.claude-plugin/plugin.json" 2>/dev/null || true
fi
if [ -f "$INSTALL_DIR/.claude-plugin/marketplace.json" ]; then
    cp "$INSTALL_DIR/.claude-plugin/marketplace.json" \
        "$SKILL_DIR/.claude-plugin/marketplace.json" 2>/dev/null || true
fi

# Cleanup temp
if [ -n "${TMP_DIR:-}" ] && [ -d "$TMP_DIR" ]; then
    rm -rf "$TMP_DIR"
fi

echo ""
echo -e "${GREEN}Installation complete!${NC}"
echo -e "Skill installed to: ${YELLOW}$SKILL_DIR/skills/$SKILL_NAME/${NC}"
echo ""
echo "Trigger phrases: 'LIGGGHTS syntax', 'LIGGGHTS script', 'DEM script syntax'"
echo "Or use: /liggghts-syntax"
echo ""
echo -e "${YELLOW}Restart your Claude Code session or run /reload-skill to activate.${NC}"
