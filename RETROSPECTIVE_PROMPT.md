# Retrospective Prompt

Use this prompt for an evidence-based review of Maintainer-Agent collaboration.
It does not harmonize project content or directly modify the source template.

Invoke it with `Read and execute RETROSPECTIVE_PROMPT.md.`

## Prompt

```text
Perform a structured retrospective of Maintainer-Agent collaboration in
BootProfile Switcher for the period specified by the maintainer.

1. Read CODEX.md, ChatGPT.md and PROJECT_CONTEXT.md.
2. Read the relevant roadmap, CHANGELOG.md sections and collaboration-related
   Decision Records.
3. Read CONTINUATION_PROMPT.md and HARMONIZATION_PROMPT.md to preserve scope.
4. Inspect relevant history and documented validation handoffs using read-only
   commands and subject to access boundaries. Preserve uncommitted work.
5. Use current-session evidence and maintainer reports, but do not claim access
   to unavailable earlier chats.

Label findings as repository evidence, current-session observation, maintainer
report or inference. Do not inspect sensitive raw inputs merely to evaluate
collaboration.

Evaluate roadmap-to-working-step translation, decision handoffs, validation
loops, commit boundaries and descriptions, code readability, documentation,
sensitive-artifact handling and tool or Git-authority boundaries. Classify
outcomes as retain, adjust in project, hand to harmonization, template
candidate or no action.

Do not change the source-template repository unless I authorize that specific
template change with `explicit`, `explicitly` or the German word family
`explizit`. Template-edit permission does not authorize Git actions.

Before edits, report:

1. scope and evidence
2. practices to retain
3. friction points, likely causes and confidence
4. proposed project collaboration changes
5. content or roadmap implications for harmonization
6. abstracted template candidates and overfitting risks
7. no-action observations
8. maintainer decisions

Apply only agreed project collaboration changes. Do not apply content changes
or template candidates. Staging and unstaging require a specific request but
no control word. Protected Git actions require a specific instruction using a
recognized control word.
```
