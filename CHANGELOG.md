# Changelog

All notable changes to this project will be documented in this file.

This project follows Semantic Versioning.

## [Unreleased]

### Added

- Add A4 profile-specific startup script execution for Mode A and Mode B.
- Add harmless validation profile scripts in `profiles/mode-a/startup.ps1` and `profiles/mode-b/startup.ps1`.
- Add A4 documentation for profile startup script validation.
- Add A3 startup hook proof of concept using a Windows Scheduled Task with an `AtStartup` trigger.
- Add `install-startup-hook.cmd` and `uninstall-startup-hook.cmd` wrappers for managing the A3 startup hook.
- Add `scripts/Invoke-BootProfileStartupHook.ps1` to log automatic startup-time boot profile detection results.
- Add A3 documentation and validation notes for startup-time profile detection.
- Add A2 diagnostic script `scripts/Get-CurrentBootProfile.ps1` to detect the selected BootProfile Switcher mode from the current BCD entry description.
- Add double-clickable `detect-current-profile.cmd` wrapper for current profile detection.
- Add A2 documentation and validation notes for current boot profile detection.
- Add double-clickable `install.cmd` and `uninstall.cmd` wrappers that request administrator privileges and invoke the PowerShell boot menu scripts with a process-local execution policy bypass.
- Add A1 Boot Menu proof of concept with reversible PowerShell scripts for creating, inspecting and removing two Windows Boot Manager entries: `BootProfile Switcher - Mode A` and `BootProfile Switcher - Mode B`.
- Add A1 PoC documentation with test procedure and validation notes.
- Add runtime ignore rules for generated `state/` and `backups/` directories.

### Changed

- Mark A4 profile startup script execution as validated for Mode A and Mode B.
- Extend the startup hook to execute the detected profile startup script.
- Mark A3 startup hook detection as validated for Mode A and Mode B.
- Mark A2 current boot profile detection as validated for Mode A and Mode B.
- Refocus v0.3.0 from generic boot process research to a Boot Profile Detection Proof of Concept.

### Fixed

- Use `{default}` instead of `{current}` as the BCD copy source so the installer remains reliable after booting from and removing a managed boot entry.
- Fix PowerShell string interpolation in the uninstall script by using `${id}` before a colon in warning output.

### Planned

- Document resulting architectural decisions as ADRs.

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
