# 每日资讯 · 20260917

## 一、论文（arxiv）

1. **[Interactive Memory Learning for Long-Term Conversations](https://arxiv.org/abs/2609.17088)**
   - 元信息：2026-09-15（arxiv submitted）；预印本；主题标签：Agent Memory / 多 Agent 协同 / 延迟奖励对齐 / 可学习记忆策略；分级：S
   - 核心问题：长对话助手若按静态启发式被动归档记忆，无法随用户需求演化评估「该存什么、何时取回」；需要把记忆管理做成可与交互反馈共演化的策略，而不是固定管线。
   - 机制/设计：将交互记忆学习建模为 POMDP；两阶段——先用 Retrospective Session Synthesis（逆向补前序故事线 + 正向标注 Planner/Trigger 监督标签，含 hard/soft negatives）做冷启动 warm-up；再上线 ICML：Planner 对当前 turn 做 save/discard，Trigger 从记忆库选索引（0=不取）；共享 Actor-Critic + PPO 联合优化。关键是 Cross-Session Truth Reward：把未来 Trigger 命中后的质量分 \(r^{qual}\) 回传到当初写入的 Planner，与 proxy reward 合成 \(r^{truth}=r^{proxy}+\lambda r^{qual}\mathbb{I}(\text{triggered})\)，用 Pending Reward Buffer 解延迟信用分配。
   - 证据：MSC / CC / GC；训练默认 Qwen3-8B，骨干含 GPT-4o、Gemini2.5；对照 Long Context、Mem0、A-Mem、MemoryOS、MemoryBank、LD-Agent、THEANINE。Gemini2.5+ICML-8B：CC/MSC/GC Mauve 80.33 / 66.01 / 59.81，明显高于同骨干强基线（如 THEANINE CC Mauve 75.42、Long Context 72.04）。消融（Table 2）：去掉 Truth Reward 使 CC Mauve 80.33→76.19；去 Evolution / Planner / Trigger / Synthetic Data 均下降。人工偏好：相对多类基线 generation/memory 胜率约 66–80%。合成 warm-up 约 0.25K–0.5K episode 最优；token/latency 图显示相对 MemoryOS/THEANINE 推理与存储更稳、建库更轻。
   - 局限：Limitations 明确评测偏向开放域陪伴与个性化，不覆盖数学/代码/严格事实检索；奖励依赖骨干 LLM 打分；办公单据、工具成功与审批反馈等硬信号未进入奖励定义。
   - 对办公 Agent 或 Agent 基础设施的意义：给「写什么进长期记忆、何时注入上下文」提供可学的双 Agent 分工与延迟信用回路——可对照邮件/会议助手：把「是否被后续任务真正用到」回写到写入策略；生产上应用企业验收/人工评分替换 LLM proxy，并与可审计事实库分层。

2. **[Cognitive Extensions for Dual-Process Language Agents: Memory and Self-Reflection in Interactive Environments](https://arxiv.org/abs/2609.19128)**
   - 元信息：2026-09-16（arxiv submitted）；预印本；主题标签：Agent Memory / 执行时上下文控制 / 双过程 Agent / 有界反思；分级：A
   - 核心问题：交互环境中合理高层计划常在执行时崩坏（无效动作、陈旧重复、无进展循环）；单靠加长提示不够。需在双过程（快提议/慢规划）之上，把情景记忆与执行时监护做成可消融的模块。
   - 机制/设计：在 SwiftSage 式基板上挂两个 feature-flag 扩展。(1) AMM：步进后按显著性门（成功/加分/近失/无效反馈/应回避失败）写入半结构化情景记录；检索触发 T1（Swift 失败恢复）、T4（Sage 规划），提示块有界、去重截断，失败则回退基线提示。(2) SRM：执行前 Gate–1 校验/浅修复/丢弃非法动作；执行后检测停滞，仅在预算与冷却允许时调用 Critic，输出写入与 Sage 相同的 FIFO buffer，仍经 Gate–1。全系统保持「当前合法动作与约束 > 停滞诊断 > 可选记忆 > Gate–1」优先级。
   - 证据：ScienceWorld 任务 0–29，每配置最多约 271 episode；本地 Qwen2.5-7B-Instruct-1M 作 Sage/Critic。Table 1：Baseline / +AMM / +SRM / Full 的 Final 51.67 / 53.83 / 64.33 / 64.62，Success 23.99% / 26.94% / 41.33% / 43.17%，Steps@Succ 24.48 / 24.03 / 19.76 / 19.33。相对 baseline，Full +25.1%、SRM +24.5%、AMM 仅 +4.1%。机制日志：Gate–1 每集丢弃约 17–20 次；Critic 有效调用约 1.3 次；Full 的 System-2 调用从 24.6→14.1。敏感：Critic 预算 3→6 使分数 64.33→52.95；关 T1 注入使 Full 64.62→63.33（长任务更伤）。
   - 局限：正文 Limitations——AMM 仍偏情景、缺语义巩固与技能抽象；Gate–1/停滞阈值等多手调；评测限于 ScienceWorld 与特定 SwiftSage 复现设定，不直接外推办公 GUI/多模态；AMM 主结果用 populated memory，弱记忆设定另作敏感条件。
   - 对办公 Agent 或 Agent 基础设施的意义：把「记忆」与「执行闸门」解耦——先挡住非法/陈旧工具调用，再谈跨任务经验注入；办公侧可映射为：工具 schema 门禁 + 停滞检测（重复写同字段/无状态变化）+ 有界重规划，避免无限制反思拖垮长流程。

3. **[ERPBench: A State-Grounded Evaluation Paradigm for Computer-Use Agents in Enterprise Software](https://arxiv.org/abs/2609.17885)**
   - 元信息：2026-09-15（arxiv submitted）；预印本；主题标签：办公/企业 Agent / ERP GUI / 数据库态评分 / 人机审批 harness / 失败 taxonomy；分级：S
   - 核心问题：通用桌面/网页 GUI 基准上表现好的 computer-use agent，在 ERP 上可能「界面看似成功」却把错误写入持久业务库；需要像素观测、真实可复现 ERP、以数据库真值为准的评测，以及可部署的风险门控 harness。
   - 机制/设计：ERPNext Docker + Xvfb/noVNC，agent 仅见 1280×720 截图、输出坐标动作，无 DOM/A11y。任务 YAML 分 T1（20 单字段/简单创建）、T2（多字段关联）、T3（2–4 文档链式；含 submit 与 blank-start）。Harness：Flask FSM + 风险分类（safe/commit/irreversible）；部署模式人审，评测用 200ms Auto Approver。评分：DB Grader（Frappe API，全目标字段正确才成功）、Stage Grader（Navigation→Interaction→Commit→Database；T3 用 chain-depth）、Log Grader。失败 taxonomy：Recovery / Planning / Grounding / Save-step / Perception（静默错写）。
   - 证据：六模型各 5 次跑（T1/T2/T3 每模型 100/20/30 runs）+ 三人人工基线。Claude Sonnet 4.6：T1/T2/T3 成功率 94%/100%/100%，但 T1→T3 输入 token 约 231K→2.0M。开源最强 Holo3 / Qwen3-VL-32B：T1 仅 34%/32%，T2/T3 跌至 0–3%；UI-TARS-7B OSWorld-Verified 42.5 分，T1 成功率仅 9%——导航达 95%、Commit 68%，Database 正确仅 9%；T2 上 Commit 85% 而 Database 仅 3%。人工专家约 95–100%。失败上开源多在导航之后：如 Qwen3-VL Grounding 59%；UI-TARS Perception 59% + Grounding 27%。
   - 局限：无独立 Limitations 节；范围目前是 ERPNext 上 30 类任务与 screenshot-only 通道；评测用全自动审批，不等于部署态人审下的吞吐；Claude 高成功率伴随极高 token，ROI 未系统核算；结论亦承认需扩展更多企业工作流。
   - 对办公 Agent 或 Agent 基础设施的意义：把办公 Agent 验收从「点对了按钮」改成「库里的业务态对不对」；并给出可抄的生产配方——副作用动作按风险门控、静默错写单独入 taxonomy。与 GUI 记忆回放类工作互补：回放再快，也必须以 DB/业务态为最终判据。

## 二、GitHub 仓库

1. **[iOfficeAI/OfficeCLI](https://github.com/iOfficeAI/OfficeCLI)**
   - 元信息：2026-09-16；已发布（[v1.0.151](https://github.com/iOfficeAI/OfficeCLI/releases/tag/v1.0.151)）；主题标签：办公 Agent / Word·Excel·PPT / 修订轨与讲者备注 / dump→batch 编号重映射 / 原子 batch；分级：S；重复出现，值得关注
   - 核心问题：办公 Agent 改 `.docx`/`.pptx` 时，找替换锚点落在修订轨/`w:hyperlink` 内、讲者备注按错误 placeholder 索引、跨文档 dump 编号定义，会静默写错位、读空 notes 或污染目标列表；需要把「可脚本化编辑」做成对真实 OOXML 结构稳健、失败可回滚的工具面。
   - 机制/设计：三层能力——L1 `view`（text/outline/issues/html/screenshot）、L2 路径 DOM（`get`/`query`/`set`/`add`/`move`…）、L3 `raw`/`raw-set`；`open`/`close` resident + 默认原子 `batch`（失败整批回滚）。Agent 侧靠 `SKILL.md`（L1→L2→L3、help-first）与 `officecli mcp`。本窗 v1.0.151：`AddInlineAtSplitPoint` 把 find 锚点爬到段落级祖先，落在 `w:ins`/`w:del`/`w:hyperlink` 内则拆容器并换新 revision id；讲者备注统一 `FindNotesBodyShape`（按 `type=body`，不再用 `idx==1`）；`dump /numbering` 用 `[last()]` 寻址并经 `BatchCompat.RemapNumberingIds` 重映射，避免覆写目标已有列表。
   - 证据：README「Three-Layer Architecture / Resident Mode & Batch / MCP Server」；[`SKILL.md`](https://raw.githubusercontent.com/iOfficeAI/OfficeCLI/main/SKILL.md) Strategy；[v1.0.151](https://github.com/iOfficeAI/OfficeCLI/releases/tag/v1.0.151)（2026-09-16）及提交 [243ba96](https://github.com/iOfficeAI/OfficeCLI/commit/243ba96)（`WordHandler.Helpers.FindReplace.cs`，Closes #402）、[1cc8639](https://github.com/iOfficeAI/OfficeCLI/commit/1cc8639)（`PowerPointHandler.Notes.cs`，Closes #403）、[d0aed3e](https://github.com/iOfficeAI/OfficeCLI/commit/d0aed3e)（numbering dump/replay，#404）；同窗前序 [ecbcef7](https://github.com/iOfficeAI/OfficeCLI/commit/ecbcef7) 仍约束「拒绝的 mutation 不盖 `OfficeCLI.Version`/`LastModified`」。
   - 局限：仍是本地 OOXML runtime，不覆盖 Gmail/日历/Teams；高保真 `screenshot` 依赖无头浏览器；复杂版式仍可能落到 L3；README「world's first/best」属营销口径，需以兼容性实测为准。
   - 对办公 Agent 或 Agent 基础设施的意义：把「审阅稿里找替换、改 PPT 备注、从模板 dump 再批量克隆」从脆弱启发式变成可验证的文档 runtime；适合作为办公 Agent 的本地文档执行层——能读修订轨与 notes、跨文档不串列表、批量失败可回滚。

2. **[Shalimov04/mcp-airlock](https://github.com/Shalimov04/mcp-airlock)**
   - 元信息：2026-09-16（[v0.2.0](https://github.com/Shalimov04/mcp-airlock/releases/tag/v0.2.0)；仓建于 2026-09-13，同窗先发 [v0.1.0](https://github.com/Shalimov04/mcp-airlock/releases/tag/v0.1.0)）；已发布（PyPI/`ghcr.io/shalimov04/mcp-airlock`）；主题标签：Agent 基础设施 / MCP 治理代理 / 权限分层 / 人机确认 / 审计与 blast radius；分级：S
   - 核心问题：Agent 直连可写 MCP（发邮件、改库、删服务）时，协议本身不提供「谁可调什么、默认干跑、危险操作必经人批、事后可审计」；需要一个放在 Agent 与 upstream 之间的治理面，且不能靠 Agent 自觉。
   - 机制/设计：无会话 MCP（2026-07-28）上的 Starlette 代理：身份只认 JWT/`X-Airlock-Principal`（永不取自 body）；未列入策略的工具一律拒绝。按环境分 L0 直通 / L1 强制 `dry_run` / L2 先干跑再 `input_required`+HMAC `requestState`（人批后单次兑现，重放拒绝）/ L3 自动。另有 per-call/per-principal blast radius、输出截断、输出侧注入标记（只标不改）、intent+outcome 双行审计（密钥类字段 redact）与 OTel span。人批链接用另一派生密钥签名，Agent 持有的 `requestState` 无法自批；可选 Slack/Telegram webhook。v0.2.0 补 PostgreSQL 示例策略，并有 k8s/Grafana/Postgres 隔离 e2e 栈。
   - 证据：README「How a call goes through / Confirmations in detail / Audit」；实现 [`policy.py`](https://github.com/Shalimov04/mcp-airlock/blob/main/src/mcp_airlock/policy.py)（`Engine.evaluate`/`reserve`）、[`app.py`](https://github.com/Shalimov04/mcp-airlock/blob/main/src/mcp_airlock/app.py)（`TOKEN_PREFIX`/`APPROVE_PREFIX`、`/approve` GET 空操作防预览误批）；[`docs/clients.md`](https://github.com/Shalimov04/mcp-airlock/blob/main/docs/clients.md)；[`examples/policies/postgres.yaml`](https://github.com/Shalimov04/mcp-airlock/blob/main/examples/policies/postgres.yaml)（2026-09-16 对照 bettyguo/mcp-postgres）；e2e/`kubernetes`/`grafana`/`postgres`；[v0.2.0](https://github.com/Shalimov04/mcp-airlock/releases/tag/v0.2.0)。
   - 局限：代理只检查 schema 是否声明 `dry_run`，无法证明 upstream 真遵守；多数写工具无 `dry_run` 时 L1 被拒、L2 无人预览；L2 与 upstream 自有 `input_required` 不兼容；官方 Python SDK 对 `input_required` 轮询约 2s 会超时，人批需客户端重试；approve URL 是能力链接，需挂 SSO/VPN；无内置办公语义连接器。
   - 对办公 Agent 或 Agent 基础设施的意义：给「邮件发送 / 表写入 / 库变更」类 MCP 补上可部署的权限与审批闸——策略按环境收紧、确认单次有效、审计可查；办公落地可把 Gmail/Sheets/日历 MCP 挂在其后，把不可逆动作标 L2，并把 approve 页纳入组织身份，而不是把 HITL 写进 prompt。

3. **[temporal-community/temporal-agent-harness](https://github.com/temporal-community/temporal-agent-harness)**
   - 元信息：2026-09-15（[0.4.0](https://github.com/temporal-community/temporal-agent-harness/releases/tag/0.4.0) 预发布；同窗延续 [#128](https://github.com/temporal-community/temporal-agent-harness/pull/128) MCP 治理与 [#135](https://github.com/temporal-community/temporal-agent-harness/pull/135)）；已发布开源（Experimental）；主题标签：Agent harness / 可观测工作状态 / 人机审批 / MCP 工具治理 / 持久暂停续跑；分级：A；重复出现，值得关注
   - 核心问题：把 Agent 建成 Temporal workflow 后，客户端要精确跟踪 plan/todo/scratchpad 且不漏变更；同时 OpenAI Agents SDK 对 MCP 曾直调 `call_tool`，会旁路 harness 的审批与 `tool_start`/`tool_end` 观测。
   - 机制/设计：0.4.0 新增 Observable agent state——`HarnessState` 子类 + `runner.state("plan", PlanState())` 一次 opt-in；`with ref.mutate() as d:` 提交后向既有 `turn_events` 发 RFC 6902 patch（注册时先发 snapshot），草稿保持 `isinstance`/mypy，未触达子树按 identity 共享。同窗 [#128] 的 `as_harness_mcp_server(server, runner, inherently_safe=...)` 在真正调用前经 `_apply_approval_policy`：拒绝则 `is_error` 且不触达下游；通过后发生命周期事件并用 `tool_meta_resolver` 对齐模型侧 call id。策略层仍是 safe-by-default；gated 调用在 workflow 内持久暂停直至人批。
   - 证据：[0.4.0 release notes](https://github.com/temporal-community/temporal-agent-harness/releases/tag/0.4.0)；设计文档 [`docs/design/observable-agent-state.md`](https://github.com/temporal-community/temporal-agent-harness/blob/main/docs/design/observable-agent-state.md)；实现 `temporal_agent_harness/harness/state/` 与 PR [#130](https://github.com/temporal-community/temporal-agent-harness/pull/130)；`as_harness_mcp_server` 于 `openai_agents_harness.py`（[#128](https://github.com/temporal-community/temporal-agent-harness/pull/128)，2026-09-14 合并）；单测 `tests/harness/test_observable_state.py`、`tests/ai_sdks/openai_agents/test_harness_mcp_server.py`；示例 `examples/monty/trip_board.py`。
   - 局限：官方标注 Experimental，API 会变；`AgentStatus` 仍靠轮询；子 Agent 状态进 pane 但未上 flow canvas；无 op coalescing；`inherently_safe` 目前是整 MCP server 粒度；主要绑定 Temporal + 少数 AI SDK，办公垂直连接器需自接。
   - 对办公 Agent 或 Agent 基础设施的意义：给「跨应用办公助手」同时补上工作计划/审批现场可按 patch 审计回放，以及邮件/日历类 MCP 副作用工具必须与本地 function tool 走同一闸门与事件流——否则 HITL/审计形同虚设。

## 三、博客 / 工程文档

1. **[Claude Cowork and chat are now one Claude](https://claude.com/blog/cowork-is-now-claude)**（底层：[Help Center · One Claude](https://support.claude.com/en/articles/16761823-claude-cowork-and-chat-are-one-claude)、[Use Claude Cowork safely](https://support.claude.com/en/articles/13364135-use-claude-cowork-safely)、[Team and Enterprise](https://support.claude.com/en/articles/13455879-use-claude-cowork-on-team-and-enterprise-plans)、[Google Workspace connectors](https://support.claude.com/en/articles/10166901-use-google-workspace-connectors)）
   - 元信息：2026-09-16；已发布（Claude 官方博客；Help Center 同日标注 Updated today）；主题标签：办公 Agent / 文档与幻灯片 / 跨应用连接器 / 人机审批 / 权限与审计；分级：S
   - 核心问题：用户被迫在 Chat / Cowork / Design 之间选入口，任务上下文无法跨模式携带；需要把「问答」与「长任务办公产出」（报告、表格、幻灯片、跨 Gmail/日历/Drive）并进同一会话，同时保留默认可审批与企业侧治理。
   - 机制/设计：产品层合并为 One Claude——任意对话可自动选用原 Cowork/Design 能力（skills、connectors、本地文件夹、内置浏览器/Chrome、定时任务、云端续跑）。新上线 beta：Claude Docs（可与团队共编的 living documents）、Claude Slides（可直接演示或导出 PPT/PDF）、Claude Design 进对话。权限面：会话级 Manual（默认，逐步审批）/ Auto（不停步但有 action screening）；永久删文件任何模式都要显式 Allow。连接器侧 Gmail 发送/回复/转发与 Drive share/move/trash 默认每次审批，Team/Enterprise 由 Owner 决定是否允许「Always allow」写工具。企业层另有：组织级开关、云端会话能力、禁 Auto 模式、OTel 流式导出 tool call/文件访问/审批决策、Compliance API 捕获远程会话；写工具与读工具分风险对待，强调 prompt injection 需同时具备「读出信任边界外内容」与「可写副作用」。
   - 证据：公告给出周报→同会话产出 doc+五页 slides、手机跟进度、默认可先问再动、Enterprise 至少提前 30 天通知的产品契约；Help Center 列明可并行多任务、云端在关本后继续、产出含带公式 spreadsheet、日程任务可云端跑、Computer use 按应用授权；安全文明确分类 read vs write tools，并规定定时任务应避开发信/支付等难逆操作；Workspace 连接器写明权限镜像（只能触达用户已有 Google 权限）与引用回链。
   - 局限：Docs/Slides/Design 仍为 beta；Team/Enterprise 暂保持 Chat/Cowork 分离，One Claude 尚未全量进企业；Incognito 退回旧体验且不能造文件/跑代码；Compliance API 未覆盖全部本地会话删除；Computer use「无文件操作那层沙箱」、浏览器/MCP 是注入主向量；跨 Excel↔PowerPoint 可能在未明示时传上下文；无公开成功率/误拦率评测。
   - 对办公 Agent 或 Agent 基础设施的意义：给出「文档/表格/幻灯片 + 邮件日历 Drive」统一工作面的产品配方，并把人机审批拆成会话姿态（Manual/Auto）与连接器写闸门（默认逐次 / 组织禁 Always allow）两层；办公落地应把高副作用工具默认闸住，并把审批事件送进 SIEM，而不是只依赖模型自觉。

2. **[Build zero-trust AI agents that judge intent, not just syntax](https://developers.googleblog.com/build-zero-trust-ai-agents-that-judge-intent-not-just-syntax/)**（配套开源 demo：[zero-trust-agents-2](https://github.com/GoogleCloudPlatform/generative-ai/tree/main/agents/adk/zero-trust-agents-2)）
   - 元信息：2026-09-15；已发布（Google Developers Blog；Gemini Enterprise Agent Platform 运行时治理 Part 2）；主题标签：Agent Gateway / 语义策略闸门 / 会话级异常审计 / 闭环策略补丁 / 人机路由；分级：S；重复出现，值得关注
   - 核心问题：签名写库、沙箱、正则网关等建时确定性控件挡不住「语法合法、意图违规」的工具调用，也看不见跨多轮拆单掏空；治理应上移到平台运行时，由安全管理员而非 Agent 开发者拥有策略。
   - 机制/设计：在 Agent Gateway 叠三层——Model Armor（入站屏注入/越狱/恶意 URL，出站 SDP 脱敏）；Semantic Governance Policies（自然语言 YAML 约束，在模型提出 `issue_refund` 等工具调用时对照用户意图与业务规则给 ALLOW/DENY，适用于本地函数 / API / MCP）；Agent Anomaly Detection（跨会话看工具调用速率、同实体反复写、累计金额，经 Security Command Center 出 `AGENT_SESSION_ANOMALY`）。闭环可不改 Agent 代码：管理员或 API 新增自然语言约束，下一跳即生效。示例仍是客服退款：`verify_order` → 沙箱内 `calculate_restocking_fee` → Cloud KMS 签名 `issue_refund`。
   - 证据：文中四类攻击路径与拦截点；语义策略对「Workplace User License」$120 数字商品退款的 DENY 日志（rationale、token_usage）；多轮各 $20 累计超过订单 $149 的异常 finding 形状；`remediate()` 将 SCC finding 写成「同 order_id 本会话已批过则拒绝」策略的代码；本地可用 `./demo/run_part2_demo.sh` 与 `test_runtime_governance.py` 复现。
   - 局限：主叙事是客服退款演示，非 Docs/邮件/日历产品表面；异常检测字段标明 illustrative；语义策略依赖 LLM 评判，误拦/漏拦与延迟成本未给生产 A/B；闭环仍需管理员审 trace 写约束，不是自动审批 UI。
   - 对办公 Agent 或 Agent 基础设施的意义：把「发信、改表、退款、开票」一类副作用工具的门禁从应用内正则升级为可审计的意图闸门 + 会话级累计风控；办公落地应把业务政策写成可读策略挂在 Gateway，并把多轮小额/重复写同一单据的模式纳入审计，否则单次 HITL 通过后仍会被拆单绕过。

