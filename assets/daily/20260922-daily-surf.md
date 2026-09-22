# 每日资讯 · 20260922

## 一、论文（arxiv）

1. **[DolphinBench: Mapping the Pareto Frontier of Agent Memory](https://arxiv.org/abs/2609.24971)**
   - 元信息：2026-09-22（arxiv new listings；v1 submitted 2026-09-21）；预印本；主题标签：Agent Memory / 知识工作任务完成评测 / 成本·延迟·准确率 Pareto / 可解性双盲验证；分级：S
   - 核心问题：主流记忆基准多为「问答即检索信号」——题目已暗示要召回哪类事实；且只报准确率，允许用全量重读历史刷分。需要用无提示的动作任务测「知不知道要记」，并把准确率、总成本、中位延迟一并报告，同时证明每题「有金证必过、无金证必败」。
   - 机制/设计：三人设知识工作 persona（startup CEO Morgan / 基建工程师 Alex / 产品经理 Riley），各约 3,400–5,128 条用户消息、≈500k user-token（tiktoken o200k_base）。分层构造：人设→多年叙事/季度/周事件→仿真 Notion·Gmail·GitHub 等 app 记录→只写用户侧消息（agent 摄入时自产回复）→LLM 提案依赖历史事实的任务与 grading。验证：GPT-5.6-Luna 对每题跑 2×oracle 消息必全过、2×无历史必全败，否则修订或剔除；共 600 题（200/人）。评分：确定性检查（工具名/ID/数值）+ GPT-5.6-Sol LLM judge（语义等价）；提交必须报 accuracy、摄入+测试总成本、$ 与 median latency。
   - 证据：Table 2（600 题）。Hermes+GPT-5.6-Luna+Mem0 准确率 70.67%（最高），总成本 $96.21、中位延迟 37.69 s；同骨干 Built-in 65.67%/$61.48/44.35 s。Hindsight 准确率 69.50%、成本 $84.65 但延迟 55.31 s；Honcho 68.50%/$142.85/44.66 s。换 MiniMax M3：Mem0 47.83% vs Built-in 26.50%。Claude Code+Sonnet 5：Honcho 35.83% 高于 Mem0 32.33%，但 agent 侧成本升至 $1.5k–$1.8k。记忆系统排名随 harness/模型翻转；最贵配置并非最准或最快。
   - 局限：Limitations——历史为合成、非真实用户多语/多风格；三人设未覆盖法务/医疗/客服；工具为可复现仿真而非生产故障与并发改写；单任务 1–4 个可评分动作，未测长依赖流水线；先完整摄入再测，未交错「边聊边测」。失败条件：无相关历史时任务应失败——若无历史仍过则题无效；oracle 过不了则题不可解。
   - 对办公 Agent 或 Agent 基础设施的意义：把办公记忆评测从「考回忆」改成「发邮件/下单/改表是否用对偏好与事实」，并强制报 $/延迟；选型应看 Pareto，而非只盯准确率。生产上可用同款「有/无金证双跑」验收记忆仓与 harness 组合。

2. **[RPMem: Learning Long-Term Recurrent Parametric Memory Across Sessions for LLM Agents](https://arxiv.org/abs/2609.23466)**
   - 元信息：2026-09-22（arxiv new listings；v1 submitted 2026-09-20）；预印本；主题标签：Agent Memory / 跨会话参数化记忆 / 前向编译+循环巩固门 / LoRA 解码与换骨干复用；分级：S
   - 核心问题：文本记忆每问都要检索并塞进上下文，长程依赖检索质量；现有参数化记忆多是单会话静态适配或与特定骨干耦合，换服务模型后记忆不可迁移。需要生命周期无关的固定容量跨会话记忆：前向写入、选择性巩固、解码到当前骨干 LoRA。
   - 机制/设计：两阶段。(1) Session Compilation：冻结上下文编码器 \(E_\xi\) + 可训 Perceiver resampler \(G_\phi\) 把会话压成定形潜变量 \(q_t\in\mathbb{R}^{L\times M\times r\times d}\)；解码器 \(D_\beta\) 生成 LoRA \(\Lambda_t\)；用固定参考回复上的 Top-\(K\)+tail Forward-KL 对齐「读原文」与「读 adapter」的下一 token 分布（Fixed FKL），并正则化 LoRA 幅度。(2) Cross-session Consolidation：\(h_1=q_1\)，其后 \(z_t=\sigma([h_{t-1};q_t]W_g+b_g)\)，\(h_t=z_t\odot h_{t-1}+(1-z_t)\odot q_t\)；仅训门 \(\psi\)，任务 CE 经冻结编译器/骨干回传。换骨干只重训解码器，保留 \(G_\phi\)、门与 \(h_T\)。
   - 证据：主骨干 Qwen3-8B。PERMA Core Avg. 85.52%（vs Metis-9B 80.20、Full Context 72.54；+5.32/+12.98 pp）；四核设定 SD-C/N、MD-C/N = 90.57/91.20/79.67/80.62。PersonaMem-v2 Overall/Self/Current = 40.22/43.61/47.28（vs Full Context 31.10/32.72/33.97）。PrefEval 在 300 intervening turns 达 74.81%（最佳），而 LightMem 从 10→300 轮由 81.30 降至 73.52。消融：Fixed FKL 85.52 vs Compiler SFT 61.21 / Top-\(K\) CE 77.66；Learned gate 85.52 vs factor averaging 54.21 / Latest Session 53.56（MD 差距最大）。64 会话：更新 0.043 s（≈Mem0 的 1/292）、记忆 36.6 MiB 且增长 ≈\(1.00\times\)、查询历史 token=0。换骨干仅重训解码：跨模型平均 75.97→89.64。一般能力：MMLU/GSM8K/IFEval 相对 Base 掉 ≤3.81 pp。
   - 局限：Limitations——巩固策略按目标场景任务监督，跨场景迁移性未证；编译器训练约 338 GPU-h。失败形态：无学习门而用拼接/平均时准确率崩（rank concat 仅 13.84%）；MD 异质会话上固定规则掉点最大。记忆不可审计为明文条目。
   - 对办公 Agent 或 Agent 基础设施的意义：给「跨周偏好/决策」一条不占 prompt 的参数化记忆配方——会话前向写入、固定容量巩固、换模型只换解码器；适合控制办公 Agent 上下文成本，但需另配可审计文本层与权限，因潜变量不可直接合规复查。

3. **[Propose, Verify, Commit: Evidence-Grounded Memory for Long-Horizon Multi-Actor Conversations](https://arxiv.org/abs/2609.23465)**
   - 元信息：2026-09-22（arxiv new listings；v1 submitted 2026-09-20）；预印本；主题标签：Agent Memory / 多参与者会话 / 可搜索状态机 / propose–verify–commit / 自适应证据导航；分级：S
   - 核心问题：多方长对话中证据分散在说话人、线程与语境，且先前决策会被修订；扁平相似度检索分不清「谁的证据、指向哪段状态、是否仍有效」。需要把持久证据与显式当前状态分离，写时有据更新、读时迭代定位。
   - 机制/设计：EGMemory 将记忆建模为 \(\mathcal{M}_t=(\mathcal{E}_t,\mathcal{S}_t,\mathcal{R}_t)\)。写路径：自适应解析入站消息相对已有状态 → Propose 结构化 \(\Delta_t\)（话题、与旧状态关系、状态值、检索表示）→ Verify 用确定性重叠启发式核对源消息与 prior-state 引用 → Commit 写入证据并更新活跃状态；修订为 \(e^{(k)}\prec e^{(k+1)}\)，旧证据保留。读路径：自适应证据导航，两遍检索（全局词法–语义锚点 → 话题桶/回复与版本邻域收窄再排）+ 当前态/精确词法/时间工具；无记忆专用策略训练，靠提示与工具调用（qwen3.7-max + text-embedding-v4 + qwen3-rerank）。
   - 证据：GroupMemBench 745 题 / EverMemBench 2,400 题 / LoCoMo 1,986 题；判分统一 Kimi-K3。总体：GroupMemBench 68.2%（95% CI 64.8–71.4，相对最强基线 +22.7）、EverMemBench 77.9%（+21.4）、LoCoMo 73.6%（+4.3）。类别：GroupMem Multi-hop 75.3（vs Mem0 35.2）、Temporal 80.2、Knowledge update 46.7；Abstention 79.1 低于 Mem0 92.8（覆盖–弃权权衡）。EverMem Multi-hop Trajectory 74.7（vs A-MEM 3.6）；Style 仅 32.4（弱于 MB-NF 51.1）。消融（GroupMem）：单轮 reader −7.9、去版本态 −5.0、去 reranker −4.7、去证据校验 −2.3。
   - 局限：Limitations——校验是词面重叠启发式非语义蕴含，强改写修订可能被拒、重叠也不保证语义正确；显式状态偏事实/决策，对风格等弥散信号弱；读写交互调用多，未优化延迟/token；单模型族与英语基准；多方记忆含敏感信息需配 ACL/删除策略。失败条件：无版本态或单轮检索时多跳/更新类掉点最大；过度搜索会伤弃权。
   - 对办公 Agent 或 Agent 基础设施的意义：适配「群聊/跨组协作/决策修订」办公场景——纪要与审批状态应证据 append-only、活跃态可版本追溯，读时用结构收窄+内容排序；落地把 verify 接到审计，并用覆盖–弃权策略约束「找不到就硬答」。

## 二、GitHub 仓库

1. **[genspark-ai/genoffice](https://github.com/genspark-ai/genoffice)**
   - 元信息：2026-09-21～2026-09-22（[v0.10.915](https://github.com/genspark-ai/genoffice/releases/tag/v0.10.915) 同步快照 [#657](https://github.com/genspark-ai/genoffice/pull/657)；本窗合入 `analyze_media`、自定义端点模型发现与多条防护补丁）；已发布开源（Apache-2.0）；主题标签：办公 Agent / Word·Excel·PPT·PDF / CLI·MCP / 可审阅修订与布局审计 / 路径与审计边界；分级：S；重复出现，值得关注
   - 核心问题：编码 Agent 若只能吐 Markdown/HTML 近似稿，或脆弱改 OOXML，无法在本机产出可进 Word/Excel/PowerPoint 的真文件，也无法让人按修订/公式/版式核验；需要把「读→改→审计→渲染」做成与编辑器同源的本地工具面，并对路径、缓冲与出站 URL 做硬边界。
   - 机制/设计：桌面套件本地打开/保存原生 `.docx`/`.xlsx`/`.pptx`（未改字节保留），AI 改动以修订轨/可回滚快照/批量 undo 落地；表格走自研 Rust xlsx 引擎与活公式。Agent 面：`genoffice` CLI 与 skill 走同一引擎；`genoffice mcp` 把命令登记为 MCP 工具（`docs_*`/`sheet_*`/`slides_*`/`deck_start→deck_page→deck_build` 等）。路径策略：`GENOFFICE_ALLOWED_ROOTS` 约束读写树；命令审计写入 `~/.genoffice/cli-audit.jsonl`。本窗增量：Docs 通过 `analyze_media` 读入文档内嵌图（[#544](https://github.com/genspark-ai/genoffice/pull/544)）；自定义 OpenAI 兼容端点可 `GET /models` 发现模型（[#586](https://github.com/genspark-ai/genoffice/pull/586)）；CLI 子进程输出帽 5MB、`normalizeBaseUrl` 禁非 http(s)、SSRF 重定向跳数有限、几何/解析数值全盘有限化。
   - 证据：README「Command line and agent skill / MCP」；[`packages/cli/README.md`](https://github.com/genspark-ai/genoffice/blob/main/packages/cli/README.md)（Path policy and audit log、`GENOFFICE_ALLOWED_ROOTS`、cli-audit）；实现 [`packages/cli/src/mcp/tools.ts`](https://github.com/genspark-ai/genoffice/blob/main/packages/cli/src/mcp/tools.ts)；Release [v0.10.915](https://github.com/genspark-ai/genoffice/releases/tag/v0.10.915)；PR [#544](https://github.com/genspark-ai/genoffice/pull/544)、[#586](https://github.com/genspark-ai/genoffice/pull/586)、[#594](https://github.com/genspark-ai/genoffice/pull/594)、[#622](https://github.com/genspark-ai/genoffice/pull/622)、[#593](https://github.com/genspark-ai/genoffice/pull/593)、[#671](https://github.com/genspark-ai/genoffice/pull/671)。
   - 局限：云侧 `search`/`image`/`media` 仍出站到配置提供商；无邮件/日历/Teams 连接器；PDF/复杂版式依赖本机渲染与 OCR；「world's first」属营销口径；大量本窗补丁为防护向数值/缓冲帽，需以兼容性与安全实测为准。
   - 对办公 Agent 或 Agent 基础设施的意义：给出「文档/表格/幻灯片」本地执行层配方——Agent 规划，CLI/MCP 做可检查写文件与布局审计；生产上应默认设允许根目录、读审计日志，并把图文理解（`analyze_media`）与出站 URL/缓冲帽一并纳入办公 Agent 工具面，而不是只靠模型自觉。

2. **[decionis/agent-safe-pipeline](https://github.com/decionis/agent-safe-pipeline)**
   - 元信息：2026-09-20～2026-09-22（[v0.3.2](https://github.com/decionis/agent-safe-pipeline/releases/tag/v0.3.2)→[v0.3.3](https://github.com/decionis/agent-safe-pipeline/releases/tag/v0.3.3)→[v0.3.4](https://github.com/decionis/agent-safe-pipeline/releases/tag/v0.3.4)；本窗重写并随发行附带 **Govern 2.0/2.1** 工作流门闸）；已发布开源（Apache-2.0 边界 + 托管权威）；主题标签：执行权威网关 / 人机审批 / 审计 dossier / 透明拦截 / CI·CD Govern；分级：S；重复出现，值得关注
   - 核心问题：办公 Agent 往往持有合法身份与未过期凭证，却仍可发出无人授权的发信、退款、删客户或部署副作用；仅靠身份/scope 无法回答「这一次、这些参数、这个目标」是否被授权，需要把执行权威绑到精确 action 上，并覆盖运行时 HTTP 与 CI 工作流两类入口。
   - 机制/设计：AgentSafe 作为反向代理/拦截器：对 `POST|PUT|PATCH|DELETE` 捕获 `agent-safe.intent/1`（canonical JSON + SHA-256），问 Decionis 得 `ALLOW|BLOCK|ESCALATE`；`ALLOW` 先 claim 单次 grant，再按已绑定字节转发一次；`ESCALATE` 经 Presence 人证后 resume；失败默认 fail-closed。透明拦截可对点名主机 **Govern**（旁路 TLS 由运营方 CA 终止）。本窗主增量：`govern/` 用单一 Go 二进制把门闸接到 GitHub Actions / GitLab CI / Jenkins / 任意可跑命令的 runner——`capture→enforce-and-bind→claim→run→finalize`，与运行时同一执行契约；v0.3.4 起附 Windows 归档并支持 `pwsh`/`powershell`/`cmd` 作为 gated shell。
   - 证据：README 状态表与 `agentsafe test`；[`docs/gateway/http-interception.md`](https://github.com/decionis/agent-safe-pipeline/blob/master/docs/gateway/http-interception.md)；[`docs/gateway/transparent-interception.md`](https://github.com/decionis/agent-safe-pipeline/blob/master/docs/gateway/transparent-interception.md)；[`govern/README.md`](https://github.com/decionis/agent-safe-pipeline/blob/master/govern/README.md)；PR [#243](https://github.com/decionis/agent-safe-pipeline/pull/243)（Go 重写）、[#249](https://github.com/decionis/agent-safe-pipeline/pull/249)（Windows/PowerShell）、Release [v0.3.3](https://github.com/decionis/agent-safe-pipeline/releases/tag/v0.3.3)/[v0.3.4](https://github.com/decionis/agent-safe-pipeline/releases/tag/v0.3.4)。
   - 局限：生产策略引擎与 Presence 不在本仓，需托管 Decionis 或自实现接口；透明 Govern 要求工作负载信任运营方 CA；尚无 HTTP/2 治理流、WebSocket、不定结果对账路由；默认只覆盖 80/443；Govern 的 `ESCALATE` 受契约五分钟意图 TTL 约束。
   - 对办公 Agent 或 Agent 基础设施的意义：把「发邮件/改表/调内部 API」与「办公流水线里的 deploy/迁移」统一成可测的执行权威层——同一合法身份下未授权意图必须 BLOCK/ESCALATE；落地可先 `agentsafe test`/shadow，再对邮件/CRM/支付出口与 CI 步骤套同一 intent/dossier 审计链。

3. **[basilos-ai/office-agent-benchmark](https://github.com/basilos-ai/office-agent-benchmark)**
   - 元信息：2026-09-20（首发提交 “Publish Office Agent Benchmark tasks and scoring”；dataset card 标 v0.1.0）；已发布开源（合成评测包，见 LICENSE-NOTICE）；主题标签：办公 Agent 评测 / 文档·表格·演示 / 邮件·会议·日程 / 安全授权与副作用约束；分级：A
   - 核心问题：办公 Agent 常被「能生成看似合理的 Word/Excel/邮件草稿」带过，却缺少可执行、可隔离的契约式评分——尤其「草稿≠发送」「不得伪造副作用」「受保护输入不可改」等授权边界，难以靠人工抽查或纯 LLM judge 复现。
   - 机制/设计：63 道合成任务，覆盖 `office_document`/`office_spreadsheet`/`office_presentation`、邮件往来、会议纪要、跨时区日程、PDF 核对，以及 `safety_authorization`、`recovery_reliability`、`skill_compliance` 等。流程：`prepare` 落盘只读夹具 → 外部 harness 跑 Agent → `grade` 按 case JSON 的 file/command/text 断言严格全过（无部分分）。评分器在 `evaluation/core`：夹具 SHA-256 完整性、路径逃逸与 symlink 拒绝、文件大小帽、命令评测需显式 `--allow-command-evaluators`；不调用模型、不附带成绩榜。
   - 证据：README / [DATASET_CARD.md](https://github.com/basilos-ai/office-agent-benchmark/blob/main/DATASET_CARD.md) / [SCORING.md](https://github.com/basilos-ai/office-agent-benchmark/blob/main/SCORING.md) / [TASKS.md](https://github.com/basilos-ai/office-agent-benchmark/blob/main/TASKS.md)；任务例 [`tasks/safety-03.md`](https://github.com/basilos-ai/office-agent-benchmark/blob/main/tasks/safety-03.md)（草稿≠发送、禁 `sent.log`）与契约 [`dataset/cases/safety-03.jsonl`](https://github.com/basilos-ai/office-agent-benchmark/blob/main/dataset/cases/safety-03.jsonl)；[`tasks/email-01.md`](https://github.com/basilos-ai/office-agent-benchmark/blob/main/tasks/email-01.md)、[`tasks/meeting-01.md`](https://github.com/basilos-ai/office-agent-benchmark/blob/main/tasks/meeting-01.md)；实现 [`evaluation/core/evaluators.ts`](https://github.com/basilos-ai/office-agent-benchmark/blob/main/evaluation/core/evaluators.ts)、[`evaluation/core/fs-safety.ts`](https://github.com/basilos-ai/office-agent-benchmark/blob/main/evaluation/core/fs-safety.ts)。
   - 局限：小样本合成集，作者明确不作统计代表性或视觉/自由写作质量主张；不含模型结果与排行榜；command 评测需隔离环境，flag 只是知情确认而非沙箱；邮件/会议/日程题量少于表格文档题；与 SpreadsheetBench/OfficeBench 仅借鉴职责分离，任务与代码自研。
   - 对办公 Agent 或 Agent 基础设施的意义：把「办公能力」从 demo 叙事拉回可回归的授权与副作用契约——可直接对照 GenOffice 类本地写文件 Agent 与 AgentSafe 类执行闸，用 `safety-03`/`email-*`/`meeting-*` 做 CI 冒烟，先验收「不越权发副作用」，再谈版式美观。

## 三、博客 / 工程文档

1. **[Agent Optimizer: A Faster Path to Better Outcomes](https://www.salesforce.com/blog/agent-optimizer/)**
   - 元信息：2026-09-21；已发布（Salesforce 官方博客；Agentforce beta）；主题标签：办公/业务 Agent 基础设施 / 生产可观测 / 回归测试闭环 / 人机审批·autonomy dial / 系统集成；分级：S
   - 核心问题：Agent 上线后失败模式、需求漂移与模型行为变化会持续出现，但「读会话→找模式→改指令/动作→回归」仍靠人工，跟不上日产数千会话；需要把生产洞察与构建/测试接成同一条可审计闭环，并由人定义成功标准与放权边界。
   - 机制/设计：Agent Optimizer 作为「造 Agent / 改 Agent」的元 Agent，挂在 Agentforce Builder 与 Observability。(1) 构建：自然语言业务意图（如「处理退货」）→ 配置含 subagents 与 actions；可从历史坐席/Agent 对话 transcript 抽取真实诉求起步，而非空白页。(2) 同环测试：模拟会话预览→失败则调查改配置再试；预览用例沉淀为可复用回归套件，后续改指令/加能力时自动复跑。(3) 生产：在 Observability 中按 resolution rate / CSAT 等业务目标分析数百～数千会话，按 tool-call 错误、知识缺口、跑题等聚类失败，再把推荐改动交回 Builder 实现与测试。(4) 人机控制：autonomy dial 可选「每步签字」或「调查→建议→构建→测试→暂存部署，仅在设定审查点停下」；人定 outcomes 与放权刻度，Agent 负责调查与起草变更。
   - 证据：客户口径——Engine 旅行平台 Agent 解决 50% 聊天问询、客服处理时长降 15%；Hibbett 零售用 Agent 覆盖 90% 核心购物路径。产品面给出 Builder 内改 Refund Status 子 Agent 推理指令并在 5 个测试用例上预览、Observability 按出现频次聚合 failure modes 的界面叙事；明确 beta、需联系 AE。
   - 局限：公开文偏产品叙事，未给误拦率、回归套件规模、autonomy dial 各级默认策略或 Decision 审计字段 schema；失败聚类与「知识源不可达」类归因依赖平台会话日志完备性；无跨租户对照实验；退货/客服主叙事，邮件/日历/Docs 垂直连接器细节未展开。
   - 对办公 Agent 或 Agent 基础设施的意义：把「会议跟进/退货/开票」类办公 Agent 的运维从周会复盘改成可配置的生产→测试→审批闭环；落地应默认把业务 KPI 挂进 Observability，并用 autonomy dial 把高副作用配置变更钉在人审，而不是只靠上线前一次 UAT。

2. **[Introducing Grok 4.7](https://x.ai/news/grok-4-7)**（底层：[Model Card: Grok 4.7](https://media.x.ai/v1/website/4p7card-5eccc980.pdf)）
   - 元信息：2026-09-21；已发布（xAI/SpaceXAI 官方公告 + 同日 Model Card rev. 2026-09-21）；主题标签：办公 Agent / Word·Excel·PowerPoint 插件 / 文档·表格·幻灯片技能 / 长时知识工作评测 / 安全与人机监督；分级：A
   - 核心问题：知识工作 Agent 若只强在写代码，无法在真实公文包里稳定产出可交付文档/表格/幻灯片，也无法在高风险域保持可校准拒答；需要把长时办公任务能力与生产安全栈一并交代，并标明高 stakes 场景不可无监督自治。
   - 机制/设计：更大基座 + 更长 RL（偏多小时任务），强化自检与长上下文；对 Grok Bot harness 做原生适配。分发面明确含 **Microsoft Word / PowerPoint / Excel 的 Grok 插件默认模型**，以及 API、Grok Build、Cursor、多网关。知识工作评测用文档/演示/表格技能：Legal Agent Benchmark 在无外网 Valkyrie harness 下用六类文件/终端工具 + document/presentation/spreadsheet skills 按准则全过才计通过。Model Card 声明高 stakes（医/法/财/安全关键）须人机监督与领域专家校验；生产侧新 safeguard stack 覆盖拒答、越狱、双用途 cyber/bio 等。
   - 证据：公告 AA Briefcase v1.1（多小时办公）1,657 vs Grok 4.6 的 1,546；称 GDPval/AA Briefcase 上文档与演示产出相对 4.6 提升。Model Card：Harvey Legal Agent 120 题 held-out，Grok 4.7 xhigh 19.6%（vs 4.6 high 15.8%；对照 GPT-5.6 Sol max 2.5%、Fable 5.1 6.7%）。安全：LatchBio biosafety 62.4%；HackerBench v0.3 仅放行 3.3% 高风险双用途提示。CursorBench 4.0 xhigh 46.3%（vs 4.6 的 40.4%）作长任务自检能力旁证。
   - 局限：AA Briefcase/GDPval 公告给分但 Model Card 正文未展开方法学表；Legal Agent 绝对通过率仍低（19.6%），说明长程公文包远未「可无人值守」；Office 插件仅为默认模型切换，无连接器级权限/审计/发信闸门设计；消费端 web/mobile/X 尚未上 4.7；部分安全评测在无生产护栏下量能力，与线上行为需分开读。
   - 对办公 Agent 或 Agent 基础设施的意义：把「制表/写稿/做幻灯片」锚定到 Word/Excel/PPT 插件与可测的文档技能基准，同时用 Model Card 把法务级任务钉死「须人审」；办公落地可优先用 4.7 做本地 Office 产物质量，但发信、外部分享与财务动作仍须外挂审批与审计，不可把基准分当作生产自治许可。

3. **[Spec-Driven Development comes to Azure Cosmos DB: The First Database Extension for GitHub Spec Kit](https://devblogs.microsoft.com/cosmosdb/spec-driven-development-comes-to-azure-cosmos-db-the-first-database-extension-for-github-spec-kit/)**
   - 元信息：2026-09-21；已发布（Azure Cosmos DB 工程博客；Spec Kit 扩展 public preview v0.2.0）；主题标签：Agent 基础设施 / 规格驱动·人机审批 / 实现前后钩子 / 托管身份与权限模式 / 可靠性回归；分级：A
   - 核心问题：编码 Agent 能吐应用代码，但分区键、访问模式与客户端韧性决定成本与正确性；若跳过可审计划直接实现，错误会 downstream 到一切依赖该库的办公/业务 Agent 数据面。需要把 Cosmos 最佳实践嵌进「规格→计划→任务→实现」并强制人审节点。
   - 机制/设计：GitHub Spec Kit 扩展提供 `/specify`→`/plan`→`/tasks`→`/implement`。扩展注入：点读/分区感知参数化查询、托管身份认证、韧性客户端等代码生成命令；按读写模式指导容器与分区键。v0.2.0 关键改动——`before_implement` advisor 把相关规则**直接写入实现上下文**且钩子不可跳过；`after_implement` 要求 Agent 对照指南自检、修复再复检。团队可用 presets 叠命名/安全/审批步骤而不 fork。配套仍建议结合 VS Code/MCP 查询工具（权限由你授予）与 Agent Kit skills。
   - 证据：最佳实践符合度：有指南 vs 无指南，24 组测试组合中 19 组提升，平均 pass rate +0.10；客户端 application-name 配置单项 +0.79；advisor 推荐 precision 0.57→0.68。端到端自治跑曾常跳过 Cosmos 命令——驱动了强制钩子。安装：`specify extension add cosmosdb --from …/v0.2.0.zip`；兼容 Copilot / Claude Code / Codex / Cursor / Gemini CLI。
   - 局限：作者明确——应用级自治测试仅「略高于」旧版且不确定性含零改进，仍低于「不用 Spec Kit 的 Agent」；第三模型因 runtime 失败无可用分；未测「人在每阶段审阅」的增益；preview 命令可能变；预设只提供指令不强制合规。
   - 对办公 Agent 或 Agent 基础设施的意义：凡办公 Agent 背后有共享状态库（工单、审批单、客户档案），应把数据面设计做成可审批工件，并用实现前/后硬钩子防止 Agent 绕过；生产上可对照——托管身份、分区感知查询与回归自检进默认流水线，而不是上线后再用运维 Agent 救火。

