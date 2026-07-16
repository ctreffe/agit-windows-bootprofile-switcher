<#
.SYNOPSIS
Removes the Startup and User-Application Control module demonstration.

.DESCRIPTION
Removes the Startup and User-Application Control demonstration through the
installed machine-wide deployment uninstaller. The standard removal restores
machine baselines, schedules each affected user's HKCU baseline restore at the
next logon, and removes only the startup hook and managed boot-menu entries.
It intentionally retains the user-logon hook until every affected user has
completed their restore.

Use -FinalizeUserRestore only after reviewing that completion evidence. It
removes the remaining user-logon hook in a separate final-cleanup run. If a
ProgramData profile configuration backup exists, it is restored so the demo
does not permanently replace the previous configuration.
#>

[CmdletBinding(SupportsShouldProcess = $true)]
param(
    [switch]$KeepStateFile,
    [switch]$KeepConfiguration,
    [switch]$FinalizeUserRestore
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
$configBackup = Join-Path $env:ProgramData 'BootProfileSwitcher\config\profiles.before-startup-user-application-control-demo.json'
$deploymentUninstaller = Join-Path $env:ProgramData 'BootProfileSwitcher\runtime\scripts\Uninstall-BootProfileSwitcherDeployment.ps1'
$demoRestoreConfiguration = Join-Path $env:ProgramData 'BootProfileSwitcher\runtime\config\demos\startup-user-application-control.json'

if (-not (Test-Path $deploymentUninstaller)) {
    throw "Installed deployment uninstaller not found: $deploymentUninstaller"
}

$uninstallArguments = @('-RemoveStartupHook', '-RemoveBootMenu', '-AsJson')
if ($FinalizeUserRestore) {
    $uninstallArguments += @('-RemoveUserLogonHook', '-Force')
}
else {
    if (-not (Test-Path $demoRestoreConfiguration)) {
        throw "Installed demo restore configuration not found: $demoRestoreConfiguration"
    }
    $uninstallArguments += @('-RestoreMachineBaselines', '-ScheduleUserBaselineRestore', '-UserBaselineRestoreConfigPath', $demoRestoreConfiguration)
}

$result = & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $deploymentUninstaller @uninstallArguments
if ($LASTEXITCODE -ne 0) {
    throw "Startup and User-Application Control demo removal failed with exit code ${LASTEXITCODE}: $($result | Out-String)"
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
        Write-Warning "No Startup and User-Application Control demo configuration backup found at $configBackup"
        Write-Warning "Current profile configuration was left unchanged."
    }
}

if ($FinalizeUserRestore) {
    Write-Host 'Startup and User-Application Control demo final cleanup completed.'
}
else {
    Write-Host 'Machine baseline restore and per-user baseline restore scheduling completed.'
    Write-Host 'Keep the User-Logon hook installed until all affected users have logged on and their completion evidence has been reviewed.'
    Write-Host 'Then rerun this script with -FinalizeUserRestore to remove that hook.'
}
