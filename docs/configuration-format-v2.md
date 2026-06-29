# Configuration Format v2

Configuration Format v2 is the planned configuration shape for the next structural BootProfile Switcher milestones.

It is introduced in v1.2.0 as a design and validation target. Runtime boot menu creation from this format is planned for a later milestone.

## Goals

Configuration Format v2 is intended to support:

- a variable number of managed boot profiles
- freely chosen profile display names
- configuration-driven boot menu creation
- constrained handling of the Windows default boot entry
- profile-local module settings
- future production modules such as Service Control

## Default Entry

The Windows default boot entry is not a normal BootProfile Switcher profile.

It is the recovery and return path of the system. Configuration Format v2 therefore models it separately under `bootMenu.defaultEntry`.

The default entry should only support carefully scoped options:

- `rename`
- `displayName`
- `hide`

Any future implementation that renames or hides the default entry must store enough baseline state to restore the desired normal system state during uninstall.

## Managed Profiles

Managed BootProfile Switcher profiles are listed under `profiles`.

Each managed profile has:

- `id` for stable internal identity
- `displayName` for user-facing labels
- `bootMenu.enabled` for future boot menu creation
- `modules` as an object containing selected modules and their settings
- `scripts` for future custom script support

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

## Example

The v2 example configuration is:

```text
config/profiles.v2.example.json
```

The current production runtime still uses the installed `profiles.json` path and existing startup flow. v2 exists so the configuration model can be validated before boot menu creation is made configuration-driven.
