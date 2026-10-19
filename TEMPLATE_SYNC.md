# Template synchronization state

## Comparison and adoption

- Verified source: https://github.com/ctreffe/ai-template-dev.
- Initial project provenance: [PROJECT_CONTEXT.md](PROJECT_CONTEXT.md).
- Previous full comparison: `d782a842cc5733d34c60a6bce39ddca5a65a9b64`; later selected follow-ups were reviewed again.
- Last compared upstream commit/date: `08ed8c62ae085a803ad9426ec5ca2d629826cfbc` / 2026-10-19.
- Latest selected adoption checkpoint: `08ed8c62ae085a803ad9426ec5ca2d629826cfbc`; selected outcomes below independently validated on 2026-10-19.
- Fully resolved through: `08ed8c62ae085a803ad9426ec5ca2d629826cfbc` for the recorded source delta and earlier selected follow-ups; no deferred/conflicting adoption item remains.
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
