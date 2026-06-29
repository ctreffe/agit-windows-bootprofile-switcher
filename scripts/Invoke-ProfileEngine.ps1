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

function Get-ConfigurationSchemaVersion {
    param([object]$Configuration)

    $schemaVersion = Get-SettingValue -Object $Configuration -Name 'schemaVersion' -Default 1
    return [int]$schemaVersion
}

function Get-ProfileIdentity {
    param([object]$Profile)

    $id = Get-SettingValue -Object $Profile -Name 'id' -Default $null
    if ($null -ne $id) {
        return [string]$id
    }

    return [string](Get-SettingValue -Object $Profile -Name 'mode' -Default $null)
}

function Get-ProfileDisplayName {
    param([object]$Profile)

    $displayName = Get-SettingValue -Object $Profile -Name 'displayName' -Default $null
    if ($null -ne $displayName) {
        return [string]$displayName
    }

    return [string](Get-SettingValue -Object $Profile -Name 'name' -Default $null)
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

function Get-ProfileModuleSettingsContainer {
    param(
        [object]$Configuration,
        [object]$Profile,
        [int]$SchemaVersion
    )

    if ($SchemaVersion -eq 2) {
        return Get-SettingValue -Object $Profile -Name 'modules' -Default $null
    }

    return $Profile.PSObject.Properties['moduleSettings']
}

function Find-ConfiguredProfile {
    param(
        [object[]]$Profiles,
        [object]$ResolverResult,
        [int]$SchemaVersion
    )

    $profileId = if ($ResolverResult.PSObject.Properties['profileId']) { [string]$ResolverResult.profileId } else { $null }
    $mode = [string]$ResolverResult.mode

    foreach ($profile in $Profiles) {
        if ($SchemaVersion -eq 2) {
            if ([string](Get-SettingValue -Object $profile -Name 'id' -Default $null) -eq $profileId -or
                [string](Get-SettingValue -Object $profile -Name 'id' -Default $null) -eq $mode) {
                return $profile
            }
        } elseif ([string](Get-SettingValue -Object $profile -Name 'mode' -Default $null) -eq $mode) {
            return $profile
        }
    }

    return $null
}

function Get-NetworkIsolationSettingsForRestore {
    param(
        [object]$Configuration,
        [int]$SchemaVersion
    )

    if ($SchemaVersion -eq 1) {
        $globalModuleSettings = $Configuration.PSObject.Properties['moduleSettings']
        return Get-ProfileModuleSettings -ModuleSettings $globalModuleSettings -ModuleName 'network-isolation'
    }

    foreach ($profile in @($Configuration.profiles)) {
        $modules = Get-ProfileModuleContainer -Profile $profile
        $settings = Get-ProfileModuleSettings -ModuleSettings $modules -ModuleName 'network-isolation'
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

if ($resolverResult.detected) {
    if (-not $configurationValidation.valid) {
        $dispatchSkippedReason = 'configuration-invalid'
    } else {
        $configuration = Get-Content -Path $ConfigPath -Raw | ConvertFrom-Json
        $schemaVersion = Get-ConfigurationSchemaVersion -Configuration $configuration
        $configuredProfiles = @($configuration.profiles)
        $configuredProfile = Find-ConfiguredProfile -Profiles $configuredProfiles -ResolverResult $resolverResult -SchemaVersion $schemaVersion

        if ($null -eq $configuredProfile) {
            Invoke-NetworkIsolationLifecycle `
                -ModuleSettings (Get-NetworkIsolationSettingsForRestore -Configuration $configuration -SchemaVersion $schemaVersion) `
                -Isolating $false `
                -Detected ([bool]$resolverResult.detected) `
                -Mode $resolverResult.mode `
                -Name $resolverResult.name `
                -Identifier $resolverResult.identifier | Out-Null

            $dispatchSkippedReason = "profile-not-configured:$($resolverResult.mode)"
        } else {
            $profileConfigured = $true
            $customScriptsSkipped = @($configuredProfile.scripts).Count
            $moduleSettings = Get-ProfileModuleSettingsContainer -Configuration $configuration -Profile $configuredProfile -SchemaVersion $schemaVersion
            $moduleNames = Get-ProfileModuleNames -Profile $configuredProfile
            $currentRunIsolating = @($moduleNames) -contains 'network-isolation'
            $networkIsolationSettings = $null

            if ($schemaVersion -eq 1) {
                $globalModuleSettings = $configuration.PSObject.Properties['moduleSettings']
                $networkIsolationSettings = Merge-NetworkIsolationSettings `
                    -GlobalSettings (Get-ProfileModuleSettings -ModuleSettings $globalModuleSettings -ModuleName 'network-isolation') `
                    -ProfileSettings (Get-ProfileModuleSettings -ModuleSettings $moduleSettings -ModuleName 'network-isolation')
            } else {
                $networkIsolationSettings = Get-ProfileModuleSettings -ModuleSettings $moduleSettings -ModuleName 'network-isolation'
            }

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
                    -ModuleSettings (Get-NetworkIsolationSettingsForRestore -Configuration $configuration -SchemaVersion $schemaVersion) `
                    -Isolating $false `
                    -Detected ([bool]$resolverResult.detected) `
                    -Mode $resolverResult.mode `
                    -Name $resolverResult.name `
                    -Identifier $resolverResult.identifier | Out-Null
            }

            foreach ($moduleName in @($moduleNames)) {
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
        $schemaVersion = Get-ConfigurationSchemaVersion -Configuration $configuration
        Invoke-NetworkIsolationLifecycle `
            -ModuleSettings (Get-NetworkIsolationSettingsForRestore -Configuration $configuration -SchemaVersion $schemaVersion) `
            -Isolating $false `
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
