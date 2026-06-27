# A2 – Current Boot Profile Detection

A2 validates whether Windows exposes enough information after startup to detect
which BootProfile Switcher boot menu entry was selected.

A1 already showed during manual validation that `bcdedit /enum "{current}"`
returns the selected proof-of-concept boot entry description after booting via
Mode A or Mode B.

Follow-up validation during A2 also showed that `bcdedit /enum "{current}" /v`
returns the real BCD object identifier for the selected entry. Without `/v`,
`bcdedit` exposes the identifier as the `{current}` alias. With `/v`, it exposes
the underlying GUID.

## Scope

A2 uses GUID-based detection as the primary mechanism:

- read the current BCD entry with `bcdedit /enum "{current}" /v`
- parse the real BCD object identifier
- compare it with the managed identifiers stored in `state/boot-menu.json`
- report the detected mode

The implementation keeps description-based detection as a fallback for
diagnostics and compatibility.

## Usage

Install the A1 boot menu first:

```powershell
.\install.cmd
```

Restart Windows and choose either `BootProfile Switcher - Mode A` or
`BootProfile Switcher - Mode B` in the Windows Boot Manager.

After Windows has started, run the command wrapper from the repository root:

```cmd
detect-current-profile.cmd
```

Alternatively, from an elevated PowerShell session, run:

```powershell
.\scripts\Get-CurrentBootProfile.ps1
```

Machine-readable output is available with:

```powershell
.\scripts\Get-CurrentBootProfile.ps1 -AsJson
```

For troubleshooting or future regression checks, the read-only inspection script
can compare the current BCD entry, verbose current BCD output, all BCD entries
and the managed A1 state file:

```powershell
.\scripts\Inspect-CurrentBootEntry.ps1
.\scripts\Inspect-CurrentBootEntry.ps1 -AsJson
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

A2 has been validated on Windows 11 for the core BootProfile Switcher proof of concept:

- Mode A is detected after booting through Mode A
- Mode B is detected after booting through Mode B
- `bcdedit /enum "{current}" /v` exposes the real BCD identifier for Mode A
- `bcdedit /enum "{current}" /v` exposes the real BCD identifier for Mode B
- the script resolves the detected mode by matching the current BCD identifier to the managed identifier stored in `state/boot-menu.json`
- `scripts/Inspect-CurrentBootEntry.ps1` confirmed that verbose current BCD output exposes the managed Mode A and Mode B GUIDs

The normal Windows boot entry and JSON output remain useful regression checks for later automation work.

## Detection behavior

The current implementation uses GUID-based detection first. It reads the current
BCD entry with verbose output, extracts the real BCD object identifier and maps
that identifier to the managed entries created by A1.

If GUID-based detection cannot identify a managed entry, the script falls back
to matching the BCD entry description against the managed entry names. This keeps
the original A2 detection bridge available as a diagnostic fallback.
