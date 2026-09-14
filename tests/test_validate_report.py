import importlib.util
from pathlib import Path
import unittest

ROOT = Path(__file__).resolve().parents[1]
spec = importlib.util.spec_from_file_location("validate_report", ROOT / "scripts" / "validate_report.py")
validator = importlib.util.module_from_spec(spec)
assert spec.loader
spec.loader.exec_module(validator)


def item(n: int) -> str:
    return f"""{n}. **[标题 {n}](https://example.com/{n})**
   - 元信息：日期 2026-09-10；已发布；分级：A
   - 核心问题：问题
   - 机制/设计：机制
   - 证据：证据
   - 局限：局限
   - 对办公 Agent 的意义：意义
"""


class ValidateReportTests(unittest.TestCase):
    def test_valid_six_item_report(self):
        text = "# 每日资讯\n\n" + "\n".join(
            [
                "## 一、论文（arxiv）\n" + item(1) + item(2),
                "## 二、GitHub 仓库\n" + item(1) + item(2),
                "## 三、博客 / 工程文档\n" + item(1) + item(2),
            ]
        )
        self.assertEqual(validator.validate(text), [])

    def test_shallow_report_fails(self):
        text = "\n".join(validator.SECTIONS) + "\n1. **[x](https://example.com)**"
        self.assertTrue(validator.validate(text))

    def test_date_without_literal_keyword_passes(self):
        text = "# 每日资讯\n\n" + "\n".join(
            [
                "## 一、论文（arxiv）\n" + item(1).replace("日期 2026-09-10", "2026-09-10") + item(2),
                "## 二、GitHub 仓库\n" + item(1) + item(2),
                "## 三、博客 / 工程文档\n" + item(1) + item(2),
            ]
        )
        self.assertEqual(validator.validate(text), [])


if __name__ == "__main__":
    unittest.main()
