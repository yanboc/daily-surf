# daily-report Specification

## Purpose
定义每天自动生成的科研/技术资讯日报：抓取当日新增论文、GitHub 热门库、前沿公司技术博客/工程文档三大板块，写成一个结构化 markdown 文件落盘。daily-surf 只关注精品长内容，不追踪社交平台动态。

## Requirements

### Requirement: 抓取最近三天窗口的三大板块
系统 SHALL 每次抓取目标日及其前两天（东八区，共 3 个自然日）新增的论文、GitHub 仓库、技术博客/工程文档三大板块内容，并保留原文链接。

#### Scenario: 抓取最近三天内容
- **WHEN** 定时任务在生成日（东八区）触发日报流程
- **THEN** 系统对三个板块分别检索最近 3 天（东八区）内新增内容，且每条结果带原文链接

### Requirement: 少而深的一手研究
系统 SHALL 每份日报保留三个板块、合计 6–9 条，并基于一手资料为每条写出元信息、核心问题、机制/设计、证据、局限和实践意义；系统 SHALL NOT 额外生成主题综述或泛泛点评。

#### Scenario: 论文入选
- **WHEN** 论文候选与办公 Agent、Agent Memory、上下文管理或多 Agent 协同相关
- **THEN** agent 阅读正文的方法、实验/案例与 limitations 后才可写入，且优先记忆、上下文管理和多 Agent 协同

#### Scenario: 仓库或博客入选
- **WHEN** GitHub、博客或 X 线索指向办公 Agent 或 Agent 基础设施
- **THEN** agent 阅读 README/官方文档/关键设计/完整正文；普通 X 帖只作线索，作者或团队的一手长帖可进入博客板块

### Requirement: 审阅模式
系统 SHALL 支持指定历史日期生成隔离待审稿；审阅模式不得覆盖正式日报、发送邮件或写入飞书。

#### Scenario: 历史补跑
- **WHEN** 使用 `--date YYYYMMDD --review`
- **THEN** 报告、中间稿、结构化 JSON 和日志写入 `assets/review/YYYYMMDD/`

#### Scenario: 某板块无新增
- **WHEN** 某一板块最近 3 天窗口内无新增内容
- **THEN** 系统在日报中标注「本板块今日无新增」，其余板块正常输出

### Requirement: 允许内容重复
系统 SHALL NOT 对同一内容（跨日报或窗口内重复出现）做去重剔除；重复出现视为内容值得关注的信号，正常保留。

#### Scenario: 窗口内重复出现
- **WHEN** 同一论文/仓库/博客在最近 3 天窗口内重复出现（例如被多次转载/讨论）
- **THEN** 系统正常保留该条，并标注「重复出现，值得关注」，不因重复而剔除

### Requirement: 日报落盘
系统 SHALL 将生成的日报写入 `assets/daily/YYYYMMDD-daily-surf.md`，文件名为生成日日期（`YYYYMMDD`，东八区）。

#### Scenario: 生成当日日报文件
- **WHEN** 日报内容生成完成
- **THEN** 系统在 `assets/daily/` 下创建以当日日期命名的 `-daily-surf.md` 文件

#### Scenario: 文件已存在
- **WHEN** 目标文件名已存在
- **THEN** 系统覆盖该文件，用最新生成内容替换

### Requirement: 发布状态区分
系统 SHALL 严格区分「已发布」与「未发布/预印本」，并在每条内容旁标注。

#### Scenario: 标注发布状态
- **WHEN** 日报引用某条论文或博客
- **THEN** 每条内容标注「已发布」或「预印本」，预印本明确标注

### Requirement: 输出不含数据口径叙述
系统 SHALL NOT 在输出文档中叙述数据抓取口径（如生成日、时间口径、检索方式说明），只呈现内容本身。

#### Scenario: 输出仅内容
- **WHEN** 日报生成时
- **THEN** 日报开头不出现「数据口径/生成日/抓取时间」类说明文字，直接呈现各板块内容
