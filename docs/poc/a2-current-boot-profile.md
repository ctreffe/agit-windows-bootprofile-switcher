# A2 – Current Boot Profile Detection

A2 validates whether Windows exposes enough information after startup to detect
which BootProfile Switcher boot menu entry was selected.

A1 already showed during manual validation that `bcdedit /enum "{current}"`
returns the selected proof-of-concept boot entry description after booting via
Mode A or Mode B.

## Scope

A2 intentionally starts with the smallest useful detection mechanism:

- read the current BCD entry with `bcdedit /enum "{current}"`
- parse the `description` field
- compare it with the managed entries stored in `state/boot-menu.json`
- report the detected mode

This step does not yet resolve the real BCD object identifier behind the
`{current}` alias. GUID-based detection remains a follow-up investigation.

## Usage

Install the A1 boot menu first:

```powershell
.\install.cmd
```

Restart Windows and choose either `BootProfile Switcher - Mode A` or
`BootProfile Switcher - Mode B` in the Windows Boot Manager.

After Windows has started, run:

```powershell
.\scripts\Get-CurrentBootProfile.ps1
```

Machine-readable output is available with:

```powershell
.\scripts\Get-CurrentBootProfile.ps1 -AsJson
```

## Expected results

After booting Mode A:

```text
Current BootProfile Switcher profile detected.
Mode:        A
Name:        BootProfile Switcher - Mode A
```

After booting Mode B:

```text
Current BootProfile Switcher profile detected.
Mode:        B
Name:        BootProfile Switcher - Mode B
```

If Windows was started through the normal Windows entry, the script should report
that the current boot entry is not a managed BootProfile Switcher profile.

## Validation notes

A2 is considered validated when:

- Mode A is detected after booting through Mode A
- Mode B is detected after booting through Mode B
- the normal Windows boot entry is not falsely identified as a managed profile
- JSON output is suitable for later startup automation

## Known limitation

The current implementation uses the BCD entry description as the detection key.
This is acceptable for the first A2 diagnostic step, but it is not the final
architecture. The preferred long-term identity is the real BCD object identifier
if it can be resolved reliably.
