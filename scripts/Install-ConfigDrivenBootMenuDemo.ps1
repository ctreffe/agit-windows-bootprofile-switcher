<#
.SYNOPSIS
Installs the Configuration Format v2 boot menu demonstration.

.DESCRIPTION
Installs a demo v2 profile configuration, creates a boot menu from that
configuration and installs the startup hook. The demo hides the default Windows
boot entry from the display order and creates three managed entries:
Network Isolation, Experiment Local and Maintenance.

The previous ProgramData profile configuration is backed up before replacement
and can be restored by Uninstall-ConfigDrivenBootMenuDemo.ps1.
#>

[CmdletBinding(SupportsShouldProcess = $true)]
param(
    [switch]$CleanupExisting,
    [switch]$Force
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
$configSource = Join-Path $repoRoot 'config\demos\config-driven-boot-menu.json'
$configDestination = Join-Path $env:ProgramData 'BootProfileSwitcher\config\profiles.json'
$configBackup = Join-Path $env:ProgramData 'BootProfileSwitcher\config\profiles.before-config-driven-boot-menu-demo.json'
$installConfigurationScript = Join-Path $repoRoot 'scripts\Install-BootProfileConfiguration.ps1'
$installBootMenuScript = Join-Path $repoRoot 'scripts\Install-BootProfileMenu.ps1'
$installStartupHookScript = Join-Path $repoRoot 'scripts\Install-StartupHook.ps1'

if (-not (Test-Path $configSource)) {
    throw "Config-driven boot menu demo configuration not found: $configSource"
}

New-Item -ItemType Directory -Path (Split-Path -Parent $configDestination) -Force | Out-Null

if ((Test-Path $configDestination) -and -not (Test-Path $configBackup)) {
    if ($PSCmdlet.ShouldProcess($configBackup, 'Back up existing ProgramData profile configuration')) {
        Copy-Item -Path $configDestination -Destination $configBackup -Force
        Write-Host "Backed up existing profile configuration: $configBackup"
    }
}

& powershell.exe -NoProfile -ExecutionPolicy Bypass -File $installConfigurationScript -SourcePath $configSource -DestinationPath $configDestination -Force

$bootMenuArguments = @(
    '-NoProfile',
    '-ExecutionPolicy', 'Bypass',
    '-File', $installBootMenuScript,
    '-ConfigPath', $configDestination
)

if ($CleanupExisting) {
    $bootMenuArguments += '-CleanupExisting'
}

if ($Force) {
    $bootMenuArguments += '-Force'
}

& powershell.exe @bootMenuArguments
& powershell.exe -NoProfile -ExecutionPolicy Bypass -File $installStartupHookScript

Write-Host 'Config-driven boot menu demo installed.'
Write-Host "Config: $configDestination"
Write-Host 'Managed boot entries: Network Isolation, Experiment Local, Maintenance'
Write-Host 'Default Windows boot entry is hidden from the boot menu display order.'
