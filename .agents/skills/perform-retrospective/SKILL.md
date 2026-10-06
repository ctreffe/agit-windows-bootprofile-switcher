---
name: perform-retrospective
description: Distill collaboration evidence from one derived project into project, source-template or Templateverse improvement candidates.
---

# Perform Retrospective

Establish whether the current repository is a derived project or a source-
template maintenance checkout, then define the reviewed period, permitted
evidence and project boundary. Prefer durable repository evidence and do not
assume access to private chat or sensitive material.

Classify every result as project-specific, source-template candidate, family-
wide candidate or no action. Route project-specific findings to the current
project's roadmap or Decision Record process, template candidates to the
verified source template's `IDEAS.md` and family-wide candidates to governance
`IDEAS.md`.

Only when a result needs another repository, read
`RETROSPECTIVE_PATHS.local.md`. Canonicalize the selected path, verify the
tracked repository identity and, for a derived project's source template,
confirm that the recorded source baseline exists in that clone. Treat a
missing file, `Unset`, identity mismatch or absent baseline as an unresolved or
stale mapping: report the exact role and offer to create or refresh the current
repository's ignored file. Do not scan drives, guess from directory names or
include a concrete path in transferable evidence or a handoff. A valid mapping
still grants no access, destination write, Git, versioning, transmission or
publication authority.

For each transferable candidate record an approved non-sensitive source label,
reviewed period, sanitized evidence, opportunity, recurrence, reusable
elements, benefit, risk, boundaries and next maintainer decision. Sanitize
before anything crosses the project boundary.

In a source-template maintenance checkout, capture in that repository's own
`IDEAS.md` under normal authorized in-scope edit rules. Write to another
repository only when the maintainer authorizes that exact cross-repository
destination and action using `explicit`, `explicitly` or German `explizit`.
Without that cross-repository authorization, return a `Pending Idea Transfer`
containing the fields above,
the exact intended destination and `Destination-write authorization: Not
granted`. Reference it in `TASK_HANDOFF.md` only when that handoff is already
being updated within the same task; do not open a handoff merely to store it.

When the destination write is the next requested step, also propose one minimal
copy-ready instruction naming the exact action, destination repository and
material consequence; the proposal is not authorization.

Capture is not promotion or implementation approval. Do not edit another
repository automatically, create a derived-project `IDEAS.md`, or add, remove
or rewrite one in an existing derived project.
