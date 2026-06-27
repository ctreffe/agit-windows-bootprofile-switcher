# ChatGPT.md

# Collaboration Model v1.3

**Status:** Stable  
**Applies to:** AGIT software projects  
**Repository Maintainer:** ctreffe

---

# Purpose

This document describes the collaboration model used for AGIT software projects.

Its purpose is to document the engineering practices, decision-making process and collaboration principles that proved useful during the development of the AGIT Windows Deployment Kit and are now maintained as part of the AGIT Project Template.

Although this document is named **ChatGPT.md**, it is intentionally written to be useful for future AI assistants as well as human contributors.

This document intentionally contains **no hidden prompts**.

Instead, it openly documents the collaboration model used to develop and maintain AGIT repositories.

---

# Core Principles

The collaboration is based on the following principles:

- Architecture before implementation.
- Discuss trade-offs before writing code.
- Prefer incremental evolution over complete redesigns.
- Documentation is part of the implementation.
- Explain architectural decisions, not only technical solutions.
- Prefer maintainability over short-term convenience.
- Favor readability over cleverness.
- Keep software modular.
- Prefer supported configuration methods whenever practical.
- Never hide important assumptions.
- Validate before declaring success.
- Use precise, technical language instead of promotional wording.

---

# Repository Maintainer (ctreffe)

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

Manual intervention is considered acceptable whenever it improves safety, transparency or reliability.

This section intentionally documents engineering preferences rather than personal characteristics.

---

# Collaboration Workflow

Projects should evolve through iterative collaboration.

The preferred workflow is:

1. Understand the objective.
2. Discuss architectural alternatives.
3. Agree on the overall direction.
4. Implement incrementally.
5. Validate on real systems whenever possible.
6. Review the results together.
7. Improve the implementation.
8. Update all relevant documentation.
9. Prepare a repository-ready contribution.
10. Publish only after successful validation.

---

# Decision Making

Whenever multiple technical solutions exist:

- explain the available options
- discuss advantages and disadvantages
- provide a recommendation
- justify the recommendation

The objective is informed engineering decisions rather than simply generating code.

---

# AI Responsibilities

The AI assistant is expected to contribute beyond code generation.

Its responsibilities include:

- proposing architectural improvements
- identifying opportunities to simplify solutions
- improving documentation
- suggesting better engineering practices
- questioning assumptions when appropriate
- contributing to project organization
- improving release management
- helping maintain long-term consistency across the project

The AI assistant should actively participate in improving both the software and the engineering process.

Whenever recurring patterns or successful collaboration practices emerge during a project, they should be proposed for inclusion in this Collaboration Model and, once accepted, incorporated into the AGIT Project Template Repository.

The objective is continuous improvement of both the project and the collaboration itself.

---

# Repository-Ready Delivery

Repository-ready delivery means that a change is complete, reviewed and ready to be committed without further modification.

Implementation work is not considered complete until it is ready to be integrated into the repository.

Whenever practical, the AI assistant should prepare repository contributions by providing:

- the modified files as a ZIP archive
- an appropriate commit summary
- a detailed commit description
- suggested version tags or release milestones, where applicable
- updates to affected documentation
- consistency checks across related project documents

Repository-ready deliverables should only be generated after the repository maintainer and the AI assistant have agreed on the final content of the corresponding change.

The delivered ZIP archive, commit metadata and accompanying documentation are expected to represent the exact state intended for the repository.

Repository-ready deliverables should not require additional manual editing before being committed.

Repository-ready delivery means producing the actual agreed artifacts, not merely describing what those artifacts should contain. Placeholder files, draft-only file lists or conceptual commit descriptions are not repository-ready deliverables unless the maintainer explicitly requests them.

The objective is to minimize manual preparation work for the repository maintainer and provide complete, reviewable change sets.

Repository-ready delivery is considered an integral part of the engineering process.

---

# Shared Repository State

Repository-ready delivery requires the AI assistant to work from the current repository state.

Whenever the AI assistant cannot reliably reconstruct the latest repository contents from the current conversation, it should explicitly request the current repository as a ZIP archive before preparing repository-ready deliverables.

The repository maintainer should provide the current repository state when requested.

This ensures that generated change sets, ZIP archives and commit metadata accurately reflect the intended repository state and remain directly commit-ready without additional manual reconciliation.

---

# Git Workflow

The following Git workflow has proven effective for projects developed under this Collaboration Model.

## Git Client

GitHub Desktop is the preferred Git client for the repository maintainer.

The AI assistant should therefore avoid assuming command-line Git usage whenever practical and provide guidance that integrates naturally with GitHub Desktop.

## Repository Contributions

Repository changes should be delivered as complete repository-ready contributions whenever practical.

## Commit Messages

Every commit should include:

- a concise commit summary
- a meaningful commit description

Commit summaries should describe the primary purpose of the change.

Commit descriptions should describe only the actual changes introduced by that specific commit.

They should not repeat project history or describe changes introduced by previous commits.

Each commit should represent one logical engineering step.

Whenever practical, unrelated changes should be split into separate commits.

## Documentation Commits

Documentation changes are considered first-class engineering work.

Updates to README files, PHILOSOPHY.md, ChatGPT.md, CHANGELOG.md or other project documentation should receive their own well-structured commits whenever appropriate.

## Version Tags and Releases

Version tags and GitHub Releases should be created intentionally as project milestones.

They should not be created automatically after every commit.

Semantic Versioning should be used consistently throughout the project.

For future AGIT projects, version tags should use a leading `v`, for example `v1.0.0`.

Existing repositories may keep their established tag style for consistency.

## Branching Strategy

For projects maintained primarily by a single repository owner, a simplified Git workflow is preferred.

Changes are committed directly to the `main` branch.

Feature branches and pull requests are unnecessary unless multiple human contributors actively collaborate on the repository.

The workflow should remain as simple as possible while preserving a clean, understandable and well-documented project history.

---

# Documentation Philosophy

Documentation is considered part of the software.

Important architectural decisions should eventually be reflected in one or more of the following documents:

- README
- CHANGELOG
- PHILOSOPHY
- Release Notes
- configuration comments

Documentation should evolve together with the implementation.

User documentation should remain focused on using the software.

Engineering philosophy and collaboration practices belong in their dedicated documents.

Technical documentation should use precise, objective language.

Avoid promotional, exaggerated or marketing-oriented wording.

Well-designed software should communicate its quality through clarity, consistency and technical accuracy rather than persuasive language.

---

# Repository Evolution

The repository should evolve gradually.

Large-scale rewrites should be avoided whenever incremental improvements achieve the same objective.

Backward compatibility should be preserved whenever practical.

Engineering decisions should prioritize long-term maintainability over short-term convenience.

---

# Continuous Improvement

This Collaboration Model is intentionally a living document.

After completing every project, the repository maintainer and the AI assistant should perform a short retrospective.

Whenever new collaboration patterns, engineering practices or successful workflows have been identified, this document should be updated.

Typical additions include:

- engineering practices
- collaboration patterns
- documentation standards
- release workflows
- architectural lessons learned
- testing strategies
- project organization improvements

The objective is **not** to collect personal information about the repository maintainer.

The objective is to continuously improve the shared engineering process.

---

# Template Repository

This Collaboration Model is maintained within the AGIT Project Template Repository.

Whenever this document is improved after a completed project, the template repository should be updated accordingly.

Future projects should always begin with the latest version of the Collaboration Model.

The template repository therefore serves as the canonical starting point for all future AGIT software projects.

---

# Versioning

The Collaboration Model is versioned independently from the software project.

Version numbers should only change when meaningful improvements have been made to the collaboration process itself.

Each version should represent an observable improvement in the engineering process.

---

# Historical Note

Version 1.0 of the Collaboration Model was first developed during the implementation of the AGIT Windows Deployment Kit.

The initial version can be found in that project's repository:

https://github.com/ctreffe/agit-windows-deployment-kit

Beginning with version 1.1, the AGIT Project Template is the canonical source for maintaining and evolving the Collaboration Model.

Version 1.2 refined the repository ZIP workflow, commit delivery expectations, language consistency rules and retrospective-driven template evolution based on practical experience from the BootProfile Switcher project.

Version 1.3 clarified that explicit commit creation requests require actual file modifications and available repository-ready artifacts, not plans, placeholders or conceptual deliverables.

Future AGIT projects should adopt the latest version from this repository.

---

# Transparency

AGIT repositories may explicitly document when they were conceived, designed, implemented or documented through an iterative collaboration between the repository maintainer (**ctreffe**) and **ChatGPT (OpenAI)**.

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
- reproducible releases
- repository-ready deliverables

Software quality is measured not only by functionality, but also by how understandable, maintainable, reproducible and easy to continue the project remains over time.

---

# Architectural Status

This document is considered part of the software architecture.

It defines the collaboration model under which AGIT projects are designed, implemented, documented and maintained.

Changes to this document should therefore be reviewed with the same level of care as architectural changes to the software itself.


## Repository Initialization Baseline

At the start of a new AGIT project, the repository maintainer should create the repository from the AGIT Project Template and then upload the current repository state as a ZIP archive.

This ZIP archive is the authoritative working baseline for the AI assistant.

The AI assistant should not assume that it can reliably read all repository contents from GitHub links alone.

If the current repository state is missing, outdated or ambiguous, the AI assistant should request an updated ZIP archive before preparing repository-ready deliverables.

## Commit Delivery

When the maintainer explicitly requests that a commit be created, the planning phase is considered complete.

The AI assistant should then provide the requested commit immediately instead of restating the plan.

A commit delivery should include:

- a ZIP archive containing only new or modified files required for that commit
- the development version or release tag, according to the project workflow
- a commit summary
- a commit description

The ZIP archive should not contain unchanged files unless they are required for technical reasons.

The ZIP archive should not contain Git metadata such as a `.git` directory.

If a commit only removes files, the files to delete should be listed explicitly in the response because deletions cannot be represented by the presence of files in a ZIP archive.

The AI assistant should only interrupt the commit delivery flow when essential information is missing, requirements conflict or a technical blocker prevents creation of the requested commit.

## Commit Creation Means Finished Files

When the maintainer asks the AI assistant to create a commit, the expected output is the finished commit content.

The AI assistant should therefore modify the affected files, perform consistency checks and provide a repository-ready ZIP archive with the actual changed files.

Creating a commit always includes producing the real file changes required for that commit. It is not sufficient to describe the intended changes, provide a conceptual file list or generate placeholder content.

A commit request should not be answered with a plan, outline or proposed file list unless the maintainer explicitly asks for planning instead of execution.

If the AI assistant cannot create the requested commit because the current repository state is missing, ambiguous or technically unavailable, it should state that explicitly and request the missing information instead of presenting an incomplete commit as finished.

## Language Consistency

Multilingual repository documents should remain linguistically consistent.

For example:

- `README.md` should be written in English.
- `README.de.md` should be written in German.

Translations should be complete translations, not partially localized copies.

Headings, explanatory text and lists should be translated consistently.

Project names, product names, repository names and established technical terms may remain in their original form when translation would reduce clarity.

## Retrospectives

The AGIT Project Template should evolve through retrospectives based on practical project experience.

Retrospectives normally occur at the end of a project, but they may also occur during a project whenever enough practical experience has been gathered to justify improving the template.

Template updates should be made only as part of a retrospective.

This keeps the template stable during normal project work while still allowing it to improve when real projects reveal better practices.


---

# Completion Integrity

ChatGPT must never report a requested deliverable as completed unless the agreed deliverable has actually been produced and is available to the maintainer.

This principle applies to all deliverables, including commit ZIP files, generated documents, reports, analyses and other requested artifacts.

Download links or artifact references should only be provided after the corresponding artifact has actually been created and is available to the maintainer.
