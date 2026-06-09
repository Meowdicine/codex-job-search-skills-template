---
name: data-center-coop-watch
description: Use when finding, monitoring, scoring, or saving external public data center, hyperscaler, cloud infrastructure, network operations, critical environment, facility operations, power/cooling, NOC, AI infrastructure, or paid trainee/co-op leads. Public-safe template version that relies on the candidate's private career config.
---

# Data Center Co-op Watch

## Overview

Find and triage public data-center-related leads without mixing them into university portal submission workflow. This skill handles discovery, scoring, hard-gate review, and local saving.

Use `$ats-resume-tailor` for concrete resume tailoring and `$external-coop-apply` for employer portal execution. Use `$oscarplus-coop-apply` only for university portal postings or upload/submission steps.

## Boundaries

- Do not log into job boards, bypass gated pages, scrape credentials, upload documents, or submit applications.
- Prefer official company pages. Use mirrors only for discovery; mark `manual-company-check`.
- Do not assume full-time, trainee, apprentice, or technician roles count as co-op. Mark `manual-review` until eligibility, hours, dates, pay, and employer documentation are clear.
- Save only useful or watch-worthy leads.
- Default to software/infrastructure adjacency first: cloud/platform, network automation, observability, monitoring, backend/internal tools, data platforms, AI infrastructure, and infrastructure testing.
- Promote pure hardware/facility roles only when student, intern, co-op, trainee, junior, entry-level, paid training, or recruiter-confirmed compatibility is plausible.

## Private Sources

Read from private `career-config.json`:

1. `paths.jobQueue`
2. `paths.resumeSystem`
3. `paths.resumeSummary`
4. `paths.jobLeadsDir`

Read `references/employer-watchlist.md` when the task mentions hyperscalers, cloud infrastructure, paid training, data centers, facility operations, critical environment, power, cooling, network operations, or infrastructure monitoring.

## Workflow

1. Establish scope.
   - Use term, geography, target roles, and preferred lanes from config unless the user overrides them.

2. De-duplicate.
   - Read queue IDs and existing digest rows.
   - Treat same company + similar title + same city as likely duplicate.

3. Search current public sources.
   - Official careers pages first.
   - Mirrors only for discovery or when official pages block indexing.
   - If current availability cannot be verified, mark `manual-company-check` or `watch-only`.

4. Hard-gate.
   - Mark `skip` for expired, clearly senior-only, unpaid, unrelated, or legally impossible roles.
   - Mark `manual-review` for unclear term dates, full-time labels, clearance, residency/citizenship, bilingual requirements, driver/vehicle, relocation, rotating shift, or heavy electrical/mechanical credentials.

5. Score:

```text
priority = resume_fit * 0.40 + co_op_legality * 0.25 + software_infra_fit * 0.15 + salary * 0.10 + city * 0.05 + brand_or_referral * 0.05 - friction
```

Caps:

- Hardware/facility roles requiring 2+ years, trade credentials, maintenance ownership, or deep rack/cabling cap at `3.4` unless student/trainee compatibility is explicit.
- Senior facility ownership, licensed trades, or project manager scope cap at `3.1` unless the user wants salary intelligence only.
- Software infrastructure co-ops can exceed `4.2` even when data-center-adjacent rather than physically in a data center.

Thresholds:

- `apply-now`: 4.2+ and no hard gate.
- `fit-check`: 3.7+ and details mostly clear.
- `manual-review`: high upside with unresolved gate.
- `lead-inbox`: useful watch target.
- `skip`: low fit, expired, or blocked.

## Resume Lane Selection

Use lanes from private config. Typical choices:

- `software-data`: cloud/devops, infrastructure DevOps, network automation, monitoring, observability, AI tools, backend, database, analytics, internal platforms.
- `industrial-automation-ot`: data center technician, critical environment intern, facility operations intern, power/cooling monitoring, BMS/BAS/EPMS data workflows, network hardware test automation.
- `domain-specialist`: energy, utilities, process systems, or other candidate-specific domain.

For concrete tailoring, invoke `$ats-resume-tailor`.

## Saving Contract

Append a lead object to the private queue only when new and useful:

```json
{
  "id": "public-<company>-<role-slug>-<location-or-requisition>-YYYYMMDD",
  "company": "",
  "role": "",
  "date": "YYYY-MM-DD",
  "status": "fit-check | manual-review | lead-inbox | watch-only | skip",
  "source": "public-company-page | public-job-board/manual-company-check",
  "sourceUrl": "",
  "fitScore": 4.1,
  "resumeVersion": "software-data",
  "hardGates": [],
  "feedback": "",
  "next": ""
}
```

## Output Contract

Report:

- what was saved and where
- top leads in priority order
- company, title, location, pay if known, status, lane, match reason, and hard gates
- which facts are from official pages versus mirrors
- soft infrastructure matches separately from hardware/facility exceptions
