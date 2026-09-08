# 每日资讯 · 20260909

> 生成日：东八区 2026-09-09。数据口径见各板块；预印本已标注。

## 概述

面向偏好：LLM 后训练/对齐、Agentic AI、Agent Memory、Context Management；GitHub 侧重 AI/agent；博客优先 OpenAI/Anthropic/DeepMind/Meta AI/Mistral/xAI/Qwen/DeepSeek；大佬跟踪 Karpathy/LeCun/Hinton/李飞飞/Andrew Ng。

## 一、论文（arxiv）

> 口径：东八区 2026-09-09 晨间抓取；`arxiv.org/list/{cs.AI,cs.CL,cs.LG,cs.MA}/new` 当前显示 **Monday, 7 September 2026** 批次（Labor Day 后补发的最新 new listings）。主题筛选：LLM 后训练/对齐、Agentic AI、Agent Memory、Context Management；本批次未见梁文锋/DeepSeek 团队新作。

1. **CoSkill: Joint Reinforcement Learning of Reasoning and Meta-Skill Agents for Hierarchical Skill Evolution**  
   作者：Jinyuan Feng, Dongmin Li, Yiqun Chen, Yang Gao, Xing Chen, Huimu Wang, Zhiqiang Pu  
   链接：https://arxiv.org/abs/2609.04865 · 预印本 · cs.AI · 列入 2026-09-07 new  
   值得关注：把 meta-skill 从固定工作流改成可学习的 Meta-Skill Agent，与 Reasoning Agent 联合 RL，直接对准「agentic RL + 技能库共进化」。

2. **Persistent Teacher Anchoring for Tool-Using Agents**  
   作者：Hyun Bin Park, Kyungho Song, Sangmin Lee, Du-Seong Chang  
   链接：https://arxiv.org/abs/2609.04773 · 已发布（Accepted at EMNLP 2026 Main）· cs.LG/cs.AI/cs.CL · 列入 2026-09-07 new  
   值得关注：在工具调用场景把教师锚定做到 turn-level commitment，专治 on-policy 蒸馏里「学生乱调工具、前缀漂移」的后训练痛点。

3. **From Interaction Traces to Persistent Skills: Online Evolution for Computer-Use Agents**  
   作者：Longtao Hu, Xiao Liang, Linchao Zhu  
   链接：https://arxiv.org/abs/2609.04869 · 预印本 · cs.AI · 列入 2026-09-07 new  
   值得关注：把 GUI agent 的交互轨迹在线沉淀为可复用 persistent skills，正是 Agent Memory「跨任务保留程序性知识」的落地形态。

4. **Compact-Memory LLM Agents via Online Max-Member Clustering and Atom-Aware Packing**  
   作者：Jiahe Geng, Jinpeng Wang, Kun Yuan  
   链接：https://arxiv.org/abs/2609.04915 · 预印本 · cs.AI · 列入 2026-09-07 new  
   值得关注：在紧 prompt budget 下做在线聚类与 atom-aware packing，同时踩中 Agent Memory 与 Context Management 的质量–token 权衡。

5. **Does Your Agent's Memory Survive a Model Upgrade? A Controlled Study of Memory Portability**  
   作者：Ankit Goyal, Jaideep Ray  
   链接：https://arxiv.org/abs/2609.05339 · 预印本（under review）· cs.AI/cs.CL/cs.IR · 列入 2026-09-07 new  
   值得关注：系统测「换模型后记忆是否还认得」——verbatim 长上下文 vs 检索记忆的可移植性，对真实 agent 记忆基建很关键。

6. **TROVE: Adaptive Agent Skill Orchestration via Trace-Grounded Route Validation and Editing**  
   作者：Tianxing Wang, Mingming Zhao, Shuai Huang, Huiyang Xu, Chaoyue Niu, Shengzhong Liu, Fan Wu  
   链接：https://arxiv.org/abs/2609.05019 · 预印本 · cs.AI · 列入 2026-09-07 new  
   值得关注：反对执行前锁死编排，按运行时证据做局部 route 编辑（插入/后缀替换），是多技能 agent 编排的实用机制。
## 二、GitHub 热门仓库

> 数据口径：GitHub Trending 周榜（`since=weekly`），抓取时刻东八区 2026-09-09；筛选本周 star 增长 ≥1000 且与 AI/agent/多 agent 相关。

1. **[tt-a1i/archify](https://github.com/tt-a1i/archify)** · 本周 +14,946 ★  
   Agent Skill：用自包含 HTML/SVG 画可校验的架构/时序/数据流图，专给 coding agent 出图，避开 Mermaid 糊图。

2. **[mattpocock/skills](https://github.com/mattpocock/skills)** · 本周 +13,575 ★  
   从真实 `.agents` 目录抽出的工程向 Skills 合集，代表「agent = skills 市场」这一周的主流叙事。

3. **[DietrichGebert/ponytail](https://github.com/DietrichGebert/ponytail)** · 本周 +12,834 ★  
   让 AI agent 按「最懒的资深工程师」决策：少写代码、多质疑需求，偏行为约束而非新框架。

4. **[affaan-m/ECC](https://github.com/affaan-m/ECC)** · 本周 +7,735 ★  
   Agent harness 性能优化系统（Skills / instincts / memory / security），面向 Claude Code、Codex、Cursor 等统一加固。

5. **[NousResearch/hermes-agent](https://github.com/NousResearch/hermes-agent)** · 本周 +4,229 ★  
   「会成长的 agent」：自学习与持续演进路线，比一次性 prompt 包更接近长期个人 agent。

6. **[ruvnet/ruflo](https://github.com/ruvnet/ruflo)** · 本周 +1,578 ★  
   多 agent meta-harness：swarm 编排、自适应记忆与 RAG，直接贴合多 agent 工作流偏好。
## 三、大厂技术博客

> 时间口径：东八区 2026-09-09 生成；官网检索 past week（约 9/2–9/8）。截至抓取时点，优先来源在 **9/9 当日尚无新帖**（美西仍为 9/8 晚间），下列为近期已核实的技术/研究向更新（已排除融资通稿类）。DeepSeek 近一周无官网技术博客新增。

1. **On the Navier–Stokes Millennium Prize Problem**
   - 来源：OpenAI（Research）· 发布 2026-09-08
   - 链接：https://openai.com/index/navier-stokes-solution/
   - 看点：内部更强模型驱动约万级并发 agent 系统，在 ~88 小时内给出 Navier–Stokes 奇异性解析证明，并用 GPT-6 Astra 完成 Lean 形式化；明确不申领 Millennium Prize。

2. **Formalizing Fermat's Last Theorem**
   - 来源：Anthropic（Science）· 发布 2026-09-04
   - 链接：https://www.anthropic.com/research/formalizing-fermats-last-theorem
   - 看点：多 Claude agent + Prove2Me 协同，约 11 天写出端到端 Lean 可检 FLT 形式化（约 1300 万行 Lean / 2.95 万中间定理），展示大规模数学 autoformalization 的 harness 设计。

3. **Designing Grok Bot for a world of persistent agents**
   - 来源：xAI · 发布 2026-09-03
   - 链接：https://x.ai/news/designing-grok-bot
   - 看点：把产品原语从「会话」改成持久 Bot（独立记忆/计算机/Routines），讨论多 Bot 协同、能力共享 vs 角色记忆边界——对 Agent Memory / 长程委托很有工程参考价值。

4. **Introducing Gemini 3.8 Flash and 3.8 Flash Cyber**
   - 来源：Google DeepMind / Google Blog · 发布 2026-09-02
   - 链接：https://blog.google/innovation-and-ai/models-and-research/gemini-models/3-8-flash-and-3-8-flash-cyber/
   - 看点：同价位强化长程 coding / agentic 推理；另推 Fairwind 信任访问的 Flash Cyber（漏洞发现与自动修补），并强调 prompt-injection 鲁棒性。

5. **Introducing Muse Spark 1.3**
   - 来源：Meta AI Research · 发布 2026-09-02
   - 链接：https://research.meta.ai/blog/introducing-muse-spark-1-3
   - 看点：面向长程 agentic/coding：更会澄清与确认不可逆动作，多任务线程管理更稳；相对 1.2 约少 20% tool calls、少 25% tokens，并加强对抗/注入鲁棒性。
## 四、大佬动态

本板块今日无新增（东八区 2026-09-09 口径下，关注列表 Andrej Karpathy / Yann LeCun / Geoffrey Hinton / 李飞飞 / Andrew Ng 未检索到可核实的当日一手博客或公开发言；X 匿名抓取被限流、LinkedIn 近期动态需登录，一手社交源不可用；近几日可见内容均早于今日——如 Karpathy 约 09-07 的 reader3/LLM 阅读习惯讨论、LeCun 09-06 网络安全相关 LinkedIn、Hinton 配合英超智法案的 09-08 媒体引述、Andrew Ng 09-04 The Batch「Using coding agents」信函、李飞飞/World Labs 09-01 Atlas 发布——均不计入今日新增，故不编造条目）。

**时间口径**：东八区当日新增；来源渠道：公开网页检索 + 官方博客尝试抓取。
## 个人点评

_（待偏好反馈闭环补充）_

