#!/usr/bin/env bash
# 每天 08:00 由 launchd 触发：生成当日日报。
# 若为周一，额外生成周报（覆盖上一周）。
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck disable=SC1091
source "$REPO_ROOT/scripts/lib.sh"
load_env

TODAY="$(today_yyyymmdd)"
DEST="$REPO_ROOT/assets/daily/${TODAY}-daily-surf.md"
LOGFILE="$LOG_DIR/daily-${TODAY}.log"

{
  echo "[$(date '+%F %T')] ===== 日报流程开始 ====="
  echo "目标文件: $DEST"

  if [ -z "${CURSOR_API_KEY:-}" ]; then
    echo "错误: 未设置 CURSOR_API_KEY，请在 .env 中填写后重试" >&2
    exit 1
  fi

  # 用 agent 生成日报（非交互、可写文件）。要求 agent 读 openspec/specs/daily-report 与 .preference/。
  "$AGENT_BIN" --print \
    --api-key "$CURSOR_API_KEY" \
    --model auto \
    "你是 daily-surf 的资讯生成 agent。请按 openspec/specs/daily-report/spec.md 规格、并参考 .preference/ 下 papers/repos/blogs/people 与 feedback/ 的 taste，抓取今日（东八区 $(TZ=Asia/Shanghai date +%F)）四大板块新增内容（论文/GitHub 热门库/大厂博客/大佬动态），写成结构化 Markdown，每条附原文链接并标注发布时间口径，直接写入文件 $DEST。完成后紧接着按 openspec/specs/preference-feedback/spec.md 的闭环，把需要向用户收集的反馈问题写在日志里。报告你写入了哪些内容。" \
    >> "$LOGFILE" 2>&1

  if [ ! -s "$DEST" ]; then
    echo "错误: 日报文件未生成或为空，请检查日志 $LOGFILE" >&2
    exit 1
  fi
  echo "日报已写入: $DEST"

  # 周一额外生成周报
  if [ "$(today_weekday)" = "1" ]; then
    WK="$(prev_iso_week)"
    WDEST="$REPO_ROOT/assets/weekly/w${WK}.md"
    echo "[$(date '+%F %T')] ===== 周报流程开始（ISO 周 w${WK}）====="
    "$AGENT_BIN" --print \
      --api-key "$CURSOR_API_KEY" \
      --model auto \
      "你是 daily-surf 的资讯生成 agent。请按 openspec/specs/weekly-report/spec.md 规格、并参考 .preference/ 的 taste，聚合上一周（周一到周日）四大板块内容，写成结构化周报（含概述、四大板块、个人点评，每条附原文链接），直接写入文件 $WDEST。" \
      >> "$LOGFILE" 2>&1
    echo "周报已写入: $WDEST"
  fi

  echo "[$(date '+%F %T')] ===== 日报流程结束 ====="
} | tee "$LOGFILE"