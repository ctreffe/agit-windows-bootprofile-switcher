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

**v0.3.0 – Boot Profile Detection Proof of Concept**

The Boot Profile Detection Proof of Concept milestone is complete.

## Current Focus

Prepare the next milestone after the validated proof of concept.

The completed proof of concept validated whether a Windows Boot Manager selection can be used as the basis for selecting a boot profile before user logon.

A1 has established a reversible boot menu with two entries:

* BootProfile Switcher - Mode A
* BootProfile Switcher - Mode B

A1 validation also showed that the installer should copy `{default}` rather than `{current}` because `{current}` can become invalid after booting from and removing a managed proof-of-concept entry. Usability has been improved with double-clickable `install.cmd` and `uninstall.cmd` wrappers that request elevation and call the PowerShell scripts.

A2 has been validated for Mode A and Mode B. `scripts/Get-CurrentBootProfile.ps1` detects the current BootProfile Switcher mode by reading the real `{current}` BCD object identifier from verbose `bcdedit` output and mapping it to the managed A1 state file. Description-based detection remains available as a fallback.

A3 has been validated for Mode A and Mode B. A Windows Scheduled Task with an `AtStartup` trigger runs the BootProfile Switcher detection automatically during system startup and writes the selected mode to `logs/startup-profile.log`.

A4 has been validated for Mode A and Mode B. The startup hook now executes profile-specific startup scripts from `profiles/mode-a/startup.ps1` and `profiles/mode-b/startup.ps1`. These scripts intentionally perform harmless validation logging to `logs/profile-startup-actions.log`.

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

# Current Development Roadmap

## v0.4.x – Boot Profile Detection

Planned focus:

* Turn the proof-of-concept detection path into a cleaner boot profile resolver.
* Decide which description-based fallback behavior should remain in the production design.
* Refine startup execution requirements for the final profile engine.

Initial decisions for v0.4.x:

* The resolver identifies the selected boot profile and writes structured state only.
* The resolver must not apply configuration, execute profile scripts or modify system state.
* Resolver output is written as JSON to `state/current-boot-profile.json`.
* GUID-based detection remains primary; description-based detection remains as fallback.
* Normal unmanaged Windows startup should produce `detected = false` and exit successfully.
* `scripts/Resolve-BootProfile.ps1` is the new resolver entry point.
* `scripts/Get-CurrentBootProfile.ps1` remains as the validated proof-of-concept path until the resolver has been tested and adopted.
* Boot menu installation must detect existing BootProfile Switcher BCD entries and interactively offer cleanup before creating fresh entries, so repeated installation does not create duplicate Mode A/Mode B entries.

Validation note:

* The interactive cleanup path has been validated with an existing managed boot menu. The installer removed the previous Mode A and Mode B BCD entries, archived the old `state/boot-menu.json`, created fresh entries and `scripts/Get-BootProfileMenuStatus.ps1` reported exactly one managed Mode A entry and one managed Mode B entry afterward.

---

## Planned Future Milestones

Current planning:

* v0.5.x – Profile Engine
* v0.6.x – Module System
* v0.7.x – Configuration
* v0.8.x – Integration
* v0.9.x – Validation
* v1.0.0 – Initial stable release

The roadmap may evolve based on research findings.

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

Implementation has validated a limited proof of concept for boot menu creation, detection and startup execution.

The proof of concept validated that the selected Windows Boot Manager entry can be identified after startup using the current BCD entry identifier and managed BootProfile Switcher state. It also validated that this detection can run automatically during system startup through a scheduled task and dispatch profile-specific startup scripts.

---

# Open Decisions

The following questions remain intentionally unanswered:

* Should description-based detection remain as a long-term fallback after GUID-based detection has been validated?
* Which execution point is most suitable before user logon?
* Which Windows components should be used instead of custom solutions whenever possible?
* Which parts should remain extensible through modules?

These decisions will be evaluated during later milestones.

---

# AGIT Environment

## AGIT Project Template

Current version:

**v1.0.9**

---

## Collaboration Model

Current version:

**v1.6**

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
* Local Codex work follows `CODEX.md`, including read-only Git usage by default.

---

# Next Immediate Task

Prepare the next small step for `v0.4.x – Boot Profile Detection`.

Primary objective:

Turn the validated proof-of-concept detection behavior into a cleaner resolver design that can evolve toward the production profile engine.

Immediate next validation target:

Validate `scripts/Resolve-BootProfile.ps1` for Mode A and Mode B using the freshly recreated managed boot menu entries.

---

# Notes

This document intentionally represents the **current state** of the project.

It is **not** a historical log and should be updated whenever the project reaches a new milestone, the current development focus changes or a future collaboration session needs a reliable re-entry point.

Its purpose is to enable any future contributor—or a new ChatGPT conversation—to resume development immediately from the current project state.
