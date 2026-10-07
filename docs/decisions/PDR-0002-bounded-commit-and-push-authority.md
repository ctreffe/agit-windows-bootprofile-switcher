# PDR-0002: Bounded Commit and Push Authority

Status: Accepted
Date: 2026-10-07

## Context

The selected template synchronization excluded the current commit skills and
normal-push authority rule. The maintainer selected correction of this omission
after reviewing its effect across the derived projects.

## Decision

Adopt `commit-changes` and `commit-milestone` from `ai-template-dev` at
`6a2cc69831c99dd68d00fba9063bd404ab0b9df7`. Within either workflow, an explicit repository-specific
commit instruction includes the normal push to the verified existing upstream
unless the maintainer excludes push. Skill invocation alone supplies no Git
authority. This replaces the former separate-push rule only in these workflows.

Force-push, additional refs, remote changes, tags, releases, pulls, merges,
rebases and other protected actions retain separate exact authorization.
Preserve every existing project decision, domain safeguard, host-operation gate,
access boundary, privacy and license rule. Git push grants no separate release
or content publication permission. Platform execution approval remains separate.

## Rationale

An explicitly authorized commit can close the same reviewed selection through
its verified upstream without a second ordinary-push prompt. The maintainer can
still request commit only. Consistent skills and guidance avoid contradictory
instructions during later task closure.

## Consequences

- Keep resident rules, collaboration guidance, available repository contracts,
  both workflow-guide languages and the two skills aligned.
- Push only the authorized branch selection with a normal refspec and no
  following tags. No other repository, future commit or protected action is
  included.
- If push is rejected, preserve the commit and diagnose; never silently pull,
  merge, rebase or force-push.
- Preserve historical decisions and source baselines. Document retained local
  adaptations accurately in [TEMPLATE_SYNC.md](../../TEMPLATE_SYNC.md).

## Alternatives considered

Retaining separate commit and push prompts was the earlier selection. The
maintainer now selected the current bounded rule. Blanket Git permission and
replacement of domain policy were not selected.

## Follow-up

Validate the adopted skills and rule consistency. During any later authorized
commit, verify the exact selection, current repository and existing upstream.
This content correction itself authorizes no staging, commit or push.
