# daily-surf 资讯自动化

> 个人科研 / 技术资讯流：每天自动抓取论文、博客/工程文档、GitHub 仓库三类精品长内容，生成日报/周报并邮件推送。
> 本文件是索引入口，具体内容见下方导航。

## 导航

| 分类 | 位置 | 说明 |
| --- | --- | --- |
| 偏好 / taste | [`.preference/`](.preference/) | 论文 [`papers.md`](.preference/papers.md) · 代码仓 `repos.md` · 博客 `blogs.md` · 反馈 `feedback/` |
| 流程规格 | [`openspec/specs/`](openspec/specs/) | 日报 [`daily-report`](openspec/specs/daily-report/spec.md) · 周报 [`weekly-report`](openspec/specs/weekly-report/spec.md) · 偏好反馈 [`preference-feedback`](openspec/specs/preference-feedback/spec.md) |
| 生成产物 | [`assets/`](assets/) | 日报 `assets/daily/` · 周报 `assets/weekly/` · 待审稿 `assets/review/` |
| 资讯库 | 飞书多维表格 | `papers` / `repos` / `blogs` 三表，S/A/B 分级，`report_file` 索引到日报 |
| 脚本与调度 | [`scripts/`](scripts/) | runner、邮件发送、飞书入库、launchd plist |

## 运行节律

| 事项 | 触发时间 | 产物 / 动作 |
| --- | --- | --- |
| 日报 | 每天 08:00（东八区） | 抓取最近 3 天三大板块，写 `assets/daily/YYYYMMDD-daily-surf.md` |
| 周报 | 每周一 08:00 | 聚合上一周内容，写 `assets/weekly/w{ISO周数}.md` |
| 资讯库 | 每天日报生成后 | 解析日报条目（含 S/A/B 分级）写入飞书多维表格 |
| 邮件 | 每天 09:00 | 渲染当日日报为 HTML 发至收件人；周一同时发周报 |

## 编码约定

全链路一律 **UTF-8**：脚本源码、`.env`、日志、日报/周报 markdown、渲染出的 HTML、飞书 API payload 均为 UTF-8。`scripts/lib.sh` 统一导出 `LC_ALL/LANG=C.UTF-8` 与 `PYTHONIOENCODING=utf-8`，所有入口脚本经 `lib.sh` 继承；Python 脚本读写文件均显式 `encoding="utf-8"`。

## 运行方式：GitHub Actions（云端为主）与本地 launchd（备选）

**云端（推荐）**：`.github/workflows/daily.yml` 每天 UTC 00:00（东八区 08:00）自动运行——安装 cursor-agent、生成日报（周一含周报）、提交回仓库、发邮件、写飞书，不依赖本机开机。

需在仓库 Settings → Secrets 配置：`CURSOR_API_KEY`、`SMTP_PASS`（可选覆盖 `SMTP_HOST`/`SMTP_PORT`/`SMTP_USER`/`SMTP_FROM`）、`FEISHU_APP_ID`、`FEISHU_APP_SECRET`、`FEISHU_APP_TOKEN`。CI 中配置只走环境变量（同 `.env` 同名），无需提交 `.env`。

手动补跑：Actions 页面「Run workflow」——填 `date`（YYYYMMDD）补跑某日；勾选 `review` 进入审阅模式（不发布、不入库、不发邮件，待审稿作为 artifact 下载）。

**本地（备选）**：launchd 两个定时任务仍可用。云端启用后建议执行 `scripts/install_schedule.sh` 禁用本地任务，避免重复生成。

## agent 规则

所有生成内容的 agent 一律遵循 [`openspec/AGENTS.md`](openspec/AGENTS.md)。

## 补跑与审阅

```bash
scripts/run_daily.sh --date 20260912 --review
scripts/publish_review.sh 20260912                 # 仅提升为正式日报
scripts/publish_review.sh 20260912 --feishu --mail # 明确入库并补发
```

审阅模式不会覆盖正式日报、写飞书或发送邮件。正式调度由专用 `DailySurfRunner.app` 启动；先运行 `scripts/install_runner_app.sh`，在 macOS“完全磁盘访问”中授权该 App，再用 `scripts/install_schedule.sh install` 安装为禁用状态，审阅通过后执行 `enable`。
