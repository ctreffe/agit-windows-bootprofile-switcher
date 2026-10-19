# External File and Source Catalog

Record unchanged external development files and sources, including services,
URLs and sources outside the repository. Put only Git-safe metadata here; use
ignored `CATALOG.local.md` and `PATHS.local.md` for sensitive details and
device-specific resolutions.

| ID | Description | Kind | Content location | Assistant access | Git content | External sharing | Source version or retrieval state | Integrity | Last verified | Notes |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| `<source-id>` | `<safe description>` | `<file | dataset | service | URL | other>` | `<intake | restricted | local | versioned | stable URL or logical external location>` | `<not approved | approved scope>` | `<no | yes | not applicable>` | `<not approved | approved scope>` | `<version, timestamp or mutability note>` | `<checksum, validation or not applicable>` | `<date>` | `<provenance or engineering notes>` |

Use stable public URLs directly and logical locations for private or
device-specific sources. Resolve logical locations in `PATHS.local.md`, copied
from the example. Never record credentials or private tokens. A catalog entry
grants no additional permission.
