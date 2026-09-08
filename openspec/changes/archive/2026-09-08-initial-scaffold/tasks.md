## 1. 仓库与 openspec 初始化

- [ ] 1.1 修正 git remote 为 https://github.com/yanboc/daily-surf，清理 .DS_Store 并完善 .gitignore
- [ ] 1.2 运行 openspec init，写 openspec/config.yaml 与 openspec/AGENTS.md

## 2. 文档与偏好

- [ ] 2.1 重写 README.md 为纯索引
- [ ] 2.2 修正 .preference/papers.md，新建 repos.md / blogs.md 与 feedback 模板

## 3. 邮件配置

- [ ] 3.1 写 mail_list.json（两个收件邮箱）
- [ ] 3.2 写 .env.example（SMTP 与 CURSOR_API_KEY 字段）
- [ ] 3.3 写 scripts/send_mail.py 与 scripts/md2html.py

## 4. 定时任务

- [ ] 4.1 写 scripts/run_daily.sh 与 scripts/run_weekly.sh（内容生成 runner）
- [ ] 4.2 写 scripts/send_mail.sh（渲染并发送）
- [ ] 4.3 写两个 launchd plist 并装载

## 5. 首份样例产物

- [ ] 5.1 生成 assets/daily/260908-daily-surf.md 样例
- [ ] 5.2 生成 assets/weekly/w35.md 样例