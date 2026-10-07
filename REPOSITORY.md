# Repository Standards

This document defines ongoing repository practices for BootProfile Switcher.

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
