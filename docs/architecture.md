# System Architecture

## Overview

BootProfile Switcher is a Windows boot profile engine for systems that need multiple operating profiles from a single Windows installation.

A user selects a profile during system startup. The selected profile is resolved before interactive user logon. The corresponding system configuration is then applied by the engine through modular components.

```text
Windows Boot Manager
        |
Boot Profile Selection
        |
Boot Profile Resolver
        |
BootProfile Engine
        |
Profile Loader
        |
Modules
        |
Windows Configuration
```

This document describes the conceptual architecture only. Implementation details and technical trade-offs are documented separately in Architecture Decision Records (ADRs).

## Architectural Goals

The architecture is designed around the following goals:

- use a single Windows installation
- allow profile selection during boot
- apply the selected profile before user logon
- keep profile definitions declarative
- keep implementation modules independent and replaceable
- support unattended installation and removal
- support Group Policy based deployment environments
- make all managed infrastructure traceable and reversible

## Core Concepts

### Boot Profile

A boot profile represents a named system operating state.

Examples include:

- `Normal`
- `Experiment`
- `Service`
- `Offline`

The engine must not hardcode the meaning of specific profile names. It should resolve and apply profiles generically.

### Boot Profile Selection

Boot profile selection is the mechanism by which the system determines which profile should be applied during startup.

The exact detection mechanism is intentionally not specified in this document. It will be evaluated and documented in a dedicated ADR once the implementation strategy is selected.

### Boot Profile Resolver

The resolver determines the selected boot profile and passes the resulting profile name or identifier to the engine.

The resolver is responsible for detection only. It does not apply system configuration.

### BootProfile Engine

The engine coordinates profile application.

Its responsibilities include:

- loading the selected profile
- validating the profile structure
- selecting the required modules
- invoking modules in a defined order
- logging the result
- reporting failure states in a diagnosable way

The engine should not contain profile-specific business rules.

### Profile Loader

The profile loader reads declarative profile definitions from the configured profile location.

Profiles should describe desired state. They should not contain procedural implementation logic.

### Modules

Modules apply specific parts of the desired system state.

Examples of future modules include:

- firewall configuration
- services
- Bluetooth
- USB storage
- power settings

Each module should have a clearly defined responsibility.

`network-isolation` is the first production-oriented lifecycle module. It owns
hardware network adapter isolation decisions, baseline learning and baseline
restoration. Adapter selection policy stays in configuration, while profiles
only declare whether a given start is isolating by including the module. The
profile engine triggers the lifecycle without containing network-specific
business rules.

In v1.1.0, Network Isolation is adapter-level isolation. It targets hardware
network interfaces by default, with an explicit opt-in for Bluetooth network
adapters because Windows may expose them as non-hardware interfaces. It should not be
treated as a complete security boundary against local administrators or other
privileged tooling. Stronger prevention belongs in a future hardening milestone
that evaluates Group Policy, network UI restrictions, device-management
controls, service controls or firewall enforcement.

Bluetooth network adapter handling does not imply Bluetooth radio or USB
Bluetooth adapter device isolation. Those device-level controls belong in a
separate future module.

### Windows Configuration

Windows configuration represents the actual system state after a profile has been applied.

BootProfile Switcher should prefer supported Windows mechanisms over undocumented workarounds whenever practical.

## Lifecycle

BootProfile Switcher is designed as managed infrastructure.

The lifecycle consists of:

```text
Install
   |
Configure
   |
Apply Profile
   |
Remove
```

Installation must be scriptable and suitable for unattended deployment.

Removal must cleanly remove managed infrastructure. The preferred update strategy for managed deployments is removal of the old infrastructure followed by installation of the new infrastructure.

## Deployment Model

Group Policy based deployment is a primary design consideration.

This means that installation, removal and future updates should be possible without interactive user action.

The architecture should therefore avoid assumptions that depend on:

- an already logged-in user
- per-user configuration
- manual GUI interaction
- non-reproducible local steps

## Reversibility

Every infrastructure change managed by BootProfile Switcher must be traceable and reversible.

This includes, but is not limited to:

- boot configuration entries
- scheduled tasks or services
- files and directories
- registry keys
- event log sources
- generated state files

BootProfile Switcher should avoid modifying infrastructure it does not own unless the change can be clearly documented, validated and reversed.

## Documentation Model

The documentation model follows these responsibilities:

- `README.md` describes what the project is.
- `docs/architecture.md` describes how the system is conceptually structured.
- `docs/modules/` contains user-facing documentation for modules that need more space than the README should provide.
- ADRs document why significant architectural decisions were made.

ADRs document decisions, not general project state.
