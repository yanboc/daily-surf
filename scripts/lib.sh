#!/usr/bin/env bash
# 公共函数：加载 .env、计算日期、判断周一
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
AGENT_BIN="/Users/apple/.local/bin/cursor-agent"
LOG_DIR="$REPO_ROOT/logs"

mkdir -p "$LOG_DIR" "$REPO_ROOT/assets/daily" "$REPO_ROOT/assets/weekly"

# 加载 .env
load_env() {
  if [ -f "$REPO_ROOT/.env" ]; then
    set -a
    # shellcheck disable=SC1091
    source "$REPO_ROOT/.env"
    set +a
  fi
}

# 东八区今天 YYYYMMDD
today_yyyymmdd() {
  TZ=Asia/Shanghai date +%Y%m%d
}

# 东八区今天 weekday(1=周一 .. 7=周日)
today_weekday() {
  TZ=Asia/Shanghai date +%u
}

# 今天的 ISO 周数（取当前日），用于周报命名上一周用
iso_week_of() {
  local d="$1" # YYYYMMDD
  python3 -c "import datetime,sys; d=datetime.date(int('${d}'[:4]),int('${d}'[4:6]),int('${d}'[6:8])); print(d.isocalendar()[1])"
}

# 上一周（周一到周日）所在的 ISO 周数——周一生成时用上周一计算
prev_iso_week() {
  TZ=Asia/Shanghai python3 -c "import datetime; d=datetime.datetime.now()+datetime.timedelta(days=-7); print(d.isocalendar()[1])"
}