---
name: external-coop-search
description: Use when finding, verifying, scoring, deduplicating, saving, and prioritizing public external co-op, internship, new-grad, or early-career leads outside the university portal. Stops at lead/package readiness and routes employer portal execution to external-coop-apply.
---

# External Co-op Search

## Overview

Find public external job leads, verify current availability where possible, score them against the candidate's private config, and save only useful new leads into the private job queue.

This skill owns discovery and prioritization, not employer-portal execution. Use `$ats-resume-tailor` for concrete resume packages, `$external-coop-apply` for accounts/login/upload/staging/final-submit handoff, and `$oscarplus-coop-apply` only for university portal records or submissions.

## Boundaries

- Do not operate employer portal accounts, login, credential retrieval, file upload, CAPTCHA/2FA handoff, or final submit from this skill.
- Do not browse or inspect credential stores, cookies, browser storage, or session files.
- Prefer official company careers pages. Use public mirrors only for discovery or when the official page is unavailable; mark mirror-only leads `manual-company-check`.
- Do not assume full-time, trainee, new-grad, or technician roles count as co-op. Mark `manual-review` until paid full-time duration, dates, and employer documentation are clear.
- Preserve existing queue data. Append useful new external leads only; do not rewrite, delete, or reorder unrelated entries.
- Use the candidate's preferred language from `career-config.json` for summaries.

## Private Sources

Read these from private `career-config.json`:

1. `paths.jobQueue`
2. `paths.resumeSystem`
3. `paths.resumeSummary`
4. `paths.jobLeadsDir`
5. optional job-search email policy, only if the user explicitly authorizes mailbox use in the current task

Load references only when relevant:

- `references/domains-software-data.md`
- `references/domains-ml-ai-data.md`
- `references/domains-data-center-infra.md`
- `references/domains-industrial-automation-ot.md`
- `references/domains-energy-utilities.md`
- `references/employer-watchlist.md`
- `references/search-queries.md`

## Workflow

1. Establish scope.
   - Default to the term, geography, target roles, and resume lanes in config.
   - If scope is missing, infer conservatively from the user's request and note assumptions.

2. De-duplicate before searching deeply.
   - Read existing queue IDs, source URLs, companies, roles, and statuses.
   - Treat same company + similar title + same city as likely duplicate.
   - Use `scripts/normalize_external_lead.ps1` for pasted leads or stable IDs.

3. Search and verify public sources.
   - Use official careers pages first.
   - Use public mirrors only to discover leads or fill missing details.
   - If availability cannot be verified on the official page, keep only as `manual-review`, `lead-inbox`, or `watch-only`.

4. Hard-gate before scoring.
   - Mark `skip` for expired, closed, senior-only, unpaid, unrelated, legally impossible, or clearly blocked roles.
   - Mark `manual-review` for unclear dates, full-time labels, work authorization, security clearance, citizenship/PR, language, relocation, driver/vehicle, heavy trade credentials, or mirror-only evidence.
   - Promote hardware/facility roles only when student, intern, co-op, trainee, junior, entry-level, or paid-training compatibility is plausible.

5. Score and classify.

```text
priority = resume_fit * 0.35 + co_op_legality * 0.25 + career_direction * 0.15 + salary * 0.10 + city * 0.05 + brand_or_referral * 0.10 - friction
```

Default thresholds:

- `apply-now`: 4.2 or higher and no hard gate.
- `fit-check`: 3.7 or higher with mostly clear details.
- `manual-review`: high upside but unresolved gate.
- `lead-inbox`: useful watch target, not ready.
- `watch-only`: interesting but not actionable.
- `skip`: blocked or low fit.

Use `scripts/score_external_leads.ps1` for local JSON scoring when useful.

6. Select resume lane.
   - Choose from `career-config.json.resumeLanes`.
   - For concrete resume editing, invoke `$ats-resume-tailor`; do not rewrite resume content inside this skill.

7. Save only useful new leads.
   - Append to `job-hunting.json.pipeline[]` only when the lead is new and useful.
   - Keep this object shape compatible:

```json
{
  "id": "public-<company>-<role-slug>-<location-or-requisition>-YYYYMMDD",
  "company": "",
  "role": "",
  "date": "YYYY-MM-DD",
  "status": "apply-now | fit-check | manual-review | lead-inbox | watch-only | skip",
  "source": "public-company-page | public-job-board/manual-company-check",
  "sourceUrl": "",
  "fitScore": 4.1,
  "resumeVersion": "software-data",
  "hardGates": [],
  "feedback": "",
  "next": ""
}
```

## External Apply Handoff

When a lead should move into execution, write `next` with:

- `$external-coop-apply`
- official portal URL
- recommended resume lane
- package readiness
- unresolved hard gates

Let `$external-coop-apply` handle accounts, credentials, portal fields, upload staging, CAPTCHA/Cloudflare/2FA handoff, approval logs, and final submit boundaries.

## Output Contract

Report:

- what was searched and which sources were official
- top leads in priority order
- company, title, location, pay if known, status, fit score, lane, URL, match reason, and hard gates
- saved path and new lead IDs, if saving
- clear separation between apply-ready, manual-review, watch-only, and skip
