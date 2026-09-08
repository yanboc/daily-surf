#!/usr/bin/env bash
# 公共函数：加载 .env、计算日期、判断周一
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
AGENT_BIN="/Users/apple/.local/bin/cursor-agent"
LOG_DIR="$REPO_ROOT/logs"

mkdir -p "$LOG_DIR" "$REPO_ROOT/assets/daily" "$REPO_ROOT/assets/weekly"

# 加载 .env（兼容 `KEY=value`、`KEY = "value"` 等写法；去除空格与包裹引号）
load_env() {
  if [ -f "$REPO_ROOT/.env" ]; then
    eval "$(python3 - "$REPO_ROOT/.env" <<'PY'
import sys
path = sys.argv[1]
for line in open(path, encoding="utf-8"):
    line = line.strip()
    if not line or line.startswith("#") or "=" not in line:
        continue
    k, _, v = line.partition("=")
    k = k.strip()
    v = v.strip()
    if len(v) >= 2 and v[0] == v[-1] and v[0] in "\"'":
        v = v[1:-1]
    print("export %s=%s" % (k, repr(v)))
PY
)"
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

# 今天的 ISO 周数（取当前日）
iso_week_of() {
  local d="$1" # YYYYMMDD
  python3 -c "import datetime,sys; d=datetime.date(int('${d}'[:4]),int('${d}'[4:6]),int('${d}'[6:8])); print(d.isocalendar()[1])"
}

# 周报命名用「生成日所在 ISO 周数」（用户确认口径）
weekly_week() {
  iso_week_of "$1"
}