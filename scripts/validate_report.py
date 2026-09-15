#!/usr/bin/env python3
"""校验日报的三板块、条目数量和深度字段。"""
from pathlib import Path
import re
import sys

SECTIONS = ["## 一、论文（arxiv）", "## 二、GitHub 仓库", "## 三、博客 / 工程文档"]
FIELDS = ["元信息", "核心问题", "机制/设计", "证据", "局限", "意义"]
ITEM = re.compile(r"(?m)^\s*\d+[.、)]\s+")


def validate(text: str) -> list[str]:
    errors: list[str] = []
    headings = [line for line in text.splitlines() if line.startswith("## ")]
    if headings != SECTIONS:
        errors.append("必须且只能包含三个规定板块")
    starts = list(ITEM.finditer(text))
    if not 6 <= len(starts) <= 9:
        errors.append(f"条目数必须为 6-9，实际为 {len(starts)}")
    for index, match in enumerate(starts):
        end = starts[index + 1].start() if index + 1 < len(starts) else len(text)
        block = text[match.start():end]
        missing = [field for field in FIELDS if field not in block]
        if missing:
            errors.append(f"第 {index + 1} 条缺少字段: {', '.join(missing)}")
        if "http://" not in block and "https://" not in block:
            errors.append(f"第 {index + 1} 条缺少原文链接")
        # 日期只做正则匹配（如 2026-09-10 / 2026/09/10 / 2026年9月），不强制「日期」字样
        if not re.search(r"20\d\d\s*[-/.年]\s*\d{1,2}", block):
            errors.append(f"第 {index + 1} 条元信息缺少日期")
        # 分级容忍加粗与不同写法：分级：S / 分级：**S** / 【S / 元信息行尾「；S」
        clean = block.replace("**", "")
        has_tier = re.search(r"(?:分级|【)[：:]?\s*[SAB](?![A-Za-z])", clean) or re.search(
            r"(?m)[；;]\s*[SAB]\s*$", clean
        )
        if not has_tier:
            errors.append(f"第 {index + 1} 条缺少 S/A/B 分级")
    return errors


def main() -> int:
    if len(sys.argv) != 2:
        print("usage: validate_report.py <report.md>", file=sys.stderr)
        return 2
    path = Path(sys.argv[1])
    errors = validate(path.read_text(encoding="utf-8"))
    if errors:
        for error in errors:
            print(f"[validate] {error}", file=sys.stderr)
        return 1
    print(f"[validate] 通过: {path}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
