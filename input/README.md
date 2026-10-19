# External Files and Sources

This is a generic catalog/storage convention for future explicitly selected inputs.
It selects no host-specific files and does not broaden local access rules.

For approved external originals in the simple synchronized input root,
follow [SYNCHRONIZED_STORAGE.md](../SYNCHRONIZED_STORAGE.md). Mapping a root
does not authorize its contents or unrelated synchronized folders.

Use `input/` for externally supplied development files such as logs, dumps,
API responses, screenshots, exports and reproduction material. New or uncertain
files start in `intake/`; already classified files may go directly to
`restricted/`, `local/` or `versioned/`.

Keep their content unchanged. Any sanitization, conversion, extraction or other
content change creates a new file governed through `materials/`.

- `intake/` contains files not yet classified;
- `restricted/` contains ignored files unavailable to assistants;
- `local/` contains ignored files approved for assistant access;
- `versioned/` contains files deliberately approved for Git and assistant
  access.

Use `CATALOG.md` for safe metadata about files and unchanged external services,
datasets or URLs. Use ignored `CATALOG.local.md` when filenames, paths or
details are sensitive, and `PATHS.local.md` for device-specific resolution of
logical external locations.
Assistant access, Git versioning and external sharing remain separate
maintainer decisions.

Some runtime files must remain at tool-defined paths, such as a root `.env` or
a local database. Document those exceptions in the catalog and protect them
with path-specific ignore rules instead of moving them merely for uniformity.
Files promoted into source, tests or configuration retain their recorded
provenance.
