# Template synchronization state

## Sync-state storage

TEMPLATE_SYNC.md is the sole durable owner of source revisions, baseline/overlay
evidence, selected outcomes and reconsideration conditions. Keep that evidence
here, including the source snapshots below. Do not create a template-sync/
directory or separate JSON manifest in this project. Temporary comparison work
is disposable and must not be required to reconstruct the recorded sync state.
This storage correction changes no adoption checkpoint or project authority.

## Comparison and adoption

- Verified source: https://github.com/ctreffe/ai-template-dev.
- Initial project provenance: [PROJECT_CONTEXT.md](PROJECT_CONTEXT.md).
- Previous full comparison: `d782a842cc5733d34c60a6bce39ddca5a65a9b64`; later selected follow-ups were reviewed again.
- Last compared upstream commit/date: `a5044248b894a87a86ab64c1cb9afd659ffa5f8b` / 2026-11-08; clean local source.
- Latest selected adoption checkpoint: `a5044248b894a87a86ab64c1cb9afd659ffa5f8b`; NOV08 ongoing-workflow outcomes independently validated on 2026-11-08.
- Fully resolved through: `a5044248b894a87a86ab64c1cb9afd659ffa5f8b` for compared source changes, adopted/adapted or deliberately rejected below; no deferred/conflicting adoption item remains.
- [Pre-sync lineage, earlier selections, domain evidence and limitations](https://github.com/ctreffe/agit-windows-bootprofile-switcher/blob/52bfb1080a6871ef8ca55a8a52eb4568532a3dfd/TEMPLATE_SYNC.md).
  No unresolved deferred/conflicting adoption item was carried from that record;
  deferred operational/domain tests remain open, not new template-adoption evidence.

## Change outcomes

All rows compare `d782a842cc5733d34c60a6bce39ddca5a65a9b64` through `08ed8c62ae085a803ad9426ec5ca2d629826cfbc` and recheck intervening selected
follow-ups. Applied outcomes are supported by the validation checkpoint below.

| Change ID | Source path/concept | Outcome | Local application or reason | Next review condition |
| --- | --- | --- | --- | --- |
| SYNC-001 | `AGENTS.md` | adapted | Selected source delta applied with local project rules preserved, or already present from earlier recorded follow-ups. | Next source delta or changed local rule. |
| SYNC-002 | `CHANGELOG.md` | rejected | Project identity/history and completed initialization remain authoritative; no source release metadata, source task or initialization is copied. | New initialization or a separately selected project release/scope change. |
| SYNC-003 | `COLLABORATION.md` | adopted | Selected source delta applied with local project rules preserved, or already present from earlier recorded follow-ups. | Next source delta or changed local rule. |
| SYNC-004 | `PROJECT_CONTEXT.md` | adapted | Selected source delta applied with local project rules preserved, or already present from earlier recorded follow-ups. | Next source delta or changed local rule. |
| SYNC-005 | `PROJECT_SETUP.md` | rejected | Project identity/history and completed initialization remain authoritative; no source release metadata, source task or initialization is copied. | New initialization or a separately selected project release/scope change. |
| SYNC-006 | `README.de.md` | adapted | Selected source delta applied with local project rules preserved, or already present from earlier recorded follow-ups. | Next source delta or changed local rule. |
| SYNC-007 | `README.md` | adapted | Selected source delta applied with local project rules preserved, or already present from earlier recorded follow-ups. | Next source delta or changed local rule. |
| SYNC-008 | `REPOSITORY.md` | adopted | Selected source delta applied with local project rules preserved, or already present from earlier recorded follow-ups. | Next source delta or changed local rule. |
| SYNC-009 | `SYNCHRONIZED_STORAGE.md` | adapted | Selected source delta applied with local project rules preserved, or already present from earlier recorded follow-ups. | Next source delta or changed local rule. |
| SYNC-010 | `TASK_HANDOFF.md` | rejected | Project identity/history and completed initialization remain authoritative; no source release metadata, source task or initialization is copied. | New initialization or a separately selected project release/scope change. |
| SYNC-011 | `TEMPLATE_SYNC.md` | adapted | Selected source delta applied with local project rules preserved, or already present from earlier recorded follow-ups. | Next source delta or changed local rule. |
| SYNC-012 | `VALIDATION.md` | adapted | Selected source delta applied with local project rules preserved, or already present from earlier recorded follow-ups. | Next source delta or changed local rule. |
| SYNC-013 | `VERSION` | rejected | Project identity/history and completed initialization remain authoritative; no source release metadata, source task or initialization is copied. | New initialization or a separately selected project release/scope change. |
| SYNC-014 | `input/README.md` | adapted | Selected source delta applied with local project rules preserved, or already present from earlier recorded follow-ups. | Next source delta or changed local rule. |
| SYNC-015 | `materials/README.md` | adapted | Selected source delta applied with local project rules preserved, or already present from earlier recorded follow-ups. | Next source delta or changed local rule. |
| SYNC-016 | `scripts/Test-ExternalStorage.ps1` | adapted | Selected source delta applied with local project rules preserved, or already present from earlier recorded follow-ups. | Next source delta or changed local rule. |
| SYNC-017 | `scripts/Test-ExternalStorageHelper.ps1` | adapted | Selected source delta applied with local project rules preserved, or already present from earlier recorded follow-ups. | Next source delta or changed local rule. |
| SYNC-018 | `templates/RESEARCH_REPORT.md` | adapted | Selected source delta applied with local project rules preserved, or already present from earlier recorded follow-ups. | Next source delta or changed local rule. |
| SKILLS | Full active skill-directory and metadata inventory | adapted | Current ongoing skills and explicit-only question research; local boundaries retained. Retired initialization/creation skills and aliases stay absent. | Next source skill change; preserve local-only skills. |
| INIT | Source start-project/create-local-project changes | rejected | Project initialization is complete; retained setup is provenance, not an ongoing executable workflow. | Only a separately authorized new project initialization. |
| STORAGE | Existing canonical mappings/manifests | adapted | Simplified layout applies to new approved areas; no existing file, marker, manifest or host mapping migrated. | Explicit storage migration or changed access/provider decision. |

## Local adaptations and evidence

- Research is explicit-only; reports and generated data are unversioned by default.
- Existing project READMEs, version, release history, license and domain safeguards remain unchanged.
- Project context points here for synchronization state; historical observations remain labeled historical.
- No research, live cloud check, private-input render or operational/device test is implied.

At the next sync compare new changes AND every deferred/conflicting item from its
original baseline. Revisit rejected items only when their condition applies.

## Validation checkpoint — 2026-10-19

- 4 changed skills passed the local Test-CodexSkill.ps1 wrapper with an
  existing pinned Python/PyYAML runtime; no installation or dependency change.
- Test-ExternalStorageHelper.ps1 passed 28 synthetic assertions under each of
  PowerShell 7 and Windows PowerShell 5.1 (56 total). The 5.1 process explicitly
  imported its installed Utility module after an autoload failure; no host repair.
- 108 selected local Markdown targets checked; no broken target or
  unresolved inspected anchor. Targeted English/German guide meaning and structure
  reviewed; project README pair and content sources remain unchanged.
- YAML syntax, explicit-only research metadata, full active skill inventory,
  retired initialization absence and ignored research/mapping/catalog paths checked.
- Added missing generic input/material guides, catalogs, mapping examples and
  ignore coverage needed by research; no host input or cloud area selected.

Full milestone/build/render/visual/domain tests, actual cloud convergence and
receiving-device/backup checks remain outside this ordinary workflow sync.
Existing pending document/device/production evidence is not completed by these tests.

## Selected synchronization — 2026-11-03

Status: completed for the selected source-workflow adoption, with the
independent focused evidence below. Operational/domain limits remain separate.

The maintainer selected the current local source with project adaptations.
Compared from `08ed8c62ae085a803ad9426ec5ca2d629826cfbc` through source HEAD `65a4f1bc036936ea19195560c77474c5786716f2`.
The working-tree overlay is not a commit. Snapshot: `ba85bbfe3c6929325e1c9195f8ae2bf1b36f89cb47b3051a6252dc937d21d9dc`.
The [source snapshot 2026-11-03](#source-snapshot-2026-11-03) records its
LF-normalized hashes and complete source-delta paths. No fetch or remote
freshness claim is included.

| Change ID | Source path/concept | Outcome | Local application or reason | Review condition |
| --- | --- | --- | --- | --- |
| NOV03-001 | `.agents/skills/manage-restricted-storage/SKILL.md` | adopted | Verified source delta; project-specific boundaries retained. | Next source or local-rule change. |
| NOV03-002 | `.agents/skills/manage-restricted-storage/agents/openai.yaml` | adopted | Verified source delta; project-specific boundaries retained. | Next source or local-rule change. |
| NOV03-003 | `.agents/skills/manage-restricted-storage/references/codex-permissions.md` | adopted | Verified source delta; project-specific boundaries retained. | Next source or local-rule change. |
| NOV03-004 | `.agents/skills/perform-retrospective/SKILL.md` | adapted | Verified source delta; project-specific boundaries retained. | Next source or local-rule change. |
| NOV03-005 | `.agents/skills/record-idea/SKILL.md` | adopted | Verified source delta; project-specific boundaries retained. | Next source or local-rule change. |
| NOV03-006 | `.agents/skills/record-idea/agents/openai.yaml` | adopted | Verified source delta; project-specific boundaries retained. | Next source or local-rule change. |
| NOV03-007 | `.agents/skills/review-code/SKILL.md` | adopted | Verified source delta; project-specific boundaries retained. | Next source or local-rule change. |
| NOV03-008 | `.agents/skills/review-code/agents/openai.yaml` | adopted | Verified source delta; project-specific boundaries retained. | Next source or local-rule change. |
| NOV03-009 | `.agents/skills/setup-test-environment/SKILL.md` | adopted | Verified source delta; project-specific boundaries retained. | Next source or local-rule change. |
| NOV03-010 | `.agents/skills/start-project/SKILL.md` | rejected | Initialization is complete; retained setup stays provenance. | Next source or local-rule change. |
| NOV03-011 | `.agents/skills/sync-template/SKILL.md` | adopted | Verified source delta; project-specific boundaries retained. | Next source or local-rule change. |
| NOV03-012 | `.agents/skills/test-code/SKILL.md` | adopted | Verified source delta; project-specific boundaries retained. | Next source or local-rule change. |
| NOV03-013 | `.agents/skills/test-code/agents/openai.yaml` | adopted | Verified source delta; project-specific boundaries retained. | Next source or local-rule change. |
| NOV03-014 | `.gitignore` | adapted | Project-specific ongoing guidance/catalog integration; local authority retained. | Next source or local-rule change. |
| NOV03-015 | `AGENTS.md` | adapted | Project-specific ongoing guidance/catalog integration; local authority retained. | Next source or local-rule change. |
| NOV03-016 | `CHANGELOG.md` | rejected | Keep project-owned history and continuation; record this sync locally. | Next source or local-rule change. |
| NOV03-017 | `COLLABORATION.md` | adapted | Project-specific ongoing guidance/catalog integration; local authority retained. | Next source or local-rule change. |
| NOV03-018 | `DOCUMENTATION.md` | adapted | Project-specific ongoing guidance/catalog integration; local authority retained. | Next source or local-rule change. |
| NOV03-019 | `IDEAS.md` | rejected | Never import source-template entries; preserve/create project-owned backlog separately. | Next source or local-rule change. |
| NOV03-020 | `PROJECT_SETUP.md` | rejected | Initialization is complete; retained setup stays provenance. | Next source or local-rule change. |
| NOV03-021 | `README.de.md` | adapted | Project-specific ongoing guidance/catalog integration; local authority retained. | Next source or local-rule change. |
| NOV03-022 | `README.md` | adapted | Project-specific ongoing guidance/catalog integration; local authority retained. | Next source or local-rule change. |
| NOV03-023 | `REPOSITORY.md` | adapted | Project-specific ongoing guidance/catalog integration; local authority retained. | Next source or local-rule change. |
| NOV03-024 | `RESTRICTED_STORAGE.md` | adopted | Verified source delta; project-specific boundaries retained. | Next source or local-rule change. |
| NOV03-025 | `RETROSPECTIVE_PATHS.example.md` | adapted | Verified source delta; project-specific boundaries retained. | Next source or local-rule change. |
| NOV03-026 | `SYNCHRONIZED_STORAGE.md` | adapted | Verified source delta; project-specific boundaries retained. | Next source or local-rule change. |
| NOV03-027 | `TASK_HANDOFF.md` | rejected | Keep project-owned history and continuation; record this sync locally. | Next source or local-rule change. |
| NOV03-028 | `templates/IDEAS.md` | adopted | Verified source delta; project-specific boundaries retained. | Next source or local-rule change. |
| NOV03-029 | `templates/RESTRICTED_CATALOG.md` | adopted | Verified source delta; project-specific boundaries retained. | Next source or local-rule change. |
| NOV03-030 | `templates/RESTRICTED_STORAGE.local.example.md` | adopted | Verified source delta; project-specific boundaries retained. | Next source or local-rule change. |
| NOV03-031 | `templates/TEST_ENVIRONMENT.md` | adopted | Verified source delta; project-specific boundaries retained. | Next source or local-rule change. |
| NOV03-032 | `templates/TEST_REPORT.md` | adopted | Verified source delta; project-specific boundaries retained. | Next source or local-rule change. |
| NOV03-IDEAS | Project-owned IDEAS.md and stable IDs | adapted | New empty backlog where absent; existing entries preserved. No source-template idea import. | Clear local idea-capture request or changed ownership. |
| NOV03-INVENTORY | All skill directories and invocation metadata | adapted | Preserve local-only/project-owned methods; completed creation/initialization definitions stay absent. | New source/local skill delta. |

No earlier deferred/conflicting adoption item was found in the current ledger.
Earlier deliberate rejections remain history: source release/task/version
metadata and completed initialization are still excluded. The newly selected
project backlog changes only the old assumption that no local idea intake was
needed; template-owned entries remain rejected.

Preserve CODEX.md and boot/account/service/registry/rollback safeguards.
Do not execute host-changing helpers or inspect device-bound logs/state for ideas.

Operational/domain evidence and pending project work are unchanged. This sync
does not start tests, services, storage setup, data processing or publication.

### Independent validation — 2026-11-03

- 7 changed/new skills passed this project's `scripts/Test-CodexSkill.ps1`
  wrapper with the existing managed Governance Python and pinned PyYAML 6.0.3.
  No environment or package was installed.
- Full ongoing skill topology and invocation-policy comparison passed,
  preserving documented project-owned exceptions and local-only skills.
- Both focused intake/reflection source contracts passed. These are instruction
  and structural checks, not a live retrospective or automatic-routing trial.
- Markdown links: 219 local target(s) across 28 file(s).
- 3 local target(s) remain unverified by scope or access policy.
- Both README pairs retain aligned heading hierarchies; targeted bilingual
  meaning, catalog availability, role/navigation and rights were reviewed.
- Hash checks confirm the exact edit plan, preserved untargeted control files,
  unchanged existing idea entries, retained project continuation and local-only
  skills. HEAD, branch, worktree list and empty staging stayed unchanged.

No real/sensitive data, conversation, catalog contents, private mapping or
operational state was inspected. No real initialization, storage setup, runtime
test, installation, cloud operation, publication or protected Git action ran.
Full project/domain/release/milestone and family gates were not run except the
explicitly required static local gate above. Existing operational evidence gaps
remain project-owned and are not adoption blockers for these source methods.
No selected source-workflow implementation remains.

## Source snapshot 2026-11-03

Source evidence retained in this ledger; no separate manifest is required.

| Field | Value |
| --- | --- |
| `source_repository` | ai-template-dev |
| `source_head` | 65a4f1bc036936ea19195560c77474c5786716f2 |
| `compared_from` | 08ed8c62ae085a803ad9426ec5ca2d629826cfbc |
| `source_snapshot_sha256` | ba85bbfe3c6929325e1c9195f8ae2bf1b36f89cb47b3051a6252dc937d21d9dc |
| `hash_convention` | SHA-256 of UTF-8 text without BOM, CRLF normalized to LF |
| `note` | Local source snapshot; no remote freshness, commit or release is implied. |

### source working tree overlay

| Source path | SHA-256 / value |
| --- | --- |
| `.agents/skills/perform-retrospective/SKILL.md` | `84c020c5f69a68f0385a3d8926bb5ccd2bbe192a64952dcbe7de28368e8909eb` |
| `.agents/skills/record-idea/SKILL.md` | `ab7ac5b6ff22d93c4fd862ee197c270ea8538ffbf4ae6db84dcf40d11bebf76c` |
| `.agents/skills/record-idea/agents/openai.yaml` | `8619a54e8c098122a7f3881394f84ca89b684366e848233a29ad18b6ec363935` |
| `.agents/skills/start-project/SKILL.md` | `84061f4d62e6eb9f899370c5a88204c77d101530c1654fe9ca87fbeb35d1a057` |
| `.agents/skills/sync-template/SKILL.md` | `3183117c9369bebf52f44f4c057de3cd6579d04ba2441106b7b339773fd5a719` |
| `AGENTS.md` | `09431ea758f78d5b0f3af6b67793f397ce7b8de51bf1fef8fa21afa9dbda7b79` |
| `CHANGELOG.md` | `7e89aaa2fe2ece4c654a23e8d116de982787ab902a6589c0db305b9f1d412d06` |
| `COLLABORATION.md` | `9b862f4d97758fc7323cb5e70f21b2d860ef91dd71ddf5c3b909b6b3079ed759` |
| `IDEAS.md` | `b304112ad02ecea877c7d65b98b4101f7e894e3b8358d5ce14e1b2633f4c3bb7` |
| `PROJECT_SETUP.md` | `80cbbb3467d7c4a8610c2a41fd36ea896c392f3f49fb6122f6c7269cc85e1caf` |
| `README.de.md` | `202fb468871395c18621f8966c5ee99614cd0eda1b6376f393df70b54e433b0e` |
| `README.md` | `74329066ca173fb618d0e0dd7e80314300f864644395aa53fb64ce7eb942e22f` |
| `RETROSPECTIVE_PATHS.example.md` | `c50e5eb14db0e60dcef596d540f793b6d0daa19277889b0a95bc0568803aef25` |
| `TASK_HANDOFF.md` | `e0ed95f3a8b0fb8ddfcc88130a627354f992f52cab3392f239cd1d447108ed7e` |
| `templates/IDEAS.md` | `d54757310e2c131bf2ff9b8eb2dbf8c5538a73318dee4887e179aac71f7eee35` |

### source delta

| Order | Source path / value |
| --- | --- |
| 1 | `.agents/skills/manage-restricted-storage/SKILL.md` |
| 2 | `.agents/skills/manage-restricted-storage/agents/openai.yaml` |
| 3 | `.agents/skills/manage-restricted-storage/references/codex-permissions.md` |
| 4 | `.agents/skills/perform-retrospective/SKILL.md` |
| 5 | `.agents/skills/record-idea/SKILL.md` |
| 6 | `.agents/skills/record-idea/agents/openai.yaml` |
| 7 | `.agents/skills/review-code/SKILL.md` |
| 8 | `.agents/skills/review-code/agents/openai.yaml` |
| 9 | `.agents/skills/setup-test-environment/SKILL.md` |
| 10 | `.agents/skills/start-project/SKILL.md` |
| 11 | `.agents/skills/sync-template/SKILL.md` |
| 12 | `.agents/skills/test-code/SKILL.md` |
| 13 | `.agents/skills/test-code/agents/openai.yaml` |
| 14 | `.gitignore` |
| 15 | `AGENTS.md` |
| 16 | `CHANGELOG.md` |
| 17 | `COLLABORATION.md` |
| 18 | `DOCUMENTATION.md` |
| 19 | `IDEAS.md` |
| 20 | `PROJECT_SETUP.md` |
| 21 | `README.de.md` |
| 22 | `README.md` |
| 23 | `REPOSITORY.md` |
| 24 | `RESTRICTED_STORAGE.md` |
| 25 | `RETROSPECTIVE_PATHS.example.md` |
| 26 | `SYNCHRONIZED_STORAGE.md` |
| 27 | `TASK_HANDOFF.md` |
| 28 | `templates/IDEAS.md` |
| 29 | `templates/RESTRICTED_CATALOG.md` |
| 30 | `templates/RESTRICTED_STORAGE.local.example.md` |
| 31 | `templates/TEST_ENVIRONMENT.md` |
| 32 | `templates/TEST_REPORT.md` |

## Source snapshot 2026-11-08

- Source repository: ai-template-dev, version 1.8.0.
- Exact source commit: `a5044248b894a87a86ab64c1cb9afd659ffa5f8b`.
- Source working-tree overlay: none; selected source was clean.
- Previous comparison: `65a4f1bc036936ea19195560c77474c5786716f2` plus the
  [2026-11-03 overlay evidence](#source-snapshot-2026-11-03) retained above.
- The committed revision and per-path outcomes reproduce the scope; required
  overlay hashes remain in this ledger. No JSON manifest or extra template-sync/
  folder is created. This comparison makes no remote freshness claim.

## Selected synchronization — 2026-11-08

Status: completed for the maintainer-selected ongoing-workflow package.

Earlier outcomes, exclusions and historical source evidence remain intact.
Project is the historical seed; Dev remains the selected ongoing source.
No missing initial commit or setup provenance is invented. Selected adoption
advances after independent validation; rejected source deltas are deliberately
resolved. Domain evidence gaps below remain open.

| Change ID | Source path/concept | Outcome | Local application or reason | Next review condition |
| --- | --- | --- | --- | --- |
| NOV08-001 | `.agents/skills/commit-changes/SKILL.md` | adopted | Selected ongoing source method; local domain and authority boundaries retained. | Next source delta or changed local rule; initialization stays separately selected. |
| NOV08-002 | `.agents/skills/commit-milestone/SKILL.md` | adopted | Selected ongoing source method; local domain and authority boundaries retained. | Next source delta or changed local rule; initialization stays separately selected. |
| NOV08-003 | `.agents/skills/manage-codex-config/SKILL.md` | adapted | Config ownership/usability retains CODEX.md, host-operation and device-state boundaries; omit completed initialization. | Next source delta or changed local rule; initialization stays separately selected. |
| NOV08-004 | `.agents/skills/manage-codex-config/agents/openai.yaml` | adopted | Selected ongoing source method; local domain and authority boundaries retained. | Next source delta or changed local rule; initialization stays separately selected. |
| NOV08-005 | `.agents/skills/manage-restricted-storage/SKILL.md` | adapted | Config ownership/usability retains CODEX.md, host-operation and device-state boundaries; omit completed initialization. | Next source delta or changed local rule; initialization stays separately selected. |
| NOV08-006 | `.agents/skills/manage-restricted-storage/assets/native_git_ssh.cs` | adopted | Selected ongoing source method; local domain and authority boundaries retained. | Next source delta or changed local rule; initialization stays separately selected. |
| NOV08-007 | `.agents/skills/manage-restricted-storage/references/codex-permissions.md` | adopted | Selected ongoing source method; local domain and authority boundaries retained. | Next source delta or changed local rule; initialization stays separately selected. |
| NOV08-008 | `.agents/skills/manage-restricted-storage/references/profile-usability.md` | adopted | Selected ongoing source method; local domain and authority boundaries retained. | Next source delta or changed local rule; initialization stays separately selected. |
| NOV08-009 | `.agents/skills/perform-retrospective/SKILL.md` | adapted | Selected ongoing source method; local domain and authority boundaries retained. | Next source delta or changed local rule; initialization stays separately selected. |
| NOV08-010 | `.agents/skills/record-decision/SKILL.md` | adopted | Selected ongoing source method; local domain and authority boundaries retained. | Next source delta or changed local rule; initialization stays separately selected. |
| NOV08-011 | `.agents/skills/reuse-fixes/SKILL.md` | adopted | Selected ongoing source method; local domain and authority boundaries retained. | Next source delta or changed local rule; initialization stays separately selected. |
| NOV08-012 | `.agents/skills/review-project/SKILL.md` | adopted | Selected ongoing source method; local domain and authority boundaries retained. | Next source delta or changed local rule; initialization stays separately selected. |
| NOV08-013 | `.agents/skills/start-project/SKILL.md` | rejected | Preserve identity/history and completed initialization; no source release/task/idea or setup scaffold import. | Next source delta or changed local rule; initialization stays separately selected. |
| NOV08-014 | `.agents/skills/sync-template/SKILL.md` | adapted | Durable source/overlay evidence stays in TEMPLATE_SYNC.md without JSON manifests or a template-sync folder. | Next source delta or changed local rule; initialization stays separately selected. |
| NOV08-015 | `.gitignore` | adapted | Ignore local config/recovery and Git route state plus temp contents; retain public temp/README.md. | Next source delta or changed local rule; initialization stays separately selected. |
| NOV08-016 | `AGENTS.md` | adapted | Selected ongoing source method; local domain and authority boundaries retained. | Next source delta or changed local rule; initialization stays separately selected. |
| NOV08-017 | `CHANGELOG.md` | rejected | Preserve identity/history and completed initialization; no source release/task/idea or setup scaffold import. | Next source delta or changed local rule; initialization stays separately selected. |
| NOV08-018 | `CODEX_CONFIGURATION.md` | adapted | Selected ongoing source method; local domain and authority boundaries retained. | Next source delta or changed local rule; initialization stays separately selected. |
| NOV08-019 | `COLLABORATION.md` | adapted | Selected ongoing source method; local domain and authority boundaries retained. | Next source delta or changed local rule; initialization stays separately selected. |
| NOV08-020 | `COMMIT_PACKAGES.md` | adopted | Selected ongoing source method; local domain and authority boundaries retained. | Next source delta or changed local rule; initialization stays separately selected. |
| NOV08-021 | `DOCUMENTATION.md` | adapted | Selected ongoing source method; local domain and authority boundaries retained. | Next source delta or changed local rule; initialization stays separately selected. |
| NOV08-022 | `GIT_TRANSPORT.md` | adopted | Selected ongoing source method; local domain and authority boundaries retained. | Next source delta or changed local rule; initialization stays separately selected. |
| NOV08-023 | `PHILOSOPHY.md` | adapted | Append inherited Dev mission while retaining the full local engineering philosophy and maintainer mission ownership. | Next source delta or changed local rule; initialization stays separately selected. |
| NOV08-024 | `PROJECT_CONTEXT.md` | rejected | Preserve identity/history and completed initialization; no source release/task/idea or setup scaffold import. | Next source delta or changed local rule; initialization stays separately selected. |
| NOV08-025 | `PROJECT_SETUP.md` | rejected | Preserve identity/history and completed initialization; no source release/task/idea or setup scaffold import. | Next source delta or changed local rule; initialization stays separately selected. |
| NOV08-026 | `README.de.md` | adapted | Mapped to TEMPLATE_README.de.md under DDR-0001; preserve introductions, local inventory, licensing and boot/runtime safeguards. | Next source delta or changed local rule; initialization stays separately selected. |
| NOV08-027 | `README.md` | adapted | Mapped to TEMPLATE_README.md under DDR-0001; preserve introductions, local inventory, licensing and boot/runtime safeguards. | Next source delta or changed local rule; initialization stays separately selected. |
| NOV08-028 | `REPOSITORY.md` | adapted | Keep module/runtime/config/test paths and device-state boundaries; no file migration or host operation. | Next source delta or changed local rule; initialization stays separately selected. |
| NOV08-029 | `RESTRICTED_STORAGE.md` | adopted | Selected ongoing source method; local domain and authority boundaries retained. | Next source delta or changed local rule; initialization stays separately selected. |
| NOV08-030 | `SYNCHRONIZED_STORAGE.md` | adapted | Selected ongoing source method; local domain and authority boundaries retained. | Next source delta or changed local rule; initialization stays separately selected. |
| NOV08-031 | `TASK_HANDOFF.md` | rejected | Preserve identity/history and completed initialization; no source release/task/idea or setup scaffold import. | Next source delta or changed local rule; initialization stays separately selected. |
| NOV08-032 | `VERSION` | rejected | Preserve identity/history and completed initialization; no source release/task/idea or setup scaffold import. | Next source delta or changed local rule; initialization stays separately selected. |
| NOV08-033 | `temp/README.md` | adopted | Selected ongoing source method; local domain and authority boundaries retained. | Next source delta or changed local rule; initialization stays separately selected. |
| NOV08-034 | `templates/RESTRICTED_STORAGE.local.example.md` | adopted | Selected ongoing source method; local domain and authority boundaries retained. | Next source delta or changed local rule; initialization stays separately selected. |
| NOV08-035 | `.agents/skills/record-idea/SKILL.md` | already present | Unchanged from the previous adopted source overlay. | Next source delta or changed local rule; initialization stays separately selected. |
| NOV08-036 | `.agents/skills/record-idea/agents/openai.yaml` | already present | Unchanged from the previous adopted source overlay. | Next source delta or changed local rule; initialization stays separately selected. |
| NOV08-037 | `IDEAS.md` | already present | Unchanged from the previous adopted source overlay. | Next source delta or changed local rule; initialization stays separately selected. |
| NOV08-038 | `RETROSPECTIVE_PATHS.example.md` | already present | Unchanged from the previous adopted source overlay. | Next source delta or changed local rule; initialization stays separately selected. |
| NOV08-039 | `templates/IDEAS.md` | already present | Unchanged from the previous adopted source overlay. | Next source delta or changed local rule; initialization stays separately selected. |

### Local boundaries

PDR-0003 and CODEX.md retain local execution, network, private-transmission and
host-operation safeguards. Boot, account, service, registry and rollback controls
remain binding. No elevation, host-changing script, real-system test or access
to device-bound logs, backups, state or discovery inventories follows from
configuration/profile usability. Only separately approved sanitized fixtures
may be used. Modules, installed runtime, configuration and config/test paths
remain unchanged. No document/runtime migration was needed or performed.

Initialization is complete. PROJECT_SETUP.md and INITIAL_PROMPT.md remain absent.
No actual configuration, profile or adapter was created or activated. Temporary
worktree placement now has matching ignore coverage, preserving temp/README.md;
no worktree was created, inspected internally or removed.

### Independent validation — 2026-11-08

- Nine changed/new skills passed scripts/Test-CodexSkill.ps1 with the established
  exact interpreter and pinned PyYAML 6.0.3; no installation.
- All 20 skills were inventoried, including new manage-codex-config. Fourteen
  YAML metadata files and six intentional omissions match source invocation
  policy. Retired initialization/creation skills and aliases remain absent.
- Both README language pairs retain aligned headings; bilingual additions and
  complete skill catalogs were reviewed. Unselected skills retain their hashes.
- Before finalization, 264 permitted local links/anchors and all 28 implementation
  readbacks passed; six references remained outside generic link scope. Fourteen
  selected identity/context/history/license/config/policy/roadmap/provenance
  files or absence states retain their hashes.
- Source/diff review covered config ownership, Git/commit packages, mission and
  writing, temporary worktrees, local paths and operational access gates.
  Live Git inspection confirmed the selected scope and unchanged HEAD/staging;
  git check-ignore confirmed local temporary work/worktree container coverage.

The final ledger/handoff receive focused readback/link verification. No runtime
code was changed and no host operation or device-bound content inspection was
performed. Real deployment/restore and v1.8.0 policy/vendor discovery evidence
remain separately controlled and incomplete. Runtime tests, whitespace and full
engineering/family/milestone gates were not required for this bounded workflow
update and were not run. No protected Git action or publication occurred.
This sync closes no project milestone or operational evidence gap.
