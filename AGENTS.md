# AGENTS.md

Resident contract for BootProfile Switcher.

Read CODEX.md before tools or edits and ChatGPT.md for the retained project
collaboration model. Preserve the repository, staging, local work and all
Windows boot, account, service, registry and rollback safeguards.
Protected Git actions require explicit repository-specific authority.
Within `commit-changes` or `commit-milestone`, repository-specific explicit
commit authorization includes the commit and its normal push to the verified
existing upstream unless the maintainer excludes push. Skill invocation alone
grants no Git authority. Force-push, other refs, remote changes, tags and release
publication remain outside this bundle; other protected actions still need
separate authority. This changes neither content-access nor publication rules.
Do not run host-changing scripts as a validation shortcut.
Read docs/decisions/ and affected domain guidance before design.
Skill edits use scripts/Test-CodexSkill.ps1 and VALIDATION.md.

## Selected template workflows

Use the retained skills for ongoing work: start-task and handoff-task for
bounded tasks; explicitly invoke review-project, check-consistency,
sync-template and perform-retrospective for their specialized outcomes.
Reuse-fixes consults only this project's confirmed corrections. If no local
record exists, diagnose within current authority and retain only a verified
project-local fix; never copy another repository's incidents.
Initialization is complete: do not rerun it, recreate removed creation skills
or substitute upstream context, roadmap, decisions, versions or licensing.
Local access, domain and protected-action rules remain authoritative.
See [TEMPLATE_SYNC.md](TEMPLATE_SYNC.md) for the selected source and deviations.
The bounded commit-and-push decision is [PDR-0002](docs/decisions/PDR-0002-bounded-commit-and-push-authority.md).
