#!/usr/bin/env bash
# 每天 09:00 由 launchd 触发：把当日日报（周一则含本周周报）渲染后发邮件。
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck disable=SC1091
source "$REPO_ROOT/scripts/lib.sh"
load_env

TODAY="$(today_yyyymmdd)"
REPORT="$REPO_ROOT/assets/daily/${TODAY}-daily-surf.md"
LOGFILE="$LOG_DIR/mail-${TODAY}.log"

SUBJECT="daily-surf 日报 $(TZ=Asia/Shanghai date +%Y-%m-%d)"

# 用 bash 数组收集要渲染/发送的 md 文件
MD_FILES=("$REPORT")
if [ "$(today_weekday)" = "1" ]; then
  WK="$(weekly_week "$TODAY")"
  WR="$REPO_ROOT/assets/weekly/w${WK}.md"
  if [ -f "$WR" ]; then
    SUBJECT="daily-surf 周报(w${WK}) + 日报 $(TZ=Asia/Shanghai date +%Y-%m-%d)"
    MD_FILES+=("$WR")
  fi
fi

{
  echo "[$(date '+%F %T')] ===== 邮件发送开始 ====="
  if [ ! -s "$REPORT" ]; then
    echo "错误: 日报文件不存在或为空: $REPORT" >&2
    exit 1
  fi

  # 渲染每个 md -> html
  for f in "${MD_FILES[@]}"; do
    python3 "$REPO_ROOT/scripts/md2html.py" "$f" "$f.html"
  done

  # 发送：主题 + 所有 md 文件（send_mail.py 内部合并渲染）
  python3 "$REPO_ROOT/scripts/send_mail.py" "$SUBJECT" "${MD_FILES[@]}"
  echo "[$(date '+%F %T')] ===== 邮件发送结束 ====="
} | tee "$LOGFILE"