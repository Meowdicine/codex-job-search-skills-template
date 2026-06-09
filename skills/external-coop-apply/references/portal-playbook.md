# External Portal Playbook

Use only when a concrete employer portal is open or failing.

## Lever / Greenhouse

- Usually no account is needed.
- Fill ordinary fields, attach the approved upload-facing PDF, verify filename, and stop at final submit.
- Do not use `Apply with LinkedIn` unless explicitly approved.
- If resume parsing changes fields, correct obvious non-sensitive errors such as name, email, phone, location, company, LinkedIn, GitHub, and portfolio.
- If CAPTCHA appears, mark `captcha-verification-needed` and hand off to the user.

## Oracle Candidate Experience

- Typical flow: `Apply now` -> email -> terms -> identity verification -> code/link.
- Keep one live verification page. Codes may invalidate when the flow is reopened.
- Do not request repeated codes or retry aggressively after invalid-code/cooldown errors.
- Never log or repeat verification codes.

## Workday

- Avoid repeated failed logins.
- Try a stored isolated credential only when authorized.
- If rejected once, stop and mark `credential-reset-needed`.
- After login, verify uploaded resume version and replace stale PDFs when possible.

## Cloudflare / CAPTCHA

- Cloudflare, Turnstile, hCaptcha, reCAPTCHA, and browser trust pages are handoff gates.
- Let the user complete the challenge in a visible browser.
- Do not use stealth, CAPTCHA-solving services, fingerprint bypasses, or repeated automated refreshes.
- Reclaim the same tab/page after the user completes the challenge.

## Public Job Boards

- Prefer official employer pages for submission.
- Submit through a mirror only when the user explicitly approves that mirror path for the specific role.

## File Uploads

- Prefer direct browser-supported upload when available and reviewable.
- If the runtime cannot safely set files, copy/show the approved absolute path and stop at the upload control.
- Do not operate native file pickers through foreground automation unless the user explicitly asks in the current thread.
