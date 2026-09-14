## 1. 仓库与 openspec 初始化

- [x] 1.1 修正 git remote 为 https://github.com/yanboc/daily-surf，清理 .DS_Store 并完善 .gitignore
- [x] 1.2 运行 openspec init，写 openspec/config.yaml 与 openspec/AGENTS.md

## 2. 文档与偏好

- [x] 2.1 重写 README.md 为索引与运行入口
- [x] 2.2 修正 .preference/papers.md，新建 repos.md / blogs.md 与 feedback 模板

## 3. 邮件配置

- [x] 3.1 写 mail_list.json（两个收件邮箱）
- [x] 3.2 写 .env.example（SMTP、Cursor 与飞书字段）
- [x] 3.3 写 scripts/send_mail.py 与 scripts/md2html.py

## 4. 定时任务

- [x] 4.1 写 scripts/run_daily.sh（周一内含周报流程）
- [x] 4.2 写 scripts/send_mail.sh（渲染并发送）
- [x] 4.3 写两个 launchd plist（经 DailySurfRunner.app 启动）

## 5. 首份样例产物

- [x] 5.1 生成 assets/daily/260908-daily-surf.md 样例
- [x] 5.2 生成 assets/weekly/w35.md 样例
