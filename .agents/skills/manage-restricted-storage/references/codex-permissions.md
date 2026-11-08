# Codex permission profiles and ordinary Desktop verification

Use [manage-codex-config](../../manage-codex-config/SKILL.md) for composing,
validating, applying and recovering the selected config delta. The original
state and backup below are the shared transaction, not a second snapshot.
Keep this procedure's protection, full-restart and domain-specific recovery
requirements; the config skill supplies no broader access or activation.

Use only for the selected project and approved profile changes.

## Capture the original state

Record the original Desktop mode and retain the exact approved project-local
`.codex/config.toml` bytes or its prior absence. Record any affected default
needed to restore it. Keep the recovery record in approved ignored local
storage. When a change could prevent startup or tool access, establish a
bounded independent rollback before editing. It restores only the owned change
and stops on unexpected concurrent edits.

## Prepare the project profile

Use the full repository slug followed by `-restricted`. Extend the approved
baseline and preserve existing grants, denies and unrelated settings. Resolve
the three standard denies from the known project root without inspecting the
closed zones. Add only explicitly named and approved external protected paths.
Keep catalogs and ordinary working folders outside the denied paths.

A new ordinary project's profile enables command networking unless the
maintainer specifies a restriction or higher rules require one. Preserve
approved network rules on existing profiles. Transmission and access require
their own authority. Preserve the current default unless a change to it is
approved. This example shows the profile definition to adapt.

```toml
[permissions.example-repository-restricted]
extends = ":workspace"

[permissions.example-repository-restricted.filesystem]
'D:/APPROVED-PROJECT/input/intake' = "deny"
'D:/APPROVED-PROJECT/input/restricted' = "deny"
'D:/APPROVED-PROJECT/temp/restricted' = "deny"

[permissions.example-repository-restricted.network]
enabled = true
```

Check that the intended safe project write root is covered. If it is missing,
use the profile's `workspace_roots` for the exact approved project root. A
working directory alone cannot grant writes. Review any conflicting overrides
and managed restrictions before applying the approved change.

## Restart and confirm

1. Save the approved change. Ask the maintainer to fully quit and reopen
   Desktop, then select the named profile in the intended local chat if needed.
2. In a fresh ordinary, non-escalated tool turn, check the profile marker and
   the supplied effective permission scope against the intended denies and
   safe project roots. Check the declared network rule when available. Record
   the date and active scope, or the exact gap. This confirms settings in effect for the observed route. Actual denial and ordinary
   operations require separate behavior evidence.
3. For rollback, restore the original config bytes or prior absence while
   preserving concurrent edits. The maintainer fully restarts Desktop, then
   restores the original mode if needed. Confirm the original configuration
   and effective scope in a fresh ordinary tool turn after that restart.

Routine scope checks use no negative canary probes. During selected setup,
qualify required ordinary workflows through the
[usability procedure](profile-usability.md), reusing current evidence and
existing authority. Bring unresolved enforcement or compatibility questions
to Governance for separately scoped invented-only tests. Keep failed or stale results visible. Local command scope
gives no assurance for other tool routes or approved escalation.

## Required workflows

Complete the [usability procedure](profile-usability.md) alongside the selected
profile setup. Keep missing authority or failed required operations pending.
Domain-specific credential and execution boundaries remain authoritative.

## Official sources

Checked 2026-11-04; verify relevant changes before later configuration work:

- [Permission profiles and workspace roots](https://learn.chatgpt.com/docs/permissions)
- [Sandbox and Desktop permissions control](https://learn.chatgpt.com/docs/sandboxing)
- [Configuration precedence](https://learn.chatgpt.com/docs/config-file/config-basic)
- [CLI reference](https://learn.chatgpt.com/docs/cli/reference)
- [App-server interface](https://learn.chatgpt.com/docs/app-server)

## Engineering boundary

Fixtures and status checks do not run application/build/startup hooks,
provision environments or approve access to logs, dumps, APIs, databases or
credentials. Preserve the existing source/test/configuration ownership.
