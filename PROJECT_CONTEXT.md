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

Prepare and begin **v0.3.0 – Boot Process**.

The next milestone is to understand the Windows boot process in sufficient detail before implementing any solution.

The project intentionally follows a **research-first** approach.

The objective is to understand:

* Windows Boot Manager
* Boot profile selection
* Available identification mechanisms
* Boot configuration persistence
* Pre-logon execution environment
* Official Windows mechanisms
* Long-term maintainability

Only after this research phase will architectural decisions be documented as ADRs.

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

## v0.3.0 – Boot Process

Research the Windows boot sequence.

Goals:

* Understand the complete boot process.
* Identify reliable profile detection mechanisms.
* Evaluate available Windows APIs and configuration stores.
* Compare supported and unsupported approaches.
* Produce ADRs where architectural decisions are required.

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

No implementation has started yet.

Upcoming work should validate the architecture against actual Windows behavior before implementation begins.

---

# Open Decisions

The following questions remain intentionally unanswered:

* Which Windows mechanism will identify the selected boot profile?
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

Begin the research phase for **v0.3.0 – Boot Process**.

Primary objective:

Understand the Windows boot process well enough to make informed architectural decisions before writing implementation code.

---

# Notes

This document intentionally represents the **current state** of the project.

It is **not** a historical log and should be updated whenever the project reaches a new milestone, the current development focus changes or a future collaboration session needs a reliable re-entry point.

Its purpose is to enable any future contributor—or a new ChatGPT conversation—to resume development immediately from the current project state.
