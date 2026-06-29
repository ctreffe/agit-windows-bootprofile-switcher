# Network Isolation Module

## Purpose

`network-isolation` is the first production-oriented lifecycle module in BootProfile Switcher.

It can disable selected network adapter categories for isolating boot profiles and restore the last learned normal adapter baseline when the system starts again without active isolation.

The module is intended for scenarios where a Windows installation should remain usable while specific boot profiles run with restricted network connectivity.

## What The Module Controls

The module supports these adapter categories:

- `ethernet`
- `wifi`
- `cellular`
- `bluetoothNetwork`

Bluetooth support means Bluetooth network adapters such as Bluetooth PAN entries. It does not disable the Bluetooth radio or a USB Bluetooth adapter as a device. Full Bluetooth device isolation belongs in a later dedicated module or hardening milestone.

The module targets hardware network interfaces by default. VPN, tunnel, loopback and virtual adapters are logged and skipped in this first implementation. Bluetooth network adapters are an explicit opt-in exception because Windows may expose them as non-hardware interfaces.

## Safety Boundary

Network Isolation is adapter-level isolation.

It is intended to prevent ordinary users from simply continuing to use disabled target adapters. It is not a complete security boundary against local administrators, privileged management tools or later manual reconfiguration.

Future hardening should evaluate:

- Group Policy restrictions
- network UI restrictions
- device-management controls
- service controls
- firewall enforcement

Use this module only with that boundary in mind.

## Configuration

BootProfile Switcher uses Configuration Format v2. Each profile declares its module settings directly under `profiles[].modules`.

A profile activates Network Isolation by adding a `network-isolation` object to its `modules` object:

```json
{
  "schemaVersion": 2,
  "bootMenu": {
    "timeoutSeconds": 10,
    "sourceEntry": "{default}",
    "defaultEntry": {
      "rename": false,
      "displayName": null,
      "hide": false
    }
  },
  "profiles": [
    {
      "id": "network-isolation",
      "displayName": "Network Isolation",
      "bootMenu": {
        "enabled": true
      },
      "modules": {
        "network-isolation": {
          "dryRun": true,
          "disable": {
            "ethernet": true,
            "wifi": true,
            "cellular": false,
            "bluetoothNetwork": false
          },
          "exclude": {
            "macAddresses": [],
            "interfaceDescriptions": [],
            "interfaceAliases": []
          }
        }
      },
      "scripts": []
    }
  ]
}
```

Set `dryRun` to `false` only after validating the logged adapter decisions on the target machine.

## Per-Profile Settings

Network Isolation settings are intentionally profile-local in v2. This keeps small deployments easy to read: two or three boot profiles can each declare their own network policy without global defaults.

Different profiles may disable different adapter categories or use different exclusions. For example, one profile may disable Wi-Fi only, while another disables Ethernet, Wi-Fi, cellular and Bluetooth PAN network adapters.

## Exclusions

Adapters can be excluded by:

- MAC address
- interface description
- interface alias

MAC addresses are useful for stable per-device exceptions.

Interface descriptions are useful for matching hardware models across similar devices.

Interface aliases are useful when administrators deliberately assign predictable names through deployment or Group Policy.

## Lifecycle And Baseline

The module stores its normal adapter baseline and last run metadata in:

```text
%ProgramData%\BootProfileSwitcher\state\network-isolation-state.json
```

The lifecycle is:

1. If the previous run was not isolating, the current adapter snapshot may become the new normal baseline.
2. If the current profile is isolating, the configured adapter categories are disabled.
3. If the previous run was isolating and the current start is not isolating, the stored baseline is restored instead of learning the isolation-created state.

This allows administrative changes made during normal, non-isolating operation to become the new baseline automatically.

Restore decisions use adapter administrative state. This matters because adapters disabled by `Disable-NetAdapter` may be reported by Windows with runtime status `Not Present`, while their administrative state still shows that they can be re-enabled.

## Logging

The startup hook writes the overall result to:

```text
logs/startup-profile.log
```

Module actions are written to:

```text
logs/module-actions.log
```

The logs show whether configuration was valid, whether a profile was detected, which modules ran, which adapter decisions were made and whether a dispatch path was skipped.

## Demo

The module includes a dedicated demo setup:

```text
install-network-isolation-demo.cmd
```

The demo installs one managed boot menu entry named `Network Isolation`, installs a matching machine-wide profile configuration and installs the startup hook.

The demo profile disables Ethernet, Wi-Fi, cellular and Bluetooth PAN network adapters. It demonstrates the full lifecycle:

1. normal startup learns the current adapter baseline
2. `Network Isolation` startup disables the configured network paths
3. normal startup restores the learned baseline

The demo can be removed with:

```text
uninstall-network-isolation-demo.cmd
```

If an earlier ProgramData profile configuration was backed up during installation, the uninstall wrapper restores it.

The demo configuration is stored in:

```text
config/demos/network-isolation.json
```

## Validation

Validate the repository fixtures with:

```text
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\scripts\Test-BootProfileConfigurationFixtures.ps1 -AsJson
```

Validate the demo configuration with:

```text
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\scripts\Test-BootProfileConfiguration.ps1 -ConfigPath .\config\demos\network-isolation.json -AsJson
```

## Known Limits

- The module does not disable Bluetooth radios or USB Bluetooth adapter devices.
- The module does not currently manage VPN, tunnel, loopback or virtual adapters.
- Adapter-level isolation is not a full security boundary against local administrators.
- Stronger enterprise enforcement belongs in a future hardening milestone.
