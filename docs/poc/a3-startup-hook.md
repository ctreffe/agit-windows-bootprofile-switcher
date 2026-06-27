# A3 – Startup Hook Proof of Concept

## Goal

A3 validates whether BootProfile Switcher can run the current boot profile
detection automatically during Windows startup.

The goal is not yet to apply real profile-specific system configuration. The
goal is to prove the following chain:

```text
Windows Boot Manager selection
→ Windows startup
→ scheduled task at system startup
→ BootProfile Switcher detection
→ startup log entry
```

## Implementation

A3 adds a Windows Scheduled Task installed by:

```text
install-startup-hook.cmd
```

The task runs as the local `SYSTEM` account with an `AtStartup` trigger and
executes:

```text
scripts/Invoke-BootProfileStartupHook.ps1
```

The hook script invokes:

```text
scripts/Get-CurrentBootProfile.ps1
```

and writes the detection result to:

```text
logs/startup-profile.log
```

## Validation

A3 was validated on Windows 11 with the A1 boot menu installed.

Validation sequence:

1. Install the boot menu with `install.cmd`.
2. Install the startup hook with `install-startup-hook.cmd`.
3. Reboot and select `BootProfile Switcher - Mode A`.
4. Confirm that `logs/startup-profile.log` contains a Mode A entry.
5. Reboot and select `BootProfile Switcher - Mode B`.
6. Confirm that `logs/startup-profile.log` contains a Mode B entry.
7. Remove the startup hook with `uninstall-startup-hook.cmd`.
8. Remove the boot menu with `uninstall.cmd`.

Observed validation output:

```text
detected=true | mode=A | name=BootProfile Switcher - Mode A
detected=true | mode=B | name=BootProfile Switcher - Mode B
```

## Result

A3 confirms that BootProfile Switcher can run profile detection automatically
during Windows startup and record the selected boot profile without manual
interaction after login.

This completes the proof that a Windows Boot Manager profile selection can be
transported into the early Windows startup phase and made available to further
initialization logic.

## Limitations

- The hook currently writes only a diagnostic log entry.
- No profile-specific configuration changes are applied yet.
- Detection uses the GUID-based BCD identifier mapping established in A2, with
  description-based detection retained as a fallback.
