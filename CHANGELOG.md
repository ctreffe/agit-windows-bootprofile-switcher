# Changelog

All notable changes to this project will be documented in this file.

This project follows Semantic Versioning.

## [Unreleased]

### Added

- Add a read-only Service and Startup Control discovery document and inventory script for v1.4.0 planning.

### Changed

- Define v1.4.0 as a Service and Startup Control Discovery milestone before implementing service-control behavior.

## [v1.3.0] - 2026-06-30

### Added

- Add ADR-0006 documenting configuration-driven boot menu installation.
- Add a config-driven boot menu demo with multiple managed profiles and hidden default-entry behavior.

### Changed

- Make boot menu installation read Configuration Format v2 directly.
- Add non-interactive cleanup support for managed boot menu replacement.
- Extend resolver and profile engine compatibility for v2-generated boot menu state.
- Remove legacy Configuration Format v1 validation and runtime dispatch compatibility.
- Migrate active Network Isolation configuration fixtures and demos to Configuration Format v2.
- Harmonize project status documentation for the completed v1.3.0 milestone.
- Record successful real-system validation of the config-driven boot menu demo and Network Isolation demo uninstall restore path.
- Expand Configuration Format v2 documentation with practical editing guidance, safe workflow notes and troubleshooting for less experienced users.

### Fixed

- Restore the Network Isolation adapter baseline during demo uninstall before removing the startup hook and demo configuration.

## [v1.2.0] - 2026-06-30

### Added

- Add validated Configuration Format v2 example and documentation.
- Add v2 configuration validation coverage for managed profile identity, display names, default-entry settings and module settings.
- Add v2 hardening fixtures for legacy fields, unknown properties, invalid profile IDs, empty modules and invalid script entries.
- Add ADR-0005 documenting the Configuration Format v2 decision.

### Changed

- Extend the configuration validator and fixture runner to support `schemaVersion = 2` while preserving v1 validation.
- Tighten v2 validation by rejecting legacy profile fields, unsupported top-level properties, invalid profile identifiers, empty module sets and non-string script entries.

## [v1.1.0] - 2026-06-28

### Added

- Add ADR-0004 documenting Network Isolation as a lifecycle module with persistent baseline state.
- Add the `network-isolation` module as the first production-oriented lifecycle module.
- Add global `moduleSettings.network-isolation` configuration for `dryRun`, adapter category flags and exclusions.
- Add profile-specific Network Isolation overrides with additive exclusions.
- Add persistent Network Isolation baseline state design for learning normal adapter state and restoring it after isolation.
- Add validation coverage for required `network-isolation` settings.
- Document the v1.1.0 Network Isolation security boundary and future hardening direction.
- Document that Bluetooth PAN isolation does not disable Bluetooth radio or USB Bluetooth adapter devices.
- Add an installable Network Isolation module demo with one managed `Network Isolation` boot profile.
- Add the convention that production modules should include a small installable demo when practical.
- Add dedicated English and German Network Isolation module documentation.

### Changed

- Register `network-isolation` as a known module and include it in the example profile configuration with `dryRun` enabled.
- Pass optional module settings and lifecycle context from the profile engine to module entry points.
- Restore Network Isolation baseline state using adapter administrative state instead of treating `Not Present` as always unavailable.
- Record successful real lifecycle validation for Network Isolation baseline learning, isolation and restore.

## [v1.0.0] - 2026-06-28

### Added

- Add the temporary `demo-system-marker` module for the v1.0.0 release demonstration.
- Add a v1.0.0 release scope document defining included behavior, exclusions, safety expectations and readiness checks.
- Add `install-demo.cmd` and `uninstall-demo.cmd` wrappers for the current v1.0.0 demo setup flow.

### Changed

- Register `demo-system-marker` as a known module and include it in the example profile configuration.
- Record successful Mode A runtime validation for the temporary `demo-system-marker` module.

## [v0.9.0] - 2026-06-28

### Added

- Add a repeatable v0.9 validation checklist with expected runtime log assertions.

### Changed

- Record successful V1 through V8 validation for the configuration-driven runtime path.

## [v0.8.0] - 2026-06-28

### Added

- Add `scripts/Install-BootProfileConfiguration.ps1` and `install-configuration.cmd` for controlled installation of validated machine-wide profile configuration.

### Changed

- Make `scripts/Invoke-ProfileEngine.ps1` use valid profile configuration for module dispatch.
- Treat missing, invalid or incomplete profile configuration as an explicitly logged no-op instead of falling back to implicit profile actions.
- Harmonize the project collaboration model with AGIT Project Template v1.1.0 and Collaboration Model v1.12.
- Update project context and philosophy guidance for context handoff discipline, milestone work rhythm, code documentation and user-facing documentation.
- Align local Codex policy references with the documents that remain in this derived repository.
- Expand README command and configuration reference material for the current validation state.
- Refresh script help text to describe current managed boot menu, startup hook and validation-script roles.

## [v0.7.0] - 2026-06-28

### Added

- Add the first example profile configuration schema at `config/profiles.example.json`.
- Add `scripts/Test-BootProfileConfiguration.ps1` to validate the initial configuration schema without applying changes.
- Add configuration validation fixtures and a lightweight fixture runner for valid and invalid schema cases.

### Changed

- Update the profile engine to validate configuration during execution without using it for dispatch decisions yet.
- Mark the Configuration milestone as completed after validating schema, fixtures and runtime configuration checks.

## [v0.6.0] - 2026-06-28

### Added

- Add the initial harmless `validation-log` module.

### Changed

- Update the profile engine to invoke the validation module while preserving existing profile script validation.
- Refactor module invocation through an internal module registry.
- Mark the Module System milestone as completed after successful validation module and internal registry validation.

## [v0.5.0] - 2026-06-28

### Added

- Add `scripts/Invoke-ProfileEngine.ps1` as the initial profile engine entry point.

### Changed

- Update the startup hook to invoke the profile engine after resolving the selected boot profile.
- Mark the Profile Engine milestone as completed after successful Mode A and Mode B engine validation.

## [v0.4.0] - 2026-06-28

### Added

- Add `scripts/Resolve-BootProfile.ps1` as a dedicated boot profile resolver that writes structured state to `state/current-boot-profile.json`.
- Add ADR-0003 documenting the boot profile resolver boundary and resolver output contract.
- Add interactive install-time detection and cleanup for existing BootProfile Switcher BCD entries to avoid duplicate Mode A/Mode B entries.

### Changed

- Update the startup hook to use the dedicated boot profile resolver instead of the earlier proof-of-concept detection script.
- Mark the Boot Profile Detection milestone as completed after successful Mode A and Mode B resolver validation.

## [v0.3.0] - 2026-06-27

### Added

- Add `CODEX.md` as the local Codex operating policy for this repository.
- Add local tool, Codex workspace and generated artifact ignore rules from the current AGIT Project Template.
- Restore the AI Collaboration Note in both README files with project-specific wording.
- Add A4 profile-specific startup script execution for Mode A and Mode B.
- Add harmless validation profile scripts in `profiles/mode-a/startup.ps1` and `profiles/mode-b/startup.ps1`.
- Add A4 documentation for profile startup script validation.
- Add A3 startup hook proof of concept using a Windows Scheduled Task with an `AtStartup` trigger.
- Add `install-startup-hook.cmd` and `uninstall-startup-hook.cmd` wrappers for managing the A3 startup hook.
- Add `scripts/Invoke-BootProfileStartupHook.ps1` to log automatic startup-time boot profile detection results.
- Add A3 documentation and validation notes for startup-time profile detection.
- Add A2 diagnostic script `scripts/Get-CurrentBootProfile.ps1` to detect the selected BootProfile Switcher mode from the current BCD entry.
- Add A2 inspection script `scripts/Inspect-CurrentBootEntry.ps1` for read-only BCD identifier diagnostics.
- Add A5 proof-of-concept findings documentation.
- Add ADR-0002 documenting the boot profile detection strategy.
- Add double-clickable `detect-current-profile.cmd` wrapper for current profile detection.
- Add A2 documentation and validation notes for current boot profile detection.
- Add double-clickable `install.cmd` and `uninstall.cmd` wrappers that request administrator privileges and invoke the PowerShell boot menu scripts with a process-local execution policy bypass.
- Add A1 Boot Menu proof of concept with reversible PowerShell scripts for creating, inspecting and removing two Windows Boot Manager entries: `BootProfile Switcher - Mode A` and `BootProfile Switcher - Mode B`.
- Add A1 PoC documentation with test procedure and validation notes.
- Add runtime ignore rules for generated `state/` and `backups/` directories.

### Changed

- Update the project Collaboration Model to v1.6 from the AGIT Project Template v1.0.9.
- Align project collaboration context with the current AGIT Project Template version.
- Align project philosophy with current AGIT integrity, validated learning and roadmap discipline guidance.
- Harmonize README and project context status during milestone preparation.
- Mark A4 profile startup script execution as validated for Mode A and Mode B.
- Extend the startup hook to execute the detected profile startup script.
- Mark A3 startup hook detection as validated for Mode A and Mode B.
- Mark A2 current boot profile detection as validated for Mode A and Mode B.
- Use GUID-based current boot profile detection via `bcdedit /enum "{current}" /v`, with description-based detection retained as a fallback.
- Refocus v0.3.0 from generic boot process research to a Boot Profile Detection Proof of Concept.
- Mark v0.3.0 as completed.

### Fixed

- Use `{default}` instead of `{current}` as the BCD copy source so the installer remains reliable after booting from and removing a managed boot entry.
- Fix PowerShell string interpolation in the uninstall script by using `${id}` before a colon in warning output.

## [0.2.0] - 2026-06-27

### Added

- Add conceptual system architecture documentation.
- Add ADR-0001 documenting the overall architecture and documentation model.
- Update README files to reflect the Architecture milestone.

### Changed

- Update the project Collaboration Model to v1.3 from the AGIT Project Template v1.0.5.
- Align project context with the completed Architecture milestone and the next Boot Process research focus.

## [0.1.0] - 2026-06-27

### Added

- Initialize BootProfile Switcher from the AGIT Project Template.
- Add project-specific English and German README files.
- Define the initial project scope and non-goals.
- Define the first project milestone as `0.1.0 Foundation`.
- Adapt the project philosophy for a configurable Windows boot profile engine.
- Set initial project version metadata.
