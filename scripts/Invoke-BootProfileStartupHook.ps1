<#
.SYNOPSIS
Runs BootProfile Switcher startup initialization.

.DESCRIPTION
Invoked by the startup scheduled task. The script calls
Resolve-BootProfile.ps1, invokes the profile engine and writes the startup
result to logs/startup-profile.log.

The profile engine currently keeps profile scripts harmless. They only write
validation log entries so the boot-profile startup chain can be verified
without changing system configuration.
#>

[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$repoRoot = Split-Path -Parent (Split-Path -Parent $PSCommandPath)
$resolveScript = Join-Path $repoRoot 'scripts\Resolve-BootProfile.ps1'
$profileEngineScript = Join-Path $repoRoot 'scripts\Invoke-ProfileEngine.ps1'
$logDir = Join-Path $repoRoot 'logs'
$logFile = Join-Path $logDir 'startup-profile.log'

if (-not (Test-Path $resolveScript)) {
    throw "Resolver script not found at $resolveScript"
}

if (-not (Test-Path $profileEngineScript)) {
    throw "Profile engine script not found at $profileEngineScript"
}

New-Item -ItemType Directory -Path $logDir -Force | Out-Null

$timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss zzz'

try {
    $json = & $resolveScript -AsJson
    $result = $json | ConvertFrom-Json
    $engineJson = & $profileEngineScript -ResolverStatePath $result.outputPath -LogDir $logDir
    $engineResult = $engineJson | ConvertFrom-Json

    $resolverError = if ($result.error) { ([string]$result.error) -replace "(`r`n|`n|`r)", ' ' } else { $null }

    $line = '{0} | detected={1} | mode={2} | name={3} | identifier={4} | source={5} | profileScriptExecuted={6} | profileScript={7} | resolverError={8} | engineStatePath={9}' -f `
        $timestamp, `
        $result.detected, `
        $result.mode, `
        $result.name, `
        $result.identifier, `
        $result.source, `
        $engineResult.profileScriptExecuted, `
        $engineResult.profileScript, `
        $resolverError, `
        $result.outputPath

    Add-Content -Path $logFile -Value $line -Encoding UTF8
}
catch {
    $message = $_.Exception.Message -replace "(`r`n|`n|`r)", ' '
    $line = '{0} | detected=false | profileScriptExecuted=false | error={1}' -f $timestamp, $message
    Add-Content -Path $logFile -Value $line -Encoding UTF8
    throw
}
