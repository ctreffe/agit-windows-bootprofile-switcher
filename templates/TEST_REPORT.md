# Local Test Plan and Report

Copy once per agreed plan to an ignored assistant-readable location, normally
`temp/test-code/<run-ID>/REPORT.md`. Confirm ignore coverage before execution.
Do not version populated reports, credentials, raw private logs or host bindings.
Append attempts; preserve failures and interruptions. Material scope expansion
creates a linked new plan/report instead of rewriting this run.

## Plan

- Run ID, date and owner: `<identity>`
- Question and selected target: `<behavior, suspected defect or change>`
- Source repository/revision/dirty state: `<actual provenance>`
- Runtime/build identity and verification method: `<actual target; unknown if unverifiable>`
- Environment definition/version and readiness: `<reference and limits>`
- Methods/tools and their coverage limits: `<browser/HTTP/unit/integration/concurrency>`
- Fixtures/data, access and effect authority: `<synthetic default; exact scope>`
- Isolation and excluded targets: `<services, accounts, storage and networks>`
- Resource/time/request/concurrency limits: `<bounds>`
- Stop conditions and cleanup/retention recipe: `<criteria and owned resources>`
- Planned attempts/retry allowance: `<bounds>`
- Plan agreement: `<maintainer instruction/date and agreed scope; pending until agreed>`
- Prior/new linked runs: `<references or none>`

| Case ID | Action / method | Expected outcome | Authoritative oracle and permitted evidence |
| --- | --- | --- | --- |
| C1 | `<action>` | `<observable expectation>` | `<independent outcome check>` |

## Attempts

Repeat this section for each attempt within the plan. An interrupted attempt
remains recorded; unknown outcomes are not passes.

### Attempt A1

- Start/end and actual parameters: `<timestamps and bounds>`
- Actual source/build/runtime provenance: `<verified identity or gap>`
- Commands/method and evidence locators: `<safe references; no uncontrolled dumps>`
- Deviations, interruption or stopping reason: `<facts or none>`

| Case ID | Actual outcome | Pass / fail / blocked / not run | Evidence and limits |
| --- | --- | --- | --- |
| C1 | `<observation>` | `<status>` | `<authoritative result and locator>` |

- Cleanup result and retained owned resources: `<observed result>`
- Additional-attempt agreement if outside existing allowance: `<instruction or not applicable>`

## Result

- Run status: `<planned | running | completed | interrupted | blocked>`
- Behavior established and unresolved failures: `<evidence-based conclusion>`
- Coverage gaps and remaining cases: `<limits>`
- Cleanup gaps and next agreed action: `<facts>`
- Linked follow-up plan or separately authorized fix: `<reference or none>`
