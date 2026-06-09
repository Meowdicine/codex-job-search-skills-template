# External Apply Status Contract

Use these statuses in the private queue for external application execution.

## Core Fields

Keep existing queue object fields:

```json
{
  "id": "",
  "company": "",
  "role": "",
  "date": "YYYY-MM-DD",
  "status": "",
  "source": "public-company-page",
  "sourceUrl": "",
  "fitScore": 4.1,
  "resumeVersion": "software-data",
  "hardGates": [],
  "feedback": "",
  "next": ""
}
```

Do not delete, reorder, or overwrite unrelated entries.

## Apply Statuses

- `package-needed`: resume/application package is missing.
- `layout-pass`: package and upload-facing PDF are ready.
- `credential-needed`: portal requires account/login setup.
- `credential-reset-needed`: stored credential failed or account may be locked.
- `email-verification-needed`: waiting for email verification or user input on one live page.
- `email-verification-cooldown`: portal rate-limited code attempts.
- `captcha-verification-needed`: CAPTCHA/hCaptcha/reCAPTCHA/Turnstile requires user completion.
- `browser-verification-needed`: Cloudflare/browser verification requires user completion.
- `upload-staged`: document upload is complete, but review page is not reached.
- `final-approval-needed`: all required fields/documents are staged and final submit is next.
- `submitted-user-approved`: Codex clicked final submit after explicit current-thread approval.
- `submitted-user-completed`: user submitted manually outside Codex.
- `manual-review`: legality/path/custom-answer/hard-gate uncertainty remains.
- `skip`: do not apply unless facts change.

## Local Artifacts

For every active external application package, maintain:

- `JD.md`
- `fit-gate-verdict.md`
- `keyword-map.md`
- `truthfulness-notes.md`
- `resume-change-summary.md`
- `submit-checklist.md`
- `approval-log.md`
- `resume.lock.json`
- upload-facing PDF under `submission/`

## Log Rules

- Record non-secret events only: page reached, fields filled, filename staged, blocker shown, confirmation received.
- Do not record passwords, verification codes, cookies, full private address strings, session tokens, protected-class answers, or screenshots that reveal secrets.
- Record `Codex did not click final submit` unless final submit was explicitly approved and completed.
