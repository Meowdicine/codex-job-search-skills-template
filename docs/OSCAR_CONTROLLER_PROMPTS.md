# OSCAR 主控多线程 Prompt 模板

下面这些 prompt 是给 Codex 多线程求职用的 public-safe 版本。把真实路径、posting ID、公司名、portal URL 填到自己的 private workspace 里，不要写进公开 repo。

## 主控 Thread：总入口 Prompt

```text
Use $oscarplus-coop-apply as the OSCAR Controller.

Private config: <absolute path to career-config.json>
Queue path: <absolute path to job-hunting.json>
Mode: controller

Goal:
Build the next application batch, rank postings, create or refresh application packages, assign worker threads, collect handoffs, and stop before every final submit.

Inputs:
- Posting IDs or queue filter: <paste IDs, companies, deadline range, or say "use queue">
- Current priority: <software/data/cloud/platform, external portal, deadline rescue, etc.>
- Batch size: <for example 5-10>

Rules:
- Do not click final submit.
- Do not inspect or store portal credentials, cookies, browser storage, passwords, verification codes, or session files.
- Create or refresh package skeletons before assigning workers.
- Give each worker exactly one package and one next action.
- Keep a controller ledger with:
  Job id | Company | Role | Package path | Owner thread | Status | Blocker | Next action | Last verified
- Only one worker may edit a package at a time.
- If two workers touch the same file, stop and reconcile before continuing.
- Route resume analysis to $ats-resume-tailor.
- Route external employer portal execution to $external-coop-apply.

For each job, assign exactly one next action:
- resume-worker-needed
- portal-worker-needed
- search-worker-needed
- qa-worker-needed
- manual-review
- ready-for-final-approval
- skip

Return:
1. ranked batch table
2. package paths
3. worker assignment prompts
4. approval checkpoints
5. current blockers
6. next action for the user
```

## Resume Worker Prompt

```text
Use $ats-resume-tailor.

Private config: <absolute path to career-config.json>
Package path: <absolute package path>
JD source: <JD.md path or pasted JD>
Resume lane hint: <software-data | industrial-automation-ot | domain-specific | let skill choose>

Task:
Prepare this package's resume analysis and edits only.

Produce or update:
- fit-gate-verdict.md
- keyword-map.md
- truthfulness-notes.md
- resume-change-summary.md
- submit-checklist.md

Rules:
- Keep every claim supported by private resume sources or user-provided facts.
- Do not invent metrics, tools, dates, publications, employer relationships, or credentials.
- Do not upload, submit, or operate a portal.
- Stop if a hard gate is not resume-fixable.

Return the handoff:
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

## Portal Worker Prompt

```text
Use $external-coop-apply.

Private config: <absolute path to career-config.json>
Package path: <absolute package path>
Queue id: <job queue id>
Official portal URL: <url>
Mode: upload-stage

Task:
Stage the employer portal or external application with approved documents and ordinary approved profile defaults.

Rules:
- Upload only the approved upload-facing PDF and required approved documents.
- Stop for CAPTCHA, Cloudflare, non-email 2FA, OAuth, account linking, saved-password prompts, security questions, custom answers, warnings, or changed required documents.
- Do not click final submit without explicit current-thread approval.
- Do not log passwords, verification codes, cookies, session tokens, protected-class answers, or full private address strings.
- If file upload needs the native file picker, copy/show the approved absolute file path and hand off only that step.
- After manual upload, verify the visible uploaded filename/state before continuing.

Return the handoff:
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

## Search Worker Prompt

```text
Use $external-coop-search.

Private config: <absolute path to career-config.json>
Search scope: <roles, cities, term, companies, public sources>

Task:
Find current public leads, verify official company pages where possible, deduplicate against the private queue, score useful leads, and save only useful new entries.

Rules:
- Do not create accounts, log in, upload files, solve CAPTCHA, or submit applications.
- Prefer official company pages; mark mirror-only leads as manual-company-check.
- Mark unclear full-time/trainee/co-op eligibility as manual-review.

Return:
- searched sources
- saved lead IDs
- top apply-now / fit-check leads
- manual-review gates
- skipped duplicates
- recommended next action for the controller
```

## QA Worker Prompt

```text
Act as a package QA worker for the OSCAR Controller.

Private config: <absolute path to career-config.json>
Package path: <absolute package path>

Check:
- hard gates are documented
- JD keywords are mapped truthfully
- resume-change-summary names baseline and unsupported JD terms not forced
- submit-checklist covers file name, one-page/layout status, selectable PDF, and blockers
- approval-log says final submit was not clicked unless approved
- no passwords, verification codes, cookies, tokens, protected-class answers, or full private addresses are logged

Do not rewrite the package unless the controller asks. Return findings and next action.
```

## Worker Handoff Format

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
