<#
.SYNOPSIS
Runs BootProfile Switcher startup initialization.

.DESCRIPTION
Invoked by the startup scheduled task. The script calls
Resolve-BootProfile.ps1, writes the detected profile to
logs/startup-profile.log and executes the matching profile-specific
startup.ps1 script from profiles/mode-*/.

The current profile scripts remain harmless. They only write validation log
entries so the boot-profile startup chain can be verified without changing
system configuration.
#>

[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$repoRoot = Split-Path -Parent (Split-Path -Parent $PSCommandPath)
$resolveScript = Join-Path $repoRoot 'scripts\Resolve-BootProfile.ps1'
$logDir = Join-Path $repoRoot 'logs'
$logFile = Join-Path $logDir 'startup-profile.log'

if (-not (Test-Path $resolveScript)) {
    throw "Resolver script not found at $resolveScript"
}

New-Item -ItemType Directory -Path $logDir -Force | Out-Null

$timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss zzz'

try {
    $json = & $resolveScript -AsJson
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

    $resolverError = if ($result.error) { ([string]$result.error) -replace "(`r`n|`n|`r)", ' ' } else { $null }

    $line = '{0} | detected={1} | mode={2} | name={3} | identifier={4} | source={5} | profileScriptExecuted={6} | profileScript={7} | resolverError={8}' -f `
        $timestamp, `
        $result.detected, `
        $result.mode, `
        $result.name, `
        $result.identifier, `
        $result.source, `
        $profileScriptExecuted, `
        $profileScript, `
        $resolverError

    Add-Content -Path $logFile -Value $line -Encoding UTF8
}
catch {
    $message = $_.Exception.Message -replace "(`r`n|`n|`r)", ' '
    $line = '{0} | detected=false | profileScriptExecuted=false | error={1}' -f $timestamp, $message
    Add-Content -Path $logFile -Value $line -Encoding UTF8
    throw
}
