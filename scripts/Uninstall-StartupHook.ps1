<#
.SYNOPSIS
Removes the BootProfile Switcher A3 startup hook.

.DESCRIPTION
Unregisters the Windows Scheduled Task installed by Install-StartupHook.ps1.
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
        throw 'Administrator privileges are required to remove the startup hook.'
    }
}

Assert-Administrator

$task = Get-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue

if (-not $task) {
    Write-Host "No BootProfile Switcher startup hook task found."
    return
}

if ($PSCmdlet.ShouldProcess($TaskName, 'unregister startup hook scheduled task')) {
    Unregister-ScheduledTask -TaskName $TaskName -Confirm:$false
    Write-Host "BootProfile Switcher startup hook removed."
}
