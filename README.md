# BootProfile Switcher

![License](https://img.shields.io/github/license/ctreffe/agit-windows-bootprofile-switcher)
![Release](https://img.shields.io/github/v/tag/ctreffe/agit-windows-bootprofile-switcher)
![Last Commit](https://img.shields.io/github/last-commit/ctreffe/agit-windows-bootprofile-switcher)

[Deutsche Dokumentation](README.de.md)

> [!NOTE]
> **AI Collaboration**
>
> This project is developed through collaboration between the repository maintainer and an AI assistant.
>
> The collaboration model documents engineering practices, collaboration workflows and repository conventions used in this project.
>
> It is maintained in [ChatGPT.md](ChatGPT.md).

> [!NOTE]
> **Project Status**
>
> BootProfile Switcher has completed the Architecture milestone (`v0.2.0`), the Boot Profile Detection Proof of Concept (`v0.3.0`), the Boot Profile Detection milestone (`v0.4.0`), the Profile Engine milestone (`v0.5.0`), the Module System milestone (`v0.6.0`), the Configuration milestone (`v0.7.0`), the Integration milestone (`v0.8.0`), the Validation milestone (`v0.9.0`), the Initial Stable Release milestone (`v1.0.0`), the Network Isolation milestone (`v1.1.0`), the Configuration Format v2 milestone (`v1.2.0`), the Boot Menu From Configuration milestone (`v1.3.0`), the Service and Startup Control Discovery milestone (`v1.4.0`) and the Service Control for Windows Search milestone (`v1.5.0`).
>
> The `v1.5.0 – Service Control for Windows Search` milestone is complete. This release implements the generic allow-listed `service-control` module for `WSearch`, including dry-run, real apply, restore behavior and an elevation preflight for non-dry-run service changes.

## Overview

BootProfile Switcher is a configurable Windows boot profile engine that applies modular system profiles before user logon.

The project is intended to support Windows systems that need multiple operating profiles from a single Windows installation. A user selects a boot profile during system startup. BootProfile Switcher then applies the corresponding system configuration before interactive logon begins.

The initial use case is a Windows computer that can start either in normal operation or in an experimental profile with restricted or disabled network connectivity. The architecture is intentionally generic so that additional profiles and components can be added later.

## Quick Start: Foundation Demo

For the v1.0.0 foundation demo setup, use the combined wrapper from the repository root:

```text
install-demo.cmd
```

It requests administrator privileges when needed and runs the foundation demo setup
sequence:

1. install managed boot menu entries
2. install the validated profile configuration
3. install the startup hook

The demo setup can be removed with:

```text
uninstall-demo.cmd
```

The demo uninstall removes the startup hook, removes the managed boot menu
entries and deletes the temporary demo marker if present. It leaves the
ProgramData profile configuration unchanged so a customized configuration is
not removed unexpectedly.

## Quick Start: Network Isolation Demo

The Network Isolation module has its own documentation:

- [Network Isolation module documentation](docs/modules/network-isolation.md)

It also has its own demonstration setup:

```text
install-network-isolation-demo.cmd
```

This installs one managed boot menu entry named `Network Isolation`, installs a
matching machine-wide profile configuration and installs the startup hook. The
boot menu then lets the user choose between normal Windows startup and the
Network Isolation profile.

The demo profile disables Ethernet, Wi-Fi, cellular and Bluetooth PAN network
adapters and demonstrates the full lifecycle:

1. normal startup learns the current adapter baseline
2. `Network Isolation` startup disables the configured network paths
3. normal startup restores the learned baseline

The Network Isolation demo can be removed with:

```text
uninstall-network-isolation-demo.cmd
```

The uninstall wrapper restores the saved normal adapter baseline when needed,
then removes the startup hook and the managed demo boot entry. If an earlier
ProgramData profile configuration was backed up during installation, it is
restored.

Each production module should provide a small installable demo when practical.
The demo should show the module's intended behavior without requiring manual
configuration edits.

## Quick Start: Config-Driven Boot Menu Demo

The Configuration Format v2 boot menu demo installs a v2 configuration, creates
managed boot entries from that configuration and installs the startup hook:

```text
install-config-driven-boot-menu-demo.cmd
```

The demo creates three managed entries named `Network Isolation`,
`Experiment Local` and `Maintenance`. It also hides the default Windows boot
entry from the boot menu display order to demonstrate constrained
`bootMenu.defaultEntry.hide` behavior. The default entry is not deleted, and the
demo uninstall restores it through the recorded boot menu state:

```text
uninstall-config-driven-boot-menu-demo.cmd
```

## Individual Setup Steps

For the original two-profile validation setup, the easiest way to install or remove the managed boot menu entries is to use the command wrappers from the repository root:

```text
install.cmd
uninstall.cmd
```

Both wrappers can be started by double-clicking them in Windows Explorer. They request administrator privileges through UAC when required and then invoke the underlying PowerShell scripts with a process-local execution policy bypass.

The wrappers currently manage the BootProfile Switcher boot menu entries:

- `BootProfile Switcher - Mode A`
- `BootProfile Switcher - Mode B`

The underlying implementation remains in `scripts/` for explicit inspection and advanced manual testing.

## Quick Start: Configuration and Startup Hook

Before the startup hook can dispatch configured profile actions, install the
example profile configuration to the machine-wide default location:

```text
install-configuration.cmd
```

After installing the boot menu, the startup hook can be installed from the
repository root:

```text
install-startup-hook.cmd
```

The startup hook registers a Windows Scheduled Task that runs at system startup,
resolves the selected boot profile through `scripts/Resolve-BootProfile.ps1`,
invokes `scripts/Invoke-ProfileEngine.ps1`, dispatches modules from the
matching configured profile and writes the startup result to:

```text
logs/startup-profile.log
```

`validation-log` writes validation entries to:

```text
logs/module-actions.log
```

`network-isolation` is the first production-oriented lifecycle module. It can
disable configured hardware network adapter categories for isolating boot
profiles and restore the last learned normal adapter baseline after isolation.
For setup, warnings, configuration details and the module demo, see
[Network Isolation module documentation](docs/modules/network-isolation.md).

`demo-system-marker` is a temporary foundation demonstration module. It writes the
resolved profile to a harmless machine-wide marker at:

```text
C:\ProgramData\BootProfileSwitcher\runtime\demo-current-profile.json
```

The demo marker proves that profile-specific modules can apply a harmless
system-level change without changing Windows behavior. It remains available for
the foundation demo and can be removed in a later cleanup once the production
module demos fully replace it. The marker file can be deleted safely.

The hook can be removed with:

```text
uninstall-startup-hook.cmd
```

## Current Command and Configuration Reference

Current command wrappers:

- `install-demo.cmd` installs the v1.0.0 foundation demo setup in the expected order and requests elevation when needed.
- `uninstall-demo.cmd` removes the startup hook, managed boot menu entries and temporary demo marker while leaving ProgramData configuration unchanged.
- `install-network-isolation-demo.cmd` installs the Network Isolation module demo with one managed `Network Isolation` boot profile.
- `uninstall-network-isolation-demo.cmd` removes the Network Isolation module demo and restores the previous ProgramData profile configuration when a backup exists.
- `install-config-driven-boot-menu-demo.cmd` installs the Configuration Format v2 boot menu demo with multiple named managed profiles.
- `uninstall-config-driven-boot-menu-demo.cmd` removes the config-driven boot menu demo and restores the previous ProgramData profile configuration when a backup exists.
- `install.cmd` installs the managed BootProfile Switcher boot menu entries and requests elevation when needed.
- `install-configuration.cmd` installs a validated profile configuration to the default machine-wide configuration path and requests elevation when needed.
- `uninstall.cmd` removes the managed boot menu entries and requests elevation when needed.
- `install-startup-hook.cmd` installs the startup Scheduled Task.
- `uninstall-startup-hook.cmd` removes the startup Scheduled Task.
- `detect-current-profile.cmd` runs the current profile detection helper.

Current PowerShell entry points:

- `scripts/Get-BootProfileMenuStatus.ps1` reports managed boot menu state and detected BootProfile Switcher BCD entries.
- `scripts/Resolve-BootProfile.ps1` resolves the selected boot profile and writes structured resolver state.
- `scripts/Invoke-ProfileEngine.ps1` consumes resolver state, validates configuration and invokes only the modules selected by the matching configured profile.
- `scripts/Install-NetworkIsolationDemo.ps1` installs the Network Isolation module demo boot entry, configuration and startup hook.
- `scripts/Uninstall-NetworkIsolationDemo.ps1` removes the Network Isolation module demo and restores the previous profile configuration backup when available.
- `scripts/Install-ConfigDrivenBootMenuDemo.ps1` installs the config-driven boot menu demo.
- `scripts/Uninstall-ConfigDrivenBootMenuDemo.ps1` removes the config-driven boot menu demo.
- `scripts/Install-BootProfileConfiguration.ps1` validates and installs a profile configuration file to the default machine-wide configuration path.
- `scripts/Test-BootProfileConfiguration.ps1` validates a profile configuration file without applying changes.
- `scripts/Test-BootProfileConfigurationFixtures.ps1` validates the included known-good and known-bad configuration fixtures.
- `scripts/Inspect-ServiceStartupControlTargets.ps1` performs read-only service, startup and user-application control discovery for the v1.4.0 milestone.

The default machine-wide configuration path is:

```text
%ProgramData%\BootProfileSwitcher\config\profiles.json
```

The validated Configuration Format v2 example is stored in:

```text
config/profiles.v2.example.json
```

The Network Isolation module demo configuration is stored in:

```text
config/demos/network-isolation.json
```

The config-driven boot menu demo configuration is stored in:

```text
config/demos/config-driven-boot-menu.json
```

Configuration now drives module dispatch. If the default `profiles.json` is missing, invalid or does not contain the resolved profile ID, the boot profile performs no action. The engine reports the reason in its structured output, and the startup hook logs the configuration status, validation errors and dispatch skip reason to `logs/startup-profile.log`. Custom script paths are structurally accepted by the configuration format but are not executed yet.

Configuration Format v2 is documented in
[docs/configuration-format-v2.md](docs/configuration-format-v2.md). Boot menu installation can now read v2 directly from the machine-wide configuration or from an explicit `-ConfigPath` override.

Network Isolation is documented in detail in
[docs/modules/network-isolation.md](docs/modules/network-isolation.md).

Service Control is documented in
[docs/modules/service-control.md](docs/modules/service-control.md). The current
implementation supports dry-run and controlled apply/restore behavior for
`WSearch` as the first allow-listed service.

Startup and User-Application Control planning is documented in
[docs/modules/startup-user-application-control.md](docs/modules/startup-user-application-control.md).
The v1.6.0 design addresses Teams, OneDrive, ownCloud and Microsoft Office through a
shared control-surface model with per-application capability notes.

Known modules in the current repository:

- `validation-log`
- `network-isolation`
- `service-control` Windows Search service-control module
- `demo-system-marker` temporary foundation demo module

## Project Goals

BootProfile Switcher aims to provide:

- profile selection during system boot
- one shared Windows installation
- pre-logon system configuration
- modular profile management
- scriptable installation and removal
- deployment compatibility with Group Policy based environments
- clear logging and diagnosability
- reversible infrastructure changes

## Non-Goals

BootProfile Switcher is not intended to provide:

- multiple Windows installations
- a user-facing desktop application
- a replacement for Windows deployment tools
- hidden or undocumented system changes
- irreversible configuration changes

## Engineering Approach

This project follows the AGIT Collaboration Model documented in [ChatGPT.md](ChatGPT.md).

The project is developed with the following principles:

- architecture before implementation
- Windows-supported mechanisms before custom workarounds
- configuration instead of hardcoding
- modular design
- maintainability over short-term convenience
- Semantic Versioning
- meaningful changelog entries
- repository-ready change sets
- code and user-facing documentation that can be understood without private chat history

## Versioning

BootProfile Switcher follows Semantic Versioning.

The latest completed project milestone is:

```text
1.4.0 Service and Startup Control Discovery
```

## Validation

The repeatable validation scope for the current runtime path is documented in:

```text
docs/validation/v0.9-validation-checklist.md
```

The intended scope for the initial stable release is documented in:

```text
docs/release/v1.0.0-release-scope.md
```

Version tags should use a leading `v`, for example:

```text
v0.2.0
```

Version tags and GitHub Releases are created intentionally. Not every version tag requires a GitHub Release.

## Documentation

Core project documents:

- [PROJECT_CONTEXT.md](PROJECT_CONTEXT.md) – current project state and next development focus
- [README.md](README.md) – primary English project documentation
- [README.de.md](README.de.md) – German project documentation
- [CHANGELOG.md](CHANGELOG.md) – version history
- [ChatGPT.md](ChatGPT.md) – AGIT Collaboration Model
- [CODEX.md](CODEX.md) – local Codex operating policy
- [PHILOSOPHY.md](PHILOSOPHY.md) – project philosophy
- [docs/architecture.md](docs/architecture.md) – conceptual system architecture
- [docs/configuration-format-v2.md](docs/configuration-format-v2.md) – Configuration Format v2 documentation
- [docs/configuration-format-v2.de.md](docs/configuration-format-v2.de.md) – German Configuration Format v2 documentation
- [docs/discovery/service-startup-control.md](docs/discovery/service-startup-control.md) – Service and Startup Control discovery scope and inventory workflow
- [docs/discovery/service-startup-control-findings.md](docs/discovery/service-startup-control-findings.md) – Service and Startup Control discovery findings and first module recommendation
- [docs/discovery/startup-user-application-control-findings.md](docs/discovery/startup-user-application-control-findings.md) – Startup and User-Application Control discovery findings
- [docs/modules/service-control.md](docs/modules/service-control.md) – Service Control module design
- [docs/modules/startup-user-application-control.md](docs/modules/startup-user-application-control.md) – Startup and User-Application Control module design
- [docs/modules/network-isolation.md](docs/modules/network-isolation.md) – Network Isolation module documentation
- [docs/modules/network-isolation.de.md](docs/modules/network-isolation.de.md) – German Network Isolation module documentation
- [docs/poc/a1-boot-menu.md](docs/poc/a1-boot-menu.md) – A1 boot menu proof of concept
- [docs/poc/a2-current-boot-profile.md](docs/poc/a2-current-boot-profile.md) – A2 current boot profile detection
- [docs/poc/a3-startup-hook.md](docs/poc/a3-startup-hook.md) – A3 startup hook proof of concept
- [docs/poc/a4-profile-startup-scripts.md](docs/poc/a4-profile-startup-scripts.md) – A4 profile startup script execution
- [docs/poc/a5-findings.md](docs/poc/a5-findings.md) – A5 proof-of-concept findings
- [docs/release/v1.0.0-release-scope.md](docs/release/v1.0.0-release-scope.md) – initial stable release scope
- [docs/decisions/ADR-0001-overall-architecture.md](docs/decisions/ADR-0001-overall-architecture.md) – initial architecture decision record
- [docs/decisions/ADR-0002-boot-profile-detection.md](docs/decisions/ADR-0002-boot-profile-detection.md) – boot profile detection strategy
- [docs/decisions/ADR-0003-boot-profile-resolver-boundary.md](docs/decisions/ADR-0003-boot-profile-resolver-boundary.md) – boot profile resolver boundary
- [docs/decisions/ADR-0004-network-isolation-lifecycle-module.md](docs/decisions/ADR-0004-network-isolation-lifecycle-module.md) – Network Isolation lifecycle module decision
- [docs/decisions/ADR-0005-configuration-format-v2.md](docs/decisions/ADR-0005-configuration-format-v2.md) – Configuration Format v2 decision
- [docs/decisions/ADR-0006-configuration-driven-boot-menu.md](docs/decisions/ADR-0006-configuration-driven-boot-menu.md) – configuration-driven boot menu installation decision
- [docs/decisions/ADR-0007-service-and-startup-control-modularization.md](docs/decisions/ADR-0007-service-and-startup-control-modularization.md) – Service and Startup Control modularization decision
- [docs/decisions/ADR-0008-startup-and-user-application-control.md](docs/decisions/ADR-0008-startup-and-user-application-control.md) – Startup and User-Application Control decision
- [LICENSE](LICENSE) – MIT License

### Current profile resolver

After installing the boot menu and booting through a managed profile such as `Network Isolation`, `Experiment Local` or `Maintenance`, run:

```cmd
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\scripts\Resolve-BootProfile.ps1
```

Alternatively, from an elevated PowerShell session, run:

```powershell
.\scripts\Resolve-BootProfile.ps1
```

For machine-readable output:

```powershell
.\scripts\Resolve-BootProfile.ps1 -AsJson
```

## License

This project is licensed under the MIT License.
