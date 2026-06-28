<#
.SYNOPSIS
Mode B validation startup script.

.DESCRIPTION
This script is intentionally harmless. It only writes a validation entry to the
BootProfile Switcher log directory so profile-specific startup execution can
be validated without changing system configuration.
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
$logFile = Join-Path $LogDir 'profile-startup-actions.log'
$line = '{0} | profile=mode-b | mode={1} | name={2} | identifier={3} | action=validation-log' -f `
    $timestamp, `
    $Mode, `
    $Name, `
    $Identifier

Add-Content -Path $logFile -Value $line -Encoding UTF8
