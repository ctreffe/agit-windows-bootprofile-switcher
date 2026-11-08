# Repository Standards

This document defines ongoing repository practices for BootProfile Switcher.

## Temporary Worktree Exception

Ordinary disposable/never-versioned temp rules exclude Git worktrees.
Their container stays ignored by the parent checkout; source versioning inside
follows normal repository authority. Do not clean them as scratch or promote
them to materials/. Follow [Project Anchor and Temporary Worktrees](COLLABORATION.md#project-anchor-and-temporary-worktrees)
for placement, access, preflight, recovery and separately authorized removal.

## Document and subproject folders

Preserve the established module, installed-runtime, configuration and
config/test/ fixture paths. Device-bound logs/, backups/ and state/ remain
unversioned and inaccessible without their own approved scope. These general
preferences authorize no runtime migration, baseline inspection or host operation.

Within each applicable role and access root, prefer shallow folders named for
the document, subject or subproject. Keep companion formats together, for
example output/handbook/handbook.pdf and output/handbook/handbook.docx.
A single deliverable may live directly in output/. Add subfolders only for
meaningful source roles, access boundaries, workflow, volume or tool requirements.
Work-item and catalog IDs remain metadata, not mandatory directory names.
Use descriptive filenames and language or revision suffixes when needed to
avoid collisions; do not add version-folder chains by default.

Apply this within input/ classifications, materials/ storage states and approved
output locations; never merge access zones or alter original input content.
Keep catalog IDs, provenance and relative references stable. Technical build,
website and dependency trees may need their own structure. Rendering must
preserve companion formats and unrelated files; cleanup needs its own authority.
Existing projects and files are not moved or reorganized automatically.

Keep source, tests, fixtures, packages and build/release trees in their tool-required locations.

## Repository Baseline

The local working tree is the active baseline when it is available and selected
by the maintainer. Use `PROJECT_CONTEXT.md` as the current-state entry point and
read-only Git evidence to reconcile branch, tag, commit and working-tree state.
Do not combine unrelated baselines or overwrite uncommitted work.

## Git Authority

GitHub Desktop is the maintainer's preferred Git client. Assistants may inspect
Git state by default. Staging and unstaging do not require a control word, but
they require a specific maintainer request or authorization of the corresponding
commit and must preserve existing staged selections.

Commits, amends, tags, pushes, pulls, merges, rebases, resets, branch changes,
stash operations and other protected Git actions require a maintainer
instruction for that specific action containing `explicit`, `explicitly` or
the German word family `explizit`. Permission to edit files or stage a change
does not authorize a protected Git action.

Within `commit-changes`, repository-specific explicit commit authorization
includes the normal push to the verified existing upstream unless excluded.
Within `commit-milestone`, explicit milestone commit authorization also includes
one matching annotated version tag and its exact upstream push (TVDR-0053).
"Commit only" excludes tags and pushes; "no push" retains a local commit/tag;
"no tag" excludes tag creation/push; "no tag push" retains the local tag.
Skill invocation alone grants no Git authority. Force-push, other refs, remote
changes, tag movement/replacement and release publication remain separately
controlled. This changes neither content-access nor publication rules.
See [PDR-0004](docs/decisions/PDR-0004-milestone-version-tag-bundle.md) for the milestone-tag amendment to PDR-0002.

## Commit Boundaries

Each regular working commit should represent one logical, validated step and
use an appropriate Conventional Commit prefix. Documentation-only work normally
uses `docs:`. Every suggested commit includes a concise summary and a meaningful
description matching the actual diff.

Milestone commits are separate closure commits. They use a human-readable
summary containing the completed version and close work already recorded in
regular commits.

## Versioning and Releases

The project uses Semantic Versioning and leading-`v` tags. `VERSION` describes
the latest completed milestone. Tags and GitHub Releases are intentional,
separate maintainer actions; not every tag needs a release.

## Decision Records

Use `docs/decisions/` for durable decisions. ADRs cover architecture and
technical lifecycle; PDRs cover scope, roadmap and governance; DDRs cover
durable user-documentation structure and terminology. Minor implementation
choices do not require a record.

## Sensitive Inputs and Generated Artifacts

Raw logs, backups, runtime state, inventories, dumps, screenshots and vendor
diagnostics remain outside Git by default. `logs/`, `backups/` and `state/` are
local runtime areas. Prefer sanitized fixtures in `config/test/` when they can
reproduce behavior without sensitive context.

Before proposing a commit, inspect new and untracked paths at metadata level and
review intended files for secrets, personal data and accidental generated
artifacts. Assistant access, Git versioning and publication are separate
approvals. A clean automated scan does not establish safety.

## Repository-Ready Delivery

A repository-ready change includes the actual working-tree changes, aligned
documentation, proportionate validation, known limitations and matching commit
guidance. Do not claim an artifact, validation result or Git state that does not
exist.

## Current source operating conventions

AGENTS.md and COLLABORATION.md define lifecycle-aware task entry, focused
context loading, small reviewable steps, authority and completion. Keep exact
direct Conventional Commit prefixes and meaningful real-newline bodies;
milestone closure is separate from implementation. Maintain both required
README language pairs and refresh guides when their workflows change.
Private/host inputs and local validation/real-system gates retain their
accepted domain rules. Compatibility prompt paths are not parallel methods.

## Restricted-source metadata workflow

Use explicit `manage-restricted-storage` and [RESTRICTED_STORAGE.md](RESTRICTED_STORAGE.md)
for selected empty-area setup, device connection, approved metadata maintenance
or selected project profile work. Existing access rules, inventories and
provider/recipient choices prevail. Record layout, catalog, configuration and
effective protection separately; failures/stale evidence remain visible.
Metadata never authorizes source discovery, reading, processing or transmission.
No live area, setting, policy, service or test is activated by template adoption.

## Optional AI collaboration branch recommendation

Preserve an established local branch convention. Where none exists, the source
recommends `<type>/ai-dev/<topic>` with a short lowercase kebab-case topic and
an appropriate semantic type, such as feature, fix, docs or chore. Agree local
defaults when needed; this recommendation creates, switches or renames no branch.
Every Git action retains its repository/action-specific control-word authority.
