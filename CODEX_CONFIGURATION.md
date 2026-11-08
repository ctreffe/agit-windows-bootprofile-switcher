# Project-local Codex configuration

Use [manage-codex-config](.agents/skills/manage-codex-config/SKILL.md) for requested
changes to the project's `.codex/config.toml`. This guide ships a reusable method,
not an active config. Keep existing settings and change only selected keys.
Ordinary task entry does not inspect or configure the client.

## One owner and one pending change

| Workflow | Responsibility |
| --- | --- |
| manage-codex-config | Compose and validate the selected config change; preserve the original state, resolve concurrent edits and coordinate activation/recovery. |
| manage-restricted-storage, when present | Define approved protection roots/rules and required usability; supply that delta to the config owner and retain domain-specific activation/qualification. |
| Git workflows | Use GIT_TRANSPORT.md for the qualified command route; a config recommendation supplies no Git authority. |

Calls from setup/storage continue within their authorized scope, without a new
chat or recursive call back into the caller. Reuse an existing pending transaction
and recovery checkpoint. For selected configuration/storage work, combine compatible settings
and the approved profile delta before applying or restarting. If nothing needs
changing, leave the file absent or unchanged. Initialization is complete; retained
setup documents are provenance, and retired setup skills stay absent.

## Scope, trust and precedence

Trusted project layers apply from the project root toward the working directory;
nearer layers override broader ones. CLI overrides outrank project layers, followed
by selected user config-profile files, user defaults, cloud-managed defaults,
system defaults and built-ins. Enforced requirements constrain these defaults.
An untrusted project does not load its project config. Do not grant trust or read
user/global settings merely to complete this workflow; request only relevant
approved metadata when effective precedence is unclear.
[Configuration basics](https://learn.chatgpt.com/docs/config-file/config-basic)

Resolve relative config paths against the declaring `.codex` directory. User
config-profile files selected by `--profile` are different from the project's
`permissions.<name>` tables. Project-local config cannot set provider/auth routing,
notification/telemetry commands or config-profile selection. The documented ignored
keys include `model_provider`, `model_providers`, `openai_base_url`,
`chatgpt_base_url`, `apps_mcp_product_sku`, `notify`, `profile`, `profiles`,
`experimental_realtime_ws_base_url` and `otel`. Report such a request for separate
user/admin configuration; do not silently move it into a global file.
[Advanced configuration](https://learn.chatgpt.com/docs/config-file/config-advanced)

## Choose only settings the project needs

This is a decision map, not a preset or a frozen supported-key list. Check the
current official reference and the actual client for each selected key.

| Setting area | Project approach |
| --- | --- |
| Model, reasoning and response preferences | Preserve the maintainer's model/effort baseline. Pin only a requested project need supported by its client/account; no source-template model pin. |
| Approval policy and reviewer | Apply the recommendation below; retain existing preferences and supported granular prompt categories. |
| Filesystem and command networking | Use the local storage design and approved workspace roots; preserve existing denies/networking and the selected permission profile. |
| Web search, apps, MCP and plugins | Choose only required capabilities, recipients and tool scope. Configuration does not authorize installation, authentication, connections or transmission. |
| Instructions, project-root detection and context limits | Keep AGENTS.md and the project anchor authoritative; no alternate instruction file or reduced context limit without a concrete selected need. |
| Shell environment, hooks and agent roles | Review execution, secret inheritance and output before enabling; no automatic hook execution, delegated work or environment dumps. |
| Feature flags and runtime-specific options | Leave unchanged unless a demonstrated need and current support justify the exact option. |
| User/admin-owned settings | Report out-of-scope provider/auth, trust, telemetry, global profiles and managed requirements; make no automatic migration. |

The reference covers these settings, including model-dependent effort levels,
per-tool controls and execution-related options. Availability is client-specific;
a documented key or valid TOML does not prove live support.
[Configuration reference](https://learn.chatgpt.com/docs/config-file/config-reference)

## Approval reviewer recommendation

For a new project, recommend the following top-level delta when compatible with
the maintainer's choice and enforced requirements:

```toml
approval_policy = "on-request"
approvals_reviewer = "auto_review"
```

Merge it above any TOML table declaration or edit existing root keys; appending
these lines inside a permissions table would change their meaning. Preserve an
existing eligible granular policy rather than replacing it with `on-request`.
Keep an explicit `user` preference unless its change is authorized. Unsupported
or managed-disallowed Auto-review remains unavailable; never replace it with
`never`, full access or relaxed protection to avoid prompts.

Auto-review handles eligible interactive approval requests. An operation already
permitted inside the sandbox need not generate one, and `never` supplies none.
Reviewer choice changes neither file protection nor maintainer action authority.
App/tool-specific overrides can differ; an observed shell approval does not prove
every tool uses the same reviewer. Keep reviewer selection separate from policy
replacement; do not install `[auto_review].policy` as part of this recommendation.
[Auto-review](https://learn.chatgpt.com/docs/sandboxing/auto-review)

Named permission profiles use `permissions.<name>` and `default_permissions`.
Do not combine a new legacy sandbox override with a custom profile blindly.
Retain the intended parent, safe roots, deny rules and existing network policy;
confirm the actual selected profile after activation. Command-network access,
domain restrictions and other tool surfaces have different enforcement scopes.
[Permissions](https://learn.chatgpt.com/docs/permissions)

## Prepare, apply and recover

1. Establish the repository, exact config path, client/device and selected keys.
   Read only authorized non-sensitive config; if settings contain protected
   bindings or secrets, the operator handles those values and returns approved
   metadata. Never dump configuration, environment or credentials into chat.
2. Retain the original file bytes or absence, the relevant active selection and
   the approved before/after delta. Use one ignored local checkpoint, normally
   `CODEX_CONFIG.local.md`, with owned backup/candidate paths under
   `.codex/config-recovery/`. Reuse an existing approved storage recovery record
   instead of making a second owner. Ignore status is not access protection.
3. Prepare a minimal candidate preserving comments, unrelated keys and tables.
   Parse the complete candidate with an existing TOML-capable tool; check selected
   keys against current documentation/client support, managed constraints and
   effective-layer evidence. A parse pass proves syntax only. Avoid running a
   client just to parse a file if startup could launch hooks, MCP or network work.
4. Review the exact delta and recovery plan. Reuse applicable action authority;
   ask only for missing authority after the change is concrete. For changes that
   could lose startup/tool access, establish the existing bounded independent
   recovery route first. A backup alone cannot recover a locked-out session.
5. Immediately before writing, compare the target's exact current bytes/existence
   to the prepared baseline. If changed, stop that write, reconcile only the
   selected keys and revalidate the candidate. Preserve concurrent edits. Apply
   the narrow reviewed patch with required `.codex` execution approval; verify
   the resulting full file and selected semantic diff without disclosing values.
6. Roll back automatically only through an already authorized recovery route
   whose expected post-change state still matches. Restore original bytes or
   prior absence only in that case. On concurrent changes, retain both states
   and reconcile the owned delta; never overwrite or delete the whole new file.
   Recheck the restored configuration and original usable scope after activation.

A checkpoint needs only the exact task/scope, original-state reference, selected
keys and rationale, expected candidate reference, caller, recovery owner,
activation/evidence state and next step. Keep sensitive values outside readable
state. Resume without replacing the original backup or repeating completed work.

## Activate and report

Record separately: prepared, saved, active and behavior-verified (or pending).
For protection-profile changes retain the local full Desktop restart and fresh
ordinary-tool check required by the storage workflow. Combine compatible changes
into that same restart. For other settings use the supported client reload or
next-run behavior and verify only the affected capability; do not create a new
chat or restart solely to make a status field look complete.

Use supported status/config diagnostics or supplied effective session metadata
without dumping private layers. For reviewer verification, observe an eligible,
already authorized operation requiring review. No prompt for an allowed action
is inconclusive. If no such operation is needed, record reviewer behavior as
NOT_TESTED; do not create a remote write or change permissions just to elicit it.
Keep file/profile activation evidence independent and retain failed results.
Reassess only changed client/profile/settings; no recurring full config audit.

## Domain boundary

Preserve the project toolchain and reviewed hooks/environment; configuration does not authorize installation or operational tests.
