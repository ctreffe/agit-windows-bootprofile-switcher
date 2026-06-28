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

The `network-isolation` module is the first production-oriented module. The
validator checks its global or profile-local settings so unsafe or misspelled
policies are rejected before startup execution.
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

function Test-ObjectProperty {
    param(
        [object]$Value
    )

    if ($null -eq $Value) {
        return $false
    }

    return ($Value -is [System.Collections.IDictionary] -or $Value -is [pscustomobject])
}

function Test-BooleanProperty {
    param(
        [object]$Value
    )

    return $Value -is [bool]
}

function Test-StringArrayProperty {
    param(
        [object]$Value
    )

    if (-not (Test-ArrayProperty -Value $Value)) {
        return $false
    }

    foreach ($item in @($Value)) {
        if ($null -eq $item -or -not ($item -is [string])) {
            return $false
        }
    }

    return $true
}

function Test-NetworkIsolationSettings {
    param(
        [object]$Settings,
        [string]$Prefix,
        [System.Collections.Generic.List[string]]$Errors,
        [bool]$RequireComplete
    )

    if ($null -eq $Settings) {
        if ($RequireComplete) {
            Add-ValidationError -Errors $Errors -Message "$Prefix must be present when network-isolation is enabled."
        }

        return
    }

    if (-not (Test-ObjectProperty -Value $Settings)) {
        Add-ValidationError -Errors $Errors -Message "$Prefix must be an object."
        return
    }

    $dryRun = Get-JsonProperty -Object $Settings -Name 'dryRun'
    $disable = Get-JsonProperty -Object $Settings -Name 'disable'
    $exclude = Get-JsonProperty -Object $Settings -Name 'exclude'

    if ($null -ne $dryRun -and -not (Test-BooleanProperty -Value $dryRun)) {
        Add-ValidationError -Errors $Errors -Message "$Prefix.dryRun must be a boolean."
    }

    if ($null -eq $disable) {
        if ($RequireComplete) {
            Add-ValidationError -Errors $Errors -Message "$Prefix.disable must be an object."
        }
    } elseif (-not (Test-ObjectProperty -Value $disable)) {
        Add-ValidationError -Errors $Errors -Message "$Prefix.disable must be an object."
    } else {
        foreach ($propertyName in @('ethernet', 'wifi', 'cellular', 'bluetoothNetwork')) {
            $propertyValue = Get-JsonProperty -Object $disable -Name $propertyName
            if ($null -ne $propertyValue -and -not (Test-BooleanProperty -Value $propertyValue)) {
                Add-ValidationError -Errors $Errors -Message "$Prefix.disable.$propertyName must be a boolean."
            }
        }
    }

    if ($null -eq $exclude) {
        if ($RequireComplete) {
            Add-ValidationError -Errors $Errors -Message "$Prefix.exclude must be an object."
        }
    } elseif (-not (Test-ObjectProperty -Value $exclude)) {
        Add-ValidationError -Errors $Errors -Message "$Prefix.exclude must be an object."
    } else {
        foreach ($propertyName in @('macAddresses', 'interfaceDescriptions', 'interfaceAliases')) {
            $propertyValue = Get-JsonProperty -Object $exclude -Name $propertyName
            if ($null -eq $propertyValue) {
                if ($RequireComplete) {
                    Add-ValidationError -Errors $Errors -Message "$Prefix.exclude.$propertyName must be an array."
                }
            } elseif (-not (Test-StringArrayProperty -Value $propertyValue)) {
                Add-ValidationError -Errors $Errors -Message "$Prefix.exclude.$propertyName must be an array of strings."
            }
        }
    }
}

$repoRoot = Split-Path -Parent (Split-Path -Parent $PSCommandPath)

if (-not $ConfigPath) {
    $ConfigPath = Join-Path $env:ProgramData 'BootProfileSwitcher\config\profiles.json'
}

$knownModules = @('validation-log', 'demo-system-marker', 'network-isolation')
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
    $rootModuleSettings = Get-JsonProperty -Object $configuration -Name 'moduleSettings'
    $rootNetworkIsolationSettings = if ($null -ne $rootModuleSettings) { Get-JsonProperty -Object $rootModuleSettings -Name 'network-isolation' } else { $null }

    if ($schemaVersion -ne 1) {
        Add-ValidationError -Errors $errors -Message "schemaVersion must be 1."
    }

    if ($null -ne $rootModuleSettings -and -not (Test-ObjectProperty -Value $rootModuleSettings)) {
        Add-ValidationError -Errors $errors -Message "moduleSettings must be an object when present."
    }

    Test-NetworkIsolationSettings `
        -Settings $rootNetworkIsolationSettings `
        -Prefix 'moduleSettings.network-isolation' `
        -Errors $errors `
        -RequireComplete $false

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
            $moduleSettings = Get-JsonProperty -Object $profile -Name 'moduleSettings'

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

            if ($null -ne $moduleSettings -and -not (Test-ObjectProperty -Value $moduleSettings)) {
                Add-ValidationError -Errors $errors -Message "$prefix.moduleSettings must be an object when present."
            }

            $profileNetworkIsolationSettings = if ($null -ne $moduleSettings) { Get-JsonProperty -Object $moduleSettings -Name 'network-isolation' } else { $null }

            if (@($modules) -contains 'network-isolation') {
                Test-NetworkIsolationSettings `
                    -Settings $rootNetworkIsolationSettings `
                    -Prefix 'moduleSettings.network-isolation' `
                    -Errors $errors `
                    -RequireComplete $true
            }

            Test-NetworkIsolationSettings `
                -Settings $profileNetworkIsolationSettings `
                -Prefix "$prefix.moduleSettings.network-isolation" `
                -Errors $errors `
                -RequireComplete $false
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
