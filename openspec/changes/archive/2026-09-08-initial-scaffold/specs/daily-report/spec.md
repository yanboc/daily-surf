## Purpose

定义每天自动生成的科研/技术资讯日报：抓取当日新增论文、GitHub 热门库、前沿公司技术博客/工程文档三大板块，写成一个结构化 markdown 文件落盘。daily-surf 只关注精品长内容，不追踪社交平台动态。

## ADDED Requirements

### Requirement: 每日抓取三大板块
系统 SHALL 每天在固定时间抓取以下三个板块当日新增内容，并保留原文链接：
- 论文（arxiv）
- GitHub 热门仓库
- 前沿公司技术博客/工程文档

#### Scenario: 正常抓取当天内容
- **WHEN** 定时任务在生成日（东八区）触发日报流程
- **THEN** 系统对三个板块分别检索，且每条结果带原文链接

#### Scenario: 某板块无新增
- **WHEN** 某一板块当日无新增内容
- **THEN** 系统在日报中标注「本板块今日无新增」，其余板块正常输出

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
