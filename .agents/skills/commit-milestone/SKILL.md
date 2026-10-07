---
name: commit-milestone
description: Close an already reviewed version or milestone with synchronized metadata, comprehensive applicable checks, a milestone commit and normal upstream push unless excluded.
---

# Commit Milestone

Use only when the maintainer explicitly invokes `$commit-milestone` for an
identified milestone or version closure. This is not a substitute for
developing or reviewing the milestone.

When this workflow is requested, repository-specific explicit commit
authorization includes the commit and its normal push to the verified existing
upstream, unless the maintainer says commit only, no push or an equivalent
restriction. Invoking a skill alone supplies no Git authority. Confirm the
repository, reviewed selection and intended upstream before committing; ask
only if the target is missing, ambiguous or outside that scope. This is not
standing authority for later commits, another repository or another Git action.

1. Establish the exact repository, completed version or milestone, Git state
   and staged file list.
2. Inspect staged versions of relevant version, changelog, README, objective or
   roadmap and handoff files. Read a full staged patch or unrelated working-tree
   file only when an inconsistency requires it.
3. Classify the semantic scope and run the repository's comprehensive
   applicable validation after milestone inputs are stable. Add release,
   rendering, visual, security, privacy, statistical or other domain checks
   required by the declared milestone. Reuse current evidence only where the
   milestone contract permits it and governed inputs are unchanged. Bound
   success output, retain failure diagnostics and rerun affected checks after a
   relevant correction.
4. Check tags, upstream state and release rules with bounded commands. Load
   additional authority only for a real conflict or gap.
5. Keep unstaged and untracked work outside the milestone and report it without
   inventorying unrelated contents.
6. Resolve only authorized closure gaps, rerun required validation and propose
   a human-readable versioned summary plus concise evidence-based body.
   The default `workspace-write` sandbox keeps `.git` read-only. Once exact
   milestone staging is requested or the milestone commit is authorized,
   request each `git add`, `git commit` and included `git push` command through the platform's
   narrow sandbox escalation on its first attempt; do not probe the expected
   `.git/index.lock` denial first. Keep read-only Git inspection sandboxed.
   Escalation changes only the execution boundary, grants no additional Git or
   path-selection authority and creates no persistent allow rule.
7. Create the commit with the required explicit authorization and verify it.
   When its control word is missing, propose one minimal copy-ready instruction
   naming the exact commit-and-push action, repository, existing upstream and
   material consequence; the proposal is not authorization.
8. Perform the included normal push unless excluded. Use one explicit branch
   refspec to the verified existing upstream and disable following tags. Never
   force-push, push other refs or create or change a remote. If a normal push is
   rejected, retain the completed commit and diagnose the push; do not pull,
   merge, rebase or force-push without separate authority. Verify local HEAD and
   the intended upstream revision after success. A required platform escalation
   supplies execution permission, not a need to ask again about an authorized
   push.

Tag creation, tag push and release publication remain separate protected
actions requiring their own authorization and post-action verification. When a
control word is missing, propose separate copy-ready wording for each of these
independent actions. A commit-only restriction is honored without a new push
question.
