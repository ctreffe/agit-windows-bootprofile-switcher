---
name: record-decision
description: Record a durable repository decision with the established local Decision Record taxonomy, template, numbering and index conventions.
---

# Record Decision

Use when the task requires creating or updating a durable Decision Record. Do
not create a record merely because an ordinary implementation choice was made.

First identify the repository role. In governance, use the governance record
taxonomy. In a derived project, create concrete numbered records when the
decision threshold is met. In a source template, keep only reusable `0000`
record templates and route durable template-development decisions to the
governance repository. TVDR-0050/0080 apply this same rule to Guarded Agent;
there is no historical-record exception. Derived projects own their local
records. Preserve project-owned decisions and unknown inherited records;
removal or migration needs its own maintainer-selected scope. This routing
grants no protected-project access.

1. Read the local Decision Record guidance, index and applicable accepted
   records before choosing the record type.
2. Confirm the maintainer-owned decision, scope and status. Do not convert an
   unresolved choice into an accepted decision.
3. Select the local taxonomy and next stable identifier without renumbering or
   silently rewriting existing records.
4. Use the repository template and record context, decision, rationale,
   consequences, alternatives and follow-up at proportionate depth.
5. Update the local index and only the current-state or roadmap references made
   stale by the decision.
6. Validate links, naming, status and consistency with prior records.

Supersede an accepted record explicitly rather than editing away its history.
Repository edits and protected Git actions retain their normal authorization
boundaries.
