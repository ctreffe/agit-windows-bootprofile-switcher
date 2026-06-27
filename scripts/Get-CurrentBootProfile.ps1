<#
.SYNOPSIS
Detects the currently selected BootProfile Switcher proof-of-concept boot profile.

.DESCRIPTION
Reads the current Windows Boot Configuration Data entry by calling
`bcdedit /enum "{current}"`, extracts the entry description, and maps it to the
managed A1 boot menu entries stored in state/boot-menu.json.

This script is part of the A2 proof-of-concept step. It intentionally uses the
BCD entry description as the first detection mechanism because `bcdedit` exposes
`{current}` as an alias instead of the real boot entry identifier.
#>

[CmdletBinding()]
param(
    [switch]$AsJson
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Get-BcdCurrentDescription {
    $output = & bcdedit /enum '{current}' 2>&1

    if ($LASTEXITCODE -ne 0) {
        $message = ($output | Out-String).Trim()
        throw "Could not read current BCD entry: $message"
    }

    foreach ($line in $output) {
        if ($line -match '^description\s+(.+)$') {
            return $Matches[1].Trim()
        }
    }

    $joined = ($output | Out-String).Trim()
    throw "Could not parse current BCD entry description from bcdedit output: $joined"
}

$repoRoot = Split-Path -Parent (Split-Path -Parent $PSCommandPath)
$stateFile = Join-Path $repoRoot 'state\boot-menu.json'

if (-not (Test-Path $stateFile)) {
    throw "No BootProfile Switcher state file found at $stateFile. Run install.cmd or scripts/Install-BootProfileMenu.ps1 first."
}

$state = Get-Content -Path $stateFile -Raw | ConvertFrom-Json
$currentDescription = Get-BcdCurrentDescription

$matchedEntry = $null
foreach ($entry in $state.entries) {
    if ($entry.name -eq $currentDescription) {
        $matchedEntry = $entry
        break
    }
}

$result = [ordered]@{
    detected = $null -ne $matchedEntry
    source = 'bcdedit /enum "{current}" description'
    currentDescription = $currentDescription
    mode = $null
    name = $null
    identifier = $null
}

if ($matchedEntry) {
    $result.mode = $matchedEntry.mode
    $result.name = $matchedEntry.name
    $result.identifier = $matchedEntry.identifier
}

if ($AsJson) {
    $result | ConvertTo-Json -Depth 5
    return
}

if ($matchedEntry) {
    Write-Host 'Current BootProfile Switcher profile detected.'
    Write-Host "Mode:        $($matchedEntry.mode)"
    Write-Host "Name:        $($matchedEntry.name)"
    Write-Host "Identifier:  $($matchedEntry.identifier)"
    Write-Host 'Source:      bcdedit /enum "{current}" description'
} else {
    Write-Warning 'Current boot entry is not a managed BootProfile Switcher profile.'
    Write-Host "Description: $currentDescription"
}
