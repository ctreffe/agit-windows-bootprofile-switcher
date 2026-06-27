<#
.SYNOPSIS
Creates the BootProfile Switcher proof-of-concept boot menu entries.

.DESCRIPTION
Creates two Windows Boot Manager entries by copying the current Windows boot
loader entry. The entries are named "BootProfile Switcher - Mode A" and
"BootProfile Switcher - Mode B" and are added to the Boot Manager display
order. The script stores the created identifiers in state/boot-menu.json so the
entries can be inspected or removed later.

This script changes Windows Boot Configuration Data and must be run from an
elevated PowerShell session.
#>

[CmdletBinding(SupportsShouldProcess = $true)]
param(
    [int]$TimeoutSeconds = 10
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Test-Administrator {
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = [Security.Principal.WindowsPrincipal]::new($identity)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Get-GuidFromBcdeditOutput {
    param([string[]]$Output)

    $joined = $Output -join "`n"
    $match = [regex]::Match($joined, '\{[0-9a-fA-F-]{36}\}')
    if (-not $match.Success) {
        throw "Could not parse boot entry identifier from bcdedit output: $joined"
    }

    return $match.Value
}

if (-not (Test-Administrator)) {
    throw 'This script must be run from an elevated PowerShell session.'
}

$repoRoot = Split-Path -Parent (Split-Path -Parent $PSCommandPath)
$stateDir = Join-Path $repoRoot 'state'
$backupDir = Join-Path $repoRoot 'backups'
$stateFile = Join-Path $stateDir 'boot-menu.json'

if (Test-Path $stateFile) {
    throw "BootProfile Switcher state already exists: $stateFile. Run scripts/Uninstall-BootProfileMenu.ps1 before installing again."
}

if ($PSCmdlet.ShouldProcess($stateDir, 'Create directory')) {
    New-Item -ItemType Directory -Path $stateDir -Force | Out-Null
}

if ($PSCmdlet.ShouldProcess($backupDir, 'Create directory')) {
    New-Item -ItemType Directory -Path $backupDir -Force | Out-Null
}

if ($PSCmdlet.ShouldProcess('Windows Boot Configuration Data store', 'Create BootProfile Switcher menu entries')) {
    $timestamp = Get-Date -Format 'yyyyMMdd-HHmmss'
    $backupFile = Join-Path $backupDir "bcd-before-bootprofile-menu-$timestamp.bak"

    & bcdedit /export $backupFile | Out-Null

    $modeAOutput = & bcdedit /copy '{current}' /d 'BootProfile Switcher - Mode A'
    $modeAId = Get-GuidFromBcdeditOutput -Output $modeAOutput

    $modeBOutput = & bcdedit /copy '{current}' /d 'BootProfile Switcher - Mode B'
    $modeBId = Get-GuidFromBcdeditOutput -Output $modeBOutput

    & bcdedit /displayorder $modeAId /addlast | Out-Null
    & bcdedit /displayorder $modeBId /addlast | Out-Null
    & bcdedit /timeout $TimeoutSeconds | Out-Null

    $state = [ordered]@{
        createdAt = (Get-Date).ToString('o')
        sourceEntry = '{current}'
        entries = @(
            [ordered]@{
                mode = 'A'
                name = 'BootProfile Switcher - Mode A'
                identifier = $modeAId
            },
            [ordered]@{
                mode = 'B'
                name = 'BootProfile Switcher - Mode B'
                identifier = $modeBId
            }
        )
        timeoutSeconds = $TimeoutSeconds
        backupFile = $backupFile
    }

    $state | ConvertTo-Json -Depth 5 | Set-Content -Path $stateFile -Encoding UTF8

    Write-Host 'BootProfile Switcher boot menu entries created.'
    Write-Host "Mode A: $modeAId"
    Write-Host "Mode B: $modeBId"
    Write-Host "State:  $stateFile"
    Write-Host "Backup: $backupFile"
}
