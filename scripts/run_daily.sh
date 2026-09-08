#!/usr/bin/env bash
# 每天 08:00 由 launchd 触发：生成当日日报（3 路并行：arxiv/github/blogs）。
# 若为周一，额外生成周报（覆盖上一周）。
# daily-surf 只关注精品长内容：论文、博客/工程文档、GitHub 仓库。
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck disable=SC1091
source "$REPO_ROOT/scripts/lib.sh"
load_env

# 防御：清除可能被注入的代理变量（Cursor 沙箱等会注入本地 HTTP 代理，
# 会让 cursor-agent 的 TLS 握手失败）。launchd 环境本就干净，此步无害。
unset HTTP_PROXY HTTPS_PROXY ALL_PROXY SOCKS_PROXY SOCKS5_PROXY \
  http_proxy https_proxy all_proxy socks_proxy socks5_proxy \
  GIT_HTTP_PROXY GIT_HTTPS_PROXY 2>/dev/null || true

TODAY="$(today_yyyymmdd)"
DEST="$REPO_ROOT/assets/daily/${TODAY}-daily-surf.md"
LOGFILE="$LOG_DIR/daily-${TODAY}.log"

# 中间产物目录：每板块一个 agent 写独立文件，最后合并
TMP_DIR="$REPO_ROOT/assets/daily/.tmp-${TODAY}"
mkdir -p "$TMP_DIR"

{
  echo "[$(date '+%F %T')] ===== 日报流程开始（3 路并行）====="
  echo "目标文件: $DEST"

  if [ -z "${CURSOR_API_KEY:-}" ]; then
    echo "错误: 未设置 CURSOR_API_KEY，请在 .env 中填写后重试" >&2
    exit 1
  fi

  TODAY_HUMAN="$(TZ=Asia/Shanghai date +%F)"

  # 三个板块的 agent 并行启动，各自写中间 md 文件
  # 板块 1: arxiv 论文
  "$AGENT_BIN" --print --trust -f \
    --api-key "$CURSOR_API_KEY" \
    --model auto \
    "你是 daily-surf 的 arxiv 论文抓取 agent。请按 openspec/specs/daily-report/spec.md 规格，并参考 .preference/papers.md 的主题（LLM 后训练/对齐、Agentic AI、Agent Memory、Context Management）与作者（梁文锋/DeepSeek）。抓取今日（东八区 ${TODAY_HUMAN}）arxiv 新增论文（cs.CL/cs.MA/cs.AI/cs.LG，含预印本/已发布标注），挑选与偏好最相关的 3-6 篇，每条含标题、作者、arXiv 链接、一句为什么值得关注。如果抓取不可用，如实写'本板块今日无新增（原因）'，不要编造。把结果 Markdown 直接写入文件 ${TMP_DIR}/01-arxiv.md，只输出该板块内容（含 ## 一、论文（arxiv）标题）。" \
    > "$TMP_DIR/01-arxiv.log" 2>&1 &
  PID_ARXIV=$!

  # 板块 2: GitHub 热门仓库
  "$AGENT_BIN" --print --trust -f \
    --api-key "$CURSOR_API_KEY" \
    --model auto \
    "你是 daily-surf 的 GitHub 仓库抓取 agent。请按 openspec/specs/daily-report/spec.md 规格，并参考 .preference/repos.md。抓取今日（东八区 ${TODAY_HUMAN}）GitHub Trending 周榜中 star 增长过千、与 AI/agent/多 agent 相关的仓库 3-6 个，每条含仓库名、链接、star 增长、一句点评。如果抓取不可用，如实写'本板块今日无新增（原因）'，不要编造。把结果 Markdown 直接写入文件 ${TMP_DIR}/02-github.md，只输出该板块内容（含 ## 二、GitHub 热门仓库标题）。" \
    > "$TMP_DIR/02-github.log" 2>&1 &
  PID_GITHUB=$!

  # 板块 3: 大厂博客
  "$AGENT_BIN" --print --trust -f \
    --api-key "$CURSOR_API_KEY" \
    --model auto \
    "你是 daily-surf 的大厂博客抓取 agent。请按 openspec/specs/daily-report/spec.md 规格，并参考 .preference/blogs.md。抓取今日（东八区 ${TODAY_HUMAN}）OpenAI、Anthropic、Google DeepMind、Meta AI、Mistral、xAI、Qwen、DeepSeek 等的最新技术博客/工程文档 3-5 条，每条含标题、来源、链接、一句话看点。如果抓取不可用，如实写'本板块今日无新增（原因）'，不要编造。把结果 Markdown 直接写入文件 ${TMP_DIR}/03-blogs.md，只输出该板块内容（含 ## 三、大厂技术博客标题）。" \
    > "$TMP_DIR/03-blogs.log" 2>&1 &
  PID_BLOGS=$!

  echo "已并行启动 3 个 agent（PIDs: ${PID_ARXIV} ${PID_GITHUB} ${PID_BLOGS}）"

  # 等待全部完成
  FAIL=0
  for pid in "$PID_ARXIV" "$PID_GITHUB" "$PID_BLOGS"; do
    if ! wait "$pid"; then
      echo "警告: agent $pid 异常退出"
      FAIL=1
    fi
  done

  # 合并三个板块
  {
    echo "# 每日资讯 · $TODAY"
    echo ""
    for sec in 01-arxiv 02-github 03-blogs; do
      if [ -s "$TMP_DIR/$sec.md" ]; then
        cat "$TMP_DIR/$sec.md"
      else
        echo "## ${sec}"
        echo ""
        echo "_（本板块未生成内容，见日志）_"
        echo ""
      fi
    done
    echo "## 个人点评"
    echo ""
    echo "_（待偏好反馈闭环补充）_"
    echo ""
  } > "$DEST"

  echo "日报已写入: $DEST"
  if [ "$FAIL" = "1" ]; then
    echo "注意: 部分板块 agent 失败，保留临时目录: $TMP_DIR"
    for lf in "$TMP_DIR"/*.log; do
      echo "--- $(basename "$lf") ---"
      tail -5 "$lf" 2>/dev/null
    done
  else
    rm -rf "$TMP_DIR"
  fi

  # 周一额外生成周报（周数取生成日 ISO 周）
  if [ "$(today_weekday)" = "1" ]; then
    WK="$(weekly_week "$TODAY")"
    WDEST="$REPO_ROOT/assets/weekly/w${WK}.md"
    echo "[$(date '+%F %T')] ===== 周报流程开始（ISO 周 w${WK}）====="
    "$AGENT_BIN" --print --trust -f \
      --api-key "$CURSOR_API_KEY" \
      --model auto \
      "你是 daily-surf 的资讯生成 agent。请按 openspec/specs/weekly-report/spec.md 规格、并参考 .preference/ 的 taste，聚合上一周（周一到周日）论文、博客/工程文档、GitHub 仓库三大板块内容，写成结构化周报（含概述、三大板块、个人点评，每条附原文链接），直接写入文件 ${WDEST}。" \
      >> "$LOGFILE" 2>&1
    echo "周报已写入: $WDEST"
  fi

  echo "[$(date '+%F %T')] ===== 日报流程结束 ====="
} | tee "$LOGFILE"