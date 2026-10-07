---
name: commit-milestone
description: Close a reviewed version or milestone with synchronized metadata, comprehensive checks, a commit, an annotated version tag and exact upstream pushes unless excluded.
---

# Commit Milestone

Use only when the maintainer explicitly invokes `$commit-milestone` for an
identified milestone or version closure, or requests missing tags for identified
completed milestones. This does not replace development or review.

Repository-specific explicit milestone commit authorization includes the commit,
its annotated version tag, normal branch push and exact tag push to the verified
existing upstream unless excluded. Invoking a skill alone supplies no Git
authority. Confirm the repository, reviewed selection, version, tag and upstream;
ask only for a missing or ambiguous target or authority. This is not standing
authority for later commits, another repository or other Git actions.

Honor exclusions literally: "commit only" means only the commit; "no push"
retains the commit and local tag; "no tag" excludes tag creation and tag push;
"no tag push" retains the local tag and allows the included branch push.
Release publication remains separately authorized.

1. Establish the exact repository, completed version or milestone, branch,
   worktree and staged file list. Preserve unrelated changes and selections.
2. Inspect staged version, changelog, README, objective/roadmap and handoff
   metadata. Resolve inconsistencies before creating a version tag.
3. Classify semantic scope and run comprehensive applicable validation after
   milestone inputs are stable. Include required release, rendering, visual,
   security, privacy, statistical and other domain checks. Reuse evidence only
   where the contract permits and governed inputs are unchanged; rerun affected
   checks after a relevant correction. Retain diagnostics and report limits.
4. Select the repository's established version-tag name (`vX.Y.Z` in these source
   templates). Its target is the new reviewed milestone commit, or an exact
   existing commit for backfill. Inspect that name locally and on the
   verified upstream, including an annotated tag's peeled commit. Reuse an
   existing tag only when it resolves to the intended commit; reconcile differing
   local/remote tag objects before push. Never move, replace or delete a tag to
   make the check pass. Ask for a name when the milestone has no version/tag rule.
5. Resolve authorized closure gaps and propose a human-readable versioned commit
   summary, concise evidence-based body and tag annotation. Keep unstaged,
   untracked, generated and local work outside the reviewed selection.
6. With the required explicit authority, request each `git add`, `git commit`,
   `git tag` and included `git push` through narrow platform escalation on its
   first attempt; do not probe `.git/index.lock` denial. Keep read-only inspection
   sandboxed. Escalation grants no additional action, path or standing authority.
   If a control word is missing, propose one minimal copy-ready instruction naming
   the exact commit/tag/push action, repository, upstream and material consequence;
   the proposal is not authorization.
7. Create and verify the reviewed commit, then create its missing annotated tag
   at that exact full commit ID, with a meaningful annotation. Reuse an existing
   matching tag instead of creating it again. Verify the tag's
   object type and peeled commit. Respect repository signing requirements without
   changing identity, signing configuration or installing tools.
8. Push only the intended branch and exact version tag to the existing upstream.
   Prefer one atomic push with one explicit branch refspec and one explicit tag
   refspec; disable following tags. Never use `--tags`, force-push, include other
   refs or create/change a remote. When atomic push is unsupported, push the exact
   branch then exact tag separately under the same authority and report partial
   outcomes. A rejected push permits no pull, merge, rebase, forced tag replacement
   or force-push; retain completed local artifacts and diagnose the actual gap.
9. Verify local commit/tag and live upstream branch/tag revisions, including the
   peeled tag commit. Report the actual result, exclusions and validation limits;
   a successful branch push alone does not complete an included tag push.

For missing tags on already completed milestones, review each named repository,
version and exact historical target against its committed metadata and retained
acceptance. Reuse unchanged evidence with its recorded limits. Create and push
only the exact missing tag with explicit backfill authority; do not create a new
content commit or tag current HEAD merely because it is newer. Complete any
necessary version correction in a separately reviewed and authorized commit
before selecting the final target. Do not reinterpret earlier commit authority
retroactively or retag an existing release. Excluded tags and standalone tag
operations outside this workflow retain their own authorization boundaries.
