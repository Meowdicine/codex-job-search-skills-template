---
name: ats-resume-tailor
description: Use when tailoring a candidate's resume, CV, cover letter, or application package to a specific job posting. Performs ATS keyword extraction, hard-gate review, truthfulness checks, resume lane selection, and submit-ready package notes using the candidate's private career config and resume sources.
---

# ATS Resume Tailor

## Purpose

Tailor a resume for one concrete job posting quickly, truthfully, and ATS-readably. Optimize for recruiter search and human review, not abstract ATS scores.

## Configuration

Before editing anything, locate the candidate's private `career-config.json`. If the user does not provide a path, search the current workspace for it or ask for the private career workspace root.

Use only private files referenced by that config:

- `paths.resumeSystem`
- `paths.resumeSummary`
- `paths.resumeMaterialBank`
- `paths.resumeVariantsDir`
- the selected resume lane's `baselineSource`
- the target application package, when provided

Never assume the public template repo contains real resume facts.

Read `references/resume-source-map.md` when selecting a lane or checking claim boundaries. Read `references/ats-customization-guide.md` for keyword extraction and final QA.

## Workflow

1. Intake the posting.
   - If the user provides a URL, verify the current public posting page when possible.
   - If the posting is gated, use pasted content and mark missing details as `manual-check-required`.
   - Do not request or inspect credentials.

2. Identify hard gates before polishing.
   - Work authorization, co-op/intern term, location, degree/program, required years, clearance, required certifications, language, relocation, and must-have technologies.
   - If a gate is not resume-fixable, say so plainly and recommend `manual-review` or `skip`.

3. Select the closest resume lane from `career-config.json`.
   - Prefer the lane that is already evidence-supported.
   - Do not create a new lane unless the user asks or the existing lanes cannot represent the role truthfully.

4. Extract ATS terms.
   - Exact target title.
   - 5-15 exact JD phrases worth reusing verbatim where truthful.
   - 10-30 hard skills for the skills section, prioritized by JD importance.
   - Domain/company words that should appear naturally in summary or bullets.

5. Rewrite only the useful parts.
   - Default to light, baseline-preserving tailoring.
   - Prioritize target title, summary, skills ordering, and strongest matched bullets.
   - Preserve the baseline's section order and experience inventory unless the JD gives a concrete reason.

6. Keep every claim evidence-bound.
   - Do not invent metrics, tools, responsibilities, dates, employment relationships, publications, patents, or credentials.
   - Treat prior employer-specific resume variants as contaminated unless the fact is also supported by the base resume sources.

7. Validate and stop tuning.
   - The goal is a submit-ready application, not endless wording polish.

## Resume And PDF Defaults

- Keep employer-facing filenames short and human, for example `Candidate_Resume.pdf` or the `candidate.uploadFileStem` from config.
- Do not include company names, posting IDs, full role titles, dates, `ATS`, `tailored`, or long keyword strings in upload-facing filenames.
- Keep verbose archive names only inside the private application package.
- Prefer the candidate's proven resume template before creating a new format.
- Keep one-page co-op/intern resumes text-selectable and visually full unless the user explicitly requests a CV.
- If the final resume depends on Overleaf or another web editor, use an authorized browser/plugin workflow and stop if the user is not logged in or the browser cannot safely export.
- Do not use foreground desktop automation, native file-picker automation, or cursor movement for resume export unless the user explicitly requests that fallback in the current thread.

## Writing Rules

- Use the JD's exact wording for ATS-critical nouns and phrases when the claim is true.
- Put keywords in headline/summary, skills, and experience/project bullets.
- Keep skills mostly hard skills and technologies.
- Avoid generic AI resume phrases, unsupported numbers, inflated achievements, and repeated buzzword stuffing.
- Keep bullets line-efficient, but never cut important truthful evidence merely for keyword stuffing.
- Lead with plain-English project names and employer-relevant outcomes; put niche acronyms only where they add credibility.

## Output Contract

For a specific job, return or write these package artifacts:

- `fit-gate-verdict.md`: lane, hard gates, missing details, and whether tailoring is worthwhile.
- `keyword-map.md`: exact JD terms and where they appear in the resume.
- `resume-change-summary.md`: baseline file, optimization level, changed title/summary/skills/bullets, unchanged sections, and unsupported JD terms not forced.
- `truthfulness-notes.md`: unsupported or risky claims removed, softened, or needing confirmation.
- `submit-checklist.md`: title match, hard skills, copied JD phrases, selectable PDF, one-page/layout status, file name, and final blockers.

Use the user's preferred language from config for explanations. Preserve exact JD phrases, resume lines, job titles, company names, technologies, filenames, and local paths in their original language.
