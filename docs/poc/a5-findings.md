# A5 - Proof-of-Concept Findings

## Objective

A5 summarizes the findings from the Boot Profile Detection Proof of Concept and
captures the resulting architectural direction before finalizing `v0.3.0`.

The proof of concept tested the core hypothesis:

Can a user select a boot profile in the Windows Boot Manager and can that
selection be detected after Windows startup so profile-specific initialization
can run automatically?

## Validated Chain

The complete proof-of-concept chain has been validated:

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
current BCD entry detected
        |
        v
startup hook runs at system startup
        |
        v
profile-specific startup script executes
```

## Findings

### A1 - Boot Menu Creation

A1 validated that BootProfile Switcher can create and remove two managed Windows
Boot Manager entries:

- `BootProfile Switcher - Mode A`
- `BootProfile Switcher - Mode B`

The entries are created by copying `{default}`. Earlier validation showed that
copying `{current}` can become unreliable after booting from and removing a
managed proof-of-concept entry.

The installer stores the managed BCD identifiers in `state/boot-menu.json`.

### A2 - Current Boot Profile Detection

A2 validated that Windows exposes enough information after startup to identify
the selected BootProfile Switcher entry.

The final detection strategy is GUID-based:

- `bcdedit /enum "{current}"` exposes the identifier as the `{current}` alias.
- `bcdedit /enum "{current}" /v` exposes the real BCD object identifier.
- The real identifier can be matched against the managed identifiers stored in
  `state/boot-menu.json`.

Description-based detection remains available as a fallback and diagnostic
bridge.

### A3 - Startup Hook

A3 validated that detection can run automatically during Windows startup.

A Windows Scheduled Task named `BootProfileSwitcher-StartupHook` runs with an
`AtStartup` trigger and writes detection results to
`logs/startup-profile.log`.

This validates that the selected boot profile can be made available without
manual action after login.

### A4 - Profile Startup Scripts

A4 validated that the startup hook can dispatch profile-specific startup logic.

The hook executes:

- `profiles/mode-a/startup.ps1`
- `profiles/mode-b/startup.ps1`

The proof-of-concept scripts intentionally perform harmless validation logging
to `logs/profile-startup-actions.log`.

## Architectural Conclusions

The proof of concept supports the following architectural direction:

- Windows Boot Manager entries can serve as the boot profile selection mechanism.
- The boot profile resolver can use the real current BCD identifier as its
  primary profile identity.
- Managed BCD state should remain traceable in repository-owned runtime state.
- Description-based matching should remain available as a fallback, but not as
  the primary identity mechanism.
- A startup hook can bridge the selected boot profile into Windows startup.
- Profile application should remain modular and profile-specific logic should be
  dispatched by the engine rather than hardcoded into the resolver.

## Remaining Scope

The proof of concept intentionally does not implement the final profile engine.

Remaining future work includes:

- deciding the final startup execution mechanism for production use
- replacing harmless validation scripts with a real profile engine
- defining declarative profile configuration
- defining module interfaces
- validating behavior in managed deployment environments
- expanding cleanup and update behavior beyond proof-of-concept infrastructure

## Result

The `v0.3.0` proof-of-concept objective is satisfied.

The project has validated that Windows Boot Manager selection can be used as the
basis for selecting a boot profile and that the selected profile can trigger
profile-specific startup logic automatically after Windows startup.
