# Startup and User-Application Control Module Design

## Purpose

Startup and User-Application Control is the v1.6.0 design area for Microsoft
Teams, OneDrive, ownCloud and Microsoft Office.

The goal is to control application startup behavior from BootProfile Switcher
profiles without treating user applications as ordinary Windows services and
without creating one module per application.

The design should use shared module logic for Windows control surfaces and
per-application capability notes for differences between targets.

The current implementation provides the first read-only dry-run path. It
validates allow-listed application IDs, inspects known registry, scheduled task
and process surfaces, and logs planned startup/task actions without changing
Windows state.

## Target Applications

The v1.6.0 milestone addresses:

| Application | Discovery classification | Initial v1.6.0 treatment |
| --- | --- | --- |
| Microsoft Teams | startup-control-or-user-app-control | Allow-listed startup registry values first; machine-wide installer startup needs caution |
| OneDrive | startup-control-or-user-app-control | Allow-listed startup scheduled tasks first; reporting and update tasks need a separate decision |
| ownCloud | startup-control-or-user-app-control | Allow-listed per-user startup registry value first; running process behavior remains inspect-only |
| Microsoft Office | startup-control-or-user-app-control | Allow-listed Office startup/update scheduled tasks are in scope; arbitrary broad Office matching is not |

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
          "id": "microsoft-office",
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
- `microsoft-office`

Unsupported application identifiers should be configuration errors.

## Lifecycle And Baseline

The module should be a lifecycle module.

It needs to run when a profile requests startup control and also when the
current profile no longer requests it, because the latter case may need to
restore startup entries or scheduled tasks changed by a previous run.

The state file should live at:

```text
%ProgramData%\BootProfileSwitcher\state\startup-user-application-control-state.json
```

The current dry-run implementation does not write this default ProgramData
state file unless a state path is explicitly passed for validation. This keeps
normal dry-run engine dispatch non-persistent while still allowing baseline and
restore behavior to be tested with an isolated temporary state file.

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

### Registry Startup Baseline

Registry startup entries should be represented as allow-listed Run values.

For each controlled registry value, the baseline should record:

- application id
- registry path
- value name
- whether the value existed
- original command value
- value kind when available

When a profile requests `startup.enabled = false`, the real implementation
should disable the startup entry by removing the allow-listed registry value
after the baseline has been learned. It should not replace the value with an
empty string, rename it or write a shadow value into the Run key.

Restore should use the learned baseline:

- If the value existed, recreate it with the original command.
- If the value did not exist, leave it absent.
- If the parent registry path no longer exists, log a restore skip instead of
  creating broad registry structure.

### Scheduled Task Baseline

Scheduled tasks should be represented by exact allow-listed task path and task
name. Wildcard matching may be used only to discover SID-scoped OneDrive
startup tasks; the concrete matched task identities must be stored before real
changes.

For each controlled task, the baseline should record:

- application id
- task path
- task name
- whether the task existed
- original task state
- whether the task was enabled

When a profile requests `startup.enabled = false`, the real implementation
should disable the allow-listed scheduled task. It should not delete tasks,
edit task actions or alter triggers.

Restore should use the learned baseline:

- If the task existed and was enabled, enable it again.
- If the task existed and was disabled, leave or return it disabled.
- If the task did not exist, leave it absent.
- If the task disappeared after baseline learning, log a restore skip and do
  not recreate it.

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

The first real-change implementation should continue to treat processes as
inspect-only even when `dryRun = false`.

## Dry-Run Behavior

Examples and demos should default to `dryRun = true`.

In dry-run mode, the module should:

- inventory supported application startup surfaces
- show whether a baseline would be learned
- write baseline state only when an explicit validation state path is provided
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

The v1.6.0 discovery refresh found the same two startup registry values and no
Teams service, scheduled task, startup-folder entry or running process.

The first implementation should classify exact Teams startup entries and avoid
wide pattern matching that could affect unrelated Microsoft components.

### OneDrive

The v1.4.0 discovery found OneDrive scheduled tasks, startup registry entries
and a running process.

The v1.6.0 discovery refresh found SID-scoped OneDrive scheduled tasks and no
OneDrive service, startup registry entry, startup-folder entry or running
process. `OneDrive Startup Task-<SID>` is the clearest first startup-control
candidate. Reporting and standalone update tasks should not be disabled by
default.

The first implementation should distinguish user startup behavior from update,
reporting or cleanup tasks. Disabling broad OneDrive update infrastructure may
have different consequences than suppressing user-session startup.

### ownCloud

The v1.4.0 discovery found an `ownCloud` startup registry entry and an
`owncloud` running process.

The v1.6.0 discovery refresh again found the `ownCloud` per-user startup
registry value and an active `owncloud` process.

The first implementation should treat the startup entry as the primary
candidate and keep process handling inspect-only until user-session behavior is
validated.

### Microsoft Office

The v1.4.0 discovery found Office scheduled tasks and a running `OUTLOOK`
process. For v1.6.0, the target is intentionally defined as Microsoft Office
because Office startup and update behavior is part of the desired control
scope, and no Outlook-specific startup surface was found in the refresh.

The v1.6.0 discovery refresh found broad Microsoft Office scheduled tasks, but
no Outlook-specific startup registry entry, startup-folder entry or running
process.

The first implementation may control explicitly allow-listed Office scheduled
tasks, especially Office update and Click-to-Run startup behavior, when the
profile requests Microsoft Office control. It must not use broad
`*Office*` matching as a generic task-disabling mechanism. Outlook process
handling remains inspect-only until user-session behavior has explicit safety
rules.

## Validation Plan

The v1.6.0 implementation should be validated in phases:

1. Refresh read-only inventory for Teams, OneDrive, ownCloud and Microsoft
   Office on the current machine.
2. Document exact startup registry entries, startup-folder entries, scheduled
   tasks and running process matches for each application.
3. Define the allow-list and configuration validation fixtures.
4. Validate dry-run inventory and planned changes.
5. Validate baseline state creation without changing startup surfaces.
6. Validate a non-controlling restore dry-run after a controlling dry-run.
7. Run controlled real tests only after dry-run output is reviewed.
8. Confirm a later non-controlling startup restores the learned baseline.
9. Record per-application capability notes for any target that remains
   inspect-only or unsupported.

## Non-Goals

The v1.6.0 design should not:

- control arbitrary applications
- disable Windows Update tasks
- disable Bitdefender or other vendor/security components
- disable arbitrary Office tasks unless they are explicitly allow-listed as
  part of the Microsoft Office target
- terminate user processes by default
- delete user startup entries when disabling/restoring can be represented more
  safely
- bypass policy, vendor protection or user consent boundaries
