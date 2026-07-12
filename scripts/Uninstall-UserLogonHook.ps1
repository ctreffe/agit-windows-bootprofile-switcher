<#
.SYNOPSIS
Unregisters the BootProfile Switcher user-logon hook.
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
        throw 'Administrator privileges are required to uninstall the user-logon hook.'
    }
}

Assert-Administrator

$task = Get-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue
if ($null -eq $task) {
    Write-Host "BootProfile Switcher user-logon hook is not installed: $TaskName"
    return
}

if ($PSCmdlet.ShouldProcess($TaskName, 'unregister user-logon hook scheduled task')) {
    Unregister-ScheduledTask -TaskName $TaskName -Confirm:$false
    Write-Host "BootProfile Switcher user-logon hook uninstalled: $TaskName"
}
