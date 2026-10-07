---
name: commit-changes
description: Finalize an ordinary reviewed change as a scoped commit and normal upstream push unless excluded. Do not use for version or milestone closure.
---

# Commit Changes

Confirm repository scope, working-tree state, staged selection and changed
hunks. Preserve unrelated and pre-existing changes. Reuse current evidence
while governed inputs have not changed.

When this workflow is requested, repository-specific explicit commit
authorization includes the commit and its normal push to the verified existing
upstream, unless the maintainer says commit only, no push or an equivalent
restriction. Invoking a skill alone supplies no Git authority. Confirm the
repository, reviewed selection and intended upstream before committing; ask
only if the target is missing, ambiguous or outside that scope. This is not
standing authority for later commits, another repository or another Git action.

An ordinary commit needs a good, targeted and reviewable state, not a complete
repository gate. Select the smallest check or review that materially increases
confidence in the changed behavior, text or contract. Automated tests,
whitespace checks, broad renders, builds and full suites are optional unless
affected or required by a stated material risk. A failed relevant check must be
diagnosed and rerun after an in-scope fix. Keep success output concise and
retain focused failure diagnostics. Member repositories do not run the family
validator; possible shared consequences become a Governance follow-up.

Then present and check the complete proposed message. An ordinary summary uses
one exact direct prefix from `feat:`, `fix:`, `docs:`, `chore:`, `refactor:`,
`test:`, `ci:` or `build:` followed by a concise imperative summary. Scoped
forms such as `feat(scope):` do not satisfy this repository-family convention.
Provide a meaningful body that explains purpose, material changes, important
boundaries and relevant validation without merely repeating the summary. Use
real line breaks and reject literal `\n` escape text. Milestone metadata is
handled only by `commit-milestone`.

When `TASK_HANDOFF.md` is included, confirm that its completed-state wording
remains true after the commit. Do not update it after committing merely to
record that the commit occurred; later work reconstructs live Git state.

The default `workspace-write` sandbox keeps `.git` read-only. Once exact
staging is requested or the corresponding commit is authorized, request each
`git add`, `git commit` and included `git push` command through the platform's narrow sandbox
escalation on its first attempt; do not probe the expected `.git/index.lock`
denial first. Keep read-only Git inspection sandboxed. Escalation changes only
the execution boundary: it grants no repository, action, path-selection, push
or standing authority and creates no persistent allow rule.

Create the commit only after the repository's required explicit authorization.
If the control word is missing, propose one minimal copy-ready instruction
naming the exact commit-and-push action, repository, existing upstream and
material consequence; the proposal is not authorization. Respect a commit-only
restriction without asking again about push.

Verify the resulting commit, including its complete message and remaining
working tree. Then perform the included normal push unless excluded. Use one
explicit branch refspec to the verified existing upstream and disable following
tags. Never force-push, push other refs, create or change a remote, or publish a
release under this authorization. If a normal push is rejected, retain the
completed commit and diagnose the push; pull, merge, rebase and force-push
remain separately controlled. Verify local HEAD and the intended upstream
revision after success. A required platform escalation is an execution approval,
not a reason to ask again for an already authorized push.

Stop instead of silently widening scope, repairing unrelated failures or
including files that were not reviewed.
