# ADR-0001: Overall Architecture

## Status

Accepted

## Context

BootProfile Switcher is intended to manage multiple Windows operating profiles from a single Windows installation.

The selected profile must be applied before interactive user logon. The system should be suitable for managed Windows environments and should eventually support deployment via Group Policy.

The project must remain generic enough to support future use cases beyond the initial normal and experimental modes.

## Decision

BootProfile Switcher will use a modular architecture consisting of the following conceptual components:

- boot profile selection
- boot profile resolver
- BootProfile Engine
- profile loader
- modules
- Windows configuration targets

The engine will operate on generic profile names and declarative profile definitions.

Profile-specific behavior will not be hardcoded into the engine. Instead, profiles describe desired state and modules apply the relevant parts of that state.

The project will maintain a clear distinction between:

- system architecture documentation
- architecture decision records
- user-facing project documentation

The initial architecture documentation is maintained in `docs/architecture.md`.

Architecture Decision Records begin with `ADR-0001`. The project does not use an `ADR-0000`, because ADRs are reserved for decisions rather than general project philosophy or project state.

## Rationale

This architecture keeps the system flexible and maintainable.

A modular engine makes it possible to add new profile types and new configuration areas without redesigning the core boot profile mechanism.

Declarative profiles reduce hardcoded behavior and allow later configuration changes without changing core engine logic.

A strict separation between architecture documentation and ADRs keeps documentation concise:

- architecture documentation explains the system structure
- ADRs explain the decisions behind important design choices
- README files explain the project purpose and usage context

Designing for Group Policy based deployment and reversible installation from the beginning avoids treating deployment as an afterthought.

## Consequences

The project will initially invest more effort in architecture and documentation before implementation begins.

Future code should be organized around the architectural components described here.

Modules should remain independent and focused on one area of Windows configuration.

Any future decision that materially changes the architecture should be documented in a new ADR.

The boot profile detection strategy is intentionally not decided in this ADR. It will be evaluated separately because it is a critical technical decision.
