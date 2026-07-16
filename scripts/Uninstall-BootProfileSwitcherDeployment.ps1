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

    [switch]$AsJson
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$runtimeRoot = Split-Path -Parent (Split-Path -Parent $PSCommandPath)
$machineRoot = Split-Path -Parent $runtimeRoot
$deploymentLogPath = Join-Path $machineRoot 'logs\deployment-uninstall.log'
$bootMenuStatePath = Join-Path $runtimeRoot 'state\boot-menu.json'
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
    if (-not ($RemoveStartupHook -or $RemoveUserLogonHook -or $RemoveBootMenu -or $RestoreMachineBaselines)) {
        Set-Failure -ExitCode 1 -Message 'Specify at least one removal option.'
    }

    $startupHookUninstaller = Join-Path $runtimeRoot 'scripts\Uninstall-StartupHook.ps1'
    $userLogonHookUninstaller = Join-Path $runtimeRoot 'scripts\Uninstall-UserLogonHook.ps1'
    $bootMenuUninstaller = Join-Path $runtimeRoot 'scripts\Uninstall-BootProfileMenu.ps1'
    $machineRestoreScript = Join-Path $runtimeRoot 'scripts\Restore-BootProfileSwitcherMachineBaselines.ps1'

    foreach ($scriptPath in @($startupHookUninstaller, $userLogonHookUninstaller, $bootMenuUninstaller)) {
        if (-not (Test-Path -LiteralPath $scriptPath)) {
            Set-Failure -ExitCode 1 -Message "Installed deployment component not found: $scriptPath"
        }
    }

    if ($RestoreMachineBaselines -and -not (Test-Path -LiteralPath $machineRestoreScript)) {
        Set-Failure -ExitCode 1 -Message "Installed machine baseline restore script not found: $machineRestoreScript"
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
