# Service Control Module Design

## Purpose

`service-control` is the planned module family for controlling ordinary Windows
services from BootProfile Switcher profiles.

The module is intended to be generic. It should not become one module per
service. Instead, it should support an explicit allow-list of services that
have been validated as safe enough for BootProfile Switcher control.

The first supported service should be Windows Search / `WSearch`.

## First Supported Service

The initial implementation should support only:

```text
WSearch
```

`WSearch` is the first candidate because the v1.4.0 read-only discovery found a
clear service identity for Windows Search indexing.

Supporting `WSearch` first keeps the first implementation narrow while still
building the reusable shape for later ordinary Windows services.

## What The Module Controls

The module should control Windows services by service name.

For each supported service, the module may control:

- service startup type
- current running state

The first implementation should support a profile requesting that a service is
disabled for a managed boot profile, then restored to its learned baseline when
the system starts again without that request.

The v1.5.0 milestone should deliver the full first `WSearch` service-control
path. Dry-run is the first implementation and validation phase, not the final
milestone boundary.

The module should not control:

- scheduled tasks
- startup registry entries
- startup-folder entries
- interactive user-application processes
- vendor-protected security components
- Windows Update policy or self-healing behavior

Those surfaces belong to later module families or policy/vendor guidance.

## Configuration Shape

Configuration Format v2 keeps module settings profile-local. A future profile
may activate the module like this:

```json
{
  "id": "search-disabled",
  "displayName": "Search Disabled",
  "bootMenu": {
    "enabled": true
  },
  "modules": {
    "service-control": {
      "dryRun": true,
      "services": [
        {
          "name": "WSearch",
          "target": {
            "startupType": "Disabled",
            "runningState": "Stopped"
          }
        }
      ]
    }
  },
  "scripts": []
}
```

The first implementation should reject unsupported service names instead of
attempting best-effort control.

Allowed values for `startupType` should be intentionally narrow in the first
implementation:

- `Disabled`

Allowed values for `runningState` should be intentionally narrow in the first
implementation:

- `Stopped`

Restore behavior should use the learned baseline rather than hardcoded desired
values.

Unsupported service names are configuration errors. They should be rejected by
the configuration validation path rather than silently skipped at runtime.

## Allow-List

The module should include a small internal allow-list of supported service
definitions.

The initial allow-list should contain:

| Service | Display purpose | Initial support |
| --- | --- | --- |
| `WSearch` | Windows Search indexing | Disable and restore |

The allow-list exists to prevent a profile from using `service-control` as an
arbitrary service-disabling mechanism.

The allow-list is part of the safety model, not only documentation. A profile
that references a service outside the allow-list is invalid for the current
implementation.

Future services can be added only after discovery confirms:

- the service is a normal Windows service control target
- startup type and running state can be restored safely
- the service is not better handled through policy, vendor tooling or another
  module family
- the behavior can be tested in dry-run mode before real changes

## Lifecycle And Baseline

The module should be a lifecycle module.

It needs to run when a profile requests service control and also when no
current profile requests service control, because the latter case may need to
restore services changed by a previous run.

The module should store state in:

```text
%ProgramData%\BootProfileSwitcher\state\service-control-state.json
```

For each managed service, the state should record at least:

- service name
- whether the service existed when the baseline was learned
- baseline startup type
- baseline delayed automatic start flag, when Windows exposes it
- baseline running state
- observed dependent services, for diagnostics only
- whether the previous run actively controlled the service
- last profile id that requested control
- timestamp of the baseline snapshot
- timestamp of the last module run

Lifecycle rules:

1. If the previous run did not control a service, the current service state may
   become the normal baseline before any current control action is applied.
2. If the current profile requests service control, the module applies the
   configured target state after baseline learning.
3. If the previous run controlled a service and the current profile no longer
   requests that service, the module restores the learned baseline instead of
   learning the controlled state as normal.
4. If a service is missing, unsupported or cannot be inspected, the module logs
   a skip result and does not attempt modification.
5. Service dependencies are inspected and logged for diagnostics, but the first
   implementation does not automatically stop, start or reconfigure dependent
   services.

This mirrors the key Network Isolation lesson: do not accidentally learn a
module-created state as the new normal baseline.

## Dry-Run Behavior

The first implementation should default examples and demos to `dryRun = true`.

In dry-run mode, the module should:

- inspect supported services
- show whether a baseline would be learned
- show whether a service would be stopped
- show whether startup type would be changed
- show whether a previous baseline would be restored
- write normal module logs
- avoid changing service startup type
- avoid stopping or starting services

## Restore Semantics

Restore should use the learned baseline.

If the baseline says that `WSearch` was originally automatic and running, a
restore should return it to that state.

If the baseline says that `WSearch` was originally manual and stopped, a
restore should return it to that state.

If the baseline says that `WSearch` used delayed automatic startup, restore
should preserve that baseline value. Delayed automatic startup is a restore
value, not an explicit first-version target setting.

If the baseline service no longer exists, restore should log that the service
is missing and skip modification.

If restore fails, the module should log the attempted action and error clearly.

## Validation Plan

The first implementation should be validated in phases:

1. Validate configuration fixtures for supported and unsupported service names.
2. Run the module in dry-run mode with `WSearch` and confirm planned actions.
3. Validate that unsupported service names are hard configuration errors.
4. Validate lifecycle state creation without changing the service.
5. Validate delayed automatic startup baseline capture when the service exposes
   that value.
6. Validate dependency inspection logging without controlling dependencies.
7. Run a controlled real test only after dry-run output is reviewed.
8. Confirm a later non-controlling startup restores the learned baseline.

The dry-run phase should be committed and reviewed before the real apply/restore
phase is added. Both phases belong to the same v1.5.0 milestone unless
validation reveals a safety issue that requires rescoping.

## Non-Goals

The first implementation should not:

- support arbitrary services
- control Windows Update services
- control Bitdefender or other security vendor services
- disable scheduled tasks
- edit startup registry entries
- terminate user processes
- control Teams, OneDrive, ownCloud or Outlook
- control dependent services automatically
- bypass vendor tamper protection
- use service control as a complete security boundary

## Resolved Design Questions

- `Manual` and `Automatic` are restore-only values in the first implementation.
  The only explicit target startup type is `Disabled`.
- Service dependencies are inspected and logged for diagnostics, but they are
  not controlled automatically in the first implementation.
- Delayed automatic startup is stored as baseline/restore metadata when
  available, but it is not an explicit target setting in the first
  implementation.
- Unsupported service names are hard configuration errors, not runtime skips.
