<#
.SYNOPSIS
Removes the managed BootProfile Switcher boot menu entries.

.DESCRIPTION
Reads state/boot-menu.json and removes the boot entries created by
Install-BootProfileMenu.ps1. The original BCD backup file is kept for manual
recovery. The state file is renamed instead of deleted so the operation remains
auditable. When the installer changed the default Windows boot entry
description or removed it from the Boot Manager display order, uninstall
restores that default-entry state from the recorded baseline.
#>

[CmdletBinding(SupportsShouldProcess = $true)]
param(
    [switch]$KeepStateFile
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Test-Administrator {
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = [Security.Principal.WindowsPrincipal]::new($identity)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

if (-not (Test-Administrator)) {
    throw 'This script must be run from an elevated PowerShell session.'
}

$repoRoot = Split-Path -Parent (Split-Path -Parent $PSCommandPath)
$stateDir = Join-Path $repoRoot 'state'
$stateFile = Join-Path $stateDir 'boot-menu.json'

if (-not (Test-Path $stateFile)) {
    throw "No BootProfile Switcher state file found at $stateFile"
}

$state = Get-Content -Path $stateFile -Raw | ConvertFrom-Json

foreach ($entry in $state.entries) {
    $id = [string]$entry.identifier
    $name = if ($entry.PSObject.Properties['displayName']) { [string]$entry.displayName } else { [string]$entry.name }

    if ($PSCmdlet.ShouldProcess($id, "Delete boot entry $name")) {
        try {
            & bcdedit /delete $id /f | Out-Null
            Write-Host "Deleted boot entry $name ($id)."
        } catch {
            Write-Warning "Could not delete boot entry ${id}: $($_.Exception.Message)"
        }
    }
}

if ($state.PSObject.Properties['defaultEntry'] -and $null -ne $state.defaultEntry) {
    $defaultEntry = $state.defaultEntry
    $sourceEntry = if ($defaultEntry.PSObject.Properties['sourceEntry']) { [string]$defaultEntry.sourceEntry } else { [string]$state.sourceEntry }
    $sourceIdentifier = if ($defaultEntry.PSObject.Properties['sourceIdentifier']) { [string]$defaultEntry.sourceIdentifier } else { $sourceEntry }

    if ([string]::IsNullOrWhiteSpace($sourceEntry)) {
        $sourceEntry = '{default}'
    }

    if ([string]::IsNullOrWhiteSpace($sourceIdentifier)) {
        $sourceIdentifier = $sourceEntry
    }

    if ($defaultEntry.PSObject.Properties['renameApplied'] -and [bool]$defaultEntry.renameApplied) {
        $originalDescription = [string]$defaultEntry.originalDescription

        if (-not [string]::IsNullOrWhiteSpace($originalDescription)) {
            if ($PSCmdlet.ShouldProcess($sourceEntry, "Restore default entry description to $originalDescription")) {
                & bcdedit /set $sourceEntry description $originalDescription | Out-Null
            }
        }
    }

    if ($defaultEntry.PSObject.Properties['restoreDisplayOrder'] -and [bool]$defaultEntry.restoreDisplayOrder) {
        if ($PSCmdlet.ShouldProcess('Windows Boot Manager', "Restore $sourceIdentifier as first display order entry")) {
            & bcdedit /displayorder $sourceIdentifier /addfirst | Out-Null
        }
    }

    if ($defaultEntry.PSObject.Properties['originalBootManagerDefault'] -or $defaultEntry.PSObject.Properties['originalBootManagerDefaultIdentifier']) {
        $originalDefault = if ($defaultEntry.PSObject.Properties['originalBootManagerDefaultIdentifier']) {
            [string]$defaultEntry.originalBootManagerDefaultIdentifier
        } else {
            [string]$defaultEntry.originalBootManagerDefault
        }

        if ($originalDefault -in @('{default}', '{current}')) {
            $originalDefault = $sourceIdentifier
        }

        if (-not [string]::IsNullOrWhiteSpace($originalDefault)) {
            if ($PSCmdlet.ShouldProcess('Windows Boot Manager', "Restore boot manager default to $originalDefault")) {
                & bcdedit /default $originalDefault | Out-Null
            }
        }
    } elseif ($defaultEntry.PSObject.Properties['restoreDisplayOrder'] -and [bool]$defaultEntry.restoreDisplayOrder) {
        if ($PSCmdlet.ShouldProcess('Windows Boot Manager', "Restore boot manager default to $sourceIdentifier")) {
            & bcdedit /default $sourceIdentifier | Out-Null
        }
    }
} else {
    if ($PSCmdlet.ShouldProcess('Windows Boot Manager', 'Restore current Windows entry as first display order entry')) {
        & bcdedit /displayorder '{current}' /addfirst | Out-Null
    }
}

if ($PSCmdlet.ShouldProcess('Windows Boot Manager', 'Set timeout to 0 seconds')) {
    & bcdedit /timeout 0 | Out-Null
}

if (-not $KeepStateFile) {
    $timestamp = Get-Date -Format 'yyyyMMdd-HHmmss'
    $archivedStateFile = Join-Path $stateDir "boot-menu.removed-$timestamp.json"

    if ($PSCmdlet.ShouldProcess($stateFile, "Archive state file as $archivedStateFile")) {
        Move-Item -Path $stateFile -Destination $archivedStateFile -Force
        Write-Host "Archived state file: $archivedStateFile"
    }
}

Write-Host 'BootProfile Switcher boot menu entries removed.'
