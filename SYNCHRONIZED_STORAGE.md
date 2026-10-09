# Synchronized External Project Storage

Use synchronized external project storage when large or non-versioned project
files must be available on several devices. A cloud, NAS or peer-sync desktop
client may provide the local directory, but the repository convention remains
provider-neutral.

This is a form of the existing `external` storage state. Synchronization is not
Git history, backup, assistant access or publication approval.

## Default Structure

Use one stable project ID and this external structure:

```text
<synchronized-root>/
└── <project-id>/
    ├── PROJECT_ID.txt
    ├── input/
    │   ├── intake/
    │   ├── restricted/
    │   └── local/
    └── materials/
```

`PROJECT_ID.txt` contains only the stable project ID and optional format
version. Do not include credentials, share tokens or sensitive metadata.
Projects may add an external `output/` subtree for deliberately synchronized
large results. Do not synchronize `temp/`; temporary content remains
uncataloged, disposable and device-local.

## Input and Material Rules

The external input subtrees keep the repository meanings:

- `intake/` is unclassified and must not be enumerated or read by assistants;
- `restricted/` remains unavailable to assistants;
- `local/` contains unchanged input approved for scoped assistant access but
  not Git versioning.

Synchronization does not grant access. Do not enumerate the synchronization
root or unrelated project folders. Use only exact paths allowed by the current
project catalog, mapping and access rules.

Files below the external `materials/` subtree are cataloged with storage
`external`, not `local`, because they remain outside the repository. Every
registered material is assistant-readable. Restricted or unclassified content
therefore cannot be registered as a material.

## Portable Mapping

Use stable provider-neutral logical roots in versioned catalogs:

```text
sync:<project-id>/input
sync:<project-id>/materials
```

Record the logical root plus the relative file path. Copy the path examples to
ignored `input/PATHS.local.md` and `materials/PATHS.local.md` on every device
and map those roots to the absolute local directories. Provider names, absolute
paths and private endpoints remain in ignored local files.

Before using a file, verify `PROJECT_ID.txt`, confirm that the file is fully
available locally rather than an on-demand placeholder, and check sync status.
Use checksums or equivalent integrity evidence for immutable input when
proportionate. Avoid concurrent binary edits unless the provider has a reviewed
conflict workflow.

Provider transmission, assistant access, Git versioning, backup and publication
or other sharing are separate maintainer decisions. Provider version history
may help recovery but does not replace an approved backup.

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

## Optional explicit workflow

Use `$manage-external-storage` only when explicitly selected to set up storage,
connect a host or check exact project files. Ordinary task entry, initialization
and handoff do not invoke it or require synchronization metadata.

Resolve the project's permitted Markdown mappings first, then pass the exact
external project directory, expected ID and approved relative files to
[scripts/Test-ExternalStorage.ps1](scripts/Test-ExternalStorage.ps1):

```powershell
./scripts/Test-ExternalStorage.ps1 -ProjectPath '<absolute-project-directory>' `
    -ProjectId 'project-a' -RelativeFile 'input/local/source.pdf', 'materials/image.png'
```

For this helper, put the safe project ID on the marker's first line and any
optional format version on a separate line. IDs use 1-64 letters, digits,
underscores or hyphens. Review incompatible existing markers manually; do not
automatically migrate or overwrite them. The helper checks a marker at most
256 bytes long and ordinary local file metadata, without directory discovery.

An optional `-ExpectedSha256` hashtable maps exact selected relative files to
approved expected hashes. Hashing reads content and requires its access scope.
By default only the safe marker and file metadata are read. The helper refuses
intake/restricted/temp selections, traversal, UNC/device paths and reparse
points, including some cloud-backed paths. Offline/recall flags return
`placeholder`; unsupported paths need an operator check, not automatic hydration.
It prints fixed statuses and selection indices, never paths or hashes.

`local_file` is metadata evidence, not a provider-independent hydration guarantee.
`SyncStatus` remains `not_checked`; report checked sync only with separately
reviewed provider evidence. Local availability or a hash alone proves no remote
convergence, backup or conflict freedom. Avoid concurrent path replacement or
binary edits; this helper is not filesystem isolation or a cloud adapter.

Folder creation and file moves inside a sync root need their own outside-write
and transmission authority. Record durable storage decisions in existing
project context or local Decision Records only when needed and authorized.
Include storage details in a handoff only for a concrete continuation dependency.
