# DDR-0001: Project Introductions and Template Guides

Status: Accepted
Date: 2026-10-06

## Context

The existing project README pair introduces the project. Selected updates from
AI Dev Template also contain inherited operating guidance that needs a
separate home without overwriting the project introduction.

## Decision

The maintainer separately selected TEMPLATE_README.md and TEMPLATE_README.de.md
for this project. Keep README.md and README.de.md as introductions; link each
introduction to the matching guide and maintain reciprocal language links.
Guides reflect actual files and skills, omit inherited badges and executable
creation/initialization instructions, and defer to project rules and decisions.
Preserve attribution, licenses, existing content and historical provenance.
Map later selected source README changes to the guides via sync-template.

## Rationale

Contributors can find inherited workflows directly while project readers retain
the existing introduction. The mapping prevents upstream README overwrite.

## Consequences

Review both language pairs, inventory and navigation when selected guidance
changes. Source selection is recorded in [TEMPLATE_SYNC.md](../../TEMPLATE_SYNC.md). No project intent,
license, access, installation or protected Git authority changes.

## Alternatives considered

Keeping only the existing introductions would leave inherited guidance remote;
replacing them would lose project-specific documentation. Both are rejected
for this selected adoption.

## Follow-up

Validate both guides, their local links and their project adaptations before
recording this selected synchronization as complete.
