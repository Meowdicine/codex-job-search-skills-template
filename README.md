# Codex Job Search Skills Template

Public-safe Codex skills for running a structured co-op, internship, or early-career job search.

This repository is a template. It intentionally contains no real candidate name, email, school account, resume, application package, portal credential, browser cookie, or local path from the original private setup.

## What Is Included

- `skills/ats-resume-tailor`: tailor a resume to a concrete job posting with ATS keywords and truthfulness checks.
- `skills/external-coop-search`: find, verify, score, deduplicate, and save public external job leads.
- `skills/external-coop-apply`: stage external employer portal applications and stop before final submit.
- `skills/oscarplus-coop-apply`: main controller for university co-op portal batches, OSCARplus-style posting IDs, packages, and approvals.
- `skills/data-center-coop-watch`: optional focused monitor for cloud infrastructure, data center, network, and facility-adjacent leads.
- `config/career-config.example.json`: private configuration schema. Copy it outside the public repo before filling it in.
- `docs/USAGE.md`: setup and daily workflow.
- `docs/OSCAR_MULTI_THREAD_PLAYBOOK.md`: how to run one main controller thread plus worker Codex threads.
- `docs/GITHUB_SHARING.md`: how to publish or share the template safely.
- `docs/PUBLICATION_CHECKLIST.md`: privacy checklist before publishing or sharing.

## Quick Install

1. Clone or download this repository.
2. Copy the folders under `skills/` into your Codex skills directory:

```powershell
$repo = "PATH_TO_REPO\codex-job-search-skills-template"
$skillsHome = "$env:USERPROFILE\.codex\skills"
New-Item -ItemType Directory -Force -Path $skillsHome | Out-Null
Copy-Item -Recurse -Force "$repo\skills\*" $skillsHome
```

3. Copy `config/career-config.example.json` to a private career workspace as `career-config.json`, then fill in your real paths and preferences there.
4. Create the private files named in the config, especially `Resume-Summary.md`, `Resume-Material-Bank.md`, and `dashboard-data/job-hunting.json`.
5. Start a new Codex thread and invoke a skill by name, for example:

```text
Use $oscarplus-coop-apply as the main controller. Read my private career-config.json, rank these posting IDs, create packages, route resume tailoring to $ats-resume-tailor, and stop before every final submit.
```

## Safety Model

These skills are designed around three rules:

- Final application submission always needs explicit approval in the current thread.
- Passwords, verification codes, cookies, session tokens, protected-class answers, and private address details must not be logged.
- Public repo files stay generic. Real resumes, emails, queue data, packages, and credentials live outside git.

## Suggested Repository Layout For Real Use

Keep this public template separate from your private career workspace:

```text
public-template-repo\
  skills\
  config\career-config.example.json
  docs\

private-career-workspace\
  career-config.json
  Resume-Summary.md
  Resume-Material-Bank.md
  Resume-Variants\
  dashboard-data\job-hunting.json
  Applications\
  Job-Leads\
```

The public repo is reusable machinery. The private workspace is the candidate's actual life. Keep those two worlds politely separated.
