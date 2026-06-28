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
> BootProfile Switcher has completed the Architecture milestone (`v0.2.0`), the Boot Profile Detection Proof of Concept (`v0.3.0`), the Boot Profile Detection milestone (`v0.4.0`), the Profile Engine milestone (`v0.5.0`) and the Module System milestone (`v0.6.0`).
>
> The `v0.6.0 – Module System` milestone has been completed. The profile engine now invokes a harmless validation module through an internal module registry, while configuration files and real system-changing actions remain intentionally postponed.

## Overview

BootProfile Switcher is a configurable Windows boot profile engine that applies modular system profiles before user logon.

The project is intended to support Windows systems that need multiple operating profiles from a single Windows installation. A user selects a boot profile during system startup. BootProfile Switcher then applies the corresponding system configuration before interactive logon begins.

The initial use case is a Windows computer that can start either in normal operation or in an experimental profile with restricted or disabled network connectivity. The architecture is intentionally generic so that additional profiles and components can be added later.

## Quick Start: A1 Boot Menu PoC

For the current proof of concept, the easiest way to install or remove the temporary boot menu entries is to use the command wrappers from the repository root:

```text
install.cmd
uninstall.cmd
```

Both wrappers can be started by double-clicking them in Windows Explorer. They request administrator privileges through UAC when required and then invoke the underlying PowerShell scripts with a process-local execution policy bypass.

The wrappers currently manage only the A1 proof-of-concept boot menu entries:

- `BootProfile Switcher - Mode A`
- `BootProfile Switcher - Mode B`

The underlying implementation remains in `scripts/` for explicit inspection and advanced manual testing.



## Quick Start: A3 Startup Hook PoC

After installing the A1 boot menu, the A3 startup hook can be installed from the
repository root:

```text
install-startup-hook.cmd
```

The startup hook registers a Windows Scheduled Task that runs at system startup,
resolves the selected boot profile through `scripts/Resolve-BootProfile.ps1`,
invokes `scripts/Invoke-ProfileEngine.ps1` and writes the startup result to:

```text
logs/startup-profile.log
```

and, starting with A4, executes the matching profile script:

```text
profiles/mode-a/startup.ps1
profiles/mode-b/startup.ps1
```

The profile scripts are intentionally harmless and write validation entries to:

```text
logs/profile-startup-actions.log
```

The hook can be removed with:

```text
uninstall-startup-hook.cmd
```

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

## Versioning

BootProfile Switcher follows Semantic Versioning.

The latest completed project milestone is:

```text
0.6.0 Module System
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
- [docs/poc/a1-boot-menu.md](docs/poc/a1-boot-menu.md) – A1 boot menu proof of concept
- [docs/poc/a2-current-boot-profile.md](docs/poc/a2-current-boot-profile.md) – A2 current boot profile detection
- [docs/poc/a3-startup-hook.md](docs/poc/a3-startup-hook.md) – A3 startup hook proof of concept
- [docs/poc/a4-profile-startup-scripts.md](docs/poc/a4-profile-startup-scripts.md) – A4 profile startup script execution
- [docs/poc/a5-findings.md](docs/poc/a5-findings.md) – A5 proof-of-concept findings
- [docs/decisions/ADR-0001-overall-architecture.md](docs/decisions/ADR-0001-overall-architecture.md) – initial architecture decision record
- [docs/decisions/ADR-0002-boot-profile-detection.md](docs/decisions/ADR-0002-boot-profile-detection.md) – boot profile detection strategy
- [docs/decisions/ADR-0003-boot-profile-resolver-boundary.md](docs/decisions/ADR-0003-boot-profile-resolver-boundary.md) – boot profile resolver boundary
- [LICENSE](LICENSE) – MIT License

## License

This project is licensed under the MIT License.

### Current profile resolver

After installing the boot menu and booting through Mode A or Mode B, run:

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
