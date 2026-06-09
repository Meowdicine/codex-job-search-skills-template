# 使用说明

这套模板适合让 Codex 参与求职：找岗位、排优先级、改简历、准备申请包、操作学校 co-op portal 或外部 employer portal，并在 final submit 前停下来等你确认。

## 1. 安装 skills

把仓库里的 `skills/*` 复制到 Codex skills 目录。

Windows:

```powershell
$repo = "PATH_TO_REPO\codex-job-search-skills-template"
$skillsHome = "$env:USERPROFILE\.codex\skills"
New-Item -ItemType Directory -Force -Path $skillsHome | Out-Null
Copy-Item -Recurse -Force "$repo\skills\*" $skillsHome
```

macOS/Linux:

```bash
repo="/path/to/codex-job-search-skills-template"
skills_home="$HOME/.codex/skills"
mkdir -p "$skills_home"
cp -R "$repo/skills/"* "$skills_home/"
```

安装后开一个新 Codex thread，让 Codex 重新加载 skill metadata。

## 2. 建立 private career workspace

不要在 public repo 里填真实个人信息。另建一个 private 文件夹，例如：

```text
%USERPROFILE%\Career-System\
  career-config.json
  Resume-Coop-System.md
  Resume-Summary.md
  Resume-Material-Bank.md
  Resume-Variants\
  dashboard-data\job-hunting.json
  Applications\
    OSCARplus\
    External\
  Job-Leads\
```

然后复制：

```text
config/career-config.example.json -> private-career-workspace/career-config.json
```

把里面的 `YOUR_*`、路径、学校、term、email、resume lane 改成自己的。

## 2.5 可选：用 xcode.best / CC Switch 切换中转站 API

Codex 做批量求职、浏览、改简历、开多线程时会消耗较多 API 额度。如果朋友准备用 xcode.best 这类 OpenAI-compatible 中转站，可以把这一步放在安装教程里，但不要把 API key 写进本 repo。

参考文档：

- xcode.best Codex 配置教程：https://docs.xcode.best/codex.html
- xcode.best CC Switch 使用教程：https://docs.xcode.best/cc-switch.html
- CC Switch Release 下载页：https://github.com/farion1231/cc-switch/releases

推荐路径：

1. 先在 xcode.best 控制台创建 API key。
2. 下载并安装 CC Switch。Windows 用户通常选择 `.msi` 安装包。
3. 打开 CC Switch，进设置页，开启对应工具的接管开关，例如 Codex。
4. 新建供应商，例如命名为 `Xcode`。
5. 在 Codex 标签或统一供应商里填写：

```text
Provider name: Xcode
Base URL: https://api.xcode.best/v1
API Key: <your private API key>
Model: choose the model shown in the provider docs or your plan
```

6. 在 CC Switch 里切换到这个供应商。
7. 重启正在运行的 Codex CLI / Codex App / terminal session，让新配置生效。

安全规则：

- 不要把 API key 写进 `career-config.json`、skill、README、申请包或 GitHub issue。
- 不要提交 `%USERPROFILE%\.codex\auth.json`、`config.toml`、截图或任何显示 key 的配置页。
- 第三方中转站不是官方 OpenAI 账号体系。使用前让朋友自己确认价格、额度、服务条款、隐私策略和可接受的风险。
- 如果 CC Switch 和手动 `.codex` 配置冲突，优先只保留一种配置方式，避免 Codex 实际请求走错供应商。

## 3. 准备最少材料

至少准备这些 private 文件：

- `Resume-Summary.md`: 最短可信简历事实，教育、项目、经历、技能、日期。
- `Resume-Material-Bank.md`: 可复用 bullet、数字、项目细节、证据边界。
- `Resume-Coop-System.md`: 你的求职目标、term、地域、resume lanes、文件命名规则。
- `dashboard-data/job-hunting.json`: 申请队列。
- `Application-Form-Defaults.md`: 常见表单默认值，只放非敏感字段。
- `External-Application-Profile.md`: 外部 portal 常用 profile 信息，只放你愿意让 Codex 使用的普通字段。

不要在这些文件里放明文密码、验证码、cookie、session、身份证件号码、完整住址、或任何你不愿意被复制到申请日志的内容。

## 4. 推荐日常入口

学校 portal / OSCARplus 批量申请：

```text
Use $oscarplus-coop-apply as the main controller. Read my private career-config.json and job queue. Rank the next batch by fit, deadline, salary, and friction. For each selected posting, create or refresh the package, route resume tailoring to $ats-resume-tailor, and stop before upload and final submit.
```

公共岗位搜索：

```text
Use $external-coop-search. Find current public Fall co-op/intern postings for software/data/cloud roles in Canada, verify official company pages where possible, deduplicate against my job queue, score them, and save only useful leads.
```

简历定制：

```text
Use $ats-resume-tailor for this JD. Give me the hard-gate verdict, ATS keyword map, truthfulness notes, and concrete resume edits. Keep every claim supported by my private resume sources.
```

外部 employer portal 申请：

```text
Use $external-coop-apply for this saved lead. Stage the official portal application with the approved package, handle ordinary fields, stop for CAPTCHA/2FA/custom answers, and do not click final submit without my current-thread approval.
```

## 5. 状态约定

`job-hunting.json` 里的 `status` 建议用这些：

- Search: `lead-inbox`, `fit-check`, `manual-review`, `apply-now`, `watch-only`, `skip`
- Package: `package-needed`, `jd-extracted`, `tailored`, `layout-pass`, `layout-revise`, `package-approved`
- Apply: `credential-needed`, `upload-staged`, `final-approval-needed`, `submitted-user-approved`, `submitted-user-completed`

状态越稳定，多线程协作越不容易乱。

## 6. 关键安全边界

- Codex 可以准备和检查，但 final submit 必须等你在当前 thread 明确批准。
- Codex 不应该打印、保存、截图、总结验证码或密码。
- 外部 portal 遇到 CAPTCHA、Cloudflare、2FA、OAuth 授权、账号关联、security questions，应该交给你处理。
- voluntary demographic/protected-class 问题只用你明确写在 private defaults 里的答案，不能推断。
- 学校 SSO、学校邮箱、OSCARplus 密码不能给外部 job-site 复用。

## 7. 更新模板

你可以把这个 repo 当 public template 维护，把自己的真实求职系统放在 private workspace。以后改进 skill 的通用逻辑时，只改 `skills/` 和 `docs/`；真实简历、申请队列、截图、PDF 都不要进 git。
