<#
.SYNOPSIS
Installs the BootProfile Switcher user-logon hook.

.DESCRIPTION
Registers a Windows Scheduled Task that runs at user logon for members of the
local built-in Users group. The task executes Invoke-BootProfileUserLogonHook.ps1 so
per-user startup registry entries and user-session processes can be handled in
the logged-on user's context.
#>

[CmdletBinding(SupportsShouldProcess)]
param(
    [string]$TaskName = 'BootProfileSwitcher-UserLogonHook'
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Assert-Administrator {
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = [Security.Principal.WindowsPrincipal]::new($identity)

    if (-not $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        throw 'Administrator privileges are required to install the user-logon hook.'
    }
}

Assert-Administrator

$repoRoot = Split-Path -Parent (Split-Path -Parent $PSCommandPath)
$hookScript = Join-Path $repoRoot 'scripts\Invoke-BootProfileUserLogonHook.ps1'
$hiddenLauncherScript = Join-Path $repoRoot 'scripts\Invoke-BootProfileUserLogonHook.vbs'

if (-not (Test-Path $hookScript)) {
    throw "User-logon hook script not found at $hookScript"
}

if (-not (Test-Path $hiddenLauncherScript)) {
    throw "Hidden user-logon launcher not found at $hiddenLauncherScript"
}

$actionArguments = "//B `"$hiddenLauncherScript`""
$action = New-ScheduledTaskAction -Execute 'wscript.exe' -Argument $actionArguments
$trigger = New-ScheduledTaskTrigger -AtLogOn
$principal = New-ScheduledTaskPrincipal -GroupId 'S-1-5-32-545' -RunLevel Limited
$settings = New-ScheduledTaskSettingsSet `
    -AllowStartIfOnBatteries `
    -DontStopIfGoingOnBatteries `
    -StartWhenAvailable `
    -MultipleInstances IgnoreNew

if ($PSCmdlet.ShouldProcess($TaskName, 'register user-logon hook scheduled task')) {
    Register-ScheduledTask `
        -TaskName $TaskName `
        -Action $action `
        -Trigger $trigger `
        -Principal $principal `
        -Settings $settings `
        -Description 'BootProfile Switcher user-logon hook.' `
        -Force | Out-Null

    Write-Host "BootProfile Switcher user-logon hook installed."
    Write-Host "Task:   $TaskName"
    Write-Host "Script: $hookScript"
}
