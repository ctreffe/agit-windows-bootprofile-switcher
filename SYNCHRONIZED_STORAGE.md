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
