# Startup and User-Application Control Discovery Findings

Date: 2026-07-12

This document records the v1.6.0 read-only discovery refresh for Microsoft
Teams, OneDrive, ownCloud and Microsoft Office.

The inventory was generated with:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\scripts\Inspect-ServiceStartupControlTargets.ps1 -AsJson
```

The refresh was run in an elevated PowerShell session so services and scheduled
tasks could be read completely. No system state was modified.

## Summary

The refreshed local inventory confirms the v1.6.0 direction:

- Teams, OneDrive, ownCloud and Microsoft Office are not `service-control`
  targets on this machine.
- Teams and ownCloud have concrete startup registry surfaces that are plausible
  first `startup-control` candidates.
- OneDrive has several SID-scoped scheduled tasks. Its `Startup Task` entries
  are plausible candidates, while reporting and standalone update tasks need a
  more cautious capability decision.
- Microsoft Office has no Outlook-specific startup registry entry,
  startup-folder entry or running process in this refresh. It matched Office
  scheduled tasks that are intentionally relevant because Office startup and
  update behavior are part of the desired control scope.

The first v1.6.0 implementation should therefore start with dry-run inventory
and allow-listed startup surfaces before any real changes.

## Target Findings

### Microsoft Teams

Classification: `startup-control-or-user-app-control`

Observed services:

- None.

Observed scheduled tasks:

- None.

Observed startup registry entries:

- `HKCU:\Software\Microsoft\Windows\CurrentVersion\Run`
  - `com.squirrel.Teams.Teams`
- `HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Run`
  - `TeamsMachineInstaller`

Observed startup-folder entries:

- None.

Observed processes:

- None.

Capability note:

Teams has concrete startup registry entries and no current service or task
surface in this refresh. The first implementation can dry-run and later control
explicitly allow-listed Teams startup values. `TeamsMachineInstaller` should be
treated cautiously because it is machine-wide installer behavior, not only
per-user application startup.

### OneDrive

Classification: `startup-control-or-user-app-control`

Observed services:

- None.

Observed scheduled tasks:

- `OneDrive Reporting Task-<SID>` entries: 3
- `OneDrive Standalone Update Task-<SID>` entries: 3
- `OneDrive Startup Task-<SID>` entries: 3

Observed startup registry entries:

- None.

Observed startup-folder entries:

- None.

Observed processes:

- None.

Capability note:

OneDrive is task-oriented on this machine. `OneDrive Startup Task-<SID>` is the
clearest first candidate for startup suppression. Reporting and standalone
update tasks should not be disabled by default until the module design records
whether update/reporting behavior is intentionally in scope.

### ownCloud

Classification: `startup-control-or-user-app-control`

Observed services:

- None.

Observed scheduled tasks:

- None.

Observed startup registry entries:

- `HKCU:\Software\Microsoft\Windows\CurrentVersion\Run`
  - `ownCloud`

Observed startup-folder entries:

- None.

Observed processes:

- `owncloud`

Capability note:

ownCloud has a concrete per-user startup registry entry and an active running
process. The startup entry is a plausible first startup-control candidate.
Running process behavior should stay inspect-only until user-session process
handling has explicit safety rules.

### Microsoft Office

Classification: `startup-control-or-user-app-control`

Observed services:

- None.

Observed scheduled tasks:

- `\Microsoft\Office\Office Automatic Updates 2.0`
- `\Microsoft\Office\Office ClickToRun Service Monitor`
- `\Microsoft\Office\Office Feature Updates`
- `\Microsoft\Office\Office Feature Updates Logon`

Observed startup registry entries:

- None.

Observed startup-folder entries:

- None.

Observed processes:

- None.

Capability note:

Microsoft Office has no Outlook-specific startup surface in this refresh. The
matched Office scheduled tasks are Office maintenance/update surfaces and are
intentionally relevant for v1.6.0 because Office startup and update behavior
should be controllable when requested. The first implementation should
allow-list exact Office task identities instead of using broad task-name
matching. Outlook process handling remains inspect-only unless a later
user-session design is accepted.

## v1.6.0 Recommendation

The next implementation step should build dry-run validation for a
startup/user-application control module with explicit allow-list entries for:

- Teams startup registry values
- ownCloud startup registry values
- OneDrive startup scheduled tasks
- Microsoft Office scheduled task classification

The module should reject unsupported application identifiers and unsupported or
ambiguous control surfaces. Real changes should wait until dry-run output and
baseline/restore behavior have been validated on the target machine.
