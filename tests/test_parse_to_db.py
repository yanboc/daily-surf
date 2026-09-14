import importlib.util
import tempfile
from pathlib import Path
import unittest

ROOT = Path(__file__).resolve().parents[1]


def load_script(name):
    spec = importlib.util.spec_from_file_location(name, ROOT / "scripts" / f"{name}.py")
    module = importlib.util.module_from_spec(spec)
    assert spec.loader
    spec.loader.exec_module(module)
    return module


parse_to_db = load_script("parse_to_db")


class ParseToDbTests(unittest.TestCase):
    def test_deep_item_is_parsed(self):
        block = [
            "1. **[Memory Paper](https://arxiv.org/abs/2609.12345)**",
            "   - 元信息：2026-09-10；预印本；分级：S",
            "   - 核心问题：记忆写入失控。",
            "   - 机制/设计：门控写入。",
            "   - 证据：消融有效。",
            "   - 局限：只测单一模型。",
            "   - 对 Agent 基础设施的意义：可控制记忆成本。",
        ]
        row = parse_to_db.parse_block(block, "paper", "arxiv")
        self.assertEqual(row["title"], "Memory Paper")
        self.assertEqual(row["tier"], "S")
        self.assertEqual(row["url"], "https://arxiv.org/abs/2609.12345")
        self.assertIn("门控写入", row["summary"])

    def test_missing_tier_defaults_to_b(self):
        row = parse_to_db.parse_block(
            ["1. **[Repo](https://github.com/org/repo)**", "   - 核心问题：测试。"],
            "repo",
            "github",
        )
        self.assertEqual(row["tier"], "B")

    def test_missing_file_is_empty(self):
        with tempfile.TemporaryDirectory() as directory:
            rows = parse_to_db.parse_file(
                str(Path(directory) / "missing.md"), "paper", "arxiv", "20260910", "report.md"
            )
        self.assertEqual(rows, [])


if __name__ == "__main__":
    unittest.main()
