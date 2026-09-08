# weekly-report Specification

## Purpose
定义每周一自动聚合上一周（周一到周日）四大板块内容生成的周报，并以上一周所在 ISO 周数命名落盘。

## Requirements

### Requirement: 每周聚合四大板块
系统 SHALL 在每周一聚合上一周（周一至周日）的四大板块内容，生成周报：
- 论文：大模型、多 agent 交互、agent harness/记忆相关新论文
- GitHub：周内 star 增长过千的库，重点 AI/agent/多 agent
- 公司博客：OpenAI、Anthropic、Google DeepMind、Meta AI、Mistral、xAI、Qwen、DeepSeek 等
- 大佬动态：Andrej Karpathy、Yann LeCun、Geoffrey Hinton、李飞飞、Andrew Ng 等

#### Scenario: 周一生成上一周周报
- **WHEN** 定时任务在周一触发周报流程
- **THEN** 系统聚合上一周（周一至周日）内容，覆盖四大板块

#### Scenario: 建议动态调整
- **WHEN** 周报生成时
- **THEN** 系统在四大板块之外，额外给出主题/人物/工具/思想等新建议，供后续调整每日/每周自动化任务

### Requirement: 周报落盘
系统 SHALL 将周报写入 `assets/weekly/w{ISO周数}.md`，ISO 周数以生成日所在周的前一周为准。

#### Scenario: 生成 ISO 周命名的周报
- **WHEN** 周报内容生成完成
- **THEN** 系统在 `assets/weekly/` 下创建以 ISO 周数命名的 `.md` 文件

### Requirement: 周报格式规范
系统 SHALL 每周报包含概述、四大板块与个人点评，每条附原文链接，并明确数据来源与时间口径。

#### Scenario: 结构化周报
- **WHEN** 周报生成时
- **THEN** 周报含概述、四大板块、个人点评，每条带原文链接，明确来源与口径
