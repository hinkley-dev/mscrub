#!/usr/bin/env bash
set -euo pipefail

INSTALL_DIR="$HOME/.local/bin"
SYSTEM=false

for arg in "$@"; do
    case $arg in
        --system) SYSTEM=true ;;
        *) echo "Unknown argument: $arg" >&2; exit 1 ;;
    esac
done

if $SYSTEM; then
    INSTALL_DIR="/usr/local/bin"
fi

# Create install dir if it doesn't exist
if [[ ! -d "$INSTALL_DIR" ]]; then
    mkdir -p "$INSTALL_DIR"
    echo "Created $INSTALL_DIR"
fi

# Resolve the script to copy — works whether run via curl|bash or directly
if [[ -f "$(dirname "$0")/mscrub" ]]; then
    # Running from a cloned repo
    SCRIPT_PATH="$(dirname "$0")/mscrub"
else
    # Running via curl | bash — download the script directly
    TMP=$(mktemp)
    trap 'rm -f "$TMP"' EXIT
    echo "Downloading mscrub..."
    curl -fsSL https://raw.githubusercontent.com/hinkley-dev/mscrub/main/mscrub -o "$TMP"
    SCRIPT_PATH="$TMP"
fi

if $SYSTEM; then
    sudo cp "$SCRIPT_PATH" "$INSTALL_DIR/mscrub"
    sudo chmod +x "$INSTALL_DIR/mscrub"
else
    cp "$SCRIPT_PATH" "$INSTALL_DIR/mscrub"
    chmod +x "$INSTALL_DIR/mscrub"
fi

echo "Installed mscrub to $INSTALL_DIR/mscrub"

# Warn if the install dir is not on PATH
if [[ ":$PATH:" != *":$INSTALL_DIR:"* ]]; then
    echo ""
    echo "Warning: $INSTALL_DIR is not on your PATH."
    echo "Add the following line to your ~/.bashrc or ~/.zshrc and restart your shell:"
    echo ""
    echo "  export PATH=\"\$HOME/.local/bin:\$PATH\""
fi
