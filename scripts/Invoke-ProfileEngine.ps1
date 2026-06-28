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

For the v1.0.0 release demonstration, the engine also knows a temporary
demo-system-marker module that writes the resolved profile to ProgramData
without changing Windows behavior.
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
    }
)

if ($resolverResult.detected) {
    if (-not $configurationValidation.valid) {
        $dispatchSkippedReason = 'configuration-invalid'
    } else {
        $configuration = Get-Content -Path $ConfigPath -Raw | ConvertFrom-Json
        $configuredProfiles = @($configuration.profiles)
        $configuredProfile = $configuredProfiles | Where-Object { [string]$_.mode -eq [string]$resolverResult.mode } | Select-Object -First 1

        if ($null -eq $configuredProfile) {
            $dispatchSkippedReason = "profile-not-configured:$($resolverResult.mode)"
        } else {
            $profileConfigured = $true
            $customScriptsSkipped = @($configuredProfile.scripts).Count

            foreach ($moduleName in @($configuredProfile.modules)) {
                $module = $moduleRegistry | Where-Object { $_.name -eq [string]$moduleName } | Select-Object -First 1

                if ($null -eq $module) {
                    throw "Configured module is not registered: $moduleName"
                }

                if (-not (Test-Path $module.path)) {
                    throw "Module not found for $($module.name): $($module.path)"
                }

                & $module.path `
                    -Mode $resolverResult.mode `
                    -Name $resolverResult.name `
                    -Identifier $resolverResult.identifier `
                    -RepoRoot $repoRoot `
                    -LogDir $LogDir

                $modulesExecuted += [ordered]@{
                    name = $module.name
                    path = $module.path
                }
            }
        }
    }
} else {
    $dispatchSkippedReason = 'profile-not-detected'
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
