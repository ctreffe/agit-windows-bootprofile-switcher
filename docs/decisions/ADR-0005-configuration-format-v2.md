# ADR-0005: Configuration Format v2

## Status

Accepted

## Context

BootProfile Switcher started with a simple profile configuration format that
was sufficient for proof-of-concept validation and the first production-oriented
modules.

The next milestones need a clearer configuration contract because boot menu
installation, profile dispatch, module settings and future managed deployment
must all depend on the same declarative source.

The format must also model the Windows default boot entry carefully. The
default entry is not a managed BootProfile Switcher profile, but installation
may still need to rename or hide it in the Windows Boot Manager.

During design, global module defaults were considered. The expected deployment
shape is usually a small number of managed boot profiles per machine. In that
case, copying explicit module settings per profile is easier to understand than
introducing inheritance before there is a proven need for it.

## Decision

BootProfile Switcher will introduce `schemaVersion = 2` as the forward-looking
configuration format.

The v2 format separates global boot menu behavior from managed profiles:

- `bootMenu` describes Windows Boot Manager behavior and constrained handling
  of the default Windows boot entry.
- `profiles` contains only managed BootProfile Switcher profiles.

The Windows default boot entry is represented only under
`bootMenu.defaultEntry`. It is not represented as a profile. The default entry
supports only constrained global settings:

- `rename`
- `displayName`
- `hide`

Managed profiles use stable lowercase profile IDs and explicit display names.
Each managed profile contains its own module settings under a profile-local
`modules` object.

The v2 format intentionally does not include global module defaults. Module
settings are explicit per profile until a real deployment need justifies a
shared defaults or inheritance model.

The validator must reject ambiguous or legacy shapes, including:

- unsupported top-level properties
- v1-only profile fields such as `mode` or `moduleSettings`
- invalid profile identifiers
- duplicate profile identifiers
- duplicate display names
- empty `modules` objects
- unknown module names
- non-string script entries
- default-entry display names when `rename` is `false`

The v1 configuration format remains supported during the transition.

## Rationale

Separating the default Windows boot entry from managed profiles keeps the model
honest. The default entry can be renamed or hidden in the boot menu, but it does
not participate in profile module dispatch.

Profile-local module settings keep the configuration readable for the expected
small number of profiles. They also avoid implicit behavior that could be easy
to miss during Group Policy based deployment review.

Rejecting legacy and ambiguous shapes makes migration safer. A configuration
file should either be clearly v1 or clearly v2, not a mixture of both.

Keeping v1 validation available reduces migration risk while v2 becomes the
source format for later boot menu installation work.

## Consequences

Future boot menu installation work should use the v2 configuration as its
source of truth.

The profile engine and modules must continue to support the existing runtime
path while v2 is adopted incrementally.

If later deployments require shared module settings across many profiles, a
future ADR should define an explicit inheritance or defaults model instead of
silently extending v2 behavior.

Documentation and fixtures must stay aligned with the validator so the
configuration format remains understandable and testable.
