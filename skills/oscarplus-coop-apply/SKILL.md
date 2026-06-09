---
name: oscarplus-coop-apply
description: Use as the main controller for university co-op portal applications, OSCARplus-style posting IDs, local job queues, application package creation, resume-tailoring handoffs, upload staging, multi-thread coordination, and strict final-submit approval.
---

# OSCARplus Co-op Apply

## Purpose

Prepare university co-op portal applications end to end without losing control of high-consequence actions. This skill coordinates priority sorting, posting extraction, resume tailoring, PDF/layout QA, package creation, upload staging, multi-thread handoffs, and final approval.

This skill is an orchestrator. Do not duplicate resume-tailoring logic from `$ats-resume-tailor`; route JD analysis, ATS keywords, truthfulness checks, and resume edits to that skill.

## Non-Negotiable Boundaries

- Never submit a university portal application without explicit user approval in the current thread.
- Never store, request, inspect, or infer university portal credentials, school SSO credentials, cookies, local storage, passwords, or session files.
- Do not bypass CAPTCHA, 2FA, login checks, SSO checks, or site access controls.
- If the user authorizes login navigation, it is allowed to click the normal portal login entry. Stop before password, OTP, CAPTCHA, authenticator, consent, or security prompt steps that require user action.
- Use portal browsing only for authorized posting extraction, document upload staging, review-page handoff, and final-submit handoff.
- If a portal posting points to an external employer site, capture portal evidence and required documents, then route employer-side account/login/upload/staging work to `$external-coop-apply`.
- Avoid duplicate tabs. Reuse the newest matching tab or current controlled tab when possible; if duplicates make state ambiguous, stop and ask for tab cleanup or a unique fresh tab.
- Do not repeatedly fight native file choosers. If direct browser upload is unavailable, copy/show the approved file path and let the user perform the file-picker step.
- Stop if the portal asks custom questions, rejects a file, changes required documents, or shows a warning.
- The final action must be one of `approve-to-submit`, `revise`, or `skip`. There is no fully automatic final-submission mode.

## Operating Modes

- `dry-run`: rank postings, create skeletons, and identify next actions; do not upload or submit.
- `prepare`: extract JD, tailor materials, run layout QA, and stop with package approval request.
- `upload-stage`: stage approved files and stop on review/submit page.
- `submit-handoff`: ask for final approval and click submit only after approval in the current thread.
- `controller`: manage a batch and hand off jobs to worker threads. See `docs/OSCAR_MULTI_THREAD_PLAYBOOK.md` in the template repo.

## Private Sources

Read from private `career-config.json`:

1. current user-provided posting IDs, company names, deadlines, salary, or priorities
2. `paths.jobQueue`
3. existing packages under `paths.oscarApplicationsDir`
4. `paths.applicationFormDefaults`, only for ordinary non-secret defaults
5. live portal pages, only when the user is authorized
6. `$ats-resume-tailor` private resume sources

## Priority Model

Use deterministic sorting before opening many pages:

- `fit`: existing score or rubric fit.
- `salary`: visible hourly pay/stipend; unknown salary is neutral.
- `deadline`: earlier deadlines get a stronger boost.
- `lane`: priority-apply > backup-apply > interview-practice.
- `friction`: missing docs, cover letter, custom questions, work authorization ambiguity, location friction, or hard gates.

Recommended weight:

```text
priority = fit * 0.45 + salary * 0.20 + deadline_urgency * 0.25 + lane_boost * 0.10 - friction
```

Deadline overrides:

- Due today or tomorrow: raise to the current batch unless clearly skip.
- Expired or same-day deadline already passed: mark `manual-check-required`.
- Hard gate failure: mark `manual-review` or `skip` even when the score is high.

Use `scripts/score_oscar_queue.ps1` to rank a local queue when useful.

## Multi-Thread Controller Rules

When the user asks to run multiple Codex threads:

1. Act as the controller thread.
2. Create or refresh package skeletons before assigning work.
3. Give each worker exactly one package and one next action.
4. Require each worker to return the handoff contract:

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

5. Only one worker may edit a package at a time.
6. The controller owns batch priority, final decisions, and final-submit approval cadence.
7. If two workers touch the same file, stop and reconcile before continuing.

## Workflow

1. Build the candidate batch.
   - Read user-provided IDs first; otherwise read the private queue.
   - Sort by fit, salary, deadline, lane, and friction.
   - Present the next batch with priority class, deadline, and approval checkpoints.

2. Create or refresh each package.
   - Use `scripts/init_application_package.ps1`.
   - Use a folder under `paths.oscarApplicationsDir`.

3. Extract the posting.
   - Use authorized browser access or pasted content.
   - Save visible JD text to `JD.md`.
   - Save metadata to `posting.json` when available: posting ID, company, role, deadline, salary, location, term, required documents, source URL, extraction timestamp.
   - If access fails, mark `manual-check-required` and continue only with pasted/local content.

4. Invoke `$ats-resume-tailor`.
   - Require fit/gate verdict, keyword map, resume change summary, truthfulness notes, resume edit plan, and submit checklist.
   - Write outputs into package files.

5. Produce materials.
   - Use the selected resume lane from config.
   - Keep resumes truth-bound, text-selectable, and layout-checked.
   - Keep employer-facing filenames short.
   - If a cover letter, transcript, or extra document is required, flag for approval.

6. Stage upload only after package approval.
   - Upload only approved files.
   - If final submission happens on an external employer portal, route to `$external-coop-apply`.
   - For manual upload handoff, give the exact upload control/page, approved file path, and next user action.
   - After manual upload, verify visible uploaded filename before continuing.
   - Stop on the review/submit page and ask for final approval.

7. Final submission.
   - Ask explicitly whether the user approves final submission for the exact posting.
   - Only click submit after current-thread approval.
   - Save non-secret confirmation text/screenshot and update local package status.

## Package Contract

Each package should contain:

```text
<postingId>-<company-slug>-<role-slug>\
  posting.json
  JD.md
  priority.json
  fit-gate-verdict.md
  keyword-map.md
  resume-change-summary.md
  truthfulness-notes.md
  submit-checklist.md
  prep-notes.md
  approval-log.md
  resume\
    source.*
    archive\
  cover-letter\
  layout-qa\
  chrome-evidence\
  submission\
```

## Status Values

- `queued`
- `jd-extracted`
- `tailored`
- `layout-pass`
- `layout-revise`
- `package-approved`
- `manual-upload-needed`
- `upload-staged`
- `final-approval-needed`
- `submitted`
- `manual-review`
- `skip`

## User-Facing Response Contract

Report:

- current batch and priority order
- extracted posting facts and missing details
- resume lane and PDF/layout status
- main resume changes and unsupported JD terms not forced
- checkpoints waiting for approval
- exact private package paths for completed materials
- whether final submit was clicked
