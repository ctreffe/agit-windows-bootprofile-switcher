# ADR-0007: Service and Startup Control Modularization

## Status

Accepted

## Context

After v1.3.0, the next requested project direction is to control startup-time
behavior for targets such as Windows Update, Bitdefender, Microsoft Teams,
OneDrive, ownCloud, Outlook and Windows Search indexing.

These targets do not share one Windows control surface. Some are system
services, some are scheduled tasks, some are per-user startup entries, some are
interactive user applications, and some may be protected by vendor tamper
protection or managed through policy.

BootProfile Switcher runs from a startup-time profile engine before normal
interactive user workflows. Treating all requested targets as one generic
"service control" capability would blur important boundaries and could lead to
unsafe behavior, especially for security software, update infrastructure and
per-user applications.

The project therefore needs a clear architecture boundary before implementing
the next production module.

## Decision

Service, startup and user-application control will be modularized by control
surface rather than implemented as one broad module.

The project will distinguish at least these module families or guidance areas:

- `service-control` for real Windows services with explicit restore semantics.
- `startup-control` for startup registry entries, startup-folder entries and
  scheduled tasks when they are the relevant startup surface.
- `user-app-control` for later user-session application behavior such as
  Outlook, Teams, OneDrive or ownCloud process/session handling.
- `policy-or-vendor-guidance` for targets that are self-healing,
  policy-managed or protected by vendor mechanisms.

The v1.4.0 milestone remains a read-only discovery milestone. It collects and
classifies local inventory before any production module changes service states,
scheduled tasks, registry startup entries or running processes.

Windows Search indexing is the likely first `service-control` implementation
candidate because `WSearch` has a clear Windows service identity and a narrower
restore model than Windows Update or security software.

Windows Update and Bitdefender must not be implemented as simple forced
disable/stop behavior. They require policy-aware or vendor-aware treatment, and
BootProfile Switcher must not bypass vendor protection mechanisms.

Per-user applications such as Teams, OneDrive, ownCloud and Outlook must not be
treated as ordinary Windows services unless discovery proves that a service is
the relevant control surface for a specific deployment.

## Rationale

Separating control surfaces keeps the profile engine small and prevents one
module from accumulating unrelated Windows behavior.

Windows services can often be inspected and controlled before user logon, but
per-user startup and interactive applications belong to a different lifecycle.
Those applications may need user-session timing, per-user state handling and
different restore semantics.

Scheduled tasks and startup entries are configuration surfaces, not running
services. They need different inventory, safety checks and rollback behavior
than service startup types.

Security products and update components can be self-healing, policy-managed or
protected against tampering. Treating them as normal services would create
unreliable behavior and could conflict with security or management policy.

A read-only discovery milestone reduces implementation risk. It records what
actually exists on a target system before the project decides which behavior is
safe, useful and reversible.

## Consequences

The next implementation should begin with a narrow `service-control` module
only after discovery confirms an appropriate first candidate and restore model.

The first candidate should likely be Windows Search indexing rather than
Windows Update, Bitdefender or per-user sync/communication applications.

Future modules must declare which control surface they own and how they restore
state after a profile no longer requests the behavior.

The configuration format may later need separate module settings for service
control, startup control and user-application control instead of one combined
setting.

Unsupported, postponed or policy-managed targets should be documented as
validated project knowledge rather than hidden behind best-effort behavior.

The project should continue to avoid bypassing vendor protection mechanisms.
