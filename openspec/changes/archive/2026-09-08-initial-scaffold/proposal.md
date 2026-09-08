## Why

用户需要一个无人值守的本地资讯流：每天自动抓取当日 AI/agent 领域的新论文、GitHub 热门库、大厂博客、大佬动态，生成日报并通过邮件推送；每周一额外生成周报。此前仓库里是一份手动维护、已过时且自相矛盾的飞书周报流程，需要彻底重建成「定时生成 → markdown 落盘 → HTML 邮件」的自动化系统，并用 openspec 管理流程规格、用 `.preference/` 沉淀用户 taste 并形成反馈闭环。

## What Changes

- 新建三个能力规格：`daily-report`（每日日报生成）、`weekly-report`（每周周报生成）、`preference-feedback`（产出后偏好反馈闭环）
- 重写 `README.md` 为纯索引，指向 `.preference/`、`openspec/specs/`、`assets/`、`scripts/`
- 完善 `.preference/`：修正 `papers.md`，新建 `repos.md` / `blogs.md` / `people.md` 及 `feedback/` 记录模板
- 新增邮件与调度脚本：`mail_list.json`、`.env.example`、`scripts/send_mail.py`、`scripts/md2html.py`、launchd plist 与 runner 脚本
- 生成首份样例日报与周报到 `assets/`

## Capabilities

### New Capabilities
- `daily-report`: 每日抓取四大板块并生成日报、落盘、标记发布时间口径
- `weekly-report`: 每周一聚合上一周四大板块生成周报、落盘
- `preference-feedback`: 每次产出后收集用户「喜欢/不喜欢 + 原因 + 改进方向」并回写 taste 文档

### Modified Capabilities
<!-- 无 -->

## Impact

- 新增 `scripts/`（Python 邮件与渲染脚本、shell runner、launchd plist）
- 新增 `assets/daily/` 与 `assets/weekly/` 目录
- 依赖：macOS `launchd`、Python `smtplib`、Cursor SDK（`cursor_sdk`）、`openspec` CLI
- 凭证：`.env`（SMTP 与 `CURSOR_API_KEY`，不入仓）