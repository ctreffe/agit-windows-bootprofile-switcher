# Validation

## Codex skill validation: first use

Only prepare this Python tool dependency when a task edits a Codex skill and
needs the bundled Skill Creator validator. Prefer the project's established
manager, lockfile and isolated environment. If none is suitable, after approval
for environment creation and package download, prepare this clone's ignored
`.venv`:

```powershell
python -m venv .venv
.\.venv\Scripts\python.exe -m pip install -r requirements-tools.txt
```

Run the fixed wrapper rather than `quick_validate.py` through arbitrary Python:

```powershell
.\scripts\Test-CodexSkill.ps1 -SkillPath .\.agents\skills\start-task
```

For an existing managed environment, supply its exact interpreter path with
`-PythonPath`. Use `-ValidatorPath` only when the installed Skill Creator moved.
The wrapper checks `import yaml` and runs validation; it does not install
packages, alter global Python or change engineering, test, release or Git
authority. PyYAML is pinned in `requirements-tools.txt`; upgrades are deliberate
dependency changes.

## Exact interpreter used for this synchronization

The eight-project synchronization used the already approved, existing
Governance-managed interpreter with pinned PyYAML 6.0.3 via -PythonPath.
This does not create a project environment, change its manager or grant
installation authority. Future tasks verify their selected interpreter.
