---
name: start-task
description: Start a new bounded repository task with lean context reconstruction. Use for ordinary objective changes, not comprehensive project or governance reviews.
---

# Start Task

Establish only the context needed for the requested objective.

A clarification, status request or continuation of the same objective is not
new task entry. Reuse already established context and evidence while their
inputs remain unchanged. Refresh changed or uncertain authority, scope and
repository state; freshly read exact patch spans as required below. Mandatory
domain and access gates still apply.

1. Read the closest repository instructions and current `TASK_HANDOFF.md` when
   present. Reconcile any transient Git observation there with live repository
   state. A commit created after a completed handoff is normal lifecycle
   progression, not a stale handoff; do not surface that mismatch unless it
   changes the recorded outcome, substantive open points or continuation.
   Treat an otherwise stale or unrelated handoff as non-authoritative.
2. Inspect branch, working tree and staged state without changing them.
3. Establish the intended outcome, repository scope and a clear completion
   criterion from the request. Ask only for missing information that materially
   affects the work; continue independent authorized work while awaiting it.
4. Read the target and only directly applicable authority, domain, decision and
   validation material. Prefer matched sections, changed hunks and bounded
   output before full files or diffs.
   Before a coordinated or context-sensitive patch, freshly read each exact
   target span. Build small hunks around stable semantic anchors and separate
   independent files or uncertain hunks. When assembling a patch dynamically,
   preserve an explicit operation marker on every hunk line.
5. Continue the authorized bounded work until its completion criterion is met
   or a real blocker requires input. Obtain only the smallest evidence needed
   to show that the affected behavior or text is acceptable and aligned with
   project intent; an automated check is optional. Do not default to whitespace checks,
   broad renders or complete suites. Exercise a changed validator narrowly and
   escalate only for a stated material risk.
   After a context-verification rejection, inspect whether any partial edit
   occurred and reread only the failed target instead of retrying the same
   patch or assuming whitespace damage.
6. Report evidence actually obtained and checks deferred or not run. Keep
   successful output concise and retain focused diagnostics for failures.

Escalate to the repository's review skill only when identity, authority or
current state cannot be established safely through this route.
