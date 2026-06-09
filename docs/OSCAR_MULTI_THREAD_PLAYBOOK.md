# OSCAR 主控 + 多线程求职 Playbook

目标：一个主控 thread 负责排序、分配、合并状态；多个 worker thread 分别做 JD 提取、简历定制、外部 portal staging、搜索补充。这样可以并行，但不会让多个 Codex 同时乱改同一个申请。

## 线程角色

| Thread | 负责什么 | 不负责什么 |
|---|---|---|
| OSCAR Controller | 批次排序、posting IDs、状态总览、分配任务、合并结果、最终审批节奏 | 不深改每份简历、不同时操作多个 portal |
| Resume Worker | 单个 JD 的 ATS map、resume edits、truthfulness notes、PDF/layout QA | 不 final submit、不改全局队列状态 |
| Portal Worker | 外部 employer portal 填表、上传、CAPTCHA/2FA handoff、停在 review page | 不选择岗位、不改简历事实 |
| Search Worker | 找外部 public leads、去重、评分、写入候选队列 | 不登录 portal、不提交 |
| QA/Review Worker | 独立检查 package、hard gates、文件名、日志是否安全 | 不重写主工作流 |

## 主控 thread 的启动 prompt

```text
Use $oscarplus-coop-apply as the OSCAR Controller.

Read my private career-config.json and dashboard-data/job-hunting.json.
Build the next batch from these posting IDs: <paste IDs or say use queue>.
Rank by fit, deadline, salary, lane, and friction.

For each job, create or refresh a package and assign exactly one next action:
- resume-worker-needed
- portal-worker-needed
- manual-review
- ready-for-final-approval
- skip

Do not click final submit. Keep a controller ledger with package path, owner thread, status, blocker, and next action.
```

## Worker thread prompt: Resume

```text
Use $ats-resume-tailor.

Package path: <absolute package path>
JD source: <JD.md path or pasted JD>
Private config: <career-config.json path>

Produce fit-gate-verdict.md, keyword-map.md, truthfulness-notes.md, resume-change-summary.md, and submit-checklist.md.
Keep every claim supported by Resume-Summary.md or Resume-Material-Bank.md.
Do not submit or upload anything.
Return a concise handoff summary for the OSCAR Controller.
```

## Worker thread prompt: External Portal

```text
Use $external-coop-apply.

Package path: <absolute package path>
Official portal URL: <url>
Queue id: <job-hunting pipeline id>

Stage the application with the approved upload-facing PDF.
Use only ordinary approved profile defaults.
Stop for CAPTCHA, Cloudflare, non-email 2FA, OAuth, security questions, custom answers, or final submit.
Return current status, fields staged, document filename shown, blocker if any, and exact next action.
```

## Worker thread prompt: Search

```text
Use $external-coop-search.

Search scope: <roles, cities, term, companies>.
Read career-config.json and job-hunting.json.
Verify official company pages where possible.
Deduplicate before saving.
Save only useful new leads and return new IDs plus hard gates.
Do not create accounts, upload files, or submit applications.
```

## Handoff Contract

Every worker should report back to the controller with:

```text
Job id:
Company:
Role:
Package path:
Files changed:
Current status:
Blocker:
Next action:
Final submit clicked: no
Secrets logged: no
```

The controller then updates the ledger and, if needed, asks another worker to continue.

## File Ownership Rules

- Only the controller updates batch-level priority notes.
- Only one worker at a time edits one package folder.
- Resume worker owns package resume notes and resume source.
- Portal worker owns `approval-log.md`, `submit-checklist.md`, and portal status after upload begins.
- Search worker may append new leads to `job-hunting.json`, but should not rewrite unrelated entries.
- If two threads touch the same file, the controller decides which result wins before anyone continues.

## Practical Batch Pattern

1. Controller ranks 5-10 postings.
2. Controller creates package skeletons.
3. Resume workers prepare top 2-4 packages in parallel.
4. Controller reviews hard gates and chooses which packages deserve upload.
5. Portal workers stage one application each.
6. Controller collects statuses and asks the user for final approvals one by one.
7. After submission or skip, controller records final state and moves to the next batch.

## Approval Cadence

Do not compress final approval. A good rhythm:

- Approve target selection for high-priority postings.
- Approve fit/gate verdict before heavy tailoring.
- Approve final package before upload.
- Approve final submit only when the portal is ready and visible state is summarized.

The exact final question should name the portal, company, role, posting ID, and button label.

## Failure Recovery

- Duplicate tabs: worker reports visible tab cue and stops; controller decides whether to close or reuse.
- Portal CAPTCHA/Cloudflare: user completes it; same worker resumes if it can reclaim the page.
- Resume layout blocked: mark `layout-revise` or `chrome-plugin-blocked`; do not upload.
- Unclear hard gate: mark `manual-review`; do not polish around it.
- Custom answer appears: draft answer in package notes, wait for user approval.
