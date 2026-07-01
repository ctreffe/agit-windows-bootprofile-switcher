# ADR-0008: Startup and User-Application Control

## Status

Accepted

## Context

After v1.5.0, BootProfile Switcher has a validated `service-control`
lifecycle module for Windows Search / `WSearch`.

The next requested milestone should address Microsoft Teams, OneDrive,
ownCloud and Outlook. The v1.4.0 discovery found that these targets are not
ordinary Windows services on the validated machine. They appear through startup
registry entries, scheduled tasks or running user applications.

These control surfaces are related but not identical:

- Startup registry entries and startup-folder entries affect future user
  session startup behavior.
- Scheduled tasks may be machine-wide or user-scoped and may belong to update,
  reporting or application startup behavior.
- Running user processes are active session state and cannot always be managed
  safely before user logon.

The project needs to address all four requested applications in one milestone
without creating one module per application and without pretending that every
application can be controlled through the same Windows mechanism.

## Decision

v1.6.0 will be scoped as **Startup and User-Application Control** for Microsoft
Teams, OneDrive, ownCloud and Outlook.

The milestone will use a shared module design for startup and user-application
control surfaces. The module family may be implemented as one module or as two
closely coordinated modules if validation shows that startup configuration and
running user-session process control need separate lifecycles.

The milestone must address all four applications:

- Microsoft Teams
- OneDrive
- ownCloud
- Outlook

"Address" means each application receives explicit inventory, configuration
validation, documentation and a capability decision. If an application can be
safely controlled through the selected module surface, the milestone should
implement that behavior. If it cannot be safely controlled, the milestone must
record the limitation and avoid best-effort manipulation.

The initial shared design will focus on reversible startup-surface control:

- per-user startup registry entries
- machine-wide startup registry entries when appropriate
- startup-folder entries
- scheduled tasks that are clearly application-owned and safe to disable and
  restore

Running user processes are a separate capability inside the same problem space.
They may be inventoried and classified in v1.6.0, but terminating interactive
applications should require an explicit design decision, dry-run evidence and
clear user-session safety rules before implementation.

Windows Update and Bitdefender remain outside v1.6.0 implementation scope.
They belong to policy or vendor guidance unless a later discovery milestone
identifies a supported management surface.

## Rationale

Teams, OneDrive, ownCloud and Outlook are user-facing applications, not a set
of ordinary Windows services. Treating them as service-control targets would
violate ADR-0007 and would produce unreliable behavior.

At the same time, implementing one module per application would fragment the
architecture. The safer boundary is the Windows control surface: startup
registry entries, startup folders, scheduled tasks and user-session processes.

Using shared module logic with per-application capability notes keeps the
system understandable. It allows the project to support all four requested
applications while still admitting that OneDrive scheduled tasks, Teams startup
entries, ownCloud process behavior and Outlook/Office task behavior may need
different treatment.

BootProfile Switcher runs before normal user workflows. Startup configuration
can often be changed before a user logs on, but running interactive processes
belong to a later session lifecycle. That difference must remain visible in
the design.

## Consequences

v1.6.0 should begin with a module design and validation plan before
implementation.

Configuration validation should reject unsupported application identifiers,
unsupported control surfaces and ambiguous task or registry matches.

The implementation should learn a baseline before changing startup surfaces and
restore the learned baseline when the current profile no longer requests
control.

Dry-run behavior should be the first validation phase. Real changes should be
enabled only after the inventory and planned changes are reviewed.

The project should document per-application capability notes for Teams,
OneDrive, ownCloud and Outlook. These notes should distinguish implemented
control, dry-run-only classification and intentionally unsupported behavior.

The module must not disable broad Microsoft Office, Windows Update or vendor
tasks merely because their names are adjacent to a requested application.

Running process termination remains a high-caution behavior. It should not be
implemented as implicit cleanup unless later validation proves that it is safe,
necessary and reversible enough for the project goals.
