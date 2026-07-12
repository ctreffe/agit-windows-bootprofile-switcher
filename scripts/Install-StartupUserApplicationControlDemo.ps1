<#
.SYNOPSIS
Installs the Startup and User-Application Control module demonstration.

.DESCRIPTION
Creates one managed Windows Boot Manager entry named "App Startup Control",
installs a matching machine-wide profile configuration and installs the startup
hook.

The demo profile targets Teams, OneDrive, ownCloud and Microsoft Office startup
surfaces with real apply/restore behavior enabled. It backs up an existing
ProgramData profile configuration before replacing it. The script changes
Windows Boot Configuration Data and must run elevated.
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

function Get-ExistingStartupUserApplicationControlDemoEntries {
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
        if ($joined -notmatch '(?m)^(description|Beschreibung)\s+App Startup Control$') {
            continue
        }

        $idMatch = [regex]::Match($joined, '\{[0-9a-fA-F-]{36}\}')
        if (-not $idMatch.Success) {
            continue
        }

        $entries += [pscustomobject]@{
            mode = 'app-startup-control'
            name = 'App Startup Control'
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

$sourceRoot = Split-Path -Parent (Split-Path -Parent $PSCommandPath)
$runtimeRoot = Join-Path $env:ProgramData 'BootProfileSwitcher\runtime'
$runtimeInstallerScript = Join-Path $sourceRoot 'scripts\Install-BootProfileRuntime.ps1'

& $runtimeInstallerScript -SourceRoot $sourceRoot -RuntimeRoot $runtimeRoot

$stateDir = Join-Path $runtimeRoot 'state'
$backupDir = Join-Path $runtimeRoot 'backups'
$stateFile = Join-Path $stateDir 'boot-menu.json'
$legacyStateFile = Join-Path $sourceRoot 'state\boot-menu.json'
$configSource = Join-Path $sourceRoot 'config\demos\startup-user-application-control.json'
$configDestination = Join-Path $env:ProgramData 'BootProfileSwitcher\config\profiles.json'
$configBackup = Join-Path $env:ProgramData 'BootProfileSwitcher\config\profiles.before-startup-user-application-control-demo.json'
$startupHookScript = Join-Path $runtimeRoot 'scripts\Install-StartupHook.ps1'
$userLogonHookScript = Join-Path $runtimeRoot 'scripts\Install-UserLogonHook.ps1'
$validatorScript = Join-Path $runtimeRoot 'scripts\Test-BootProfileConfiguration.ps1'

if (-not (Test-Path $configSource)) {
    throw "Startup and User-Application Control demo configuration not found: $configSource"
}

$validationOutput = & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $validatorScript -ConfigPath $configSource -AsJson 2>&1
$validation = (($validationOutput | Out-String).Trim()) | ConvertFrom-Json
if (-not $validation.valid) {
    throw "Startup and User-Application Control demo configuration is invalid: $(@($validation.errors) -join '; ')"
}

$stateFileCandidates = @($stateFile, $legacyStateFile)
$existingStateFiles = @($stateFileCandidates | Where-Object { Test-Path $_ })
$existingState = $existingStateFiles.Count -gt 0
$existingDemoEntries = @(Get-ExistingStartupUserApplicationControlDemoEntries)

if ($existingState -or $existingDemoEntries.Count -gt 0) {
    Write-Host 'Existing BootProfile Switcher demo or state data was found.'

    if (-not $RemoveExisting) {
        $shouldRemove = Read-YesNo -Prompt 'Remove existing managed demo entries/state and install Startup and User-Application Control demo'
        if (-not $shouldRemove) {
            throw 'Installation cancelled. Existing data was left unchanged.'
        }
    }

    foreach ($existingStateFile in $existingStateFiles) {
        $oldState = Get-Content -Path $existingStateFile -Raw | ConvertFrom-Json
        $existingDemoEntries += @($oldState.entries)

        $timestamp = Get-Date -Format 'yyyyMMdd-HHmmss'
        $archiveDirectory = Split-Path -Parent $existingStateFile
        $archivedStateFile = Join-Path $archiveDirectory "boot-menu.replaced-by-startup-user-application-control-demo-$timestamp.json"
        Move-Item -Path $existingStateFile -Destination $archivedStateFile -Force
        Write-Host "Archived existing state file: $archivedStateFile"
    }

    $entriesToRemove = @($existingDemoEntries | Group-Object identifier | ForEach-Object { $_.Group[0] })
    Remove-BcdEntries -Entries $entriesToRemove
}

New-Item -ItemType Directory -Path $stateDir -Force | Out-Null
New-Item -ItemType Directory -Path $backupDir -Force | Out-Null
New-Item -ItemType Directory -Path (Split-Path -Parent $configDestination) -Force | Out-Null

if ((Test-Path $configDestination) -and -not (Test-Path $configBackup)) {
    Copy-Item -Path $configDestination -Destination $configBackup -Force
    Write-Host "Backed up existing profile configuration: $configBackup"
}

Copy-Item -Path $configSource -Destination $configDestination -Force
Write-Host "Installed Startup and User-Application Control demo configuration: $configDestination"

$timestamp = Get-Date -Format 'yyyyMMdd-HHmmss'
$backupFile = Join-Path $backupDir "bcd-before-startup-user-application-control-demo-$timestamp.bak"
& bcdedit /export $backupFile | Out-Null

$entryOutput = & bcdedit /copy '{default}' /d 'App Startup Control'
$entryId = Get-GuidFromBcdeditOutput -Output $entryOutput

& bcdedit /displayorder $entryId /addlast | Out-Null
& bcdedit /timeout $TimeoutSeconds | Out-Null

$state = [ordered]@{
    createdAt = (Get-Date).ToString('o')
    demo = 'startup-user-application-control'
    sourceEntry = '{default}'
    entries = @(
        [ordered]@{
            mode = 'app-startup-control'
            name = 'App Startup Control'
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

# Keep the hook installation in this elevated process. Starting a second shell
# here can lose the elevated token and used to hide hook-registration failures.
& $startupHookScript
& $userLogonHookScript

Write-Host 'Startup and User-Application Control demo installed.'
Write-Host "Boot entry: $entryId"
Write-Host "State:      $stateFile"
Write-Host "Config:     $configDestination"
Write-Host "Backup:     $backupFile"
