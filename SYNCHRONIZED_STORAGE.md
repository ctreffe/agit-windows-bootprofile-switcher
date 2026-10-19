# Synchronized external project storage

Existing project mappings, canonical selections and restoration rules below retain
their authority. The simple layout applies to new approved areas only.

The provider's desktop client exposes an ordinary local directory. These rules
integrate that directory with repository catalogs; they do not manage accounts,
sync files or prove remote convergence. Use `manage-external-storage` deliberately
for setup, connecting a host or diagnosing selected files. Routine use of an
already approved mapping does not require that skill or repeat setup.

## Simple external layout

```text
<synchronized-root>/<project-id>/
    PROJECT_ID.txt
    input/                 # unchanged approved originals
    materials/             # retained created or transformed working files
        research/          # reports and generated research data
    output/                # only when deliberately selected
```

This new external project area contains only content already approved for the
agent and the provider. Do not mirror repository `local`, `versioned`, `intake`
or `restricted` classifications as new external subfolders. Unclassified,
restricted and credential content stays outside this area. The rule does not
reclassify existing files or authorize access to a whole cloud account.
Existing `input/local/` mappings remain supported for exact approved files;
legacy intake/restricted areas remain closed. No automatic move or migration.
Optional subject/document folders may organize content without changing its role.

Put a stable non-sensitive ID of 1–64 letters, digits, underscores or hyphens
on the first line of `PROJECT_ID.txt`; an optional format version follows.
Preserve existing markers. An identity mismatch requires resolution before use.

## One catalog identity, different physical locations

| Artifact | Repository location when local | External location | Catalog owner |
| --- | --- | --- | --- |
| Unchanged approved original | `input/local/` | `sync:<project-id>/input/<file>` | `input/CATALOG.md` |
| Created/transformed retained material | `materials/local/` | `sync:<project-id>/materials/<file>` | `materials/CATALOG.md` |
| Research report or generated dataset | `materials/local/research/` | `sync:<project-id>/materials/research/<file>` | Separate IDs in `materials/CATALOG.md` |
| Deliberately synchronized deliverable | Domain-specific `output/` | Optional external `output/` | Existing deliverable record |

External catalogs use storage `external`, not `local` or `versioned`. Record one
actual location per retained artifact and keep its stable ID when an authorized
move changes location. Link transformations to the original input ID in `Based on`;
never modify an input in place or keep silently competing copies. Document
assignments use IDs; they do not duplicate source files. Repository source,
configuration, approved versioned assets and domain-specific maintained data
remain in their established repository locations. Do not synchronize `temp/`; it stays disposable and device-local. Cloud synchronization is not Git history, backup or publication.

Versioned catalogs contain only safe logical references. Ignored
`input/PATHS.local.md` and `materials/PATHS.local.md` map logical roots to this
host's exact directories, copied from their tracked examples when needed.
Never version concrete device paths, provider secrets or private share tokens.
Keep sensitive metadata in approved ignored storage. Record selected scope,
provider/write authority, conflict handling and backup responsibility in existing
project context or an appropriate decision; do not create a second catalog.

## Setup once; check only what the next operation needs

For setup, reuse supplied project identity and existing decisions; ask only for
missing project directory, permitted scope or a consequential conflict. Prepare
the proposed mapping/layout first. Create folders or transfer files only with
the exact required outside-write and provider authority. Do not copy existing
repository folders wholesale. Connecting another host normally changes only
its ignored mappings and verifies the existing project marker.

For routine reads/writes, use known catalog IDs and exact mapped paths. Reuse
unchanged checks during the task; recheck after a device/path/classification
change, conflicting identity, unavailable file or evidence of concurrent edits.
Do not scan the sync root, unrelated projects or sensitive catalogs.
Research uses [the material storage rule](materials/README.md#research-storage-and-reuse).

## Targeted local helper

```powershell
./scripts/Test-ExternalStorage.ps1 -ProjectPath '<absolute-project-directory>' `
    -ProjectId 'project-a' -RelativeFile 'input/source.pdf', 'materials/research/report.md'
```

An empty selection checks only the marker. For a new material, verify the known
project/parent within approved scope; the new file is expected to be missing.
The helper checks existing file availability, not destination write permission.
It reads only the safe marker and selected metadata by default. Optional
`-ExpectedSha256` values must cover selected approved files; hashing reads content.
Intake/restricted/temp paths, traversal, UNC/device paths and linked destinations
are refused. Offline/recall flags return `placeholder`, not automatic hydration.
Unsupported provider paths need an operator check; there is no provider API fallback.

Outputs contain fixed statuses and selection indices, not paths, file contents
or hashes. `local_file` is local metadata evidence, not proof of remote sync or
conflict freedom. `SyncStatus` is `not_checked`; only separate reviewed provider
evidence supports a stronger statement. Avoid concurrent binary edits and path
replacement. Keep conflict handling and backup explicit; no automatic overwrite.
Only a concrete continuation dependency belongs in TASK_HANDOFF.md; general
task entry and initialization do not acquire mandatory storage checks.

## Repository boundary

Maintained source, configuration, tests and approved versioned assets stay in
the repository. External storage does not replace its authoritative project state.

## Development Adaptation

Do not use the synchronized root as a substitute for maintained source, tests,
fixtures, configuration or reviewed release assets. Tool-defined runtime files
such as `.env`, databases and logs keep their documented paths and ignore
rules. Build output remains generated output unless a retained file has a clear
cataloged material role.

## BootProfile boundary

This optional model excludes device-bound logs, backups and runtime state.
No source transfer or synchronization setting is selected. Existing Windows
host-operation and rollback gates remain independently applicable.
