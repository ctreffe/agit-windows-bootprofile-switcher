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

**v0.2.0 – Architecture**

The Architecture milestone is complete.

## Current Focus

Continue **v0.3.0 – Boot Profile Detection Proof of Concept**.

The current milestone validates whether a Windows Boot Manager selection can be used as the basis for selecting a boot profile before user logon.

A1 has established a reversible boot menu with two entries:

* BootProfile Switcher - Mode A
* BootProfile Switcher - Mode B

A1 validation also showed that the installer should copy `{default}` rather than `{current}` because `{current}` can become invalid after booting from and removing a managed proof-of-concept entry. Usability has been improved with double-clickable `install.cmd` and `uninstall.cmd` wrappers that request elevation and call the PowerShell scripts.

The next step is A2: determine whether Windows can reliably identify which of these boot entries was selected during startup.

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

# Current Development Roadmap

## v0.3.0 – Boot Profile Detection Proof of Concept

Validate the core technical hypothesis:

Can a user select a boot profile in the Windows Boot Manager and can that selection be detected before user logon so profile-specific initialization can run?

Planned steps:

* A1 – Create a reversible boot menu with Mode A and Mode B. Completed and validated; command wrappers added for easier installation and removal.
* A2 – Identify the selected boot entry from within Windows.
* A3 – Determine the earliest suitable execution point before user logon.
* A4 – Execute profile-specific startup logic based on the detected mode.
* A5 – Document findings and resulting architectural decisions.

---

## Planned Future Milestones

Current planning:

* v0.4.x – Boot Profile Detection
* v0.5.x – Profile Engine
* v0.6.x – Module System
* v0.7.x – Configuration
* v0.8.x – Integration
* v0.9.x – Validation
* v1.0.0 – Initial stable release

The roadmap may evolve based on research findings.

---

# Architecture Status

The conceptual architecture has been established.

Implementation has started with a limited proof of concept for boot menu creation.

Upcoming work should validate whether the selected Windows Boot Manager entry can be identified reliably before user logon.

---

# Open Decisions

The following questions remain intentionally unanswered:

* Which Windows mechanism will identify the selected boot profile?
* Can the selected BCD boot entry be detected reliably after startup?
* Which execution point is most suitable before user logon?
* Which Windows components should be used instead of custom solutions whenever possible?
* Which parts should remain extensible through modules?

These decisions will be captured as ADRs during v0.3.0.

---

# AGIT Environment

## AGIT Project Template

Current version:

**v1.0.5**

---

## Collaboration Model

Current version:

**v1.3**

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

---

# Next Immediate Task

Begin A2 of **v0.3.0 – Boot Profile Detection Proof of Concept**.

Primary objective:

Determine whether Windows can reliably identify which BootProfile Switcher boot menu entry, Mode A or Mode B, was selected during startup.

---

# Notes

This document intentionally represents the **current state** of the project.

It is **not** a historical log and should be updated whenever the project reaches a new milestone, the current development focus changes or a future collaboration session needs a reliable re-entry point.

Its purpose is to enable any future contributor—or a new ChatGPT conversation—to resume development immediately from the current project state.
