# Service and Startup Control Discovery Findings

Date: 2026-06-30

This document records the first local read-only discovery results for the
v1.4.0 Service and Startup Control Discovery milestone.

The inventory was generated with:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\scripts\Inspect-ServiceStartupControlTargets.ps1 -AsJson
```

No system state was modified.

## Summary

The local discovery confirms that the requested targets use different Windows
control surfaces.

Windows Search / Indexing is the clearest first `service-control` candidate.
It has a direct Windows service identity through `WSearch` and related search
processes.

Windows Update and Bitdefender are not good first implementation candidates.
They expose service identities, but they are likely self-healing,
policy-managed or vendor-protected and need special treatment.

Teams, OneDrive, ownCloud and Outlook are not service-control candidates based
on this inventory. They appear as startup entries, scheduled tasks or running
user applications.

## Target Findings

### Windows Update

Classification: `policy-or-vendor-guidance`

Observed services:

- `BITS`
- `DoSvc`
- `UsoSvc`
- `WaaSMedicSvc`
- `wuauserv`

Observed scheduled tasks:

- `\Microsoft\Windows\InstallService\ScanForUpdates`
- `\Microsoft\Windows\InstallService\ScanForUpdatesAsUser`
- `\Microsoft\Windows\InstallService\WakeUpAndContinueUpdates`
- `\Microsoft\Windows\InstallService\WakeUpAndScanForUpdates`
- `\Microsoft\Windows\WindowsUpdate\Scheduled Start`

Finding:

Windows Update spans several services and scheduled tasks. It should not be
treated as a simple service startup toggle. Future work should evaluate
Windows-supported policy or management surfaces before any direct control.

### Bitdefender

Classification: `policy-or-vendor-guidance`

Observed services:

- `BDESVC`
- `EPIntegrationService`
- `EPProtectedService`
- `EPRedline`
- `EPSecurityService`
- `EPUpdateService`

Observed processes:

- `bdredline`

Finding:

Bitdefender exposes multiple endpoint/security services and an active process.
Because security products can use tamper protection, BootProfile Switcher must
not bypass vendor protection mechanisms. This target is postponed until a
vendor-supported or policy-supported control model is known.

### Microsoft Teams

Classification: `startup-control-or-user-app-control`

Observed startup registry entries:

- `com.squirrel.Teams.Teams`
- `TeamsMachineInstaller`

Finding:

Teams appears as startup configuration rather than as a system service on this
machine. It belongs to a later startup-control or user-app-control module.

### OneDrive

Classification: `startup-control-or-user-app-control`

Observed scheduled tasks:

- `\OneDrive Reporting Task-S-1-5-21-1880078766-1776770297-1804922951-51586`
- `\OneDrive Standalone Update Task-S-1-5-21-1880078766-1776770297-1804922951-51586`
- `\OneDrive Startup Task-S-1-5-21-1880078766-1776770297-1804922951-51586`

Observed startup registry entries:

- `Delete Cached Update Binary`
- `Delete Cached Standalone Update Binary`
- `Uninstall 26.098.0524.0004`

Observed processes:

- `OneDrive.Sync.Service`

Finding:

OneDrive has scheduled tasks, update or cleanup startup entries and a running
process. It should not be modeled as a first `service-control` target.

### ownCloud

Classification: `startup-control-or-user-app-control`

Observed startup registry entries:

- `ownCloud`

Observed processes:

- `owncloud`

Finding:

ownCloud appears as a per-user startup application and running process. It
belongs to a later startup-control or user-app-control module.

### Outlook

Classification: `startup-control-or-user-app-control`

Observed scheduled tasks:

- `\Microsoft\Office\Office Automatic Updates 2.0`
- `\Microsoft\Office\Office ClickToRun Service Monitor`
- `\Microsoft\Office\Office Feature Updates`
- `\Microsoft\Office\Office Feature Updates Logon`

Observed processes:

- `OUTLOOK`

Finding:

Outlook appears through Office scheduled tasks and a running user application.
It is not a first service-control candidate.

### Windows Search / Indexing

Classification: `service-control-candidate`

Observed services:

- `WSearch`

Observed scheduled tasks:

- `\Microsoft\Windows\Shell\IndexerAutomaticMaintenance`

Observed processes:

- `SearchFilterHost`
- `SearchIndexer`
- `SearchProtocolHost`

Finding:

Windows Search / Indexing is the strongest first implementation candidate for
a narrow `service-control` module because `WSearch` is a clear Windows service.

## Recommendation

The next implementation milestone should design and implement a narrow
`service-control` module for Windows Search / `WSearch` first.

The first production module should:

- support explicit service allow-listing
- record baseline startup type and running state before changing anything
- restore baseline state when the profile no longer requests the service
  control behavior
- support dry-run validation before real changes
- avoid Windows Update, Bitdefender and per-user application targets

Windows Update and Bitdefender should remain postponed until policy-supported
or vendor-supported behavior is documented.

Teams, OneDrive, ownCloud and Outlook should be handled later through a
separate startup-control or user-app-control design.
