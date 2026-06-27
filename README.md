# BootProfile Switcher

![License](https://img.shields.io/github/license/ctreffe/agit-windows-bootprofile-switcher)
![Release](https://img.shields.io/github/v/tag/ctreffe/agit-windows-bootprofile-switcher)
![Last Commit](https://img.shields.io/github/last-commit/ctreffe/agit-windows-bootprofile-switcher)

[Deutsche Dokumentation](README.de.md)

> [!NOTE]
> **Project Status**
>
> BootProfile Switcher is in early project foundation stage.
>
> The repository currently defines the project scope, engineering principles and documentation baseline. Implementation work has not started yet.

## Overview

BootProfile Switcher is a configurable Windows boot profile engine that applies modular system profiles before user logon.

The project is intended to support Windows systems that need multiple operating profiles from a single Windows installation. A user selects a boot profile during system startup. BootProfile Switcher then applies the corresponding system configuration before interactive logon begins.

The initial use case is a Windows computer that can start either in normal operation or in an experimental profile with restricted or disabled network connectivity. The architecture is intentionally generic so that additional profiles and components can be added later.

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

The initial project milestone is:

```text
0.1.0 Foundation
```

Version tags should use a leading `v`, for example:

```text
v0.1.0
```

## Documentation

Core project documents:

- [README.md](README.md) – primary English project documentation
- [README.de.md](README.de.md) – German project documentation
- [CHANGELOG.md](CHANGELOG.md) – version history
- [ChatGPT.md](ChatGPT.md) – AGIT Collaboration Model
- [PHILOSOPHY.md](PHILOSOPHY.md) – project philosophy
- [LICENSE](LICENSE) – MIT License

## License

This project is licensed under the MIT License.
