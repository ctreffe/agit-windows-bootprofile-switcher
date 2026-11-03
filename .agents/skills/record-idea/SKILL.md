---
name: record-idea
description: Capture or update an existing idea in the appropriate project, source-template or Governance backlog when the maintainer asks to retain it, including authorized cross-repository transfers. Do not use for mere discussion or retrospective discovery.
---

# Record Idea

Preserve CODEX.md and boot/account/service/registry/rollback safeguards.
Do not execute host-changing helpers or inspect device-bound logs/state for ideas.

Use implicitly for a clear request such as "keep this idea for later" or "add
this to the template's ideas". Discussion, a request for assessment or an
agent-generated suggestion alone does not authorize a write. Capture a supplied
idea directly; do not require a retrospective, reviewed period or recurrence.

Preserve engineering evidence, architecture, test and release authority;
keep secrets, private logs and source dumps out of entries.

## Owner and local capture

Identify whether this is Governance, source-template maintenance or a derived
project. Route project-specific ideas to that project's own `IDEAS.md`,
source-template candidates to the verified source template's `IDEAS.md` and
family-wide candidates to Governance `IDEAS.md`. Respect a named destination;
clarify a material ownership ambiguity rather than guessing. A derived project
is not its source template. Selected planned work belongs in the roadmap and
durable accepted decisions use `record-decision`; neither follows from capture.

Read the authorized owner's rules and backlog, deduplicate and update an
existing entry when it is the same idea. Otherwise choose the next stable local
`IDEA-NNNN`, considering all entries/redirects without renumbering. Keep one
authoritative entry; references use repository identity plus local ID. For an
authorized transfer, retain a compact `Transferred` redirect at the origin only
when that origin edit is also in scope. Do not silently move or duplicate ideas.

Capture in the current repository's own `IDEAS.md` under normal authorized
in-scope edit rules. In an existing ordinary derived project, a clear local
capture request may create a missing backlog from
[the empty project scaffold](../../../templates/IDEAS.md); adapt project identity and preserve all existing
content. Do not run initialization or clear a backlog to record an idea.

Use the local entry format. The lightweight core is status (normally
`Captured`), opportunity, potential destination (which may be unresolved) and
next maintainer decision. Add sources, evidence, benefit, risks, boundaries or
references only when useful or required locally. Never invent evidence or
recurrence. Retrospective-derived candidates retain their reviewed period,
sanitized evidence and observed recurrence/limits. Report the owning entry.

## Cross-repository intake

Only when another repository is needed, resolve a permitted exact destination.
In a source template or derived project, read `RETROSPECTIVE_PATHS.local.md`:
canonicalize the selected path, verify tracked repository identity and, for a
derived project's source template, confirm the recorded source baseline exists
in that clone. A missing file, `Unset`, identity mismatch or absent baseline is
an unresolved or stale mapping: identify the role and offer to create/refresh
only the current repository's ignored mapping. Do not scan drives, guess clone
identity or include concrete paths in transferable evidence or handoffs.
Governance uses its authorized registry-selected destination and applicable
local mapping. A mapping grants no access, destination write, Git, versioning,
recipient, transmission or publication authority.

Write another repository only after exact destination and action authorization
containing `explicit`, `explicitly` or `explizit`. Implicit invocation, delegation
from another skill and approved source access do not grant that authority.
Without it, return a `Pending Idea Transfer` with:

- **Source:** Approved non-sensitive label, if relevant
- **Candidate scope:** Project-specific | Source-template | Family-wide
- **Intended destination:** Exact repository/role and `IDEAS.md`; mark unresolved mappings
- **Opportunity:** Supplied idea or useful outcome
- **Boundaries:** Material access, disclosure, domain and non-goals
- **Next decision:** Smallest maintainer-owned decision
- **Destination-write authorization:** Not granted

Add reviewed period, sanitized evidence, recurrence/limits, reusable elements,
benefit, risk and references when derived from a retrospective or otherwise
material; a supplied idea needs no fabricated retrospective. Reference the block
in `TASK_HANDOFF.md` only if already being updated in this task; do not open a
handoff just to store it. Pending capture is not a destination entry.

When the destination write is the requested next step, propose one minimal
copy-ready instruction naming the exact action, destination repository and
material consequence. The proposal is not authorization.

Capture is not promotion or implementation approval. Promote only after the
maintainer selects destination and scope; link the selected roadmap or durable
decision and avoid stale duplicate plans. Immediate selection is possible.
Git, protected access, security acceptance and publication remain separate.
