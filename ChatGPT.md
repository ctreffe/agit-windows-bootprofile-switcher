# ChatGPT.md

# Collaboration Model v1.19

**Status:** Stable  
**Applies to:** AGIT software projects  
**Repository Maintainer:** ctreffe

---

# Purpose

This document describes the collaboration model used for AGIT software projects.

Although this document is named **ChatGPT.md**, it is intentionally written for both human contributors and future AI assistants. It contains no hidden prompts. It openly documents how AGIT projects are planned, implemented, validated, committed and improved.

The model exists to make collaboration reproducible across conversations and across projects. A new session should be able to reconstruct the project state from the repository, not from private memory or chat history.

Codex-specific local execution rules are documented separately in `CODEX.md`. This keeps the general Collaboration Model separate from machine-local operating policy.

---

# Core Principles

AGIT projects follow these principles:

- Architecture before implementation.
- Roadmap before technical curiosity.
- Discuss trade-offs before writing code.
- Prefer incremental evolution over complete redesigns.
- Documentation is part of the implementation.
- Explain architectural decisions, not only technical solutions.
- Prefer maintainability over short-term convenience.
- Favor readability over cleverness.
- Keep software modular.
- Prefer supported platform mechanisms whenever practical.
- Never hide important assumptions.
- Validate before declaring success.
- Treat validated negative results as project knowledge.
- Use precise, technical language instead of promotional wording.
- Produce actual artifacts when asked to create something.
- Prefer integrity over apparent helpfulness.
- Never simulate completed work or invented artifacts.

---

# Repository Maintainer Preferences

The repository maintainer consistently values:

- maintainability
- transparency
- modular design
- semantic versioning
- comprehensive documentation
- reproducible workflows
- structured logging where appropriate
- validation on real systems whenever practical
- long-term maintainability over quick solutions

Manual intervention is acceptable whenever it improves safety, transparency or reliability.

This section documents engineering preferences, not personal characteristics.

---

# Repository as Source of Truth

The repository is the authoritative project state.

The chat is useful for discussion, validation and decision making, but it is not the canonical record. The current repository contents, especially `PROJECT_CONTEXT.md`, define where the project stands.

When the assistant has access to the local repository working tree, that local working tree may be used as the working baseline.

When a public repository is available and intended as the source of truth, the assistant may use the current public repository state as the working baseline.

When the assistant cannot technically access or process the intended repository state, it must say so explicitly and request a usable baseline, such as a current ZIP archive.

When the repository state is ambiguous, outdated or missing, the assistant must request the current repository state before preparing repository-ready deliverables.

The assistant must not invent a repository state from memory or from partial conversation context.

---

# PROJECT_CONTEXT.md as Re-Entry Point

Every AGIT project should maintain `PROJECT_CONTEXT.md`.

`PROJECT_CONTEXT.md` is the primary entry point for resuming work. It should describe:

- the current project version
- the active milestone
- the current focus
- completed milestones
- open decisions
- important decisions already made
- relevant documents
- collaboration notes
- notes for the next session

The document should describe the current state, not the full history. History belongs in `CHANGELOG.md`, decision records or commit history.

At the start of a new AI-assisted session, the assistant should read or reconstruct `PROJECT_CONTEXT.md` before proposing implementation work.

Begin a new context window or assistant session with
`CONTINUATION_PROMPT.md`. It defines the ordered re-entry review, read-only Git
baseline check and numbered handoff that should precede substantive work.

---

# Context Handoff Discipline

Long AI-assisted work can exceed a model's available context window.

The assistant should not rely on private chat history remaining available. When a session becomes long, a substantial change is in progress, or context exhaustion appears possible, the assistant should update `PROJECT_CONTEXT.md` before continuing with lower-priority implementation work.

If the assistant environment exposes remaining context or token budget, the assistant should reserve enough capacity for a useful handoff update before the context becomes full. Exact token counts are environment-specific, so the rule is to preserve practical handoff capacity rather than depend on a fixed number.

If no budget information is visible, the assistant should use conservative judgment. Warning signs include long conversations, many changed files, multiple unresolved decisions, extended validation work or a likely transition to another session.

A handoff update should capture enough information for a new session to continue from the repository alone, including:

- the current repository baseline
- the active objective
- completed changes since the last context update
- open tasks
- affected files
- validation results
- known limitations or blockers
- the recommended next step

The assistant should prefer an early, slightly imperfect handoff update over losing important state to context exhaustion.

---

# Collaboration Workflow

Projects evolve through iterative collaboration.

The preferred workflow is:

1. Establish the current repository baseline.
2. Establish maintainer-owned project context and desired end state.
3. Derive or review the roadmap objective.
4. Discuss architectural alternatives when needed.
5. Agree on the next small step.
6. Implement incrementally.
7. Validate on a real system whenever practical.
8. Review the result against the roadmap objective.
9. Fix issues discovered during validation.
10. Update all affected documentation.
11. Prepare a repository-ready contribution.
12. Prepare commit-ready changes only after the work is complete and validated.
13. Finalize milestones separately from feature work.

For proof-of-concept work, the expected loop is:

```text
Implement -> Validate -> Adjust -> Prepare commit -> Continue
```

A feature commit should represent a validated logical step. A milestone commit
should represent the explicit conclusion of a roadmap milestone. The maintainer
controls when these commits are actually created unless the maintainer gives an
instruction with a recognized control word for the assistant to perform a
specific protected Git action.

---

# Git Index and Protected Git Action Authority

Staging and unstaging are Git index operations, not history actions. They do
not require a control word. The assistant may change the index only when the
maintainer specifically requests staging or unstaging, or authorizes the
corresponding commit. Existing staged selections and unrelated changes must be
preserved.

Protected Git actions include, but are not limited to:

- creating commits
- amending commits
- rebasing
- resetting
- reverting
- creating, deleting or switching branches
- creating or deleting tags
- pushing or force-pushing
- pulling or merging
- changing `.git/` contents directly

The assistant may inspect Git status, diffs and logs when useful. The assistant
may prepare file changes, propose commit boundaries and suggest commit summaries
and descriptions.

The assistant must not perform protected Git actions unless the maintainer
instructs the assistant to perform that specific action and uses a recognized
control word.

Recognized control words are `explicit` and `explicitly` in English-language
instructions, and the German word family `explizit`, including inflected forms
such as `explizite`, `expliziten`, `expliziter` and `explizites`, in
German-language instructions.

Maintainer approval for file edits does not imply approval for protected Git
actions. A request to create, implement, build, organize, document or prepare a
commit does not imply permission to run protected Git commands. Approval for one
class of protected Git action does not imply approval for another; local commits,
tags and pushes each require their own maintainer instruction with a recognized
control word.

Repository history is maintainer-controlled project memory.

---

# Code Documentation and Maintainability

Assistant-written code must be understandable without private chat history.
Code has a target readership just as user documentation has a target audience.
During initialization, the project should identify who is expected to inspect,
debug, maintain, review or extend the code and what technical context those
readers can reasonably be expected to have.

The assistant should document non-obvious behavior, assumptions, constraints and architectural decisions close to the code or in the appropriate project documentation. Comments should explain why something exists or why an approach was chosen, not repeat what the code already says.

Public functions, scripts, modules, configuration formats and integration points should be named and structured so a maintainer or future contributor can understand their purpose from the repository itself.

Code comments and doc comments should use English when English is the
repository standard. Assistant-authored scripts and code files should document
their purpose, inputs, outputs, side effects, important invariants, failure
behavior and non-obvious platform or lifecycle constraints at the level needed
by the identified human code readers. Comments should explain intent and
rationale rather than narrating self-evident syntax.

A change is not repository-ready if the maintainer or a future contributor would need the original AI conversation to understand the implementation.

---

# Milestone Work Rhythm
Recent AGIT project work has shown that collaboration is most efficient when roadmap milestones are handled as small, validated loops.

For an active milestone, the assistant should normally help maintain a rhythm like:

1. Confirm the current baseline and active milestone.
2. Identify the next smallest useful step.
3. Implement only that step.
4. Validate the step with the maintainer, especially when real-system or privileged checks are needed.
5. Interpret validation output before declaring success.
6. Prepare feature-commit guidance with summary and description.
7. Repeat until the milestone objective is satisfied.
8. Perform a documentation freshness pass before preparing the milestone commit.
9. Prepare separate milestone-commit guidance.
10. Recommend a tag for the completed milestone when appropriate.

This rhythm is especially useful when a project is evolving through architecture, proof-of-concept validation, local system integration or other work where small confirmed steps build confidence.

The assistant should avoid expanding the milestone opportunistically once the agreed objective is satisfied. If additional ideas emerge, they should be recorded as future roadmap candidates unless they are necessary to complete the current milestone.

A milestone should normally contain multiple regular working commits when the
work divides into meaningful validated steps. The project should not defer all
implementation, fixes and documentation into one oversized milestone commit.
The milestone commit is a separate closure commit and should primarily
harmonize version, changelog, context and milestone-facing documentation. A
small milestone may legitimately have only one preceding working commit, but
commit boundaries follow logical work, not version boundaries.

Before a milestone commit is prepared, the assistant should help verify that the repository documentation reflects the milestone state. This freshness pass should normally include version and status wording, roadmap and current-focus notes, changelog entries, README and translated README files, links to new specialized documentation, setup or demo instructions when applicable, and validation results. The objective is for the milestone commit itself to contain the consistent completed state, not to rely on a later cleanup commit.

After each meaningful implementation step, the assistant should provide a
concise numbered handoff covering the result ready for review, validation
performed, known limitations or disclosure risks, maintainer decisions, the
next proposed step and, when ready, a commit summary and description.

---

# Roadmap-First Development

The roadmap is the primary guide for deciding what to build next.

At the beginning of a project, or when a project enters a substantially new phase, the maintainer and assistant should explicitly establish a roadmap before implementation work accelerates.

Before the roadmap is established, the maintainer should describe the project intent and context from the maintainer's point of view. This is a maintainer-owned input, not something the assistant should invent from technical possibilities alone.

The initial intent discussion should normally cover:

- the problem space or operating context
- the intended users, maintainers or operating environment
- the desired end state or target experience
- the technical or product outcome that would make the project successful
- important boundaries, risks and intentional non-goals

The end state does not need to be a complete specification. It may be a desired user experience, a technical capability, an operational workflow, a deployment model or another clear target that gives the project direction.

The assistant should use this intent and context to help derive a roadmap. The roadmap should not be based only on isolated technical ideas when the broader project direction is still undefined.

An initial roadmap should normally define:

- the first meaningful milestone
- the next few planned milestones
- the purpose of each milestone
- which uncertainties each milestone should reduce
- what should intentionally remain out of scope
- what kind of validation is expected before completion

The roadmap does not need to predict the whole project perfectly. It should provide enough structure to make the next steps understandable, comparable and easy to resume. As learning accumulates, the roadmap may be updated deliberately.

Technical exploration is encouraged, but it should serve the current milestone. When a technical question becomes interesting, the assistant should ask whether answering it is necessary for the current roadmap step.

Before declaring a milestone or step complete, verify:

- What was the agreed objective?
- What was validated?
- What remains intentionally postponed?
- Does the result satisfy the roadmap step?
- Does the documentation reflect the actual result?

This prevents projects from drifting into open-ended experimentation.

---

# Validated Learning

Validated learning is part of engineering progress.

A project may advance by confirming that an approach works. It may also advance by proving that an approach is impractical, unnecessary or not worth pursuing.

Negative findings should be documented when they affect architecture, roadmap decisions or future implementation choices.

A failed hypothesis is not a failed milestone if the milestone was designed to reduce uncertainty.

---

# Validation Partnership

Some AGIT work must be validated by the repository maintainer because it requires local system access, elevated permissions, hardware state, GUI tools or other environment-specific conditions.

In these cases, the assistant should:

- prepare exact commands or manual steps
- explain the expected outcome
- ask the maintainer to run only the smallest necessary validation
- interpret the maintainer's pasted output
- distinguish successful validation from partial or ambiguous validation
- update the repository context or documentation when the result affects future work

The maintainer's real-system validation output is part of the engineering process. The assistant should not treat a command as validated merely because it is syntactically correct or plausible.

When validation reveals an issue, the assistant should fix the issue and re-enter the validation loop before recommending a commit.

---

# Sensitive Development Inputs

Before inspecting private, confidential or personal raw development material, the assistant should first inventory the material at the metadata level and ask whether direct inspection is appropriate. This includes `.env` files, logs, database dumps, API responses, screenshots, crash reports, customer data, user data and generated artifacts.

When possible, prefer sanitized fixtures, redacted logs, minimal reproduction cases or reviewed derivatives that expose only the information needed for the engineering task.

The maintainer remains responsible for approving access to sensitive material
and deciding what may be versioned or shared. Approval for assistant inspection,
approval for Git versioning and approval for publication or external sharing
are separate decisions. None implies another.

Generated logs, reports, screenshots, archives, fixtures and diagnostic
artifacts may still expose secrets, personal information, internal topology or
confidential behavior after raw inputs have been removed. Review visible
content, embedded resources and file metadata before versioning or sharing.

Automated secret, privacy or content checks are warning systems, not approval.
A clean result does not prove that an artifact is sanitized or safe for access,
Git or publication.

---

# Decision Making

Whenever multiple technical solutions exist:

- explain the available options
- discuss advantages and disadvantages
- provide a recommendation
- justify the recommendation
- identify what must be validated

The objective is informed engineering decisions rather than simply generating code.

If practical validation disproves an earlier assumption, update the plan instead of defending the assumption.

When a decision affects architecture, configuration formats, lifecycle behavior, deployment, security boundaries, sensitive input handling, fixture or dump versioning, generated artifact versioning or other durable project structure, the assistant should explicitly check whether an Architecture Decision Record should be created or updated in `decisions/`.

When a decision affects project scope, roadmap, collaboration structure, privacy boundaries, repository organization, documentation structure or user-facing documentation model, the assistant should check whether a PDR or DDR is more appropriate than an ADR.

Decision records are not required for minor implementation choices. They are appropriate when future maintainers should be able to understand why an approach was chosen without relying on chat history.

---

# AI Responsibilities

The AI assistant is expected to contribute beyond code generation.

Its responsibilities include:

- maintaining awareness of the roadmap
- proposing architectural improvements
- identifying opportunities to simplify solutions
- questioning assumptions when appropriate
- improving documentation
- suggesting better engineering practices
- helping maintain release and versioning consistency
- detecting inconsistencies across project documents
- distinguishing planning from delivery
- requesting the current repository state when needed
- producing actual deliverables when asked to create them
- refusing to claim completion when an artifact cannot be produced
- preserving required template artifacts such as the AI Collaboration Note unless explicitly instructed otherwise

The assistant should actively improve both the software and the engineering process.

Whenever recurring patterns or successful collaboration practices emerge
during a project, the assistant should propose them for a retrospective.
Accepted findings may become candidates for the project's recorded source
template. Any later propagation to another template repository is a separate
maintainer decision. A candidate is implemented only after the specific
template change receives the required control-word authorization.

---

# Commands, Plans and Deliverables

The wording of a maintainer request matters.

If the maintainer asks to discuss, plan, review, compare or decide, the assistant should remain in planning mode.

If the maintainer asks to create, implement, build, update or prepare a commit,
the assistant should treat the planning phase as complete and produce the
requested repository-ready deliverable in the working tree.

Preparing a commit means preparing the files and commit metadata for maintainer
review. It does not authorize staging, committing, tagging or pushing.

A request such as:

```text
Create the commit.
```

only authorizes an actual Git commit when the maintainer asks the assistant to
perform that protected Git action and uses a recognized control word. Otherwise,
commit-related wording means:

- modify the required files
- perform consistency checks
- produce the repository-ready result in the agreed delivery form
- provide commit summary and commit description

It does not mean:

- describe a possible commit
- restate the plan
- provide only a commit message
- claim completion without the agreed result

The assistant should interrupt delivery only when essential information is missing, requirements conflict or the agreed result cannot be produced. In that case, it must state the blocker clearly.

Whenever the assistant recommends a commit, it should provide both:

- a concise commit summary
- a meaningful commit description

This applies to feature commits, documentation commits and milestone commits. The description should match the actual diff and should not describe future work as if it had already been completed.

When a change is approaching commit readiness, the assistant should provide concise numbered next steps for the repository maintainer whenever practical. This is especially useful when the maintainer must perform actions outside the assistant environment, such as running validation commands, reviewing generated files, making decisions, committing through GitHub Desktop or creating tags.

Numbered next steps should be operational rather than decorative. They should distinguish:

- decisions the maintainer must make
- commands or checks the maintainer should run
- information the maintainer should review
- commit or tag actions the maintainer should perform

The assistant should keep these lists short, ordered and directly actionable. For very small changes, a one-step or two-step list is sufficient. For larger work, numbered steps help preserve efficient communication and reduce back-and-forth.


---

# Integrity Over Helpfulness

Integrity has priority over apparent helpfulness.

The assistant must not make work appear complete when it is not complete. A partial result, a limitation or a blocker should be stated clearly rather than hidden behind confident language.

The following behaviors are not acceptable:

- claiming that a ZIP archive, document, commit or repository state exists when it has not actually been produced
- providing download links to artifacts that do not exist
- saying that files were updated when no updated files are available
- implying that validation or tests were performed when they were not performed
- returning an unchanged archive as if it contained a requested change

When a requested deliverable cannot be produced in the current environment, the correct response is to explain the limitation immediately and offer a truthful alternative such as local working tree changes, a patch, explicit file contents or an archive, depending on what the environment can actually provide.

---

# Repository-Ready Delivery

Repository-ready delivery means producing the actual agreed repository state or artifacts, not merely describing what they should contain.

A repository-ready contribution should normally include:

- the changed repository state in the agreed delivery form
- an appropriate commit summary
- a detailed commit description
- updates to affected documentation
- consistency checks across related documents
- tag or release guidance when relevant

The delivery form depends on the working environment.

Examples include:

- local working tree changes when a local agent has repository write access
- a patch when direct repository editing is not available
- explicit file contents when patch or archive generation is not available
- a ZIP archive containing changed files or repository state when files must be transferred through a chat interface

The delivered state or artifact must represent the exact state intended for the repository.

Repository-ready deliverables should not require additional manual editing before commit.

Placeholder files, conceptual file lists, draft-only snippets or imaginary download links are not repository-ready deliverables unless the maintainer explicitly asks for a draft.

If a ZIP archive is provided, it must actually exist and contain the stated changes.

If no files changed, the assistant must say that no repository-ready change is necessary instead of returning an unchanged artifact as a completed change.

If a commit only removes files, deletions must be listed explicitly because removed files cannot be represented by their presence in an archive.

---

# Artifact Integrity

The assistant must never report a requested deliverable as completed unless the agreed deliverable has actually been produced and is available to the maintainer.

This applies to all deliverables, including:

- local working tree changes
- commit ZIP files
- generated documents
- reports
- analyses
- scripts
- repository updates
- release notes

Download links or artifact references may only be provided after the corresponding artifact actually exists.

If an artifact is mentioned as delivered, the artifact must be accessible and must contain the stated changes. If the assistant cannot verify that, it must not present the artifact as complete.

A repository-ready deliverable must satisfy all of the following conditions:

- the baseline repository state is known
- the relevant files were actually changed
- the changed state is available to the maintainer in the agreed delivery form
- the stated local changes, archive, patch or file set exists
- the commit summary and description match the actual diff

---

# Capability Transparency

The assistant must communicate delivery limitations before simulating completion.

If the current environment cannot perform an action, the assistant must say so directly. Examples include:

- inability to access the current repository state
- inability to modify files
- inability to create the requested delivery artifact
- inability to run tests or validation steps
- inability to inspect generated artifacts

The assistant may then offer a lower delivery level, such as a repository-ready patch or exact file contents, but it must not claim a higher delivery level than it actually produced.

A capability limitation is not a failure. Hiding the limitation is a failure.

---

# Repository Baseline Rules

Before preparing repository-ready deliverables, the assistant must know the baseline.

Accepted baselines are:

- the local repository working tree when it is accessible to the assistant and intended as the source
- the current public repository state, if accessible and explicitly intended as the source
- a repository ZIP uploaded by the maintainer
- a previously generated repository-ready artifact explicitly accepted as the new baseline

If multiple baselines are possible, the assistant must ask which one is authoritative.

The assistant should not combine files from multiple baselines unless the maintainer explicitly asks for a merge.

---

# Git Workflow

The following Git workflow is preferred for AGIT projects.

## Git Client

GitHub Desktop is the preferred Git client for the repository maintainer.

The assistant should therefore avoid assuming command-line Git usage whenever practical and should provide guidance that works naturally with GitHub Desktop.

Staging and unstaging follow the index rules above. The assistant may inspect
Git state and prepare repository-ready changes, but must not perform protected
Git actions unless the
maintainer instructs the assistant to perform that specific action with a
recognized control word.

## Branching Strategy

For projects maintained primarily by a single repository owner, committing directly to `main` is acceptable.

Feature branches and pull requests are optional and should only be introduced when they provide practical value.

For projects with multiple active human contributors, branches and pull requests may be used for review and coordination.

## Commit Messages

Every commit should include:

- a concise summary
- a meaningful description

Commit summaries should describe the primary purpose of the change.

Commit descriptions should describe the actual diff introduced by that commit and the reason for it when the reason is not obvious.

Commit descriptions should not repeat unrelated project history or describe changes introduced by previous commits.

Each commit should represent one logical engineering step.

Unrelated changes should be split into separate commits whenever practical.

## Feature Commits

Feature commits implement or improve a specific logical step.

Regular working commits must use Conventional Commit prefixes such as:

```text
feat:
fix:
docs:
chore:
refactor:
test:
ci:
build:
```

The prefix should match the actual change. Documentation-only changes should normally use `docs:`.

## Milestone Commits

Milestone commits finalize a completed roadmap milestone.

They are separate from feature commits. Milestone commits should not use a Conventional Commit prefix. They should use human-readable summaries that include the completed version number, for example:

```text
Finalize proof-of-concept milestone (v0.3.0)
```

## Documentation Commits

Documentation changes are first-class engineering work.

Documentation-only commits are acceptable when they improve clarity, consistency, usability or maintainability.

---

# Version Tags, Versions and Releases

Semantic Versioning should be used consistently.

Version numbers describe completed project states.

Version tags should mark meaningful completed roadmap states or milestones. Tags are not created after every commit by default.

GitHub Releases are user-facing publication events. Not every tag requires a GitHub Release.

The `VERSION` file should describe the latest completed project version according to the repository's versioning policy.

For future AGIT projects, version tags should use a leading `v`, for example:

```text
v0.1.0
v1.0.0
```

Existing repositories may keep their established tag style for consistency.


---

# Standard Template Artifacts

Some template elements are standardized project artifacts rather than free-form prose. They should be preserved during project setup unless the maintainer explicitly asks to change the disclosure model.

This includes the AI Collaboration Note in `README.md` and `README.de.md`.

Derived projects should place an AI Collaboration Note directly below the README badges. The note should preserve the template note's disclosure purpose, structure and visibility, point readers to `ChatGPT.md`, and use wording that is factually correct for the derived project. The literal template wording should not be copied when it would incorrectly claim that a derived project maintains the AGIT Collaboration Model.

When updating an existing project, the assistant should check whether required standard artifacts are present and consistent with the template.

---

# Documentation Philosophy

Documentation is considered part of the software.

Every document should have a clear role:

- `README.md` explains the project to users and contributors.
- `PROJECT_CONTEXT.md` explains the current state.
- `CHANGELOG.md` records version history.
- `ChatGPT.md` defines the collaboration model.
- `PHILOSOPHY.md` defines engineering principles.
- Decision records explain important decisions and durable reasoning, when used.

Documentation should evolve together with implementation.

Avoid duplicating the same rule in many places. Prefer clear ownership and cross-references.

Technical documentation should use precise, objective language.

Avoid promotional, exaggerated or marketing-oriented wording.

READMEs should remain entry points and navigation aids. When a module, integration, component or workflow becomes too substantial for the README, the detailed user-facing and maintainer-facing documentation should move into a dedicated document such as `docs/modules/<name>.md`, `docs/integrations/<name>.md` or another project-appropriate location. The README should summarize the component briefly and link to the dedicated documentation instead of duplicating all details.

---

# User-Facing Documentation

Projects should be documented so users can set them up, configure them and use them productively without relying on private chat history or maintainer explanations.

User-facing documentation should normally explain:

- what the project does and who it is for
- prerequisites, installation and setup
- configuration and important defaults
- common usage workflows and examples
- available commands, scripts, flags, settings or profiles when the project exposes them
- expected outputs, logs, files or system effects where relevant
- permissions, safety notes, platform constraints and rollback or uninstall guidance when applicable
- troubleshooting steps for common failures
- current maturity, limitations and intentionally unsupported scenarios

Reference documentation is encouraged when a project exposes a meaningful command surface, configuration schema, module interface or operational workflow. Keep it concise, accurate and generated or easy to verify when practical.

If a project exposes production modules, integrations or other reusable components, each substantial component should include a small demonstration, example configuration or validation path when applicable. The form should fit the project: a demo installer, sample configuration, reproducible command sequence, fixture or documented validation checklist may all be appropriate.

Documentation should make the first successful use of the project easy, and it should make repeated productive use predictable.

---

# Repository Evolution

Repositories should evolve gradually.

Large-scale rewrites should be avoided when incremental improvements achieve the same objective.

Backward compatibility should be preserved whenever practical.

However, documents should be fully harmonized when a retrospective changes core process rules. Adding isolated notes is not enough if the change affects the meaning of several documents.

---

# Retrospectives and Template Evolution

Use `HARMONIZATION_PROMPT.md` for project-content alignment. Harmonization
compares this project with its recorded source template, reconciles code,
tests, documentation and repository state, and reviews roadmap fit. The
concrete project and its Decision Records remain authoritative. Harmonization
does not evaluate collaboration or derive template improvements.

The AGIT Dev Template evolves through collaboration retrospectives based on
practical project experience.

The maintainer decides when to invoke a retrospective and which period it
should cover. It evaluates Maintainer-Agent collaboration, including rules,
feedback, decisions, handoffs and work rhythm.

Use `RETROSPECTIVE_PROMPT.md` for the structured collaboration review.

Template changes should be made only as part of a retrospective, not casually during normal project work.

A retrospective result is only a template candidate. The assistant must not
modify the source-template repository unless the maintainer authorizes that
specific template change with `explicit`, `explicitly` or the German word
family `explizit`. Template-edit permission does not authorize Git history;
staging or unstaging requires a specific request but no control word. Each
commit, amend, tag, push, pull, merge, rebase, reset, branch or stash action
requires its own specific control-word instruction.

Retrospective updates should:

- identify reusable lessons
- avoid overfitting the template to one project
- update all affected documents consistently
- remove or rewrite outdated guidance
- preserve the template's lightweight character

The objective is reusable process improvement, not a log of individual mistakes.

---

# Transparency

AGIT repositories may explicitly document when they were conceived, designed, implemented or documented through iterative collaboration between the repository maintainer and an AI assistant.

The objective is transparency.

Where applicable, repositories should document not only the resulting software, but also the engineering process used to create it.

---

# Definition of Success

A successful project is characterized by:

- reliable implementation
- maintainable architecture
- complete documentation
- transparent decision making
- successful validation
- reproducible workflows
- repository-ready deliverables
- a project history that can be understood later

Software quality is measured not only by functionality, but also by how understandable, maintainable, reproducible and easy to continue the project remains over time.

---

# Architectural Status

This document is part of the software architecture for AGIT projects.

It defines the collaboration model under which AGIT projects are designed, implemented, documented and maintained.

Changes to this document should therefore be reviewed with the same care as architectural changes to software.

---

# Historical Note

Version 1.0 of the Collaboration Model was first developed during the AGIT Windows Deployment Kit project.

Beginning with version 1.1, the AGIT Project Template became the canonical source for maintaining and evolving the Collaboration Model.

Version 1.2 refined repository ZIP workflows, commit delivery expectations, language consistency rules and retrospective-driven template evolution based on early BootProfile Switcher experience.

Version 1.3 introduced Completion Integrity and clarified that explicit commit creation requests require actual file modifications and available repository-ready artifacts.

Version 1.4 integrates the BootProfile Switcher v0.3.0 retrospective: repository-first collaboration, roadmap-first implementation, validated learning, feature/milestone commit separation and stricter deliverable discipline.

Version 1.5 adds Integrity over Helpfulness, Artifact Integrity and Capability Transparency. It also clarifies that standardized template artifacts such as the AI Collaboration Note must be preserved unless the maintainer explicitly requests a change.

Version 1.6 generalizes repository-ready delivery beyond browser-based ZIP workflows. It clarifies that local working tree changes, patches, explicit file contents or archives may be valid delivery forms depending on the assistant environment, while preserving the same artifact integrity requirements.

Version 1.7 adds Context Handoff Discipline. It clarifies that assistants should update `PROJECT_CONTEXT.md` before context exhaustion becomes likely and reserve practical handoff capacity when context or token budget information is available.

Version 1.8 adds numbered maintainer next steps before commit-ready handoff. It clarifies that assistants should use concise ordered lists for decisions, validation actions, review points and commit or tag actions when this improves efficiency.

Version 1.9 adds milestone work rhythm and validation partnership guidance derived from the BootProfile Switcher v0.4.0 through v0.7.0 workflow. It also clarifies that commit recommendations should include both a summary and a description.

Version 1.10 adds explicit initial roadmap agreement guidance. It clarifies that new projects or substantially new phases should establish early milestones, milestone purpose, intended validation and intentional non-goals before implementation accelerates.

Version 1.11 adds explicit code documentation and maintainability guidance for assistant-written implementation work. It clarifies that code must be understandable from the repository itself without relying on private AI conversation history.

Version 1.12 adds explicit user-facing documentation guidance. It clarifies that projects should document setup, configuration, productive usage, command or settings references, troubleshooting, permissions, safety notes and maturity where relevant.

Version 1.13 adds maintainer-owned project intent and context as an explicit project-start step before roadmap derivation. It clarifies that the maintainer should describe the problem context, desired end state and boundaries so the roadmap can be derived from project direction rather than isolated technical ideas.

Version 1.14 adds dedicated documentation guidance for substantial modules, integrations and workflows. It also adds a documentation freshness pass before milestone commits and clarifies that substantial production components should include a demonstration, example configuration or validation path when applicable.

Version 1.15 adds explicit ADR checkpoint guidance. It clarifies that important architecture, configuration-format, lifecycle, deployment and security decisions should trigger a deliberate check for creating or updating an Architecture Decision Record.

Version 1.16 adds explicit Git history authority. It clarifies that repository
history is maintainer-controlled project memory and that assistants have no
default permission to stage, commit, tag, push or otherwise perform Git history
actions.

Version 1.17 adds sensitive development input handling. It clarifies that assistants should inventory private logs, dumps, API responses, screenshots, customer data and generated artifacts before raw inspection, prefer sanitized fixtures or reviewed derivatives when possible, and consider ADRs for sensitive-input, fixture-versioning and generated-artifact decisions.

Version 1.18 formalizes human code readership, English documentation standards
for assistant-authored code, and the expectation that roadmap milestones
advance through regular validated commits before a separate milestone closure
commit.

Version 1.19 distinguishes specifically requested staging and unstaging from
protected Git actions. Index operations do not require a control word, but must
preserve existing staged selections and unrelated changes.

Future AGIT projects should adopt the latest version from this repository.
