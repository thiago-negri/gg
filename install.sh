#!/usr/bin/env bash

set -euo pipefail

GG_DIR="$HOME/.gg"
GG_SCRIPT_URL="https://raw.githubusercontent.com/thiago-negri/gg/refs/heads/main/gg.zsh"
GG_SCRIPT_PATH="$GG_DIR/gg.zsh"
ZSHRC="$HOME/.zshrc"
SOURCE_LINE='source "$HOME/.gg/gg.zsh"'

echo "Downloading gg..."
mkdir -p "$GG_DIR"
curl -fsSL "$GG_SCRIPT_URL" -o "$GG_SCRIPT_PATH"

if grep -Fxq "$SOURCE_LINE" "$ZSHRC"; then
    echo "No changes to your .zshrc, gg was already there. Enjoy!"
else
    echo "$SOURCE_LINE" >> "$ZSHRC"
    echo "Added gg to your .zshrc"
    echo "Restart your terminal or run: source ~/.gg/gg.zsh"
    echo "Enjoy!"
fi

