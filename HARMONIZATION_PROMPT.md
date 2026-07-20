# Harmonization Prompt

Use this prompt for deliberate project-content harmonization with the recorded
AGIT Dev Template source and for an internal consistency review.

Invoke it with `Read and execute HARMONIZATION_PROMPT.md.`

## Prompt

```text
Perform a structured content harmonization of BootProfile Switcher.

Maintainer intent, project architecture and project Decision Records remain
authoritative. Never copy template changes blindly.

1. Read CODEX.md and ChatGPT.md.
2. Read PROJECT_CONTEXT.md, including template lineage, deviations, roadmap,
   sensitive-input boundaries and human code readership.
3. Read README.md, VERSION, current CHANGELOG.md sections, DOCUMENTATION.md,
   REPOSITORY.md, PHILOSOPHY.md, relevant Decision Records and active code,
   tests, configuration and user documentation.
4. Inspect branch, working tree, recent commits, relevant tags and changes with
   read-only Git commands. Preserve uncommitted work.
5. Apply sensitive-input, fixture, generated-artifact and publication rules
   before opening or validating project materials.

Use the exact source template and last recorded harmonization baseline. Verify
the latest template baseline through authoritative read-only evidence when it
is available and permitted. If freshness or the baseline cannot be verified,
stop external comparison at metadata level and request the missing evidence.
Never modify the source-template repository during harmonization.

Classify material template changes as adopt, adapt, reject or defer. Record the
rationale, affected project files and governing decisions or deviations.
Present conflicts as numbered maintainer decisions before editing and stop at
project conflicts.

Perform an internal consistency pass across project identity, versions,
roadmap, architecture, implementation, configuration, fixtures, documentation,
deployment, lifecycle restoration, code readability, sensitive artifacts and
actual validation evidence. Review whether the roadmap still fits project
intent and known constraints without inventing product direction.

Before edits, report:

1. repository role and project/template baselines
2. template comparison matrix and decisions needed
3. code, test, documentation and repository findings
4. roadmap findings and proposed content changes
5. validation, security and disclosure checks
6. proposed edit and commit-sized work sequence
7. collaboration observations deferred to a retrospective
8. blocking maintainer decisions

Apply findings only when my instruction authorizes implementation and only
after reporting. After approved edits, validate affected behavior and
documentation. Update the harmonization baseline and deviations in
PROJECT_CONTEXT.md only after integration succeeds.

Staging and unstaging do not require a control word, but perform them only when
I specifically request the index action or authorize the corresponding commit.
Preserve existing staged selections and unrelated changes.

Do not perform a protected Git action unless I instruct you to perform that
specific action with `explicit`, `explicitly` or the German word family
`explizit`.
```
