<#
.SYNOPSIS
Shows the current BootProfile Switcher proof-of-concept boot menu state.
#>

[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$repoRoot = Split-Path -Parent (Split-Path -Parent $PSCommandPath)
$stateFile = Join-Path (Join-Path $repoRoot 'state') 'boot-menu.json'

if (Test-Path $stateFile) {
    Write-Host 'Managed BootProfile Switcher state:'
    Get-Content -Path $stateFile -Raw | ConvertFrom-Json | ConvertTo-Json -Depth 5
} else {
    Write-Warning "No managed BootProfile Switcher state file found at $stateFile"
}

Write-Host ''
Write-Host 'Current Windows Boot Manager entries:'
Write-Host ''
& bcdedit /enum
