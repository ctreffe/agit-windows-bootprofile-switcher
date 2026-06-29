# PROJECT_CONTEXT.md

# BootProfile Switcher – Project Context

## Project

**Name:** BootProfile Switcher

**Repository:** `agit-windows-bootprofile-switcher`

**Purpose**

BootProfile Switcher is a configurable Windows boot profile engine that allows different system configurations to be applied automatically before user logon based on the selected Windows boot profile.

The project focuses on a modular architecture, deterministic behavior and enterprise-ready deployment.

---

# Current Project Status

## Last Completed Milestone

**v1.1.0 – Network Isolation**

The Network Isolation milestone is complete.

## Current Focus

Prepare the next structural milestone: **v1.2.0 – Configuration Format v2**.

The next planned work should improve the project configuration model before adding more production modules. The following milestone should then make boot menu creation configuration-driven.

The completed proof of concept validated whether a Windows Boot Manager selection can be used as the basis for selecting a boot profile before user logon.

A1 has established a reversible boot menu with two entries:

* BootProfile Switcher - Mode A
* BootProfile Switcher - Mode B

A1 validation also showed that the installer should copy `{default}` rather than `{current}` because `{current}` can become invalid after booting from and removing a managed proof-of-concept entry. Usability has been improved with double-clickable `install.cmd` and `uninstall.cmd` wrappers that request elevation and call the PowerShell scripts.

A2 has been validated for Mode A and Mode B. `scripts/Get-CurrentBootProfile.ps1` detects the current BootProfile Switcher mode by reading the real `{current}` BCD object identifier from verbose `bcdedit` output and mapping it to the managed A1 state file. Description-based detection remains available as a fallback.

A3 has been validated for Mode A and Mode B. A Windows Scheduled Task with an `AtStartup` trigger runs the BootProfile Switcher detection automatically during system startup and writes the selected mode to `logs/startup-profile.log`.

A4 has been validated for Mode A and Mode B. The startup hook now executes profile-specific startup scripts from `profiles/mode-a/startup.ps1` and `profiles/mode-b/startup.ps1`. These scripts intentionally perform harmless validation logging to `logs/profile-startup-actions.log`.

v0.4.0 introduced `scripts/Resolve-BootProfile.ps1` as the dedicated resolver, validated it for Mode A and Mode B, kept normal unmanaged Windows startup as a successful `detected = false` case, improved boot menu installation against duplicate managed entries and moved the startup hook onto the resolver path.

v0.5.0 introduced `scripts/Invoke-ProfileEngine.ps1` as the dedicated profile engine entry point. The startup hook now orchestrates resolver output through the engine. The engine keeps existing harmless profile script dispatching and intentionally postpones configuration files, built-in system-changing flags and custom script configuration.

v0.6.0 introduced `modules/validation-log/Invoke-ValidationLogModule.ps1` as the first harmless module. `scripts/Invoke-ProfileEngine.ps1` invokes modules through an internal module registry, and the startup hook logs executed modules. Configuration files, real system-changing modules and Group Policy distribution remain intentionally postponed.

v0.7.0 introduced the first profile configuration schema in `config/profiles.example.json`, a validator in `scripts/Test-BootProfileConfiguration.ps1`, validation fixtures and runtime configuration validation in `scripts/Invoke-ProfileEngine.ps1`.

v0.8.0 makes configuration the runtime dispatch gate. `scripts/Invoke-ProfileEngine.ps1` now dispatches only modules listed on the matching configured profile. If configuration is missing, invalid or does not contain the resolved mode, the boot profile performs no action and reports the skip reason. The startup hook must still log configuration status, validation errors and dispatch skip reasons so no-op behavior remains auditable. Custom script paths remain schema-only and are not executed yet.

`scripts/Install-BootProfileConfiguration.ps1` and `install-configuration.cmd` provide a controlled installation path for copying a validated profile configuration to `%ProgramData%\BootProfileSwitcher\config\profiles.json`. Existing configuration is preserved unless replacement is confirmed or forced.

For the v1.0.0 release demonstration, `modules/demo-system-marker/Invoke-DemoSystemMarkerModule.ps1` adds a temporary harmless system-level marker module. It writes the resolved profile to `%ProgramData%\BootProfileSwitcher\runtime\demo-current-profile.json`, does not change Windows behavior and should be removed after v1.0.0 once production modules exist.

The temporary `demo-system-marker` module has been validated through the real Mode A startup-hook path after reinstalling the updated ProgramData configuration. The startup log reported `modulesExecuted=validation-log,demo-system-marker`, and the marker file contained the real managed Mode A identifier `{5f94af99-48f1-11ee-92e5-ceb38253b459}`.

`docs/release/v1.0.0-release-scope.md` defines the intended initial stable release scope: a validated foundation release with reversible boot infrastructure, configuration-driven module dispatch, predictable logging and the temporary demo marker module, but without production system-changing modules.

`install-demo.cmd` and `uninstall-demo.cmd` provide combined v1.0.0 demo setup and teardown wrappers. They keep the individual install/uninstall wrappers available for diagnostics and maintenance.

---

# Completed Milestones

## v0.1.0 – Foundation

Completed.

Main results:

* Repository initialized from the AGIT Project Template.
* Project-specific initialization completed.
* Documentation cleaned up.
* Initial project structure established.

---

## v0.2.0 – Architecture

Completed.

Main results:

* Overall project architecture defined.
* Modular engine concept established.
* Conceptual system architecture documented in `docs/architecture.md`.
* Overall architecture decision recorded in `docs/decisions/ADR-0001-overall-architecture.md`.
* Project documentation aligned with the AGIT Project Template v1.0.5.
* Collaboration Model updated to v1.3.

---

## v0.3.0 – Boot Profile Detection Proof of Concept

Completed.

Main results:

* Reversible Windows Boot Manager entries for Mode A and Mode B validated.
* Current boot profile detection validated using GUID-based BCD identifier mapping with description fallback.
* Automatic startup detection validated using a Windows Scheduled Task with an `AtStartup` trigger.
* Profile-specific startup script execution validated for Mode A and Mode B.
* Proof-of-concept findings documented in `docs/poc/a5-findings.md`.
* Boot profile detection strategy recorded in `docs/decisions/ADR-0002-boot-profile-detection.md`.

---

## v0.4.0 – Boot Profile Detection

Completed.

Main results:

* The resolver identifies the selected boot profile and writes structured state only.
* The resolver must not apply configuration, execute profile scripts or modify system state.
* Resolver output is written as JSON to `state/current-boot-profile.json`.
* GUID-based detection remains primary; description-based detection remains as fallback.
* Normal unmanaged Windows startup should produce `detected = false` and exit successfully.
* `scripts/Resolve-BootProfile.ps1` is the new resolver entry point.
* `scripts/Invoke-BootProfileStartupHook.ps1` uses `scripts/Resolve-BootProfile.ps1`.
* `scripts/Get-CurrentBootProfile.ps1` remains as the validated proof-of-concept path for now, but is no longer the startup hook detection path.
* Boot menu installation must detect existing BootProfile Switcher BCD entries and interactively offer cleanup before creating fresh entries, so repeated installation does not create duplicate Mode A/Mode B entries.

Validation note:

* The interactive cleanup path has been validated with an existing managed boot menu. The installer removed the previous Mode A and Mode B BCD entries, archived the old `state/boot-menu.json`, created fresh entries and `scripts/Get-BootProfileMenuStatus.ps1` reported exactly one managed Mode A entry and one managed Mode B entry afterward.
* `scripts/Resolve-BootProfile.ps1` has been validated for managed Mode A and managed Mode B using GUID-based current BCD entry mapping.
* The startup hook resolver path has been validated manually in an elevated PowerShell session for managed Mode B. `scripts/Invoke-BootProfileStartupHook.ps1` resolved Mode B through `scripts/Resolve-BootProfile.ps1`, executed `profiles/mode-b/startup.ps1` and logged no resolver error.

---

## v0.5.0 – Profile Engine

Completed.

Main results:

* Decide how resolver output should be consumed by the engine.
* The first profile engine step should introduce a dedicated engine entry point without adding configuration files yet.
* `scripts/Invoke-ProfileEngine.ps1` consumes `state/current-boot-profile.json`.
* The startup hook should orchestrate `Resolve-BootProfile.ps1` followed by `Invoke-ProfileEngine.ps1`.
* Existing harmless `profiles/mode-*/startup.ps1` scripts remain the execution target for now.
* Built-in system-changing flags, custom script configuration and Group Policy distribution are intentionally postponed to later milestones.

Validation note:

* `scripts/Invoke-ProfileEngine.ps1` has been validated directly with managed Mode B resolver state and with a `detected = false` resolver state.
* The startup hook has been validated manually in an elevated PowerShell session for managed Mode B after the engine split. `scripts/Invoke-BootProfileStartupHook.ps1` resolved Mode B, invoked `scripts/Invoke-ProfileEngine.ps1`, executed `profiles/mode-b/startup.ps1` and logged the engine state path.
* The startup hook has been validated manually in an elevated PowerShell session for managed Mode A after the engine split. `scripts/Invoke-BootProfileStartupHook.ps1` resolved Mode A, invoked `scripts/Invoke-ProfileEngine.ps1`, executed `profiles/mode-a/startup.ps1` and logged the engine state path.

---

## v0.6.0 – Module System

Completed.

Main results:

* Keep module behavior explicit, reversible and independently testable.
* Preserve the current harmless profile-script validation flow while module boundaries are designed.
* The first module should be harmless and validate the module boundary without changing system configuration.
* `modules/validation-log/Invoke-ValidationLogModule.ps1` is the initial module.
* `scripts/Invoke-ProfileEngine.ps1` invokes modules through an internal module registry after the existing harmless profile startup script.
* The startup hook logs which modules were executed.
* Module configuration, real system-changing modules and Group Policy distribution remain postponed.

Validation note:

* The validation module has been validated directly through `scripts/Invoke-ProfileEngine.ps1` for managed Mode A.
* The startup hook module path has been validated manually in an elevated PowerShell session for managed Mode A. `scripts/Invoke-BootProfileStartupHook.ps1` resolved Mode A, invoked the profile engine, executed `profiles/mode-a/startup.ps1`, invoked `modules/validation-log/Invoke-ValidationLogModule.ps1` and logged `modulesExecuted=validation-log`.
* The internal module registry path has been validated directly through `scripts/Invoke-ProfileEngine.ps1` and through the startup hook for managed Mode A.

---

## v0.7.0 – Configuration

Completed.

Main results:

* Keep configuration suitable for future enterprise deployment and Group Policy distribution.
* Preserve deterministic behavior when configuration is missing, invalid or incomplete.
* The default machine-wide configuration path is `%ProgramData%\BootProfileSwitcher\config\profiles.json`.
* Development and validation can use an explicit `-ConfigPath` override.
* The first schema is JSON with `schemaVersion = 1` and a `profiles` array.
* Each profile has `name`, `mode`, `modules` and `scripts`.
* Profile names and modes must be unique.
* Modules must reference known modules; currently only `validation-log` is known.
* Custom script paths are structurally accepted as a list but are not executed in v0.7.x.
* The engine continues to use its internal module registry until configuration adoption is intentionally implemented.
* `scripts/Invoke-ProfileEngine.ps1` validates configuration during execution but does not use configuration for dispatch decisions yet.

Immediate validation target:

* Validate `config/profiles.example.json` with `scripts/Test-BootProfileConfiguration.ps1`.

Validation note:

* `config/profiles.example.json` has been validated successfully with `scripts/Test-BootProfileConfiguration.ps1 -ConfigPath .\config\profiles.example.json -AsJson`.
* The default `%ProgramData%\BootProfileSwitcher\config\profiles.json` path has been checked when missing. The validator returns `valid = false`, reports the missing file and exits with code 1.

Next validation target:

* Validate known-good and known-bad configuration fixtures with `scripts/Test-BootProfileConfigurationFixtures.ps1`.

Validation note:

* `scripts/Test-BootProfileConfigurationFixtures.ps1 -AsJson` has been validated with five fixtures: one valid example and four invalid cases for duplicate profile name, duplicate mode, missing `scripts` array and unknown module. The runner reported `passed = true`, `total = 5` and `failed = 0`.

Next validation target:

* Validate that `scripts/Invoke-ProfileEngine.ps1` reports configuration validation results without changing profile script or module dispatch behavior.

Validation note:

* `scripts/Invoke-ProfileEngine.ps1 -ConfigPath .\config\profiles.example.json` has been validated with `configurationValid = true`, `configurationValidationExitCode = 0`, unchanged profile script execution and unchanged `validation-log` module execution.
* `scripts/Invoke-ProfileEngine.ps1` has been validated with the missing default `%ProgramData%\BootProfileSwitcher\config\profiles.json` path. It reports `configurationValid = false` and `configurationValidationExitCode = 1` while preserving existing internal-registry execution behavior.
* The startup hook runtime path has been validated manually in an elevated PowerShell session for managed Mode A. It logs `configurationValid=False` for the missing ProgramData config while still resolving Mode A and executing the existing profile script plus `validation-log` module.

---

# Current Development Roadmap

## v0.8.0 – Integration

Completed.

Main results:

* Use validated configuration as the dispatch source for harmless modules.
* Treat missing, invalid or incomplete configuration as a successful no-op with explicit reporting and startup logging.
* Avoid implicit fallback execution when the machine-wide profile configuration is not usable.
* Provide a controlled installer for the default machine-wide `profiles.json`.
* Keep custom script execution postponed until its safety and logging model is explicit.

Validation note:

* `scripts/Invoke-ProfileEngine.ps1` has been validated with a valid example configuration, a missing configuration file and an invalid configuration fixture. Valid configuration dispatches `validation-log`; missing or invalid configuration executes no modules and no profile scripts while reporting `dispatchSkippedReason = configuration-invalid`.
* `scripts/Install-BootProfileConfiguration.ps1 -WhatIf` has been validated with the example configuration and with an invalid fixture. Valid configuration reaches the planned install operation; invalid configuration is rejected before installation.
* The elevated startup-hook runtime path has been validated for managed Mode A with the installed ProgramData configuration. The startup log reported `configurationValid=True`, `profileConfigured=True`, `modulesExecuted=validation-log`, `profileScriptExecuted=False` and no dispatch skip reason.

---

## Planned Future Milestones

Current planning:

* v1.2.0 – Configuration Format v2
* v1.3.0 – Boot Menu From Configuration
* Later module milestone – Service Control module for configurable Windows service enable/disable behavior

The roadmap may evolve based on research findings.

## v1.2.0 – Configuration Format v2

Planned.

Main target:

* Design a second configuration format that can support variable managed boot profiles, configuration-driven boot menu creation and future production modules.
* Keep the milestone focused on configuration design, validation and documentation. Runtime boot menu creation from the new format is planned for v1.3.0.
* Preserve deterministic no-op behavior when configuration is missing, invalid or incomplete.

Default profile design:

* The Windows default boot entry is not a normal BootProfile Switcher profile.
* The default profile is the system's recovery and return path and must be treated more conservatively than managed profiles.
* Configuration Format v2 should model default boot behavior through constrained global boot menu settings, not through normal profile modules or scripts.
* The default profile may later support only carefully scoped options such as display name changes or hiding from the boot menu if those operations prove technically safe and reversible.
* Any future modification of the default boot entry must store enough baseline state to restore the desired normal system state during uninstall.
* The Network Isolation baseline/restore model is the reference lesson: before changing system state, store the previous normal state; do not accidentally learn a manipulated state as normal; make removal traceable and reversible.

Configuration topics to settle:

* Whether managed profiles use `id`, `mode` or both.
* How display names, boot menu titles and internal identifiers are represented.
* How profile-local module settings are represented without requiring global module defaults.
* How boot menu order, timeout and source entry are represented.
* How custom scripts remain represented while execution stays postponed.
* How future modules such as Service Control can express profile-specific policy without redesigning the format again.

Acceptance criteria:

* `config/profiles.v2.example.json` documents the v2 shape.
* `scripts/Test-BootProfileConfiguration.ps1` validates the v2 shape while preserving v1 validation.
* Valid and invalid v2 fixtures cover duplicate profile identifiers, duplicate display names, invalid default-profile settings, invalid module settings, legacy v1 fields, unknown properties, invalid profile IDs, empty module sets and invalid script entries.
* Documentation explains the distinction between the Windows default boot entry and managed BootProfile Switcher profiles.
* v1.3.0 can use the v2 format as the source for configuration-driven boot menu installation.

## v1.1.0 – Network Isolation

Completed.

Main target:

* Introduce `network-isolation` as the first production-oriented lifecycle module.
* Keep the module configuration-driven and suitable for enterprise deployment.
* Allow Ethernet, Wi-Fi, cellular and Bluetooth network isolation to be controlled separately.
* Default the example configuration to `dryRun = true` so adapter decisions can be validated before real disable operations.
* Support exclusions by MAC address, interface description and interface alias.
* Allow profile-specific Network Isolation overrides; `disable` and `dryRun` override global defaults, while `exclude` entries are additive.
* Target hardware interfaces by default; Bluetooth network adapters are an explicit opt-in exception, while VPN, tunnel, loopback and virtual adapters are logged and skipped.
* Treat Bluetooth radio or USB Bluetooth adapter device isolation as out of scope for `network-isolation`; that belongs in a later Bluetooth/device isolation module.
* Treat `network-isolation` as a lifecycle module with a persistent normal adapter baseline at `%ProgramData%\BootProfileSwitcher\state\network-isolation-state.json`.
* Learn the current hardware adapter snapshot as the normal baseline only when the previous run was not isolating, even if the current run will isolate afterward.
* Restore the saved baseline when the previous run was isolating and the current run is not isolating.
* Document that v1.1.0 is adapter-level isolation and not a complete security boundary against local administrators or privileged tooling.
* Provide an installable module demo with one managed boot profile named `Network Isolation`.
* Establish the project convention that production modules should include a small installable demo when practical.
* Keep the main READMEs concise and document substantial module behavior in dedicated module docs under `docs/modules/`.

Validation note:

* The module has been dry-run tested locally. It logged baseline learning as `would-update-baseline`, WLAN and the active Intel Ethernet adapter as `would-disable`, skipped VPN and virtual adapters as `not-hardware-interface`, and skipped a not-present Realtek Ethernet adapter as `not-present`.
* A real Mode A test disabled WLAN, the active Intel Ethernet adapter and the Bluetooth PAN adapter. It also showed that restore must use adapter administrative state because disabled adapters can be reported as `Not Present`; the implementation has been updated accordingly.
* The full lifecycle has been validated manually: normal startup learned the baseline, Mode A disabled WLAN, Bluetooth PAN and the active Intel Ethernet adapter, and the following normal startup restored those adapters.

Follow-up roadmap note:

* A later Network Isolation hardening milestone should evaluate Group Policy restrictions, network UI restrictions, device-management controls, service controls and firewall enforcement so isolated profiles can be made harder to bypass in enterprise deployments.
* A later Bluetooth/device isolation milestone should evaluate how to disable Bluetooth radios or USB Bluetooth adapters when that is required in addition to Bluetooth network adapter isolation.

## Later Module Candidate – Service Control

Planned after the next structural milestones.

Initial idea:

* Add a production module that can disable or restore configured Windows services for selected boot profiles.
* Target services by service name, similar in spirit to how Network Isolation uses explicit adapter policy and exclusions.
* Initial use cases include disabling services such as Windows Update or Bitdefender components during experimental profiles so background activity does not interfere with tests.
* The configuration model should support profile-specific service lists and should be suitable for enterprise deployment.
* The module must define restore behavior carefully before implementation, because service startup type and running state may both matter.

## v1.0.0 – Initial Stable Release

Completed.

Main results:

* Define the initial stable release as a validated foundation release, not as a production system-changing module release.
* Include reversible boot menu setup, startup hook integration, machine-wide configuration, configuration-driven module dispatch and predictable action/no-op logging.
* Include `validation-log` and the temporary `demo-system-marker` module for the release demonstration.
* Add combined `install-demo.cmd` and `uninstall-demo.cmd` wrappers while preserving individual setup and teardown wrappers.
* Document included behavior, explicit exclusions, safety expectations and release readiness in `docs/release/v1.0.0-release-scope.md`.

Validation note:

* The configuration-driven runtime path was validated in v0.9.0.
* The temporary `demo-system-marker` module was validated through the real managed Mode A startup-hook path before v1.0.0.
* The release keeps production modules that change Windows behavior intentionally out of scope.

## v0.9.0 – Validation

Completed.

Main results:

* Validate the configuration-driven runtime path through repeatable manual checks.
* Keep validation harmless; no real system-changing module is introduced in this milestone.
* Use `docs/validation/v0.9-validation-checklist.md` as the primary validation reference.

Validation note:

* V1 through V8 in `docs/validation/v0.9-validation-checklist.md` have been validated on 2026-06-28.
* Validated cases include configuration fixtures, installed ProgramData configuration, Mode A runtime, Mode B runtime, missing configuration no-op, invalid configuration no-op, normal Windows startup no-op and reinstall safety.
* Runtime validation confirmed `profileScriptExecuted=False` and configuration-driven `modulesExecuted=validation-log` for managed Mode A and Mode B.
* No-op validation confirmed empty `modulesExecuted`, `profileScriptExecuted=False` and explicit `dispatchSkippedReason` values for missing/invalid configuration and unmanaged Windows startup.

---

## Future Configuration Goals

Long-term configuration and deployment goals:

* Support a variable number of managed boot profiles in addition to the normal Windows/default profile.
* Allow freely chosen profile names, while validating that profile names are unique.
* Evaluate whether the normal Windows/default profile can be hidden from the boot menu. If hiding is not supported or not desirable, evaluate whether renaming the default profile is a better supported option.
* Support profile-specific boolean feature flags. Each flag represents a known, explicitly implemented system change, such as disabling selected network connections or applying supported system settings.
* Support profile-specific custom PowerShell scripts in addition to built-in feature flags. Profiles should be able to reference an arbitrary number of script files by path.
* Keep configuration suitable for enterprise deployment, especially distribution through Group Policy.

These goals are realistic, but they imply a production configuration model, validation layer, deployment location and policy story that should be designed before system-changing modules are implemented.

---

# Architecture Status

The conceptual architecture has been established.

Implementation has validated boot menu creation, detection and startup execution.

The project has validated that the selected Windows Boot Manager entry can be identified after startup using the current BCD entry identifier and managed BootProfile Switcher state. The startup hook now uses the dedicated resolver and dispatches configuration-selected modules through the profile engine when the machine-wide profile configuration is valid.

---

# Open Decisions

The following questions remain intentionally unanswered:

* Which execution point is most suitable before user logon?
* Which Windows components should be used instead of custom solutions whenever possible?
* Which parts should remain extensible through modules?
* What should the first production-oriented profile engine configuration schema look like?

These decisions will be evaluated during later milestones.

---

# AGIT Environment

## AGIT Project Template

Current version:

**v1.1.0**

---

## Collaboration Model

Current version:

**v1.12**

---

## Working Principles

This project follows the AGIT Collaboration Model.

Key principles include:

* Repository-first workflow.
* Research before implementation.
* Architecture before code.
* Small, meaningful commits.
* Semantic Versioning.
* Version tags mark meaningful project milestones.
* GitHub Releases are created intentionally and not required for every tag.
* Commit requests imply actual implementation and repository-ready deliverables.
* Completion Integrity: work is only considered complete once the agreed deliverables actually exist.
* Artifact integrity and capability transparency: generated artifacts, validation results and limitations must be reported accurately.
* Long-running sessions should preserve enough context for a useful `PROJECT_CONTEXT.md` handoff.
* Commit-ready handoffs should use concise numbered maintainer next steps when useful.
* Active milestones should progress through small implement-validate-adjust-commit loops.
* Assistant-written code must be documented and structured so maintainers and future contributors can understand it without private chat history.
* User-facing documentation should explain setup, configuration, productive usage, reference surfaces and troubleshooting where relevant.
* Local Codex work follows `CODEX.md`, including read-only Git usage by default.

---

# Next Immediate Task

Plan **v1.2.0 – Configuration Format v2**.

Primary objective:

Design the next configuration format so managed boot profiles, profile-local module settings and later module types can be represented cleanly.

Immediate next validation target:

Define the concrete questions and acceptance criteria for v1.2.0 before implementation starts.

---

# Notes

This document intentionally represents the **current state** of the project.

It is **not** a historical log and should be updated whenever the project reaches a new milestone, the current development focus changes or a future collaboration session needs a reliable re-entry point.

Its purpose is to enable any future contributor—or a new ChatGPT conversation—to resume development immediately from the current project state.
