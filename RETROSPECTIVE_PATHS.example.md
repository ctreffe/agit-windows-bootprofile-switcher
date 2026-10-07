# Local Retrospective Repository Paths

Copy this file to `RETROSPECTIVE_PATHS.local.md` on each computer. The local
file is ignored by Git and may contain machine-specific paths. Do not commit it
or copy its concrete values into handoffs, changelogs or retrospective evidence.

Use paths relative to the current repository when practical. Absolute paths are
allowed only in the ignored local file. `Unset` is valid until a retrospective
needs that destination.

## Repository Mappings

| Role | Expected repository | Local clone path |
| --- | --- | --- |
| Templateverse Governance | `AI Templateverse` | `Unset` |
| Verified source template | `AI Dev Template` | `Unset` |

Before using a mapping, canonicalize the path and verify tracked repository
identity. For a derived project's source template, also confirm that its
recorded source-template baseline exists in that clone. Do not search drives or
guess from a directory name when a value is missing or stale.

A mapping is navigation metadata only. It grants no access, retrospective-
evidence eligibility, destination write, Git action, versioning, transmission
or publication authority.
