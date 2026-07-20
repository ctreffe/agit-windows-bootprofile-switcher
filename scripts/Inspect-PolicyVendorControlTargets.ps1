<#
.SYNOPSIS
Inspects Windows Update policy and Bitdefender control-surface metadata without changing system state.

.DESCRIPTION
Collects the first read-only inventory for the v1.8.0 Policy and Vendor Control
Foundation milestone. The script inspects known Windows Update policy registry
locations, diagnostic Windows Update service metadata and Bitdefender product,
service, scheduled-task and registry-root indicators.

The script emits output only to the current process. It does not create a
report file, change policy, stop or reconfigure services, modify scheduled
tasks, inspect vendor configuration values or bypass security-product
protection.

Detailed JSON output may disclose Windows build information, installed product
versions, service names, task names and policy metadata. Policy value data and
environment metadata are omitted unless their dedicated switches are supplied.

.PARAMETER AsJson
Emits the structured inventory as JSON. Without this switch, only a concise
count summary and disclosure warning are written.

.PARAMETER IncludePolicyValues
Includes the current data stored in the inspected Windows policy values.
Policy data can contain internal update-server URLs or other environment
details and must be reviewed locally before sharing or versioning.

.PARAMETER IncludeEnvironmentMetadata
Includes Windows product name, display version, build and PowerShell version.
This metadata can fingerprint the inspected device and must be reviewed before
sharing or versioning.
#>

[CmdletBinding()]
param(
    [switch]$AsJson,

    [switch]$IncludePolicyValues,

    [switch]$IncludeEnvironmentMetadata
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Get-ObjectPropertyValue {
    param(
        [object]$Object,
        [string]$Name,
        [AllowNull()]
        [object]$DefaultValue = $null
    )

    $property = $Object.PSObject.Properties[$Name]
    if ($null -eq $property) {
        return $DefaultValue
    }

    return $property.Value
}

function Test-IsAdministrator {
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = [Security.Principal.WindowsPrincipal]::new($identity)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function ConvertTo-SerializableRegistryValue {
    param(
        [AllowNull()]
        [object]$Value
    )

    if ($null -eq $Value) {
        return $null
    }

    if ($Value -is [byte[]]) {
        return [Convert]::ToBase64String($Value)
    }

    if ($Value -is [array]) {
        return @($Value | ForEach-Object { [string]$_ })
    }

    return $Value
}

function Read-RegistryKeyMetadata {
    param(
        [string]$Label,
        [string]$Path,
        [bool]$IncludeValues
    )

    if (-not (Test-Path -LiteralPath $Path)) {
        return [ordered]@{
            label = $Label
            path = $Path
            exists = $false
            values = @()
            error = $null
        }
    }

    try {
        $key = Get-Item -LiteralPath $Path
        $values = @($key.GetValueNames() | Sort-Object | ForEach-Object {
            $valueName = [string]$_
            $valueData = $null

            if ($IncludeValues) {
                $valueData = ConvertTo-SerializableRegistryValue -Value $key.GetValue($valueName, $null)
            }

            [ordered]@{
                name = $valueName
                kind = [string]$key.GetValueKind($valueName)
                dataIncluded = $IncludeValues
                data = $valueData
            }
        })

        return [ordered]@{
            label = $Label
            path = $Path
            exists = $true
            values = @($values)
            error = $null
        }
    }
    catch {
        return [ordered]@{
            label = $Label
            path = $Path
            exists = $true
            values = @()
            error = $_.Exception.Message
        }
    }
}

function Test-RegistryKeyPresence {
    param(
        [string]$Label,
        [string]$Path
    )

    try {
        return [ordered]@{
            label = $Label
            path = $Path
            exists = [bool](Test-Path -LiteralPath $Path)
            valuesEnumerated = $false
            error = $null
        }
    }
    catch {
        return [ordered]@{
            label = $Label
            path = $Path
            exists = $false
            valuesEnumerated = $false
            error = $_.Exception.Message
        }
    }
}

function Read-WindowsUpdateServices {
    $serviceNames = @('BITS', 'DoSvc', 'UsoSvc', 'WaaSMedicSvc', 'wuauserv')

    try {
        $filter = @($serviceNames | ForEach-Object { "Name = '$_'" }) -join ' OR '
        $items = @(Get-CimInstance -ClassName Win32_Service -Filter $filter |
            Sort-Object Name | ForEach-Object {
            [ordered]@{
                name = [string]$_.Name
                displayName = [string]$_.DisplayName
                state = [string]$_.State
                startMode = [string]$_.StartMode
                diagnosticOnly = $true
            }
        })

        return [ordered]@{ items = @($items); error = $null }
    }
    catch {
        return [ordered]@{ items = @(); error = $_.Exception.Message }
    }
}

function Read-BitdefenderProducts {
    $locations = @(
        [ordered]@{ view = 'native'; path = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall' },
        [ordered]@{ view = 'wow6432'; path = 'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall' }
    )
    $items = @()
    $errors = @()

    foreach ($location in $locations) {
        if (-not (Test-Path -LiteralPath $location.path)) {
            continue
        }

        try {
            foreach ($key in @(Get-ChildItem -LiteralPath $location.path -ErrorAction Stop)) {
                $properties = Get-ItemProperty -LiteralPath $key.PSPath -ErrorAction Stop
                $displayName = [string](Get-ObjectPropertyValue -Object $properties -Name 'DisplayName')

                if ([string]::IsNullOrWhiteSpace($displayName) -or $displayName -notlike '*Bitdefender*') {
                    continue
                }

                $items += [ordered]@{
                    registryView = $location.view
                    displayName = $displayName
                    displayVersion = [string](Get-ObjectPropertyValue -Object $properties -Name 'DisplayVersion')
                    publisher = [string](Get-ObjectPropertyValue -Object $properties -Name 'Publisher')
                }
            }
        }
        catch {
            $errors += "$($location.path): $($_.Exception.Message)"
        }
    }

    $deduplicated = @($items | Sort-Object displayName, displayVersion, publisher -Unique)
    return [ordered]@{
        items = @($deduplicated)
        error = if ($errors.Count -gt 0) { $errors -join ' | ' } else { $null }
    }
}

function Test-IsBitdefenderService {
    param(
        [string]$Name,
        [string]$DisplayName
    )

    $knownNames = @(
        'BDESVC',
        'EPIntegrationService',
        'EPProtectedService',
        'EPRedline',
        'EPSecurityService',
        'EPUpdateService',
        'VSSERV'
    )

    return (
        $Name -in $knownNames -or
        $Name -like 'BDAux*' -or
        $Name -like '*Bitdefender*' -or
        $DisplayName -like '*Bitdefender*'
    )
}

function Read-BitdefenderServices {
    try {
        $filter = "Name = 'BDESVC' OR Name = 'EPIntegrationService' OR Name = 'EPProtectedService' OR Name = 'EPRedline' OR Name = 'EPSecurityService' OR Name = 'EPUpdateService' OR Name = 'VSSERV' OR Name LIKE 'BDAux%' OR Name LIKE '%Bitdefender%' OR DisplayName LIKE '%Bitdefender%'"
        $items = @(Get-CimInstance -ClassName Win32_Service -Filter $filter | Where-Object {
            Test-IsBitdefenderService -Name ([string]$_.Name) -DisplayName ([string]$_.DisplayName)
        } | Sort-Object Name | ForEach-Object {
            [ordered]@{
                name = [string]$_.Name
                displayName = [string]$_.DisplayName
                state = [string]$_.State
                startMode = [string]$_.StartMode
                diagnosticOnly = $true
            }
        })

        return [ordered]@{ items = @($items); error = $null }
    }
    catch {
        return [ordered]@{ items = @(); error = $_.Exception.Message }
    }
}

function Read-BitdefenderScheduledTasks {
    if (-not (Get-Command -Name Get-ScheduledTask -ErrorAction SilentlyContinue)) {
        return [ordered]@{
            items = @()
            error = 'Get-ScheduledTask is not available in this PowerShell environment.'
        }
    }

    try {
        $items = @(Get-ScheduledTask | Where-Object {
            $_.TaskName -like '*Bitdefender*' -or $_.TaskPath -like '*Bitdefender*'
        } | Sort-Object TaskPath, TaskName | ForEach-Object {
            [ordered]@{
                taskName = [string]$_.TaskName
                taskPath = [string]$_.TaskPath
                state = [string]$_.State
                diagnosticOnly = $true
            }
        })

        return [ordered]@{ items = @($items); error = $null }
    }
    catch {
        return [ordered]@{ items = @(); error = $_.Exception.Message }
    }
}

function Read-EnvironmentMetadata {
    if (-not $IncludeEnvironmentMetadata) {
        return [ordered]@{
            included = $false
            windows = $null
            powershellVersion = $null
            error = $null
        }
    }

    try {
        $windows = Get-ItemProperty -LiteralPath 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion'
        return [ordered]@{
            included = $true
            windows = [ordered]@{
                productName = [string](Get-ObjectPropertyValue -Object $windows -Name 'ProductName')
                displayVersion = [string](Get-ObjectPropertyValue -Object $windows -Name 'DisplayVersion')
                currentBuild = [string](Get-ObjectPropertyValue -Object $windows -Name 'CurrentBuild')
                updateBuildRevision = [int](Get-ObjectPropertyValue -Object $windows -Name 'UBR' -DefaultValue 0)
            }
            powershellVersion = [string]$PSVersionTable.PSVersion
            error = $null
        }
    }
    catch {
        return [ordered]@{
            included = $true
            windows = $null
            powershellVersion = [string]$PSVersionTable.PSVersion
            error = $_.Exception.Message
        }
    }
}

$windowsUpdatePolicyLocations = @(
    [ordered]@{
        label = 'Group Policy - Windows Update'
        path = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate'
    },
    [ordered]@{
        label = 'Group Policy - Automatic Updates'
        path = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU'
    },
    [ordered]@{
        label = 'Policy Manager - Update'
        path = 'HKLM:\SOFTWARE\Microsoft\PolicyManager\current\device\Update'
    }
)

$windowsUpdatePolicies = @($windowsUpdatePolicyLocations | ForEach-Object {
    Read-RegistryKeyMetadata `
        -Label $_.label `
        -Path $_.path `
        -IncludeValues ([bool]$IncludePolicyValues)
})

$windowsUpdateServices = Read-WindowsUpdateServices
$bitdefenderProducts = Read-BitdefenderProducts
$bitdefenderServices = Read-BitdefenderServices
$bitdefenderTasks = Read-BitdefenderScheduledTasks
$bitdefenderRegistryRoots = @(
    Test-RegistryKeyPresence `
        -Label 'Bitdefender native registry root' `
        -Path 'HKLM:\SOFTWARE\Bitdefender'
    Test-RegistryKeyPresence `
        -Label 'Bitdefender WOW6432 registry root' `
        -Path 'HKLM:\SOFTWARE\WOW6432Node\Bitdefender'
)
$environmentMetadata = Read-EnvironmentMetadata

$result = [ordered]@{
    schemaVersion = 1
    generatedAt = (Get-Date).ToString('o')
    milestone = 'v1.8.0 Policy and Vendor Control Foundation'
    readOnly = $true
    elevated = Test-IsAdministrator
    disclosure = [ordered]@{
        writesReportFile = $false
        policyValuesIncluded = [bool]$IncludePolicyValues
        environmentMetadataIncluded = [bool]$IncludeEnvironmentMetadata
        rawVendorConfigurationInspected = $false
        reviewBeforeVersioningOrSharing = $true
    }
    environment = $environmentMetadata
    windowsUpdate = [ordered]@{
        policyLocations = @($windowsUpdatePolicies)
        diagnosticServices = @($windowsUpdateServices.items)
        serviceInventoryError = $windowsUpdateServices.error
        directServiceControlSupported = $false
        classification = 'requires-supported-policy-review'
    }
    bitdefender = [ordered]@{
        installedProducts = @($bitdefenderProducts.items)
        services = @($bitdefenderServices.items)
        scheduledTasks = @($bitdefenderTasks.items)
        registryRoots = @($bitdefenderRegistryRoots)
        inventoryErrors = [ordered]@{
            installedProducts = $bitdefenderProducts.error
            services = $bitdefenderServices.error
            scheduledTasks = $bitdefenderTasks.error
        }
        supportedControlInterface = 'not-determined'
        classification = 'requires-vendor-interface-review'
    }
}

if ($AsJson) {
    $result | ConvertTo-Json -Depth 10
    return
}

$existingPolicyLocations = @($windowsUpdatePolicies | Where-Object { $_.exists }).Count
$policyValueNames = @($windowsUpdatePolicies | ForEach-Object { @($_.values) }).Count
$bitdefenderRegistryRootCount = @($bitdefenderRegistryRoots | Where-Object { $_.exists }).Count

Write-Host 'Policy and vendor control discovery inventory completed.'
Write-Host 'No system state was modified and no report file was created.'
Write-Host ''
Write-Host ("Windows Update: policyLocations={0}, policyValueNames={1}, diagnosticServices={2}" -f `
    $existingPolicyLocations,
    $policyValueNames,
    @($windowsUpdateServices.items).Count)
Write-Host ("Bitdefender: products={0}, services={1}, scheduledTasks={2}, registryRoots={3}" -f `
    @($bitdefenderProducts.items).Count,
    @($bitdefenderServices.items).Count,
    @($bitdefenderTasks.items).Count,
    $bitdefenderRegistryRootCount)
Write-Host ''
Write-Warning 'Detailed JSON can contain product, service, task and policy metadata. Review it locally before sharing or versioning.'
