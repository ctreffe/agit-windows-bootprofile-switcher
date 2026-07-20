# Documentation Standards

This document defines the ongoing documentation rules for BootProfile
Switcher. Documentation is part of the implementation and must describe
implemented and validated behavior rather than an earlier plan.

## Document Roles

- `README.md` is the primary English user entry point; `README.de.md` is its
  structurally aligned German counterpart.
- `PROJECT_CONTEXT.md` records current state, active focus, validation baseline,
  template lineage and immediate next work.
- `docs/roadmap.md` owns active and future milestone scope.
- `CHANGELOG.md` records version history and unreleased repository changes.
- `docs/architecture.md` describes the current conceptual system.
- `docs/decisions/` contains durable ADRs, PDRs and DDRs.
- `docs/modules/`, `docs/deployment/`, `docs/discovery/`, `docs/poc/` and
  `docs/release/` contain focused technical and user guidance.
- `ChatGPT.md`, `CODEX.md` and `PHILOSOPHY.md` define collaboration, local
  execution and engineering principles.
- `CONTINUATION_PROMPT.md`, `HARMONIZATION_PROMPT.md` and
  `RETROSPECTIVE_PROMPT.md` provide repeatable review workflows.

The removed initialization files `PROJECT_SETUP.md` and `INITIAL_PROMPT.md` are
not reconstructed from newer template text. Their historical absence and the
reason are recorded in `PROJECT_CONTEXT.md`.

## User Documentation

Document prerequisites, elevation requirements, configuration, commands,
expected effects, logs, rollback, removal, safety boundaries and common failure
modes. Substantial modules and deployment workflows should have dedicated
documentation plus an example, demo, fixture or repeatable validation path.

Keep English and German documents aligned where both are maintained. Technical
terms may remain English when translation would reduce clarity.

## Code Readership

The primary readers are the maintainer and future Windows administrators or
contributors who can review PowerShell and Windows management concepts but
must not require private chat history. Assistant-authored comments and help
text use English. Scripts and modules document purpose, inputs, outputs, side
effects, failure behavior and non-obvious lifecycle or security constraints.

Prefer clear names and purposeful comments. Comments explain intent and
constraints rather than restating syntax.

## Current State and Validation Claims

Use present tense for implemented behavior and future tense only for roadmap
work. Validation claims must name the validated scope and must not imply that
syntax checks or fixtures replace elevated real-system validation.

Before milestone closure, check version and status wording, roadmap, changelog,
both READMEs, dedicated documentation links, setup and removal guidance,
validation evidence and known limitations.

## Sensitive and Generated Material

Local logs, backups, state, inventories, screenshots and vendor diagnostics may
contain user, machine, product or environment information. Inventory them at
metadata level before inspection. Prefer sanitized fixtures or reviewed
derivatives. Assistant access, Git versioning and publication are separate
maintainer decisions, and automated checks are warnings rather than approval.

## Repository-Ready Documentation

When a behavior or governance rule changes, update every affected authoritative
document coherently. Verify local links, examples, parameters, translations and
the distinction between completed work and roadmap intent.
