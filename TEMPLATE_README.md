# BootProfile Switcher: Template Guide

> [!NOTE]
> **AI Collaboration**
> This guide describes adapted inherited workflows and conventions.
> Project rules and decisions remain authoritative; the collaboration model
> is documented in [COLLABORATION.md](COLLABORATION.md).

[Deutsche Anleitung](TEMPLATE_README.de.md) · [Project overview](README.md)

## Origin and scope

Adapted from AI Dev Template, reviewed at commit `d782a842cc5733d34c60a6bce39ddca5a65a9b64`. Guide adoption
was separately selected for this existing project.
[PROJECT_CONTEXT.md](PROJECT_CONTEXT.md) and [TEMPLATE_SYNC.md](TEMPLATE_SYNC.md)
record verified provenance, selection and deviations. This guide is not a
competing policy source: AGENTS.md, local domain rules and accepted Decision
Records govern actual work. Initialization is complete; removed creation
skills, template backlogs and executable setup instructions are not restored.

## Current operating contract

AGENTS.md is the resident entry point; COLLABORATION.md defines the current
maintainer/assistant model. Use start-task for a bounded task and handoff-task
for durable continuation. Read only relevant domain guidance and reuse current
evidence while its inputs are unchanged. Review, consistency, synchronization,
retrospective and milestone closure are separately selected workflows.
grill-me/grilling require explicit opt-in. Initialization is complete; retained
setup documents preserve provenance; retired skill aliases are absent. Domain safeguards and
separate access, transmission, Git and publication decisions remain binding.

## Core Principle

The maintainer owns the project direction, architecture and release decisions. The assistant may help design, implement, test, document and review changes, but must preserve maintainer authority, make assumptions and limitations visible and never simulate completed code, validation, commits or files.

The repository is the authoritative engineering state. Code and documentation should be understandable to future maintainers without private chat history, and a change is not complete merely because it worked once.

## Collaboration Skills

Skills are scoped workflows in `.agents/skills/`. They guide
the agent through a particular task and load the relevant repository guidance.
Invoke a skill in chat with `$skill-name`, for example
`$review-project`. The linked skill files describe each full workflow.

- **Agent or explicit:** The agent may select the skill when the task fits;
  you can also invoke it directly.
- **Explicit:** The skill needs a deliberate invocation or explicit maintainer
  selection. An agent suggestion does not activate it.

Selecting a skill grants no additional permission for protected Git actions,
installation, external transmission or publication. Local access and domain
rules apply to every workflow.



`reuse-fixes` reads and updates only this repository's error knowledge. It does
not collect lessons across repositories or maintain global memory.
Active fixes use 4–8 lines per case in `TROUBLESHOOTING.md`.
## External Files and Sources

Place newly received files in `input/intake/` before deciding how they may be used. Record safe metadata, provenance and the resulting classification in `input/CATALOG.md`; use the ignored `input/CATALOG.local.md` when filenames, paths or other details are themselves sensitive.

Catalog unchanged external services, datasets and URLs even when their content
remains outside the repository. Use stable public URLs directly and resolve
logical private or device-specific locations through ignored
`input/PATHS.local.md`.

- **`input/intake/`** is the ignored arrival area for files that have not yet been classified. Presence never authorizes assistant access.
- **`input/restricted/`** is ignored and reserved for files that only the maintainer, or explicitly approved local checks, may inspect.
- **`input/local/`** is ignored and holds files the assistant may process locally but that must not enter Git.
- **`input/versioned/`** contains reviewed external files that may be committed. Move files from here into a project-specific source, fixture or configuration location when that location communicates their durable role more clearly, while preserving provenance in the catalog.

Assistant access, Git versioning and external sharing are three separate decisions. A move between folders documents classification; it does not grant broader permission. Fixed runtime locations such as `.env`, application log directories or local databases may remain where the software requires them, but their classification and ignore rules should still be documented.

For large non-Git files that must remain available across devices, use the
provider-neutral workflow in `SYNCHRONIZED_STORAGE.md`.
Synchronized files remain external storage; synchronization is not Git
versioning, backup, assistant access or publication approval.

## Temporary Working Files

Use `temp/` for disposable intermediate engineering files. All contents outside
`temp/restricted/` are assistant-readable; that restricted directory must not
be enumerated or read. All temporary content is ignored, must never be versioned
and is not cataloged. Promote retained files deliberately to `materials/` or an
authoritative engineering location.

## Project Materials

Keep files in `input/` unchanged. A converted export, sanitized reproduction,
cropped screenshot, diagnostic extract or any other content change is a new
project material, not a modified input. `materials/` retains such working files
while they remain useful but have not become authoritative source code, tests,
fixtures or configuration.

Every cataloged material is assistant-readable. Record provenance and creation
or transformation in `materials/CATALOG.md`, using `Based on` input or material
IDs. Store files as **`local`** in ignored `materials/local/`, as
**`versioned`** in `materials/versioned/`, or as **`external`** at a stable
logical location in the catalog. Resolve external locations per machine in
ignored `materials/PATHS.local.md`, copied from the versioned example.

Access does not authorize Git versioning or sharing. Promote a material to
source, tests, fixtures or configuration only when that location better
expresses its durable engineering role, preserving provenance. Build outputs,
caches and disposable diagnostics do not belong in `materials/`.

Generation method does not determine location. Keep a generated file in
`materials/` when it is a durable working or source file consumed by later
engineering steps. Place it in `output/` or another documented deliverable
location when it is a project result intended for use, review, handoff, release
or delivery. Disposable generation intermediates remain in `temp/`; source,
tests, fixtures and configuration keep their authoritative locations.

## Recommended Workflow

Development proceeds through small, validated loops:

```text
Intent -> Roadmap -> Implement -> Validate -> Adjust -> Document -> Prepare commit -> Continue
```

1. Establish the current repository and working-tree baseline.
2. Confirm the active roadmap step and what it should prove or deliver.
3. Implement one logical, reviewable change.
4. Run relevant tests, scripts, linters, renderers or maintainer-local validation.
5. Fix issues found before presenting the step as ready.
6. Update code comments, technical documentation and user-facing guidance affected by the behavior.
7. Record consequential architecture, project or documentation decisions.
8. Prepare a regular working commit with an appropriate Conventional Commit prefix.
9. Close a satisfied milestone separately by harmonizing version, changelog, project context and validated status.

Routine new tasks use `start-task`. Invoke `$review-project` for a comprehensive
neutral inventory, `$sync-template` for source-template adoption,
`$check-consistency` for internal diagnosis and `$perform-retrospective` for a
separate evaluation of Maintainer-Agent collaboration.

## Decision Records

Choose the record type by decision subject:

- **ADR — Architecture Decision Record:** architecture, interfaces, configuration formats, lifecycle behavior, deployment, security boundaries, sensitive-input handling, fixture versioning or generated-output policy.
- **PDR — Project Decision Record:** scope, roadmap, collaboration, privacy, repository structure, release model or governance.
- **DDR — Documentation Decision Record:** user documentation, reference structure, terminology, examples, screenshots or documentation QA.

Templates live in [docs/decisions/](docs/decisions/). Create a record when future maintainers will need the context, rationale and consequences; routine implementation details belong in code, tests or ordinary documentation instead.

## Continuous Improvement

Development projects should retain practices that have proven useful and remove unnecessary complexity. Validated negative results, recurring validation problems and maintainability lessons are legitimate project knowledge.

Use `$sync-template` to compare a project with its verified source-template baseline and adopt selected developments. Use `$check-consistency` separately to diagnose contradictions among implementation, tests, documentation and roadmap, and `$perform-retrospective` to evaluate collaboration, engineering handoffs, validation strategy and work rhythm. A finding becomes a template candidate only after its transferability, maintenance cost and effect on different development projects have been considered.

The maintainer coordinates cross-template evolution in a private governance repository named `ai-templateverse`. It records shared conventions, deliberate specializations and evidence from derived projects. The repository is intentionally not linked because template users do not need access to it.

Governance coordination does not create hidden engineering requirements. Every change that affects this template must be represented here through maintained guidance, Decision Records where appropriate, the changelog and release history. Reusable improvements must keep code, tests, configuration and user-facing documentation aligned and must not overfit one implementation experience.


## Git authority

Git state may be inspected read-only. Staging requires a specific instruction
or authorization of the corresponding commit.

In `commit-changes`, explicit commit authorization includes normal push to this
repository's verified existing upstream. In `commit-milestone`, explicit milestone
commit authorization also includes one matching annotated version tag and its
exact upstream push. "Commit only" excludes tags and pushes; "no push" retains
the local commit/tag; "no tag" excludes tags; "no tag push" keeps the tag local.
Other Git actions, tag movement/replacement and release publication stay separate.

Skill invocation or a local clone mapping
supplies no additional authority. The local decision is [PDR-0004](docs/decisions/PDR-0004-milestone-version-tag-bundle.md).

## Retained workflows and project files

| Skill | Invocation |
| --- | --- |
| [check-consistency](.agents/skills/check-consistency/SKILL.md) | Explicit |
| [commit-changes](.agents/skills/commit-changes/SKILL.md) | Agent or explicit |
| [commit-milestone](.agents/skills/commit-milestone/SKILL.md) | Explicit |
| [grill-me](.agents/skills/grill-me/SKILL.md) | Explicit |
| [grilling](.agents/skills/grilling/SKILL.md) | Explicit |
| [handoff-task](.agents/skills/handoff-task/SKILL.md) | Agent or explicit |
| [perform-retrospective](.agents/skills/perform-retrospective/SKILL.md) | Explicit |
| [record-decision](.agents/skills/record-decision/SKILL.md) | Agent or explicit |
| [reuse-fixes](.agents/skills/reuse-fixes/SKILL.md) | Agent or explicit |
| [review-project](.agents/skills/review-project/SKILL.md) | Explicit |
| [start-task](.agents/skills/start-task/SKILL.md) | Agent or explicit |
| [manage-external-storage](.agents/skills/manage-external-storage/SKILL.md) | Explicit |
| [sync-template](.agents/skills/sync-template/SKILL.md) | Explicit |

- [AGENTS.md](AGENTS.md)
- [COLLABORATION.md](COLLABORATION.md)
- [PROJECT_CONTEXT.md](PROJECT_CONTEXT.md)
- [TASK_HANDOFF.md](TASK_HANDOFF.md)
- [TEMPLATE_SOURCE.md](TEMPLATE_SOURCE.md)
- [TEMPLATE_SYNC.md](TEMPLATE_SYNC.md)
- [PHILOSOPHY.md](PHILOSOPHY.md)
- [DOCUMENTATION.md](DOCUMENTATION.md)
- [REPOSITORY.md](REPOSITORY.md)
- [SYNCHRONIZED_STORAGE.md](SYNCHRONIZED_STORAGE.md)
- [VALIDATION.md](VALIDATION.md)
- [TROUBLESHOOTING.md](TROUBLESHOOTING.md)

## License and attribution

This guide derives from the MIT-licensed AI Dev Template.
The project license is in [LICENSE](LICENSE); existing attribution and
licenses of inherited skills remain intact. Synchronization changes no
license and grants no publication permission.
