# 每日资讯 · 20260924

## 一、论文（arxiv）

1. **[EnSIMem: Entity-Structured Indexing for Long-Term Agent Memory](https://arxiv.org/abs/2609.27279)**
   - 元信息：2026-09-23（arxiv abs；v1 submitted 2026-09-23）；预印本；主题标签：Agent Memory / 主题一致 episode / 实体–属性索引 / 需求覆盖式自适应检索 / 源证据短上下文缓冲；分级：S
   - 核心问题：长程 Agent 要在持续增长的交互史中找回「哪个实体、哪条属性、哪段原文证据」，但摘要会丢细节与 provenance，扁平 chunk/向量检索又不显式标明实体与属性；需要把结构当寻址系统、把原文当解释依据，而不是用结构替换原文。
   - 机制/设计：离线把会话切成主题连贯、非重叠 episode，抽取对话锚定索引 `[entity][type][property:value]→episode`，并保留时间戳与多模态字段。属性取「可 paraphrase、但不塌成 activity」的中等粒度。在线：查询规划器产出证据需求集 \(H(q)\)（实体/属性/条件/角色），并区分 point / temporal / compositional / aggregation；结构化匹配 + 稠密回退得到候选 episode，按需求覆盖自适应停检（聚合题须穷尽相关 episode）。生成端展开源 turn 文本而非索引摘要。无额外训练，构造与访问分离。
   - 证据：LoCoMo（Memora 协议，答生成 GPT-4.1-mini）：EnSIMem Overall 90.6%（GPT-4o-mini 评）/ 90.0%（Qwen3-32B 评），高于 MEMORA (P) 86.3%；单跳 94.2%、时序 89.0%、开放域仍最弱（70.8%）。LongMemEval：两评测模型 Overall 均为 92.8%，相对 MEMORA (P) 约 +5.4pp；多会话与 SS-assistant 增益最大。效率（LoCoMo）：端到端均值 14.4s，规划占 71.1%、检索 1.92 步/查询。消融：theme-coherent 96.59% vs per-session 94.32% / per-turn 90.91%；属性 Broad 96.59% vs Fine 92.05% / Very broad 90.91%；结构化检索 96.59% vs 仅稠密 86.36%；自适应预算 96.59% vs 固定 top-\(k\) 峰值 95.45%（\(k=8\)）。
   - 局限：Discussion/Limitations——当前只覆盖情景对话记忆，未含程序/语义记忆；切分、属性抽取、查询规划依赖 LLM，跨模型/提示会变；LoCoMo/LongMemEval 偏对话回忆而非技能执行或持久事实更新；评测模型偏好影响绝对分；延迟与引擎强相关，不宜直接对比 Memora 的 5.70s。失败条件：开放域证据不足、属性过粗/过细、固定小 \(k\) 覆盖不全。
   - 对办公 Agent 或 Agent 基础设施的意义：给「跨周邮件/会议纪要里谁说过什么、何时改过决议」一条可审计配方——索引寻址、原文作答、按题型控证据预算；落地可把实体 ID 挂权限/删除，并把开放域弱项外接企业知识检索。

2. **[Stable Geometry with Divergent Task Evidence for Efficient Long-Horizon Agent Compression](https://arxiv.org/abs/2609.27332)**
   - 元信息：2026-09-23（arxiv abs；v1 submitted 2026-09-23）；预印本；主题标签：Context Engineering / 几何–证据鸿沟 / GEM 证据优先块选择 / WorkBuddyBench（含 Office）/ 无训练外挂压缩；分级：S
   - 核心问题：长程轨迹在表示空间高度冗余，但「几何可覆盖」≠「执行证据可丢」——改文件的计划、写入命令与事后读回可能同向却承载不同任务态。仅靠几何覆盖做压缩会删掉下一步仍依赖的低能量证据。
   - 机制/设计：GEM（Geometry-Guided Evidence-Preserving Memory）。以完整交互块为单位、冻结编码器；(1) 保护集 \(P_t\)：近窗、目标相关观测、执行态（编辑/写路径）、新鲜错误、源记录；(2) 从 \(P_t\) 出发用最大残差贪婪补几何覆盖（默认 \(\tau=0.90\)、名义 \(K=16\)），受保护块不可因残差小被踢；(3) 在线转发带删除守卫 \(\delta=0.05\)，保留原文与时间序；不足 16 块不压；全局重选在首合格请求、会话/目标变更或新增 256 块后触发。不写摘要、不改行动模型。
   - 证据：表示层——同预算下证据约束相对几何把 next-action Top-3 从 0.31 提到 0.69（centroid 相似度仍 0.98）；定向替换使 Top-3 −0.33 而几何指标几乎不动。WorkBuddyBench Full260（DeepSeek-V4-Flash，Qwen3-Embedding-8B）：Base → GEM，Overall Score 69.87→70.18，合并 token 2.69M→2.11M/任务（−21.4%）；Office 81.84→84.06 且 T 1.20→1.15；Security token 5.98→3.95；Code 略掉分（76.99→75.25）。20 题在线消融：GEM Overall 60.39 / 3.36M vs Base 60.75 / 5.19M（约 −35% token）；Random / Geometry-only 分别为 53.06、55.03。固定-40 参考板（非配对）显示摘要/窗/PACE 等常在分与 token 间不可兼得。
   - 局限：保护规则是廉价启发式非环境真值（写≠成功、错误过期≠已修）；无独立 Limitations 节，但正文明确 Code 对中间态更敏感、20 题消融上 Security 可降分；embedding 增未缓存成本；Fixed-40 的 GEM† 与对照非同次配对跑。失败条件：仅几何补全、证据规则漏检关键写/错、或 \(\delta\)/重选过稀导致该留的块被裁。
   - 对办公 Agent 或 Agent 基础设施的意义：直接对应「读表→改文档→报错重试」类办公轨迹——先钉目标/写态/错因，再砍几何冗余；可与摘要式 compaction 对照：优先保可重放的原始工具块。生产上应按域（Office vs Code）调 \(K/\tau\)，并把保护规则接到审计字段。

3. **[Agensh: Scaling Organizational Intelligence to 1,024 Agents](https://arxiv.org/abs/2609.26781)**
   - 元信息：2026-09-22（arxiv abs；v1 submitted 2026-09-22）；预印本；主题标签：Multi-Agent / 无中心编排自组织 / 共享工作区·消息·共享上下文 / ProgramBench 规模化至 1,024；分级：S
   - 核心问题：主流多 Agent harness 依赖中心 orchestrator 分解与调度，扩展受编排容量瓶颈；需要让大量 worker 异步自发现子任务、通信消冲突、并入共享成果，且不把组织循环硬编码进运行时。
   - 机制/设计：每 worker 同一五步循环——Gather context → Claim（共享上下文写 CLAIM）→ Take action → Verify → Merge（Git 工作区）；重叠用 Mattermost 频道/私信协商。基础设施三件：Gitea 共享工作区（分支/冲突/PR）、Mattermost 消息、DeLM 风格 append-only 共享上下文（OBSERVED / FACT / FAIL / CLAIM / PATCH_SUMMARY + 全史 grep）。组织行为靠统一 prompt（仅 worker ID 不同）挂在单 Agent harness（如 Copilot）之上，适配器可换。
   - 证据：ProgramBench 五最难仓（FFmpeg/gromacs/pandoc/PHP-src/ctags），GPT-5.6-sol (high) + Copilot，6h、禁网。1→8→32→128 agents：五任务均值终测通过率 19.31%→20.68%→26.52%→28.78%（相对约 +49%）。更大组织更早达同分（如 pandoc 30%：128 约 30min vs 32/8 约 60/90min）。pandoc 扩到 1,024：33.89%→50.94%（128）→55.06%（1,024）。轨迹观察：8 人级接口协同、32 人级多人审整合、128 人级流程标准化与审稿角色、1,024 人级多 integrator 与失败接管——均为自组织涌现。
   - 局限：正文无独立 Limitations；评测限于软件复现、单模型/单 harness/固定 6h；绝对通过率仍低；涌现合作属轨迹观察非对照实验；未在同 \(N\) 下系统对比强中心编排。失败条件：CLAIM 冲突未及时协商、merge 反复冲突、或 FAIL 记录未阻止无效重试时吞吐浪费。
   - 对办公 Agent 或 Agent 基础设施的意义：给「多人并行起草/审订/合并」的企业知识工作一条去中心配方——共享文档仓 + 即时消息 + 类型化共享板（谁在做、已证伪什么）；落地可把 CLAIM/FAIL/PATCH_SUMMARY 接到权限与审计，用 agent 数换截止时间，而不是只加长单会话上下文。

## 二、GitHub 仓库

1. **[ilia-sokolov/OfficeAgent.NET](https://github.com/ilia-sokolov/OfficeAgent.NET)**
   - 元信息：2026-09-23（[v1.0.0](https://github.com/ilia-sokolov/OfficeAgent.NET/releases/tag/v1.0.0)）；已发布开源（MIT；NuGet `OfficeAgent.Mcp` 等）；主题标签：办公 Agent / Word·PowerPoint·Excel OOXML / 修订轨与 preview→apply / MCP·Agent Framework / 写结果可恢复审计；分级：S
   - 核心问题：编码 Agent 若整文件塞进上下文、或直接改 OOXML，既贵又易打坏样式/批注；合同与公文又需要「可红线审阅」与「写失败能不能重试」的明确语义。需要把意图收成可校验的 typed plan，在原生包上落地，并把存储结果与人审面拆开。
   - 机制/设计：基于 Open XML SDK 的统一引擎，经 `.NET` API / MCP / Microsoft Agent Framework 三面投影。(1) 工作流固定为 Inspect→Find（内容验证锚点）→Preview→Apply；锚点带 `expect`，漂移则 `expect-mismatch`/`stale-snapshot`，计划全成或全不成。(2) Word 默认 `Tracked` 修订；PPT 无红线模型，连接级 `DefaultChangeMode=Direct`，显式 Tracked 拒收；Excel 支持有界 `setCell`/`appendTableRows`/cell notes，改公式清缓存并标全簿重算，不自己算值。(3) 文档经 `(connectionId, documentId)` 寻址，文件系统根与 SharePoint（含 OBO 按用户身份）为边界；`writeOutcome` 区分 `notWritten`/`committed`/`writtenNotRegistered`/`unknown`，不确定写带 `possibleOutput`+SHA-256 走 recovery，禁止盲重试。v1.0 冻结线协议：工具响应统一 camelCase、22 工具输入 schema 与 69 命名响应态进 CI wire contract，引擎缝标 `[Experimental]`。
   - 证据：README「How it works / Scope and limitations」与 Try a Word edit（`writeOutcome: committed` + 修订轨验收）；[`docs/mcp-server.md`](https://github.com/ilia-sokolov/OfficeAgent.NET/blob/main/docs/mcp-server.md)、[`docs/concepts.md`](https://github.com/ilia-sokolov/OfficeAgent.NET/blob/main/docs/concepts.md)、[`docs/excel.md`](https://github.com/ilia-sokolov/OfficeAgent.NET/blob/main/docs/excel.md)、[`docs/upgrading-to-1.0.md`](https://github.com/ilia-sokolov/OfficeAgent.NET/blob/main/docs/upgrading-to-1.0.md)；[`SECURITY.md`](https://github.com/ilia-sokolov/OfficeAgent.NET/blob/main/SECURITY.md) 与 [`samples/HostedGateway/HostedSecurity.cs`](https://github.com/ilia-sokolov/OfficeAgent.NET/blob/main/samples/HostedGateway/HostedSecurity.cs)（连接 ACL + receipt 审计主体）；Release [v1.0.0](https://github.com/ilia-sokolov/OfficeAgent.NET/releases/tag/v1.0.0) / [`CHANGELOG.md`](https://github.com/ilia-sokolov/OfficeAgent.NET/blob/main/CHANGELOG.md)。
   - 局限：不驱动桌面 Office；不计算 Word 域/Excel 公式、不排版；Excel 快照不含样式/图表/透视/VBA；开源 HTTP MCP 无内置鉴权，托管须自加 TLS/认证与 fail-closed `IConnectionAccessPolicy`；`Revision.Author` 非认证身份；单维护者安全响应；复杂版式仍须人审。
   - 对办公 Agent 或 Agent 基础设施的意义：给出「合同/报价/纪要」类本机与 SharePoint 写文件配方——模型出 plan，引擎出可预览红线与可对账 writeOutcome；生产上默认 Tracked+有界根目录，把 MCP 挂在认证网关后，并用 HostedGateway 模式把主体写进 apply receipt，而不是让 Agent 直接拿路径与密钥。

2. **[genspark-ai/genoffice](https://github.com/genspark-ai/genoffice)**
   - 元信息：2026-09-22～2026-09-23（[v0.10.1038](https://github.com/genspark-ai/genoffice/releases/tag/v0.10.1038)；本窗合入 ZIP/附件闸、空 HTTP token fail-closed、`--max-chars` 上界等）；已发布开源（Apache-2.0）；主题标签：办公 Agent / Word·Excel·PPT·PDF / CLI·MCP / 本地全文检索 / 路径审计与解压边界；分级：S；重复出现，值得关注
   - 核心问题：办公 Agent 既要产出可进 Word/Excel/PowerPoint 的真文件与可审阅修订，又要在 CLI/MCP 暴露读全文、改表、解附件时不被恶意包、空鉴权或无界预览拖垮上下文与进程。
   - 机制/设计：本地桌面套件 + 同源 `genoffice` CLI/`genoffice mcp`（`docs_*`/`sheet_*`/`slides_*`/`deck_start→deck_page→deck_build`）。AI 改动以修订轨/快照回滚/活公式落地；`GENOFFICE_ALLOWED_ROOTS` 约束读写树，命令审计写入 `~/.genoffice/cli-audit.jsonl`。v0.10.1038：Home 本地 SQLite 全文检索（含 CJK，可选 TypeSafe Jev 重排）、Parallel 搜索源、幻灯片图表/排版与 Docs 大文档性能等。本窗硬边界：[#761](https://github.com/genspark-ai/genoffice/pull/761) 按真实文件长度校验 ZIP 条目、`xlsx`/`pptx` 附件解析走 `assertZipWithinLimits`；[#762](https://github.com/genspark-ai/genoffice/pull/762) MCP `--token ""` 启动前拒收（空值不再被当成「未配置鉴权」全放行）；[#777](https://github.com/genspark-ai/genoffice/pull/777) `--max-chars` 超 1M 拒绝，完整正文须显式 `--full`。
   - 证据：README「Find files / Command line and agent skill / MCP」；[`packages/cli/README.md`](https://github.com/genspark-ai/genoffice/blob/main/packages/cli/README.md)（Path policy and audit log、MCP HTTP token）；Release [v0.10.1038](https://github.com/genspark-ai/genoffice/releases/tag/v0.10.1038)（同步 [#757](https://github.com/genspark-ai/genoffice/pull/757)）；PR [#761](https://github.com/genspark-ai/genoffice/pull/761)、[#762](https://github.com/genspark-ai/genoffice/pull/762)、[#777](https://github.com/genspark-ai/genoffice/pull/777)。
   - 局限：「world's first」属营销口径；`search`/`image`/`media` 仍出站；无邮件/日历/Teams 连接器；ZIP 声明信任在 `zip-load` 仍部分依赖 JSZip 膨胀后校验；PDF/复杂版式依赖本机渲染；大量补丁为防护向，需以兼容性与安全实测为准。
   - 对办公 Agent 或 Agent 基础设施的意义：与上条互补——OfficeAgent 偏契约式 plan/红线/写结果语义，GenOffice 偏完整编辑器引擎与布局审计；生产默认设允许根、开审计日志，并把 MCP HTTP token 与读文档字符帽做成硬配置，避免「以为锁了其实全开」或 Agent 把整本公文塞进上下文。

3. **[microsoft/agent-framework](https://github.com/microsoft/agent-framework)**
   - 元信息：2026-09-23（合入 [#8692](https://github.com/microsoft/agent-framework/pull/8692)；基线仍为近期 [python-1.19.0](https://github.com/microsoft/agent-framework/releases/tag/python-1.19.0) / [dotnet-1.22.0](https://github.com/microsoft/agent-framework/releases/tag/dotnet-1.22.0)）；已发布开源；主题标签：Agent harness / 人机审批续跑 / 会话态与聊天史一致性 / 失败可重放批准；分级：S
   - 核心问题：办公副作用工具（发信、改表、写库）常走 `ToolApprovalResponseContent` 人审后 resume；若 resume 因超时/取消/HTTP 失败，而会话袋已提前消费 pending 批准、聊天史却因失败未提交，会话会永久报「有请求无响应」，同一批准无法再投递，整段对话卡死。
   - 机制/设计：对齐两套存储的失败语义。聊天史本就只在 run 成功时提交；本窗把 `ApprovalResponseBindingChatClient` / `ApprovalNotRequiredFunctionBypassingChatClient` 改为：**仅在内层调用成功（流式须正常枚举完毕）后**才从 `AgentSession` state bag 清除 pending / 已注入的 auto-approval。流式路径用 `completedNormally` 区分「异常、取消、调用方提前停枚举」——后者不抛异常也会 dispose iterator，旧逻辑仍会清袋。失败 run 留下可重绑记录，宿主可原样重发同一批准响应；单测覆盖重试与流式中断。
   - 证据：PR [#8692](https://github.com/microsoft/agent-framework/pull/8692)（2026-09-23 合并）说明与 diff；实现 [`ApprovalResponseBindingChatClient.cs`](https://github.com/microsoft/agent-framework/blob/main/dotnet/src/Microsoft.Agents.AI/ChatClient/ApprovalResponseBindingChatClient.cs)、[`ApprovalNotRequiredFunctionBypassingChatClient.cs`](https://github.com/microsoft/agent-framework/blob/main/dotnet/src/Microsoft.Agents.AI/ChatClient/ApprovalNotRequiredFunctionBypassingChatClient.cs)；单测 `ApprovalResponseBindingChatClientTests`、`ChatClientAgent_ApprovalRetryTests`（+269 行）。
   - 局限：本窗为 .NET 路径修复，生产需 pin 含该提交的包/commit，勿只盯旧 release tag；不替代网关级 RBAC/执行权威；不内置邮件/日历/Office 连接器语义；流式「提前停枚举仍 record emitted requests」依赖调用方正确续传批准。
   - 对办公 Agent 或 Agent 基础设施的意义：补上 HITL 的「批准态权威与聊天史同成败」——凡把 GenOffice/OfficeAgent/Workspace MCP 挂在 MAF 上做人审，resume 失败必须可重放同一批准，否则发信/改表闸门会假死；与 OpenAI Agents 侧嵌套审批保全同类，应视为办公 harness 默认回归项。

## 三、博客 / 工程文档

1. **[MCP Is Not Just Another API Standard](https://www.oreilly.com/radar/mcp-is-not-just-another-api-standard/)**（底层：[MCP Spec 2026-07-28](https://modelcontextprotocol.io/specification/2026-07-28/)、[Tasks Extension](https://tasks.extensions.modelcontextprotocol.io/specification/2026-07-28/tasks)）
   - 元信息：2026-09-23；已发布（O'Reilly Radar 长文；作者 Balaji Venkatasubramaniyar，基于大型企业平台 MCP 集成实践）；主题标签：Agent 基础设施 / MCP 工具描述即接口 / Tasks 长程·人机审批 / MCP Apps 审批 UI / 权限·审计·allowlist；分级：S
   - 核心问题：把 MCP 当成「又一套 API」会低估真正变化——集成决策从「双方事先谈妥契约」变成「模型在运行时按自然语言描述组合从未约定过的工具链」；文档处理、多步审批等办公/企业工作又无法塞进单次请求，且协议层不替你做治理。
   - 机制/设计：作者把生产痛点映射到 2026-07-28 规格演进。(1) 工具描述与 schema 分工：schema 管参数形状，name/description 管「何时选用、与相邻工具如何区分」；差描述会导致自信地调错工具或带错假设。(2) 组合是涌现的：序列逻辑在模型推理里而非可单测脚本，需按「未测链路也会出现」做失败安全。(3) 规格侧：协议核心无状态（去掉 sticky `MCP-Session-Id` 以适配水平扩展）；**Tasks** 把长任务做成可轮询的 durable handle，`input_required` + `tasks/update` 承接人审/补参（规范示例含「Approve deployment…」类 form elicitation）；**MCP Apps** 让服务器返回可内嵌交互 UI，便于人看清再批；鉴权对齐 OAuth 2.1/OIDC。(4) 治理配方：按 Agent 强制 allowlist、远程端点一律鉴权、不可变集中审计每一跳工具调用、密钥走 secrets manager 而非本地配置（防 configuration poisoning）。
   - 证据：全文基于作者「数月企业 MCP 集成」叙事；正式规格确认 Tasks 为 `io.modelcontextprotocol/tasks` 扩展、面向「Human-in-the-loop workflows — approval gates」、`tasks/get` 轮询与 `inputRequests`/`tasks/update` 输入回路；主规格 Security 节仍要求用户对工具调用显式同意、且工具描述默认不可信。文中给出 registry ~10k 服务器、SDK 下载量级等 adoption 旁证。
   - 局限：Vulnerability 扫描结论（路径穿越/注入/描述投毒等）为引用独立研究综述，文内无自跑复现表；allowlist/审计是架构建议而非可粘贴实现；Tasks/Apps 需客户端与服务器双向协商，落地仍依赖宿主产品。失败形态：描述过短时 Agent 选错相邻工具，问题常表现为下游「略偏」而非栈追踪。
   - 对办公 Agent 或 Agent 基础设施的意义：把「读公文→改表→发邮件/建审批」类跨系统工作流从 ad-hoc webhook 升到协议级 Tasks + 人审 UI，同时把工具文案当可审工程产物；生产上应默认：高副作用工具进 allowlist、每次调用落审计、发信/改共享盘前走 `input_required`，而不是指望模型自觉停手。

2. **[Introducing Claude Opus 5.5](https://www.anthropic.com/news/claude-opus-5-5)**
   - 元信息：2026-09-22；已发布（Anthropic 官方模型公告；配套 System Card / 行为审计叙述）；主题标签：办公知识工作 / Excel·演示文稿产出 / AutomationBench 跨应用业务流 / 难逆操作与边界遵守 / 动作分类器·沙箱；分级：A
   - 核心问题：办公 Agent 需要在真实公文包里稳定做研究、建表、出演示，并跨连接应用跑业务流，同时在长时无人值守时降低「越界 / 难逆副作用」；仅靠编码榜无法代表知识工作与工作流可靠性。
   - 机制/设计：更大能力 + 更低成本的 Opus 线（相对 Opus 5：默认负载约 −40% 成本，cache read $0.20、输出更快）。知识工作侧强调长上下文研究与可核对引用；安全侧称相对近期模型更少采取难逆操作或越权，并对每次动作做分类器筛查、提供可审计开源沙箱与合并前代码审查。高风险 cyber/bio 走与 Fable 5.1 同级 safeguard（必要时透明回落其他模型）。对齐：近 2,000 场景自动化 behavioral audit 上多项误对齐行为优于近期 Claude；新 containment 评测上试图绕边界次数约降 85%，且尝试均为低严重度并自报。
   - 证据：并购分析案例——两模型均用 Excel 建财务模型再写成是否成交的高管演示，结论一致，但 Opus 5.5 更完整、演示更易读，63 分钟 vs Opus 5 的 93 分钟且成本约 −50%。GDPval-AA v2.1：1846 Elo（Fable 5.1 1735 / Opus 5 1708）。AutomationBench（Zapier，跨多连接应用的真实业务工作流）：各 effort 档均高于 Opus 5 与 GPT-5.6 Sol；脚注说明该跑法无 fallback，safeguard 介入计失败。客户侧：Hex DataBench（晚到包裹 vs 追踪坏）、Hebbia 端到端财务工作流 rubric 覆盖 86.6% vs Opus 5 的 60.3%；Viktor（Slack/Teams 内 AI 员工）称同 effort 下步骤/工具调用更少、成本近半。
   - 局限：AutomationBench 为 Zapier 早期访问口径且无 fallback 压低分；公告偏能力叙事，未给发信/改日历连接器级 ACL、审批态 schema 或误拦率；作者承认模型常怀疑自己在被评测，真实部署外推仍难；cyber/bio 护栏会挡部分双用途办公安全研究。失败条件：把榜分当「可无人值守发信改库」许可会踩坑。
   - 对办公 Agent 或 Agent 基础设施的意义：把「建表→出演示→跨 Zapier 类连接器跑流」的能力信号和「难逆动作更收敛 + 动作前分类器」绑在同一发布里；落地应用 5.5 做公文包质量与跨应用编排，但对外发送、付款、关单仍须外挂确定性审批与审计，与模型内约束分层。

3. **[Introducing DigitalOcean Managed Agents: One AI-native stack to power your intelligence](https://www.digitalocean.com/blog/managed-agents-public-preview)**（配套：[How to Monitor Harness Runtime Sessions](https://docs.digitalocean.com/products/managed-agents/agent-harness-runtime/how-to/monitor-sessions/)）
   - 元信息：2026-09-22（博客 Updated）；监控文档 Last verified 2026-09-23；已发布（DigitalOcean 官方产品博客 + 工程文档；Managed Agents public preview）；主题标签：Agent 运行时 pause/resume / Action Gateway 权限与人机审批 / 跨系统工具集成 / 邮件·工单分流案例 / 可观测审计；分级：A；重复出现，值得关注
   - 核心问题：办公/业务 Agent 要跨 Slack、邮件、工单与沙箱跑脚本，传统 VM 难在「等模型/等人审时停计费、状态仍可恢复」，且凭证与工具权限若进沙箱就失去治理边界。
   - 机制/设计：两层垂直集成。(1) Harness Runtime：Firecracker microVM 隔离执行；pause/resume/fork 保留文件与会话；空闲可 auto-pause；按 active CPU 计费。(2) Action Gateway：单一托管 MCP，16,000+ 工具；凭证运行时代持、不进模型/沙箱；集中权限，敏感动作可强制人审；意图→工具匹配内部测称 99.3%。Insights 暴露审批次数、等待时长、token 与沙箱资源；文档明确「觉得慢先看审批队列」。案例：Qencode 从 Slack/邮件/Intercom 分流到 Jira，低置信度才人审。
   - 证据：公开基准（2026-09-21，Codex CLI×gpt-5.5，RIC1）：create→就绪 886 ms、首响 3.3 s；resume 就绪 305 ms，恢复后响 2.43 s≈常驻 2.47 s。计费例：2 vCPU 均 25% + 峰值 4 GB·1h ≈ $0.060 vs 满配 $0.126。Qencode 称 triage/状态汇报每周约省 4–8 小时、响应从数小时到近即时（厂商转述）。监控文档列出 Approvals 类指标与「approval request text truncated」等运维边界。
   - 局限：public preview；exec 路径较 Sprites 慢约 110 ms（边缘鉴权/审计开销）；Cursor/LangGraph 不报 token；审批文案在日志中截断；意图匹配 99.3% 为内部测试；Qencode 效果非独立对照实验；办公面仍偏连接器+沙箱，无原生 Docs/Sheets 修订轨语义。
   - 对办公 Agent 或 Agent 基础设施的意义：给出「跨邮件/聊天/CRM 的办公分流 Agent」基础设施配方——工具权限与人审在网关、执行在可暂停沙箱、会话日志可审计；生产上应把审批等待纳入 SLO，并对发信/建单/改库默认 ask，再按队列数据放宽例行动作。

