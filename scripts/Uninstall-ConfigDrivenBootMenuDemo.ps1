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

$configDestination = Join-Path $env:ProgramData 'BootProfileSwitcher\config\profiles.json'
$configBackup = Join-Path $env:ProgramData 'BootProfileSwitcher\config\profiles.before-config-driven-boot-menu-demo.json'
$deploymentUninstaller = Join-Path $env:ProgramData 'BootProfileSwitcher\runtime\scripts\Uninstall-BootProfileSwitcherDeployment.ps1'

if (-not (Test-Path $deploymentUninstaller)) {
    throw "Installed deployment uninstaller not found: $deploymentUninstaller"
}

$result = & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $deploymentUninstaller -RemoveStartupHook -RemoveBootMenu -AsJson
if ($LASTEXITCODE -ne 0) {
    throw "Config-driven boot menu demo removal failed with exit code ${LASTEXITCODE}: $($result | Out-String)"
}

if ($KeepStateFile) {
    Write-Warning 'KeepStateFile is retained for compatibility but managed boot-menu state is archived by the central uninstaller.'
}

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
