---
name: manage-codex-config
description: Create, review or change a project's custom .codex/config.toml, including selected protection-profile deltas; preserve existing settings and coordinate validation, activation and conflict-safe recovery. Use for configuration requests or calls from manage-restricted-storage, not ordinary task entry, completed initialization or global configuration.
---

# Manage Codex Config

Apply local AGENTS.md and domain access rules. Follow
[CODEX_CONFIGURATION.md](../../../CODEX_CONFIGURATION.md) for the shared ownership,
setting choices, precedence, reviewer recommendation and recovery procedure.
Work on the selected project's custom `.codex/config.toml`; do not initialize a
source checkout, inspect another project or configure user/admin settings.

1. Identify the requested outcome, caller, exact target, approved readable state
   and actual client. Reuse setup answers and existing authority. Consult current
   official documentation only for the selected settings; do not import a complete
   sample config. Do not inspect secret-bearing config, global stores or protected
   paths to discover values. Resolve missing scope through approved metadata.
2. Select a minimal delta. Preserve model/reasoning preferences, existing granular
   approval rules, selected permission profile, file denies and network settings.
   For new projects recommend `auto_review` with an eligible interactive policy;
   honor explicit manual-review preferences and managed restrictions. Provider,
   trust, global profile or credential requests need their own owning scope.
3. Reuse one pending transaction for requested configuration and storage work.
   `manage-restricted-storage` supplies the approved protection delta and owns
   its qualification. Combine compatible changes before the required restart.
   Do not call back into the caller, overwrite its original backup or apply a
   competing config. Leave optional tuning deferred and no-op files untouched.
4. Prepare the exact candidate and shared recovery checkpoint. Parse the complete
   TOML, review key placement/support and effective-layer conflicts, and preserve
   comments and unrelated settings. Retain the original bytes/absence and expected
   candidate. Establish independent recovery before changes that could prevent
   startup/tool access, retaining stronger local protection requirements.
5. Apply only within existing action authority, with narrow platform approval when
   required for `.codex` writes. Recompare the current target with the prepared
   baseline immediately before editing; concurrent changes require reconciliation
   and renewed candidate validation, not overwrite. Verify the resulting file.
   On rollback, restore full bytes/absence only when expected post-change state
   matches; otherwise reconcile the owned delta without discarding new work.
6. Follow the owning client's activation procedure. Storage-profile changes retain
   its full Desktop restart and fresh ordinary-tool scope/usability check. Reuse
   that restart for combined settings. Keep saved values, active profile/reviewer
   and observed behavior separate. An allowed operation without a prompt does not
   establish Auto-review. Use an already authorized relevant operation, or report
   behavior NOT_TESTED; never invent a Git/remote write as an approval probe.
7. Return the selected delta, actual evidence, preserved state and pending work to
   the caller. Use the existing ignored recovery record, or CODEX_CONFIG.local.md
   when no owner exists; keep device bindings and protected values out of tracked
   guidance. No installation, trust grant, global change, credential provisioning,
   new chat, delegated work or publication is implied by this skill.

## Local boundary

Preserve the project toolchain and reviewed hooks/environment; configuration does not authorize installation or operational tests.

Never recreate retired setup skills or absent PROJECT_SETUP.md/INITIAL_PROMPT.md.
Preserve CODEX.md's execution, network, private-transmission and host-operation
safeguards under PDR-0003. Boot, account, service, registry and rollback rules
remain authoritative. Profile usability grants no elevation, host-changing
script, real-system test or access to device-bound logs, backups, state or
discovery inventories. Use only separately approved sanitized fixtures; real
deployment and restore evidence remains separately controlled.
