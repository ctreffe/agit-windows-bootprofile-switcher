---
name: manage-external-storage
description: Set up optional external project storage, connect a host or check selected local files. Use only when explicitly invoked; ordinary tasks and handoffs do not activate it.
---

# Manage External Storage

Run only after an explicit `$manage-external-storage` invocation or deliberate
maintainer selection. Use the current project when its identity and scope are
known; otherwise establish an exact authorized project path. Select either
setup/host connection or a targeted check. Read the
[opt-in guide](../../../SYNCHRONIZED_STORAGE.md) for the convention and helper.

## Establish scope

Use an exact maintainer-supplied project path, not repository discovery. Apply
its closest AGENTS.md and storage guidance; read DATA_PRIVACY.md or SECURITY.md
and EXECUTION_SAFETY.md first where required. Establish allowed metadata,
file classifications and intended action. Governance does not override local
authority. Never inspect intake, restricted content, private worker state or
protected projects to determine whether they are safe.

Read only safe catalog entries and the exact permitted local mappings. Keep
absolute paths and provider details in ignored host files. Do not enumerate
the sync root, other projects or entire catalogs containing sensitive metadata.
Invocation grants no access, destination writes, installation, transmission,
Git or publication authority. Ask only for authority missing for a concrete
next action; continue independent permitted work. If the project's rules need
a control word, propose one minimum copy-ready destination/action instruction.

## Setup or connect a host

Reuse existing decisions and mappings. Establish the stable non-sensitive
project ID, selected input/material scope, optional output, conflict handling
and backup responsibility only as needed. Resolve logical roots to this host's
exact directories. Preserve existing mappings and markers; do not overwrite
or invent an identity when the marker conflicts.

Prepare local mapping changes and the exact proposed directory layout. Obtain
any missing outside-write and provider-transmission authority before creating
folders or moving files inside a synchronized directory. Keep input unchanged;
use external materials for retained approved working files and never sync temp.
Record a durable storage decision in existing project context or a local
Decision Record only when authorized. A read-only check needs no new setup.

## Targeted check

Confirm input/material mappings resolve to the intended project directory.
Choose only exact approved files needed for this request; an empty selection
checks the marker only. For ordinary supported local paths, use
[scripts/Test-ExternalStorage.ps1](../../../scripts/Test-ExternalStorage.ps1)
with that absolute project directory, expected ID and relative files. Optional
expected SHA-256 values must be approved and match selected files; hashing is
content access. The helper outputs fixed statuses and selection indices only.

On identity mismatch, unavailable/placeholder paths or unsupported reparse
points, stop dependent file use. Report the specific fixed status and request
an operator check if needed; do not automatically hydrate, scan, copy or fall
back to a provider API. The helper checks local metadata and optional integrity,
not cloud convergence. Report sync as checked only from separately reviewed
provider evidence; otherwise distinguish unchecked from technically unverifiable.

Report the selected result, actual checks, limitations and any concrete next
step. Handoff storage details only when the current continuation depends on
them. Do not add checks or required sync fields to start-task, start-project,
general handoffs or background workflows.

## Domain boundary

Keep maintained source, tests, fixtures, configuration, release assets and
tool-defined runtime files in their authoritative locations. This workflow
does not relocate secrets, databases, logs or build output.

## Project boundary

Keep device-bound logs, backups and runtime state on their documented host.
Apply CODEX.md before private transmission or host operations. This read-only
workflow does not execute boot, account, service, registry or rollback scripts
and supplies no elevation or real-system test authority.
