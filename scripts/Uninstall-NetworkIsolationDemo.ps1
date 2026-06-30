<#
.SYNOPSIS
Removes the Network Isolation module demonstration.

.DESCRIPTION
Removes the startup hook and the managed demo boot entry created by
Install-NetworkIsolationDemo.ps1. If a ProgramData profile configuration backup
exists, it is restored so the demo does not permanently replace the previous
configuration.
#>

[CmdletBinding(SupportsShouldProcess = $true)]
param(
    [switch]$KeepStateFile,
    [switch]$KeepConfiguration
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
$uninstallStartupHookScript = Join-Path $repoRoot 'scripts\Uninstall-StartupHook.ps1'
$profileEngineScript = Join-Path $repoRoot 'scripts\Invoke-ProfileEngine.ps1'
$logDir = Join-Path $repoRoot 'logs'
$configSource = Join-Path $repoRoot 'config\demos\network-isolation.json'
$configDestination = Join-Path $env:ProgramData 'BootProfileSwitcher\config\profiles.json'
$configBackup = Join-Path $env:ProgramData 'BootProfileSwitcher\config\profiles.before-network-isolation-demo.json'
$networkIsolationStatePath = Join-Path $env:ProgramData 'BootProfileSwitcher\state\network-isolation-state.json'

function Invoke-NetworkIsolationDemoRestore {
    if (-not (Test-Path $networkIsolationStatePath)) {
        Write-Host "No Network Isolation lifecycle state found at $networkIsolationStatePath"
        return
    }

    if (-not (Test-Path $profileEngineScript)) {
        Write-Warning "Cannot restore Network Isolation baseline because profile engine is missing: $profileEngineScript"
        return
    }

    $restoreConfigPaths = @()

    if (Test-Path $configDestination) {
        $restoreConfigPaths += $configDestination
    }

    if ((Test-Path $configSource) -and ($restoreConfigPaths -notcontains $configSource)) {
        $restoreConfigPaths += $configSource
    }

    if ($restoreConfigPaths.Count -eq 0) {
        Write-Warning "Cannot restore Network Isolation baseline because no usable profile configuration was found."
        return
    }

    New-Item -ItemType Directory -Path $stateDir -Force | Out-Null
    New-Item -ItemType Directory -Path $logDir -Force | Out-Null

    $restoreResolverStatePath = Join-Path $stateDir 'network-isolation-demo-uninstall-resolver.json'
    $restoreResolverState = [ordered]@{
        schemaVersion = 1
        generatedAt = (Get-Date).ToString('o')
        detected = $false
        profileId = $null
        mode = 'unmanaged'
        name = 'Unmanaged Windows startup'
        identifier = 'unmanaged'
        source = 'network-isolation-demo-uninstall'
        description = 'Network Isolation demo uninstall restore'
        currentIdentifier = $null
        outputPath = $restoreResolverStatePath
        stateFile = $stateFile
        error = $null
    }

    $restoreResolverState | ConvertTo-Json -Depth 5 | Set-Content -Path $restoreResolverStatePath -Encoding UTF8

    foreach ($restoreConfigPath in $restoreConfigPaths) {
        Write-Host "Restoring Network Isolation baseline before removing demo infrastructure using $restoreConfigPath..."
        $engineJson = & powershell.exe `
            -NoProfile `
            -ExecutionPolicy Bypass `
            -File $profileEngineScript `
            -ResolverStatePath $restoreResolverStatePath `
            -LogDir $logDir `
            -ConfigPath $restoreConfigPath

        $engineResult = ($engineJson | Out-String).Trim() | ConvertFrom-Json

        if (-not [bool]$engineResult.configurationValid) {
            Write-Warning "Network Isolation baseline restore did not run because this profile configuration is invalid: $restoreConfigPath"
            foreach ($configurationError in @($engineResult.configurationErrors)) {
                Write-Warning "- $configurationError"
            }
            continue
        }

        $networkIsolationExecuted = @($engineResult.modulesExecuted | Where-Object { $_.name -eq 'network-isolation' }).Count -gt 0

        if ($networkIsolationExecuted) {
            Write-Host 'Network Isolation baseline restore path completed.'
            return
        }
    }

    Write-Warning 'Network Isolation baseline restore path did not execute; adapters may need manual review.'
}

Invoke-NetworkIsolationDemoRestore

& powershell.exe -NoProfile -ExecutionPolicy Bypass -File $uninstallStartupHookScript

if (Test-Path $stateFile) {
    $state = Get-Content -Path $stateFile -Raw | ConvertFrom-Json

    foreach ($entry in @($state.entries)) {
        if ($PSCmdlet.ShouldProcess($entry.identifier, "Delete demo boot entry $($entry.name)")) {
            try {
                & bcdedit /delete ([string]$entry.identifier) /f | Out-Null
                Write-Host "Deleted demo boot entry $($entry.name) ($($entry.identifier))."
            } catch {
                Write-Warning "Could not delete demo boot entry $($entry.identifier): $($_.Exception.Message)"
            }
        }
    }

    if (-not $KeepStateFile) {
        $timestamp = Get-Date -Format 'yyyyMMdd-HHmmss'
        $archivedStateFile = Join-Path $stateDir "boot-menu.removed-network-isolation-demo-$timestamp.json"
        Move-Item -Path $stateFile -Destination $archivedStateFile -Force
        Write-Host "Archived state file: $archivedStateFile"
    }
} else {
    Write-Warning "No managed BootProfile Switcher state file found at $stateFile"
}

if (-not $KeepConfiguration) {
    if (Test-Path $configBackup) {
        Copy-Item -Path $configBackup -Destination $configDestination -Force
        Remove-Item -Path $configBackup -Force
        Write-Host "Restored previous profile configuration: $configDestination"
    } else {
        Write-Warning "No Network Isolation demo configuration backup found at $configBackup"
        Write-Warning "Current profile configuration was left unchanged."
    }
}

& bcdedit /displayorder '{current}' /addfirst | Out-Null
& bcdedit /timeout 0 | Out-Null

Write-Host 'Network Isolation demo removed.'
