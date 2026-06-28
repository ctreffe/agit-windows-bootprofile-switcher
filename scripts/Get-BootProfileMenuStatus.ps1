<#
.SYNOPSIS
Shows the current BootProfile Switcher proof-of-concept boot menu state.
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

function Get-BootProfileEntriesFromBcd {
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
        $descriptionMatch = [regex]::Match($joined, 'BootProfile Switcher - Mode (?<mode>[AB])')

        if (-not $descriptionMatch.Success) {
            continue
        }

        $idMatch = [regex]::Match($joined, '\{[0-9a-fA-F-]{36}\}')

        if (-not $idMatch.Success) {
            continue
        }

        $mode = $descriptionMatch.Groups['mode'].Value

        $entries += [pscustomobject]@{
            Mode = $mode
            Name = "BootProfile Switcher - Mode $mode"
            Identifier = $idMatch.Value
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

if (Test-Path $stateFile) {
    Write-Host 'Managed BootProfile Switcher state:'
    $state = Get-Content -Path $stateFile -Raw | ConvertFrom-Json
    $state | ConvertTo-Json -Depth 5
    $managedIdentifiers = @($state.entries | ForEach-Object { [string]$_.identifier })
} else {
    Write-Warning "No managed BootProfile Switcher state file found at $stateFile"
}

Write-Host ''
Write-Host 'Detected BootProfile Switcher BCD entries:'
$bootProfileEntries = @(Get-BootProfileEntriesFromBcd)

if ($bootProfileEntries.Count -eq 0) {
    Write-Host '  None'
} else {
    foreach ($entry in $bootProfileEntries) {
        $classification = 'orphaned'

        if ($managedIdentifiers -contains $entry.Identifier) {
            $classification = 'managed'
        }

        Write-Host "  $($entry.Name): $($entry.Identifier) [$classification]"
    }
}

Write-Host ''
Write-Host 'Current Windows Boot Manager entries:'
Write-Host ''
& bcdedit /enum
