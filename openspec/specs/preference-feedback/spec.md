# preference-feedback Specification

## Purpose
定义每次生成日报/周报后必须执行的用户偏好反馈闭环：收集「喜欢/不喜欢 + 为什么 + 改进方向」，并把反馈结构化的沉淀到 `.preference/` 与 taste 文档中。

## Requirements

### Requirement: 每次产出后收集反馈
系统 SHALL 在每次生成日报或周报后，向用户询问「喜欢 / 不喜欢」以及「为什么喜欢」和「要往哪个方向改进」。

#### Scenario: 产出后询问反馈
- **WHEN** 一份日报或周报产出完成
- **THEN** 系统向用户发起反馈询问，覆盖喜欢/不喜欢、原因、改进方向三个维度

### Requirement: 反馈结构化沉淀
系统 SHALL 将每次反馈结构化写入 `.preference/feedback/` 下的记录文件（以日期命名）。

#### Scenario: 写入反馈记录
- **WHEN** 用户提供反馈
- **THEN** 系统在 `.preference/feedback/` 下创建或更新一份记录，包含喜欢/不喜欢、原因、改进方向

### Requirement: 反馈回写 taste 文档
系统 SHALL 在反馈指向用户口味变化时，同步更新 `.preference/` 下对应的 taste 文档（papers.md 记录主题/作者/出版物，repos.md 记录代码仓喜好，blogs.md 记录博客喜好，people.md 记录大佬喜好）。

#### Scenario: 更新论文 taste
- **WHEN** 用户反馈表达了对某主题/作者/出版物的喜好变化
- **THEN** 系统更新 `.preference/papers.md` 对应部分

#### Scenario: 更新代码仓/博客/大佬 taste
- **WHEN** 用户反馈表达了对某代码仓、博客或大佬的喜好变化
- **THEN** 系统更新 `.preference/` 对应的 repos.md / blogs.md / people.md

### Requirement: 不经允许不跳过闭环
系统 SHALL 在每次产出后都执行反馈闭环，除非用户明确表示不更新。

#### Scenario: 默认执行闭环
- **WHEN** 产出完成且用户未明确跳过
- **THEN** 系统执行反馈闭环并尝试回写 taste 文档
