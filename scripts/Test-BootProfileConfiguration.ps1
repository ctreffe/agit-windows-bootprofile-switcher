<#
.SYNOPSIS
Validates the BootProfile Switcher profile configuration schema.

.DESCRIPTION
Reads a profile configuration JSON file and validates the first v0.7.x schema.
The validator does not apply system changes, execute modules or run custom
scripts. It only checks that the configuration is structurally valid and
references known modules.

The temporary `demo-system-marker` module is accepted for the v1.0.0 release
demonstration and should be removed once production modules exist.
#>

[CmdletBinding()]
param(
    [string]$ConfigPath,

    [switch]$AsJson
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Add-Type -AssemblyName System.Web.Extensions

function Add-ValidationError {
    param(
        [System.Collections.Generic.List[string]]$Errors,
        [string]$Message
    )

    $Errors.Add($Message)
}

function Test-ArrayProperty {
    param(
        [object]$Value
    )

    if ($null -eq $Value) {
        return $false
    }

    return $Value -is [array]
}

function Get-JsonProperty {
    param(
        [object]$Object,
        [string]$Name
    )

    if ($null -eq $Object) {
        return $null
    }

    if ($Object -is [System.Collections.IDictionary]) {
        if ($Object.ContainsKey($Name)) {
            Write-Output -NoEnumerate $Object[$Name]
            return
        }

        return $null
    }

    $property = $Object.PSObject.Properties[$Name]
    if ($null -eq $property) {
        return $null
    }

    Write-Output -NoEnumerate $property.Value
}

$repoRoot = Split-Path -Parent (Split-Path -Parent $PSCommandPath)

if (-not $ConfigPath) {
    $ConfigPath = Join-Path $env:ProgramData 'BootProfileSwitcher\config\profiles.json'
}

$knownModules = @('validation-log', 'demo-system-marker')
$errors = [System.Collections.Generic.List[string]]::new()
$configuration = $null

if (-not (Test-Path $ConfigPath)) {
    Add-ValidationError -Errors $errors -Message "Configuration file not found: $ConfigPath"
} else {
    try {
        $jsonText = Get-Content -Path $ConfigPath -Raw
        $serializer = [System.Web.Script.Serialization.JavaScriptSerializer]::new()
        $configuration = $serializer.DeserializeObject($jsonText)
    } catch {
        Add-ValidationError -Errors $errors -Message "Configuration file is not valid JSON: $($_.Exception.Message)"
    }
}

if ($configuration) {
    $schemaVersion = Get-JsonProperty -Object $configuration -Name 'schemaVersion'
    $profiles = Get-JsonProperty -Object $configuration -Name 'profiles'

    if ($schemaVersion -ne 1) {
        Add-ValidationError -Errors $errors -Message "schemaVersion must be 1."
    }

    if (-not (Test-ArrayProperty -Value $profiles)) {
        Add-ValidationError -Errors $errors -Message "profiles must be an array."
    } else {
        $seenNames = @{}
        $seenModes = @{}

        for ($index = 0; $index -lt $profiles.Count; $index++) {
            $profile = $profiles[$index]
            $prefix = "profiles[$index]"
            $name = [string](Get-JsonProperty -Object $profile -Name 'name')
            $mode = [string](Get-JsonProperty -Object $profile -Name 'mode')
            $modules = Get-JsonProperty -Object $profile -Name 'modules'
            $scripts = Get-JsonProperty -Object $profile -Name 'scripts'

            if ([string]::IsNullOrWhiteSpace($name)) {
                Add-ValidationError -Errors $errors -Message "$prefix.name must not be empty."
            } elseif ($seenNames.ContainsKey($name)) {
                Add-ValidationError -Errors $errors -Message "$prefix.name must be unique: $name"
            } else {
                $seenNames[$name] = $true
            }

            if ([string]::IsNullOrWhiteSpace($mode)) {
                Add-ValidationError -Errors $errors -Message "$prefix.mode must not be empty."
            } elseif ($seenModes.ContainsKey($mode)) {
                Add-ValidationError -Errors $errors -Message "$prefix.mode must be unique: $mode"
            } else {
                $seenModes[$mode] = $true
            }

            if (-not (Test-ArrayProperty -Value $modules)) {
                Add-ValidationError -Errors $errors -Message "$prefix.modules must be an array."
            } else {
                foreach ($moduleName in @($modules)) {
                    if ([string]::IsNullOrWhiteSpace([string]$moduleName)) {
                        Add-ValidationError -Errors $errors -Message "$prefix.modules must not contain empty module names."
                    } elseif ($knownModules -notcontains [string]$moduleName) {
                        Add-ValidationError -Errors $errors -Message "$prefix.modules references unknown module: $moduleName"
                    }
                }
            }

            if (-not (Test-ArrayProperty -Value $scripts)) {
                Add-ValidationError -Errors $errors -Message "$prefix.scripts must be an array."
            }
        }
    }
}

$result = [ordered]@{
    schemaVersion = 1
    generatedAt = (Get-Date).ToString('o')
    valid = $errors.Count -eq 0
    configPath = $ConfigPath
    knownModules = $knownModules
    errors = @($errors)
}

$json = $result | ConvertTo-Json -Depth 5

if ($AsJson) {
    $json
} elseif ($result.valid) {
    Write-Host 'BootProfile Switcher configuration is valid.'
    Write-Host "Config: $ConfigPath"
} else {
    Write-Warning 'BootProfile Switcher configuration is invalid.'
    foreach ($validationError in $errors) {
        Write-Host "- $validationError"
    }
}

if (-not $result.valid) {
    exit 1
}
