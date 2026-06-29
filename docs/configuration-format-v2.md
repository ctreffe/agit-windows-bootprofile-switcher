# Configuration Format v2

Configuration Format v2 is the configuration shape for current structural BootProfile Switcher milestones.

It was introduced in v1.2.0 as a design and validation target. Starting with v1.3.0, boot menu installation can read this format directly.

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
- `bootMenu.enabled` for boot menu creation
- `modules` as an object containing selected modules and their settings
- `scripts` for future custom script support

Profile IDs must use lowercase letters, numbers and single hyphen separators,
for example `network-isolation` or `experiment-local`. The old v1 `mode` field
is not part of v2.

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

## Example

The v2 example configuration is:

```text
config/profiles.v2.example.json
```

The current runtime uses the installed `profiles.json` path and existing startup flow. Boot menu installation reads v2 from that machine-wide path by default, or from an explicit `-ConfigPath` override for demos, tests and migration work.
