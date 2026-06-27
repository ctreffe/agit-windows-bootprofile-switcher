<#
.SYNOPSIS
Runs BootProfile Switcher startup initialization.

.DESCRIPTION
Invoked by the startup scheduled task. The script calls
Get-CurrentBootProfile.ps1, writes the detected profile to
logs/startup-profile.log and executes the matching profile-specific
startup.ps1 script from profiles/mode-*/.

A4 intentionally keeps profile scripts harmless. They only write validation
log entries so the proof of concept can verify the full boot-profile startup
chain without changing system configuration.
#>

[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$repoRoot = Split-Path -Parent (Split-Path -Parent $PSCommandPath)
$detectScript = Join-Path $repoRoot 'scripts\Get-CurrentBootProfile.ps1'
$logDir = Join-Path $repoRoot 'logs'
$logFile = Join-Path $logDir 'startup-profile.log'

if (-not (Test-Path $detectScript)) {
    throw "Detection script not found at $detectScript"
}

New-Item -ItemType Directory -Path $logDir -Force | Out-Null

$timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss zzz'

try {
    $json = & $detectScript -AsJson
    $result = $json | ConvertFrom-Json

    $profileScriptExecuted = $false
    $profileScript = $null

    if ($result.detected) {
        $modeSlug = ('mode-{0}' -f ([string]$result.mode).ToLowerInvariant())
        $profileScript = Join-Path $repoRoot (Join-Path 'profiles' (Join-Path $modeSlug 'startup.ps1'))

        if (-not (Test-Path $profileScript)) {
            throw "Profile startup script not found for mode $($result.mode): $profileScript"
        }

        & $profileScript `
            -Mode $result.mode `
            -Name $result.name `
            -Identifier $result.identifier `
            -RepoRoot $repoRoot `
            -LogDir $logDir

        $profileScriptExecuted = $true
    }

    $line = '{0} | detected={1} | mode={2} | name={3} | identifier={4} | source={5} | profileScriptExecuted={6} | profileScript={7}' -f `
        $timestamp, `
        $result.detected, `
        $result.mode, `
        $result.name, `
        $result.identifier, `
        $result.source, `
        $profileScriptExecuted, `
        $profileScript

    Add-Content -Path $logFile -Value $line -Encoding UTF8
}
catch {
    $message = $_.Exception.Message -replace "(`r`n|`n|`r)", ' '
    $line = '{0} | detected=false | profileScriptExecuted=false | error={1}' -f $timestamp, $message
    Add-Content -Path $logFile -Value $line -Encoding UTF8
    throw
}
