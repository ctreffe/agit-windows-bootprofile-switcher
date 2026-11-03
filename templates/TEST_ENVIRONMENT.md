# Test Environment Definition

Copy to `docs/testing/TEST_ENVIRONMENT.md` when defining a concrete environment.
Fill only project-relevant fields; mark exclusions explicitly. This portable
definition and its recipes may be versioned. Keep credentials, private paths,
host bindings and runtime evidence in approved ignored local storage. A recipe
is not installation, execution, access or external-effect authorization.

## Identity and supported scope

- Environment ID and definition revision/date: `<identity>`
- Owner and approved setup scope: `<preparation | start | readiness | stop>`
- Supported tests and excluded behavior: `<scope>`
- Source repository/baseline and dirty-tree policy: `<identity>`
- Runtime target: `<local development build | selected published version>`
- Build/runtime provenance checks and expected identity: `<commands and criteria>`

## Prerequisites and topology

| Component | Exact version/source | Role and dependencies | Readiness criterion |
| --- | --- | --- | --- |
| `<tool/service>` | `<pinned project-owned source>` | `<process/ports/network/storage>` | `<observable condition>` |

- Supported host/platform and manager: `<requirements>`
- Host binding names and ignored mapping location: `<logical names; no secrets>`
- Synthetic fixture recipe and reset policy: `<commands and allowed storage>`
- Protected/real data and unrelated services: `<exclusions>`
- Approved external effects and required separate authority: `<scope or none>`
- Time/resource/request/concurrency limits and stop conditions: `<limits>`

## Executable recipes

Replace each recipe with exact project-supported commands and expected results.
Record working directory, shell and required authority per phase. Do not run
unfilled placeholders. Keep preparation/build separate from start and readiness.

| Phase | Working directory / shell | Commands or script reference | Expected result / failure action |
| --- | --- | --- | --- |
| Prepare/build | `<relative root / shell>` | `<exact commands>` | `<artifact and provenance>` |
| Start | `<relative root / shell>` | `<exact commands>` | `<owned processes/resources>` |
| Readiness | `<relative root / shell>` | `<bounded synthetic health checks>` | `<observable criteria and timeout>` |
| Stop/cleanup | `<relative root / shell>` | `<commands targeting owned resources>` | `<retention, failure reporting>` |

## Reconstruction and change rules

- Reuse this definition before asking questions; resolve only changed host facts.
- Verify actual source/build/runtime identity before calling the environment ready.
- Resolve occupied ports or missing prerequisites without replacing unrelated services.
- Review material version, recipe, topology, data or effect changes before execution.
- Save phase outcomes, provenance, retained resources and gaps in the approved
  ignored host record, normally `temp/test-environment/<environment-ID>/HOST.local.md`.
- Same-host reuse and readiness do not establish fresh-host restoration or test coverage.
- Operational tests require a separately agreed `test-code` plan.
