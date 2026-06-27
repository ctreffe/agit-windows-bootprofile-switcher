# A1 Boot Menu Proof of Concept

## Purpose

A1 validates that BootProfile Switcher can create a reversible Windows Boot Manager menu with two profile-oriented entries:

- `BootProfile Switcher - Mode A`
- `BootProfile Switcher - Mode B`

This step does not detect the selected boot entry yet and does not execute profile startup logic. It only establishes the boot menu foundation for the v0.3.0 Boot Profile Detection Proof of Concept.

## Scope

Included:

- create two Windows Boot Manager entries by copying the default Windows entry
- add both entries to the Boot Manager display order
- set a temporary Boot Manager timeout
- store created entry identifiers in `state/boot-menu.json`
- create a BCD backup before modifying the store
- inspect current state and Boot Manager output
- remove the managed entries again

Not included:

- detecting which boot entry was selected
- running scripts before logon
- changing system configuration based on a profile
- creating a GUI

## User-facing wrappers

```text
install.cmd
uninstall.cmd
```

The command wrappers live in the repository root and are intended for double-click usage from Windows Explorer. They request administrator privileges through UAC when required and then call the underlying PowerShell scripts with `-ExecutionPolicy Bypass` for that process only.

## Scripts

```text
scripts/Install-BootProfileMenu.ps1
scripts/Get-BootProfileMenuStatus.ps1
scripts/Uninstall-BootProfileMenu.ps1
```

## Test procedure

For normal interactive testing, double-click `install.cmd` from the repository root and approve the UAC prompt. After validation, double-click `uninstall.cmd` to remove the entries again.

For manual testing, open Windows PowerShell as Administrator from the repository root.

If local script execution is blocked for the current shell, temporarily allow it for this PowerShell process only:

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
```

Run a dry run first:

```powershell
.\scripts\Install-BootProfileMenu.ps1 -WhatIf
```

Install the boot menu entries:

```powershell
.\scripts\Install-BootProfileMenu.ps1
```

Inspect the managed state and the current Boot Manager configuration:

```powershell
.\scripts\Get-BootProfileMenuStatus.ps1
```

Restart Windows and verify that the boot menu displays both entries:

```text
BootProfile Switcher - Mode A
BootProfile Switcher - Mode B
```

After validation, remove the entries again. Either double-click `uninstall.cmd`, or run manually:

```powershell
.\scripts\Uninstall-BootProfileMenu.ps1
```

## Validation result

Validated on Windows 11 during A1 development:

- the install script created both boot menu entries
- both entries appeared in the Boot Manager display order
- the state file contained the expected identifiers
- the uninstall script removed the entries successfully after fixing a PowerShell string interpolation issue
- reinstall testing showed that `{default}` is a more robust copy source than `{current}` after booting through a managed entry
- command wrappers were added to simplify installation and removal for normal Windows users

## Known limitations

The installer copies `{default}` instead of `{current}` so reinstalling remains reliable even if the current Windows session was started from a proof-of-concept entry that has since been removed.

The current implementation stores only the created entry identifiers. It does not yet persist or restore the previous timeout value. The uninstall script currently sets the timeout to `0` after removing the proof-of-concept entries.

This is acceptable for A1 because the goal is to validate reversible boot menu creation, not final boot manager state management.
