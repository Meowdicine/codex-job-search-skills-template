# Publication Checklist

Run this before making the repo public.

## Must Be Absent

- Real candidate name, email, phone, student number, school account, or private address.
- Real resume, cover letter, transcript, PDF, DOCX, TEX, screenshots, or application package.
- Real `job-hunting.json` queue.
- Portal credentials, password vault files, cookies, browser profiles, session storage, OAuth tokens, API keys, or verification codes.
- Local Codex API configuration files such as `.codex/auth.json` and `.codex/config.toml`.
- Absolute private paths such as a real OneDrive, Google Drive, Dropbox, or home directory.
- Employer portal confirmation screenshots that include personal data.

## Safe To Include

- Generic skill instructions.
- Placeholder config examples.
- Public job-search heuristics.
- Scripts that do not contain secrets and default to user-provided paths.
- Example JSON with fake companies and fake IDs.

## Suggested Scan

From the repository root:

```powershell
rg -n -i "YOUR_|candidate@example.com|password|secret|token|cookie|session|verification code|private key|BEGIN OPENSSH|BEGIN RSA"
rg -n -i "real-name|real-email|student-number|home-address|phone-number"
rg -n -i "C:\\Users\\|D:\\|OneDrive|Google Drive|Dropbox"
```

Placeholders are expected. Real values are not.

Also inspect `git status --ignored` and confirm generated artifacts are ignored before the first public push.
