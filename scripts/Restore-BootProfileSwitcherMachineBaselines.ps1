<#
.SYNOPSIS
Restores machine-scoped BootProfile Switcher lifecycle baselines.

.DESCRIPTION
Runs the installed profile engine with an explicit unmanaged resolver state.
This triggers the restore lifecycle for Network Isolation, Service Control and
machine-scoped Startup and User-Application Control surfaces before deployment
infrastructure is removed.

Per-user HKCU baselines are intentionally not restored here. They require the
user-logon hook to run in each affected user's context.
#>

[CmdletBinding(SupportsShouldProcess)]
param(
    [string]$ConfigPath,

    [switch]$AsJson
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$runtimeRoot = Split-Path -Parent (Split-Path -Parent $PSCommandPath)
$machineRoot = Split-Path -Parent $runtimeRoot
$stateDir = Join-Path $runtimeRoot 'state'
$logDir = Join-Path $runtimeRoot 'logs'
$deploymentLogPath = Join-Path $machineRoot 'logs\deployment-restore.log'
$script:failureExitCode = 1

if (-not $ConfigPath) {
    $ConfigPath = Join-Path $machineRoot 'config\profiles.json'
}

function Set-Failure {
    param([int]$ExitCode, [string]$Message)
    $script:failureExitCode = $ExitCode
    throw $Message
}

function Write-DeploymentLog {
    param([string]$Message)
    New-Item -ItemType Directory -Path (Split-Path -Parent $deploymentLogPath) -Force | Out-Null
    Add-Content -Path $deploymentLogPath -Value "$((Get-Date).ToString('o')) | $Message" -Encoding UTF8
}

function Get-LifecycleModuleNames {
    param([object]$Configuration)

    $names = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)
    foreach ($profile in @($Configuration.profiles)) {
        $modules = $profile.PSObject.Properties['modules']
        if ($null -eq $modules -or $null -eq $modules.Value) {
            continue
        }

        foreach ($property in $modules.Value.PSObject.Properties) {
            if ($property.Name -in @('network-isolation', 'service-control', 'startup-user-application-control')) {
                $null = $names.Add([string]$property.Name)
            }
        }
    }

    return @($names | Sort-Object)
}

function Get-DryRunLifecycleModules {
    param([object]$Configuration)

    $names = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)
    foreach ($profile in @($Configuration.profiles)) {
        $modules = $profile.PSObject.Properties['modules']
        if ($null -eq $modules -or $null -eq $modules.Value) {
            continue
        }

        foreach ($property in $modules.Value.PSObject.Properties) {
            if ($property.Name -notin @('network-isolation', 'service-control', 'startup-user-application-control')) {
                continue
            }

            $dryRun = $property.Value.PSObject.Properties['dryRun']
            if ($null -ne $dryRun -and [bool]$dryRun.Value) {
                $null = $names.Add([string]$property.Name)
            }
        }
    }

    return @($names | Sort-Object)
}

function Write-RestoreResult {
    param(
        [bool]$Succeeded,
        [int]$ExitCode,
        [string]$ErrorMessage,
        [string[]]$LifecycleModules,
        [string[]]$EngineModules
    )

    $result = [ordered]@{
        schemaVersion = 1
        succeeded = $Succeeded
        exitCode = $ExitCode
        whatIf = [bool]$WhatIfPreference
        runtimeRoot = $runtimeRoot
        configurationPath = $ConfigPath
        lifecycleModules = @($LifecycleModules)
        engineModulesExecuted = @($EngineModules)
        userLogonRestoreRequired = @($LifecycleModules) -contains 'startup-user-application-control'
        error = $ErrorMessage
    }

    if ($AsJson) { $result | ConvertTo-Json -Depth 5 } else { [pscustomobject]$result }
}

try {
    $ConfigPath = [System.IO.Path]::GetFullPath($ConfigPath)
    $validatorScript = Join-Path $runtimeRoot 'scripts\Test-BootProfileConfiguration.ps1'
    $engineScript = Join-Path $runtimeRoot 'scripts\Invoke-ProfileEngine.ps1'

    foreach ($requiredPath in @($ConfigPath, $validatorScript, $engineScript)) {
        if (-not (Test-Path -LiteralPath $requiredPath)) {
            Set-Failure -ExitCode 1 -Message "Machine baseline restore prerequisite not found: $requiredPath"
        }
    }

    $validationOutput = & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $validatorScript -ConfigPath $ConfigPath -AsJson 2>&1
    $validationExitCode = $LASTEXITCODE
    $validation = (($validationOutput | Out-String).Trim()) | ConvertFrom-Json
    if ($validationExitCode -ne 0 -or -not $validation.valid) {
        Set-Failure -ExitCode 1 -Message "Machine baseline restore requires a valid configuration: $(@($validation.errors) -join '; ')"
    }

    $configuration = Get-Content -LiteralPath $ConfigPath -Raw | ConvertFrom-Json
    $lifecycleModules = @(Get-LifecycleModuleNames -Configuration $configuration)
    $dryRunModules = @(Get-DryRunLifecycleModules -Configuration $configuration)

    if ($WhatIfPreference) {
        Write-RestoreResult -Succeeded $true -ExitCode 0 -ErrorMessage $null -LifecycleModules $lifecycleModules -EngineModules @()
        exit 0
    }

    if ($dryRunModules.Count -gt 0) {
        Set-Failure -ExitCode 1 -Message "Machine baseline restore requires dryRun=false for configured lifecycle modules: $($dryRunModules -join ', ')"
    }

    New-Item -ItemType Directory -Path $stateDir -Force | Out-Null
    New-Item -ItemType Directory -Path $logDir -Force | Out-Null
    $resolverStatePath = Join-Path $stateDir "deployment-restore-$((Get-Date).ToString('yyyyMMdd-HHmmss')).json"
    $resolverState = [ordered]@{
        schemaVersion = 1
        generatedAt = (Get-Date).ToString('o')
        detected = $false
        profileId = $null
        mode = 'unmanaged'
        name = 'Unmanaged Windows startup'
        identifier = 'unmanaged'
        source = 'deployment-machine-baseline-restore'
        description = 'Machine baseline restore before deployment cleanup'
        currentIdentifier = $null
        outputPath = $resolverStatePath
        stateFile = Join-Path $stateDir 'boot-menu.json'
        error = $null
    }
    $resolverState | ConvertTo-Json -Depth 5 | Set-Content -Path $resolverStatePath -Encoding UTF8

    Write-DeploymentLog -Message "machine-baseline-restore-start configPath=$ConfigPath"
    $engineOutput = & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $engineScript -ResolverStatePath $resolverStatePath -LogDir $logDir -ConfigPath $ConfigPath
    $engineExitCode = $LASTEXITCODE
    if ($engineExitCode -ne 0) {
        Set-Failure -ExitCode 5 -Message "Profile engine failed during machine baseline restore with exit code $engineExitCode."
    }

    $engineResult = (($engineOutput | Out-String).Trim()) | ConvertFrom-Json
    if (-not $engineResult.configurationValid) {
        Set-Failure -ExitCode 5 -Message "Profile engine rejected the configuration during machine baseline restore: $(@($engineResult.configurationErrors) -join '; ')"
    }

    $engineModules = @($engineResult.modulesExecuted | ForEach-Object { [string]$_.name })
    Write-DeploymentLog -Message "machine-baseline-restore-success modules=$($engineModules -join ',')"
    Write-RestoreResult -Succeeded $true -ExitCode 0 -ErrorMessage $null -LifecycleModules $lifecycleModules -EngineModules $engineModules
    exit 0
}
catch {
    $message = $_.Exception.Message
    if (-not $WhatIfPreference) {
        try { Write-DeploymentLog -Message "machine-baseline-restore-failed exitCode=$script:failureExitCode error=$message" } catch { }
    }
    Write-RestoreResult -Succeeded $false -ExitCode $script:failureExitCode -ErrorMessage $message -LifecycleModules @() -EngineModules @()
    exit $script:failureExitCode
}
