# A4 – Profile Startup Script Execution Proof of Concept

## Objective

A4 validates that BootProfile Switcher can execute profile-specific startup
logic after the selected boot profile has been detected automatically during
system startup.

A4 extends the A3 startup hook. The startup hook still detects the current boot
profile, but now also executes the matching profile script:

```text
profiles/mode-a/startup.ps1
profiles/mode-b/startup.ps1
```

## Scope

Included:

- Execute a profile-specific PowerShell script for Mode A or Mode B.
- Pass the detected mode, display name and managed BCD identifier to the script.
- Write validation output to `logs/profile-startup-actions.log`.
- Keep the existing startup detection log in `logs/startup-profile.log`.

Not included:

- Real system configuration changes.
- Network, service, driver or hardware configuration.
- User-facing profile management.

## Execution Flow

```text
Windows Boot Manager
        |
        v
Mode A / Mode B selected
        |
        v
Windows starts
        |
        v
Scheduled Task: BootProfileSwitcher-StartupHook
        |
        v
scripts/Invoke-BootProfileStartupHook.ps1
        |
        v
scripts/Get-CurrentBootProfile.ps1
        |
        v
profiles/mode-a/startup.ps1 or profiles/mode-b/startup.ps1
        |
        v
logs/profile-startup-actions.log
```

## Validation Steps

1. Install the boot menu:

   ```text
   install.cmd
   ```

2. Install the startup hook:

   ```text
   install-startup-hook.cmd
   ```

3. Restart Windows and select `BootProfile Switcher - Mode A`.

4. After login, inspect:

   ```powershell
   Get-Content .\logs\startup-profile.log
   Get-Content .\logs\profile-startup-actions.log
   ```

   Expected result:

   - `startup-profile.log` contains a `mode=A` line.
   - `profile-startup-actions.log` contains a `profile=mode-a` line.

5. Restart Windows and select `BootProfile Switcher - Mode B`.

6. Inspect the same logs again.

   Expected result:

   - `startup-profile.log` contains a `mode=B` line.
   - `profile-startup-actions.log` contains a `profile=mode-b` line.

7. Clean up when finished:

   ```text
   uninstall-startup-hook.cmd
   uninstall.cmd
   ```

## Success Criteria

A4 is successful when both Mode A and Mode B automatically execute their own
profile startup script during system startup and leave distinct validation
entries in `logs/profile-startup-actions.log`.

## Notes

The profile scripts intentionally perform harmless logging only. This keeps the
PoC safe while proving that the complete chain from boot menu selection to
profile-specific startup execution works.
