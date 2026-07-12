<#
.SYNOPSIS
Runs the BootProfile Switcher profile engine.

.DESCRIPTION
Consumes the structured resolver output from state/current-boot-profile.json,
validates the profile configuration and dispatches modules selected by the
matching configured profile.

This engine intentionally keeps execution narrow. A valid machine-wide profile
configuration is required before any profile action is executed. Missing,
invalid or incomplete configuration produces a successful no-op with explicit
validation output.

Lifecycle modules may run outside profile dispatch when a valid configuration
requires state tracking across normal and managed boot profile starts. The
first such module is network-isolation, which needs to learn and restore a
network baseline even when the current startup is not an isolating profile.

For the v1.0.0 release demonstration, the engine also knows a temporary
demo-system-marker module that writes the resolved profile to ProgramData
without changing Windows behavior.

The engine passes optional per-module settings from profile configuration to
modules. This keeps module-specific policy out of the dispatcher while allowing
production modules such as network-isolation to remain configuration-driven.
#>

[CmdletBinding()]
param(
    [string]$ResolverStatePath,

    [string]$LogDir,

    [string]$ConfigPath,

    [ValidateSet('Startup', 'UserLogon')]
    [string]$ExecutionScope = 'Startup'
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$repoRoot = Split-Path -Parent (Split-Path -Parent $PSCommandPath)

if (-not $ResolverStatePath) {
    $ResolverStatePath = Join-Path $repoRoot 'state\current-boot-profile.json'
}

if (-not $LogDir) {
    $LogDir = Join-Path $repoRoot 'logs'
}

if (-not $ConfigPath) {
    $ConfigPath = Join-Path $env:ProgramData 'BootProfileSwitcher\config\profiles.json'
}

if (-not (Test-Path $ResolverStatePath)) {
    throw "Resolver state file not found at $ResolverStatePath"
}

New-Item -ItemType Directory -Path $LogDir -Force | Out-Null

$configurationValidatorScript = Join-Path $repoRoot 'scripts\Test-BootProfileConfiguration.ps1'

if (-not (Test-Path $configurationValidatorScript)) {
    throw "Configuration validator not found at $configurationValidatorScript"
}

$configurationValidationOutput = & powershell.exe `
    -NoProfile `
    -ExecutionPolicy Bypass `
    -File $configurationValidatorScript `
    -ConfigPath $ConfigPath `
    -AsJson 2>&1
$configurationValidationExitCode = $LASTEXITCODE
$configurationValidationJson = ($configurationValidationOutput | Out-String).Trim()
$configurationValidation = $configurationValidationJson | ConvertFrom-Json

$resolverResult = Get-Content -Path $ResolverStatePath -Raw | ConvertFrom-Json
$profileScriptExecuted = $false
$profileScript = $null
$modulesExecuted = @()
$profileConfigured = $false
$dispatchSkippedReason = $null
$customScriptsSkipped = 0
$moduleRegistry = @(
    [ordered]@{
        name = 'validation-log'
        path = Join-Path $repoRoot 'modules\validation-log\Invoke-ValidationLogModule.ps1'
    },
    [ordered]@{
        name = 'demo-system-marker'
        path = Join-Path $repoRoot 'modules\demo-system-marker\Invoke-DemoSystemMarkerModule.ps1'
    },
    [ordered]@{
        name = 'network-isolation'
        path = Join-Path $repoRoot 'modules\network-isolation\Invoke-NetworkIsolationModule.ps1'
    },
    [ordered]@{
        name = 'service-control'
        path = Join-Path $repoRoot 'modules\service-control\Invoke-ServiceControlModule.ps1'
    },
    [ordered]@{
        name = 'startup-user-application-control'
        path = Join-Path $repoRoot 'modules\startup-user-application-control\Invoke-StartupUserApplicationControlModule.ps1'
    }
)

function Get-ProfileModuleSettings {
    param(
        [object]$ModuleSettings,
        [string]$ModuleName
    )

    if ($null -eq $ModuleSettings) {
        return $null
    }

    $settingsObject = if ($ModuleSettings.PSObject.Properties['Value']) { $ModuleSettings.Value } else { $ModuleSettings }

    if ($null -eq $settingsObject) {
        return $null
    }

    if ($settingsObject -is [System.Collections.IDictionary]) {
        if ($settingsObject.Contains($ModuleName)) {
            return $settingsObject[$ModuleName]
        }

        return $null
    }

    $property = $settingsObject.PSObject.Properties[$ModuleName]
    if ($null -eq $property) {
        return $null
    }

    return $property.Value
}

function Get-SettingValue {
    param(
        [object]$Object,
        [string]$Name,
        [object]$Default
    )

    if ($null -eq $Object) {
        return $Default
    }

    $property = $Object.PSObject.Properties[$Name]
    if ($null -eq $property) {
        return $Default
    }

    return $property.Value
}

function Get-ProfileModuleContainer {
    param([object]$Profile)

    $modules = Get-SettingValue -Object $Profile -Name 'modules' -Default $null
    if ($null -eq $modules) {
        return $null
    }

    if ($modules -is [System.Collections.IDictionary]) {
        return $modules
    }

    if ($modules -is [array]) {
        return $modules
    }

    return $modules
}

function Get-ProfileModuleNames {
    param([object]$Profile)

    $modules = Get-ProfileModuleContainer -Profile $Profile

    if ($null -eq $modules) {
        return @()
    }

    if ($modules -is [System.Collections.IDictionary]) {
        return @($modules.Keys | ForEach-Object { [string]$_ })
    }

    if (@($modules.PSObject.Properties).Count -gt 0 -and -not ($modules -is [array])) {
        return @($modules.PSObject.Properties.Name | ForEach-Object { [string]$_ })
    }

    return @($modules | ForEach-Object { [string]$_ })
}

function Find-ConfiguredProfile {
    param(
        [object[]]$Profiles,
        [object]$ResolverResult
    )

    $profileId = if ($ResolverResult.PSObject.Properties['profileId']) { [string]$ResolverResult.profileId } else { $null }
    $mode = [string]$ResolverResult.mode

    foreach ($profile in $Profiles) {
        if ([string](Get-SettingValue -Object $profile -Name 'id' -Default $null) -eq $profileId -or
            [string](Get-SettingValue -Object $profile -Name 'id' -Default $null) -eq $mode) {
            return $profile
        }
    }

    return $null
}

function Get-NetworkIsolationSettingsForRestore {
    param(
        [object]$Configuration
    )

    foreach ($profile in @($Configuration.profiles)) {
        $modules = Get-ProfileModuleContainer -Profile $profile
        $settings = Get-ProfileModuleSettings -ModuleSettings $modules -ModuleName 'network-isolation'
        if ($null -ne $settings) {
            return $settings
        }
    }

    return $null
}

function Get-ServiceControlSettingsForRestore {
    param(
        [object]$Configuration
    )

    foreach ($profile in @($Configuration.profiles)) {
        $modules = Get-ProfileModuleContainer -Profile $profile
        $settings = Get-ProfileModuleSettings -ModuleSettings $modules -ModuleName 'service-control'
        if ($null -ne $settings) {
            return $settings
        }
    }

    return $null
}

function Get-StartupUserApplicationControlSettingsForRestore {
    param(
        [object]$Configuration
    )

    foreach ($profile in @($Configuration.profiles)) {
        $modules = Get-ProfileModuleContainer -Profile $profile
        $settings = Get-ProfileModuleSettings -ModuleSettings $modules -ModuleName 'startup-user-application-control'
        if ($null -ne $settings) {
            return $settings
        }
    }

    return $null
}

function Invoke-NetworkIsolationLifecycle {
    param(
        [object]$ModuleSettings,
        [bool]$Isolating,
        [bool]$Detected,
        [string]$Mode,
        [string]$Name,
        [string]$Identifier
    )

    if ($null -eq $ModuleSettings) {
        return $false
    }

    $networkIsolationModule = $moduleRegistry | Where-Object { $_.name -eq 'network-isolation' } | Select-Object -First 1
    & $networkIsolationModule.path `
        -Mode $Mode `
        -Name $Name `
        -Identifier $Identifier `
        -RepoRoot $repoRoot `
        -LogDir $LogDir `
        -ModuleSettings $ModuleSettings `
        -Isolating $Isolating `
        -Detected $Detected

    $script:modulesExecuted += [ordered]@{
        name = $networkIsolationModule.name
        path = $networkIsolationModule.path
    }

    return $true
}

function Invoke-ServiceControlLifecycle {
    param(
        [object]$ModuleSettings,
        [bool]$Controlling,
        [bool]$Detected,
        [string]$Mode,
        [string]$Name,
        [string]$Identifier
    )

    if ($ExecutionScope -eq 'UserLogon') {
        return $false
    }

    if ($null -eq $ModuleSettings) {
        return $false
    }

    $serviceControlModule = $moduleRegistry | Where-Object { $_.name -eq 'service-control' } | Select-Object -First 1
    & $serviceControlModule.path `
        -Mode $Mode `
        -Name $Name `
        -Identifier $Identifier `
        -RepoRoot $repoRoot `
        -LogDir $LogDir `
        -ModuleSettings $ModuleSettings `
        -Controlling $Controlling `
        -Detected $Detected

    $script:modulesExecuted += [ordered]@{
        name = $serviceControlModule.name
        path = $serviceControlModule.path
    }

    return $true
}

function Invoke-StartupUserApplicationControlLifecycle {
    param(
        [object]$ModuleSettings,
        [bool]$Controlling,
        [bool]$Detected,
        [string]$Mode,
        [string]$Name,
        [string]$Identifier
    )

    if ($null -eq $ModuleSettings) {
        return $false
    }

    $startupUserApplicationControlModule = $moduleRegistry | Where-Object { $_.name -eq 'startup-user-application-control' } | Select-Object -First 1
    & $startupUserApplicationControlModule.path `
        -Mode $Mode `
        -Name $Name `
        -Identifier $Identifier `
        -RepoRoot $repoRoot `
        -LogDir $LogDir `
        -ModuleSettings $ModuleSettings `
        -Controlling $Controlling `
        -Detected $Detected `
        -ExecutionScope $ExecutionScope

    $script:modulesExecuted += [ordered]@{
        name = $startupUserApplicationControlModule.name
        path = $startupUserApplicationControlModule.path
    }

    return $true
}

if ($resolverResult.detected) {
    if (-not $configurationValidation.valid) {
        $dispatchSkippedReason = 'configuration-invalid'
    } else {
        $configuration = Get-Content -Path $ConfigPath -Raw | ConvertFrom-Json
        $configuredProfiles = @($configuration.profiles)
        $configuredProfile = Find-ConfiguredProfile -Profiles $configuredProfiles -ResolverResult $resolverResult

        if ($null -eq $configuredProfile) {
            Invoke-NetworkIsolationLifecycle `
                -ModuleSettings (Get-NetworkIsolationSettingsForRestore -Configuration $configuration) `
                -Isolating $false `
                -Detected ([bool]$resolverResult.detected) `
                -Mode $resolverResult.mode `
                -Name $resolverResult.name `
                -Identifier $resolverResult.identifier | Out-Null

            Invoke-ServiceControlLifecycle `
                -ModuleSettings (Get-ServiceControlSettingsForRestore -Configuration $configuration) `
                -Controlling $false `
                -Detected ([bool]$resolverResult.detected) `
                -Mode $resolverResult.mode `
                -Name $resolverResult.name `
                -Identifier $resolverResult.identifier | Out-Null

            Invoke-StartupUserApplicationControlLifecycle `
                -ModuleSettings (Get-StartupUserApplicationControlSettingsForRestore -Configuration $configuration) `
                -Controlling $false `
                -Detected ([bool]$resolverResult.detected) `
                -Mode $resolverResult.mode `
                -Name $resolverResult.name `
                -Identifier $resolverResult.identifier | Out-Null

            $dispatchSkippedReason = "profile-not-configured:$($resolverResult.mode)"
        } else {
            $profileConfigured = $true
            $customScriptsSkipped = @($configuredProfile.scripts).Count
            $moduleSettings = Get-ProfileModuleContainer -Profile $configuredProfile
            $moduleNames = Get-ProfileModuleNames -Profile $configuredProfile
            $currentRunIsolating = @($moduleNames) -contains 'network-isolation'
            $currentRunControlsServices = @($moduleNames) -contains 'service-control'
            $currentRunControlsStartupUserApplications = @($moduleNames) -contains 'startup-user-application-control'
            $networkIsolationSettings = Get-ProfileModuleSettings -ModuleSettings $moduleSettings -ModuleName 'network-isolation'
            $serviceControlSettings = Get-ProfileModuleSettings -ModuleSettings $moduleSettings -ModuleName 'service-control'
            $startupUserApplicationControlSettings = Get-ProfileModuleSettings -ModuleSettings $moduleSettings -ModuleName 'startup-user-application-control'

            if ($currentRunIsolating) {
                Invoke-NetworkIsolationLifecycle `
                    -ModuleSettings $networkIsolationSettings `
                    -Isolating $true `
                    -Detected ([bool]$resolverResult.detected) `
                    -Mode $resolverResult.mode `
                    -Name $resolverResult.name `
                    -Identifier $resolverResult.identifier | Out-Null
            } else {
                Invoke-NetworkIsolationLifecycle `
                    -ModuleSettings (Get-NetworkIsolationSettingsForRestore -Configuration $configuration) `
                    -Isolating $false `
                    -Detected ([bool]$resolverResult.detected) `
                    -Mode $resolverResult.mode `
                    -Name $resolverResult.name `
                    -Identifier $resolverResult.identifier | Out-Null
            }

            if ($currentRunControlsServices) {
                Invoke-ServiceControlLifecycle `
                    -ModuleSettings $serviceControlSettings `
                    -Controlling $true `
                    -Detected ([bool]$resolverResult.detected) `
                    -Mode $resolverResult.mode `
                    -Name $resolverResult.name `
                    -Identifier $resolverResult.identifier | Out-Null
            } else {
                Invoke-ServiceControlLifecycle `
                    -ModuleSettings (Get-ServiceControlSettingsForRestore -Configuration $configuration) `
                    -Controlling $false `
                    -Detected ([bool]$resolverResult.detected) `
                    -Mode $resolverResult.mode `
                    -Name $resolverResult.name `
                    -Identifier $resolverResult.identifier | Out-Null
            }

            if ($currentRunControlsStartupUserApplications) {
                Invoke-StartupUserApplicationControlLifecycle `
                    -ModuleSettings $startupUserApplicationControlSettings `
                    -Controlling $true `
                    -Detected ([bool]$resolverResult.detected) `
                    -Mode $resolverResult.mode `
                    -Name $resolverResult.name `
                    -Identifier $resolverResult.identifier | Out-Null
            } else {
                Invoke-StartupUserApplicationControlLifecycle `
                    -ModuleSettings (Get-StartupUserApplicationControlSettingsForRestore -Configuration $configuration) `
                    -Controlling $false `
                    -Detected ([bool]$resolverResult.detected) `
                    -Mode $resolverResult.mode `
                    -Name $resolverResult.name `
                    -Identifier $resolverResult.identifier | Out-Null
            }

            foreach ($moduleName in @($moduleNames)) {
                if ([string]$moduleName -eq 'network-isolation' -or [string]$moduleName -eq 'service-control' -or [string]$moduleName -eq 'startup-user-application-control') {
                    continue
                }

                $module = $moduleRegistry | Where-Object { $_.name -eq [string]$moduleName } | Select-Object -First 1

                if ($null -eq $module) {
                    throw "Configured module is not registered: $moduleName"
                }

                if (-not (Test-Path $module.path)) {
                    throw "Module not found for $($module.name): $($module.path)"
                }

                $settingsForModule = $null
                $settingsForModule = Get-ProfileModuleSettings -ModuleSettings $moduleSettings -ModuleName $module.name

                & $module.path `
                    -Mode $resolverResult.mode `
                    -Name $resolverResult.name `
                    -Identifier $resolverResult.identifier `
                    -RepoRoot $repoRoot `
                    -LogDir $LogDir `
                    -ModuleSettings $settingsForModule

                $modulesExecuted += [ordered]@{
                    name = $module.name
                    path = $module.path
                }
            }
        }
    }
} else {
    if (-not $configurationValidation.valid) {
        $dispatchSkippedReason = 'configuration-invalid'
    } else {
        $configuration = Get-Content -Path $ConfigPath -Raw | ConvertFrom-Json
        Invoke-NetworkIsolationLifecycle `
            -ModuleSettings (Get-NetworkIsolationSettingsForRestore -Configuration $configuration) `
            -Isolating $false `
            -Detected ([bool]$resolverResult.detected) `
            -Mode 'unmanaged' `
            -Name 'Unmanaged Windows startup' `
            -Identifier 'unmanaged' | Out-Null

        Invoke-ServiceControlLifecycle `
            -ModuleSettings (Get-ServiceControlSettingsForRestore -Configuration $configuration) `
            -Controlling $false `
            -Detected ([bool]$resolverResult.detected) `
            -Mode 'unmanaged' `
            -Name 'Unmanaged Windows startup' `
            -Identifier 'unmanaged' | Out-Null

        Invoke-StartupUserApplicationControlLifecycle `
            -ModuleSettings (Get-StartupUserApplicationControlSettingsForRestore -Configuration $configuration) `
            -Controlling $false `
            -Detected ([bool]$resolverResult.detected) `
            -Mode 'unmanaged' `
            -Name 'Unmanaged Windows startup' `
            -Identifier 'unmanaged' | Out-Null

        $dispatchSkippedReason = 'profile-not-detected'
    }
}

$result = [ordered]@{
    schemaVersion = 1
    generatedAt = (Get-Date).ToString('o')
    detected = [bool]$resolverResult.detected
    mode = $resolverResult.mode
    name = $resolverResult.name
    identifier = $resolverResult.identifier
    resolverSource = $resolverResult.source
    resolverError = $resolverResult.error
    resolverStatePath = $ResolverStatePath
    configurationPath = $ConfigPath
    executionScope = $ExecutionScope
    configurationValid = [bool]$configurationValidation.valid
    configurationValidationExitCode = $configurationValidationExitCode
    configurationErrors = @($configurationValidation.errors)
    profileConfigured = $profileConfigured
    dispatchSkippedReason = $dispatchSkippedReason
    profileScriptExecuted = $profileScriptExecuted
    profileScript = $profileScript
    customScriptsSkipped = $customScriptsSkipped
    modulesExecuted = @($modulesExecuted)
}

$result | ConvertTo-Json -Depth 5
