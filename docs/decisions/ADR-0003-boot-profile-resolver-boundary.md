# ADR-0003: Boot Profile Resolver Boundary

## Status

Accepted

## Context

The `v0.3.0` proof of concept validated that BootProfile Switcher can detect the
selected Windows Boot Manager entry and dispatch profile-specific startup
scripts.

The next milestone starts turning the proof-of-concept detection path into a
cleaner production-oriented component. The component boundary must remain narrow
so later profile engine and module work can evolve independently.

## Decision

BootProfile Switcher will introduce a dedicated boot profile resolver.

The resolver is responsible only for identifying the selected managed boot
profile and writing that result as structured data.

The resolver must not:

- apply system configuration
- execute profile scripts
- modify BCD state
- call modules
- perform profile engine responsibilities

The resolver output is a JSON object written to a non-user-specific state path:

```text
state/current-boot-profile.json
```

The initial resolver script is:

```text
scripts/Resolve-BootProfile.ps1
```

The existing `scripts/Get-CurrentBootProfile.ps1` remains available as the
validated proof-of-concept detection script until the new resolver path has been
validated and adopted by the startup hook.

## Resolver Contract

The resolver writes a JSON object with the following stable fields:

- `schemaVersion`
- `generatedAt`
- `detected`
- `mode`
- `name`
- `identifier`
- `source`
- `description`
- `currentIdentifier`
- `outputPath`
- `stateFile`
- `error`

When Windows starts through the normal unmanaged boot entry, the resolver should
not fail. It should write `detected = false`, leave profile-specific fields
empty and exit successfully. Later engine or startup-hook logic can then decide
not to execute profile-specific actions.

## Rationale

Separating profile resolution from profile application keeps the architecture
modular.

The resolver provides a clear handoff point between boot selection and future
profile engine behavior. It can be tested independently from system
configuration modules and can evolve without hardcoding profile behavior into
startup scripts.

Writing structured state to a non-user-specific location makes the selected boot
profile available to system-level startup components without depending on an
interactive user session.

Keeping the proof-of-concept script temporarily reduces migration risk while the
new resolver path is validated.

## Consequences

The `v0.4.x` milestone should focus on validating and adopting the resolver
boundary.

The startup hook should continue to use the validated proof-of-concept path until
the resolver has been tested in the same Mode A and Mode B startup scenarios.

Future profile engine work should consume resolver output rather than re-running
boot detection logic directly.
