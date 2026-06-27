# REPOSITORY.md

# Repository Standards

This document describes repository-level standards used by the AGIT Project Template.

It focuses on repository organization, Git usage, versioning and release handling for repositories created from the template.

---

# Repository Naming

Repository names should be clear, descriptive and stable.

For new AGIT repositories, prefer kebab-case names, for example:

```text
agit-project-template
agit-windows-deployment-kit
```

Repository names should describe the project without unnecessary marketing language.

A repository name should remain useful even if the project grows over time.

---

# Repository Description

The repository description should briefly explain what the project is.

Prefer precise technical language.

Avoid promotional wording, exaggerated claims or vague statements.

A good repository description should help a visitor quickly understand the scope of the project.

---

# Git Client

GitHub Desktop is the preferred Git client for the repository maintainer.

Repository guidance should avoid assuming command-line Git usage whenever practical.

Command-line Git may still be used when needed, but documentation should not depend on it unless there is a clear reason.

---

# Branching Strategy

For small projects maintained primarily by a single repository owner, commit directly to `main`.

Feature branches and pull requests are optional and should only be introduced when they provide practical value.

For projects with multiple active human contributors, branches and pull requests may be used to support review and coordination.

The workflow should remain as simple as possible while preserving a clean and understandable project history.

---

# Commit Messages

Every commit should have:

- a concise summary
- a meaningful description

The summary should describe the primary purpose of the change.

The description should describe the actual diff introduced by the commit.

Commit descriptions should not repeat project history or describe future plans.

Each commit should represent one logical engineering step.

Unrelated changes should be split into separate commits whenever practical.

---

# Documentation Commits

Documentation changes are first-class engineering work.

Updates to README files, CHANGELOG.md, PHILOSOPHY.md, ChatGPT.md, DOCUMENTATION.md or other project documentation should receive clear commits.

Documentation-only commits are acceptable when they improve clarity, usability or maintainability.

---

# Repository-Ready Delivery

When repository changes are prepared with AI assistance, they should be delivered as complete, reviewable change sets.

Whenever practical, this includes:

- a ZIP archive containing the modified repository files
- a commit summary
- a commit description
- tag or release guidance when relevant

Repository-ready deliverables should represent the final agreed state of the change and should not require additional manual editing before commit.

If the current repository state is unclear, the AI assistant should request a current repository ZIP before preparing repository-ready deliverables.

---

# Version Tags

Version tags should mark meaningful project milestones.

For future AGIT projects, version tags should use a leading `v`, for example:

```text
v0.1.0
v1.0.0
```

Existing repositories may keep their established tag style for consistency.

Tags should be created intentionally and should not be added after every commit by default.

---

# Releases

GitHub Releases should be created for meaningful project milestones.

Not every tag requires a release.

For small projects, it is usually sufficient to create releases for:

- first stable releases
- release candidates when useful
- versions with meaningful user-facing changes

Release notes should describe the actual changes included in the release.

---

# Repository Metadata

Repository metadata should be accurate and concise.

This includes:

- repository description
- topics
- license
- README badges

Metadata should help users understand the project without overstating its scope.

---

# Language

English is the primary project language.

Translated documentation may be provided where useful.

Non-English documentation should be clearly identified and should follow the structure of the primary English documentation whenever practical.

---

# Derived Projects

Repositories created from the AGIT Project Template should review which template documents remain useful after initial setup.

In most derived projects, the following documents are part of the setup workflow and may be removed after initialization:

- `PROJECT_SETUP.md`
- `DOCUMENTATION.md`
- `REPOSITORY.md`

The following documents usually remain part of the derived project:

- `README.md`
- `README.de.md` where useful
- `CHANGELOG.md`
- `ChatGPT.md`
- `PHILOSOPHY.md`
- `LICENSE`
