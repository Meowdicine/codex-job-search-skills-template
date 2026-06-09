# GitHub 分享说明

## 推荐方式

公开分享这个 template repo，私有保存自己的 career workspace。

```text
Public:
  codex-job-search-skills-template

Private:
  career-config.json
  Resume-Summary.md
  Resume-Material-Bank.md
  job-hunting.json
  Applications/
  PDFs/screenshots/portal logs
```

## 第一次发布

在模板仓库根目录运行：

```powershell
git init
git add .
git status
git commit -m "Initial public-safe Codex job search skills template"
```

确认 `git status` 没有真实简历、真实申请队列、PDF、截图、credential、session、`career-config.json` 后，再创建 GitHub repo。

使用 GitHub CLI 时：

```powershell
gh repo create codex-job-search-skills-template --public --source . --push
```

如果只给朋友看原型，可以先用 private repo：

```powershell
gh repo create codex-job-search-skills-template --private --source . --push
```

## 朋友如何使用

朋友 clone 后：

1. 把 `skills/*` 复制到自己的 Codex skills 目录。
2. 把 `config/career-config.example.json` 复制到自己的 private career workspace，改名 `career-config.json`。
3. 创建自己的 `Resume-Summary.md`、`Resume-Material-Bank.md`、`job-hunting.json`。
4. 新开 Codex thread，使用 `$oscarplus-coop-apply` 或其他 skill。

## 不要提交这些

- `career-config.json`
- 真实简历/cover letter/transcript
- `job-hunting.json`
- application package
- browser screenshots
- portal confirmation
- password vault
- `.env`
- cookies/session/token
