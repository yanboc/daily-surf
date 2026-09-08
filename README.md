# daily-surf 资讯自动化

> 个人科研 / 技术资讯流：每天自动抓取论文、博客/工程文档、GitHub 仓库三类精品长内容，生成日报/周报并邮件推送。
> 本文件是索引入口，具体内容见下方导航。

## 导航

| 分类 | 位置 | 说明 |
| --- | --- | --- |
| 偏好 / taste | [`.preference/`](.preference/) | 论文 [`papers.md`](.preference/papers.md) · 代码仓 `repos.md` · 博客 `blogs.md` · 反馈 `feedback/` |
| 流程规格 | [`openspec/specs/`](openspec/specs/) | 日报 [`daily-report`](openspec/specs/daily-report/spec.md) · 周报 [`weekly-report`](openspec/specs/weekly-report/spec.md) · 偏好反馈 [`preference-feedback`](openspec/specs/preference-feedback/spec.md) |
| 生成产物 | [`assets/`](assets/) | 日报 `assets/daily/` · 周报 `assets/weekly/` |
| 脚本与调度 | [`scripts/`](scripts/) | runner、邮件发送、launchd plist |

## 运行节律

| 事项 | 触发时间 | 产物 / 动作 |
| --- | --- | --- |
| 日报 | 每天 08:00（东八区） | 写 `assets/daily/YYYYMMDD-daily-surf.md` |
| 周报 | 每周一 08:00 | 写 `assets/weekly/w{ISO周数}.md` |
| 邮件 | 每天 09:00 | 渲染当日日报为 HTML 发至收件人；周一同时发周报 |

## agent 规则

所有生成内容的 agent 一律遵循 [`openspec/AGENTS.md`](openspec/AGENTS.md)。