#!/usr/bin/env bash
# 每天 08:00 由 launchd 触发；也支持指定日期生成隔离的待审稿。
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck disable=SC1091
source "$REPO_ROOT/scripts/lib.sh"
load_env

unset HTTP_PROXY HTTPS_PROXY ALL_PROXY SOCKS_PROXY SOCKS5_PROXY \
  http_proxy https_proxy all_proxy socks_proxy socks5_proxy \
  GIT_HTTP_PROXY GIT_HTTPS_PROXY 2>/dev/null || true

REPORT_DATE="$(today_yyyymmdd)"
REVIEW=0
while [ "$#" -gt 0 ]; do
  case "$1" in
    --date)
      [ "$#" -ge 2 ] || { echo "错误: --date 需要 YYYYMMDD" >&2; exit 2; }
      REPORT_DATE="$2"
      shift 2
      ;;
    --review)
      REVIEW=1
      shift
      ;;
    *)
      echo "错误: 不支持的参数 $1" >&2
      echo "用法: run_daily.sh [--date YYYYMMDD] [--review]" >&2
      exit 2
      ;;
  esac
done

[[ "$REPORT_DATE" =~ ^[0-9]{8}$ ]] || { echo "错误: 日期必须为 YYYYMMDD" >&2; exit 2; }
REPORT_HUMAN="$(human_date "$REPORT_DATE")" || { echo "错误: 无效日期 $REPORT_DATE" >&2; exit 2; }
START_DATE="$(days_before_yyyymmdd "$REPORT_DATE" 2)"
START_HUMAN="$(human_date "$START_DATE")"

if [ "$REVIEW" = "1" ]; then
  REVIEW_DIR="$REPO_ROOT/assets/review/$REPORT_DATE"
  TMP_DIR="$REVIEW_DIR/work"
  DEST="$REVIEW_DIR/${REPORT_DATE}-daily-surf.md"
  DB_JSON="$REVIEW_DIR/db.json"
  LOGFILE="$REVIEW_DIR/run.log"
  mkdir -p "$TMP_DIR"
else
  DEST="$REPO_ROOT/assets/daily/${REPORT_DATE}-daily-surf.md"
  TMP_DIR="$REPO_ROOT/assets/daily/.tmp-${REPORT_DATE}"
  DB_JSON="$TMP_DIR/db.json"
  LOGFILE="$LOG_DIR/daily-${REPORT_DATE}.log"
  mkdir -p "$TMP_DIR"
fi

DEEP_FIELDS='每条严格使用以下字段：元信息（日期、已发布/预印本、主题标签、S/A/B 分级）、核心问题、机制/设计、证据、局限、对办公 Agent 或 Agent 基础设施的意义。必须读一手资料正文，不能只改写摘要、搜索片段或营销文案。'

run_report() {
  echo "[$(date '+%F %T')] ===== 日报流程开始（3 路并行）====="
  echo "报告日期: ${REPORT_DATE}；窗口: ${START_DATE}-${REPORT_DATE}；审阅模式: ${REVIEW}"
  echo "目标文件: $DEST"

  if [ -z "${CURSOR_API_KEY:-}" ]; then
    echo "错误: 未设置 CURSOR_API_KEY，请在 .env 中填写后重试" >&2
    return 1
  fi

  "$AGENT_BIN" --print --trust -f --api-key "$CURSOR_API_KEY" --model auto \
    "你是 daily-surf 的论文研究 agent。先完整读取 openspec/specs/daily-report/spec.md、.preference/papers.md 和最近反馈。检索 ${START_HUMAN} 至 ${REPORT_HUMAN} 新增的一手论文，重点限定为：Agent 在办公/企业知识工作中的应用、Agent Memory、上下文管理器/context engineering、多 Agent 协同/交互/通信，其中优先 Memory、上下文管理、多 Agent。只选 2-3 篇。必须打开论文全文，至少阅读方法与实验/案例/limitations；从正文核对关键机制、数据集、指标和失败条件。${DEEP_FIELDS} 每条标题必须写成数字列表项 '1. **[标题](URL)**'，字段用缩进项目符号。无法读取全文或验证日期则不收录，不得编造。直接写 ${TMP_DIR}/01-arxiv.md，只含 '## 一、论文（arxiv）' 及条目。" \
    > "$TMP_DIR/01-arxiv.log" 2>&1 &
  PID_ARXIV=$!

  "$AGENT_BIN" --print --trust -f --api-key "$CURSOR_API_KEY" --model auto \
    "你是 daily-surf 的 GitHub 工程研究 agent。先完整读取 openspec/specs/daily-report/spec.md、.preference/repos.md 和最近反馈。检索 ${START_HUMAN} 至 ${REPORT_HUMAN} 期间新发布、显著更新或受到关注的 2-3 个仓库，优先办公 Agent：文档、表格、邮件、会议、日程、跨应用工作流，以及权限、审计、可靠性、人机审批、系统集成；也可收录直接相关的 agent harness。必须阅读 README、官方文档，并检查关键设计/代码或该窗口内 release/commit，不能仅凭 star 数。${DEEP_FIELDS} 证据字段应指向具体文档、实现或 release。每条标题必须写成数字列表项 '1. **[owner/repo](URL)**'，字段用缩进项目符号。普通 X 帖只作发现线索。直接写 ${TMP_DIR}/02-github.md，只含 '## 二、GitHub 仓库' 及条目。" \
    > "$TMP_DIR/02-github.log" 2>&1 &
  PID_GITHUB=$!

  "$AGENT_BIN" --print --trust -f --api-key "$CURSOR_API_KEY" --model auto \
    "你是 daily-surf 的博客/工程文档研究 agent。先完整读取 openspec/specs/daily-report/spec.md、.preference/blogs.md 和最近反馈。检索 ${START_HUMAN} 至 ${REPORT_HUMAN} 发布的一手博客、工程文档或作者/项目团队的一手 X 长帖，选 2-3 条，重点办公 Agent：文档、表格、邮件、会议、日程、跨应用工作流，以及权限、审计、可靠性、人机审批和系统集成。必须阅读全文；普通 X 帖只作线索，只有作者或团队的一手长帖可入选并标注来源为 X；若帖子指向底层论文/仓库/官方文档，以底层材料为主要依据。${DEEP_FIELDS} 每条标题必须写成数字列表项 '1. **[标题](URL)**'，字段用缩进项目符号。直接写 ${TMP_DIR}/03-blogs.md，只含 '## 三、博客 / 工程文档' 及条目。" \
    > "$TMP_DIR/03-blogs.log" 2>&1 &
  PID_BLOGS=$!

  echo "已并行启动 3 个 agent（PIDs: ${PID_ARXIV} ${PID_GITHUB} ${PID_BLOGS}）"
  FAIL=0
  for pid in "$PID_ARXIV" "$PID_GITHUB" "$PID_BLOGS"; do
    if ! wait "$pid"; then
      echo "警告: agent $pid 异常退出"
      FAIL=1
    fi
  done

  {
    echo "# 每日资讯 · $REPORT_DATE"
    echo ""
    for sec in 01-arxiv 02-github 03-blogs; do
      if [ -s "$TMP_DIR/$sec.md" ]; then
        sed '/^# 每日资讯/d' "$TMP_DIR/$sec.md"
      else
        case "$sec" in
          01-arxiv) echo "## 一、论文（arxiv）" ;;
          02-github) echo "## 二、GitHub 仓库" ;;
          03-blogs) echo "## 三、博客 / 工程文档" ;;
        esac
        echo ""
        echo "_（本板块未生成可验证内容，见运行日志）_"
      fi
      echo ""
    done
  } > "$DEST"
  echo "日报已写入: $DEST"

  python3 "$REPO_ROOT/scripts/validate_report.py" "$DEST"

  python3 "$REPO_ROOT/scripts/parse_to_db.py" "$TMP_DIR" \
    --report-date "$REPORT_DATE" --report-file "assets/daily/${REPORT_DATE}-daily-surf.md" \
    --out "$DB_JSON"

  if [ "$REVIEW" = "1" ]; then
    echo "审阅模式：已生成结构化 JSON；明确跳过飞书、邮件和周报。"
  elif [ -n "${FEISHU_APP_ID:-}" ] && [ -n "${FEISHU_APP_SECRET:-}" ] && [ -n "${FEISHU_APP_TOKEN:-}" ]; then
    python3 "$REPO_ROOT/scripts/feishu_bitable.py" --write-json "$DB_JSON" || \
      echo "警告: 飞书入库失败（不影响日报生成）"
  else
    echo "提示: 飞书配置不完整，跳过入库"
  fi

  if [ "$REVIEW" = "0" ] && [ "$FAIL" = "0" ]; then
    rm -rf "$TMP_DIR"
  fi

  if [ "$REVIEW" = "0" ] && [ "$(weekday_of "$REPORT_DATE")" = "1" ]; then
    WK="$(weekly_week "$REPORT_DATE")"
    WDEST="$REPO_ROOT/assets/weekly/w${WK}.md"
    "$AGENT_BIN" --print --trust -f --api-key "$CURSOR_API_KEY" --model auto \
      "按 openspec/specs/weekly-report/spec.md 和 .preference/ 聚合目标日期 ${REPORT_HUMAN} 的上一周内容，直接写入 ${WDEST}。" \
      >> "$LOGFILE" 2>&1
    echo "周报已写入: $WDEST"
  fi

  echo "[$(date '+%F %T')] ===== 日报流程结束 ====="
  return "$FAIL"
}

run_report 2>&1 | tee "$LOGFILE"
