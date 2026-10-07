# AGENTS.md

Resident contract for BootProfile Switcher.

## Safety

- Inspect repository, branch, worktree and staging; preserve changes and
  selections.
- Maintainers own intent, architecture, roadmap and consequential decisions.
- Authorized reads and edits are allowed. Commits, tags, pushes, pulls, merges,
  rebases, resets, reverts, branches, stashes, destructive restores and direct
  `.git/` changes each require an instruction containing `explicit`,
  `explicitly` or German `explizit`.
- In `commit-changes`, explicit repository commit authorization includes normal
  verified-upstream push unless excluded. In `commit-milestone`, explicit milestone
  commit authorization also includes its matching annotated version tag and exact
  tag push. Honor commit-only/no-push/no-tag restrictions. Other Git actions,
  tag movement/replacement and release publication remain separately controlled.
- When such a control-word instruction is needed, propose one minimal copy-ready
  wording that names the exact action, repository and material consequence;
  the proposal is not authorization.
- Once exact staging is requested or its commit is authorized, run Git commands
  that write `.git` through narrow sandbox escalation on their first attempt;
  do not probe the expected `workspace-write` `.git/index.lock` denial. Keep
  read-only Git inspection sandboxed. Escalation grants no additional Git or
  standing authority.
- Use normal sandboxed execution when it is equally effective. If an already
  authorized in-scope action requires crossing a platform boundary, promptly
  request the narrowest sufficient escalation through the platform mechanism;
  do not omit or replace the action merely to avoid approval. Ask separately in
  prose only when action authority is missing or unclear. Escalation grants no
  broader repository, action, path, dependency, engineering, test, release,
  Git, publication or standing authority.
- Ask before dependencies, installation, privilege, external operations,
  outside writes or transmission; access, versioning and publication differ.
- Retry unchanged once only if plausibly transient. For clear or recurring
  failures, use `reuse-fixes` to consult this repository's confirmed fixes,
  continue within existing authority and ask only for a missing approval or
  blocking decision. Verify at the original operation and retain useful prevention.
- `input/intake/` grants no access; keep `input/` unchanged. Registered
  `materials/` and unrestricted `temp/` are readable; never version temporary
  content or inspect `temp/restricted/`. Keep secrets, logs and dumps out of
  Git. Synchronization grants no access.

## Routing

- Bounded work uses `start-task`, `TASK_HANDOFF.md`, targets and checks. Load
  `PROJECT_CONTEXT.md` only for project-wide state or unclear scope.
- Read `COLLABORATION.md` for initialization, full review, authority conflicts
  or collaboration-model changes. Load `REPOSITORY.md`, `DOCUMENTATION.md`,
  `PHILOSOPHY.md`, `SYNCHRONIZED_STORAGE.md` and domain guidance when applicable.
- Inspect affected source, tests, configuration and Decision Records before
  design. Existing project-local environments and tools take precedence.
- Task entry, handoff, ordinary commits and Decision Records route
  automatically. Invoke initialization, review, template sync, consistency,
  retrospective and `commit-milestone` explicitly.

## Validation

Codex skill edits use `scripts/Test-CodexSkill.ps1`; on first use follow
`VALIDATION.md` and prefer the project's existing manager and exact interpreter.

Scale evidence by stage: a bounded change needs the smallest useful behavioral
or source review, an ordinary commit needs targeted evidence for a good
reviewable state, and a milestone commit owns comprehensive engineering and
release checks. Tests, linters, formatters, builds, whitespace, links and
bilingual scans are not defaults before the milestone unless affected or
required by a stated material risk. Report limits and deferred checks truthfully.

## Initialized project workflows

Initialization is complete. Retained setup documents are provenance; creation
and initialization skill definitions are absent from the active skill inventory. Never recreate removed creation skills, template-only backlogs
or absent setup files. Use start-task/handoff-task for bounded work; explicitly
select review-project, sync-template, check-consistency and perform-retrospective.
grill-me and grilling remain explicit-only. A retrospective never grants access
or permission to write another repository. See [TEMPLATE_SYNC.md](TEMPLATE_SYNC.md).

## Project boundaries

- Preserve Windows boot, account, service, registry and rollback safeguards;
  do not run host-changing scripts as a validation shortcut. Logs, backups and
  state remain device-bound and outside Git. Use sanitized fixtures only within
  their approved scope. Existing elevated real-system test gates remain.
- Missing historical PROJECT_SETUP.md and INITIAL_PROMPT.md are not recreated.

## Retained local policy

Read CODEX.md when its execution, network, private-transmission or host-operation
rules apply; those safeguards remain binding. ChatGPT.md retains domain notes,
not a parallel generic task method. Current task routing is defined here and
in COLLABORATION.md; the legacy prompt paths redirect to current skills.
See [PDR-0003](docs/decisions/PDR-0003-current-template-workflow-authority.md).
