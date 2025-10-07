#!/usr/bin/env bash

GG_DIR="$HOME/.gg"
GG_SCRIPT_URL="https://raw.githubusercontent.com/thiago-negri/gg/refs/heads/main/gg.sh"
GG_SCRIPT_PATH="$GG_DIR/gg.sh"
BASHRC="$HOME/.bashrc"
SOURCE_LINE='[ -f "$HOME/.gg/gg.sh" ] && . "$HOME/.gg/gg.sh"'

echo "Downloading gg..."
mkdir -p "$GG_DIR"
curl -fsSL "$GG_SCRIPT_URL" -o "$GG_SCRIPT_PATH"

if grep -Fxq "$SOURCE_LINE" "$BASHRC"; then
    echo "No changes to your .bashrc, gg was already there. Enjoy!"
else
    echo "$SOURCE_LINE" >> "$BASHRC"
    echo "Added gg to your .bashrc"
    echo "Restart your terminal or run: source ~/.gg/gg.sh"
    echo "Enjoy!"
fi
