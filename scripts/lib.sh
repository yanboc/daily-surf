#!/usr/bin/env bash
# 公共函数：加载 .env、计算日期、判断周一
set -euo pipefail

# 全链路统一 UTF-8：脚本输出、日志、agent 读写、Python stdio 均为 UTF-8 编码。
# C.UTF-8 在 macOS 与 Linux（含 GitHub Actions runner）均可用。
export LC_ALL="${LC_ALL:-C.UTF-8}"
export LANG="${LANG:-C.UTF-8}"
export PYTHONIOENCODING="utf-8"

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# AGENT_BIN 可被环境覆盖；默认优先 PATH 中的 cursor-agent（CI），回退本机安装路径。
AGENT_BIN="${AGENT_BIN:-$(command -v cursor-agent || echo /Users/apple/.local/bin/cursor-agent)}"
LOG_DIR="$REPO_ROOT/logs"

mkdir -p "$LOG_DIR" "$REPO_ROOT/assets/daily" "$REPO_ROOT/assets/weekly" "$REPO_ROOT/assets/review"

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

# 指定日期的 weekday(1=周一 .. 7=周日)
weekday_of() {
  local d="$1"
  python3 -c "import datetime; d=datetime.datetime.strptime('${d}', '%Y%m%d').date(); print(d.isoweekday())"
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

# 基准日期 N 天前，均为 YYYYMMDD；基准日期默认东八区今天。
days_before_yyyymmdd() {
  local base="${1:-$(today_yyyymmdd)}"
  local n="${2:-2}"
  python3 -c "import datetime; d=datetime.datetime.strptime('${base}', '%Y%m%d').date(); print((d-datetime.timedelta(days=int('${n}'))).strftime('%Y%m%d'))"
}

human_date() {
  local d="$1"
  python3 -c "import datetime; print(datetime.datetime.strptime('${d}', '%Y%m%d').date().isoformat())"
}
