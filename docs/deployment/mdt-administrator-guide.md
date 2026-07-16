# Deploying BootProfile Switcher with MDT

This guide covers unattended installation, updates, verification and removal
for MDT administrators. The technical parameter contract is documented in the
[MDT Deployment Model](mdt-deployment.md).

## Prerequisites

- The MDT Task Sequence runs in the machine (`LocalSystem`) context.
- The application package contains `scripts\`, `modules\` and a validated,
  site-specific configuration such as `config\site\profiles.json`.
- Start with a pilot device. Boot-menu changes require separate approval.

Validate the production configuration before rollout:

```text
powershell.exe -NoProfile -ExecutionPolicy Bypass -File ".\scripts\Test-BootProfileConfiguration.ps1" -ConfigurationPath ".\config\site\profiles.json"
```

After deployment, the active runtime is local at
`%ProgramData%\BootProfileSwitcher\runtime`; it no longer needs access to the
MDT share. Installed configuration and tasks must not contain credentials, UNC
paths, user names or SIDs.

## Standard deployment

After unpacking the application package locally, add a PowerShell step to the
Task Sequence. In MDT, `%SCRIPTROOT%` points to the package:

```text
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%SCRIPTROOT%\scripts\Install-BootProfileSwitcherDeployment.ps1" -SourceRoot "%SCRIPTROOT%" -ConfigurationPath "%SCRIPTROOT%\config\site\profiles.json" -InstallStartupHook -InstallUserLogonHook -Force -AsJson
```

| Option | Purpose |
| --- | --- |
| `-SourceRoot` | Required path to the unpacked application package. |
| `-ConfigurationPath` | Validates and installs the profile configuration. |
| `-InstallStartupHook` | Registers the machine startup hook. |
| `-InstallUserLogonHook` | Registers the hook in every user's context. |
| `-Force` | Permits replacement of a different managed configuration. |
| `-AsJson` | Produces a compact result for MDT logs. |

The step is non-interactive. MDT must treat only exit code `0` as success.

## Deliberately enable the boot menu

The standard deployment does not change BCD. Add this only for an approved
boot-menu deployment:

```text
-InstallBootMenu
```

Replace existing managed entries only with explicit cleanup:

```text
-InstallBootMenu -CleanupExistingBootMenu
```

Other BCD entries remain untouched. Installation does not require a restart,
but a restart is needed before a user can choose a new boot profile.

## Update and verify

A runtime-only update preserves configuration and lifecycle state:

```text
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%SCRIPTROOT%\scripts\Install-BootProfileSwitcherDeployment.ps1" -SourceRoot "%SCRIPTROOT%" -AsJson
```

Verify the runtime, configuration and logs under
`%ProgramData%\BootProfileSwitcher`, plus the tasks
`BootProfileSwitcher-StartupHook` and `BootProfileSwitcher-UserLogonHook`.

| Exit code | Meaning |
| --- | --- |
| `0` | Success or idempotent no-change result. |
| `1` | Parameter, configuration or privilege error. |
| `2` | Local runtime copy failed. |
| `3` | Scheduled-task operation failed. |
| `4` | BCD operation failed. |
| `5` | Restore or cleanup operation failed. |

Inspect tasks and BCD in the same elevated context as deployment; non-elevated
queries can be incomplete.

## Controlled removal

Never delete files manually. For state-changing modules, follow this order:

1. Restore machine baselines:

   ```text
   powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%ProgramData%\BootProfileSwitcher\runtime\scripts\Uninstall-BootProfileSwitcherDeployment.ps1" -RestoreMachineBaselines -AsJson
   ```

2. Schedule per-user restoration and retain the user-logon hook:

   ```text
   powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%ProgramData%\BootProfileSwitcher\runtime\scripts\Uninstall-BootProfileSwitcherDeployment.ps1" -ScheduleUserBaselineRestore -AsJson
   ```

   Each affected user must log on once. Completion is recorded at
   `%LocalAppData%\BootProfileSwitcher\state\pending-user-baseline-restore.json`.

3. After reviewing all completion records, remove installed components, for
   example:

   ```text
   powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%ProgramData%\BootProfileSwitcher\runtime\scripts\Uninstall-BootProfileSwitcherDeployment.ps1" -RemoveStartupHook -RemoveUserLogonHook -RemoveBootMenu -RemoveConfiguration -RemoveMachineState -Force -AsJson
   ```

4. Remove the runtime only in a separate final step:

   ```text
   powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%ProgramData%\BootProfileSwitcher\runtime\scripts\Uninstall-BootProfileSwitcherDeployment.ps1" -RemoveRuntime -Force -AsJson
   ```

The external worker writes
`%ProgramData%\BootProfileSwitcher\runtime-removal-result.json`. Removal is
complete only when it reports `succeeded: true` and the runtime directory is
absent.

## Operational notes

- Both hooks use only the local ProgramData runtime.
- The user-logon hook handles HKCU data only for the currently logged-on user.
- Use pilot groups and maintain a documented rollback plan.
