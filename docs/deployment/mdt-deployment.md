# MDT Deployment Model

## Status

Implemented and validated for v1.7.0 - Machine-Wide Runtime and Deployment.

The current implementation provides non-interactive runtime, configuration,
scheduled-hook and explicit boot-menu deployment, plus restore-aware,
unattended removal and final external-runtime cleanup.

## Purpose

This document defines the intended unattended deployment model for BootProfile
Switcher when it is installed by Microsoft Deployment Toolkit (MDT). It is an
technical reference for the v1.7.0 deployment entry points. For practical
administrator workflows, see the [English guide](mdt-administrator-guide.md)
or the [German guide](mdt-administrator-guide.de.md).

The design supports an MDT Task Sequence running as `LocalSystem`. It must not
depend on an interactive desktop, a particular Windows user, a mapped drive or
continued access to an MDT deployment share after installation.

## Target Machine Layout

All active, machine-scoped BootProfile Switcher artifacts belong below:

```text
%ProgramData%\BootProfileSwitcher\
    runtime\     Executable PowerShell scripts and module code
    config\      Installed, validated profile configuration
    state\       Resolver, boot-menu and machine-module lifecycle state
    logs\        Runtime and deployment logs
    backups\     Managed backups required for restoration
```

The runtime must be copied locally before either scheduled hook is registered.
At runtime, neither hook may use the MDT package location, a repository
checkout or a network path.

## Deployment Package

The MDT application/package supplies a source directory containing the
repository runtime payload: `scripts`, `modules` and configuration schema or
example files. The Task Sequence passes that directory explicitly to the
deployment script. It must not rely on the current working directory.

The installed production configuration is a separate, validated input. This
allows a runtime update without replacing site-specific profile policy, and a
configuration update without replacing executable runtime code.

## Deployment Entry Point

v1.7.0 provides a machine deployment script named
`Install-BootProfileSwitcherDeployment.ps1` for MDT and other unattended
software-deployment tools.

Its planned parameter surface is:

```text
-SourceRoot <path>                 Required deployment-package source
-ConfigurationPath <path>          Optional profile configuration to validate and install
-InstallStartupHook                Register the SYSTEM startup hook
-InstallUserLogonHook              Register the built-in-Users logon hook
-InstallBootMenu                   Explicitly manage BCD entries
-CleanupExistingBootMenu           Replace only known managed BCD entries
-Force                             Permit documented replacement operations
-WhatIf                            Report planned changes without changing the machine
-AsJson                            Emit the deployment result as JSON
```

Boot-menu deployment is explicit. If known managed entries already exist, a
non-interactive deployment fails unless `-CleanupExistingBootMenu` is supplied.
The replacement path passes `-CleanupExisting -Force` to the local boot-menu
installer, which removes only managed entries recorded or recognized by that
installer before creating the configured replacement entries.

### MDT Task Sequence Command

For a deployment package whose root is available as MDT's `%SCRIPTROOT%`, use
the following command in an elevated Task Sequence step. Substitute the
configuration path with the site-specific package configuration when needed.

```text
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%SCRIPTROOT%\scripts\Install-BootProfileSwitcherDeployment.ps1" -SourceRoot "%SCRIPTROOT%" -ConfigurationPath "%SCRIPTROOT%\config\profiles.v2.example.json" -InstallStartupHook -InstallUserLogonHook -Force -AsJson
```

`-Force` makes repeated deployment replace a previously installed, different
managed configuration. Omit `-ConfigurationPath` when updating only runtime
files and hooks while deliberately retaining the existing machine policy.

For a deliberate managed boot-menu replacement, append:

```text
-InstallBootMenu -CleanupExistingBootMenu
```

The normal MDT runtime deployment installs or updates the local runtime, then
optionally installs a supplied configuration and hooks. `-InstallBootMenu` is
deliberately opt-in: changing BCD is a material system change and is not a
side effect of deploying files or scheduled tasks.

The script must reject ambiguous or unsafe combinations, for example
`-CleanupExistingBootMenu` without `-InstallBootMenu`, or a configuration
replacement without `-Force` when a different managed configuration exists.
There must be no `Read-Host`, confirmation prompt or other interactive branch
when the deployment entry point is used.

## Scheduled Hook Requirements

The startup hook remains a Scheduled Task running as `SYSTEM` at startup. The
user-logon hook remains a task for the built-in Users group and executes in
each user's context. Both task actions must point to the installed local
runtime.

Only the user-logon hook may use user-scoped Windows state such as `HKCU`.
Machine configuration, resolved boot-profile state and module lifecycle state
must contain neither user names nor user SIDs.

## Upgrade, Removal and Ownership

Runtime deployment is repeatable. An update may replace files owned below the
BootProfile Switcher runtime directory, but it must preserve configuration and
state unless the corresponding explicit operation requests replacement.

`Uninstall-BootProfileSwitcherDeployment.ps1` provides the first unattended
uninstall step. It can remove selected hooks and managed boot-menu entries,
while preserving runtime, configuration and module lifecycle state for a later
restore-aware cleanup step.

`Restore-BootProfileSwitcherMachineBaselines.ps1` is the restore-aware step.
It runs the installed engine with an unmanaged resolver result before removal,
restoring Network Isolation, Service Control and machine-scoped startup
surfaces from their recorded baselines. It requires a valid configuration with
`dryRun = false` for every configured lifecycle module that may need restore.

Its parameter surface is:

```text
-RemoveStartupHook                 Remove the named SYSTEM startup task
-RemoveUserLogonHook               Remove the named built-in-Users logon task
-RemoveBootMenu                    Remove entries recorded in managed state
-RestoreMachineBaselines           Restore machine baselines before removal
-ScheduleUserBaselineRestore       Keep the user hook and restore HKCU baselines at next logon
-RemoveConfiguration               Remove ProgramData configuration after validation (requires -Force)
-RemoveMachineState                Remove ProgramData lifecycle state after validation (requires -Force)
-RemoveRuntime                     Schedule external runtime removal (requires -Force; separate final run)
-Force                             Confirm destructive final-cleanup options
-WhatIf                            Report planned changes without changing the machine
-AsJson                            Emit the removal result as JSON
```

Run it from the installed local runtime, for example:

```text
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%ProgramData%\BootProfileSwitcher\runtime\scripts\Uninstall-BootProfileSwitcherDeployment.ps1" -RemoveStartupHook -RemoveUserLogonHook -RemoveBootMenu -AsJson
```

Do not combine `-RestoreMachineBaselines` with `-RemoveUserLogonHook` while
`startup-user-application-control` is configured. Per-user `HKCU` baseline
state is stored per user and must be restored by the existing user-logon hook
in each affected user's session. The machine restore result exposes this as
`userLogonRestoreRequired`.

When per-user restoration is required, use `-ScheduleUserBaselineRestore` and
retain the user-logon hook. It creates a machine marker under ProgramData; at
each subsequent user logon the hook restores that user's local baseline once
and records completion under `%LocalAppData%\BootProfileSwitcher\state`.
After the relevant users have logged on and the user-logon log has been
reviewed, remove the user-logon hook in a separate explicit final-cleanup run.

The complete planned removal model removes only infrastructure owned by
BootProfile Switcher:

- the named startup and user-logon tasks;
- runtime files and directories below the machine root, when explicitly
  requested;
- BCD entries whose identifiers are recorded in managed boot-menu state;
- baseline state only after a module-specific restore path has completed.

It must not delete arbitrary BCD entries, user startup values, scheduled tasks
or application state merely because their names resemble supported targets.
Configuration and machine-state removal are explicit `-Force` options, not a
default effect of an update. They are available only after restore evidence has
been reviewed. Runtime removal remains a separate final step because the
uninstaller first copies `Remove-BootProfileSwitcherRuntimeWorker.ps1` to a
temporary external location. The worker waits for the uninstaller to exit,
removes the runtime and writes `runtime-removal-result.json` under the machine
root. `-RemoveRuntime` must be invoked by itself and is rejected while hooks,
managed boot-menu state, pending per-user restore, configuration or machine
state remain.

## MDT Result Contract

The deployment script must write a timestamped local deployment log under
`%ProgramData%\BootProfileSwitcher\logs`. It must also emit a concise result
object suitable for Task Sequence logs, including runtime path, configuration
path, installed hooks, boot-menu action and errors.

The following exit-code contract is reserved for v1.7.0:

| Code | Meaning |
| --- | --- |
| 0 | Requested operation completed successfully, including an idempotent no-change result. |
| 1 | Invalid parameters, invalid configuration or an unmet prerequisite such as missing elevation. |
| 2 | Runtime copy or local filesystem setup failed. |
| 3 | Scheduled-task installation or removal failed. |
| 4 | Requested BCD operation failed. |
| 5 | Requested restore or removal operation failed. |

The script must stop on failure and return a non-zero code. MDT therefore has
one reliable success criterion: exit code `0`.

## Security and Connectivity Boundaries

The installer may read its source payload from the MDT-provided local package
location. No installed runtime component may require network access. The
installation must not embed deployment-share credentials, UNC paths, named
users or Active Directory identifiers into machine configuration or scheduled
task definitions.

## Validation Plan

Before v1.7.0 is complete, validate the following on a representative MDT
target or equivalent `LocalSystem` deployment context:

1. Fresh non-interactive runtime, configuration and hook installation.
2. Repeated deployment with the same payload, confirming idempotent success.
3. Runtime-only update without overwriting the installed configuration or
   lifecycle state.
4. Installation and later logon by a different local or AD user, confirming
   that the user-logon hook uses the local runtime and handles only that user's
   `HKCU` state.
5. Explicit boot-menu installation and replacement, confirming that only
   recorded managed entries are changed and that an existing menu without the
   cleanup option fails without prompting.
6. Explicit uninstall and module baseline restore, confirming that managed
   infrastructure is removed and unrelated system state remains intact.

### Validation Status

On 2026-07-16, the machine restore and pending per-user restore path were
validated on the development device using the existing Startup and
User-Application Control configuration. The machine restore completed with
Service Control and Startup/User-Application Control lifecycle execution. A
real subsequent user logon completed the pending per-user restore: the
User-Logon Scheduled Task returned code `0`, wrote its local completion marker
under `%LocalAppData%`, and recorded `pendingUserBaselineRestore=True` in the
machine runtime log.

The same development device then completed the full final-cleanup path for its
only affected user: the remaining hooks, managed boot-menu state, configuration
and machine state were removed, followed by `-RemoveRuntime -Force`. The
external worker reported `succeeded: true` and the installed runtime directory
was absent. Validate managed scheduled-task preconditions in the same elevated
context as the uninstaller; a non-elevated query did not reliably show the
existing startup hook on this device. An MDT Task Sequence / `LocalSystem`
validation was then completed on the development device. Fresh deployment,
repeat deployment and runtime-only update all returned code `0` through a
temporary `SYSTEM` scheduled task. The runtime-only update preserved both the
installed configuration hash and a lifecycle-state sentinel. Explicit managed
boot-menu installation succeeded; the deliberate retry without cleanup
returned code `4`, and a cleanup replacement succeeded after fixing a
schema-v2 compatibility error for the absent optional legacy `mode` property.
The System-context central uninstall and external runtime worker each returned
code `0`; the worker recorded `succeeded: true` and the runtime directory was
absent. The temporary SYSTEM test task was removed. Validation of a different
local or AD user's later logon then completed with `GWDG\0ctreffe`: its own
`%LocalAppData%` completion marker recorded the pending restore ID, the
User-Logon task returned code `0`, and its registered action used the local
ProgramData runtime. The original user subsequently completed the same restore
ID. The user hook, configuration and machine state were then removed, followed
by successful external runtime removal.

## Relationship to Existing Components

`Install-BootProfileRuntime.ps1` already provides the initial local runtime
copy operation. The current demo setup uses that runtime successfully. v1.7.0
will make the deployment entry point the owner of the ordered runtime,
configuration and hook workflow, then adapt the granular installers and
uninstallers so their active paths follow this machine-wide model.

The design follows the machine-wide and version-resilient rules in
[ADR-0009](../decisions/ADR-0009-machine-wide-and-version-resilient-controls.md).
