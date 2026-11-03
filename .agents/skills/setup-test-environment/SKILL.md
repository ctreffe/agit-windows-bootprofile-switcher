---
name: setup-test-environment
description: Define or reconstruct a project-owned test environment from a portable definition and executable recipe. Use for requested environment setup, not to launch operational tests or provision tools during ordinary validation.
---

# Setup Test Environment

Keep environment readiness separate from test coverage. Use this workflow for
a requested setup task; a missing dependency discovered during another task is
not authority to install it. Read local engineering, data and execution rules.

1. Inspect the existing approved environment definition first, normally
   docs/testing/TEST_ENVIRONMENT.md. Reuse its requirements and recipes; do not
   repeat a completed interview. Establish the desired source/runtime baseline
   and whether the request is first definition, reconstruction or a bounded
   update. Same-host reuse does not prove fresh-host reconstruction.
2. For a new or incomplete definition, ask only unresolved material questions:
   supported tests, tools and exact versions/sources, topology/ports, storage,
   synthetic fixtures, external effects, resource/stop limits and readiness
   criteria. Keep project-specific bindings instead of choosing a stack for the
   template. Resolve scope and required installation/privilege/effect authority
   before performing those actions; reuse exact existing approvals.
3. Fill the [portable definition](../../../templates/TEST_ENVIRONMENT.md),
   including executable preparation/build, start, readiness and stop/retention
   recipes, before implementation. Use the project's supported command syntax,
   exact tools and working directories. Do not execute unfilled placeholders.
   Record portable source/version identity and expected outcomes. Credentials,
   concrete host paths and private data remain in approved ignored local storage,
   for example temp/test-environment/<environment-ID>/HOST.local.md, outside
   temp/restricted/. A definition or mapping grants no access to its targets.
4. On reconstruction, compare the current host with the definition using only
   authorized checks. Resolve host bindings and missing prerequisites; do not
   silently change versions, download dependencies, use real data, replace
   unrelated services or alter the agreed definition to fit the host. Review
   material recipe changes before execution and retain their rationale locally.
5. Prepare/build only within the selected authority. Start only the selected
   services when start is in scope; preserve unrelated processes, occupied ports
   and existing data. Track resources created by this run for bounded cleanup.
   Verify actual source/build/runtime identity, including dirty state where
   applicable. Support a local development build or an explicitly selected
   published-version comparison without substituting one for the other.
6. Check the agreed readiness criteria with synthetic, bounded health checks;
   record prepared, started, ready, failed or blocked independently. Stop on
   unexpected effects or limits. Follow the agreed stop/retention recipe for
   owned resources and report anything retained or not cleaned up.
7. Keep the portable definition current and save host-specific readiness evidence
   in the approved ignored location. State which definition/version was used,
   actual provenance, phases performed, readiness result and remaining gaps.
   Do not invoke test-code or operational tests automatically. Preparing,
   starting and readiness never imply that project behavior has been tested.
