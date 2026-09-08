#!/usr/bin/env python3
"""极简 Markdown -> HTML 渲染器。

覆盖最常用元素：标题、粗体、行内代码、代码块、链接、无序/有序列表、段落。
先跑通，观感后续再迭代。
"""
import html
import re
import sys


def _escape(text: str) -> str:
    return html.escape(text, quote=False)


def _inline(text: str) -> str:
    # 行内代码（先处理，避免破坏其它规则）
    text = re.sub(r"`([^`]+)`", lambda m: "<code>%s</code>" % _escape(m.group(1)), text)
    # 粗体
    text = re.sub(r"\*\*(.+?)\*\*", r"<strong>\1</strong>", text)
    # 链接 [text](url)
    text = re.sub(
        r"\[([^\]]+)\]\((https?://[^\)]+)\)",
        lambda m: '<a href="%s">%s</a>' % (_escape(m.group(2)), m.group(1)),
        text,
    )
    return text


def render(md: str) -> str:
    lines = md.split("\n")
    out: list[str] = []
    i = 0
    in_list = None  # "ul" | "ol" | None
    in_code = False
    code_buf: list[str] = []

    while i < len(lines):
        line = lines[i].rstrip()

        # 代码块
        if line.strip().startswith("```"):
            if in_code:
                out.append("<pre><code>%s</code></pre>" % _escape("\n".join(code_buf)))
                code_buf = []
                in_code = False
            else:
                in_code = True
            i += 1
            continue
        if in_code:
            code_buf.append(line)
            i += 1
            continue

        stripped = line.strip()

        # 空行：结束列表
        if not stripped:
            if in_list:
                out.append("</%s>" % in_list)
                in_list = None
            i += 1
            continue

        # 标题
        m = re.match(r"^(#{1,6})\s+(.*)$", stripped)
        if m:
            if in_list:
                out.append("</%s>" % in_list)
                in_list = None
            level = len(m.group(1))
            out.append("<h%d>%s</h%d>" % (level, _inline(m.group(2)), level))
            i += 1
            continue

        # 无序列表
        m = re.match(r"^[-*+]\s+(.*)$", stripped)
        if m:
            if in_list != "ul":
                if in_list:
                    out.append("</%s>" % in_list)
                out.append("<ul>")
                in_list = "ul"
            out.append("<li>%s</li>" % _inline(m.group(1)))
            i += 1
            continue

        # 有序列表
        m = re.match(r"^\d+\.\s+(.*)$", stripped)
        if m:
            if in_list != "ol":
                if in_list:
                    out.append("</%s>" % in_list)
                out.append("<ol>")
                in_list = "ol"
            out.append("<li>%s</li>" % _inline(m.group(1)))
            i += 1
            continue

        # 表格行（简单处理：忽略分隔行，普通行转段落）
        if stripped.startswith("|"):
            if in_list:
                out.append("</%s>" % in_list)
                in_list = None
            # 表格分隔行 |---|---| 跳过
            if re.match(r"^\|[\s:|-]+\|$", stripped):
                i += 1
                continue
            cells = [c.strip() for c in stripped.strip("|").split("|")]
            out.append("<p>" + " | ".join(_inline(c) for c in cells) + "</p>")
            i += 1
            continue

        # 普通段落
        if in_list:
            out.append("</%s>" % in_list)
            in_list = None
        out.append("<p>%s</p>" % _inline(stripped))
        i += 1

    if in_list:
        out.append("</%s>" % in_list)
    if in_code:
        out.append("<pre><code>%s</code></pre>" % _escape("\n".join(code_buf)))

    return "\n".join(out)


def main() -> int:
    if len(sys.argv) != 3:
        print("usage: md2html.py <in.md> <out.html>", file=sys.stderr)
        return 2
    with open(sys.argv[1], "r", encoding="utf-8") as f:
        md = f.read()
    body = render(md)
    doc = (
        "<!DOCTYPE html><html><head><meta charset=\"utf-8\">"
        "<title>daily-surf</title>"
        "<style>"
        "body{font-family:-apple-system,'PingFang SC','Noto Sans CJK SC',sans-serif;"
        "max-width:860px;margin:32px auto;padding:0 20px;line-height:1.75;color:#1f2328;}"
        "h1,h2,h3,h4{border-bottom:1px solid #eaecef;padding-bottom:.3em;margin-top:1.5em;}"
        "a{color:#0969da;text-decoration:none;}"
        "code{background:#f6f8fa;padding:.2em .4em;border-radius:4px;font-size:90%;}"
        "pre{background:#f6f8fa;padding:14px;border-radius:6px;overflow:auto;}"
        "pre code{background:none;padding:0;}"
        "ul,ol{padding-left:1.6em;}"
        "</style></head><body>"
        + body
        + "</body></html>"
    )
    with open(sys.argv[2], "w", encoding="utf-8") as f:
        f.write(doc)
    return 0


if __name__ == "__main__":
    sys.exit(main())