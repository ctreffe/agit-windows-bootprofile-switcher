# BootProfile Switcher - Project Context

## Project

BootProfile Switcher is a configurable Windows boot profile engine that applies
modular machine and user-session state from a selected Windows boot profile.
It is designed for deterministic, reversible operation in managed Windows
environments.

Repository: `agit-windows-bootprofile-switcher`

## Maintainer Intent and Desired End State

The project should make one Windows installation usable in multiple controlled
operating profiles selected during boot. Profiles should be understandable,
configuration-driven and suitable for unattended enterprise deployment.

The desired end state is a locally installed machine runtime that:

- resolves the selected boot profile before interactive logon;
- applies only allow-listed, documented modules;
- handles machine and per-user lifecycle state in the correct security context;
- supports dry-run, baseline learning, apply, restore and complete cleanup;
- uses Windows-supported or vendor-supported control surfaces;
- remains diagnosable without repository access or private chat history.

Important boundaries:

- no hidden or irreversible system changes;
- no named users or SIDs in machine configuration;
- no dependency on a repository checkout, mapped drive or deployment share at
  runtime;
- no bypass of security-product tamper protection or Windows self-healing;
- no unsupported service stopping when policy or vendor management is the
  appropriate control surface.

## Current Status

Last completed milestone:

**v1.7.0 - Machine-Wide Runtime and Deployment**

The milestone established and validated:

- the local `%ProgramData%\BootProfileSwitcher` runtime;
- separate runtime and configuration deployment;
- unattended LocalSystem-compatible installation and removal;
- explicit managed boot-menu operations;
- startup and per-user logon hooks using the installed runtime;
- machine and per-user baseline restoration;
- multi-user completion markers and final external runtime cleanup;
- active demo installation and restore-aware removal through the central
  deployment workflow.

The release-close validation left no managed BootProfile Switcher tasks, boot
entries, runtime, configuration or machine state on the development device.

## Current Focus

Prepare **v1.8.0 - Policy and Vendor Control Foundation**.

This is a broader capability milestone, not a discovery-only release. It covers
Windows Update and Bitdefender discovery, a durable control-surface decision,
policy-module and configuration design, at least one supported reversible
Windows policy implementation when discovery confirms a stable surface, and
real deployment and restore validation.

Bitdefender remains outcome-dependent: a supported enterprise interface may
lead to an integration path; otherwise the milestone must record a validated
negative result and safe operator guidance.

The detailed roadmap is maintained in [docs/roadmap.md](docs/roadmap.md).

## Current Technical Baseline

- Configuration Format v2 defines named profiles, boot-menu behavior and
  profile-local module settings.
- `scripts/Resolve-BootProfile.ps1` resolves managed and unmanaged startup.
- `scripts/Invoke-ProfileEngine.ps1` validates installed configuration and
  dispatches registered modules.
- `network-isolation`, `service-control` and
  `startup-user-application-control` implement lifecycle behavior.
- `validation-log` and `demo-system-marker` remain validation/demo components.
- `scripts/Install-BootProfileSwitcherDeployment.ps1` and
  `scripts/Uninstall-BootProfileSwitcherDeployment.ps1` own unattended
  deployment and restore-aware removal.
- The installed runtime, state, logs, configuration and backups are owned below
  `%ProgramData%\BootProfileSwitcher`.

## Validation Baseline

Validated through v1.7.0:

- configuration fixture validation;
- managed and unmanaged resolver/engine behavior;
- Network Isolation apply and restore;
- Windows Search and AnyDesk service-control baseline/apply/restore;
- startup and user-application control for supported targets;
- Configuration Format v2 boot-menu creation and replacement;
- LocalSystem fresh deployment, repeat deployment and runtime-only update;
- multi-user pending baseline restoration;
- complete restore-aware removal and external runtime cleanup.

Relevant references:

- [MDT deployment model](docs/deployment/mdt-deployment.md)
- [MDT administrator guide](docs/deployment/mdt-administrator-guide.md)
- [Configuration Format v2](docs/configuration-format-v2.md)
- [System architecture](docs/architecture.md)
- [Roadmap](docs/roadmap.md)

## Immediate Next Step

Start v1.8.0 with a read-only capability inventory and support matrix for
Windows Update and Bitdefender. Before implementation, decide which findings
belong to Windows policy control, vendor integration, diagnostics or explicit
non-support, and record the durable decision.

## Open Decisions

- Which Windows Update settings provide stable, supported and reversible
  machine policy control for the first implementation?
- Should the first policy implementation extend an existing module boundary or
  introduce a dedicated allow-listed policy-control module?
- Which Bitdefender product and management surfaces are available on the target
  environment, and which are supported for unattended enterprise control?
- Which discovery or generated artifacts may contain machine, user or vendor
  information and therefore require sanitization or exclusion from Git?

## Project Documents

- `README.md` and `README.de.md` - user-facing entry points
- `docs/roadmap.md` - active and future roadmap
- `docs/architecture.md` - system architecture
- `docs/decisions/` - durable architecture decisions
- `CHANGELOG.md` - completed version history and unreleased changes
- `ChatGPT.md` - AGIT Collaboration Model
- `CODEX.md` - local Codex operating policy
- `PHILOSOPHY.md` - project engineering principles

## AGIT Baseline

- AGIT Dev Template reference: **v1.1.2**, including current post-release
  harmonization guidance reviewed on 2026-07-16
- Collaboration Model: **v1.18**

The project retains its project-specific documentation structure. Template-only
setup documents are not copied into this mature derived repository unless they
become useful as maintained project documents.

## Working Principles

- repository-first, roadmap-first development;
- Windows-supported and vendor-supported mechanisms before workarounds;
- small validated working commits during a milestone;
- a separate milestone closure commit after implementation is already recorded;
- English code comments and documentation for assistant-authored implementation;
- documentation freshness before milestone closure;
- explicit decision-record checkpoints for architecture, configuration,
  lifecycle, deployment, security, privacy and durable roadmap changes;
- separate approval for inspecting sensitive inputs, versioning artifacts and
  publishing them;
- maintainer-controlled Git history according to `ChatGPT.md` and `CODEX.md`.

This file describes the current state and should remain concise. Historical
detail belongs in `CHANGELOG.md`, decision records, component documentation and
Git history.
