# Configuration Format v2

Configuration Format v2 is the configuration shape for current structural BootProfile Switcher milestones.

It was introduced in v1.2.0 as a design and validation target. Starting with v1.3.0, boot menu installation can read this format directly.

This document is written as a practical guide for editing `profiles.json`.
It explains what each part of the file means, which values are safe to change
first and how to validate the result before installing it.

## Goals

Configuration Format v2 is intended to support:

- a variable number of managed boot profiles
- freely chosen profile display names
- configuration-driven boot menu creation
- constrained handling of the Windows default boot entry
- profile-local module settings
- future production modules such as Service Control

## Where The Configuration Lives

The default machine-wide configuration file is:

```text
C:\ProgramData\BootProfileSwitcher\config\profiles.json
```

BootProfile Switcher reads this file during startup. The boot menu installer
also uses it by default when creating managed boot entries.

For development, tests and demos, scripts can use another file through
`-ConfigPath`. The repository contains these useful examples:

- `config/profiles.v2.example.json` is the general v2 example.
- `config/demos/config-driven-boot-menu.json` demonstrates multiple managed boot entries.
- `config/demos/network-isolation.json` demonstrates the real Network Isolation lifecycle.

Do not edit the installed ProgramData file blindly. Prefer editing a copy in
the repository or another working location, validating it, then installing it
with the provided installer script.

## File Structure

A v2 configuration has three top-level parts:

```json
{
  "schemaVersion": 2,
  "bootMenu": {},
  "profiles": []
}
```

`schemaVersion` must be `2`.

`bootMenu` describes global Windows Boot Manager behavior.

`profiles` contains the managed BootProfile Switcher profiles that may appear
in the boot menu and may run modules during startup.

The Windows default boot entry is not listed in `profiles`. It is handled only
through `bootMenu.defaultEntry`.

## Default Entry

The Windows default boot entry is not a normal BootProfile Switcher profile.

It is the recovery and return path of the system. Configuration Format v2 therefore models it separately under `bootMenu.defaultEntry`.

The default entry should only support carefully scoped options:

- `rename`
- `displayName`
- `hide`

Any future implementation that renames or hides the default entry must store enough baseline state to restore the desired normal system state during uninstall.

Current fields:

- `rename` controls whether the default Windows boot entry description is changed.
- `displayName` is the replacement name when `rename` is `true`; it must be `null` when `rename` is `false`.
- `hide` controls whether the default Windows boot entry is removed from the visible boot menu display order.

For cautious first tests, keep:

```json
"defaultEntry": {
  "rename": false,
  "displayName": null,
  "hide": false
}
```

The config-driven boot menu demo uses `hide = true` to demonstrate that the
normal Windows entry can be hidden from the display order without deleting it.
Uninstall restores the recorded default-entry state.

## Managed Profiles

Managed BootProfile Switcher profiles are listed under `profiles`.

Each managed profile has:

- `id` for stable internal identity
- `displayName` for user-facing labels
- `bootMenu.enabled` for boot menu creation
- `modules` as an object containing selected modules and their settings
- `scripts` for future custom script support

Profile IDs must use lowercase letters, numbers and single hyphen separators,
for example `network-isolation` or `experiment-local`. The old v1 `mode` field
is not part of v2.

A minimal managed profile looks like this:

```json
{
  "id": "experiment-local",
  "displayName": "Experiment Local",
  "bootMenu": {
    "enabled": true
  },
  "modules": {
    "validation-log": {}
  },
  "scripts": []
}
```

Field meanings:

- `id` is the stable internal identifier. Keep it lowercase and do not rename it casually after deployment.
- `displayName` is what users see in the Windows Boot Manager.
- `bootMenu.enabled` decides whether this profile gets a managed boot entry.
- `modules` selects what BootProfile Switcher runs when this profile is detected.
- `scripts` is reserved for future custom script support. It must be an array, but custom scripts are not executed yet.

If `bootMenu.enabled` is `false`, the profile can remain in configuration for
future use, but the boot menu installer will not create a boot entry for it.

## Module Settings

Module settings are stored directly on each profile under `modules`.

This keeps each profile readable without merging settings from multiple places.
For the expected two or three managed profiles on a machine, explicit
profile-local module settings are easier to review than inherited global
defaults.

```json
"modules": {
  "network-isolation": {
    "dryRun": true,
    "disable": {
      "ethernet": true,
      "wifi": true,
      "cellular": true,
      "bluetoothNetwork": true
    },
    "exclude": {
      "macAddresses": [],
      "interfaceDescriptions": [],
      "interfaceAliases": []
    }
  },
  "validation-log": {}
}
```

Global module defaults may be reconsidered later if a real deployment need
appears. They are intentionally not part of v2.

Known modules in the current repository:

- `validation-log` writes harmless validation log entries.
- `network-isolation` can disable and restore configured network adapter categories.
- `service-control` can currently inspect planned Windows Search / `WSearch`
  service-control actions in dry-run mode.
- `demo-system-marker` is a temporary foundation demo module.

### Network Isolation Settings

`network-isolation` is the first module that can change real Windows state.
Start with `dryRun = true` when preparing a new configuration:

```json
"network-isolation": {
  "dryRun": true,
  "disable": {
    "ethernet": true,
    "wifi": true,
    "cellular": true,
    "bluetoothNetwork": true
  },
  "exclude": {
    "macAddresses": [],
    "interfaceDescriptions": [],
    "interfaceAliases": []
  }
}
```

When `dryRun` is `true`, the module logs what it would do without disabling
adapters. Change it to `false` only after reviewing the logged decisions on the
target machine.

The `disable` object selects adapter categories:

- `ethernet` for wired network adapters
- `wifi` for wireless LAN adapters
- `cellular` for mobile broadband adapters
- `bluetoothNetwork` for Bluetooth PAN network adapters

The `exclude` object keeps selected adapters out of isolation. Use exclusions
when a management adapter, recovery path or other required connection must stay
available.

`bluetoothNetwork` does not disable the Bluetooth radio or a USB Bluetooth
device. It only targets Bluetooth network adapters such as Bluetooth PAN.

## Validation Rules

The v2 validator intentionally rejects ambiguous or legacy shapes:

- unsupported top-level properties
- v1-only profile fields such as `mode` or `moduleSettings`
- invalid profile IDs
- duplicate profile IDs
- duplicate display names
- empty `modules` objects
- unknown module names
- non-string script entries
- default-entry display names when `rename` is `false`

These rules keep the format explicit as the source for configuration-driven
boot menu installation.

## Safe Editing Workflow

Use this workflow when changing a configuration:

1. Copy an existing example, such as `config/profiles.v2.example.json`.
2. Change one profile at a time.
3. Keep `network-isolation.dryRun` set to `true` until the log output is reviewed.
4. Validate the file:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\scripts\Test-BootProfileConfiguration.ps1 -ConfigPath .\config\profiles.v2.example.json -AsJson
```

5. Install the validated configuration:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\scripts\Install-BootProfileConfiguration.ps1 -SourcePath .\config\profiles.v2.example.json
```

6. Install or update the managed boot menu only after configuration validation succeeds.

The validator only checks structure and known settings. It does not prove that
a profile is operationally safe for a specific machine. Review adapter names,
exclusions and dry-run logs before enabling real Network Isolation changes.

## Common Changes

To add a harmless test profile, copy an existing profile and change `id`,
`displayName` and `modules`:

```json
{
  "id": "maintenance",
  "displayName": "Maintenance",
  "bootMenu": {
    "enabled": true
  },
  "modules": {
    "validation-log": {}
  },
  "scripts": []
}
```

To show a profile in configuration but keep it out of the boot menu, set:

```json
"bootMenu": {
  "enabled": false
}
```

To test Network Isolation without changing adapters, keep:

```json
"dryRun": true
```

To allow real Network Isolation changes after validation, set:

```json
"dryRun": false
```

Use `dryRun = false` only in the dedicated Network Isolation demo or in a
configuration that has been reviewed for the target machine.

## Troubleshooting

If validation fails, read the `errors` array in the JSON output. Common causes
are duplicate `id` values, duplicate `displayName` values, invalid profile IDs,
unknown module names or a `displayName` under `bootMenu.defaultEntry` while
`rename` is `false`.

If a profile does not appear in the boot menu, check `profiles[].bootMenu.enabled`.

If a profile appears in the boot menu but no module runs, check that the
resolver state profile ID matches a configured profile `id`, and check
`logs/startup-profile.log` for `dispatchSkippedReason`.

If Network Isolation does not disable adapters, check whether `dryRun` is still
`true` and review `logs/module-actions.log`.

If Network Isolation disabled adapters unexpectedly, use
`uninstall-network-isolation-demo.cmd` for the demo scenario, or restore adapter
state manually through Windows if the lifecycle state is no longer available.

## Example

The v2 example configuration is:

```text
config/profiles.v2.example.json
```

The current runtime uses the installed `profiles.json` path and existing startup flow. Boot menu installation reads v2 from that machine-wide path by default, or from an explicit `-ConfigPath` override for demos, tests and migration work.
