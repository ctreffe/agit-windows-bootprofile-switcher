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
