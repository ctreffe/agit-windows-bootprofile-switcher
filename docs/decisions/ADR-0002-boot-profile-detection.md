# ADR-0002: Boot Profile Detection Strategy

## Status

Accepted

## Context

BootProfile Switcher needs to determine which Windows Boot Manager entry was
selected during startup.

The proof of concept created two managed boot entries, Mode A and Mode B, and
stored their BCD identifiers in `state/boot-menu.json`.

Early A2 work used the BCD entry description as the detection bridge because
`bcdedit /enum "{current}"` reports the identifier as the `{current}` alias.
Follow-up validation showed that verbose output exposes the real current BCD
object identifier:

```text
bcdedit /enum "{current}" /v
```

This makes direct GUID-based detection possible.

## Decision

BootProfile Switcher will use the real BCD object identifier of the current boot
entry as the primary boot profile identity.

The resolver reads the current boot entry with verbose `bcdedit` output,
extracts the current BCD identifier and maps it to the managed identifiers stored
in `state/boot-menu.json`.

Description-based matching remains available as a fallback and diagnostic aid.
It is not the primary identity mechanism.

## Rationale

The BCD identifier is a stronger identity than the entry description.

Descriptions are useful for diagnostics and user-facing display, but they are
not the best long-term identity because they are human-readable labels. The BCD
identifier is the managed object identity created during installation and stored
in project-owned runtime state.

Using verbose `bcdedit` output avoids the `{current}` alias limitation while
still relying on Windows-supported tooling.

Keeping the description fallback preserves diagnosability and makes the resolver
more tolerant during proof-of-concept and troubleshooting work.

## Consequences

The current resolver depends on `bcdedit /enum "{current}" /v` being available
and readable during startup.

Managed boot profile entries must continue to be recorded in
`state/boot-menu.json`.

Future production work should evaluate whether the same strategy is appropriate
for the final startup execution context and managed deployment environments.

The resolver remains separate from profile application. It identifies the
selected profile but does not apply system configuration directly.
