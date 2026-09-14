#!/usr/bin/env bash
# 明确发布一份已审阅日报；飞书和邮件均需显式开关。
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck disable=SC1091
source "$REPO_ROOT/scripts/lib.sh"
load_env

[ "$#" -ge 1 ] || { echo "用法: publish_review.sh YYYYMMDD [--feishu] [--mail]" >&2; exit 2; }
REPORT_DATE="$1"
shift
DO_FEISHU=0
DO_MAIL=0
while [ "$#" -gt 0 ]; do
  case "$1" in
    --feishu) DO_FEISHU=1 ;;
    --mail) DO_MAIL=1 ;;
    *) echo "错误: 不支持的参数 $1" >&2; exit 2 ;;
  esac
  shift
done

[[ "$REPORT_DATE" =~ ^[0-9]{8}$ ]] || { echo "错误: 日期必须为 YYYYMMDD" >&2; exit 2; }
REVIEW_DIR="$REPO_ROOT/assets/review/$REPORT_DATE"
SOURCE="$REVIEW_DIR/${REPORT_DATE}-daily-surf.md"
DB_JSON="$REVIEW_DIR/db.json"
DEST="$REPO_ROOT/assets/daily/${REPORT_DATE}-daily-surf.md"
[ -s "$SOURCE" ] || { echo "错误: 待审稿不存在: $SOURCE" >&2; exit 1; }

cp "$SOURCE" "$DEST"
echo "已发布日报: $DEST"

if [ "$DO_FEISHU" = "1" ]; then
  [ -s "$DB_JSON" ] || { echo "错误: 缺少 $DB_JSON" >&2; exit 1; }
  python3 "$REPO_ROOT/scripts/feishu_bitable.py" --write-json "$DB_JSON"
fi
if [ "$DO_MAIL" = "1" ]; then
  SUBJECT="daily-surf 补发日报 $(human_date "$REPORT_DATE")"
  python3 "$REPO_ROOT/scripts/send_mail.py" "$SUBJECT" "$DEST"
fi
