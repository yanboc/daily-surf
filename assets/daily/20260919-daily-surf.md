# 每日资讯 · 20260919

## 一、论文（arxiv）

1. **[JustMem: Just-Enough Memory Access for Long-Term Conversations](https://arxiv.org/abs/2609.19877)**
   - 元信息：2026-09-17（arxiv submitted）；预印本；主题标签：Agent Memory / 发现广度×阅读保真度 / 原子记忆卡+provenance / 查询自适应 LOOKUP·COMPOSE·REPLAY；分级：S
   - 核心问题：长对话记忆若用固定检索/压缩策略，要么漏掉跨会话分散证据，要么一律扩上下文抬成本并引入干扰；需要按查询把「搜多广」与「读多细」分开分配，而不是对所有问题同一套访问。
   - 机制/设计：会话级一次抽取可独立检索的原子记忆卡（subject/fact/event_date/status/kind，含时间与 provenance 链回原文）。Planner 一次产出实体/时序约束/操作，并预测分布式需求 \(d_q\) 与源保真需求 \(f_q\)，再按确定性规则选配置：\(f_q{=}1\)→REPLAY，否则 \(d_q{=}1\)→COMPOSE，否则 LOOKUP。LOOKUP：原查询相似检索+重排到 Top-K 紧凑卡；COMPOSE：原查询∪至多 2 条无答案改写的候选并集，再重排到同一 K（拓宽发现不加大最终紧凑预算）；REPLAY：用紧凑卡定位 provenance，仅在保真需求时恢复源会话。实现：GPT-4.1-mini 抽卡/规划/作答，text-embedding-3-small + Qwen3-Rerank，默认 K=10。
   - 证据：LoCoMo（Cat.1–4，1,540 题）、LongMemEval-S（500 题）；主指标 LLM-judge Acc.（5 次作答/评判，记忆与检索固定）与 Recall@10；效率计 construction/infer 生成 token。JustMem：LoCoMo Acc. 79.61±0.12、R@10 88.05、构造 53.38K、推断 1.33K；LongMemEval-S Acc. 83.40±0.24、R@10 96.00、构造 53.33K、推断 1.70K——均高于 LightMem/SimpleMem/A-Mem/MemoryOS 等匹配骨干对照，且生成预算更小。消融：全局原子 Top-10 相对 session-pack Top-1 +10.72pp；引导扩发现使聚合类查询 LoCoMo 68.93→77.97、LME 65.96→78.72；自适应 REPLAY 相对固定源恢复 83.40 vs 80.60（p=0.00258）且答阶段 token 1155 vs 3967；固定 REPLAY 全局套用仅 63.40 Acc./5.06K infer。LoCoMo-Plus 认知 split：62.59 vs 最强基线 MemOS 31.67，跨基准落差最小（17.02）。
   - 局限：Limitations——评测仍主要是既有长对话记忆基准，配置/权衡未穷尽；效率口径以生成 token 为主，未计嵌入/重排等系统成本。伦理节亦指出 provenance 恢复放大隐私与过时记忆风险。失败条件：REPLAY 在 56 道助手输出题上，源定位失败 3/56 即答错（定位成功则 53/53 全对）——瓶颈在找对源而非读源。
   - 对办公 Agent 或 Agent 基础设施的意义：给「会议/邮件跨会话回忆」定可落地的访问策略——本地事实走紧凑卡，跨单据汇总才扩发现，计划/代码/结构化产出才回放原文；生产上应把记忆写成带 provenance 的原子条目，并用查询侧规则门控是否烧上下文，而不是一律摘要或一律塞全文。

2. **[Correct Now, Insufficient Later: Auditing Update Sufficiency in Context Compression](https://arxiv.org/abs/2609.20045)**
   - 元信息：2026-09-17（arxiv submitted）；预印本；主题标签：Context Engineering / 上下文压缩 / 更新充分性审计 / paired-history / tombstone 与失败归因；分级：S
   - 核心问题：压缩记忆若只按「当前查询答对」验收，可能抹掉后续更新（撤销、过期、选择器切换、tombstone 回放等）所需的区分；需要把「现在正确、以后不够」变成可测失败模式，而不是再刷一个静态问答分。
   - 机制/设计：构造当前答案相同、但对共享未来更新答案分流的 matched-current 历史对；严格记忆轨 \(m_{t+1}=U(m_t,\delta_{t+1},q;B)\)，预算硬顶 1,200 UTF-8 字节（非 token）。对照含 deterministic frontier（保留控制事件+查询闭包内 live 记录）、latest-only、no-tombstone、structured/prose LLM writer，以及可回看原文的 archive。读端严格成功要求 stop 完成且恰为 `{"values":{query_key:...}}` 合约；另用事件解释器 \(E_q\) 与 bare-map 敏感规则做内容/格式归因。Observation 1：若两历史压缩态碰撞且未来目标不同，确定性 updater–reader 不可能两边都对。
   - 证据：24 对历史×6 机制（rollback/expiry/choice switch/late reference/tombstone replay/mixed），DeepSeek-flash 与 GLM-5.2。Frontier：DS current/reveal/joint = 96/96、96/96、45/48；GLM = 78/96、82/96、28/48。Latest-only 在 DS 上 current 仍 96/96 但 reveal 崩到 32/96；GLM 甚至 current 更高（84/96）而 reveal 仅 23/96——单看当前正确会选错压缩器。No-tombstone 在 tombstone-replay 层 reveal 0/16（相对 frontier 16/16 与 15/16）。Structured H reveal 62/96*（DS）与 56/96（GLM），其中 DS/GLM 各有 26/25 条「可解析但 wrong log」；GLM frontier 的 14 次 strict 失败在解释器下证据齐全，属 wrapper 合约问题。标识符重命名后 late-reference 充分性从 8/8 跌至 94/320，暴露词典序捷径。
   - 局限：正文 Limitations——每机制仅 4 对、合成事件语法、两段更新非长程；structured 基线未与确定性选择做 delivery 匹配；Alpha 标签等变性修复是事后设计；无第三模型实跑、缺完整部署 provenance，不能做回顾性显著性宣称；不覆盖真实对话/仓库/部分可观测环境。
   - 对办公 Agent 或 Agent 基础设施的意义：给「会话摘要 / 状态压缩 / 票据记忆」定验收标准——必须测撤销、过期、作废回放后是否仍够用；生产上应保留 tombstone/版本闭包进压缩态，并分开报「内容丢了」与「格式合约挂了」，避免用当前答对率上线错误的上下文管理器。

3. **[An Architecture for Long-Horizon Agents: Levels, Ticks and Cascaded Intelligence](https://arxiv.org/abs/2609.19519)**
   - 元信息：2026-09-17（arxiv submitted）；预印本（Preprint）；主题标签：上下文管理 / 长程 Agent harness / 层级有界状态文件 / tick 与级联智能 / 多 worker 委派；分级：A
   - 核心问题：企业级任务（运维处置、研究复现等）会穿越上下文窗口、进程寿命与人类注意力间隔；仅靠更长上下文或模型内记忆无法在 compaction/重启后不遗忘。作者主张「先能持续运行且不遗忘，才能谈持续学习」，且该能力属于模型外 harness。
   - 机制/设计：从 C,P,A,F≪H 推出七瓶颈（Autonomy/Horizon/State/Delegation/Correctness/Resilience/Cost），用四抽象回答：按时间尺度分层的 level（L0 工具秒级→L6 目标周级，每层保留有界摘要文件）、判断层行动单元 tick、具名协议文件（写者/读者/节奏/检查）、三档智能（judgment / labor·worker / 确定性进程）。关键机制：时钟唤醒+standing decisions；硬规则「任意日志/源码最多读 40 行」；resume 以 checkpoint 为准、journal 更新则 journal 胜；brief/PROGRESS/DIRECTIVE 的 steered labor；实验卡预注册假设/成功准则/早停/资源帽/种子，gate 上 adversarial reviewer；review-and-escalate（最低可行层执行→上一层审→再失败才升档）。
   - 证据：单次 10 天战役复现 Hou et al. 异步 RL 陈旧性结果（两模型尺度）：未校正策略过阈值崩溃、校正后稳定。附录 Table 1：日历 10/时钟 8 天；driver ticks 211、上下文重置 47；worker 例行/强档 403/35；对抗审阅 30 次、关键发现 7；升级/仅主理人决策 25/9；GPU-hours 2,215/3,000。 vignette：无引导 worker 卡在 958s/step，steered labor 六假设+30 分钟 DIRECTIVE 后降至 180s/step；reviewer 发现可绕过 verifier 的捷径与错误停规，迫使任务/停规重写；「持有 live run 的 worker 不得提前结束」从 brief 规则升级为 harness stop guard 后不再复发。作者强调：权重未更新，早期写入的操作知识改变了后期行为；换训练框架时 brief/card/directive/review 格式可迁移。
   - 局限：正文明确为单一部署的存在性证明而非基准对照；无多任务统计、无有/无层级文件的消融；「积累≠参数学习」。失败条件隐含：若关键状态只活在上下文、gate 未预注册、或 kill/升级证据被压缩抹掉，长程正确性与成本控制都会失效。
   - 对办公 Agent 或 Agent 基础设施的意义：把多日办公战役（跨审批、跨班次、跨工具）的「记忆」落成可 resume 的有界文件层级与协议，而不是会话摘要 alone；生产上可用 tick checkpoint + standing decisions + 副作用 gate 审阅，并把强模型只放在压缩态与升级路径上，控制长程 ROI。

## 二、GitHub 仓库

1. **[microsoft/Agents](https://github.com/microsoft/Agents)**
   - 元信息：2026-09-18；已发布开源（[#708](https://github.com/microsoft/Agents/pull/708) 合并；样本仓，语言实现分属 Agents-for-net/js/python）；主题标签：办公 Agent / SharePoint 知识检索 / 委托权限裁剪 / Graph Copilot Retrieval / Teams·Copilot 渠道；分级：S
   - 核心问题：企业办公 Agent 若用应用身份或自建索引读文档库，容易越权看到用户本无权打开的文件，或把检索与对话渠道绑死；需要把「按登录用户权限裁剪的 SharePoint 检索」做成可部署到 Teams/Web Chat 的样板，而不是再堆一套无权限感知的 RAG。
   - 机制/设计：新增跨 .NET / Node / Python 的 Build Genie Retrieval Agent 样本。用户经 Azure Bot OAuth 连接 `graph` 登录后，样本只用委托令牌调用 `POST https://graph.microsoft.com/v1.0/copilot/retrieval`：`dataSource=sharePoint`，`filterExpression` 由站点根 URL 生成 `path:"https://…/sites/…/"`，`maximumNumberOfResults` 默认 3（可配 1–25），并请求 `title`/`author` 元数据。`BuildRetrievalService` / `retrieve_sharepoint` 负责取 token、构请求、映射 `retrievalHits→extracts/webUrl`，失败归入 `NotSignedIn` / `NoResults` / `ServiceUnavailable`，不把 Graph 正文或栈写回聊天；消息路由只发摘要文本与带源链接的 Adaptive Card。README 明确不做邮件/日历/人脉等其它 Graph 面，并提示 `sharePoint` 无结果时可试 `oneDriveBusiness`。
   - 证据：样本 README（[dotnet](https://github.com/microsoft/Agents/blob/main/samples/dotnet/retrieval-agent/README.md)、[python](https://github.com/microsoft/Agents/blob/main/samples/python/retrieval-agent/README.md)）；实现 [`BuildRetrievalService.cs`](https://github.com/microsoft/Agents/blob/main/samples/dotnet/retrieval-agent/Services/BuildRetrievalService.cs)、[`RetrievalOptions.CreateFilterExpression`](https://github.com/microsoft/Agents/blob/main/samples/dotnet/retrieval-agent/Services/RetrievalOptions.cs)、[`retrieval_client.py`](https://github.com/microsoft/Agents/blob/main/samples/python/retrieval-agent/src/services/retrieval_client.py)；单测 `test_retrieves_mapped_items_with_a_delegated_token`；官方 [Copilot Retrieval API](https://learn.microsoft.com/en-us/microsoft-365/copilot/extensibility/api/ai-services/retrieval/copilotroot-retrieval)（委托 `Files.Read.All`+`Sites.Read.All`、按调用用户安全裁剪）；合并提交 [1c5ce8f](https://github.com/microsoft/Agents/commit/1c5ce8f)（2026-09-18）。
   - 局限：依赖租户具备 Retrieval API 资格与 SharePoint 索引延迟（文档入库后可能数分钟到数小时不可搜）；样本默认只演示 SharePoint 读检索，无写文档/发信/改日程；本地 fake 响应不能证明委托裁剪；索引与库「允许出现在搜索结果」需运维侧配置。
   - 对办公 Agent 或 Agent 基础设施的意义：给出「知识库问答」在 M365 落地的权限配方——检索必须走用户委托 Graph + 站点 path 过滤 + 源链接可点开核验，而不是服务账号扫全库；办公 Agent 接 SharePoint/OneDrive 时应把安全裁剪交给平台 API，并把失败收敛成可对用户说的状态，而不是泄露 token 或原始错误。

2. **[openai/openai-agents-python](https://github.com/openai/openai-agents-python)**
   - 元信息：2026-09-17；已发布（[v0.22.3](https://github.com/openai/openai-agents-python/releases/tag/v0.22.3)）；主题标签：Agent harness / 人机审批 / 条件 `needs_approval` / 校验参数对齐 / 邮件类副作用门控；分级：S；重复出现，值得关注
   - 核心问题：条件审批若看到的是「解析前/变换后不一致」的参数，会出现审批看 A、执行用 B（默认值填充、alias、validator 改写等），使「按主题/金额决定是否发信」一类策略形同虚设；需要审批观察值与最终调用绑定同一份可安全检查的输入。
   - 机制/设计：HITL 仍是 `needs_approval` → `interruptions` → `RunState.approve/reject` → 续跑。v0.22.3（#5066）把条件审批改成「先准备、再决策」：新增 `PreparedFunctionArguments` / `FunctionToolApproval`；callable 审批仅在参数可解析为对象时调用；缺省/畸形 JSON/`NaN` 等 fail-closed 强制人工批；若校验会加默认值、变换或产生不可安全比对的值（`can_prepare_without_user_code` 拒自定义 init/plugin/default factory），则不跑 callable、直接要求人工批；仅 `unchanged` 的 prepared 路径可交给后续 invoke，并用 `check_invocation` 防止审批中途换工具/参数。文档以 `send_email` 按 `subject` 含 refund 为例，且 handoff / `Agent.as_tool` 嵌套审批仍挂外层 `RunState`。
   - 证据：官方文档 [Human-in-the-loop](https://openai.github.io/openai-agents-python/human_in_the_loop/)（fail-closed 与 `send_email` 示例）；[v0.22.3](https://github.com/openai/openai-agents-python/releases/tag/v0.22.3) / 提交 [1d17ca4](https://github.com/openai/openai-agents-python/commit/1d17ca4)；实现 [`src/agents/util/_approvals.py`](https://github.com/openai/openai-agents-python/blob/v0.22.3/src/agents/util/_approvals.py)、[`src/agents/_function_tool_arguments.py`](https://github.com/openai/openai-agents-python/blob/v0.22.3/src/agents/_function_tool_arguments.py)；单测 [`tests/test_function_tool_approval_arguments.py`](https://github.com/openai/openai-agents-python/blob/v0.22.3/tests/test_function_tool_approval_arguments.py)。
   - 局限：只保证 function tool 条件审批与校验路径对齐，不替代网关级 RBAC/审计；Hosted MCP sticky 决策按 `server_label`+工具名，跨服务器同名不共享；序列化 `RunState` 会带上 context，密钥不宜放进可持久化上下文；无内置办公连接器语义。
   - 对办公 Agent 或 Agent 基础设施的意义：给「按收件人/主题/金额决定是否发信、改表、退款」的条件 HITL 补上参数一致性契约——审批回调看到的必须是将执行的那份；办公落地应把高副作用工具标 `needs_approval`，并对「缺省即放行」保持 fail-closed。

3. **[strands-agents/sdk-python](https://github.com/strands-agents/sdk-python)**
   - 元信息：2026-09-17 / 2026-09-18（[#4348](https://github.com/strands-agents/sdk-python/pull/4348) `handoff_to_user`、[#4240](https://github.com/strands-agents/sdk-python/pull/4240) Graph/Swarm snapshot）；已发布开源；主题标签：Agent harness / 人机交办 / interrupt 续跑 / 多 Agent 会话快照 / 可靠性；分级：A
   - 核心问题：办公长任务常要在「删文件/发信/提交」前主动问人，或在 Graph/Swarm 多节点中途崩溃后从节点续跑；若没有一等公民的交办工具与编排器快照，HITL 只能靠 prompt，崩溃则整图重来。
   - 机制/设计：新增 vended tool `handoff_to_user`：`make_handoff_to_user` 生成工具，首次调用经 `tool_context.interrupt(HANDOFF_INTERRUPT_NAME, reason=message)` 抛出 `InterruptException`，`stop_reason=="interrupt"`，消息在 `AgentResult.interrupts[].reason`；调用方回传 `interruptResponse` 后，人类答复作为 tool result 续跑。中断名固定为 `strands:handoff-to-user`（工具可改名仍可匹配）。文档要求勿与默认闸全部工具的 `HumanInTheLoop()` 叠成双提示，应 allow-list `handoff_to_user`；双向流式会话不支持该 interrupt。同窗 #4240 把 snapshot session 扩到 Graph/Swarm：`take_snapshot`/`load_snapshot` 用 versioned `Snapshot` 包 `serialize_state`，编排器 `save_latest` 可选按 `node`（默认，中途崩从上次节点续）或 `invocation`（更省 I/O、丢未完成 run）。
   - 证据：实现 [`handoff_to_user.py`](https://github.com/strands-agents/sdk-python/blob/main/strands-py/src/strands/vended_tools/handoff_to_user/handoff_to_user.py)、[`types.py`](https://github.com/strands-agents/sdk-python/blob/main/strands-py/src/strands/vended_tools/handoff_to_user/types.py)（`HANDOFF_INTERRUPT_NAME`）；文档 `site/.../vended-tools.mdx`「Handoff to User」；单测 `test_first_call_raises_interrupt_with_message_and_name` / 空消息不登记 interrupt；多 Agent [`_snapshot.py`](https://github.com/strands-agents/sdk-python/blob/main/strands-py/src/strands/multiagent/_snapshot.py)、[`snapshot_session_manager.py`](https://github.com/strands-agents/sdk-python/blob/main/strands-py/src/strands/session/snapshot_session_manager.py)；提交 [98b4977](https://github.com/strands-agents/sdk-python/commit/98b4977)（2026-09-17）、[5d5ffd2](https://github.com/strands-agents/sdk-python/commit/5d5ffd2)（2026-09-18）。
   - 局限：交办依赖模型主动调用工具，不是强制策略闸；与全量 HITL 叠加会双次打断；不支持 bidi streaming；编排器 snapshot 为 latest-only、无不可变历史；无内置邮件/日历/Office 连接器。
   - 对办公 Agent 或 Agent 基础设施的意义：把「先问再删/再发」做成可恢复的 interrupt 协议，并把多 Agent 办公流水线的崩溃续跑落到节点级快照——适合调研→写稿→审校并行图；生产上仍应另接工具级审批与审计，不能只靠模型记得调用 handoff。

## 三、博客 / 工程文档

1. **[The new CC, an AI agent built for families](https://blog.google/innovation-and-ai/models-and-research/google-labs/cc-expanding-to-groups/)**（底层产品说明：[labs.google/cc](https://labs.google/cc)）
   - 元信息：2026-09-17；已发布（Google Labs 官方博客；产品页 FAQ 同步）；主题标签：办公 Agent / 邮件·日历·Tasks / Docs·Sheets / 独立 Agent 身份与权限 / 人机审批；分级：S
   - 核心问题：家庭/小组的日程、学校邮件、待办分散在多人账户里，单人 Daily Brief 无法形成共享行动面；需要一个带独立身份、按发送者白名单收信、默认可写共享日历/任务但对外副作用需确认的跨应用协调 Agent。
   - 机制/设计：CC 拥有自己的已验证 Google 账号与清晰权限模型，最多 6 名成人成员协作。成员各自选择分享范围：按发送者 Auto-cc、每周私有「新发送者」清单审批、一次性转发邮件/Chat（含邀请截图）、共享 Drive 文件夹或把 CC 加入日历。产出面：共享「Your Day Ahead」晨报、专用共享 CC Calendar / Chat space / Tasks，以及预填报名/许可 PDF、购物清单、周菜单、共享 Docs/Sheets；Maps API 算车程。记忆拆成家庭共享 vs 个人私有。运行在隔离云电脑（Antigravity + Gemini）。对外闸门：只响应组成员；群外分享文件/发 PDF、向非成员发日历邀请均需确认；不能代签/代付、不能改组成员、默认不读个人主日历。
   - 证据：Tom Shane（Google Labs）博客列明身份、分享控件与三类时间节省场景；labs.google/cc FAQ 写明邮件只读批准发送者或直达 Agent 邮箱、Chat 仅限共享空间、Drive 创建物默认只对组成员共享、删除发送者会清掉 Agent 侧对应邮件、不能登录/搜索个人收件箱等硬边界。
   - 局限：Labs 实验；仅美国、18+、个人 Google 账号；学校账号/未成年人不可用；无公开误拦率/完成率；不能评论 Docs/Sheets、不能处理加密 PDF；删组成员只能整组重建。
   - 对办公 Agent 或 Agent 基础设施的意义：把「多账号邮件/日历协同」做成独立 Agent 身份 + 发送者级分享清单 + 群外写操作确认，而不是整箱 OAuth；企业落地可对照：共享工作区日历/任务与个人邮箱解耦，并对外发、外部分享做强制 HITL。

2. **[Projects redesigned: from folder to conversation](https://claude.com/blog/projects-redesigned)**（线索来源：X [@ClaudeDevs 长帖](https://www.unrollnow.com/status/2100633571543367691)；以官方博客为主要依据）
   - 元信息：2026-09-17；已发布（Claude 官方博客；Projects beta）；主题标签：多 Agent 协同 / 协调器–线程 / 共享记忆与产物库 / 长程跨文档工作流；分级：A；重复出现，值得关注
   - 核心问题：多会话并行时用户仍要自己拆任务、交接与拼结果；需要把「一个目标」变成可委派、可并行、离开后继续的项目级对话，并由协调器汇总。
   - 机制/设计：Project = 协调器对话 + 多个 thread。用户设 goal 与 repo/上下文后，Claude 划范围、委派、并行跑 thread、审输出并组装成品；可在主项目聊天或单个 thread 转向，亦可手机跟进。每个 thread 是独立 Claude Code 云会话（自有分支与仓库副本）；同文件冲突按 PR merge conflict 处理；thread 可再拆 subagents/loops/workflows。上下文：共享 memory（跨 thread 读写）+ library（用户文件与 Claude 产物）。博客明确：连上仓库可开 PR/跑测试；「with documents, it reads them and drafts」。beta 先给部分已用云会话、且尚无 web/desktop Projects 的 Pro/Max；随后扩更多 Claude Code，再扩全部 Claude 与 Team/Enterprise。
   - 证据：公告给出 checkout p75 延迟优化、跨 API/web/mobile 退役 v1 端点等并行 thread 例；可配置云环境、connectors、plugins、instructions、model；usage 按项目可查，协调器与 worker 可分设 model/effort；官方 X 长帖与 The Verge 报道日期对齐为 2026-09-17。
   - 局限：当前主战场是 Claude Code，本地工具与私网「coming very soon」；并行 thread 更快触达用量上限；同区重叠仍可能 merge conflict；办公垂直连接器与审批闸门未在本文展开；全 Claude / Cowork 覆盖仍在后续 rollout。
   - 对办公 Agent 或 Agent 基础设施的意义：给「跨文档长任务」提供可抄的多 Agent 组织形态——协调器持目标与共享记忆，线程持局部执行与分支隔离；办公落地可把调研/写稿/制表/审校拆成 thread，但必须另接写工具审批与审计，否则并行只会放大副作用面。

