# AGENTS.md — daily-surf agent 执行规则

本文件是所有 agent（含定时任务触发的 agent）在生成内容时必须遵守的规则。

## 1. 开始前必读

生成任何内容前，先读取以下文件：

1. `openspec/specs/` 下对应的规格（daily-report / weekly-report / preference-feedback）
2. `.preference/` 下的 taste 文档（papers.md / repos.md / blogs.md / people.md）
3. `.preference/feedback/` 下最近的反馈记录，了解用户最近的偏好变化

## 2. 产出落盘

- 日报写入 `assets/daily/YYYYMMDD-daily-surf.md`（日期为生成日，`+0800` 时区）
- 周报写入 `assets/weekly/w{ISO周数}.md`（ISO 周数以生成日所在周为准）
- 每条内容必须附原文链接；严格区分「已发布」与「未发布/预印本」

## 3. 偏好反馈闭环（必须执行）

每次生成日报/周报后，必须向用户收集反馈：

- 问「喜欢 / 不喜欢」，以及「为什么喜欢」「要往哪个方向改进」
- 将反馈结构化写入 `.preference/feedback/YYYYMMDD-*.md`
- 当反馈指向 taste 变化时，同步更新 `.preference/` 对应文档（papers / repos / blogs / people）
- 除非用户明确说不更新，否则每次产出后都要走这个闭环

## 4. 数据来源与时间口径

- 优先使用 web 搜索并限定时间范围（`past week` / 具体日期区间），口径要写清楚
- 论文：`arxiv` 的 `cs.CL / cs.MA / cs.AI / cs.LG` 等
- GitHub：Trending 周榜（star 增长过千的库，重点 AI/agent/多 agent）
- 公司博客：OpenAI、Anthropic、Google DeepMind、Meta AI、Mistral、xAI、Qwen、DeepSeek 等
- 大佬动态：Andrej Karpathy、Yann LeCun、Geoffrey Hinton、李飞飞、Andrew Ng 等

## 5. 语气与语言

- 面向用户「陈彦博」本人，语言用中文
- 点评要有信息量，避免空话；标注序号与原文链接