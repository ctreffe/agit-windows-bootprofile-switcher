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

    [string]$ConfigPath
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
    }
)

function Get-ProfileModuleSettings {
    param(
        [object]$ModuleSettings,
        [string]$ModuleName
    )

    if ($null -eq $ModuleSettings -or $null -eq $ModuleSettings.Value.PSObject.Properties[$ModuleName]) {
        return $null
    }

    return $ModuleSettings.Value.PSObject.Properties[$ModuleName].Value
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

function ConvertTo-StringArray {
    param(
        [object]$Value
    )

    if ($null -eq $Value) {
        return @()
    }

    return @($Value | ForEach-Object { [string]$_ } | Where-Object { -not [string]::IsNullOrWhiteSpace($_) })
}

function Merge-NetworkIsolationSettings {
    param(
        [object]$GlobalSettings,
        [object]$ProfileSettings
    )

    $globalDisable = Get-SettingValue -Object $GlobalSettings -Name 'disable' -Default $null
    $profileDisable = Get-SettingValue -Object $ProfileSettings -Name 'disable' -Default $null
    $globalExclude = Get-SettingValue -Object $GlobalSettings -Name 'exclude' -Default $null
    $profileExclude = Get-SettingValue -Object $ProfileSettings -Name 'exclude' -Default $null

    $mergedDisable = [ordered]@{}
    foreach ($propertyName in @('ethernet', 'wifi', 'cellular', 'bluetoothNetwork')) {
        $mergedDisable[$propertyName] = [bool](Get-SettingValue -Object $globalDisable -Name $propertyName -Default $false)

        $profileValue = Get-SettingValue -Object $profileDisable -Name $propertyName -Default $null
        if ($null -ne $profileValue) {
            $mergedDisable[$propertyName] = [bool]$profileValue
        }
    }

    $mergedExclude = [ordered]@{}
    foreach ($propertyName in @('macAddresses', 'interfaceDescriptions', 'interfaceAliases')) {
        $globalValues = ConvertTo-StringArray -Value (Get-SettingValue -Object $globalExclude -Name $propertyName -Default @())
        $profileValues = ConvertTo-StringArray -Value (Get-SettingValue -Object $profileExclude -Name $propertyName -Default @())
        $mergedExclude[$propertyName] = @($globalValues + $profileValues)
    }

    $merged = [ordered]@{
        dryRun = [bool](Get-SettingValue -Object $GlobalSettings -Name 'dryRun' -Default $true)
        disable = $mergedDisable
        exclude = $mergedExclude
    }

    $profileDryRun = Get-SettingValue -Object $ProfileSettings -Name 'dryRun' -Default $null
    if ($null -ne $profileDryRun) {
        $merged.dryRun = [bool]$profileDryRun
    }

    return [pscustomobject]$merged
}

if ($resolverResult.detected) {
    if (-not $configurationValidation.valid) {
        $dispatchSkippedReason = 'configuration-invalid'
    } else {
        $configuration = Get-Content -Path $ConfigPath -Raw | ConvertFrom-Json
        $configuredProfiles = @($configuration.profiles)
        $configuredProfile = $configuredProfiles | Where-Object { [string]$_.mode -eq [string]$resolverResult.mode } | Select-Object -First 1
        $globalModuleSettings = $configuration.PSObject.Properties['moduleSettings']

        if ($null -eq $configuredProfile) {
            if ($null -ne $globalModuleSettings -and $null -ne $globalModuleSettings.Value.PSObject.Properties['network-isolation']) {
                $networkIsolationModule = $moduleRegistry | Where-Object { $_.name -eq 'network-isolation' } | Select-Object -First 1
                & $networkIsolationModule.path `
                    -Mode $resolverResult.mode `
                    -Name $resolverResult.name `
                    -Identifier $resolverResult.identifier `
                    -RepoRoot $repoRoot `
                    -LogDir $LogDir `
                    -ModuleSettings $globalModuleSettings.Value.PSObject.Properties['network-isolation'].Value `
                    -Isolating $false `
                    -Detected ([bool]$resolverResult.detected)

                $modulesExecuted += [ordered]@{
                    name = $networkIsolationModule.name
                    path = $networkIsolationModule.path
                }
            }

            $dispatchSkippedReason = "profile-not-configured:$($resolverResult.mode)"
        } else {
            $profileConfigured = $true
            $customScriptsSkipped = @($configuredProfile.scripts).Count
            $moduleSettings = $configuredProfile.PSObject.Properties['moduleSettings']
            $currentRunIsolating = @($configuredProfile.modules) -contains 'network-isolation'

            if ($null -ne $globalModuleSettings -and $null -ne $globalModuleSettings.Value.PSObject.Properties['network-isolation']) {
                $networkIsolationModule = $moduleRegistry | Where-Object { $_.name -eq 'network-isolation' } | Select-Object -First 1
                $networkIsolationSettings = Merge-NetworkIsolationSettings `
                    -GlobalSettings (Get-ProfileModuleSettings -ModuleSettings $globalModuleSettings -ModuleName 'network-isolation') `
                    -ProfileSettings (Get-ProfileModuleSettings -ModuleSettings $moduleSettings -ModuleName 'network-isolation')

                & $networkIsolationModule.path `
                    -Mode $resolverResult.mode `
                    -Name $resolverResult.name `
                    -Identifier $resolverResult.identifier `
                    -RepoRoot $repoRoot `
                    -LogDir $LogDir `
                    -ModuleSettings $networkIsolationSettings `
                    -Isolating $currentRunIsolating `
                    -Detected ([bool]$resolverResult.detected)

                $modulesExecuted += [ordered]@{
                    name = $networkIsolationModule.name
                    path = $networkIsolationModule.path
                }
            }

            foreach ($moduleName in @($configuredProfile.modules)) {
                if ([string]$moduleName -eq 'network-isolation') {
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
        $globalModuleSettings = $configuration.PSObject.Properties['moduleSettings']

        if ($null -ne $globalModuleSettings -and $null -ne $globalModuleSettings.Value.PSObject.Properties['network-isolation']) {
            $networkIsolationModule = $moduleRegistry | Where-Object { $_.name -eq 'network-isolation' } | Select-Object -First 1
            & $networkIsolationModule.path `
                -Mode 'unmanaged' `
                -Name 'Unmanaged Windows startup' `
                -Identifier 'unmanaged' `
                -RepoRoot $repoRoot `
                -LogDir $LogDir `
                -ModuleSettings $globalModuleSettings.Value.PSObject.Properties['network-isolation'].Value `
                -Isolating $false `
                -Detected ([bool]$resolverResult.detected)

            $modulesExecuted += [ordered]@{
                name = $networkIsolationModule.name
                path = $networkIsolationModule.path
            }
        }

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
