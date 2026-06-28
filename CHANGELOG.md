# Changelog

All notable changes to this project will be documented in this file.

This project follows Semantic Versioning.

## [Unreleased]

### Added

- Add `scripts/Install-BootProfileConfiguration.ps1` and `install-configuration.cmd` for controlled installation of validated machine-wide profile configuration.

### Changed

- Make `scripts/Invoke-ProfileEngine.ps1` use valid profile configuration for module dispatch.
- Treat missing, invalid or incomplete profile configuration as an explicitly logged no-op instead of falling back to implicit profile actions.
- Harmonize the project collaboration model with AGIT Project Template v1.1.0 and Collaboration Model v1.12.
- Update project context and philosophy guidance for context handoff discipline, milestone work rhythm, code documentation and user-facing documentation.
- Align local Codex policy references with the documents that remain in this derived repository.
- Expand README command and configuration reference material for the current v0.7.0 validation state.
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
