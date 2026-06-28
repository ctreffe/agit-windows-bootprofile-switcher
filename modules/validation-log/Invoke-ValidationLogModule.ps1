<#
.SYNOPSIS
Runs the harmless validation-log module.

.DESCRIPTION
Writes a module validation entry for the resolved boot profile. This module is
intentionally harmless and exists to validate the module boundary before real
system-changing modules are introduced.
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
    [string]$LogDir
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

New-Item -ItemType Directory -Path $LogDir -Force | Out-Null

$timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss zzz'
$logFile = Join-Path $LogDir 'module-actions.log'
$line = '{0} | module=validation-log | mode={1} | name={2} | identifier={3} | action=validation-log' -f `
    $timestamp, `
    $Mode, `
    $Name, `
    $Identifier

Add-Content -Path $logFile -Value $line -Encoding UTF8
