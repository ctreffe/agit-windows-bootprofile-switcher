<#
.SYNOPSIS
Shows the current managed BootProfile Switcher boot menu state.

.DESCRIPTION
Reads the managed BootProfile Switcher state file, detects matching BCD
entries and prints the current Windows Boot Manager display order. The script is
read-only and is intended for installation validation and troubleshooting.
#>

[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Test-Administrator {
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = [Security.Principal.WindowsPrincipal]::new($identity)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Get-BcdProperty {
    param(
        [string[]]$Output,
        [string[]]$Names
    )

    foreach ($line in $Output) {
        foreach ($name in $Names) {
            if ($line -match ('^{0}\s+(.+)$' -f [regex]::Escape($name))) {
                return $Matches[1].Trim()
            }
        }
    }

    return $null
}

function Get-BootProfileEntriesFromBcd {
    param(
        [object[]]$ManagedEntries
    )

    $output = & bcdedit /enum all

    if ($LASTEXITCODE -ne 0) {
        throw 'Could not read Windows Boot Configuration Data. Run this script from an elevated PowerShell session.'
    }

    $blocks = @()
    $currentBlock = @()

    foreach ($line in $output) {
        if ([string]::IsNullOrWhiteSpace($line)) {
            if ($currentBlock.Count -gt 0) {
                $blocks += ,@($currentBlock)
                $currentBlock = @()
            }
            continue
        }

        $currentBlock += $line
    }

    if ($currentBlock.Count -gt 0) {
        $blocks += ,@($currentBlock)
    }

    $entries = @()

    foreach ($block in $blocks) {
        $joined = $block -join "`n"

        $identifierText = Get-BcdProperty -Output $block -Names @('identifier', 'Bezeichner')
        $identifier = $null

        if ($identifierText -match '^\{[0-9a-fA-F-]{36}\}$') {
            $identifier = $identifierText
        } elseif ($identifierText -in @('{default}', '{current}')) {
            $descriptionForAlias = Get-BcdProperty -Output $block -Names @('description', 'Beschreibung')
            $aliasMatch = $ManagedEntries | Where-Object {
                [string]$_.name -eq $descriptionForAlias -or [string]$_.displayName -eq $descriptionForAlias
            } | Select-Object -First 1

            if ($null -ne $aliasMatch) {
                $identifier = [string]$aliasMatch.identifier
            } else {
                $identifier = $identifierText
            }
        } else {
            $idMatch = [regex]::Match($joined, '\{[0-9a-fA-F-]{36}\}')
            if (-not $idMatch.Success) {
                continue
            }

            $identifier = $idMatch.Value
        }

        $description = $null
        foreach ($line in $block) {
            if ($line -match '^(description|Beschreibung)\s+(.+)$') {
                $description = $Matches[2].Trim()
                break
            }
        }

        if (-not $description) {
            continue
        }

        $managedEntry = $ManagedEntries | Where-Object {
            [string]$_.identifier -eq $identifier -or [string]$_.name -eq $description -or [string]$_.displayName -eq $description
        } | Select-Object -First 1

        if ($null -eq $managedEntry -and $description -notmatch '^BootProfile Switcher - Mode [AB]$' -and $description -ne 'Network Isolation') {
            continue
        }

        $mode = $null
        if ($null -ne $managedEntry) {
            $mode = if ($managedEntry.PSObject.Properties['mode']) { [string]$managedEntry.mode } elseif ($managedEntry.PSObject.Properties['profileId']) { [string]$managedEntry.profileId } else { $null }
        }

        $entries += [pscustomobject]@{
            Mode = $mode
            ProfileId = if ($null -ne $managedEntry -and $managedEntry.PSObject.Properties['profileId']) { [string]$managedEntry.profileId } else { $mode }
            Name = $description
            Identifier = $identifier
        }
    }

    return @($entries)
}

$repoRoot = Split-Path -Parent (Split-Path -Parent $PSCommandPath)
$stateFile = Join-Path (Join-Path $repoRoot 'state') 'boot-menu.json'

if (-not (Test-Administrator)) {
    throw 'This script must be run from an elevated PowerShell session.'
}

$managedIdentifiers = @()
$managedEntries = @()

if (Test-Path $stateFile) {
    Write-Host 'Managed BootProfile Switcher state:'
    $state = Get-Content -Path $stateFile -Raw | ConvertFrom-Json
    $state | ConvertTo-Json -Depth 5
    $managedEntries = @($state.entries)
    $managedIdentifiers = @($state.entries | ForEach-Object { [string]$_.identifier })
} else {
    Write-Warning "No managed BootProfile Switcher state file found at $stateFile"
}

Write-Host ''
Write-Host 'Detected BootProfile Switcher BCD entries:'
$bootProfileEntries = @(Get-BootProfileEntriesFromBcd -ManagedEntries $managedEntries)

if ($bootProfileEntries.Count -eq 0) {
    Write-Host '  None'
} else {
    foreach ($entry in $bootProfileEntries) {
        $classification = 'orphaned'

        if ($managedIdentifiers -contains $entry.Identifier) {
            $classification = 'managed'
        }

        $profileLabel = if ($entry.ProfileId) { " profile=$($entry.ProfileId)" } else { '' }
        Write-Host "  $($entry.Name): $($entry.Identifier) [$classification$profileLabel]"
    }
}

Write-Host ''
Write-Host 'Current Windows Boot Manager entries:'
Write-Host ''
& bcdedit /enum
