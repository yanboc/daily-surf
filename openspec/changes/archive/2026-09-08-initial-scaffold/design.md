## Context

参见 `proposal.md - Why`。当前仓库是一个空壳：git 未提交、无脚本、`.preference/papers.md` 只有残缺占位。需要一次性搭建自动化地基。

## Goals / Non-Goals

- 目标：跑通「定时触发 → 生成 → 落盘 → 渲染 → 发信」全链路，并让偏好反馈可沉淀
- 非目标：本阶段不做内容抓取的工程实现（由 agent 运行时用 web 搜索完成），不做 HTML 观感打磨

## Decisions

### 1. 调度引擎：macOS launchd

用 macOS 原生 `launchd`（plist + shell runner）而非 cron，理由：macOS 上 cron 常因休眠/权限被系统吞掉，launchd 更可靠且无需额外依赖。

- 日报：`com.daily-surf.daily`，每天 08:00
- 邮件：`com.daily-surf.mail`，每天 09:00
- 周报：挂在日报 runner 内部判断「是否周一」，不额外建第三个 plist

### 2. 内容生成：Cursor SDK（Python）

用 `cursor_sdk`（`Agent.prompt` 一次性调用）驱动 agent 按 `openspec/specs/` 与 `.preference/` 生成内容，替代手写抓取器。理由：抓取+筛选+点评本质是 agent 任务，SDK 是最直接的桥。

- 省流：需要 `CURSOR_API_KEY`（放 `.env`），runner 内显式读取
- 备选：直接写 Python 抓取脚本（arxiv API / GitHub API / RSS），但点评与 taste 匹配成本高，暂不采用

### 3. 邮件：SMTP + 自研 md→html

发件人 `yanboch@126.com`，走 126 SMTP 授权码。渲染用自研 `md2html.py` 做最简转换（标题/粗体/链接/代码块/列表），先跑通再美化。

- 备选：`markdown2` / `mistune` 等库，但引入依赖且当前只需最简渲染，暂不引入

### 4. 目录结构

- `assets/daily/` 与 `assets/weekly/` 分层放置（原计划平铺 `assets/`），更清晰
- `.preference/` 拆分为 papers/repos/blogs/people 四个 taste 文档 + `feedback/` 记录目录

## Risks / Trade-offs

- [launchd 不加载或休眠跳过] → 在 runner 里写日志，plist 用 `RunAtLoad` false、`StandardErrorPath` 定位到日志文件
- [Cursor SDK 未安装] → 需要在环境里 `pip install cursor-sdk`，并把安装步骤写进 runner 前检查
- [126 SMTP 授权码未填] → `.env` 缺失时脚本报错并退出，不静默失败

## Migration Plan

1. 建好脚本与目录后，`launchctl load` 两个 plist
2. 手动跑一次 runner 验证生成与发信
3. 回滚：`launchctl unload` 即可，无外部状态

## Open Questions

- `CURSOR_API_KEY` 的具体获取路径（Dashboard → Integrations）由用户后续提供
- HTML 观感具体样式留待用户反馈后迭代