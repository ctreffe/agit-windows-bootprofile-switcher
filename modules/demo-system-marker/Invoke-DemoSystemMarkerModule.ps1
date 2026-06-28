<#
.SYNOPSIS
Writes a temporary BootProfile Switcher demo system marker.

.DESCRIPTION
This module is a deliberately small v1.0.0 demonstration module. It writes the
currently resolved boot profile to a machine-wide marker under ProgramData so
the profile engine can demonstrate a real but harmless system-level change.

The module does not change Windows behavior, network configuration, services,
policies or boot settings. It is temporary release-demo code and should be
removed once production modules exist.
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$Mode,

    [Parameter(Mandatory = $true)]
    [string]$Name,

    [Parameter(Mandatory = $true)]
    [string]$Identifier,

    [Parameter(Mandatory = $true)]
    [string]$RepoRoot,

    [Parameter(Mandatory = $true)]
    [string]$LogDir,

    [object]$ModuleSettings
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$markerDirectory = Join-Path $env:ProgramData 'BootProfileSwitcher\runtime'
$markerPath = Join-Path $markerDirectory 'demo-current-profile.json'

New-Item -ItemType Directory -Path $markerDirectory -Force | Out-Null

$marker = [ordered]@{
    schemaVersion = 1
    generatedAt = (Get-Date).ToString('o')
    module = 'demo-system-marker'
    temporary = $true
    mode = $Mode
    name = $Name
    identifier = $Identifier
    note = 'Temporary v1.0.0 demo marker. Remove after production modules exist.'
}

$marker | ConvertTo-Json -Depth 5 | Set-Content -Path $markerPath -Encoding UTF8

$timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss zzz'
$logFile = Join-Path $LogDir 'module-actions.log'
$line = '{0} | module=demo-system-marker | mode={1} | name={2} | identifier={3} | action=write-demo-marker | marker={4}' -f `
    $timestamp, `
    $Mode, `
    $Name, `
    $Identifier, `
    $markerPath

Add-Content -Path $logFile -Value $line -Encoding UTF8
