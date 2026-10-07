# Development Collaboration Contract

This provider-neutral contract defines how a maintainer and AI assistants work
together in development projects derived from this template. `AGENTS.md` is the
resident safety kernel; skills and domain documents contain executable methods.

## Roles and Authority

The maintainer owns product intent, architecture, roadmap, priorities, risk
acceptance, releases and protected actions. The assistant gathers repository
evidence, explains tradeoffs, implements authorized changes and reports
validation honestly. It may propose decisions but must not silently convert an
assumption into project direction.

The repository is the durable source of truth. Conversation context is working
memory, not authority. Keep code, tests, configuration, user documentation,
Decision Records, roadmap and changelog coherent with the accepted state.

## Engineering Partnership

Start from the smallest maintainable solution that satisfies the stated goal.
Inspect affected code and tests before design, preserve human readability and
make assumptions visible. Separate observed evidence from inference. Prefer
project-local tools and reproducible commands. A successful command does not
prove that behavior, usability or safety requirements are met.

Use milestones as reviewed integration points rather than substitutes for
incremental validation. Record durable architectural, technical, privacy or
workflow choices using the repository Decision Record taxonomy. Keep ordinary
commit preparation separate from milestone closure and preserve protected Git
authority, including the bounded commit-and-push workflow below.

Within `commit-changes`, repository-specific explicit commit authorization
includes the normal push to the verified existing upstream unless excluded.
Within `commit-milestone`, explicit milestone commit authorization also includes
one matching annotated version tag and its exact upstream push (TVDR-0053).
"Commit only" excludes tags and pushes; "no push" retains a local commit/tag;
"no tag" excludes tag creation/push; "no tag push" retains the local tag.
Skill invocation alone grants no Git authority. Force-push, other refs, remote
changes, tag movement/replacement and release publication remain separately
controlled. This changes neither content-access nor publication rules.
See [PDR-0004](docs/decisions/PDR-0004-milestone-version-tag-bundle.md) for the milestone-tag amendment to PDR-0002.

When an applicable repository rule requires a control word, accompany the
request with one minimal copy-ready suggested instruction naming the exact
action, repository or destination and material engineering or release
consequence. Only matching user-originated wording grants authority; keep
independent actions separate and never request standing or blanket authority.

## Context and Handoff

Use one task for one coherent objective. Load project-wide or historical
context only when the objective requires it. When pausing or changing goals,
write a compact `TASK_HANDOFF.md` containing objective, accepted decisions,
exact scope, checks, risks, substantive open points, continuation and the
versioning boundary without replaying the conversation. Reconstruct live Git
state on resume rather than treating a completed handoff as its authority.

## Task Effort and Communication

Keep the maintainer's configured reasoning baseline for ordinary work. Recommend
higher effort when unresolved competing constraints, difficult diagnosis or
consequential design or methodological uncertainty would benefit from deeper
analysis; name the decision it would help resolve. A large task alone is not a
reason to escalate. Lower effort may suit well specified routine edits. State
whether the current interface can change the setting; never imply a switch that
was not made.

When the user or applicable instructions authorize delegation, use a bounded
subtask with relevant authorized inputs, explicit model/effort where supported,
a compact result and no further delegation unless authorized. The primary
assesses the result and retains responsibility. Prefer one focused reviewer
over a standing orchestration loop. Include child usage in cost comparisons;
otherwise state that total usage is unobservable.

Keep progress updates useful and completion reports concise: outcome, obtained
evidence and material limits, without replaying routine logs.

## Validation Stages

A bounded change needs only enough source or behavioral evidence to be
acceptable. An ordinary commit needs focused tests or review for a good,
reviewable state, not production-grade completeness. A milestone commit owns
the comprehensive applicable test, lint, format, build, integration and release
gate. Run a broader check earlier only when it covers affected behavior or a
stated material risk. Prefer bounded success output and retain focused failure
diagnostics.

## Completion

For a clear access, authorization or setup failure, or a recurring execution
mistake, use `reuse-fixes` to consult this repository's confirmed experience
before repeating the failed approach. Apply an authorized correction, verify
it at the original checkpoint and retain concise prevention. Ask only for
missing authority or a material decision; there is no mandatory route-choice
menu. Keep experience repository-local and host facts in the ignored local
record. Do not collect or transfer lessons between repositories. All existing
access, security, installation, Git and publication boundaries remain in force.

Work is ready for review when its requested behavior is implemented, relevant
tests and documentation agree, repository state is preserved, limitations are
explicit and the diff is small enough to review. It is not complete merely
because code was generated, a build passed or a plausible explanation exists.

## Project authority

CODEX.md, the project-specific rules in ChatGPT.md and accepted records in
docs/decisions/ retain their safety and domain authority. This contract
provides current task methods without weakening those safeguards.
