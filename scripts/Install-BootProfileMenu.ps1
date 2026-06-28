<#
.SYNOPSIS
Creates the managed BootProfile Switcher boot menu entries.

.DESCRIPTION
Creates two Windows Boot Manager entries by copying the default Windows boot
loader entry. The entries are named "BootProfile Switcher - Mode A" and
"BootProfile Switcher - Mode B" and are added to the Boot Manager display
order. The script stores the created identifiers in state/boot-menu.json so the
entries can be inspected or removed later.

This script changes Windows Boot Configuration Data and must be run from an
elevated PowerShell session.
#>

[CmdletBinding(SupportsShouldProcess = $true)]
param(
    [int]$TimeoutSeconds = 10,
    [switch]$RemoveExisting
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

function Get-BootProfileEntriesFromBcd {
    $output = & bcdedit /enum all
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

function Read-YesNo {
    param(
        [string]$Prompt
    )

    $answer = Read-Host "$Prompt [y/N]"
    return $answer -match '^(y|yes|j|ja)$'
}

function Remove-BootProfileEntries {
    param(
        [object[]]$Entries,
        [string]$StateFile
    )

    foreach ($entry in $Entries) {
        $id = [string]$entry.Identifier
        $name = [string]$entry.Name

        if ($PSCmdlet.ShouldProcess($id, "Delete existing boot entry $name")) {
            try {
                & bcdedit /delete $id /f | Out-Null
                Write-Host "Deleted existing boot entry $name ($id)."
            } catch {
                Write-Warning "Could not delete existing boot entry ${id}: $($_.Exception.Message)"
            }
        }
    }

    if (Test-Path $StateFile) {
        $timestamp = Get-Date -Format 'yyyyMMdd-HHmmss'
        $archivedStateFile = Join-Path (Split-Path -Parent $StateFile) "boot-menu.replaced-$timestamp.json"

        if ($PSCmdlet.ShouldProcess($StateFile, "Archive existing state file as $archivedStateFile")) {
            Move-Item -Path $StateFile -Destination $archivedStateFile -Force
            Write-Host "Archived existing state file: $archivedStateFile"
        }
    }
}

if (-not (Test-Administrator)) {
    throw 'This script must be run from an elevated PowerShell session.'
}

$repoRoot = Split-Path -Parent (Split-Path -Parent $PSCommandPath)
$stateDir = Join-Path $repoRoot 'state'
$backupDir = Join-Path $repoRoot 'backups'
$stateFile = Join-Path $stateDir 'boot-menu.json'

$existingEntries = @(Get-BootProfileEntriesFromBcd)
$stateFileExists = Test-Path $stateFile

if ($stateFileExists -or $existingEntries.Count -gt 0) {
    Write-Host 'Existing BootProfile Switcher installation data was found.'

    if ($stateFileExists) {
        Write-Host "State file: $stateFile"
    }

    if ($existingEntries.Count -gt 0) {
        Write-Host 'BCD entries:'
        foreach ($entry in $existingEntries) {
            Write-Host "  $($entry.Name): $($entry.Identifier)"
        }
    }

    if (-not $RemoveExisting) {
        $shouldRemove = Read-YesNo -Prompt 'Remove existing BootProfile Switcher entries and install fresh'

        if (-not $shouldRemove) {
            throw 'Installation cancelled. Existing BootProfile Switcher entries were left unchanged.'
        }
    }

    Remove-BootProfileEntries -Entries $existingEntries -StateFile $stateFile
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

    $modeAOutput = & bcdedit /copy '{default}' /d 'BootProfile Switcher - Mode A'
    $modeAId = Get-GuidFromBcdeditOutput -Output $modeAOutput

    $modeBOutput = & bcdedit /copy '{default}' /d 'BootProfile Switcher - Mode B'
    $modeBId = Get-GuidFromBcdeditOutput -Output $modeBOutput

    & bcdedit /displayorder $modeAId /addlast | Out-Null
    & bcdedit /displayorder $modeBId /addlast | Out-Null
    & bcdedit /timeout $TimeoutSeconds | Out-Null

    $state = [ordered]@{
        createdAt = (Get-Date).ToString('o')
        sourceEntry = '{default}'
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
