# ChatGPT.md

# Collaboration Model v1.1

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
