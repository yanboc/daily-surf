# 每日资讯 · 20260923

## 一、论文（arxiv）

1. **[CliffCompaction: Cost-Efficient Compaction for Long-Horizon Coding Agents](https://arxiv.org/abs/2609.26779)**
   - 元信息：2026-09-23（arxiv new listings；v1 submitted 2026-09-22）；预印本；主题标签：Context Engineering / 工具输出截断式压缩 / 非递归 cliff 丢弃旧 compaction / KV-cache 友好 / 测试时扩展与持续优化；分级：S
   - 核心问题：长程 Agent 轨迹以工具调用与工具输出为主（Terminal-Bench 上约占 token 的 84%），上下文易爆；LLM 摘要式 compaction 会链式失真（低 precision），频繁改写上下文又会打穿 KV-cache 导致重 prefill。需要一种无训练、无辅模型、可即插的压缩：在保真保留近期关键证据的同时控成本。
   - 机制/设计：规则驱动 CliffCompaction。(1) 上下文自然增长至阈值 \(B\)（如 32K/16K/8K）才触发压缩；(2) 工具结果 >500 字符直接丢弃、短结果保留；工具调用压成 name+关键参数签名（正文可再调同一工具恢复）；thoughts 截断至 300 字符；系统提示与首条任务描述全文保留，最近 \(K\) 轮原样；(3) 关键：\(S_t=C_{t-1}\oplus L_t\)，新压缩只对 live session \(L_t\) 做 \(\textsc{CliffCompaction}\)，**整段丢弃**旧 \(C_{t-1}\)，禁止「摘要套摘要」。刻意用低 recall、高 precision 换取无漂移；信息仅经后续行为隐式残留传播。
   - 证据：Terminal-Bench 2.0（Terminus-2）：Kimi K2.6 全上下文 59.16% → Cliff 32K/16K 均为 61.42%（+2.26pp），16K 成本约 $0.19 vs 全上下文 $0.40；同预算下 native 摘要仅 55.45%。Claude Code + GLM 5.3 Flash：匹配 ~45K peak 时 Cliff 76.69% > 原生自动压缩 70.97% 与 200K 默认 73.03%。SWE-bench Verified：Kimi 全上下文 73.87% → 32K 73.27%、16K 约 −2pp 内。测试时扩展：三路 Kimi@16K Cliff 达 69.7%（匹配 Opus 4.7 69.4%），总成本 $58.01，低于单次 GPT-5.3 Codex，相对无压缩三路 +5.7pp 且成本低 37%。KernelBench L3：无压缩多数 run 在 256K 窗口提前死（中位约 99–122 步），Cliff 200/400 步可达 \(2.23\times\)/\(3.58\times\)（L40S）速度提升。
   - 局限：Limitations——收益依赖 scaffold 固定开销与任务时长，短任务意义有限；最低可用 \(B\) 随系统提示/工具定义变化；仅对比「对话历史上的推理时压缩」，未与外存记忆或训练式自管理上下文对照。失败形态：8K 过紧时成功率和 cache 命中率明显掉；丢弃工具输出后 Agent 会增多 re-read（相对摘要策略）。
   - 对办公 Agent 或 Agent 基础设施的意义：给「邮件附件读入、表格导出、长会议纪要工具链」一类长办公轨迹一套默认 compaction——优先砍可重取的大工具 I/O、保任务指令与近窗原文、禁止递归摘要；生产上可把 \(B\) 与工具签名重放接到 harness，用省下的预算做并行试跑，而不是堆更长窗口。

2. **[SpeakerMem-R1: Speaker-Centered Dual-Track Memory for Multi-Party Dialogue](https://arxiv.org/abs/2609.26780)**
   - 元信息：2026-09-23（arxiv new listings；v1 submitted 2026-09-22）；预印本；主题标签：Agent Memory / 多方对话 / 双轨原文+人/组视图 / Anchor–Separate–Resolve–Compose / Speaker 条件 GRPO Writer；分级：S
   - 核心问题：群聊记忆不是扁平消息流——需同时保住「谁说的、关于谁、群体共识、状态如何修订」。通用记忆系统常丢归因与关系，或无法从交错历史重建当前态。需要可追溯的双轨存储 + 按人/事/时约束的查询组合，并降低写入时的归因与更新错误。
   - 机制/设计：System 1 存带 speaker/time/channel 的逐条原文；System 2 为四层派生结构：PERSON 域 Core/Profile + GROUP 域 Interaction/Insight，每条经 `from_ids` 回链源消息，并用 source/owner 区分「谁提供」与「关于谁」。查询走 Anchor（保留 source/owner/event/time/provenance）→ Separate（按名册展开 PERSON/GROUP 行）→ Resolve（议题/并行事件/版本）→ Compose（两轨按人、关系、更新链组装）再交给冻结 answerer；派生行空则回退该人原文。写入侧用 SpeakerLevenshtein（按 owner 桶一对一匹配）+ speaker-conditioned GRPO 只训本地 Qwen2.5-3B Writer，检索与回答冻结。
   - 证据：GroupMemBench 745 / SocialMemBench 1,031 / EverMemBench 2,400 题。主表最高配置 Acc.：GM 47.9%、SM 69.2%（近 Full context 69.4%）、EM-All 61.9%；相对各基准最强主流框架 +3.3/+12.4/+9.4pp。公开 EverMemBench 榜（GPT-4.1-mini 答 / Gemini-3-Flash 判）62.33%（1,496/2,400），高于 EverOS ~60.08%、RippleMem ~54.75%；弱项在 Multi/Skill/Role。消融：去 S1 或去 S2、或只留 person/group 层均掉点。Writer 对照（305 题、冻结查询/回答）：Writer-R1 68.20% vs SFT 57.38%（+10.82pp），达 LLM Writer 参考 71.48% 的 95.4%。LoCoMo 边界测 ALL(Non-AD) 67.34%，多跳/开放域仍弱。
   - 局限：Limitations——依赖可靠名册、source/owner 与时间识别；别名、成员变动、隐式受众、并行事件仍难；建设/检索成本与跨证据推理、开放域、跨域跨语泛化未解。失败条件：ASK 补充检索在 SocialMem 可降 Acc.（冗余证据）；S1 预算已大时再抬 S2 可能伤分。
   - 对办公 Agent 或 Agent 基础设施的意义：直接对应「群邮件/Teams 线程/跨组决策修订」——原文轨做审计，人/组结构化态做当前共识；查询应按参与者与版本收窄后再拼证据。落地可把 Writer 小型化部署，权限与删除挂在 provenance，并把 Multi/Role 类失败回流为写入规则。

3. **[When Does Execution Provenance Help Agent Memory Retrieval?](https://arxiv.org/abs/2609.25913)**
   - 元信息：2026-09-23（arxiv cs.MA pastweek 列表；v1 submitted 2026-09-22）；预印本（文首标 WSDM 2027）；主题标签：Agent Memory / 执行溯源单元 / 预算内证据完备 / 残差 R-GCN 重排 / ISETrace；分级：S
   - 核心问题：工具轨迹超窗后，记忆检索常按固定 token 窗与固定-\(k\) 打分——碎片相关不等于「金证全集能塞进预算」。小窗减噪却打散证据；扁平块 vs 图方法又常把候选边界与图传播混为一谈。需要把问题改写成预算下的证据完备，并拆开「溯源候选视图」与「图残差」各自贡献。
   - 机制/设计：EPGM。(1) 从工具参数/输出构造 source-aligned provenance units（共享源字符坐标）；(2) 冻结稠密分 \(s_0\) 后，用零初始化残差 R-GCN 在可观测执行边（feeds、ownership、artifact I/O、chunk adjacency 等，正反向共 14 类）上预测 \(\Delta_\theta\)，最终分 \(s_0+\Delta\)；(3) 主指标 Coverage@(B)、Full Support@(B)、Budget-AUC——扫描排序直至 token 预算耗尽，要求金证 span 全集落在预算内。对照：匹配 Dense-FT/Cross-Encoder 的扁平窗 vs 溯源单元；固定候选与种子分后只加图残差；另有 GraphRAG 实体共现、确定性路径扩展等负对照。
   - 证据：ISETrace 上 2,000 查询 / 1,207 条 held-out 轨迹。候选视图：Prov.-Unit Dense-FT vs 扁平 512 Dense-FT，Full Support@2048 +19.07（72.78 vs 53.71），且仍高于四档扁平窗的 per-metric oracle 11.96pp。图残差（种子透传对照）：FS@2048 +4.55（95% CI [2.98, 6.18]）；按查询类型：direct +0.19（区间含 0）、linked +4.00、multi-fact +11.83。去掉 feeds/ownership 或随机重连边时，残差在开发集被拒、退回种子分；实体共现 GraphRAG 相对 BM25 预算指标差 <1.1pp。服务开销：残差平均 +20.06 ms（+3.44%）、+11.27 MiB。下游 315 题盲评：扁平 71.75% → 单元 75.56% → 残差 77.78%；无证据 1.27%、金证 86.35%。
   - 局限：Limitations——查询为 LLM 自源包生成，500 条人工校验非独立盲重标，类型标签人机一致仅 77.8%；扁平 vs 单元非纯切块消融（字段资格不同）；图边非语义因果；≥3 事件层仅 32 题；ISETrace 为合成 OS Agent 离线全轨迹，未声称多 Agent、跨会话、在线记忆或端到端任务成功。失败条件：证据已局部（direct）时图增益不可检；金证跨多事件且预算紧时无溯源边界最易不全。
   - 对办公 Agent 或 Agent 基础设施的意义：把「读表→改 CRM→发邮件」类工具链记忆从段落相似度改成可审计的调用/返回单元，并在预算内验收「证据是否齐全」；图重排应留给跨步骤拼装查询。生产上可先换候选视图再考虑轻量残差，并对溯源字段做脱敏与 ACL。

## 二、GitHub 仓库

1. **[taylorwilsdon/google_workspace_mcp](https://github.com/taylorwilsdon/google_workspace_mcp)**
   - 元信息：2026-09-21～2026-09-22（[v1.28.0](https://github.com/taylorwilsdon/google_workspace_mcp/releases/tag/v1.28.0)；本窗合入 named range、Gmail 诚实性与 Office 解压预算等）；已发布开源（MIT）；主题标签：办公 Agent / Gmail·Calendar·Docs·Sheets·Drive MCP / 工具分层与只读模式 / 远程传输边界 / ZIP bomb 防护；分级：S
   - 核心问题：办公 Agent 若把 Gmail/日历/Docs/Sheets 全量工具塞进上下文，既易越权发信改表，又易在远程 MCP 部署上误用本机 `file_path`，或在抽取 `.docx/.xlsx/.pptx` 时被小压缩包撑爆内存；需要可分层的 Workspace 工具面，并对传输拓扑与解压预算做硬边界。
   - 机制/设计：单 MCP 覆盖约 12 类 Workspace 服务、120+ 工具；`core`/`extended`/`complete` 三档 + `--tools`/`--read-only`/`--disabled-tools` 控面。OAuth 2.1 多用户、stateless 容器、trusted-gateway 身份。本窗增量：Sheets `manage_named_range`（list/create/rename/retarget/delete，A1，属 `complete`）；Gmail 展开 `message/rfc822` 嵌套信、不可解析 `thread_id` 拒绝孤儿草稿、改标签保留可见性；`WORKSPACE_MCP_MAX_OFFICE_XML_BYTES`（默认 25 MiB）对 ZIP 成员按预算 `_read_zip_member`，超限报「过大」而非「损坏」；远程 `streamable-http` 对 `file_path` 做 schema 隐藏 + 运行时诚实报错（[#1036](https://github.com/taylorwilsdon/google_workspace_mcp/pull/1036)）。
   - 证据：README（Services / Security / tool tiers）；[`core/tool_tiers.yaml`](https://github.com/taylorwilsdon/google_workspace_mcp/blob/main/core/tool_tiers.yaml)（`manage_named_range` 在 sheets.complete）；[`core/utils.py`](https://github.com/taylorwilsdon/google_workspace_mcp/blob/main/core/utils.py)（`OfficeXmlTooLargeError`、`_ExpansionBudget`、`extract_office_xml_text`）；[`gsheets/sheets_tools.py`](https://github.com/taylorwilsdon/google_workspace_mcp/blob/main/gsheets/sheets_tools.py) `_manage_named_range_impl`；Release [v1.28.0](https://github.com/taylorwilsdon/google_workspace_mcp/releases/tag/v1.28.0)；PR [#1146](https://github.com/taylorwilsdon/google_workspace_mcp/pull/1146)、[#1150](https://github.com/taylorwilsdon/google_workspace_mcp/pull/1150)、[#1151](https://github.com/taylorwilsdon/google_workspace_mcp/pull/1151)、[#1153](https://github.com/taylorwilsdon/google_workspace_mcp/pull/1153)、[#1036](https://github.com/taylorwilsdon/google_workspace_mcp/pull/1036)。
   - 局限：发信/改表仍依赖调用方 HITL 与 scope 最小化，README 明确 prompt injection 风险；解压帽约束的是展开字节而非进程 RSS（峰值约 14–30×）；remote `file_path` 隐藏依赖客户端刷新 tool schema；Chat 需额外 Workspace Chat app 配置；能力面宽，生产默认应 `--tool-tier core` + 禁写。
   - 对办公 Agent 或 Agent 基础设施的意义：给出「跨 Gmail/日历/Docs/Sheets」的可部署 MCP 配方——先用分层与只读收面，再把远程传输边界与 Office 解压预算写进默认配置；与本地写文件套件（如 GenOffice）互补：云侧连真实 Workspace，本地侧出可审阅原生文件。

2. **[decionis/agent-safe-pipeline](https://github.com/decionis/agent-safe-pipeline)**
   - 元信息：2026-09-21～2026-09-22（[v0.3.3](https://github.com/decionis/agent-safe-pipeline/releases/tag/v0.3.3)→[v0.3.4](https://github.com/decionis/agent-safe-pipeline/releases/tag/v0.3.4)→[v0.3.5](https://github.com/decionis/agent-safe-pipeline/releases/tag/v0.3.5)；本窗主增量：**MCP 一等执行面**、边界身份入意图哈希、workload 来源信任级、六类攻击 conformance）；已发布开源（Apache-2.0 边界 + 托管权威）；主题标签：执行权威网关 / MCP 工具闸 / 人机审批 / 审计 dossier / 边界与 provenance；分级：S；重复出现，值得关注
   - 核心问题：MCP 只回答「怎么调工具」，不回答「这一次、这些参数、这个目标」是否被授权；合法身份下的 Agent 仍可对 CRM/发信/支付做未授权副作用。需要把 MCP 调用绑成可哈希意图，并在授权后禁止改参、跨边界复用 grant、冒充批准镜像。
   - 机制/设计：AgentSafe 捕获 `agent-safe.intent/1` → Decionis `ALLOW|BLOCK|ESCALATE` → claim 单次 grant 再转发；失败默认 fail-closed。v0.3.5：`packages/agentsafe/src/adapters/mcp` 的 `McpGuard`/`bindMcpInvocation`——无 MCP SDK 依赖，运维声明 binding（action、target 模板、arguments schema）；未绑定工具 / 无名参数 / 不可解析 target 在问权威前拒绝；参数进 canonical hash，派发前重算 digest，变更即 `INTENT_BINDING_MISMATCH`。ADR 0006：`enforcement_boundary` 写入 hashed `context`，跨边界呈交 grant → `BOUNDARY_MISMATCH`。ADR 0007：`WorkloadSignal` 强制带 `provenance.trust_level`，本包上限 `supplied`，镜像替换 → `WORKLOAD_MISMATCH`。`agentsafe test` 实跑六攻击（改金额/受益人、重放 grant、跨 workload、跨边界、合法主体提议被拒动作）。
   - 证据：README 状态表与 Compromised Principal；[`McpGuard.ts`](https://github.com/decionis/agent-safe-pipeline/blob/master/packages/agentsafe/src/adapters/mcp/McpGuard.ts)、[`McpIntentBinder.ts`](https://github.com/decionis/agent-safe-pipeline/blob/master/packages/agentsafe/src/adapters/mcp/McpIntentBinder.ts)；ADR [0006](https://github.com/decionis/agent-safe-pipeline/blob/master/docs/architecture/decisions/0006-enforcement-boundary-identity.md)、[0007](https://github.com/decionis/agent-safe-pipeline/blob/master/docs/architecture/decisions/0007-workload-provenance-signals.md)；`conformance/frameworks/mcp.json`；PR [#251](https://github.com/decionis/agent-safe-pipeline/pull/251)/[#252](https://github.com/decionis/agent-safe-pipeline/pull/252)/[#253](https://github.com/decionis/agent-safe-pipeline/pull/253)/[#255](https://github.com/decionis/agent-safe-pipeline/pull/255)；Release [v0.3.5](https://github.com/decionis/agent-safe-pipeline/releases/tag/v0.3.5)。
   - 局限：生产策略与 Presence 不在本仓；MCP Guard 是库适配器，须由 MCP 服务端显式接入，非透明劫持所有 MCP；workload `verified` 尚无平台 attestation provider；意图默认约五分钟 TTL；透明 Govern 仍依赖运营方 CA。
   - 对办公 Agent 或 Agent 基础设施的意义：把「发邮件/改 CRM/调内部 API」的 MCP 工具调用提升为可测的执行权威层——与上条 Workspace MCP 叠加时，模型侧工具发现与网关侧 ALLOW/ESCALATE 应分层；落地先 `agentsafe test`，再对高副作用工具做 binding + 人机 ESCALATE。

3. **[openai/openai-agents-js](https://github.com/openai/openai-agents-js)**
   - 元信息：2026-09-21～2026-09-22（本窗合入 MCP resume 接收方绑定、嵌套审批态保全、静态 MCP 过滤与 host shell 强制交互审批等；基线仍为 [v0.18.0](https://github.com/openai/openai-agents-js/releases/tag/v0.18.0)）；已发布开源；主题标签：Agent harness / Human-in-the-loop / MCP 审批续跑 / 工具过滤 / 宿主 shell 人审；分级：S
   - 核心问题：长办公任务常在嵌套 `agent.asTool()`、MCP 工具审批与 RunState 序列化续跑间切换；若 resume 时丢永久拒绝、把挂起 MCP 调到错误 server、或在无 run context 时绕过 allow/block 列表，人审闸会静默失效。
   - 机制/设计：官方 HITL：`needsApproval` → `interruptions` → 在外层 `RunState` 批准/拒绝后 resume；嵌套 agent 工具的中断仍冒泡到根 run。本窗修复：(1) [#1963](https://github.com/openai/openai-agents-js/pull/1963) resume 的 MCP 调用绑定原 server 名、原始工具名与 discovery 位次，身份不符则不执行；(2) [#1973](https://github.com/openai/openai-agents-js/pull/1973) 嵌套 restore 时保留当前永久审批（含 alwaysReject 与 per-call 例外），避免旧序列化态覆盖新决策；(3) [#1974](https://github.com/openai/openai-agents-js/pull/1974) 无完整 run context 时仍应用静态 MCP allow/block；(4) [#1966](https://github.com/openai/openai-agents-js/pull/1966) host shell 示例改为每批命令交互审批；(5) [#1961](https://github.com/openai/openai-agents-js/pull/1961) `maxListPages` 限制 MCP 工具列表分页。
   - 证据：官方文档 [Human-in-the-loop](https://openai.github.io/openai-agents-js/guides/human-in-the-loop/)（嵌套审批冒泡、`needsApproval`/resume）；README「Human in the loop / Tools / MCP」；PR [#1963](https://github.com/openai/openai-agents-js/pull/1963)、[#1973](https://github.com/openai/openai-agents-js/pull/1973)、[#1974](https://github.com/openai/openai-agents-js/pull/1974)、[#1966](https://github.com/openai/openai-agents-js/pull/1966)、[#1961](https://github.com/openai/openai-agents-js/pull/1961)（均于本窗合并）。
   - 局限：尚未切含上述修复的新 release tag，生产需 pin commit；recipient 绑定不校验同名下传输/凭证变更；无内置邮件/日历/Office 连接器语义；host shell 示例强调仍可触达宿主文件与网络，隔离须另用容器 shell。
   - 对办公 Agent 或 Agent 基础设施的意义：补上「审批态权威」与「MCP 续跑不得改路由」两条 harness 红线——适合挂 Workspace MCP / 发信改表类工具；与 AgentSafe 叠加时，SDK 侧 HITL 管人是否同意该工具调用，网关侧再对副作用字节做执行权威，二者不可互相替代。

## 三、博客 / 工程文档

1. **[Agentic workflows in Elasticsearch: pause an AI agent for human approval, resume 72 hours later](https://www.elastic.co/search-labs/blog/ai-agent-orchestration-human-approval-workflow)**
   - 元信息：2026-09-21；已发布（Elasticsearch Labs 工程教程；配套仓库 `elasticsearch-labs`）；主题标签：人机审批门闸 / 持久化工作流状态 / 可查询审计 / 诊断 Agent 与执行 Agent 分离 / 可靠性；分级：S
   - 核心问题：会话绑定 Agent 一旦要等人审批，会话超时就会丢上下文；运维级修复（改流水线、有界回放）又不能无人放行。需要把「可暂停数日的审批」做成工作流状态，而不是挂着占用算力的 Agent 会话。
   - 机制/设计：Elasticsearch Workflows 将长程状态落在 ES，Agent Builder 会话只服务单步。(1) Alert 监视 `::failures` → `failure-analyst`（只读）产出结构化 remediation JSON → 写入 `remediation-runs`（`awaiting_fix_approval`）。(2) Gate 1=`waitForInput`（approve/reject + notes，超时 72h）；批准后 `remediation-executor` 按 `execution_id`+状态取已批计划再建 pipeline/reindex；拒绝则反馈回 analyst 出修订案再经 Gate 1b。(3) Gate 2=`waitForApproval` 对执行报告做 resolve/escalate。工作流总超时 7d；作者建议生产用确定性校验自动结案，仅部分失败才进 Gate 2，以免审核疲劳。
   - 证据：端到端实测——executor 创建 `logs-demo-app-price-remediation`，5 条失败文档全部匹配并 reindex，version conflict/failure=0；主索引由 3→8 篇，failure store 原件保留（reindex 复制不删除）。审计索引串联 diagnosis、修订反馈、executor 报告与终态（`resolved`/`escalated`/`fix_rejected`）。配套脚本与 YAML 可复现。
   - 局限：教程场景是数据摄取修复，非邮件/日历连接器；Gate 2 全量人审会放大队列；单 gate 72h、整链 7d；executor 指示「勿再确认」依赖前置门闸正确；失败批 `size:50` 需分页扩展。
   - 对办公 Agent 或 Agent 基础设施的意义：把「发信/改表/写共享库」类副作用改成可挂起审批的状态机——诊断只写计划、执行只读已批 dossier、全程可检索审计；落地可对照：审批超时与 fail-closed、修订回路、以及「成功也可再验」与「确定性自动结案」的分流，避免把人钉在每一步上。

2. **[Introducing DigitalOcean Managed Agents: One AI-native stack to power your intelligence](https://www.digitalocean.com/blog/managed-agents-public-preview)**（配套：[How to Monitor Harness Runtime Sessions](https://docs.digitalocean.com/products/managed-agents/agent-harness-runtime/how-to/monitor-sessions/)）
   - 元信息：2026-09-22（博客 Updated；监控文档 Last verified 2026-09-21）；已发布（DigitalOcean 官方产品博客 + 工程文档；Managed Agents public preview）；主题标签：Agent 运行时 pause/resume / Action Gateway 权限与人机审批 / 跨系统工具集成 / 邮件·工单分流案例 / 可观测审计；分级：A
   - 核心问题：办公/业务 Agent 要跨 Slack、邮件、工单与沙箱跑脚本，传统 VM 难在「等模型/等人审时停计费、状态仍可恢复」，且凭证与工具权限若进沙箱就失去治理边界。
   - 机制/设计：两层垂直集成。(1) Harness Runtime：Firecracker microVM 隔离执行；pause/resume/fork 保留文件与会话；空闲可 auto-pause；按 active CPU 计费。(2) Action Gateway：单一托管 MCP，16,000+ 工具；凭证运行时代持、不进模型/沙箱；集中权限，敏感动作可强制人审；意图→工具匹配内部测称 99.3%。Insights 暴露审批次数、等待时长、token 与沙箱资源；文档明确「觉得慢先看审批队列」。案例：Qencode 从 Slack/邮件/Intercom 分流到 Jira，低置信度才人审。
   - 证据：公开基准（2026-09-21，Codex CLI×gpt-5.5，RIC1）：create→就绪 886 ms、首响 3.3 s；resume 就绪 305 ms，恢复后响 2.43 s≈常驻 2.47 s。计费例：2 vCPU 均 25% + 峰值 4 GB·1h ≈ $0.060 vs 满配 $0.126。Qencode 称 triage/状态汇报每周约省 4–8 小时、响应从数小时到近即时（厂商转述）。
   - 局限：public preview；exec 路径较 Sprites 慢约 110 ms（边缘鉴权/审计开销）；Cursor/LangGraph 不报 token；审批文案在日志中截断；意图匹配 99.3% 为内部测试；Qencode 效果非独立对照实验；办公面仍偏连接器+沙箱，无原生 Docs/Sheets 修订轨语义。
   - 对办公 Agent 或 Agent 基础设施的意义：给出「跨邮件/聊天/CRM 的办公分流 Agent」基础设施配方——工具权限与人审在网关、执行在可暂停沙箱、会话日志可审计；生产上应把审批等待纳入 SLO，并对发信/建单/改库默认 ask，再按队列数据放宽例行动作。

3. **[Foundry hosted agent isolation with Microsoft Agent Framework](https://devblogs.microsoft.com/agent-framework/foundry-hosted-agent-isolation-with-microsoft-agent-framework/)**
   - 元信息：2026-09-22；已发布（Microsoft Agent Framework 工程博客；Foundry hosted agents GA，AgentServer/MAF Foundry 托管包仍为 pre-release）；主题标签：用户隔离 / 托管会话隔离 / 委托身份 / 文件持久化沙箱 / 系统集成中台；分级：A
   - 核心问题：托管 Agent 分析上传文件或跨用户跑任务时，若把「谁的数据可用」与「代码/文件落在哪台沙箱」绑死，中台难做会话池、预上传与多租户；需要两套可独立配置的隔离旋钮。
   - 机制/设计：双控制面。(1) User isolation：直连用调用方 Entra；可信中台可每请求附带稳定委托身份（.NET 存 `AgentSession`，Python 每调用 `x-ms-user-identity`）。(2) Foundry hosted session isolation：`agent_session_id` 指向 VM 隔离沙箱与持久 `$HOME`/上传文件——**会话≠对话**（对话是消息/工具史，hosted session 是算力与文件）。可首请求自动建，或经 `CreateSessionAsync`/`create_session` 预建以支持先上传、生命周期与有界池。池化设计：中台映射用户↔有限 session ID 并带委托身份；Foundry 按用户隔离响应链，文件系统可共享，应用侧用 `agent_session_id`+用户身份做分区键。
   - 证据：文内给出 .NET/Python 创建与复用 hosted session、读取 `FoundryHostedAgentSessionId` / `FoundryHostedAgentUserIdentity` 的完整调用面；明确托管 Agent 已 GA，SDK 包仍预发布。机制描述与 API 对齐，无单独 benchmark 表。
   - 局限：SDK 预发布，API 可能变；委托身份对框架不透明，映射与安全模型由中台自负；池化共享文件系统时需应用层再分区，否则有交叉读写风险；文未给邮件/日历连接器 ACL 细节，焦点在托管沙箱隔离。
   - 对办公 Agent 或 Agent 基础设施的意义：凡「读公文包/上传附件再改稿」的办公 Agent，应把用户 ACL 与沙箱生命周期拆开配置——对话层跟人走，文件沙箱可池化复用；中台集成时默认带委托身份，并用 session+user 双键隔离缓存与上传物，避免多用户串文件。

