<#
.SYNOPSIS
Runs the BootProfile Switcher profile engine.

.DESCRIPTION
Consumes the structured resolver output from state/current-boot-profile.json
and dispatches the matching profile startup script from profiles/mode-*/.

This initial engine intentionally keeps execution narrow. It does not read a
configuration file, apply built-in system changes or modify machine settings.
It only preserves the existing harmless profile-script validation behavior
behind a dedicated engine entry point.
#>

[CmdletBinding()]
param(
    [string]$ResolverStatePath,

    [string]$LogDir
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$repoRoot = Split-Path -Parent (Split-Path -Parent $PSCommandPath)

if (-not $ResolverStatePath) {
    $ResolverStatePath = Join-Path $repoRoot 'state\current-boot-profile.json'
}

if (-not $LogDir) {
    $LogDir = Join-Path $repoRoot 'logs'
}

if (-not (Test-Path $ResolverStatePath)) {
    throw "Resolver state file not found at $ResolverStatePath"
}

New-Item -ItemType Directory -Path $LogDir -Force | Out-Null

$resolverResult = Get-Content -Path $ResolverStatePath -Raw | ConvertFrom-Json
$profileScriptExecuted = $false
$profileScript = $null

if ($resolverResult.detected) {
    $modeSlug = ('mode-{0}' -f ([string]$resolverResult.mode).ToLowerInvariant())
    $profileScript = Join-Path $repoRoot (Join-Path 'profiles' (Join-Path $modeSlug 'startup.ps1'))

    if (-not (Test-Path $profileScript)) {
        throw "Profile startup script not found for mode $($resolverResult.mode): $profileScript"
    }

    & $profileScript `
        -Mode $resolverResult.mode `
        -Name $resolverResult.name `
        -Identifier $resolverResult.identifier `
        -RepoRoot $repoRoot `
        -LogDir $LogDir

    $profileScriptExecuted = $true
}

$result = [ordered]@{
    schemaVersion = 1
    generatedAt = (Get-Date).ToString('o')
    detected = [bool]$resolverResult.detected
    mode = $resolverResult.mode
    name = $resolverResult.name
    identifier = $resolverResult.identifier
    resolverSource = $resolverResult.source
    resolverError = $resolverResult.error
    resolverStatePath = $ResolverStatePath
    profileScriptExecuted = $profileScriptExecuted
    profileScript = $profileScript
}

$result | ConvertTo-Json -Depth 5
