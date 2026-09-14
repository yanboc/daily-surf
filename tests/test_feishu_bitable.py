import importlib.util
import os
from pathlib import Path
from unittest import mock
import unittest

ROOT = Path(__file__).resolve().parents[1]
spec = importlib.util.spec_from_file_location("feishu_bitable", ROOT / "scripts" / "feishu_bitable.py")
feishu = importlib.util.module_from_spec(spec)
assert spec.loader
spec.loader.exec_module(feishu)


class FeishuTests(unittest.TestCase):
    def test_ensure_database_reuses_and_creates_tables(self):
        responses = [
            {"code": 0, "data": {"items": [{"name": "papers", "table_id": "p"}]}},
            {"code": 0, "data": {"table_id": "r"}},
            {"code": 0, "data": {"table_id": "b"}},
        ]
        with mock.patch.dict(os.environ, {"FEISHU_APP_TOKEN": "app"}), mock.patch.object(
            feishu, "_request", side_effect=responses
        ):
            tables = feishu.ensure_database("tenant")
        self.assertEqual(tables, {"papers": "p", "repos": "r", "blogs": "b"})

    def test_write_records_batches_at_500(self):
        with mock.patch.dict(os.environ, {"FEISHU_APP_TOKEN": "app"}), mock.patch.object(
            feishu, "_request", return_value={"code": 0}
        ) as request:
            total = feishu.write_records("tenant", "table", [{"title": str(i)} for i in range(501)])
        self.assertEqual(total, 501)
        self.assertEqual(request.call_count, 2)

    def test_http_failure_is_not_silenced(self):
        with mock.patch.dict(os.environ, {"FEISHU_APP_TOKEN": "app"}), mock.patch.object(
            feishu, "_request", return_value={"code": 999, "msg": "failed"}
        ):
            with self.assertRaises(feishu.FeishuError):
                feishu.write_records("tenant", "table", [{"title": "x"}])


if __name__ == "__main__":
    unittest.main()
