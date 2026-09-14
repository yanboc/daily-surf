#!/usr/bin/env bash
# 构建专用 launchd 启动器。安装位置固定为 ~/Applications/DailySurfRunner.app。
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
APP_DIR="$HOME/Applications/DailySurfRunner.app"
CONTENTS="$APP_DIR/Contents"
MACOS="$CONTENTS/MacOS"

mkdir -p "$MACOS"
clang -Wall -Wextra -Werror "$REPO_ROOT/scripts/DailySurfRunner.c" -o "$MACOS/DailySurfRunner"

INFO_TMP="$(mktemp)"
trap 'rm -f "$INFO_TMP"' EXIT
sed "s/__RUNNER_BUILD__/$(date +%Y%m%d%H%M%S)/" "$REPO_ROOT/scripts/runner-Info.plist" > "$INFO_TMP"
cp "$INFO_TMP" "$CONTENTS/Info.plist"
codesign --force --deep --sign - "$APP_DIR"

echo "已安装: $APP_DIR"
echo "下一步：系统设置 → 隐私与安全性 → 完全磁盘访问，添加并启用 DailySurfRunner.app"
