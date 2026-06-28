# ADR-0004: Network Isolation Lifecycle Module

## Status

Accepted

## Context

`network-isolation` is the first production-oriented module in BootProfile
Switcher.

The module must support two related behaviors:

- apply network isolation when the selected boot profile requires it
- restore the normal adapter state when the system starts without active
  isolation

During validation, it became clear that a one-shot profile action is not enough.
Network adapter state must be tracked across starts because an isolating profile
intentionally changes the system state, and a later non-isolating start must be
able to distinguish that isolation-created state from a legitimate
administrator change.

The module also needs to support normal baseline learning. Administrators may
change the normal network configuration while the system is running in a
non-isolating profile. Those changes should become the new restore baseline
without requiring manual state editing.

## Decision

Network Isolation is implemented as a lifecycle module, not as a normal
one-shot profile action.

The profile engine invokes the Network Isolation lifecycle when a valid
configuration is available, including starts where no managed isolating profile
is currently active.

The module stores persistent lifecycle state in:

```text
%ProgramData%\BootProfileSwitcher\state\network-isolation-state.json
```

The state records the learned normal adapter baseline and metadata about the
previous run.

The lifecycle rules are:

- If the previous run was not isolating, the current adapter snapshot may be
  learned as the normal baseline before any current isolation is applied.
- If the current run is isolating, the module disables the configured adapter
  categories after baseline learning.
- If the previous run was isolating and the current run is not isolating, the
  module restores the learned baseline instead of learning the
  isolation-created state.

Profiles declare whether a start is isolating by including `network-isolation`
in their `modules` array. Adapter selection policy remains configuration-driven
under `moduleSettings.network-isolation`.

The engine is responsible for invoking the lifecycle with the current profile
context. The module is responsible for network-specific state interpretation,
adapter selection, baseline learning, restore and disable actions.

## Rationale

A lifecycle module keeps network-specific behavior out of the profile engine
while still allowing the engine to coordinate work that must run even when no
isolating profile is active.

Persistent baseline state is required because Network Isolation changes system
state across reboots. Without a baseline, a normal start could not reliably
restore adapters that were disabled by a previous isolating start.

Learning the baseline only when the previous run was not isolating prevents the
module from accidentally treating an isolation-created adapter state as the new
normal state.

Learning before current isolation when the previous run was non-isolating
allows legitimate administrator changes from the last normal or non-isolating
session to become the new baseline, even if the current start is about to apply
isolation.

Keeping adapter policy in configuration preserves the overall architecture:
profiles describe desired state, modules apply their own domain behavior, and
the engine avoids hardcoded profile-specific business rules.

## Consequences

Network Isolation has a broader lifecycle than ordinary profile modules.
Future modules that need cross-start state may use the same pattern, but they
should justify the lifecycle behavior explicitly rather than becoming lifecycle
modules by default.

The profile engine must know how to invoke lifecycle modules before normal
profile module dispatch.

The persistent state file becomes managed infrastructure and must remain
traceable, diagnosable and safe to remove or recreate according to documented
module behavior.

The module must be careful not to learn an isolation-created state as normal.

The v1.1.0 implementation provides adapter-level isolation only. It is not a
complete security boundary against local administrators or privileged
management tools. Future hardening work should evaluate Group Policy
restrictions, network UI restrictions, device-management controls, service
controls and firewall enforcement.

Bluetooth network adapter isolation does not imply Bluetooth radio or USB
Bluetooth adapter device isolation. Device-level Bluetooth controls belong in a
separate future module or hardening milestone.
