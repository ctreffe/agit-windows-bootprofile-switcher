# ADR-0008: Startup and User-Application Control

## Status

Accepted

Updated after demo validation: v1.6.0 uses separate startup and user-logon
execution scopes. The SYSTEM startup hook handles machine-wide startup
surfaces. A user-logon hook handles per-user `HKCU` startup values and
explicitly configured allow-listed process stops for the logged-on user.

## Context

After v1.5.0, BootProfile Switcher has a validated `service-control`
lifecycle module for Windows Search / `WSearch`.

The next requested milestone should address Microsoft Teams, OneDrive,
ownCloud and Microsoft Office. The v1.4.0 discovery started from Outlook as
the user-facing request, but the validated control surface is Office-wide
startup and update behavior. These targets are not ordinary Windows services
on the validated machine. They appear through startup registry entries,
scheduled tasks or running user applications.

These control surfaces are related but not identical:

- Startup registry entries and startup-folder entries affect future user
  session startup behavior.
- Scheduled tasks may be machine-wide or user-scoped and may belong to update,
  reporting or application startup behavior.
- Running user processes are active session state and cannot always be managed
  safely before user logon.

The project needs to address the requested applications in one milestone
without creating one module per application and without pretending that every
application can be controlled through the same Windows mechanism.

## Decision

v1.6.0 will be scoped as **Startup and User-Application Control** for Microsoft
Teams, OneDrive, ownCloud, Microsoft Office and Microsoft 365 Copilot. The
discovered AnyDesk support service is controlled through the existing generic
`service-control` module in the same demo profile.

The milestone will use a shared module design for startup and user-application
control surfaces. The module family may be implemented as one module or as two
closely coordinated modules if validation shows that startup configuration and
running user-session process control need separate lifecycles.

The milestone must address these user-application targets:

- Microsoft Teams
- OneDrive
- ownCloud
- Microsoft Office
- Microsoft 365 Copilot

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
They may be inventoried and classified in v1.6.0. After demo validation showed
that per-user autostart can still launch applications after boot, v1.6.0 also
allows explicit allow-listed process stops in the user-logon scope.

Windows Update and Bitdefender remain outside v1.6.0 implementation scope.
They belong to policy or vendor guidance unless a later discovery milestone
identifies a supported management surface.

## Rationale

Teams, OneDrive, ownCloud, Microsoft Office and Microsoft 365 Copilot are user-facing application
targets, not a set of ordinary Windows services. Treating them as
service-control targets would violate ADR-0007 and would produce unreliable
behavior.

At the same time, implementing one module per application would fragment the
architecture. The safer boundary is the Windows control surface: startup
registry entries, startup folders, scheduled tasks and user-session processes.

Using shared module logic with per-application capability notes keeps the
system understandable. It allows the project to support the requested
target areas while still admitting that OneDrive scheduled tasks, Teams startup
entries, ownCloud process behavior, Microsoft Office task behavior and Copilot
process behavior may need
different treatment.

BootProfile Switcher has two lifecycle moments. Startup configuration for
machine-wide surfaces can be changed before a user logs on. Per-user `HKCU`
startup entries and running interactive processes belong to the user-logon
lifecycle. That difference must remain visible in the design.

## Consequences

v1.6.0 should begin with a module design and validation plan before
implementation.

Configuration validation should reject unsupported application identifiers,
unsupported control surfaces and ambiguous task or registry matches.

The implementation should learn a baseline before changing startup surfaces and
restore the learned baseline when the current profile no longer requests
control.

Registry startup entries will be controlled by removing the allow-listed Run
value after recording its previous presence and command value. Restore will
recreate the value only when the learned baseline says it existed. This avoids
inventing startup entries that were absent before BootProfile Switcher acted.

Scheduled tasks will be controlled by changing the task enabled state after
recording whether the allow-listed task existed and whether it was enabled.
Restore will return existing tasks to the learned enabled or disabled state.
If a task disappears after baseline learning, restore will log the missing
task and skip recreation.

Dry-run behavior should be the first validation phase. Real changes should be
enabled only after the inventory and planned changes are reviewed.

The project should document per-application capability notes for Teams,
OneDrive, ownCloud, Microsoft Office and Microsoft 365 Copilot. These notes should distinguish
implemented control, dry-run-only classification and intentionally unsupported
behavior.

The module may control explicitly allow-listed Microsoft Office startup and
update tasks when they are intentionally in scope, including Office
Click-to-Run or Office update startup behavior. It must not disable arbitrary
Windows Update, vendor or unrelated scheduled tasks through broad name matching.

Running process termination remains a high-caution behavior. It must not be
implicit cleanup. It is allowed only when configuration explicitly sets the
process action to `stop`, only for allow-listed target process names and only in
the user-logon scope. Startup surfaces can be restored; stopped user processes
cannot be restored with the same safety guarantees.

AnyDesk is an explicit exception to the user-application classification: local
discovery identified `AnyDesk-*` as a normal automatic service pattern. It is
allow-listed in `service-control`, with the same learned-baseline and restore
semantics as `WSearch`.
