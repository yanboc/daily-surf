#!/usr/bin/env python3
"""读取 .env 与 mail_list.json，用 SMTP 把指定 markdown 渲染成 HTML 后发送。

用法:
  send_mail.py <subject> <path/to/report.md> [path/to/extra.md ...]

- 主题用第一个参数
- 每个 md 文件渲染为一段 HTML 依次拼接（周一日报 + 周报一起发）
- 收件人读 mail_list.json；发件人与密码读 .env
"""
import email.utils
import json
import os
import smtplib
import sys
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent


def load_env() -> dict:
    env: dict = {}
    env_file = ROOT / ".env"
    if not env_file.exists():
        print("缺少 .env，请参照 .env.example 填写 SMTP 配置", file=sys.stderr)
        sys.exit(1)
    for line in env_file.read_text(encoding="utf-8").splitlines():
        line = line.strip()
        if not line or line.startswith("#") or "=" not in line:
            continue
        k, v = line.split("=", 1)
        env[k.strip()] = v.strip()
    return env


def load_recipients() -> list[str]:
    mail_file = ROOT / "mail_list.json"
    if not mail_file.exists():
        print("缺少 mail_list.json", file=sys.stderr)
        sys.exit(1)
    data = json.loads(mail_file.read_text(encoding="utf-8"))
    emails = [item["email"] for item in data if item.get("email")]
    if not emails:
        print("mail_list.json 里没有收件邮箱", file=sys.stderr)
        sys.exit(1)
    return emails


def main() -> int:
    if len(sys.argv) < 3:
        print("usage: send_mail.py <subject> <report.md> [extra.md ...]", file=sys.stderr)
        return 2
    subject = sys.argv[1]
    md_paths = sys.argv[2:]

    env = load_env()
    recipients = load_recipients()

    host = env.get("SMTP_HOST", "")
    port = int(env.get("SMTP_PORT", "465"))
    user = env.get("SMTP_USER", "")
    password = env.get("SMTP_PASS", "")
    sender = env.get("SMTP_FROM", user)

    if not all([host, user, password]):
        print("SMTP 配置不完整，请检查 .env", file=sys.stderr)
        return 1

    # 渲染 html
    sys.path.insert(0, str(ROOT / "scripts"))
    import md2html

    html_parts: list[str] = []
    for p in md_paths:
        if not os.path.exists(p):
            print("文件不存在: %s" % p, file=sys.stderr)
            return 2
        html_parts.append(md2html.render(Path(p).read_text(encoding="utf-8")))
    body_html = (
        "<body>"
        + "<hr style='margin:24px 0;border:none;border-top:1px solid #eaecef;'>".join(
            html_parts
        )
        + "</body>"
    )

    # 组合邮件
    msg = MIMEMultipart("alternative")
    msg["Subject"] = subject
    msg["From"] = email.utils.formataddr(("daily-surf", sender))
    msg["To"] = ", ".join(recipients)
    msg["Date"] = email.utils.formatdate(localtime=True)
    msg.attach(MIMEText(body_html.replace("<body>", "<body>").replace("</body>", "</body>"), "html", "utf-8"))

    try:
        if port == 465:
            server = smtplib.SMTP_SSL(host, port, timeout=30)
        else:
            server = smtplib.SMTP(host, port, timeout=30)
            server.starttls()
        server.login(user, password)
        server.sendmail(sender, recipients, msg.as_string())
        server.quit()
    except Exception as e:  # noqa: BLE001
        print("发送失败: %s" % e, file=sys.stderr)
        return 1

    print("已发送至 %d 个邮箱: %s" % (len(recipients), ", ".join(recipients)))
    return 0


if __name__ == "__main__":
    sys.exit(main())