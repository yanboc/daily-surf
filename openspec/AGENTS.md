# AGENTS.md — daily-surf agent 执行规则

本文件是所有 agent（含定时任务触发的 agent）在生成内容时必须遵守的规则。

## 1. 开始前必读

生成任何内容前，先读取以下文件：

1. `openspec/specs/` 下对应的规格（daily-report / weekly-report / preference-feedback）
2. `.preference/` 下的 taste 文档（papers.md / repos.md / blogs.md）
3. `.preference/feedback/` 下最近的反馈记录，了解用户最近的偏好变化

## 2. 内容范围

daily-surf **只关注精品长内容**，产出仅保留三个板块：

- 论文（arxiv）
- 博客 / 工程文档（可包含作者或项目团队的一手 X 长帖）
- GitHub 仓库

普通 X posts 只作发现线索；作者或项目团队的一手长帖可以进入博客板块并明确标注来源。若长帖指向论文、仓库或官方文档，优先阅读和引用底层材料。

## 3. 产出落盘

- 日报写入 `assets/daily/YYYYMMDD-daily-surf.md`（日期为生成日，`+0800` 时区）
- 周报写入 `assets/weekly/w{ISO周数}.md`（ISO 周数以生成日所在周为准）
- 每条内容必须附原文链接；严格区分「已发布」与「未发布/预印本」
- 每条内容需带 **S/A/B 分级**（S=强烈关注、A=值得读、B=可略过），依据 `.preference/` 偏好自动打标，供后续入库
- 每份日报控制在 6–9 条，每板块通常 2–3 条；质量不足时不凑数
- 每条需写清元信息、核心问题、机制/设计、证据、局限以及对办公 Agent 或 Agent 基础设施的意义
- 论文必须阅读方法、实验/案例与 limitations；仓库必须阅读 README、官方文档和关键设计/近期变更；博客必须阅读全文
- 日报生成后由 `parse_to_db.py` 解析条目、`feishu_bitable.py` 写入飞书多维表格（papers/repos/blogs 三表）
- **输出文档中不写数据抓取口径叙述**（如生成日、检索时间、方式说明），直接呈现内容
- 所有产出文件与运行日志一律使用 **UTF-8** 编码

## 4. 偏好反馈闭环（必须执行）

每次生成日报/周报后，必须向用户收集反馈：

- 问「喜欢 / 不喜欢」，以及「为什么喜欢」「要往哪个方向改进」
- 将反馈结构化写入 `.preference/feedback/YYYYMMDD-*.md`
- 当反馈指向 taste 变化时，同步更新 `.preference/` 对应文档（papers / repos / blogs）
- 除非用户明确说不更新，否则每次产出后都要走这个闭环

## 5. 数据来源

- 优先使用 web 搜索并限定时间范围（`past week` / 具体日期区间）
- 抓取窗口：日报取目标日及其前两天，共 **3 个自然日**（东八区）；周报取上一周（周一至周日）。同一内容在窗口内重复出现时正常保留，不因重复剔除
- 论文：`arxiv` 的 `cs.CL / cs.MA / cs.AI / cs.LG` 等
- GitHub：Trending 周榜（star 增长过千的库，重点 AI/agent/多 agent）
- 公司博客/工程文档：OpenAI、Anthropic、Google DeepMind、Meta AI、Mistral、xAI、Qwen、DeepSeek 等
- 主题：论文重点为办公 Agent、Agent Memory、上下文管理器、多 Agent 协同，尤其优先后三项；GitHub/博客/X 线索重点关注办公 Agent

## 6. 语气与语言

- 面向用户「陈彦博」本人，语言用中文
- 点评要有信息量，避免空话；标注序号与原文链接
