# Startup and User-Application Control Module Design

## Purpose

Startup and User-Application Control is the v1.6.0 design area for Microsoft
Teams, OneDrive, ownCloud and Outlook.

The goal is to control application startup behavior from BootProfile Switcher
profiles without treating user applications as ordinary Windows services and
without creating one module per application.

The design should use shared module logic for Windows control surfaces and
per-application capability notes for differences between targets.

## Target Applications

The v1.6.0 milestone addresses:

| Application | Discovery classification | Initial v1.6.0 treatment |
| --- | --- | --- |
| Microsoft Teams | startup-control-or-user-app-control | Startup entries first; process behavior requires explicit user-session rules |
| OneDrive | startup-control-or-user-app-control | Startup entries and clearly owned scheduled tasks first; update/reporting tasks require caution |
| ownCloud | startup-control-or-user-app-control | Startup entries first; running process behavior requires explicit user-session rules |
| Outlook | startup-control-or-user-app-control | Inventory and capability decision first; broad Office tasks must not be disabled by name alone |

Each application must be explicitly addressed. If a target cannot be safely
controlled in the initial implementation, the module documentation should say
so and explain why.

## Control Surfaces

The shared design may cover these startup surfaces:

- per-user startup registry entries
- machine-wide startup registry entries
- startup-folder entries
- scheduled tasks that are clearly owned by a supported target application

The design may inventory these user-application surfaces:

- running user processes
- user-session application state that cannot be safely controlled before logon

Running process termination is not a default first implementation behavior. It
needs explicit validation because it affects live user work and is not
reversible in the same way as restoring a registry value or task enabled state.

## Configuration Shape

Configuration Format v2 keeps module settings profile-local. A possible first
shape is:

```json
{
  "id": "focus-startup",
  "displayName": "Focus Startup",
  "bootMenu": {
    "enabled": true
  },
  "modules": {
    "startup-user-application-control": {
      "dryRun": true,
      "applications": [
        {
          "id": "teams",
          "startup": {
            "enabled": false
          },
          "processes": {
            "action": "inspect-only"
          }
        },
        {
          "id": "onedrive",
          "startup": {
            "enabled": false
          },
          "processes": {
            "action": "inspect-only"
          }
        },
        {
          "id": "owncloud",
          "startup": {
            "enabled": false
          },
          "processes": {
            "action": "inspect-only"
          }
        },
        {
          "id": "outlook",
          "startup": {
            "enabled": false
          },
          "processes": {
            "action": "inspect-only"
          }
        }
      ]
    }
  },
  "scripts": []
}
```

The final implementation may choose a shorter module name such as
`startup-control` if process handling is kept as inspect-only. If real
user-session process control becomes part of the milestone, the implementation
should keep that distinction visible in configuration and documentation.

Supported application identifiers should be allow-listed:

- `teams`
- `onedrive`
- `owncloud`
- `outlook`

Unsupported application identifiers should be configuration errors.

## Lifecycle And Baseline

The module should be a lifecycle module.

It needs to run when a profile requests startup control and also when the
current profile no longer requests it, because the latter case may need to
restore startup entries or scheduled tasks changed by a previous run.

The state file should live under:

```text
%ProgramData%\BootProfileSwitcher\state\
```

The exact file name should be chosen when the module name is finalized.

For each controlled startup surface, the state should record at least:

- application id
- control surface type
- source path or task path
- original enabled or present state
- original command or value data when applicable
- whether the previous run actively controlled the surface
- profile id that requested control
- timestamp of the baseline snapshot
- timestamp of the last module run

Lifecycle rules:

1. If the previous run did not control a surface, the current state may become
   the normal baseline before any current control action is applied.
2. If the current profile requests startup control, the module applies the
   configured target state after baseline learning.
3. If the previous run controlled a surface and the current profile no longer
   requests it, the module restores the learned baseline instead of learning
   the controlled state as normal.
4. If a surface is missing, ambiguous or unsupported, the module logs a skip or
   validation error and does not attempt modification.
5. Running processes are inspected and logged unless a later explicit decision
   allows real process control.

## Dry-Run Behavior

Examples and demos should default to `dryRun = true`.

In dry-run mode, the module should:

- inventory supported application startup surfaces
- show whether a baseline would be learned
- show which startup entries would be disabled
- show which scheduled tasks would be disabled
- show which baseline entries would be restored
- log running process matches without terminating them
- avoid editing registry values
- avoid changing scheduled task enabled state
- avoid deleting startup-folder entries
- avoid terminating processes

## Per-Application Notes

### Microsoft Teams

The v1.4.0 discovery found startup registry entries such as
`com.squirrel.Teams.Teams` and `TeamsMachineInstaller`.

The first implementation should classify exact Teams startup entries and avoid
wide pattern matching that could affect unrelated Microsoft components.

### OneDrive

The v1.4.0 discovery found OneDrive scheduled tasks, startup registry entries
and a running process.

The first implementation should distinguish user startup behavior from update,
reporting or cleanup tasks. Disabling broad OneDrive update infrastructure may
have different consequences than suppressing user-session startup.

### ownCloud

The v1.4.0 discovery found an `ownCloud` startup registry entry and an
`owncloud` running process.

The first implementation should treat the startup entry as the primary
candidate and keep process handling inspect-only until user-session behavior is
validated.

### Outlook

The v1.4.0 discovery found Office scheduled tasks and a running `OUTLOOK`
process.

The first implementation must not disable broad Office update or Click-to-Run
tasks merely to control Outlook startup. Outlook may require a capability note
or a later user-session design if no safe Outlook-specific startup surface is
found.

## Validation Plan

The v1.6.0 implementation should be validated in phases:

1. Refresh read-only inventory for Teams, OneDrive, ownCloud and Outlook on the
   current machine.
2. Document exact startup registry entries, startup-folder entries, scheduled
   tasks and running process matches for each application.
3. Define the allow-list and configuration validation fixtures.
4. Validate dry-run inventory and planned changes.
5. Validate baseline state creation without changing startup surfaces.
6. Run controlled real tests only after dry-run output is reviewed.
7. Confirm a later non-controlling startup restores the learned baseline.
8. Record per-application capability notes for any target that remains
   inspect-only or unsupported.

## Non-Goals

The v1.6.0 design should not:

- control arbitrary applications
- disable Windows Update tasks
- disable Bitdefender or other vendor/security components
- disable broad Office tasks unless they are explicitly accepted as part of an
  Outlook-specific control decision
- terminate user processes by default
- delete user startup entries when disabling/restoring can be represented more
  safely
- bypass policy, vendor protection or user consent boundaries
