---
name: test-code
description: Plan, execute and report bounded tests of behavior, suspected defects or changes on explicit maintainer invocation. Use for an agreed operational test run, not every routine validation command.
---

# Test Code

Start only on deliberate maintainer invocation. A diff is not required. This
skill coordinates project-owned methods; it does not supply a runner or grant
source fixes, installation, protected data access, Git actions or publication.

1. Reuse known requirements, local test guidance and any existing environment
   definition. Establish target behavior, actual source revision/dirty state,
   runtime/build identity, data and effect boundaries. Report a mismatch between
   requested source and running code; do not silently substitute a published or
   local build. Do not inspect unauthorized data to establish provenance.
2. Agree one bounded plan before executing tests. Use the
   [report template](../../../templates/TEST_REPORT.md) to record case IDs,
   expected outcomes and authoritative oracles, method/tools, fixtures,
   isolation, external effects, resource/concurrency/time/request limits,
   stopping conditions and cleanup. Reuse an already approved matching plan;
   otherwise present the concrete plan and wait for agreement. Only read-only
   authorized preparation may precede agreement.
3. Use available project-owned browser, HTTP, unit, integration or concurrency
   methods that answer the question. Explain their limits: HTTP does not execute
   browser JavaScript, simulated concurrency is not measured concurrent load,
   and UI success alone does not establish persisted results. If setup is
   missing, propose a bounded setup task using setup-test-environment; do not
   install, reconstruct services or broaden effects under test invocation.
4. Before execution, create one ignored local report per plan, normally
   temp/test-code/<run-ID>/REPORT.md. Confirm its location is ignored and
   assistant-readable, never under temp/restricted/. Use approved local storage
   for sensitive evidence and sanitize the report; never copy credentials or
   uncontrolled logs. If a report cannot be saved, report the blocker before
   operational execution rather than silently running without the record.
5. Append each agreed attempt to that report with timestamps, commands/method,
   actual source/runtime provenance, case outcomes, evidence locators and
   cleanup result. Preserve failures and interrupted/partial outcomes; distinguish
   pass, fail, blocked and not run. Verify relevant authoritative outcomes
   independently of presentation, within approved read/effect boundaries.
6. Stop on agreed limits, unexpected external effects or isolation failure.
   Reuse approval for retries already covered by the plan; obtain agreement for
   an additional attempt or changed parameters outside it. A material change
   to target, cases, method, effects or resource scope creates a linked new plan
   and report; do not overwrite or silently expand the old run.
7. Report the behavior established, failures/open questions, coverage limits,
   cleanup/retained resources and saved report path. Readiness or a successful
   command alone is not test coverage. Offer fixes separately; do not implement
   them as part of this skill without separate source-edit authority.
