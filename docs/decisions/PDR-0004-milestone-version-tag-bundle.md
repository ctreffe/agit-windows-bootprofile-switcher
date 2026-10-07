# PDR-0004: Milestone Version Tag Bundle

Status: Accepted
Date: 2026-10-07

## Context

The maintainer selected the new commit-milestone template update after the
detailed synchronization. [PDR-0002](PDR-0002-bounded-commit-and-push-authority.md) excluded tags from the
bounded commit workflows; that milestone-specific exclusion is now amended.

## Decision

Adopt commit-milestone from `ai-template-dev` at
`fa63ed044c980c5d4972978cd869612a7cdf459b` together with its directly related authority and guides.
Explicit repository-specific milestone commit authority includes the reviewed
commit, one matching annotated version tag, normal branch push and exact tag
push to the verified existing upstream unless excluded. Skill invocation alone
grants no Git authority. The tag identifies this project's reviewed version,
never the inherited template's version.

Commit only excludes tags and pushes; no push retains a local commit/tag;
no tag excludes creation/push; no tag push retains a local tag and permits the
included branch push. Ordinary commit-changes continues to include only normal
branch push. Other refs/actions, tag movement/replacement, force-push, remote
changes and release publication retain separate authority. Previous permissions
are not retroactively expanded; historical tag backfill requires exact explicit
repository/version/commit authority.

This partially supersedes PDR-0002 only for commit-milestone's tag exclusion.
Its ordinary-commit rule and all domain, access, privacy, license, host and
publication safeguards remain binding. This synchronization authorizes no
staging, commit, tag, push or operational execution.

## Rationale

The selected workflow closes a reviewed milestone with its discoverable version
marker. Updating the skill and related rules together avoids conflicting routes.

## Consequences

- Inspect version metadata, established tag naming, both tag objects/peeled
  commits and the verified upstream. Refuse a conflicting tag; never move it.
- Prefer atomic exact branch/tag refspecs with tag following disabled; otherwise
  report separate branch/tag outcomes. Never push all tags or unrelated refs.
- A rejected push authorizes no pull, merge, rebase or force-push. Backfill marks
  an accepted historical target, not an arbitrary newer HEAD.
- Keep comprehensive milestone/domain checks, signing and narrow platform
  execution approval. No release is implied by a version tag.

## Alternatives considered

The former separate-tag step is replaced only in the selected milestone route.
Blanket Git permission, tag replacement and automatic releases are excluded.

## Follow-up

Validate the changed skill and rule/language/link consistency. Verify actual Git
results only during a later authorized closure; instruction review is not Git
execution. See [TEMPLATE_SYNC.md](../../TEMPLATE_SYNC.md) for exact selection and evidence.
