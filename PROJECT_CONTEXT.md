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

**v1.5.0 – Service Control for Windows Search**

The Service Control for Windows Search milestone is complete.

## Current Focus

Plan the next milestone after **v1.5.0 – Service Control for Windows Search**.

v1.4.0 identified the real local control surfaces for Windows Update, Bitdefender, Teams, OneDrive, ownCloud, Outlook and Windows Search indexing before implementing control logic.

Completed v1.4.0 results:

* `scripts/Inspect-ServiceStartupControlTargets.ps1` collects a read-only inventory of service, scheduled task, startup registry, startup-folder and process matches.
* ADR-0007 documents the Service and Startup Control modularization decision.
* `docs/discovery/service-startup-control.md` defines the discovery scope and safe inventory workflow.
* `docs/discovery/service-startup-control-findings.md` records validated local findings and recommends Windows Search / `WSearch` as the first narrow service-control candidate.
* `docs/modules/service-control.md` defines a generic allow-listed `service-control` module design rather than a one-module-per-service approach.
* The initial service-control design questions are resolved: `Disabled`/`Stopped` are the only explicit target values, `Manual`/`Automatic` and delayed automatic startup are restore-only baseline values, dependencies are inspected and logged only, and unsupported service names are configuration errors.

Completed v1.5.0 results:

* `modules/service-control/Invoke-ServiceControlModule.ps1` provides dry-run and controlled apply/restore paths for Windows Search / `WSearch`.
* `scripts/Test-BootProfileConfiguration.ps1` recognizes `service-control`, validates the `WSearch` allow-list and rejects unsupported services.
* `scripts/Invoke-ProfileEngine.ps1` registers and dispatches `service-control` as a lifecycle module from valid profile configuration.
* `config/test/service-control-wsearch-valid.json`, `config/test/service-control-unsupported-service.json` and `config/test/service-control-real-apply-valid.json` cover the first validation cases.
* Direct module and engine-level validation confirmed dry-run logging for baseline inspection, dependency diagnostics and planned `WSearch` target actions without changing service state.
* Controlled elevated real-system validation confirmed baseline learning, apply to `Stopped`/`Disabled` and restore to the learned `Running`/`Auto`/delayed-auto baseline.
* Non-dry-run execution now requires an elevated PowerShell session before state is written, preventing misleading controlling state from failed non-admin real runs.

Next roadmap focus:

* Plan **v1.6.0 – Startup and User-Application Control** for Microsoft Teams, OneDrive, ownCloud and Microsoft Office based on the v1.4.0 discovery results.
* Address all four applications in the milestone through one shared control-surface model where possible, while allowing per-application capability notes when a target cannot be safely controlled through the same mechanism.
* ADR-0008 records the decision to address all four applications through shared startup/user-application control surfaces instead of one module per application.
* `docs/modules/startup-user-application-control.md` defines the initial v1.6.0 module design, baseline model and validation plan.
* `docs/discovery/startup-user-application-control-findings.md` records the elevated read-only v1.6.0 discovery refresh for Teams, OneDrive, ownCloud and Microsoft Office.
* `scripts/Test-BootProfileConfiguration.ps1` validates the first `startup-user-application-control` configuration shape and allow-listed application IDs.
* `modules/startup-user-application-control/Invoke-StartupUserApplicationControlModule.ps1` provides the first read-only dry-run module path and logs planned startup/task actions without changing Windows state.

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

## Current Roadmap

Last completed milestone:

* v1.5.0 – Service Control for Windows Search

Planned next milestone:

* v1.6.0 – Startup and User-Application Control for Teams, OneDrive, ownCloud and Microsoft Office.

Later milestone candidates:

* Network Isolation hardening for policy-backed isolation controls.
* Policy or vendor guidance for Windows Update and Bitdefender.

The roadmap may evolve based on discovery findings.

## v1.3.0 – Boot Menu From Configuration

Completed.

Main target:

* Make `scripts/Install-BootProfileMenu.ps1` read Configuration Format v2 directly.
* Use `%ProgramData%\BootProfileSwitcher\config\profiles.json` as the default configuration source and allow `-ConfigPath` overrides for demos, tests and migration workflows.
* Install managed boot entries for v2 profiles where `bootMenu.enabled = true`.
* Apply constrained default-entry behavior from `bootMenu.defaultEntry` where technically safe: rename and hide.
* Store enough boot menu baseline state for uninstall to restore the default entry description and display order.
* Support enterprise automation through explicit cleanup and force switches.
* Keep local interactive cleanup available when existing managed entries are detected.
* Provide a config-driven boot menu demo with hidden or renamed default entry behavior and multiple named managed profiles.

Acceptance criteria:

* Boot menu installation no longer hardcodes Mode A and Mode B.
* Existing managed entries can be cleaned up interactively or automatically with explicit switches.
* `state/boot-menu.json` records v2 profile identities, display names, BCD identifiers, source entry, timeout, configuration path and default-entry baseline.
* Resolver and runtime matching remain compatible with v2-generated state.
* Uninstall removes managed entries and restores the default entry to the intended normal boot menu state.
* Documentation and demo files explain the config-driven installation workflow.
* ADR-0006 documents the configuration-driven boot menu installation decision.
* Legacy Configuration Format v1 validation and runtime dispatch compatibility are removed after v2 is validated as the active configuration format.

Validation status:

* Local repository validation passed: all 16 configuration fixtures pass with `scripts/Test-BootProfileConfigurationFixtures.ps1 -AsJson`.
* Local PowerShell parser validation passed for all `.ps1` files under `scripts`, `modules` and `profiles`.
* Maintainer validation on another local system confirmed that the config-driven boot menu demo can be installed, tested and uninstalled.
* Maintainer validation confirmed that the Network Isolation demo can be installed and can disable configured adapters.
* Network Isolation demo uninstall initially removed boot menu/profile infrastructure without restoring disabled adapters. This was fixed in `scripts/Uninstall-NetworkIsolationDemo.ps1` by running a non-isolating restore before removing the startup hook and demo configuration.
* Maintainer real-system validation confirmed that the fixed Network Isolation demo uninstall restores the adapter baseline successfully.

## v1.2.0 – Configuration Format v2

Completed.

Main target:

* Design a second configuration format that can support variable managed boot profiles, configuration-driven boot menu creation and future production modules.
* Keep the milestone focused on configuration design, validation and documentation. Runtime boot menu creation from the new format is planned for v1.3.0.
* Preserve deterministic no-op behavior when configuration is missing, invalid or incomplete.

Default profile design:

* The Windows default boot entry is not a normal BootProfile Switcher profile.
* The default profile is the system's recovery and return path and must be treated more conservatively than managed profiles.
* Configuration Format v2 models default boot behavior through constrained global boot menu settings, not through normal profile modules or scripts.
* The default profile may later support only carefully scoped options such as display name changes or hiding from the boot menu if those operations prove technically safe and reversible.
* Any future modification of the default boot entry must store enough baseline state to restore the desired normal system state during uninstall.
* The Network Isolation baseline/restore model is the reference lesson: before changing system state, store the previous normal state; do not accidentally learn a manipulated state as normal; make removal traceable and reversible.

Resolved configuration decisions:

* Managed profiles use stable lowercase `id` values and explicit `displayName` values.
* The Windows default boot entry is represented only through constrained `bootMenu.defaultEntry` settings, not as a managed profile.
* Module settings are profile-local under each profile's `modules` object.
* Global module defaults are intentionally not part of v2.
* Custom scripts remain represented as paths while execution stays postponed.
* Boot menu order, timeout and source entry are represented in the v2 shape for later v1.3.0 implementation.

Acceptance criteria:

* `config/profiles.v2.example.json` documents the v2 shape.
* `scripts/Test-BootProfileConfiguration.ps1` validates the v2 shape while preserving v1 validation.
* Valid and invalid v2 fixtures cover duplicate profile identifiers, duplicate display names, invalid default-profile settings, invalid module settings, legacy v1 fields, unknown properties, invalid profile IDs, empty module sets and invalid script entries.
* Documentation explains the distinction between the Windows default boot entry and managed BootProfile Switcher profiles.
* ADR-0005 documents the Configuration Format v2 decision.
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

## v1.5.0 – Service Control for Windows Search

Completed.

Purpose:

* Implement the first production `service-control` lifecycle module for Windows Search / `WSearch`.
* Keep `service-control` generic and allow-listed rather than creating one module per service.
* Support dry-run diagnostics, real apply to `Stopped`/`Disabled`, baseline learning and later restore.
* Require elevated PowerShell for non-dry-run service changes before writing controlling state.

Validation status:

* `scripts/Test-BootProfileConfigurationFixtures.ps1` passes all configuration fixtures, including supported `WSearch`, unsupported service rejection and real-apply configuration.
* Direct module and engine-level dry-run validation confirmed baseline inspection, dependency diagnostics and planned target actions without changing service state.
* Controlled elevated real-system validation confirmed `WSearch` can be changed from `Running`/`Auto`/delayed automatic startup to `Stopped`/`Disabled` and restored to the learned baseline.
* A non-admin real run now fails before state is written, preventing a misleading controlling state when elevation is missing.

## v1.4.0 – Service and Startup Control Discovery

Completed.

Purpose:

* Inventory the real local control surfaces for Windows Update, Bitdefender, Teams, OneDrive, ownCloud, Outlook and Windows Search indexing before implementing control logic.
* Separate system services from scheduled tasks, per-user startup entries, running user processes, vendor-protected security components and policy-managed components.
* Decide which targets are suitable for a first production module and which require separate modules or policy guidance.
* Define the safety model, baseline state and restore behavior for any service-control implementation.

Initial target categories:

* `service-control`: Windows services with explicit service names, startup type and running-state restore.
* `startup-control` or `user-app-control`: per-user startup applications such as Teams, OneDrive, ownCloud and Outlook, if needed after discovery.
* `policy-or-vendor-guidance`: components such as Bitdefender or Windows Update where direct service stopping may be unreliable, unsupported or blocked by self-protection.

Known initial target interests:

* Windows Update.
* Bitdefender.
* Microsoft Teams.
* OneDrive.
* ownCloud.
* Outlook.
* Windows Search / drive indexing.

Intentional non-goals for v1.4.0:

* Do not disable or kill services, processes or security components during discovery.
* Do not bypass vendor tamper protection or Windows self-healing behavior.
* Do not treat per-user applications as normal Windows services without verifying their actual startup mechanism.
* Do not implement the production `service-control` module until discovery has identified safe first targets and restore requirements.

Expected validation:

* Produce a local inventory of relevant services, scheduled tasks, startup entries and running processes.
* Classify each requested target by control surface and risk.
* Recommend the first implementable module scope, likely starting with robust system services such as Windows Search indexing.
* Record unsupported or postponed targets explicitly as validated project knowledge.

Initial discovery artifacts:

* `docs/discovery/service-startup-control.md` defines the v1.4.0 discovery scope and safe inventory workflow.
* `docs/discovery/service-startup-control-findings.md` records the first local discovery findings and recommends Windows Search / `WSearch` as the first narrow service-control candidate.
* `docs/modules/service-control.md` designs a generic `service-control` module with `WSearch` as the first supported service, not a one-module-per-service approach.
* `scripts/Inspect-ServiceStartupControlTargets.ps1` collects a read-only JSON inventory for the current target interests.
* `docs/decisions/ADR-0007-service-and-startup-control-modularization.md` records the decision to separate service control, startup control, user-application control and policy/vendor guidance.

Validation status:

* Local read-only inventory found Windows Search / `WSearch` as the clearest first `service-control` candidate.
* Windows Update was found across `BITS`, `DoSvc`, `UsoSvc`, `WaaSMedicSvc`, `wuauserv` and several update scheduled tasks; it remains classified as `policy-or-vendor-guidance`.
* Bitdefender was found across multiple endpoint/security services and remains classified as `policy-or-vendor-guidance`.
* Teams, OneDrive, ownCloud and Outlook were found through startup entries, scheduled tasks or running user-application processes rather than as first service-control candidates.
* The discovery inventory matching was tightened after initial validation to avoid broad update-task and Bitdefender false positives.
* The first `service-control` design questions are resolved: `Disabled`/`Stopped` are the only explicit target values, `Manual`/`Automatic` and delayed automatic startup are restore-only baseline values, dependencies are inspected and logged only, and unsupported service names are configuration errors.

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

Plan **v1.6.0 – Startup and User-Application Control**.

Primary objective:

Define the startup/user-application control design for Microsoft Teams, OneDrive, ownCloud and Microsoft Office as one milestone with shared module boundaries and per-application capability notes.

Immediate next validation target:

Design the baseline and restore model for real startup-surface changes after the validated dry-run path.

---

# Notes

This document intentionally represents the **current state** of the project.

It is **not** a historical log and should be updated whenever the project reaches a new milestone, the current development focus changes or a future collaboration session needs a reliable re-entry point.

Its purpose is to enable any future contributor—or a new ChatGPT conversation—to resume development immediately from the current project state.
