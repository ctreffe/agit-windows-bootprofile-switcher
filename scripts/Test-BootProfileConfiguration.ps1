<#
.SYNOPSIS
Validates the BootProfile Switcher profile configuration schema.

.DESCRIPTION
Reads a profile configuration JSON file and validates supported BootProfile
Switcher configuration formats.
The validator does not apply system changes, execute modules or run custom
scripts. It only checks that the configuration is structurally valid and
references known modules.

The temporary `demo-system-marker` module is accepted for the v1.0.0 release
demonstration and should be removed once production modules exist.

The `network-isolation` module is the first production-oriented module. The
validator checks its settings so unsafe or misspelled policies are rejected
before startup execution.
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

function Get-JsonPropertyNames {
    param(
        [object]$Object
    )

    if ($null -eq $Object) {
        return @()
    }

    if ($Object -is [System.Collections.IDictionary]) {
        return @($Object.Keys | ForEach-Object { [string]$_ })
    }

    return @($Object.PSObject.Properties.Name)
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

function Test-IntegerProperty {
    param(
        [object]$Value
    )

    return $Value -is [int]
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

function Test-ModuleSettingsContainer {
    param(
        [object]$Settings,
        [string]$Prefix,
        [System.Collections.Generic.List[string]]$Errors,
        [string[]]$KnownModules
    )

    if ($null -eq $Settings) {
        return
    }

    if (-not (Test-ObjectProperty -Value $Settings)) {
        Add-ValidationError -Errors $Errors -Message "$Prefix must be an object when present."
        return
    }

    foreach ($property in $Settings.Keys) {
        if ($KnownModules -notcontains [string]$property) {
            Add-ValidationError -Errors $Errors -Message "$Prefix references unknown module settings: $property"
        }
    }
}

function Test-AllowedProperties {
    param(
        [object]$Object,
        [string]$Prefix,
        [string[]]$AllowedProperties,
        [System.Collections.Generic.List[string]]$Errors
    )

    foreach ($propertyName in @(Get-JsonPropertyNames -Object $Object)) {
        if ($AllowedProperties -notcontains $propertyName) {
            Add-ValidationError -Errors $Errors -Message "$Prefix contains unsupported property: $propertyName"
        }
    }
}

function Test-BootMenuV2 {
    param(
        [object]$BootMenu,
        [System.Collections.Generic.List[string]]$Errors
    )

    if (-not (Test-ObjectProperty -Value $BootMenu)) {
        Add-ValidationError -Errors $Errors -Message 'bootMenu must be an object.'
        return
    }

    Test-AllowedProperties `
        -Object $BootMenu `
        -Prefix 'bootMenu' `
        -AllowedProperties @('timeoutSeconds', 'sourceEntry', 'defaultEntry') `
        -Errors $Errors

    $timeoutSeconds = Get-JsonProperty -Object $BootMenu -Name 'timeoutSeconds'
    $sourceEntry = [string](Get-JsonProperty -Object $BootMenu -Name 'sourceEntry')
    $defaultEntry = Get-JsonProperty -Object $BootMenu -Name 'defaultEntry'

    if (-not (Test-IntegerProperty -Value $timeoutSeconds) -or $timeoutSeconds -lt 0) {
        Add-ValidationError -Errors $Errors -Message 'bootMenu.timeoutSeconds must be a non-negative integer.'
    }

    if ([string]::IsNullOrWhiteSpace($sourceEntry)) {
        Add-ValidationError -Errors $Errors -Message 'bootMenu.sourceEntry must not be empty.'
    }

    if (-not (Test-ObjectProperty -Value $defaultEntry)) {
        Add-ValidationError -Errors $Errors -Message 'bootMenu.defaultEntry must be an object.'
        return
    }

    Test-AllowedProperties `
        -Object $defaultEntry `
        -Prefix 'bootMenu.defaultEntry' `
        -AllowedProperties @('rename', 'displayName', 'hide') `
        -Errors $Errors

    $rename = Get-JsonProperty -Object $defaultEntry -Name 'rename'
    $displayName = Get-JsonProperty -Object $defaultEntry -Name 'displayName'
    $hide = Get-JsonProperty -Object $defaultEntry -Name 'hide'

    if (-not (Test-BooleanProperty -Value $rename)) {
        Add-ValidationError -Errors $Errors -Message 'bootMenu.defaultEntry.rename must be a boolean.'
    }

    if (-not (Test-BooleanProperty -Value $hide)) {
        Add-ValidationError -Errors $Errors -Message 'bootMenu.defaultEntry.hide must be a boolean.'
    }

    if ($null -ne $displayName -and -not ($displayName -is [string])) {
        Add-ValidationError -Errors $Errors -Message 'bootMenu.defaultEntry.displayName must be null or a string.'
    }

    if ($rename -eq $true -and [string]::IsNullOrWhiteSpace([string]$displayName)) {
        Add-ValidationError -Errors $Errors -Message 'bootMenu.defaultEntry.displayName must not be empty when rename is true.'
    }

    if ($rename -eq $false -and $null -ne $displayName) {
        Add-ValidationError -Errors $Errors -Message 'bootMenu.defaultEntry.displayName must be null when rename is false.'
    }
}

$repoRoot = Split-Path -Parent (Split-Path -Parent $PSCommandPath)

if (-not $ConfigPath) {
    $ConfigPath = Join-Path $env:ProgramData 'BootProfileSwitcher\config\profiles.json'
}

$knownModules = @('validation-log', 'demo-system-marker', 'network-isolation')
$errors = [System.Collections.Generic.List[string]]::new()
$configuration = $null
$schemaVersion = $null

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

    if ($schemaVersion -notin @(1, 2)) {
        Add-ValidationError -Errors $errors -Message 'schemaVersion must be 1 or 2.'
    } elseif ($schemaVersion -eq 1) {
        $rootModuleSettings = Get-JsonProperty -Object $configuration -Name 'moduleSettings'
        $rootNetworkIsolationSettings = if ($null -ne $rootModuleSettings) { Get-JsonProperty -Object $rootModuleSettings -Name 'network-isolation' } else { $null }

        if ($null -ne $rootModuleSettings -and -not (Test-ObjectProperty -Value $rootModuleSettings)) {
            Add-ValidationError -Errors $errors -Message 'moduleSettings must be an object when present.'
        }

        Test-NetworkIsolationSettings `
            -Settings $rootNetworkIsolationSettings `
            -Prefix 'moduleSettings.network-isolation' `
            -Errors $errors `
            -RequireComplete $false

        if (-not (Test-ArrayProperty -Value $profiles)) {
            Add-ValidationError -Errors $errors -Message 'profiles must be an array.'
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

                Test-NetworkIsolationSettings `
                    -Settings $profileNetworkIsolationSettings `
                    -Prefix "$prefix.moduleSettings.network-isolation" `
                    -Errors $errors `
                    -RequireComplete $false

                if (@($modules) -contains 'network-isolation') {
                    Test-NetworkIsolationSettings `
                        -Settings $rootNetworkIsolationSettings `
                        -Prefix 'moduleSettings.network-isolation' `
                        -Errors $errors `
                        -RequireComplete $true
                }
            }
        }
    } elseif ($schemaVersion -eq 2) {
        $bootMenu = Get-JsonProperty -Object $configuration -Name 'bootMenu'

        Test-AllowedProperties `
            -Object $configuration `
            -Prefix 'configuration' `
            -AllowedProperties @('schemaVersion', 'bootMenu', 'profiles') `
            -Errors $errors

        Test-BootMenuV2 -BootMenu $bootMenu -Errors $errors

        if (-not (Test-ArrayProperty -Value $profiles)) {
            Add-ValidationError -Errors $errors -Message 'profiles must be an array.'
        } else {
            $seenIds = @{}
            $seenDisplayNames = @{}

            for ($index = 0; $index -lt $profiles.Count; $index++) {
                $profile = $profiles[$index]
                $prefix = "profiles[$index]"

                Test-AllowedProperties `
                    -Object $profile `
                    -Prefix $prefix `
                    -AllowedProperties @('id', 'displayName', 'bootMenu', 'modules', 'scripts') `
                    -Errors $errors

                $id = [string](Get-JsonProperty -Object $profile -Name 'id')
                $displayName = [string](Get-JsonProperty -Object $profile -Name 'displayName')
                $profileBootMenu = Get-JsonProperty -Object $profile -Name 'bootMenu'
                $modules = Get-JsonProperty -Object $profile -Name 'modules'
                $scripts = Get-JsonProperty -Object $profile -Name 'scripts'

                if ([string]::IsNullOrWhiteSpace($id)) {
                    Add-ValidationError -Errors $errors -Message "$prefix.id must not be empty."
                } elseif ($id -notmatch '^[a-z][a-z0-9]*(?:-[a-z0-9]+)*$') {
                    Add-ValidationError -Errors $errors -Message "$prefix.id must use lowercase letters, numbers and single hyphen separators."
                } elseif ($seenIds.ContainsKey($id)) {
                    Add-ValidationError -Errors $errors -Message "$prefix.id must be unique: $id"
                } else {
                    $seenIds[$id] = $true
                }

                if ([string]::IsNullOrWhiteSpace($displayName)) {
                    Add-ValidationError -Errors $errors -Message "$prefix.displayName must not be empty."
                } elseif ($seenDisplayNames.ContainsKey($displayName)) {
                    Add-ValidationError -Errors $errors -Message "$prefix.displayName must be unique: $displayName"
                } else {
                    $seenDisplayNames[$displayName] = $true
                }

                if (-not (Test-ObjectProperty -Value $profileBootMenu)) {
                    Add-ValidationError -Errors $errors -Message "$prefix.bootMenu must be an object."
                } else {
                    Test-AllowedProperties `
                        -Object $profileBootMenu `
                        -Prefix "$prefix.bootMenu" `
                        -AllowedProperties @('enabled') `
                        -Errors $errors

                    $bootMenuEnabled = Get-JsonProperty -Object $profileBootMenu -Name 'enabled'
                    if (-not (Test-BooleanProperty -Value $bootMenuEnabled)) {
                        Add-ValidationError -Errors $errors -Message "$prefix.bootMenu.enabled must be a boolean."
                    }
                }

                if (-not (Test-ObjectProperty -Value $modules)) {
                    Add-ValidationError -Errors $errors -Message "$prefix.modules must be an object."
                } else {
                    if (@($modules.Keys).Count -eq 0) {
                        Add-ValidationError -Errors $errors -Message "$prefix.modules must contain at least one module."
                    }

                    Test-ModuleSettingsContainer -Settings $modules -Prefix "$prefix.modules" -Errors $errors -KnownModules $knownModules

                    foreach ($moduleName in $modules.Keys) {
                        if ([string]::IsNullOrWhiteSpace([string]$moduleName)) {
                            Add-ValidationError -Errors $errors -Message "$prefix.modules must not contain empty module names."
                        }
                    }
                }

                if (-not (Test-StringArrayProperty -Value $scripts)) {
                    Add-ValidationError -Errors $errors -Message "$prefix.scripts must be an array of strings."
                }

                $profileNetworkIsolationSettings = if ($null -ne $modules) { Get-JsonProperty -Object $modules -Name 'network-isolation' } else { $null }

                Test-NetworkIsolationSettings `
                    -Settings $profileNetworkIsolationSettings `
                    -Prefix "$prefix.modules.network-isolation" `
                    -Errors $errors `
                    -RequireComplete $false

                if ($null -ne $profileNetworkIsolationSettings) {
                    Test-NetworkIsolationSettings `
                        -Settings $profileNetworkIsolationSettings `
                        -Prefix "$prefix.modules.network-isolation" `
                        -Errors $errors `
                        -RequireComplete $true
                }
            }
        }
    }
}

$result = [ordered]@{
    schemaVersion = $schemaVersion
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
