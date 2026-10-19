---
name: manage-external-storage
description: Set up optional external project storage, connect a host or check selected local files. Use only when explicitly invoked; ordinary tasks and handoffs do not activate it.
---

# Manage External Storage

Run after explicit invocation or deliberate maintainer selection for setup,
host connection or a targeted storage problem. Routine work using an existing
approved mapping does not invoke this skill. Read the relevant sections of
[SYNCHRONIZED_STORAGE.md](../../../SYNCHRONIZED_STORAGE.md), not an unrelated
project inventory.

## Scope and authority

Use the known current project or an exact maintainer-supplied project path.
Apply its closest rules and DATA_PRIVACY.md or SECURITY.md/EXECUTION_SAFETY.md
where required. Read only permitted catalog entries and exact ignored mappings.
Never inspect restricted data, intake, credentials, private worker state or
protected projects to decide whether they are safe. Do not enumerate the sync
root, other projects or whole sensitive catalogs. A mapping grants no access,
destination-write, transmission, Git or publication authority; reuse existing
authority and ask only for what the concrete action lacks.

## Setup or connect

Reuse supplied identity, project ID, mappings and approved scope. Ask only for
missing decisions; a known mapping needs no new setup questionnaire. Prepare
the simple input/materials/optional-output layout and proposed local mappings.
The external area is for approved agent-readable, unversioned files; keep
repository-only classifications in the repository. Preserve existing markers
and legacy mappings; resolve identity conflicts before any dependent operation.

Obtain missing outside-write/provider authority before creating folders or
moving files. Use one stable catalog ID and actual location per artifact.
Keep originals unchanged; transformations become separately cataloged materials.
Do not synchronize temp or copy an entire repository hierarchy. Never migrate
existing files implicitly. Keep absolute paths/provider details in ignored
PATHS.local.md files. Connecting another host normally changes only those
mappings; record durable choices in existing context/decisions, not a second
storage catalog. New research defaults follow the material guide.

## Check a concrete dependency

Resolve only required IDs and exact paths. Reuse still-current checks within
the task; refresh after mapping, host, availability or conflict changes. Use
[Test-ExternalStorage.ps1](../../../scripts/Test-ExternalStorage.ps1) with the
exact project directory, expected ID and approved relative files; an empty
selection checks the marker. Optional hashes require content-access approval.
For creation, missing new files are expected: separately verify the approved
parent/write scope rather than treating missing as failed existing-file use.

On mismatch, unavailable/placeholder or unsupported linked paths, stop dependent
use; do not hydrate, scan, overwrite or invoke provider APIs. New research may
use its documented local fallback and must catalog its actual location; required
existing evidence cannot be replaced by an invented report. Distinguish local
availability/integrity from cloud convergence: report SyncStatus as unchecked
unless independently verified provider evidence exists. Keep output to fixed
statuses and safe metadata, not raw paths, private contents or hashes.

Report the resolved operation, actual checks and remaining limits. Handoff only
storage dependencies relevant to continuation. No background synchronization,
automatic task-entry check, installation, credential use or publication follows
from this skill. Where a control-word authorization is missing, propose a
minimum copy-ready instruction for the exact destination/action and consequence;
the suggestion is not authorization.

## Project boundary

Keep device-bound logs, backups and runtime state on their documented host.
Apply CODEX.md before private transmission or host operations. This read-only
workflow does not execute boot, account, service, registry or rollback scripts
and supplies no elevation or real-system test authority.
