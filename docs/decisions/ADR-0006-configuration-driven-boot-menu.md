# ADR-0006: Configuration-Driven Boot Menu Installation

## Status

Accepted

## Context

Early BootProfile Switcher milestones created fixed Mode A and Mode B boot
entries. That was useful for proof-of-concept validation, but it does not fit
the long-term configuration model.

Configuration Format v2 defines managed profiles, profile-local module
settings and constrained default Windows boot entry behavior. The boot menu
installer now needs to use that format as its source of truth.

The installer must also remain suitable for enterprise deployment. Group Policy
or other management tooling may need to run installation without interactive
prompts, but local maintainer workflows still benefit from interactive safety
when existing managed entries are found.

The Windows default boot entry is the normal recovery and return path. Renaming
or hiding it must be handled conservatively and must be reversible during
uninstall.

## Decision

BootProfile Switcher will make boot menu installation configuration-driven from
Configuration Format v2.

The installer reads `%ProgramData%\BootProfileSwitcher\config\profiles.json` by
default and accepts `-ConfigPath` as an override for demos, tests and migration
workflows.

Only v2 profiles with `bootMenu.enabled = true` are installed as managed boot
entries. Their boot menu display names come from `displayName`.

Existing BootProfile Switcher entries must not be duplicated. The installer
keeps an interactive cleanup path for local use and adds explicit automation
switches for managed deployment:

- `-CleanupExisting` removes existing managed entries before installation.
- `-Force` suppresses interactive prompts and requires explicit cleanup when
  existing managed state is present.

The installer may apply constrained default-entry behavior from
`bootMenu.defaultEntry`:

- `rename = true` sets the default entry description to `displayName`.
- `hide = true` removes the default entry from the Boot Manager display order.

Before changing the default entry, the installer stores baseline state in
`state/boot-menu.json` so uninstall can restore the original description and
return the default entry to the display order.

## Rationale

Using v2 as the installer source of truth removes the old fixed Mode A and Mode
B assumption and makes boot menu creation align with the same configuration
model used by later module work.

ProgramData is the right default because it is machine-wide and suitable for
Group Policy based deployment. `-ConfigPath` keeps development, demo and test
workflows flexible without changing production defaults.

Explicit cleanup and force switches make automation intentional. They avoid
silently deleting BCD entries during local interactive use while still allowing
non-interactive managed installation.

Treating the default Windows boot entry separately preserves the v2 design: the
default entry can be renamed or hidden in the boot menu, but it is not a managed
profile and does not receive profile modules or custom scripts.

## Consequences

Boot menu installation now depends on a valid v2 configuration file.

The managed boot menu state file must record enough metadata for resolver
mapping, diagnostics and uninstall restore behavior.

The resolver and runtime path must remain compatible with state generated from
v2 profile identifiers instead of the old fixed Mode A and Mode B entries.

Default-entry hiding is a boot menu presentation change, not deletion of the
default Windows boot entry. Uninstall must restore the default entry to the
display order.

Future changes that expand default-entry behavior beyond rename or hide should
be treated as a new architecture decision.
