# Service and Startup Control Discovery

This document defines the v1.4.0 discovery scope for service, startup and
user-application control.

The milestone is intentionally read-only. Its purpose is to understand which
Windows control surfaces are involved before any production module attempts to
disable, stop, restore or otherwise control them.

## Target Interests

The initial discovery targets are:

- Windows Update
- Bitdefender
- Microsoft Teams
- OneDrive
- ownCloud
- Outlook
- Windows Search / drive indexing

These names describe user-facing intent. They do not necessarily map to a
single Windows service.

## Control Surfaces

The discovery separates targets into control surfaces:

- Windows services
- Scheduled Tasks
- machine-wide startup registry entries
- per-user startup registry entries
- startup-folder entries
- running user processes
- vendor-protected or policy-managed components

This distinction matters because BootProfile Switcher runs before interactive
user logon. A system service can often be inspected before logon, while
per-user startup applications such as Teams, OneDrive, ownCloud and Outlook may
belong to a later user-session control model.

## Read-Only Inventory Script

The initial inventory script is:

```text
scripts/Inspect-ServiceStartupControlTargets.ps1
```

Run it from the repository root:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\scripts\Inspect-ServiceStartupControlTargets.ps1 -AsJson
```

The script is read-only. It does not:

- stop services
- change service startup types
- disable scheduled tasks
- edit registry entries
- remove startup entries
- terminate processes
- bypass vendor protection

The output is JSON so results can be reviewed and compared across machines.

## Initial Classification

The first implementation should treat matches conservatively:

- `service-control-candidate` means the target may be suitable for a future
  service-control module after restore semantics are designed.
- `startup-control-or-user-app-control` means the target appears to involve
  user-session startup or application process behavior.
- `policy-or-vendor-guidance` means the target may be self-healing,
  policy-managed or protected by vendor tamper protection.

Windows Search / Indexing is the likely first service-control candidate because
the `WSearch` service has a clear system service identity.

Windows Update requires extra caution because related services and scheduled
tasks may be self-healing or policy-managed.

Bitdefender requires extra caution because security products may use
tamper-protection mechanisms. BootProfile Switcher should not bypass those
protections.

Teams, OneDrive, ownCloud and Outlook should not be treated as ordinary Windows
services until discovery proves that a service is the relevant control surface.

## Expected Outcome

The discovery milestone should produce:

- a local inventory of relevant services, tasks, startup entries and processes
- a classification for each requested target
- an explicit recommendation for the first implementable module scope
- a list of postponed or unsupported targets with reasons

Only after this discovery should the project implement a production
`service-control` module.
