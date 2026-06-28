<#
.SYNOPSIS
Installs the BootProfile Switcher startup hook.

.DESCRIPTION
Registers a Windows Scheduled Task that runs at system startup as the local
SYSTEM account. The task executes Invoke-BootProfileStartupHook.ps1, which
detects the active BootProfile Switcher mode and writes a startup log entry.

This script installs the validated startup hook used by the current
BootProfile Switcher runtime path.
#>

[CmdletBinding(SupportsShouldProcess)]
param(
    [string]$TaskName = 'BootProfileSwitcher-StartupHook'
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Assert-Administrator {
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = [Security.Principal.WindowsPrincipal]::new($identity)

    if (-not $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        throw 'Administrator privileges are required to install the startup hook.'
    }
}

Assert-Administrator

$repoRoot = Split-Path -Parent (Split-Path -Parent $PSCommandPath)
$hookScript = Join-Path $repoRoot 'scripts\Invoke-BootProfileStartupHook.ps1'

if (-not (Test-Path $hookScript)) {
    throw "Startup hook script not found at $hookScript"
}

$actionArguments = "-NoProfile -ExecutionPolicy Bypass -File `"$hookScript`""
$action = New-ScheduledTaskAction -Execute 'powershell.exe' -Argument $actionArguments
$trigger = New-ScheduledTaskTrigger -AtStartup
$principal = New-ScheduledTaskPrincipal -UserId 'SYSTEM' -LogonType ServiceAccount -RunLevel Highest
$settings = New-ScheduledTaskSettingsSet `
    -AllowStartIfOnBatteries `
    -DontStopIfGoingOnBatteries `
    -StartWhenAvailable `
    -MultipleInstances IgnoreNew

if ($PSCmdlet.ShouldProcess($TaskName, 'register startup hook scheduled task')) {
    Register-ScheduledTask `
        -TaskName $TaskName `
        -Action $action `
        -Trigger $trigger `
        -Principal $principal `
        -Settings $settings `
        -Description 'BootProfile Switcher startup hook.' `
        -Force | Out-Null

    Write-Host "BootProfile Switcher startup hook installed."
    Write-Host "Task:   $TaskName"
    Write-Host "Script: $hookScript"
}
