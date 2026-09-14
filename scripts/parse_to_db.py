#!/usr/bin/env python3
"""把 run_daily.sh 三个板块 agent 生成的中间 md 解析成结构化 JSON，供 feishu_bitable.py 入库。

CLI:
  python3 parse_to_db.py <tmp_dir> --report-date YYYYMMDD --report-file <md路径> --out <out.json>

<tmp_dir> 内应包含 01-arxiv.md / 02-github.md / 03-blogs.md（run_daily.sh 的 $TMP_DIR）。
输出 JSON 结构：{"papers":[...], "repos":[...], "blogs":[...]}，每条含
title/url/source/tier(S|A|B)/type/summary/report_date/report_file。
解析失败的行跳过并打印警告，不影响日报主流程。
"""
import json
import os
import re
import sys

# 列表项起点：数字 + 点/顿号/右括号 + 空白
ITEM_START = re.compile(r"^\s*\d+\s*[\.、\)]\s+")
TITLE_RE = re.compile(r"\*\*(.+?)\*\*")
URL_RE = re.compile(r"(https?://[^\s\)\]>]+)")
TIER_RE = re.compile(
    r"(?:分级|level|tier)\s*[:：]?\s*([SAB])\b"
    r"|【([SAB])】"
    r"|[（(]([SAB])级[)）]"
    r"|([SAB])级"
)
SOURCE_RE = re.compile(r"来源[:：]\s*(.+)")


def split_items(text):
    """把 md 按列表项切成 [(起始行号, 正文块), ...]。"""
    lines = text.splitlines()
    items = []
    cur = None
    for idx, ln in enumerate(lines):
        if ITEM_START.match(ln):
            if cur is not None:
                items.append(cur)
            cur = [idx, [ln]]
        else:
            if cur is not None:
                cur[1].append(ln)
    if cur is not None:
        items.append(cur)
    return items


def clean(s):
    s = re.sub(r"\*\*", "", s)
    s = re.sub(r"^\s*[-*]\s+", "", s)
    return s.strip().strip("- ").strip()


def extract_tier(block):
    joined = " ".join(block)
    for m in TIER_RE.finditer(joined):
        for g in m.groups():
            if g:
                return g
    return "B"  # 解析不到默认 B（可略过），避免字段空


def parse_block(block, item_type, default_source):
    joined = " ".join(block)
    text = "\n".join(block)

    # 标题：优先 **...**，内部若是 [text](url) 取 text；否则取首行去序号
    tm = TITLE_RE.search(text)
    if tm:
        raw = tm.group(1).strip()
        mlink = re.match(r"\[(.+?)\]\(.+?\)", raw)
        title = mlink.group(1) if mlink else raw
    else:
        title = ITEM_START.sub("", clean(block[0]))
    title = title.split("（已发布）")[0].split("（预印本）")[0].strip()
    if not title:
        return None

    # URL：优先 [text](url) 内的 url，其次行内第一个 url
    um = URL_RE.search(joined)
    url = um.group(1) if um else ""
    # 去掉链接后面的尾标点
    url = url.rstrip(".,;）)")

    tier = extract_tier(block)

    # source：blogs 优先「来源」字段，其次 URL host
    source = default_source
    if item_type in ("blog", "blogs"):
        sm = SOURCE_RE.search(text)
        if sm and sm.group(1).strip():
            source = sm.group(1).strip()
        elif url:
            source = url.split("/")[2].replace("www.", "")
    elif url:
        host = url.split("/")[2].replace("www.", "")
        source = host

    # summary：去掉标题行、链接行、来源/看点/分级前缀，合并剩余描述
    desc_lines = []
    for ln in block:
        s = clean(ln)
        s = ITEM_START.sub("", s).strip()
        if not s or s.startswith(("链接", "来源", "分级", "level", "tier")):
            continue
        if s.startswith("看点"):
            s = re.sub(r"^看点\s*[:：]\s*", "", s).strip()
            if s:
                desc_lines.append(s)
            continue
        if "[" + title + "]" in s:
            # 去掉 [title](url) 链接部分，保留后续点评（repos 的 "— 点评"）
            s = re.sub(r"\[[^\]]*\]\([^)]*\)", "", s)
            s = s.replace("**", "").strip(" —-—").strip()
            if not s:
                continue
        elif s == url:
            continue
        s = s.split("（已发布）")[0].split("（预印本）")[0].strip()
        if s and s != title:
            desc_lines.append(s)
    summary = "；".join(desc_lines) if desc_lines else ""

    return {
        "title": title,
        "url": url,
        "source": source,
        "tier": tier,
        "type": item_type,
        "summary": summary,
        "report_date": None,
        "report_file": None,
    }


def parse_file(path, item_type, default_source, report_date, report_file):
    if not os.path.exists(path):
        print("[parse] 缺少 %s，跳过" % path, file=sys.stderr)
        return []
    text = open(path, encoding="utf-8").read()
    out = []
    for _start, block in split_items(text):
        rec = parse_block(block, item_type, default_source)
        if rec is None:
            print("[parse] 无法解析条目，跳过: %s" % block[0][:60], file=sys.stderr)
            continue
        rec["report_date"] = report_date
        rec["report_file"] = report_file
        out.append(rec)
    return out


def main(argv):
    if len(argv) < 2:
        print(__doc__)
        return 2
    tmp_dir = argv[0]
    report_date = None
    report_file = None
    out_path = None
    i = 1
    while i < len(argv):
        if argv[i] == "--report-date" and i + 1 < len(argv):
            report_date = argv[i + 1]
            i += 2
        elif argv[i] == "--report-file" and i + 1 < len(argv):
            report_file = argv[i + 1]
            i += 2
        elif argv[i] == "--out" and i + 1 < len(argv):
            out_path = argv[i + 1]
            i += 2
        else:
            i += 1

    if not report_date:
        print("缺少 --report-date", file=sys.stderr)
        return 2

    result = {
        "papers": parse_file(os.path.join(tmp_dir, "01-arxiv.md"), "paper", "arxiv", report_date, report_file),
        "repos": parse_file(os.path.join(tmp_dir, "02-github.md"), "repo", "github", report_date, report_file),
        "blogs": parse_file(os.path.join(tmp_dir, "03-blogs.md"), "blog", "", report_date, report_file),
    }
    n = sum(len(v) for v in result.values())
    print("[parse] 解析 %d 条: papers=%d repos=%d blogs=%d"
          % (n, len(result["papers"]), len(result["repos"]), len(result["blogs"])))

    if out_path:
        with open(out_path, "w", encoding="utf-8") as f:
            json.dump(result, f, ensure_ascii=False, indent=2)
        print("[parse] 已写出 %s" % out_path)
    else:
        print(json.dumps(result, ensure_ascii=False, indent=2))
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
