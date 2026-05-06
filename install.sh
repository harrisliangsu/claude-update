#!/usr/bin/env bash
# 把 claude-update 软链到 ~/.local/bin（或 $PREFIX/bin）
set -euo pipefail

PREFIX="${PREFIX:-$HOME/.local}"
BIN_DIR="$PREFIX/bin"
SRC="$(cd "$(dirname "$0")" && pwd)/claude-update"

mkdir -p "$BIN_DIR"
ln -sf "$SRC" "$BIN_DIR/claude-update"

echo "已安装：$BIN_DIR/claude-update -> $SRC"
case ":$PATH:" in
  *":$BIN_DIR:"*) ;;
  *) echo "提示：$BIN_DIR 未在 PATH 中，请将其加入 shell 配置（如 ~/.zshrc）" ;;
esac
