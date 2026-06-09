---
name: external-coop-apply
description: Use when staging, continuing, or recovering public external co-op, internship, new-grad, or early-career applications on employer portals such as Lever, Greenhouse, Workday, Oracle Candidate Experience, Jobvite, Paylocity, company portals, and public job boards. Handles ordinary form fields, approved document upload, safe credential handoff, CAPTCHA/2FA blockers, status updates, and strict stop-before-final-submit behavior.
---

# External Co-op Apply

## Overview

Stage external applications after a lead has been selected by `$external-coop-search` and a resume package has been prepared by `$ats-resume-tailor`.

This skill owns employer-portal execution, blocker recovery, document upload, approval logging, and final-submit handoff. Do not use it for university-portal-native submissions; route those through `$oscarplus-coop-apply`.

## Non-Negotiable Boundaries

- Never click final `Submit`, `Submit Application`, `Send application`, `Complete application`, `Apply with LinkedIn`, OAuth grant, account-linking, or irreversible consent controls without explicit approval in the current thread.
- Use only the account/login/credential authorization specified by the user in the current task or `career-config.json.applicationSafety`.
- Do not print, summarize, screenshot, store, or log passwords, verification codes, recovery codes, cookies, session tokens, browser storage, saved-password contents, or full private addresses.
- Store external job-site passwords only in an approved encrypted password manager or the optional local vault script. Never write plaintext credentials to git, package notes, queue JSON, screenshots, command output, or chat.
- Do not reuse university portal, school SSO, personal banking, or unrelated private credentials for external employer accounts.
- Stop at CAPTCHA, Cloudflare, non-email 2FA, security questions, OAuth/account linking, saved-password-manager prompts, or unusual consent prompts for user handoff.
- Upload only approved documents from the target private package.
- Do not infer protected-class, demographic, disability, veteran, Indigenous, gender, ethnicity, or sponsorship answers. Use only explicit stored defaults such as `Prefer not to answer`.

## Private Sources

Read these from private `career-config.json`:

1. `paths.jobQueue`
2. target package under `paths.externalApplicationsDir`
3. package `submit-checklist.md`, `approval-log.md`, `resume.lock.json`, and upload-facing PDF under `submission/`
4. `paths.externalApplicationProfile`, only for ordinary non-secret defaults
5. `paths.applicationFormDefaults`, only for ordinary non-secret defaults
6. the live official employer portal

Load references only when needed:

- `references/portal-playbook.md`
- `references/status-contract.md`
- `references/work-email-policy.md`

## Workflow

1. Confirm target and package.
   - Identify queue ID, company, role, official source URL, status, fit score, and resume lane.
   - Verify a tailored package exists and has an approved upload-facing PDF.
   - Require `resume.lock.json` for active upload/staging. If missing, create or request it before upload.
   - If tailoring or QA is incomplete, stop and route to `$ats-resume-tailor`.

2. Open the official portal.
   - Prefer official company pages.
   - Use mirrors only with explicit user approval when no official path exists.
   - Prefer browser/DOM upload APIs when reliable and reviewable. Otherwise prepare a manual upload handoff.

3. Handle account/login.
   - Reuse only isolated job-search credentials if authorized.
   - If account creation is allowed, use the approved external job-search identity and store generated passwords only in an encrypted password manager.
   - Accept only required candidate-account terms/privacy notices needed to continue.
   - Stop at any verification, CAPTCHA, OAuth, account linking, or saved-password prompt outside the current authorization.

4. Fill ordinary fields.
   - Allowed defaults may include legal name, work email, phone, current location, school, degree, program, graduation/work term, LinkedIn, GitHub, portfolio, and work authorization when explicitly stored.
   - Do not fill custom free-text answers without review unless the answer is purely factual and already present in the package.

5. Upload and stage documents.
   - Upload the locked package PDF and any approved transcript/cover letter requested by the portal.
   - Verify visible filename, required-document checklist, and resume-parse/autofill changes.
   - If upload triggers CAPTCHA/Cloudflare/verification, stop and mark the correct blocker.

6. Stop before final submit.
   - On a review page or submit-ready form, report the exact non-secret state and ask for explicit approval.
   - The final prompt must name the company, role, portal, and visible final button label.
   - If the user approves, click only that final button, then capture non-secret confirmation text/number when visible.

7. Record non-secret state.
   - Update package `approval-log.md` and `submit-checklist.md`.
   - Update `job-hunting.json` with `scripts/update_external_apply_status.ps1` when possible.
   - Never log secrets, protected-class answers, or full private address strings.

## Status Values

- `package-needed`
- `layout-pass`
- `credential-needed`
- `credential-reset-needed`
- `email-verification-needed`
- `email-verification-cooldown`
- `captcha-verification-needed`
- `browser-verification-needed`
- `upload-staged`
- `final-approval-needed`
- `submitted-user-approved`
- `submitted-user-completed`
- `manual-review`
- `skip`

See `references/status-contract.md` for field-level details.

## Output Contract

Report:

- company, role, source URL, package path, resume PDF path, and current status
- fields/documents staged
- visible uploaded filename, when available
- blockers
- what was recorded locally
- next single action needed from the user
- whether final submit was clicked, which should be `no` unless explicitly approved in the current thread
