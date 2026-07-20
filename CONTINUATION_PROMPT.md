# Continuation Prompt

Use this prompt as the first instruction in a new context window or assistant
session after development has already started.

Invoke it with `Read and execute CONTINUATION_PROMPT.md.`

## Prompt

```text
We are continuing the BootProfile Switcher project in a new context window.

Do not re-initialize the project and do not rely on earlier chat history.
Reconstruct the implementation and repository state before changing code.

1. Read CODEX.md and ChatGPT.md for authority, collaboration and Git rules.
2. Read PROJECT_CONTEXT.md as the primary re-entry point.
3. Read README.md, VERSION and the current CHANGELOG.md sections.
4. Read docs/roadmap.md, relevant Decision Records and documentation for the
   active component or workflow.
5. Subject to the sensitivity rules, inspect only the implementation, fixtures
   and configuration needed for the active step. Use REPOSITORY.md,
   DOCUMENTATION.md and PHILOSOPHY.md for project-wide expectations.

Use read-only Git commands to check the branch, working tree, recent commits,
latest relevant tag and staged or unstaged changes. Preserve uncommitted work
and report stale context or unclear ownership before editing overlapping files.

Reconstruct the last validated baseline without assuming that a previous
privileged or real-system test still applies to the current tree. Identify the
next small implement-validate-adjust step, expected human code readers and the
documentation that must remain aligned. Do not run destructive, privileged,
networked or system-changing checks merely to reconstruct context.

Before inspecting logs, backups, state files, dumps, screenshots, vendor
diagnostics, local configuration or generated artifacts, apply the documented
sensitivity rules. Assistant access, Git versioning and publication remain
separate decisions. Prefer sanitized fixtures or reviewed derivatives.

Before substantive edits, provide a concise numbered re-entry report:

1. project identity, current version and branch
2. active milestone and latest completed implementation step
3. working-tree changes and their relationship to active work
4. latest validated baseline and checks still needed
5. relevant decisions, code readership and documentation
6. sensitive-input, fixture and generated-artifact boundaries
7. open decisions, risks, blockers or inconsistencies
8. the smallest useful next step and its validation path
9. only blocking maintainer questions

If my instruction also gives a concrete safe task, proceed after this
reconstruction; otherwise wait for confirmation of the proposed next step.

Staging and unstaging do not require a control word, but perform them only when
I specifically request the index action or authorize the corresponding commit.
Preserve existing staged selections and unrelated changes.

Do not perform a protected Git action unless I instruct you to perform that
specific action with `explicit`, `explicitly` or the German word family
`explizit`.
```
