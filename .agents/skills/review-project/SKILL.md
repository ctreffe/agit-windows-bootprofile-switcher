---
name: review-project
description: Create a detailed, neutral project-state inventory. Use for open-ended orientation, not inconsistency diagnosis or template synchronization.
---

# Review Project

Produce a detailed, neutral inventory from durable evidence. Cover identity,
intent, objective, roadmap, decisions, structure, validation, Git state and
relevant domain context; report existing, active and open state plus evidence
gaps.

Assess mission alignment through
[COLLABORATION.md](../../../COLLABORATION.md#mission-alignment), using the
appropriate source-template or project mission. Include how relevant contents,
workflows, skills and artifacts serve it, with evidence, possible drift/conflict
and open maintainer decisions. Report this bounded assessment without turning
it into a defect audit, automatic mission change or implementation task.

Scale depth: read all relevant files in a compact repository; in a larger one,
start with inventory, routing and durable summaries, then read the evidence
needed. Comprehensive means state coverage, not an implementation audit.

Prefer recorded validation evidence. Run new checks only to resolve a specific
evidence gap; whitespace checks are not a default review step. Reuse unchanged
Git observations and quote revision expressions for the active shell.

Separate observation from interpretation. Do not hunt for defects, attach code-
review findings, propose fixes, modify files, rerun initialization or perform a
consistency audit. Check live origin only when policy permits.
