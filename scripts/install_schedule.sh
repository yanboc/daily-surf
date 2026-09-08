#!/usr/bin/env bash
# 自动装载/卸载 launchd 定时任务。
# 用法:
#   install_schedule.sh install   # 装载两个 plist
#   install_schedule.sh uninstall # 卸载
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
AGENT_DIR="$HOME/Library/LaunchAgents"
mkdir -p "$AGENT_DIR"

ACTION="${1:-install}"

install_one() {
  local src="$1"
  local name
  name="$(basename "$src")"
  local dst="$AGENT_DIR/$name"

  # 用仓库内绝对路径替换占位（当前脚本路径已写死，这里直接拷）
  cp "$src" "$dst"

  if launchctl list | grep -q "com.daily-surf"; then
    : # 已存在
  fi

  launchctl unload "$dst" 2>/dev/null || true
  launchctl load "$dst"
  echo "已装载: $dst"
}

uninstall_one() {
  local name="$1"
  local dst="$AGENT_DIR/$name"
  launchctl unload "$dst" 2>/dev/null || true
  echo "已卸载: $dst"
}

case "$ACTION" in
  install)
    install_one "$REPO_ROOT/scripts/com.daily-surf.daily.plist"
    install_one "$REPO_ROOT/scripts/com.daily-surf.mail.plist"
    ;;
  uninstall)
    uninstall_one "com.daily-surf.daily.plist"
    uninstall_one "com.daily-surf.mail.plist"
    ;;
  *)
    echo "usage: install_schedule.sh <install|uninstall>" >&2
    exit 2
    ;;
esac