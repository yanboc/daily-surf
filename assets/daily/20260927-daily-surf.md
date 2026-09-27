# 每日资讯 · 20260927

## 一、论文（arxiv）

1. **[TWIST: A Proposed Benchmark for Intervention Quality in Conversational Memory, with a Human-Validated Draft-Alignment Track](https://arxiv.org/abs/2609.28575)**
   - 元信息：2026-09-25（arxiv new listings；v1 submitted 2026-09-23）；预印本；主题标签：Agent Memory / 干预质量评测 / 草稿对齐 / 硬负例配对 / LoCoMo·多通道工作区；分级：S
   - 核心问题：长对话记忆榜多测「能否想起」或「被问时能否更新」，却很少测部署面真正决定产品风险的边界——系统何时该主动介入（发现未和解张力、拦截与记录冲突的待发草稿、用当前信念作答并保留 supersession 史、约束敏感召回），以及何时不该介入。需要把「发现/拦截」与「勿过度拦截」绑成配对指标，避免靠全量打标刷召回。
   - 机制/设计：TWIST 四轨 + 五调用 API（`ingest`/`flag_tensions`/`recall`/`check_alignment`/`resolve`）。信念转移分类：contradiction / supersession / acknowledged revision / coexistence / uncertain update。Track A 无提示张力检测；Track B 输出时草稿对齐（本版已实例化）；Track C 信念替换；Track D 安全召回（含授权上下文）。每轨为检测/拦截配硬负例与证据预算（至多 top-3 引用计入）。语料：向 LoCoMo 10 会话注入弧；另规划 TWIST-CS（6 个合成多通道工作区：chat/email/通话，400–900 事件）。验证：双人金盲标注+裁决、LLM judge decoy、可分性审计。
   - 证据：Track B v1.0 冻结键 161 项（post-adjudication κ=0.851；CR n=38 / AS n=61 / HNS n=62）。金证据条件下三后端矛盾召回均为 1.000。无配置同时高矛盾召回、高硬负例特异度与高归因：flat-RAG 召回约 0.76–0.97 但硬负例误拦约 16–43%（视后端）；部署的 coherence 向系统特异度 0.98–1.00 却只抓住约 42% 真矛盾（多 ingest 均值约 0.39 [0.19, 0.51]）。全上下文 Claude 可达约 0.947/0.951/0.919 与归因 0.889，指向检索覆盖缺口。Grounded CR 阶梯：部署 0.18 → flat-RAG 0.45–0.55 → 全上下文 Claude 0.84 → 金证据 0.97–1.00。v0 试点已暴露「召回满分 vs 硬负例 63% 误拦」对立失败。
   - 局限：Limitations——条目多为合成注入；Track B v1 由单一模型族生成（有跨族 council 与人工金门）；作者为相关产品方；Track A/C 与 CS 语料标为 v2，本版主结果在 Track B。失败条件：只报矛盾召回不报 HNS/GCR；或检索漏证据时把「能推理却找不到锚」当成记忆系统已治理。
   - 对办公 Agent 或 Agent 基础设施的意义：直接对应「发信/回客户前对照 CRM·纪要·旧承诺」——记忆层要同时测漏拦与误拦；生产可把 `check_alignment` 挂在邮件/工单写闸前，并用硬负例（已明示改口、共存事实）校准，避免助手对安全草稿过度否决或对真冲突沉默。

2. **[ERRAND: Budgeted Maintenance of Agent Memory](https://arxiv.org/abs/2609.29545)**
   - 元信息：2026-09-25（arxiv new listings；v1 submitted 2026-09-02）；预印本；主题标签：Agent Memory / 预算化再验证 / 陈旧信念 / 死区门闸 / 版本化修复；分级：S
   - 核心问题：冻结策略 Agent 在部署时接手一批已固化知识（runbook、配置、工具备注），世界会按自己的日程翻转路径/开关/价格带；任务路径上的「顺路收据」可免费刷新，离路径知识则静默陈旧。问题不是「要不要维护」，而是固定动作预算下先复核哪一条、何时故意不花预算。
   - 机制/设计：Errand 不改策略与静态库内容，只调度「从任务挪来的复核动作」。(1) 原子事实两状态 Markov 漂移，陈旧信念 \(q\) 闭式松弛；(2) 单峰 VOI \(\min\{q\ell,(1-q)g\}\)，两端确定免费；(3) 死区门闸：候选 \(V/c\) 与影子工资 \(\hat\nu\) 比较，不达则工作；(4) 三档检查（顺路推迟 / 代理读数 / 直达复测）；(5) 生命周期：abeyance 只关「用」、不关「看」，翻转则版本化替换而非删除。调度为检索候选上 \(O(k)\) 算术，不耗模型调用。
   - 证据：冻结 Qwen3-8B、\(T=2000\)（暖机 300）、briefing 26 项、硬帽 \(b\) 每百步 errand 动作；主指标 ITT（全相关步成功）+ 条件成功。无维护：知识步在仍成立时 85.8%、翻转后 6.3%（−79.5pp）。同测得花费下 Errand 高于急切再验证（最紧帽 +4.5pp，基帽 +10.0pp）；基帽 ITT 71.9% vs eager 61.9%；\(b=6/12/24\) 边际约 8.0/10.0/5.2pp；五设置均 +7.1pp。无帽时 Errand 自停在 11.0% 步，eager 花 70.7% 仍落后 capped Errand 4.5pp——工资而非帽在限流。Oracle 读真陈旧标签在条件口径居前却 ITT 落后，说明「删/滤」≠维护。
   - 局限：正文无独立 Limitations；结论边界——知识以交接 briefing 到达，自巩固经验的维护未测；环境为脚本化工具世界。失败条件：把离路径知识当永真；或无死区地周期全库复查，挤占任务预算却仍漏尾部。
   - 对办公 Agent 或 Agent 基础设施的意义：企业 Agent 的「共享盘路径、审批开关、价目/SLA」会漂——应用任务流量的免费收据养热点，把有界复核预算花在 VOI 峰值的冷知识上；生产可把「疑→停用→顺路赎回」做成可审计死区日志，而不是定时全量重爬。

3. **[How does Adversarial Influence Scale in Multi-Agent Systems?](https://arxiv.org/abs/2609.30028)**
   - 元信息：2026-09-25（arxiv new listings；v1 submitted 2026-09-24）；预印本；主题标签：Multi-Agent / 对抗影响缩放 / 欺骗者比例 / 诚实叛变 / 私聊协同；分级：A
   - 核心问题：多 Agent 辩论常靠「加人」提分，但若部分参与者不善意、主动把群体拐向错误结论，诚实多数是否随规模更稳？人类遵从研究暗示误导方须成多数才显著；需弄清 LLM 群体中叛变率随欺骗者数量还是比例缩放。
   - 机制/设计：HLE 难度分层题；组规模 \(N=2\)–\(21\)，欺骗比例 \(k/N\in\{0,1/5,1/3,3/7\}\)，诚实始终占优（如 \(8{+}2\)、\(12{+}9\)）。协议：round 0 独立作答 → 多轮公开留言板 + 私有反思 → 终局私票；欺骗者持参考答案并伪装说服。对照：欺骗者可会前/轮间私聊协同。模型：Gemini 3.8 Flash、Grok 4.3、DeepSeek V4.1 Flash、Muse Glimmer（默认同模型同质；另做人–欺异质配对）。主指标：round 0 正确的诚实者终局改错的比例（honest defection）；GPT-5.4 按 HLE 官方说明判分。
   - 证据：叛变随 \(k/N\) 近似线性（每增 0.1：Gemini \(b=5.3\)、Grok \(4.2\)、DeepSeek \(2.1\)、Muse \(5.7\)，均显著；直线 \(R^2\) 0.82–0.97 优于平方根/阶跃）。比例模型优于计数模型（加比例 \(\chi^2=62.1\)，加计数不显著）；固定比例下加大 \(N\) 无一致保护。私聊协同反而降效：Gemini 29.2%→21.9%、Grok 30.0%→24.6%。异质：更谄媚诚实侧 Muse 37.7% vs Gemini 19.5%；更善说服欺骗侧 DeepSeek 26.8% vs Grok 21.2%。行为：58–72% 首次叛变发生在第 2 轮前；诚实反思常引「题意重释/不确定」；协同在 59/60 试验中准备不同措辞，诚实侧显式怀疑仅 1/60。
   - 局限：Limitations——仅两种审议协议、\(N\leq 21\)；与人类对照任务不同；行为分析描述性、未因果解释协同为何减效。失败条件：把「扩大评审组」当对抗鲁棒性；或假设少数恶意 Agent  harmless。
   - 对办公 Agent 或 Agent 基础设施的意义：合同/方案多角色评审若混入被投毒或目标错位的 Agent，加人不够——要控欺骗比例、加固诚实骨干（降谄媚）、并对早期轮次做独立核验；私聊「对齐口径」未必增强攻击，但生产仍应按租户隔离通信通道与可审计发言身份。

## 二、GitHub 仓库

1. **[genspark-ai/genoffice](https://github.com/genspark-ai/genoffice)**
   - 元信息：2026-09-25～2026-09-27（正式安装包 [v0.10.1467](https://github.com/genspark-ai/genoffice/releases/tag/v0.10.1467) 于 2026-09-27 发布；本窗另合入 CLI 多实例开档互斥、长工具中断、透视表结构写拒绝等）；已发布开源（Apache-2.0）；主题标签：办公 Agent / Word·Excel·PPT·PDF / CLI·MCP 模板合并 / 路径审计 / Agent 循环可中断；分级：S；重复出现，值得关注
   - 核心问题：办公 Agent 经 CLI/MCP 改写真 Office 包时，既要有「读 PDF、填模板、按 schema 调 apply」的可编排面，又要在用户点停、多开 GUI、透视表源区结构编辑等场景下 fail-closed，避免半截工具结果写回或静默毁掉工作簿。
   - 机制/设计：本地桌面套件 + 同源 `genoffice` CLI/`genoffice mcp`；`GENOFFICE_ALLOWED_ROOTS` 约束读写树，命令审计写入 `~/.genoffice/cli-audit.jsonl`。本窗增量：(1) [v0.10.1467](https://github.com/genspark-ai/genoffice/releases/tag/v0.10.1467) 面向 Agent 的表面——`mcp install` 向 coding agent 注册 stdio MCP；`merge` 在 docx/pptx/xlsx 上填 `{{key}}`（嵌套键展平、表格走 `replace_blocks`、单元格单占位符保留数值类型，`--strict` 遇未解析占位符不写盘）；`pdf read` 用无头 pdfium 抽文本层；docs/sheets/slides apply 工具带 typed op schema；(2) [#1056](https://github.com/genspark-ai/genoffice/pull/1056)/`153327d`：`AgentLoop` 用 `awaitToolOrAbort` 竞态 AbortSignal，中断时回写 `TOOL_ABORTED_OUTPUT` 且 `isError`，丢弃未完成工具结果；(3) [#980](https://github.com/genspark-ai/genoffice/pull/980)：CLI 跨多实例读取开档登记，避免改写另一 GUI 已打开文件；(4) [#1046](https://github.com/genspark-ai/genoffice/pull/1046)/[#1049](https://github.com/genspark-ai/genoffice/pull/1049)：xlsx gateway 对透视源表结构编辑与未建模透视重排 fail-closed。
   - 证据：Release [v0.10.1467](https://github.com/genspark-ai/genoffice/releases/tag/v0.10.1467)「CLI & MCP / AI」段；[`packages/cli/README.md`](https://github.com/genspark-ai/genoffice/blob/main/packages/cli/README.md)（Template merge、Path policy and audit log、MCP server、`mcp install`）；实现 [`packages/agent-core/src/loop.ts`](https://github.com/genspark-ai/genoffice/blob/main/packages/agent-core/src/loop.ts)（`awaitToolOrAbort` / `TOOL_ABORTED_OUTPUT`）；[`packages/cli/src/gui.ts`](https://github.com/genspark-ai/genoffice/blob/main/packages/cli/src/gui.ts)；[`packages/xlsx-gateway`](https://github.com/genspark-ai/genoffice/blob/main/packages/xlsx-gateway/src/gateway/xlsx-gateway.ts) 与 pivot 单测；合并提交 `153327d`、`6e7b257`、`35c6f21`。
   - 局限：邮件/日历仍无一等连接器；`search`/`image`/`media` 仍出站；`merge` 遇跨 run 拆分的占位符或嵌套 pptx 组内表需人工重打/取消组合；生产若 pin 旧 tag 会缺本窗中断与透视闸。失败条件：未设 `ALLOWED_ROOTS`、或把未完成工具结果当成功写回。
   - 对办公 Agent 或 Agent 基础设施的意义：把「改真 Office」收成可装的 MCP/CLI 合同——模板合并与无头读 PDF 降低上下文里拼 OOXML 的需求；中断与开档互斥、透视 fail-closed 是人机共编桌面文件的默认护栏。生产应默认允许根+审计，并把 abort 语义与「GUI 已开则拒写」纳入回归。

2. **[chrisryugj/kordoc](https://github.com/chrisryugj/kordoc)**
   - 元信息：2026-09-25～2026-09-27（[v4.15.4](https://github.com/chrisryugj/kordoc/releases/tag/v4.15.4) 2026-09-25、[v4.15.5](https://github.com/chrisryugj/kordoc/releases/tag/v4.15.5) 2026-09-26；README/`package.json` 已记 v4.15.6，`chore(release): v4.15.6` 于 2026-09-27）；已发布开源（npm `kordoc`）；主题标签：办公 Agent / HWP·HWPX·PDF·DOCX·XLSX→Markdown / MCP 表单填充与无损 patch / 公文档解析可靠性；分级：S
   - 核心问题：韩文/公文档工作流里 Agent 要吃 HWP/HWPX/政府 PDF 与 Office 附件，但表线缺失、双栏阅读序、标题误检、缺文件与解析失败混码，会导致填表、对照、RAG 引用整条链路漂。
   - 机制/设计：Node CLI + `kordoc-mcp`（`npx kordoc setup` 向 Claude Desktop/Cursor/Codex 等写入配置，暴露 `parse_document`/`parse_table`/`fill_form`/`patch_document`/`generate_document` 等约 17 工具）；能力含 HWP↔HWPX 对照、`patchHwpx`/`patchHwp` 原格式内替换、表单字段抽取与自动填充、本地 PP-OCRv5、`kordoc redact`。本窗聚焦 PDF 结构可靠性：(1) v4.15.4 密表行与 clip 边界；(2) v4.15.5 无横线/仅竖线/booktabs 类表合一、双栏先图注后脚注、#89 标题误检、#88 缺文件改为 `FILE_NOT_FOUND`（失败 JSON 只带 basename）；(3) v4.15.6 再抬 ODL 200 文档综合至约 0.9345，并修 Word/幻灯片阴影片表、small caps/旧式数字字形、页边竖章、格内断链等。`npm run bench:gate` 为 publish 硬门。
   - 证据：README「30초 설치 / 무엇을 할 수 있나요 / v4.15.4–6 / 성능」与 [`package.json`](https://github.com/chrisryugj/kordoc/blob/main/package.json)（`bin.kordoc`/`kordoc-mcp`、`bench:gate`）；Release [v4.15.4](https://github.com/chrisryugj/kordoc/releases/tag/v4.15.4)、[v4.15.5](https://github.com/chrisryugj/kordoc/releases/tag/v4.15.5)；PR [#88](https://github.com/chrisryugj/kordoc/pull/88)、[#87](https://github.com/chrisryugj/kordoc/pull/87)、[#85](https://github.com/chrisryugj/kordoc/pull/85)；API 示例 `extractFormFields` / `compare`（README）；复现入口 `node bench/odl-bench.mjs`。
   - 局限：主场景偏韩国公文档与 HWP 族；PDF 本体 redaction 不做（非 HWPX 只出掩码 Markdown）；OCR 为 opt-in，图内字/无语境人名仍漏检；v4.15.6 截至窗口末可能尚未挂 GitHub Release tag。失败条件：把扫描页当文本层解析却不开 `--ocr`，或把 `PARSE_ERROR` 当缺文件重试。
   - 对办公 Agent 或 Agent 基础设施的意义：给出「附件→结构 Markdown→填表/对照/写回」的东亚办公配方，且错误码与表/阅读序有可复现门闸。生产可把 `fill_form`/`patch_*` 放人审后，解析侧默认开结构化错误码与 bench 门，避免 Agent 在坏 PDF 上自信填错格。

3. **[ask-marcel/ask-marcel-office-cli](https://github.com/ask-marcel/ask-marcel-office-cli)**
   - 元信息：2026-09-25～2026-09-27（本窗大量合入 Teams 贴图拉取、Drive 版本/文件 diff、SharePoint 成员列举、邮件文件夹分页等；npm 基线仍为 [v2.7.0](https://www.npmjs.com/package/ask-marcel-office-cli)）；已发布开源（MIT）；主题标签：办公 Agent / Outlook·Calendar·Drive·Teams·Excel MCP / 只读为主的权限面 / 上下文预算与可修复错误；分级：S
   - 核心问题：Agent 要答「邮件附件里的预算表 / Teams 截图 / 共享盘相对上周改了什么」，但 Graph 多跳、HTML+base64 灌爆上下文，且写权限一开就可能误发信；需要「人号一次登录 + 默认只读 + 为大二进制和视觉证据开旁路」的工具面。
   - 机制/设计：Bun/TS CLI + 五工具 MCP 网关（`list-commands`/`get-command-docs`/`run-command`/`run-write-command`/`login`），避免每命令一 schema；浏览器 Playwright 登录缓存 `~/.ask-marcel/token-cache.json`（0600），无 Azure 应用注册。设计契约：约 212 命令中绝大多数 GET，仅 4 个邮件草稿类写（无 send/create-event/upload/delete）。本窗增量：(1) `extract-teams-chat-message-images`——经 IC3 读消息，只收 `AMSImage` 的 media URL（去 emoji/贴纸），同令牌下媒体服务拉图供视觉模型；(2) `diff-drive-item-versions` / `diff-drive-items`——两侧先转 Markdown 再 unified diff；(3) `list-sharepoint-site-members` 报站点谁能开；(4) 邮件文件夹分页加大、Outlook 嵌套附件可读、Loop 过新/旧版本渲染拒绝、`--max-cells`/`--sheet` 控表膨胀、错命令名就近建议。
   - 证据：README（只读爆破半径、MCP 五工具、markdown/二进制纪律）；[`docs/COMMANDS.md`](https://github.com/ask-marcel/ask-marcel-office-cli/blob/main/docs/COMMANDS.md) 上述命令条目；实现 [`src/use-cases/commands/extract-teams-chat-message-images.ts`](https://github.com/ask-marcel/ask-marcel-office-cli/blob/main/src/use-cases/commands/extract-teams-chat-message-images.ts) 与配套测试；窗口提交 `f00e4bd`、`057fbc3`、`968263d`、`7c1b444`、`d1452ad` 等；[`docs/commands.json`](https://github.com/ask-marcel/ask-marcel-office-cli/blob/main/docs/commands.json)（本窗 `generatedAt` 至 2026-09-27）。
   - 局限：正式 npm tag 仍停在 2.7.0，生产需 pin 含上述 commit 的构建或等下一 release；Teams 图依赖 chatsvcagg/IC3 令牌层，库侧可取消 elevated/guest 层则部分能力不可用；草稿写仍可能被后继工具误发（若宿主另挂 Graph 写面）；企业策略若禁个人 OAuth 设备流则登录路径不通。失败条件：把 `run-write-command` 与只读工具合并自动批准，或对大附件不用 `--output-path`。
   - 对办公 Agent 或 Agent 基础设施的意义：示范「邮件/日历/盘/会聊」办公只读面如何做成 Agent 友好合同——五工具发现、错误带 hint、二进制落盘、视觉证据与版本 diff 旁路。与 GenOffice/kordoc 互补：一边管云端 Graph 只读情报，一边管本机真文件引擎；生产默认只挂 `run-command`，草稿写单独人审。

## 三、博客 / 工程文档

1. **[Introducing the new Copilot with Home, Code and Autopilot](https://blogs.microsoft.com/blog/2026/09/25/introducing-the-new-copilot-with-home-code-and-autopilot/)**（底层：[What is an autopilot in Microsoft Foundry?](https://learn.microsoft.com/en-us/azure/foundry/agents/concepts/autopilot-overview)、[Microsoft Entra Agent ID design patterns](https://learn.microsoft.com/en-us/entra/agent-id/concept-agent-id-design-patterns)、[Governing Agent Identities](https://learn.microsoft.com/en-us/entra/id-governance/agent-id-governance-overview)；前身：[Introducing Microsoft Scout](https://www.microsoft.com/en-us/copilot/blog/2026/06/02/introducing-microsoft-scout-your-always-on-personal-agent/)）
   - 元信息：2026-09-25；已发布（Microsoft 官方博客；Jared Spataro）；主题标签：办公 Agent / Word·Excel·PowerPoint / Outlook·Teams·会议跟进 / Autopilot 独立身份·邮箱·日历 / 权限·审计·赞助人治理；分级：S；重复出现，值得关注
   - 核心问题：知识工作在会议、邮件、文档与 Agent 之间不断切换；若常驻 Agent 只能「代用户」发信/改日历，则无登录用户时无法动作，群聊里又会错挂权限与归因。需要把即时问答、可委托长任务与常驻数字同事收进同一 Copilot 面，并在租户内用可审计的独立身份跑跨 Outlook/Teams/文档的日程与跟进。
   - 机制/设计：产品层——**Home** 合并 Chat（即时）与 Cowork（端到端交付 RFP/上市包/财务关账等）；**Office in Copilot** 在对话内创建/更新真 Word/Excel/PowerPoint 并与桌面应用同步；**Autopilot**（原 Scout）云端常驻：自有 identity/memory/computer/workspace，可盯频道、跟帖、跑周期任务、跨日续跑，样例含供应商评审全流程（排期、会前准备、会议与跟进）。**Today**（预告）跨邮件/日历/Teams/任务起草回复与改期提案。身份层（Foundry/Entra）：Autopilot = **agent identity（服务主体）+ agent user account（用户对象）**——后者才给邮箱、日历、OneDrive、Teams 在场与组织架构席位，使 Agent「作为自己」在群聊与无用户触发场景动作；blueprint 定义能力与平台基础设施，**不授予具体团队业务资源**，实例由经理决定可触达的项目/站点；「持有 SharePoint 工具 ≠ 持有任一站点」。治理层：赞助人审批与访问包到期；赞助人离职自动转交经理；Conditional Access / ID Protection 可挂 blueprint；Scout 原文补「敏感动作可要求人签核」与 Purview 标签/DLP 在发送/写入前强制。
   - 证据：2026-09-25 公告对 Office in Copilot、Autopilot 办公面、插件注册表（IT 集中审批）与 Managed Runtime 的产品承诺；Foundry 文档明确三种 Agent 类型对照（Assistive / Background service / Autopilot）及「无用户回路 / 群聊代操」失败模式；Entra 设计模式把 Digital worker 钉为 blueprint→identity→**1:1 agent user**；治理概览写明访问包请求路径（Agent 自请 / 赞助人代请 / 管理员直配）与到期提醒。Autopilot 为月末 private preview / Home·Code 走 Frontier，非 GA 实测。
   - 局限：主文偏产品发布，缺发信/改日历的逐工具审批 schema、误操作率或审计字段示例；实现细节需下钻 Entra/Purview/Agent 365，而非本篇自洽；Code/FinOps 段落与办公主线并列。失败条件：把「有独立身份」当成已具备写动作 HITL，或在无赞助人/访问包过期策略时放任常驻 Agent；或把 blueprint 上的工具能力误当成已授权具体邮箱/站点。
   - 对办公 Agent 或 Agent 基础设施的意义：把「改真文档 + 会务跟进 + 邮件/日历指挥面」绑到租户级 Agent 身份模型——生产应给常驻办公 Agent 独立 Entra ID/agent user/赞助人与访问包到期审批，并把 Outlook/Teams 写路径挂在可审计主体与 Purview 闸上，而不是复用员工个人 OAuth 长效令牌。

2. **[Build where you want, run with confidence: Now Microsoft hosts and manages the code created by Copilot](https://www.microsoft.com/en-us/copilot/blog/copilot-studio/build-where-you-want-run-with-confidence-now-microsoft-hosts-and-manages-the-code-created-by-copilot/)**
   - 元信息：2026-09-25；已发布（Microsoft Copilot Blog；David Blyth；Feature releases / public preview）；主题标签：办公 Agent 基础设施 / Copilot Managed Runtime / Cowork·Code 应用托管 / Entra 身份与连接器策略 / 审计与集中清单；分级：A
   - 核心问题：Cowork/Code/Studio 让业务侧用自然语言快速造出启动管理器、仪表盘、自动化等「小应用」，但每套构建工具若各自拼托管、身份、连接器与发布流程，会留下分散的权限面与不可盘点的影子应用。需要把「谁都能建」与「租户内统一跑、统一管」拆开。
   - 机制/设计：**Copilot Managed Runtime** 公开展示为 Microsoft 运维、落在 Microsoft 365 租户边界内的托管运行时：已承接 Cowork、Code、Copilot Studio 产出的应用，并向第三方工具与专业开发者开放 SDK/CLI。运行时侧统一提供 Entra 身份与共享、组织策略（连接器、数据访问、批准端点、审计）、部署/版本/生命周期、以及 Microsoft 365 管理中心 **Apps** 清单（访问、用量、健康、策略）。SDK 负责脚手架、连接器类型化服务、预览与部署；运行时 API 在应用与宿主暴露的企业数据/身份/Copilot 工作上下文之间做安全桥接。文中强调「开放构建、托管运行」——创建工具可变，治理模型不变。
   - 证据：全文为官方预览契约，明确 Host 能力列表、管理中心集中库存、以及「Lovable 等第三方产出可进同一租户、同一登录与策略」的合作叙述；场景段给出 Cowork 建启动管理应用 → 开发者 Git 续写 → 管理员在同一清单审阅的闭环。与同日 Copilot 主公告中的 Managed Runtime / Code 沙箱叙述相互印证。
   - 局限：属产品/平台发布文，无性能数字、误配案例或连接器拒绝率；第三方 SDK 兼容边界与审计日志字段未展开；public preview，策略面可能继续变。失败条件：只开构建入口却未启用管理中心 Apps 治理，或允许连接器策略过宽，使「办公小应用」绕过与 Agent 同级的数据边界。
   - 对办公 Agent 或 Agent 基础设施的意义：把「Agent 代写的业务小工具」从个人沙箱升到可盘点的租户运行时——与 Autopilot 的身份治理互补：一边管常驻同事的邮箱/日历主体，一边管其产出应用的连接器、端点与审计清单；生产上应默认把 Cowork/Code 发布路径打进同一 Apps 库存与连接器策略，而不是另开一套影子托管。

3. **[Introducing Zoho AgentInbox: Email infrastructure built for AI Agents](https://www.zoho.com/blog/index.php/agentinbox/introducing-zoho-agentinbox.html)**
   - 元信息：2026-09-24 发布、2026-09-25 更新；已发布（Zoho 官方博客；Pavithra Murugan；early access）；主题标签：办公 Agent / 邮件基础设施 / 每 Agent 独立邮箱与凭证 / 投递·Webhook 审计 / MCP 工具面；分级：S
   - 核心问题：办公 Agent 一旦要真正收发邮件，默认做法是借用共享别名或人类邮箱凭证——结果审计分不清「人写还是 Agent 写」、吊销困难，且恢复链路与自主系统共用同一收件箱。需要把邮箱当成 Agent 一等基础设施，而不是借壳。
   - 机制/设计：**AgentInbox** 为每个 Agent 配置独立邮箱、永久地址与隔离凭证；面向代码（REST 配置邮箱/密钥），会话间保留收件箱与完整会话线程（含附件），可在无人逐步触发下读写回复。投递侧内置 SPF/DKIM、发送域隔离防声誉串扰，退信/投诉/失败实时进日志。事件侧按到达/回复/投递失败推送 HMAC 签名 webhook，失败自动重试并记每次尝试。安全侧：每 Agent 独立 API key（可单点吊销）、可选 OAuth 委托与自动轮换、AES-256。集成侧：REST 全覆盖，并提供 **内置 MCP server** 把发信/收信等能力暴露为原生 tool call；Contacts/Calendar API 在路线图上。
   - 证据：一手产品文给出「销售外联自有地址 vs 入职接待 Agent 接管入站线程」的可操作故事；明确审计范围——出站投递全链路（排队→打开/退信）与每次 API 的 payload/响应/延迟/所用密钥；webhook 可重放且不二次触发线上动作。Early access 开放反馈，非评测论文。
   - 局限：日历/通讯录尚未 GA；SMS/语音等通道仍在规划；文内无人审闸（「可不经人工步骤收发」）与企业合规默认可能冲突；无公开投递成功率或滥用防护评测。失败条件：把「独立邮箱」当成已解决对外披露风险，却未对发信工具加 HITL/域约束；或 MCP 工具面过宽导致单 key 可群发。
   - 对办公 Agent 或 Agent 基础设施的意义：补上「办公 Agent 邮件层」的可复制配方——独立地址 + 按 Agent 凭证 + 投递/API JSON 审计 + MCP 挂载；可与 Entra agent user / Workspace Agents 写闸对照：一边解决归因与吊销，一边仍须在编排层对不可逆发信做人审与收件域约束。

