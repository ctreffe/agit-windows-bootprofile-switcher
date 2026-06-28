<#
.SYNOPSIS
Installs the Network Isolation module demonstration.

.DESCRIPTION
Creates one managed Windows Boot Manager entry named "Network Isolation",
installs a matching machine-wide profile configuration and installs the startup
hook. The resulting boot menu lets the user choose between the normal Windows
entry and a Network Isolation profile that disables Ethernet, Wi-Fi, cellular
and Bluetooth PAN network adapters.

The script backs up an existing ProgramData profile configuration before
replacing it. It changes Windows Boot Configuration Data and must run elevated.
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

function Read-YesNo {
    param([string]$Prompt)

    $answer = Read-Host "$Prompt [y/N]"
    return $answer -match '^(y|yes|j|ja)$'
}

function Get-ExistingNetworkIsolationDemoEntries {
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
        if ($joined -notmatch '(?m)^(description|Beschreibung)\s+Network Isolation$') {
            continue
        }

        $idMatch = [regex]::Match($joined, '\{[0-9a-fA-F-]{36}\}')
        if (-not $idMatch.Success) {
            continue
        }

        $entries += [pscustomobject]@{
            mode = 'network-isolation'
            name = 'Network Isolation'
            identifier = $idMatch.Value
        }
    }

    return @($entries)
}

function Remove-BcdEntries {
    param([object[]]$Entries)

    foreach ($entry in $Entries) {
        if ($PSCmdlet.ShouldProcess($entry.identifier, "Delete existing demo boot entry $($entry.name)")) {
            & bcdedit /delete ([string]$entry.identifier) /f | Out-Null
            Write-Host "Deleted existing demo boot entry $($entry.name) ($($entry.identifier))."
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
$configSource = Join-Path $repoRoot 'config\demos\network-isolation.json'
$configDestination = Join-Path $env:ProgramData 'BootProfileSwitcher\config\profiles.json'
$configBackup = Join-Path $env:ProgramData 'BootProfileSwitcher\config\profiles.before-network-isolation-demo.json'
$startupHookScript = Join-Path $repoRoot 'scripts\Install-StartupHook.ps1'
$validatorScript = Join-Path $repoRoot 'scripts\Test-BootProfileConfiguration.ps1'

if (-not (Test-Path $configSource)) {
    throw "Network Isolation demo configuration not found: $configSource"
}

$validationOutput = & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $validatorScript -ConfigPath $configSource -AsJson 2>&1
$validation = (($validationOutput | Out-String).Trim()) | ConvertFrom-Json
if (-not $validation.valid) {
    throw "Network Isolation demo configuration is invalid: $(@($validation.errors) -join '; ')"
}

$existingState = Test-Path $stateFile
$existingDemoEntries = @(Get-ExistingNetworkIsolationDemoEntries)

if ($existingState -or $existingDemoEntries.Count -gt 0) {
    Write-Host 'Existing BootProfile Switcher demo or state data was found.'

    if (-not $RemoveExisting) {
        $shouldRemove = Read-YesNo -Prompt 'Remove existing managed demo entries/state and install Network Isolation demo'
        if (-not $shouldRemove) {
            throw 'Installation cancelled. Existing data was left unchanged.'
        }
    }

    if ($existingDemoEntries.Count -gt 0) {
        Remove-BcdEntries -Entries $existingDemoEntries
    }

    if ($existingState) {
        $oldState = Get-Content -Path $stateFile -Raw | ConvertFrom-Json
        Remove-BcdEntries -Entries @($oldState.entries)

        $timestamp = Get-Date -Format 'yyyyMMdd-HHmmss'
        $archivedStateFile = Join-Path $stateDir "boot-menu.replaced-by-network-isolation-demo-$timestamp.json"
        Move-Item -Path $stateFile -Destination $archivedStateFile -Force
        Write-Host "Archived existing state file: $archivedStateFile"
    }
}

New-Item -ItemType Directory -Path $stateDir -Force | Out-Null
New-Item -ItemType Directory -Path $backupDir -Force | Out-Null
New-Item -ItemType Directory -Path (Split-Path -Parent $configDestination) -Force | Out-Null

if ((Test-Path $configDestination) -and -not (Test-Path $configBackup)) {
    Copy-Item -Path $configDestination -Destination $configBackup -Force
    Write-Host "Backed up existing profile configuration: $configBackup"
}

Copy-Item -Path $configSource -Destination $configDestination -Force
Write-Host "Installed Network Isolation demo configuration: $configDestination"

$timestamp = Get-Date -Format 'yyyyMMdd-HHmmss'
$backupFile = Join-Path $backupDir "bcd-before-network-isolation-demo-$timestamp.bak"
& bcdedit /export $backupFile | Out-Null

$entryOutput = & bcdedit /copy '{default}' /d 'Network Isolation'
$entryId = Get-GuidFromBcdeditOutput -Output $entryOutput

& bcdedit /displayorder $entryId /addlast | Out-Null
& bcdedit /timeout $TimeoutSeconds | Out-Null

$state = [ordered]@{
    createdAt = (Get-Date).ToString('o')
    demo = 'network-isolation'
    sourceEntry = '{default}'
    entries = @(
        [ordered]@{
            mode = 'network-isolation'
            name = 'Network Isolation'
            identifier = $entryId
        }
    )
    timeoutSeconds = $TimeoutSeconds
    backupFile = $backupFile
    configSource = $configSource
    configDestination = $configDestination
    configBackup = if (Test-Path $configBackup) { $configBackup } else { $null }
}

$state | ConvertTo-Json -Depth 5 | Set-Content -Path $stateFile -Encoding UTF8

& powershell.exe -NoProfile -ExecutionPolicy Bypass -File $startupHookScript

Write-Host 'Network Isolation demo installed.'
Write-Host "Boot entry: $entryId"
Write-Host "State:      $stateFile"
Write-Host "Config:     $configDestination"
Write-Host "Backup:     $backupFile"
