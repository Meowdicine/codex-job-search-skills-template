# Resume Source Map

Use this reference to choose the correct resume lane and preserve claim boundaries.

## Expected Private Sources

The public template does not include real resume evidence. Read these from the private `career-config.json`:

- `paths.resumeSystem`: operating workflow, output rules, variants, and top proof bank.
- `paths.resumeSummary`: compact canonical resume facts.
- `paths.resumeMaterialBank`: broader bullet and evidence library.
- `paths.resumeVariantsDir`: role-specific resume lanes.
- `resumeLanes[].baselineSource`: baseline source for a lane.

## Resume Lane Pattern

Common lanes:

- `software-data`: software engineering, data engineering, backend, cloud, DevOps, QA automation, internal tools, dashboards, analytics, AI tooling.
- `industrial-automation-ot`: automation, controls-adjacent software, manufacturing systems, utility technology, network/hardware test automation.
- `domain-specialist`: a candidate-specific domain such as energy, healthcare, finance, research, public sector, infrastructure, or product/design.

The candidate should customize these in private config.

## Claim Boundaries

- A tool can be used in a tailored resume only when it appears in a baseline source, material bank, user-provided evidence, or the user explicitly confirms it.
- A metric can be used only when the source gives the number or the user confirms it.
- A prior employer-specific variant should not leak its keywords into another application unless the original facts support them.
- Education, work dates, legal status, certifications, publications, and awards need exact support.

## Upload-Facing Naming

Use short, ordinary names:

- `Candidate_Resume.pdf`
- `Candidate_Resume_Coop.pdf`
- `Candidate_Resume_Data.pdf`
- `Candidate_Resume_Software.pdf`

Avoid company names, posting IDs, long role names, dates, `ATS`, `tailored`, and `final` in employer-visible filenames.
