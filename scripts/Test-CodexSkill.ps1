[CmdletBinding()]
param(
    [string[]]$SkillPath = @(),
    [string]$ValidatorPath,
    [string]$PythonPath
)

$ErrorActionPreference = 'Stop'
$repositoryRoot = Split-Path $PSScriptRoot -Parent
$selectedPython = $PythonPath
if ([string]::IsNullOrWhiteSpace($selectedPython)) {
    $selectedPython = Join-Path $repositoryRoot '.venv/Scripts/python.exe'
    if (-not (Test-Path -LiteralPath $selectedPython -PathType Leaf)) {
        $selectedPython = Join-Path $repositoryRoot '.venv/bin/python'
    }
}
if (-not (Test-Path -LiteralPath $selectedPython -PathType Leaf)) {
    throw 'Selected Python is missing. Follow the first-use setup in VALIDATION.md or supply the exact managed interpreter with -PythonPath.'
}
$selectedPython = (Resolve-Path -LiteralPath $selectedPython).Path
& $selectedPython -c 'import yaml'
if ($LASTEXITCODE -ne 0) {
    throw 'Selected Python lacks the pinned PyYAML dependency. Follow VALIDATION.md; this wrapper does not install packages.'
}
if ([string]::IsNullOrWhiteSpace($ValidatorPath)) {
    $codexDirectory = $env:CODEX_HOME
    if ([string]::IsNullOrWhiteSpace($codexDirectory)) {
        $codexDirectory = Join-Path ([Environment]::GetFolderPath('UserProfile')) '.codex'
    }
    $ValidatorPath = Join-Path $codexDirectory 'skills/.system/skill-creator/scripts/quick_validate.py'
}
if (-not (Test-Path -LiteralPath $ValidatorPath -PathType Leaf)) {
    throw 'Skill Creator validator not found. Supply its installed path with -ValidatorPath.'
}
if ($SkillPath.Count -eq 0) {
    $SkillPath = @(Join-Path $repositoryRoot '.agents/skills/start-task')
}
foreach ($target in $SkillPath) {
    $resolvedSkill = (Resolve-Path -LiteralPath $target).Path
    & $selectedPython -X utf8 $ValidatorPath $resolvedSkill
    if ($LASTEXITCODE -ne 0) {
        throw "Skill Creator validation failed for '$resolvedSkill' (exit $LASTEXITCODE)."
    }
}
