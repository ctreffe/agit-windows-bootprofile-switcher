<#
.SYNOPSIS
Runs BootProfile Switcher detection during system startup.

.DESCRIPTION
Invoked by the A3 startup scheduled task. The script calls
Get-CurrentBootProfile.ps1, captures the structured result and writes a compact
line to logs/startup-profile.log.

This script intentionally performs no profile-specific system changes yet. It
only proves that automatic startup-time detection works.
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

    $line = '{0} | detected={1} | mode={2} | name={3} | identifier={4} | source={5}' -f `
        $timestamp, `
        $result.detected, `
        $result.mode, `
        $result.name, `
        $result.identifier, `
        $result.source

    Add-Content -Path $logFile -Value $line -Encoding UTF8
}
catch {
    $message = $_.Exception.Message -replace "(`r`n|`n|`r)", ' '
    $line = '{0} | detected=false | error={1}' -f $timestamp, $message
    Add-Content -Path $logFile -Value $line -Encoding UTF8
    throw
}
