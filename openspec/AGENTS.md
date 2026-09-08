# AGENTS.md — daily-surf agent 执行规则

本文件是所有 agent（含定时任务触发的 agent）在生成内容时必须遵守的规则。

## 1. 开始前必读

生成任何内容前，先读取以下文件：

1. `openspec/specs/` 下对应的规格（daily-report / weekly-report / preference-feedback）
2. `.preference/` 下的 taste 文档（papers.md / repos.md / blogs.md）
3. `.preference/feedback/` 下最近的反馈记录，了解用户最近的偏好变化

## 2. 内容范围

daily-surf **只关注精品长内容**，仅三个板块：

- 论文（arxiv）
- 博客 / 工程文档（前沿公司）
- GitHub 仓库

**不追踪**社交平台动态（X、LinkedIn 等）。用户自己会去 X 上看，不要在产出或 taste 文档里包含社交动态内容。

## 3. 产出落盘

- 日报写入 `assets/daily/YYYYMMDD-daily-surf.md`（日期为生成日，`+0800` 时区）
- 周报写入 `assets/weekly/w{ISO周数}.md`（ISO 周数以生成日所在周为准）
- 每条内容必须附原文链接；严格区分「已发布」与「未发布/预印本」
- **输出文档中不写数据抓取口径叙述**（如生成日、检索时间、方式说明），直接呈现内容

## 4. 偏好反馈闭环（必须执行）

每次生成日报/周报后，必须向用户收集反馈：

- 问「喜欢 / 不喜欢」，以及「为什么喜欢」「要往哪个方向改进」
- 将反馈结构化写入 `.preference/feedback/YYYYMMDD-*.md`
- 当反馈指向 taste 变化时，同步更新 `.preference/` 对应文档（papers / repos / blogs）
- 除非用户明确说不更新，否则每次产出后都要走这个闭环

## 5. 数据来源

- 优先使用 web 搜索并限定时间范围（`past week` / 具体日期区间）
- 论文：`arxiv` 的 `cs.CL / cs.MA / cs.AI / cs.LG` 等
- GitHub：Trending 周榜（star 增长过千的库，重点 AI/agent/多 agent）
- 公司博客/工程文档：OpenAI、Anthropic、Google DeepMind、Meta AI、Mistral、xAI、Qwen、DeepSeek 等

## 6. 语气与语言

- 面向用户「陈彦博」本人，语言用中文
- 点评要有信息量，避免空话；标注序号与原文链接