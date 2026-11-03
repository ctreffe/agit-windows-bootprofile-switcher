---
name: review-code
description: Interactively explain and assess existing code or concrete changes in numbered review rounds. Use on deliberate maintainer selection, not for a neutral project inventory or routine validation.
---

# Review Code

Review the selected code without editing it. Apply the local access and source
ownership rules even when collaboration context and source are in different
repositories; a path or supplied diff does not grant further repository access.

1. Reuse the requested review question and scope. Establish the exact repository,
   revision or working-tree snapshot and selected files. For changes, establish
   the base and target and distinguish staged from unstaged changes without
   altering either. If the base is ambiguous, resolve it before making change
   claims; a diff is optional for existing-code review.
2. Inspect the selected code plus relevant callers, contracts, tests and state
   transitions. Verify excerpts against the stated snapshot. State gaps when
   surrounding context is unavailable rather than inventing behavior.
3. Divide the selected scope into logical blocks in an understandable order.
   Number blocks continuously across rounds. Default to four blocks per round,
   with fewer in the last round; honor an agreed different size. Show only
   useful verified excerpts or diff hunks with file/revision/line provenance.
4. Explain each block's purpose, why/how it works, side effects, callers/state,
   compatibility, relevant risks and evidence limits. Separate observed behavior
   from inference and prioritized findings from optional improvements. Mention
   material cross-block interactions when known; do not hide them until a later
   round or confuse explanation with a comprehensive correctness proof.
5. Pause after each round for feedback. Track accepted, questioned, deferred and
   not-yet-reviewed blocks against the snapshot. Answer questions and resolve
   requested clarifications before advancing; reuse already supplied acceptance.
   New source changes require a fresh snapshot and re-review of affected blocks
   and interactions. Do not carry acceptance across revisions silently.
6. Finish with reviewed scope, substantive findings, unresolved decisions,
   validation obtained and remaining coverage. If stopped early, identify the
   remaining blocks. Acceptance of a round does not establish independent or
   complete review of the project.

Do not fix source, install tools or run operational tests as a side effect of
review. Propose a separately scoped follow-up where needed. Maintainer review
acceptance, edit authority, protected Git actions and publication are separate.
No automatic source-change trigger is supplied by this template.
