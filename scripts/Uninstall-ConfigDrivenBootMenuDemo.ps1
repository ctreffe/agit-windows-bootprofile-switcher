<#
.SYNOPSIS
Removes the Configuration Format v2 boot menu demonstration.

.DESCRIPTION
Removes the startup hook, removes managed boot menu entries through the normal
BootProfile Switcher uninstall path and restores the previous ProgramData
profile configuration when a demo backup exists.
#>

[CmdletBinding(SupportsShouldProcess = $true)]
param(
    [switch]$KeepConfiguration,
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
$configDestination = Join-Path $env:ProgramData 'BootProfileSwitcher\config\profiles.json'
$configBackup = Join-Path $env:ProgramData 'BootProfileSwitcher\config\profiles.before-config-driven-boot-menu-demo.json'
$uninstallStartupHookScript = Join-Path $repoRoot 'scripts\Uninstall-StartupHook.ps1'
$uninstallBootMenuScript = Join-Path $repoRoot 'scripts\Uninstall-BootProfileMenu.ps1'

& powershell.exe -NoProfile -ExecutionPolicy Bypass -File $uninstallStartupHookScript

$bootMenuArguments = @(
    '-NoProfile',
    '-ExecutionPolicy', 'Bypass',
    '-File', $uninstallBootMenuScript
)

if ($KeepStateFile) {
    $bootMenuArguments += '-KeepStateFile'
}

& powershell.exe @bootMenuArguments

if (-not $KeepConfiguration) {
    if (Test-Path $configBackup) {
        Copy-Item -Path $configBackup -Destination $configDestination -Force
        Remove-Item -Path $configBackup -Force
        Write-Host "Restored previous profile configuration: $configDestination"
    } else {
        Write-Warning "No config-driven boot menu demo configuration backup found at $configBackup"
        Write-Warning 'Current profile configuration was left unchanged.'
    }
}

Write-Host 'Config-driven boot menu demo removed.'
