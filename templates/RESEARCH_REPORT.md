# Research Report: <short question-set title>

Internal research evidence; not automatically accepted project content or a
publication artifact. Adapt this scaffold to the question count and depth.
Write explicit unknowns, limits and non-applicability rather than filling gaps
with assumptions. Paths below are relative to the project root.

## Identity and scope

- Report/material ID: `<unique material ID, e.g. RES-0001>`
- Research date / evidence cutoff: `<dates>`
- Assigned project/document IDs: `<project/task reference; document IDs when applicable>`
- Research purpose: `<project task, document or decision this research supports>`
- Starting context and existing authorized evidence: `<references>`
- Replaces or extends: `<earlier report ID or none>`

## Operationalized questions

A topic is not a research question. Turn it into one answerable question or a
bounded, preferably related set before searching. Keep stable IDs within this
report; use `<report-ID>/Q1` when referencing a question from another file.

| ID | Concrete question | Boundaries and exclusions | Evidence needed / expected answer form |
| --- | --- | --- | --- |
| Q1 | `<answerable question>` | `<relevant product/version, population, geography, dates and non-goals>` | `<decision criterion; fact, comparison, explanation or dataset>` |
| Q2 | `<related question; remove if unused>` | `<boundaries>` | `<evidence / answer form>` |

Explain how questions relate and share evidence, or why separately scoped
unrelated questions were deliberately kept in one report: `<note>`.

## Answers and evidence

### Q1: <short question>

- Answer: `<direct scoped answer, or explicitly unresolved>`
- Supporting evidence: `<verified source IDs/links and section/page/record locators>`
- Source findings versus interpretation/synthesis: `<distinction>`
- Contradictory evidence and uncertainty: `<what affects this answer>`
- Implication for the project/document/decision: `<candidate implication; acceptance state>`

Repeat for every question, including unanswered questions. A shared source may
support several answers; do not imply it supports an uninspected claim.

## Sources and individual assessments

Use stable report-local source IDs such as S1/S2. Across reports use
`<report-ID>/S1`, or an existing catalog/bibliography ID when available. Include
every source actually used for an answer, data record or consequential evidence
selection; listing every search hit is unnecessary.

| Source ID | Verified title and author/organization | Questions/claims supported | Assessment entry |
| --- | --- | --- | --- |
| S1 | `<identity>` | `<Q1/Q2 and exact claims>` | `<heading below>` |

### S1: <source title>

- Stable URL/identifier and catalog ID if any: `<references>`
- Publication/update date, inspected version and retrieval date: `<baseline>`
- Assessment date and inspection depth: `<date; metadata/excerpt/full content>`
- Supporting passages/pages/sections/record locators: `<exact locators>`
- Supported questions/claims, contradictions and scope limits: `<mapping>`

| Criterion | Observed status/finding | Inspected evidence / locator | Reasoned assessment and limits |
| --- | --- | --- | --- |
| Authority/expertise | `<observation>` | `<evidence>` | `<why this supports or limits trust>` |
| Currency and version/context fit | `<observation>` | `<evidence>` | `<applicability to this question>` |
| Verifiability/transparency | `<observation>` | `<evidence>` | `<what is inspectable or missing>` |
| Independence/interests | `<observation>` | `<evidence>` | `<specification/vendor claim/independent report/experience; incentives>` |
| Corroboration/counterevidence | `<observation>` | `<evidence>` | `<independent support or conflict; copied claims are not independence>` |

- Use decision for this source: `<which claims it can/cannot support and why>`
- Prior assessment and changes: `<earlier report/source ID or none; changed version/judgment and reason>`

Repeat this entry for every used source. Distinguish confirmed absent, reported
but uninspected, not checked, unavailable/not ascertainable and not applicable.
Do not infer absence from missing access or replace reasoning with a score.
Keep the inspected baseline and previous report references so future checks
can reconstruct the judgment; do not silently overwrite earlier assessments.

## Search and selection note

- Tools/services and search dates actually used: `<list>`
- Central searches, filters and question mapping: `<queries -> Q-IDs>`
- Shared search paths / source tracing: `<how key evidence was reached>`
- Inclusion/exclusion rules and important selection decisions: `<criteria>`
- Counterevidence and currency/version checks: `<actual checks>`
- Coverage, access and time/depth limits: `<limits>`
- Stopping reason: `<scoped questions answered; budget/access/evidence limit>`

Keep this sufficient to extend or repeat the search, without an exhaustive log
or a claim of systematic/exhaustive coverage.

## Generated data and other materials

`None` or, for each retained file:

- Material ID, catalog and portable location: `<ID and reference>`
- Purpose and related question/project/document IDs: `<use>`
- Schema: `<fields, types, units, definitions and missing-value conventions>`
- Coverage and selection rules: `<population, dates, versions, exclusions>`
- Provenance: `<record/field -> source ID, locator and retrieval date; distinguish sourced, computed and estimated values>`
- Processing and validation: `<normalization/calculations; script or reproducible steps; checks actually performed>`
- Limitations and refresh procedure: `<known gaps, mutable sources, repeatable update steps>`

The data file supports reuse; this report explains the research and derivation.
Keep original external files unchanged and catalog generated files as materials.

## Open questions and follow-up

| Question / gap | Why unresolved and effect | Smallest useful follow-up |
| --- | --- | --- |
| `<Q-ID or new question>` | `<limit>` | `<next evidence or decision>` |

- Findings proposed for project/document use and acceptance state: `<candidate/accepted/deferred; reference>`
- Refresh triggers and evidence likely to become stale: `<conditions>`
- Any question or method changes needed for a later pass: `<changes>`
