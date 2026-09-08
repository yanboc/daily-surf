# daily-report Specification

## Purpose
定义每天自动生成的科研/技术资讯日报：抓取当日新增论文、GitHub 热门库、大厂博客、大佬动态四大板块，写成一个结构化 markdown 文件落盘。

## Requirements

### Requirement: 每日抓取四大板块
系统 SHALL 每天在固定时间抓取以下四个板块当日新增内容，并保留原文链接：
- 论文（arxiv）
- GitHub 热门仓库
- 前沿公司技术博客
- 大佬个人主页/博客动态

#### Scenario: 正常抓取当天内容
- **WHEN** 定时任务在生成日（东八区）触发日报流程
- **THEN** 系统对四个板块分别检索，且每条结果带原文链接

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

### Requirement: 发布状态口径明确
系统 SHALL 严格区分「已发布」与「未发布/预印本」，并在每条内容旁标注数据来源与时间口径。

#### Scenario: 标注来源与发布时间
- **WHEN** 日报引用某条论文或博客
- **THEN** 每条内容带来源渠道与发布时间信息，预印本标注「预印本」
