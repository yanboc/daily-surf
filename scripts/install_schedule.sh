#!/usr/bin/env bash
# 管理 launchd 定时任务。install 默认安装后禁用，审阅批准后再 enable。
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
AGENT_DIR="$HOME/Library/LaunchAgents"
DOMAIN="gui/$(id -u)"
LABELS=(com.daily-surf.daily com.daily-surf.mail)
mkdir -p "$AGENT_DIR"

plist_for() { echo "$AGENT_DIR/$1.plist"; }

install_all() {
  [ -x "$HOME/Applications/DailySurfRunner.app/Contents/MacOS/DailySurfRunner" ] || {
    echo "错误: 请先运行 scripts/install_runner_app.sh" >&2
    exit 1
  }
  for label in "${LABELS[@]}"; do
    dst="$(plist_for "$label")"
    launchctl bootout "$DOMAIN" "$dst" 2>/dev/null || true
    cp "$REPO_ROOT/scripts/$label.plist" "$dst"
    launchctl bootstrap "$DOMAIN" "$dst"
    launchctl disable "$DOMAIN/$label"
    echo "已安装并禁用: $label"
  done
}

set_enabled() {
  local verb="$1"
  for label in "${LABELS[@]}"; do
    launchctl "$verb" "$DOMAIN/$label"
    echo "$verb: $label"
  done
}

status_all() {
  for label in "${LABELS[@]}"; do
    launchctl print "$DOMAIN/$label" 2>&1 | sed -n '1,32p' || true
    launchctl print-disabled "$DOMAIN" | grep "$label" || true
  done
}

uninstall_all() {
  for label in "${LABELS[@]}"; do
    dst="$(plist_for "$label")"
    launchctl bootout "$DOMAIN" "$dst" 2>/dev/null || true
    echo "已卸载: $label"
  done
}

case "${1:-status}" in
  install) install_all ;;
  enable) set_enabled enable ;;
  disable) set_enabled disable ;;
  status) status_all ;;
  uninstall) uninstall_all ;;
  *) echo "用法: install_schedule.sh <install|enable|disable|status|uninstall>" >&2; exit 2 ;;
esac
