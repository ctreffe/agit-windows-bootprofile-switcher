<#
.SYNOPSIS
Removes the Startup and User-Application Control module demonstration.

.DESCRIPTION
Removes the startup hook and managed demo boot entry created by
Install-StartupUserApplicationControlDemo.ps1. If a ProgramData profile
configuration backup exists, it is restored so the demo does not permanently
replace the previous configuration.

If a startup-user-application-control lifecycle state file exists, the script
invokes the profile engine with an unmanaged resolver state before removing the
demo infrastructure. This restores the learned startup baseline after the real
demo profile has applied startup changes.
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

$sourceRoot = Split-Path -Parent (Split-Path -Parent $PSCommandPath)
$runtimeRoot = Join-Path $env:ProgramData 'BootProfileSwitcher\runtime'
$repoRoot = if (Test-Path (Join-Path $runtimeRoot 'scripts\Invoke-ProfileEngine.ps1')) { $runtimeRoot } else { $sourceRoot }
$stateDir = Join-Path $repoRoot 'state'
$stateFile = Join-Path $stateDir 'boot-menu.json'
$uninstallStartupHookScript = Join-Path $repoRoot 'scripts\Uninstall-StartupHook.ps1'
$uninstallUserLogonHookScript = Join-Path $repoRoot 'scripts\Uninstall-UserLogonHook.ps1'
$profileEngineScript = Join-Path $repoRoot 'scripts\Invoke-ProfileEngine.ps1'
$logDir = Join-Path $repoRoot 'logs'
$configSource = Join-Path $repoRoot 'config\demos\startup-user-application-control.json'
$configDestination = Join-Path $env:ProgramData 'BootProfileSwitcher\config\profiles.json'
$configBackup = Join-Path $env:ProgramData 'BootProfileSwitcher\config\profiles.before-startup-user-application-control-demo.json'
$startupUserApplicationControlStatePath = Join-Path $env:ProgramData 'BootProfileSwitcher\state\startup-user-application-control-state.json'

function Invoke-StartupUserApplicationControlDemoRestore {
    if (-not (Test-Path $startupUserApplicationControlStatePath)) {
        Write-Host "No Startup and User-Application Control lifecycle state found at $startupUserApplicationControlStatePath"
        return
    }

    if (-not (Test-Path $profileEngineScript)) {
        Write-Warning "Cannot restore Startup and User-Application Control baseline because profile engine is missing: $profileEngineScript"
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
        Write-Warning "Cannot restore Startup and User-Application Control baseline because no usable profile configuration was found."
        return
    }

    New-Item -ItemType Directory -Path $stateDir -Force | Out-Null
    New-Item -ItemType Directory -Path $logDir -Force | Out-Null

    $restoreResolverStatePath = Join-Path $stateDir 'startup-user-application-control-demo-uninstall-resolver.json'
    $restoreResolverState = [ordered]@{
        schemaVersion = 1
        generatedAt = (Get-Date).ToString('o')
        detected = $false
        profileId = $null
        mode = 'unmanaged'
        name = 'Unmanaged Windows startup'
        identifier = 'unmanaged'
        source = 'startup-user-application-control-demo-uninstall'
        description = 'Startup and User-Application Control demo uninstall restore'
        currentIdentifier = $null
        outputPath = $restoreResolverStatePath
        stateFile = $stateFile
        error = $null
    }

    $restoreResolverState | ConvertTo-Json -Depth 5 | Set-Content -Path $restoreResolverStatePath -Encoding UTF8

    foreach ($restoreConfigPath in $restoreConfigPaths) {
        Write-Host "Restoring Startup and User-Application Control baseline before removing demo infrastructure using $restoreConfigPath..."
        $engineJson = & powershell.exe `
            -NoProfile `
            -ExecutionPolicy Bypass `
            -File $profileEngineScript `
            -ResolverStatePath $restoreResolverStatePath `
            -LogDir $logDir `
            -ConfigPath $restoreConfigPath

        $engineResult = ($engineJson | Out-String).Trim() | ConvertFrom-Json

        if (-not [bool]$engineResult.configurationValid) {
            Write-Warning "Startup and User-Application Control baseline restore did not run because this profile configuration is invalid: $restoreConfigPath"
            foreach ($configurationError in @($engineResult.configurationErrors)) {
                Write-Warning "- $configurationError"
            }
            continue
        }

        $moduleExecuted = @($engineResult.modulesExecuted | Where-Object { $_.name -eq 'startup-user-application-control' }).Count -gt 0

        if ($moduleExecuted) {
            Write-Host 'Startup and User-Application Control baseline restore path completed.'
            return
        }
    }

    Write-Warning 'Startup and User-Application Control baseline restore path did not execute; startup surfaces may need manual review.'
}

Invoke-StartupUserApplicationControlDemoRestore

& $uninstallStartupHookScript
& $uninstallUserLogonHookScript

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
        $archivedStateFile = Join-Path $stateDir "boot-menu.removed-startup-user-application-control-demo-$timestamp.json"
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
        Write-Warning "No Startup and User-Application Control demo configuration backup found at $configBackup"
        Write-Warning "Current profile configuration was left unchanged."
    }
}

& bcdedit /displayorder '{current}' /addfirst | Out-Null
& bcdedit /timeout 0 | Out-Null

Write-Host 'Startup and User-Application Control demo removed.'
