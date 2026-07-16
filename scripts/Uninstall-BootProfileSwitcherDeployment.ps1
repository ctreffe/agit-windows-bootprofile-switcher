<#
.SYNOPSIS
Removes selected machine-wide BootProfile Switcher deployment infrastructure.

.DESCRIPTION
Provides the first v1.7.0 non-interactive uninstall path for MDT and similar
deployment tools. It can remove the managed startup hook, user-logon hook and
managed boot-menu entries in that order. It deliberately preserves runtime,
configuration and module lifecycle state so a later restore step cannot be
made unavailable by premature deletion.

The script is intended to run from the installed local runtime. It never
prompts for input and reports an absent managed boot-menu state as an
idempotent no-change result.
#>

[CmdletBinding(SupportsShouldProcess)]
param(
    [switch]$RemoveStartupHook,

    [switch]$RemoveUserLogonHook,

    [switch]$RemoveBootMenu,

    [switch]$RestoreMachineBaselines,

    [switch]$ScheduleUserBaselineRestore,

    [switch]$RemoveConfiguration,

    [switch]$RemoveMachineState,

    [switch]$RemoveRuntime,

    [switch]$Force,

    [switch]$AsJson
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$runtimeRoot = Split-Path -Parent (Split-Path -Parent $PSCommandPath)
$machineRoot = Split-Path -Parent $runtimeRoot
$deploymentLogPath = Join-Path $machineRoot 'logs\deployment-uninstall.log'
$bootMenuStatePath = Join-Path $runtimeRoot 'state\boot-menu.json'
$configurationRoot = Join-Path $machineRoot 'config'
$machineStateRoot = Join-Path $machineRoot 'state'
$pendingUserRestorePath = Join-Path $machineStateRoot 'pending-user-baseline-restore.json'
$runtimeRemovalResultPath = Join-Path $machineRoot 'runtime-removal-result.json'
$script:failureExitCode = 1
$actions = [System.Collections.Generic.List[string]]::new()

function Test-Administrator {
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = [Security.Principal.WindowsPrincipal]::new($identity)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Set-Failure {
    param(
        [int]$ExitCode,
        [string]$Message
    )

    $script:failureExitCode = $ExitCode
    throw $Message
}

function Write-DeploymentLog {
    param([string]$Message)

    $logDirectory = Split-Path -Parent $deploymentLogPath
    New-Item -ItemType Directory -Path $logDirectory -Force | Out-Null
    Add-Content -Path $deploymentLogPath -Value "$((Get-Date).ToString('o')) | $Message" -Encoding UTF8
}

function Invoke-UninstallStep {
    param(
        [string]$Name,
        [int]$ExitCode,
        [scriptblock]$Action
    )

    try {
        & $Action
        $actions.Add($Name)
    }
    catch {
        $script:failureExitCode = $ExitCode
        throw
    }
}

function Write-UninstallResult {
    param(
        [bool]$Succeeded,
        [int]$ExitCode,
        [string]$ErrorMessage,
        [string]$BootMenuAction
    )

    $result = [ordered]@{
        schemaVersion = 1
        succeeded = $Succeeded
        exitCode = $ExitCode
        whatIf = [bool]$WhatIfPreference
        runtimeRoot = $runtimeRoot
        startupHookRequested = [bool]$RemoveStartupHook
        userLogonHookRequested = [bool]$RemoveUserLogonHook
        bootMenuRequested = [bool]$RemoveBootMenu
        machineBaselineRestoreRequested = [bool]$RestoreMachineBaselines
        userBaselineRestoreScheduled = [bool]$ScheduleUserBaselineRestore
        configurationRemovalRequested = [bool]$RemoveConfiguration
        machineStateRemovalRequested = [bool]$RemoveMachineState
        runtimeRemovalRequested = [bool]$RemoveRuntime
        bootMenuAction = $BootMenuAction
        actions = @($actions)
        error = $ErrorMessage
    }

    if ($AsJson) {
        $result | ConvertTo-Json -Depth 4
    }
    else {
        [pscustomobject]$result
    }
}

$bootMenuAction = 'not-requested'

try {
    if (-not ($RemoveStartupHook -or $RemoveUserLogonHook -or $RemoveBootMenu -or $RestoreMachineBaselines -or $ScheduleUserBaselineRestore -or $RemoveConfiguration -or $RemoveMachineState -or $RemoveRuntime)) {
        Set-Failure -ExitCode 1 -Message 'Specify at least one removal option.'
    }

    $startupHookUninstaller = Join-Path $runtimeRoot 'scripts\Uninstall-StartupHook.ps1'
    $userLogonHookUninstaller = Join-Path $runtimeRoot 'scripts\Uninstall-UserLogonHook.ps1'
    $bootMenuUninstaller = Join-Path $runtimeRoot 'scripts\Uninstall-BootProfileMenu.ps1'
    $machineRestoreScript = Join-Path $runtimeRoot 'scripts\Restore-BootProfileSwitcherMachineBaselines.ps1'
    $userRestoreStarter = Join-Path $runtimeRoot 'scripts\Start-BootProfileSwitcherUserBaselineRestore.ps1'
    $runtimeRemovalWorker = Join-Path $runtimeRoot 'scripts\Remove-BootProfileSwitcherRuntimeWorker.ps1'

    foreach ($scriptPath in @($startupHookUninstaller, $userLogonHookUninstaller, $bootMenuUninstaller)) {
        if (-not (Test-Path -LiteralPath $scriptPath)) {
            Set-Failure -ExitCode 1 -Message "Installed deployment component not found: $scriptPath"
        }
    }

    if ($RestoreMachineBaselines -and -not (Test-Path -LiteralPath $machineRestoreScript)) {
        Set-Failure -ExitCode 1 -Message "Installed machine baseline restore script not found: $machineRestoreScript"
    }

    if ($ScheduleUserBaselineRestore -and -not (Test-Path -LiteralPath $userRestoreStarter)) {
        Set-Failure -ExitCode 1 -Message "Installed user baseline restore starter not found: $userRestoreStarter"
    }

    if ($ScheduleUserBaselineRestore -and $RemoveUserLogonHook) {
        Set-Failure -ExitCode 1 -Message 'Do not remove the user-logon hook while scheduling per-user baseline restoration.'
    }

    if (($RemoveConfiguration -or $RemoveMachineState) -and -not $Force) {
        Set-Failure -ExitCode 1 -Message 'Removing configuration or machine state requires -Force after restore validation.'
    }

    if ($RemoveRuntime) {
        if (-not $Force) {
            Set-Failure -ExitCode 1 -Message 'Removing the runtime requires -Force after final cleanup validation.'
        }
        if ($RemoveStartupHook -or $RemoveUserLogonHook -or $RemoveBootMenu -or $RestoreMachineBaselines -or $ScheduleUserBaselineRestore -or $RemoveConfiguration -or $RemoveMachineState) {
            Set-Failure -ExitCode 1 -Message 'RemoveRuntime must run separately after all other cleanup operations have completed.'
        }
        if (-not (Test-Path -LiteralPath $runtimeRemovalWorker)) {
            Set-Failure -ExitCode 1 -Message "Runtime removal worker not found: $runtimeRemovalWorker"
        }
        if ($null -ne (Get-ScheduledTask -TaskName 'BootProfileSwitcher-StartupHook' -ErrorAction SilentlyContinue) -or $null -ne (Get-ScheduledTask -TaskName 'BootProfileSwitcher-UserLogonHook' -ErrorAction SilentlyContinue)) {
            Set-Failure -ExitCode 1 -Message 'Remove both managed hooks before removing the runtime.'
        }
        if ((Test-Path -LiteralPath $bootMenuStatePath) -or (Test-Path -LiteralPath $pendingUserRestorePath) -or (Test-Path -LiteralPath $configurationRoot) -or (Test-Path -LiteralPath $machineStateRoot)) {
            Set-Failure -ExitCode 1 -Message 'Remove managed boot-menu state, pending user restore, configuration and machine state before removing the runtime.'
        }
    }

    if ($RemoveUserLogonHook -and (Test-Path -LiteralPath $pendingUserRestorePath) -and -not $Force) {
        Set-Failure -ExitCode 1 -Message 'A pending per-user restore marker exists. Review completion evidence and use -Force before removing the user-logon hook.'
    }

    if ($RestoreMachineBaselines -and $RemoveUserLogonHook) {
        $configPath = Join-Path $machineRoot 'config\profiles.json'
        if (Test-Path -LiteralPath $configPath) {
            $configuration = Get-Content -LiteralPath $configPath -Raw | ConvertFrom-Json
            $hasUserScopedControl = @($configuration.profiles | Where-Object {
                $modules = $_.PSObject.Properties['modules']
                $null -ne $modules -and $null -ne $modules.Value -and $null -ne $modules.Value.PSObject.Properties['startup-user-application-control']
            }).Count -gt 0

            if ($hasUserScopedControl) {
                Set-Failure -ExitCode 1 -Message 'Do not remove the user-logon hook together with machine baseline restore while startup-user-application-control is configured. Per-user HKCU baselines must be restored at user logon first.'
            }
        }
    }

    if ($RemoveBootMenu) {
        $bootMenuAction = if (Test-Path -LiteralPath $bootMenuStatePath) { 'remove-managed-entries' } else { 'not-installed' }
    }

    if ($WhatIfPreference) {
        if ($RestoreMachineBaselines) {
            $actions.Add('would-restore-machine-baselines')
        }
        if ($ScheduleUserBaselineRestore) {
            $actions.Add('would-schedule-user-baseline-restore')
        }
        if ($RemoveStartupHook) {
            $actions.Add('would-remove-startup-hook')
        }
        if ($RemoveUserLogonHook) {
            $actions.Add('would-remove-user-logon-hook')
        }
        if ($RemoveBootMenu -and $bootMenuAction -eq 'remove-managed-entries') {
            $actions.Add('would-remove-managed-boot-menu')
        }
        if ($RemoveBootMenu -and $bootMenuAction -eq 'not-installed') {
            $actions.Add('boot-menu-not-installed')
        }
        if ($RemoveConfiguration) { $actions.Add('would-remove-configuration') }
        if ($RemoveMachineState) { $actions.Add('would-remove-machine-state') }
        if ($RemoveRuntime) { $actions.Add('would-schedule-runtime-removal-worker') }

        Write-UninstallResult -Succeeded $true -ExitCode 0 -ErrorMessage $null -BootMenuAction $bootMenuAction
        exit 0
    }

    if (-not (Test-Administrator)) {
        Set-Failure -ExitCode 1 -Message 'Administrator privileges are required for machine deployment removal.'
    }

    try {
        Write-DeploymentLog -Message "uninstall-start runtimeRoot=$runtimeRoot"
    }
    catch {
        Set-Failure -ExitCode 5 -Message "Could not create the deployment uninstall log: $($_.Exception.Message)"
    }

    # Remove hooks before BCD entries so no further automatic run can start
    # while managed boot infrastructure is being removed.
    if ($RestoreMachineBaselines) {
        Invoke-UninstallStep -Name 'machine-baselines-restored' -ExitCode 5 -Action {
            $restoreOutput = & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $machineRestoreScript -AsJson
            if ($LASTEXITCODE -ne 0) {
                throw "Machine baseline restore failed with exit code ${LASTEXITCODE}: $($restoreOutput | Out-String)"
            }
        }
    }

    if ($ScheduleUserBaselineRestore) {
        Invoke-UninstallStep -Name 'user-baseline-restore-scheduled' -ExitCode 5 -Action {
            $scheduleOutput = & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $userRestoreStarter -AsJson
            if ($LASTEXITCODE -ne 0) { throw "User baseline restore scheduling failed with exit code ${LASTEXITCODE}: $($scheduleOutput | Out-String)" }
        }
    }

    if ($RemoveStartupHook) {
        Invoke-UninstallStep -Name 'startup-hook-removed' -ExitCode 3 -Action {
            & $startupHookUninstaller
        }
    }

    if ($RemoveUserLogonHook) {
        Invoke-UninstallStep -Name 'user-logon-hook-removed' -ExitCode 3 -Action {
            & $userLogonHookUninstaller
        }
    }

    if ($RemoveBootMenu -and $bootMenuAction -eq 'remove-managed-entries') {
        Invoke-UninstallStep -Name 'boot-menu-removed' -ExitCode 4 -Action {
            & $bootMenuUninstaller
        }
    }
    elseif ($RemoveBootMenu) {
        $actions.Add('boot-menu-not-installed')
    }

    if ($RemoveConfiguration -and (Test-Path -LiteralPath $configurationRoot)) {
        Invoke-UninstallStep -Name 'configuration-removed' -ExitCode 5 -Action {
            Remove-Item -LiteralPath $configurationRoot -Recurse -Force
        }
    }

    if ($RemoveMachineState -and (Test-Path -LiteralPath $machineStateRoot)) {
        Invoke-UninstallStep -Name 'machine-state-removed' -ExitCode 5 -Action {
            Remove-Item -LiteralPath $machineStateRoot -Recurse -Force
        }
    }

    if ($RemoveRuntime) {
        $workerDirectory = Join-Path $env:TEMP "BootProfileSwitcherCleanup\$([guid]::NewGuid().ToString())"
        $workerPath = Join-Path $workerDirectory 'Remove-BootProfileSwitcherRuntimeWorker.ps1'
        Invoke-UninstallStep -Name 'runtime-removal-worker-scheduled' -ExitCode 5 -Action {
            New-Item -ItemType Directory -Path $workerDirectory -Force | Out-Null
            Copy-Item -LiteralPath $runtimeRemovalWorker -Destination $workerPath -Force
            Start-Process -FilePath 'powershell.exe' -WindowStyle Hidden -ArgumentList @('-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', $workerPath, '-RuntimeRoot', $runtimeRoot, '-ResultPath', $runtimeRemovalResultPath)
        }
    }

    Write-DeploymentLog -Message "uninstall-success actions=$(@($actions) -join ',') bootMenuAction=$bootMenuAction"
    Write-UninstallResult -Succeeded $true -ExitCode 0 -ErrorMessage $null -BootMenuAction $bootMenuAction
    exit 0
}
catch {
    $message = $_.Exception.Message

    if (-not $WhatIfPreference) {
        try {
            Write-DeploymentLog -Message "uninstall-failed exitCode=$script:failureExitCode error=$message"
        }
        catch {
            # Preserve the original deployment error when logging is unavailable.
        }
    }

    Write-UninstallResult `
        -Succeeded $false `
        -ExitCode $script:failureExitCode `
        -ErrorMessage $message `
        -BootMenuAction $bootMenuAction
    exit $script:failureExitCode
}
