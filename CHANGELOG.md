# Changelog

All notable changes to this project will be documented in this file.

This project follows Semantic Versioning.

## [Unreleased]

### Added

- Add A1 Boot Menu proof of concept with reversible PowerShell scripts for creating, inspecting and removing two Windows Boot Manager entries: `BootProfile Switcher - Mode A` and `BootProfile Switcher - Mode B`.
- Add A1 PoC documentation with test procedure and validation notes.
- Add runtime ignore rules for generated `state/` and `backups/` directories.

### Changed

- Refocus v0.3.0 from generic boot process research to a Boot Profile Detection Proof of Concept.

### Fixed

- Use `{default}` instead of `{current}` as the BCD copy source so the installer remains reliable after booting from and removing a managed boot entry.
- Fix PowerShell string interpolation in the uninstall script by using `${id}` before a colon in warning output.

### Planned

- A2: determine whether Windows can reliably identify which BootProfile Switcher boot entry was selected during startup.
- Evaluate suitable pre-logon execution points.
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
