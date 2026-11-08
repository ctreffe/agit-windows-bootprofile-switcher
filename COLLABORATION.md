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

## Mission Alignment

Use PHILOSOPHY.md's template mission for source maintenance. In a derived
project, use the concrete mission and intent in PROJECT_CONTEXT.md, together
with the inherited template purpose and applicable local family principles.
The shared foundation is reliable human-AI collaboration, reusable workflows,
quality and data protection, with maintainer domain control and transparent
README disclosure. No private Governance checkout is required to apply it.

During a deliberately invoked review or retrospective, assess how the relevant
contents, workflows, skills and artifacts serve that mission. Connect the
intended outcome to inspected evidence; distinguish demonstrated contribution,
possible drift/conflict and unavailable evidence. Include domain control and
truthful human-AI disclosure. Do not equate different methods with misalignment
or completed checklists with a useful outcome. Reference project-specific
success evidence rather than inventing numerical targets.

Report uncertain or conflicting intent for a maintainer decision. Do not rewrite
missions, start fixes, invoke another review, inspect other repositories or
broaden source access automatically. Source-template project placeholders are
not missing template goals; an unclear derived-project mission is an evidence
gap. A hybrid can combine deliberately selected specialist workflows; a clear
specialization should prompt a source-adoption decision, not automatic migration.

## Project Anchor and Temporary Worktrees

Keep the active chat/task anchored to its agreed project directory, instructions
and skill context. Only a maintainer-directed change may replace that anchor.
Explicit target paths and command-local working directories are allowed within
authorized scope; apply the target repository's local rules as well.

Before a worktree action, inspect the whole tool's documented effects, including
chat reassignment, directory changes and instruction/skill discovery. If anchor
retention is uncertain, do not invoke that route; use a verified command-local
route when authorized or ask for direction. Check repository identity, branch
conventions, existing worktrees and staging. Creating, moving or removing a
worktree changes Git metadata and requires repository/action-specific authority
containing explicit, explicitly or explizit. That grant does not permit a chat
anchor switch or additional branch/history changes.

Place temporary worktrees under the owning project's ignored local temp/,
preferably `temp/worktrees/<name>/`, never global app-managed storage. Before
creation, verify canonical containment under the owning checkout and ignore
coverage (for example with git check-ignore); check existing path components
for links/junctions or storage mappings that escape that root. Do not nest a new
worktree inside another temporary worktree. Verify target identity and unchanged
chat anchor, instructions and skill availability after the action.

Worktrees are not disposable intermediates. Exclude them from generic temp
cleanup. Before separately authorized removal, inspect permitted Git state and
preserve uncommitted/untracked work and commits not safely retained elsewhere;
unknown access or retention blocks removal. The parent checkout ignores the
nested tree; source commits within it follow normal repository rules. Never
stage it in the parent or move it to materials/ as ordinary scratch. Placement
grants no access to otherwise restricted files or inherited profile readiness.

If context drifts unexpectedly, stop consequential actions, report the mismatch
without sensitive details, and re-establish and verify the intended directory,
applicable rules and available skills before resuming. Ask for maintainer help
if safe restoration is unavailable. Do not copy scaffolding or skills into
another repository to disguise the context loss. Existing worktrees and global
app storage are not automatically migrated, inspected or cleaned.

Use REPOSITORY.md for the current branch convention before proposing a name.
Keep engineering source, fixtures, environments and test/release authority local;
a worktree grants no dependency installation or operational test permission.

## Ideas and Reflection

Use `IDEAS.md` for possibilities without roadmap priority or timing commitments;
the roadmap owns selected planned work and Decision Records own durable choices.
`record-idea` may route implicitly when the maintainer clearly asks to retain or
update an idea; discussion alone does not authorize capture. Keep one owning
entry and stable local IDs. Capture does not approve implementation or policy;
an idea may be selected immediately or revisited later.

Explicit `perform-retrospective`, where available, jointly develops improvements
from an agreed project period; it may conclude with no action. Governance's
explicit `synthesize-ideas` compares selected authorized cross-project evidence.
Use `record-idea` for selected capture. Cross-repository writes still need exact
destination/action control-word authority and reviewed transferable evidence;
otherwise return a Pending Idea Transfer. Preserve local privacy, source,
security, recipient and publication boundaries.

Use `review-code` for selected interactive code review, `test-code` for an agreed
operational run with one retained report and `setup-test-environment` for a
portable definition and requested reconstruction. Readiness is not behavior
coverage; invocation grants no installation, real-data or external-effect authority.
