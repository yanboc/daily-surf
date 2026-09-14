#!/usr/bin/env python3
"""飞书多维表格（Bitable）资讯库读写。

职责：
- 用 FEISHU_APP_ID / FEISHU_APP_SECRET 换取 tenant_access_token
- 校验/创建 papers、repos、blogs 三张表（缺则自动创建）
- 批量写入资讯记录（含 S/A/B 分级、report_file 索引）

CLI:
  python3 feishu_bitable.py --init                # 初始化三张表结构（幂等）
  python3 feishu_bitable.py --write-json <file>   # 从 JSON 批量写入

凭据从环境变量读取（run_daily.sh 的 load_env 已注入），若未注入则自动读仓库根 .env。
只依赖标准库 urllib.request。
"""
import json
import os
import sys
import urllib.error
import urllib.request

BASE = "https://open.feishu.cn/open-apis"

# 三张表：表名 -> (type 值, 默认 source 提示)
TABLES = [
    {"table_name": "papers", "type": "paper"},
    {"table_name": "repos", "type": "repo"},
    {"table_name": "blogs", "type": "blog"},
]

# 字段名 -> 飞书字段类型（1=多行文本, 3=单选）
FIELDS = [
    ("title", 1),
    ("url", 1),
    ("source", 1),
    ("tier", 3),
    ("type", 1),
    ("summary", 1),
    ("report_date", 1),
    ("report_file", 1),
]
TIER_OPTIONS = ["S", "A", "B"]


class FeishuError(Exception):
    pass


def _load_env():
    """环境变量未注入时，从仓库根 .env 兜底读取。"""
    need = [k for k in ("FEISHU_APP_ID", "FEISHU_APP_SECRET", "FEISHU_APP_TOKEN")
            if not os.environ.get(k)]
    if not need:
        return
    env_path = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", ".env")
    if not os.path.exists(env_path):
        return
    for line in open(env_path, encoding="utf-8"):
        line = line.strip()
        if not line or line.startswith("#") or "=" not in line:
            continue
        k, _, v = line.partition("=")
        k = k.strip()
        v = v.strip()
        if len(v) >= 2 and v[0] == v[-1] and v[0] in "\"'":
            v = v[1:-1]
        if k in need:
            os.environ.setdefault(k, v)


def _request(method, url, payload=None, token=None):
    headers = {"Content-Type": "application/json; charset=utf-8"}
    if token:
        headers["Authorization"] = "Bearer " + token
    data = json.dumps(payload).encode("utf-8") if payload is not None else None
    req = urllib.request.Request(url, data=data, headers=headers, method=method)
    try:
        with urllib.request.urlopen(req, timeout=30) as resp:
            return json.loads(resp.read().decode("utf-8"))
    except urllib.error.HTTPError as e:
        body = e.read().decode("utf-8", errors="replace")
        raise FeishuError("HTTP %s: %s" % (e.code, body)) from e
    except urllib.error.URLError as e:
        raise FeishuError("网络错误: %s" % (e.reason,)) from e


def get_tenant_token():
    app_id = os.environ.get("FEISHU_APP_ID", "").strip()
    app_secret = os.environ.get("FEISHU_APP_SECRET", "").strip()
    if not app_id or not app_secret:
        print("错误: 未配置 FEISHU_APP_ID / FEISHU_APP_SECRET，请在 .env 填写", file=sys.stderr)
        raise SystemExit(2)
    resp = _request(
        "POST",
        "%s/auth/v3/tenant_access_token/internal" % BASE,
        {"app_id": app_id, "app_secret": app_secret},
    )
    if resp.get("code") != 0:
        raise FeishuError("获取 tenant_access_token 失败: %s" % resp)
    return resp["tenant_access_token"]


def get_app_token():
    tok = os.environ.get("FEISHU_APP_TOKEN", "").strip()
    if not tok:
        print("错误: 未配置 FEISHU_APP_TOKEN（多维表格 app_token），请在 .env 填写", file=sys.stderr)
        raise SystemExit(2)
    return tok


def list_tables(token):
    app = get_app_token()
    resp = _request(
        "GET",
        "%s/bitable/v1/apps/%s/tables?page_size=100" % (BASE, app),
        token=token,
    )
    if resp.get("code") != 0:
        raise FeishuError("列出表失败: %s" % resp)
    return resp["data"]["items"]


def ensure_database(token):
    """确保三张表存在，缺则创建；返回 {table_name: table_id}。"""
    app = get_app_token()
    existing = {t["name"]: t["table_id"] for t in list_tables(token)}
    result = {}
    for spec in TABLES:
        name = spec["table_name"]
        if name in existing:
            result[name] = existing[name]
            continue
        fields = []
        for fn, ft in FIELDS:
            f = {"field_name": fn, "type": ft}
            if ft == 3:
                f["property"] = {"options": [{"name": o} for o in TIER_OPTIONS]}
            fields.append(f)
        resp = _request(
            "POST",
            "%s/bitable/v1/apps/%s/tables" % (BASE, app),
            {"table": {"name": name, "fields": fields}},
            token=token,
        )
        if resp.get("code") != 0:
            raise FeishuError("创建表 %s 失败: %s" % (name, resp))
        result[name] = resp["data"]["table_id"]
        print("[feishu] 已创建表: %s (%s)" % (name, resp["data"]["table_id"]))
    return result


def write_records(token, table_id, records):
    """批量写入（每批 <= 500 条）。records: [{field: value}]。"""
    app = get_app_token()
    total = 0
    for i in range(0, len(records), 500):
        batch = records[i:i + 500]
        payload = {"records": [{"fields": r} for r in batch]}
        resp = _request(
            "POST",
            "%s/bitable/v1/apps/%s/tables/%s/records/batch_create" % (BASE, app, table_id),
            payload,
            token=token,
        )
        if resp.get("code") != 0:
            raise FeishuError("批量写入失败: %s" % resp)
        total += len(batch)
        print("[feishu] 已写入 %d 条（累计 %d）" % (len(batch), total))
    return total


def main(argv):
    _load_env()

    if not any(a in argv for a in ("--init", "--write-json")):
        print(__doc__)
        return 0

    token = get_tenant_token()
    tables = ensure_database(token)

    if "--init" in argv:
        print("[feishu] 初始化完成，表结构：")
        for name, tid in tables.items():
            print("  - %s: %s" % (name, tid))
        return 0

    if "--write-json" in argv:
        idx = argv.index("--write-json")
        if idx + 1 >= len(argv):
            print("用法: feishu_bitable.py --write-json <file>", file=sys.stderr)
            return 2
        with open(argv[idx + 1], encoding="utf-8") as f:
            data = json.load(f)

        # 兼容三种结构：{"papers":[]...} | {"type":..,"items":[]} | [{..type..}]
        by_table = {}
        if isinstance(data, dict) and set(data).issubset({"papers", "repos", "blogs"}):
            by_table = data
        elif isinstance(data, dict) and "type" in data and "items" in data:
            by_table[data["type"]] = data["items"]
        elif isinstance(data, list):
            for r in data:
                by_table.setdefault(r.get("type", "paper"), []).append(r)
        else:
            print("无法识别的 JSON 结构", file=sys.stderr)
            return 2

        for table, records in by_table.items():
            if table not in tables:
                print("[feishu] 跳过未知表名 %s" % table, file=sys.stderr)
                continue
            if not records:
                print("[feishu] %s: 无记录" % table)
                continue
            rows = []
            for r in records:
                row = {}
                for fn, ft in FIELDS:
                    val = r.get(fn)
                    if val is None:
                        continue
                    if ft == 3:
                        row[fn] = str(val).upper() if str(val).upper() in TIER_OPTIONS else "B"
                    else:
                        row[fn] = str(val)
                rows.append(row)
            write_records(token, tables[table], rows)
        return 0

    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
