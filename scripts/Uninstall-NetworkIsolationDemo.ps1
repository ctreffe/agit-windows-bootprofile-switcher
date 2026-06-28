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
$configDestination = Join-Path $env:ProgramData 'BootProfileSwitcher\config\profiles.json'
$configBackup = Join-Path $env:ProgramData 'BootProfileSwitcher\config\profiles.before-network-isolation-demo.json'

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
