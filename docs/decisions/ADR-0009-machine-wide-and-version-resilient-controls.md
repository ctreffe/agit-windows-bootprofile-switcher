# ADR-0009: Machine-Wide And Version-Resilient Controls

## Status

Accepted

## Context

BootProfile Switcher controls both machine-wide Windows state and per-user
session state. It must work when different local or Active Directory users log
on to the same computer. It must also remain useful after ordinary application
updates rather than depending on installation paths or package versions.

## Decision

Configuration, boot-profile detection and machine-wide lifecycle state are
machine-scoped. They must not contain a named user or a user SID. The user-logon
hook is registered for the built-in Users group and runs for every logged-on
user.

Where Windows exposes only per-user state, such as `HKCU` Run values, baseline
state is necessarily stored per user. This is not user targeting: the same
machine-wide profile configuration is applied independently to each user at
their own logon.

Supported target IDs in configuration are logical and stable. Runtime modules
must resolve product-specific implementation details through a narrow internal
allow-list. They must not use versioned installation paths, AppX package
versions or a specific user's SID as control identifiers. Version-specific
details may be recorded in logs for diagnostics only.

Product patterns are allowed only when they are narrow enough to identify the
requested product. For example, the `anydesk` service target resolves the
allow-listed `AnyDesk-*` service pattern rather than storing a particular
installation-specific service suffix in configuration.

## Consequences

- New controls require validation with a different user profile when they use
  per-user Windows state.
- The repository or installed runtime location must be readable by every user
  expected to run the user-logon hook.
- A target whose only known identifier is version-specific remains
  inspect-only until a stable, narrow resolution strategy is found.
- Product updates can still invalidate a control surface; logs and discovery
  remain the diagnostic and review path rather than broad matching.
