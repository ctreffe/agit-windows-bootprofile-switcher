# Template synchronization state

## Comparison and adoption

- Verified source: https://github.com/ctreffe/ai-template-dev.
- Initial project provenance: [PROJECT_CONTEXT.md](PROJECT_CONTEXT.md).
- Previous full comparison: `d782a842cc5733d34c60a6bce39ddca5a65a9b64`; later selected follow-ups were reviewed again.
- Last compared upstream commit/date: `65a4f1bc036936ea19195560c77474c5786716f2` / 2026-11-03; exact local overlay below.
- Latest selected adoption checkpoint: `65a4f1bc036936ea19195560c77474c5786716f2` plus local source snapshot `ba85bbfe3c6929325e1c9195f8ae2bf1b36f89cb47b3051a6252dc937d21d9dc`; NOV03 outcomes independently validated on 2026-11-03.
- Fully resolved through: `65a4f1bc036936ea19195560c77474c5786716f2` plus the identified local working-tree snapshot for the reviewed source delta and earlier applicable selections; deliberate rejections retained; no deferred/conflicting adoption item remains.
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
The [portable source manifest](template-sync/2026-11-03-source.json) records its
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
