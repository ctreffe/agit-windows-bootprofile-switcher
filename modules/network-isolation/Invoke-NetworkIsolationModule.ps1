<#
.SYNOPSIS
Applies the Network Isolation profile module.

.DESCRIPTION
Disables configured hardware network adapter categories for the resolved boot
profile. The module is policy-driven: profiles choose adapter categories such
as Ethernet or Wi-Fi, and optional exclusions keep selected adapters active by
MAC address, interface description or interface alias.

The module also owns its lifecycle state. It learns the normal network adapter
baseline when the previous run was not isolating, restores that baseline after
an isolating run and records whether the current run is isolating. This lets
administrative adapter changes made during normal operation become the new
baseline without accidentally learning an isolation-created adapter state.

The implementation intentionally avoids VPN, loopback and other virtual
adapters in this first production module. Bluetooth network adapters are an
explicit opt-in exception because Windows may expose them as non-hardware
network interfaces even though they represent a real network path.
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$Mode,

    [Parameter(Mandatory = $true)]
    [string]$Name,

    [Parameter(Mandatory = $true)]
    [string]$Identifier,

    [Parameter(Mandatory = $true)]
    [string]$RepoRoot,

    [Parameter(Mandatory = $true)]
    [string]$LogDir,

    [object]$ModuleSettings,

    [bool]$Isolating = $true,

    [bool]$Detected = $false
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Get-SettingValue {
    param(
        [object]$Object,
        [string]$Name,
        [object]$Default
    )

    if ($null -eq $Object) {
        return $Default
    }

    if ($Object -is [System.Collections.IDictionary]) {
        if ($Object.Contains($Name)) {
            return $Object[$Name]
        }

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

function Normalize-MacAddress {
    param(
        [string]$MacAddress
    )

    if ([string]::IsNullOrWhiteSpace($MacAddress)) {
        return ''
    }

    return ($MacAddress -replace '[^0-9A-Fa-f]', '').ToUpperInvariant()
}

function Test-ValueMatch {
    param(
        [string]$Value,
        [string[]]$Patterns
    )

    foreach ($pattern in $Patterns) {
        if ([string]::IsNullOrWhiteSpace($pattern)) {
            continue
        }

        if ($Value -like $pattern) {
            return $true
        }
    }

    return $false
}

function Get-AdapterCategory {
    param(
        [object]$Adapter
    )

    $propertyText = @(
        (Get-AdapterProperty -Adapter $Adapter -Name 'Name')
        (Get-AdapterProperty -Adapter $Adapter -Name 'InterfaceAlias')
        (Get-AdapterProperty -Adapter $Adapter -Name 'InterfaceDescription')
        (Get-AdapterProperty -Adapter $Adapter -Name 'MediaType')
        (Get-AdapterProperty -Adapter $Adapter -Name 'PhysicalMediaType')
        (Get-AdapterProperty -Adapter $Adapter -Name 'NdisPhysicalMedium')
    ) -join ' '

    if ($propertyText -match '(?i)bluetooth') {
        return 'bluetoothNetwork'
    }

    if ($propertyText -match '(?i)(wwan|wireless wan|mobile broadband|cellular|\blte\b)') {
        return 'cellular'
    }

    if ($propertyText -match '(?i)(wi-?fi|wireless|wlan|802\.11)') {
        return 'wifi'
    }

    if ($propertyText -match '(?i)(ethernet|802\.3|gigabit|realtek pcie gbe|intel\(r\) ethernet|usb.*lan)') {
        return 'ethernet'
    }

    return 'unknown'
}

function Get-AdapterProperty {
    param(
        [object]$Adapter,
        [string]$Name
    )

    $property = $Adapter.PSObject.Properties[$Name]
    if ($null -eq $property) {
        if ($Name -eq 'InterfaceAlias') {
            return Get-AdapterProperty -Adapter $Adapter -Name 'Name'
        }

        return ''
    }

    return [string]$property.Value
}

function Write-NetworkIsolationLog {
    param(
        [string]$Action,
        [object]$Adapter,
        [string]$Category,
        [string]$Reason
    )

    $timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss zzz'
    $logFile = Join-Path $LogDir 'module-actions.log'
    $line = '{0} | module=network-isolation | mode={1} | name={2} | identifier={3} | action={4} | adapterName={5} | interfaceAlias={6} | interfaceDescription={7} | macAddress={8} | status={9} | category={10} | reason={11}' -f `
        $timestamp, `
        $Mode, `
        $Name, `
        $Identifier, `
        $Action, `
        (Get-AdapterProperty -Adapter $Adapter -Name 'Name'), `
        (Get-AdapterProperty -Adapter $Adapter -Name 'InterfaceAlias'), `
        (Get-AdapterProperty -Adapter $Adapter -Name 'InterfaceDescription'), `
        (Get-AdapterProperty -Adapter $Adapter -Name 'MacAddress'), `
        (Get-AdapterProperty -Adapter $Adapter -Name 'Status'), `
        $Category, `
        $Reason

    Add-Content -Path $logFile -Value $line -Encoding UTF8
}

function Get-AdapterSnapshot {
    param(
        [object[]]$Adapters
    )

    return @($Adapters | ForEach-Object {
        $macAddress = Get-AdapterProperty -Adapter $_ -Name 'MacAddress'
        $interfaceDescription = Get-AdapterProperty -Adapter $_ -Name 'InterfaceDescription'
        $interfaceAlias = Get-AdapterProperty -Adapter $_ -Name 'InterfaceAlias'
        $status = Get-AdapterProperty -Adapter $_ -Name 'Status'
        $adminStatus = Get-AdapterProperty -Adapter $_ -Name 'AdminStatus'

        [ordered]@{
            key = Get-AdapterKey -MacAddress $macAddress -InterfaceDescription $interfaceDescription -InterfaceAlias $interfaceAlias
            name = Get-AdapterProperty -Adapter $_ -Name 'Name'
            interfaceAlias = $interfaceAlias
            interfaceDescription = $interfaceDescription
            macAddress = $macAddress
            status = $status
            adminStatus = $adminStatus
            enabled = $adminStatus -eq 'Up'
            category = Get-AdapterCategory -Adapter $_
            hardwareInterface = [bool]$_.HardwareInterface
        }
    })
}

function Get-AdapterKey {
    param(
        [string]$MacAddress,
        [string]$InterfaceDescription,
        [string]$InterfaceAlias
    )

    $normalizedMacAddress = Normalize-MacAddress -MacAddress $MacAddress
    if (-not [string]::IsNullOrWhiteSpace($normalizedMacAddress)) {
        return "mac:$normalizedMacAddress"
    }

    return "adapter:$InterfaceDescription|$InterfaceAlias".ToLowerInvariant()
}

function Read-NetworkIsolationState {
    param(
        [string]$Path
    )

    if (-not (Test-Path $Path)) {
        return $null
    }

    return Get-Content -Path $Path -Raw | ConvertFrom-Json
}

function Save-NetworkIsolationState {
    param(
        [string]$Path,
        [object[]]$BaselineAdapters,
        [bool]$CurrentRunIsolating
    )

    $state = [ordered]@{
        schemaVersion = 1
        generatedAt = (Get-Date).ToString('o')
        lastRun = [ordered]@{
            generatedAt = (Get-Date).ToString('o')
            isolating = $CurrentRunIsolating
            detected = $Detected
            mode = $Mode
            name = $Name
            identifier = $Identifier
        }
        baseline = [ordered]@{
            updatedAt = (Get-Date).ToString('o')
            adapters = @($BaselineAdapters)
        }
    }

    New-Item -ItemType Directory -Path (Split-Path -Parent $Path) -Force | Out-Null
    $state | ConvertTo-Json -Depth 8 | Set-Content -Path $Path -Encoding UTF8
}

function Restore-NetworkBaseline {
    param(
        [object[]]$Adapters,
        [object[]]$BaselineAdapters,
        [bool]$DryRun
    )

    foreach ($baselineAdapter in @($BaselineAdapters)) {
        $currentAdapter = $Adapters | Where-Object {
            $currentKey = Get-AdapterKey `
                -MacAddress (Get-AdapterProperty -Adapter $_ -Name 'MacAddress') `
                -InterfaceDescription (Get-AdapterProperty -Adapter $_ -Name 'InterfaceDescription') `
                -InterfaceAlias (Get-AdapterProperty -Adapter $_ -Name 'InterfaceAlias')
            $currentKey -eq [string]$baselineAdapter.key
        } | Select-Object -First 1

        if ($null -eq $currentAdapter) {
            continue
        }

        $currentAdminStatus = Get-AdapterProperty -Adapter $currentAdapter -Name 'AdminStatus'
        $shouldBeEnabled = [bool]$baselineAdapter.enabled
        $currentlyEnabled = $currentAdminStatus -eq 'Up'

        if ($shouldBeEnabled -eq $currentlyEnabled) {
            Write-NetworkIsolationLog -Action 'skip-restore' -Adapter $currentAdapter -Category (Get-AdapterCategory -Adapter $currentAdapter) -Reason 'already-baseline-state'
            continue
        }

        if ($DryRun) {
            $action = if ($shouldBeEnabled) { 'would-enable' } else { 'would-disable' }
            Write-NetworkIsolationLog -Action $action -Adapter $currentAdapter -Category (Get-AdapterCategory -Adapter $currentAdapter) -Reason 'restore-baseline-dry-run'
            continue
        }

        if ($shouldBeEnabled) {
            Enable-NetAdapter -Name (Get-AdapterProperty -Adapter $currentAdapter -Name 'Name') -Confirm:$false -ErrorAction Stop
            Write-NetworkIsolationLog -Action 'enable' -Adapter $currentAdapter -Category (Get-AdapterCategory -Adapter $currentAdapter) -Reason 'restore-baseline'
        } else {
            Disable-NetAdapter -Name (Get-AdapterProperty -Adapter $currentAdapter -Name 'Name') -Confirm:$false -ErrorAction Stop
            Write-NetworkIsolationLog -Action 'disable' -Adapter $currentAdapter -Category (Get-AdapterCategory -Adapter $currentAdapter) -Reason 'restore-baseline'
        }
    }
}

New-Item -ItemType Directory -Path $LogDir -Force | Out-Null

$disableSettings = Get-SettingValue -Object $ModuleSettings -Name 'disable' -Default $null
$excludeSettings = Get-SettingValue -Object $ModuleSettings -Name 'exclude' -Default $null

$dryRun = [bool](Get-SettingValue -Object $ModuleSettings -Name 'dryRun' -Default $true)
$disableEthernet = [bool](Get-SettingValue -Object $disableSettings -Name 'ethernet' -Default $true)
$disableWifi = [bool](Get-SettingValue -Object $disableSettings -Name 'wifi' -Default $true)
$disableCellular = [bool](Get-SettingValue -Object $disableSettings -Name 'cellular' -Default $false)
$disableBluetoothNetwork = [bool](Get-SettingValue -Object $disableSettings -Name 'bluetoothNetwork' -Default $false)

$excludedMacAddresses = ConvertTo-StringArray -Value (Get-SettingValue -Object $excludeSettings -Name 'macAddresses' -Default @()) | ForEach-Object { Normalize-MacAddress -MacAddress $_ }
$excludedDescriptions = ConvertTo-StringArray -Value (Get-SettingValue -Object $excludeSettings -Name 'interfaceDescriptions' -Default @())
$excludedAliases = ConvertTo-StringArray -Value (Get-SettingValue -Object $excludeSettings -Name 'interfaceAliases' -Default @())

$categoryEnabled = @{
    ethernet = $disableEthernet
    wifi = $disableWifi
    cellular = $disableCellular
    bluetoothNetwork = $disableBluetoothNetwork
}

$statePath = Join-Path $env:ProgramData 'BootProfileSwitcher\state\network-isolation-state.json'
$previousState = Read-NetworkIsolationState -Path $statePath
$previousRunWasIsolating = $false

if ($null -ne $previousState -and $null -ne $previousState.PSObject.Properties['lastRun']) {
    $previousRunWasIsolating = [bool]$previousState.lastRun.isolating
}

$adapters = @(Get-NetAdapter -ErrorAction Stop)
$baselineCandidateAdapters = @($adapters | Where-Object {
    $candidateCategory = Get-AdapterCategory -Adapter $_
    (
        $null -ne $_.PSObject.Properties['HardwareInterface'] -and [bool]$_.HardwareInterface
    ) -or (
        $candidateCategory -eq 'bluetoothNetwork' -and [bool]$categoryEnabled[$candidateCategory]
    )
})
$currentSnapshot = Get-AdapterSnapshot -Adapters $baselineCandidateAdapters
$baselineAdapters = @()

if ($null -ne $previousState -and $null -ne $previousState.PSObject.Properties['baseline']) {
    $baselineAdapters = @($previousState.baseline.adapters)
}

if (-not $previousRunWasIsolating) {
    $baselineAdapters = @($currentSnapshot)
    $baselineAction = if ($dryRun) { 'would-update-baseline' } else { 'update-baseline' }

    foreach ($adapter in $baselineCandidateAdapters) {
        Write-NetworkIsolationLog -Action $baselineAction -Adapter $adapter -Category (Get-AdapterCategory -Adapter $adapter) -Reason 'previous-run-not-isolating'
    }
}

if ((-not $Isolating) -and $previousRunWasIsolating) {
    Restore-NetworkBaseline -Adapters $baselineCandidateAdapters -BaselineAdapters $baselineAdapters -DryRun $dryRun
}

foreach ($adapter in $adapters) {
    if (-not $Isolating) {
        continue
    }

    $category = Get-AdapterCategory -Adapter $adapter
    $hardwareInterface = $false

    if ($null -ne $adapter.PSObject.Properties['HardwareInterface']) {
        $hardwareInterface = [bool]$adapter.HardwareInterface
    }

    if (-not $hardwareInterface -and -not ($category -eq 'bluetoothNetwork' -and [bool]$categoryEnabled[$category])) {
        Write-NetworkIsolationLog -Action 'skip' -Adapter $adapter -Category $category -Reason 'not-hardware-interface'
        continue
    }

    if (-not $categoryEnabled.ContainsKey($category) -or -not [bool]$categoryEnabled[$category]) {
        Write-NetworkIsolationLog -Action 'skip' -Adapter $adapter -Category $category -Reason 'category-disabled-or-unknown'
        continue
    }

    $normalizedMacAddress = Normalize-MacAddress -MacAddress (Get-AdapterProperty -Adapter $adapter -Name 'MacAddress')

    if ($excludedMacAddresses -contains $normalizedMacAddress) {
        Write-NetworkIsolationLog -Action 'skip' -Adapter $adapter -Category $category -Reason 'excluded-mac-address'
        continue
    }

    if (Test-ValueMatch -Value (Get-AdapterProperty -Adapter $adapter -Name 'InterfaceDescription') -Patterns $excludedDescriptions) {
        Write-NetworkIsolationLog -Action 'skip' -Adapter $adapter -Category $category -Reason 'excluded-interface-description'
        continue
    }

    if (Test-ValueMatch -Value (Get-AdapterProperty -Adapter $adapter -Name 'InterfaceAlias') -Patterns $excludedAliases) {
        Write-NetworkIsolationLog -Action 'skip' -Adapter $adapter -Category $category -Reason 'excluded-interface-alias'
        continue
    }

    $adapterStatus = Get-AdapterProperty -Adapter $adapter -Name 'Status'

    if ($adapterStatus -eq 'Disabled') {
        Write-NetworkIsolationLog -Action 'skip' -Adapter $adapter -Category $category -Reason 'already-disabled'
        continue
    }

    if ($adapterStatus -eq 'Not Present') {
        Write-NetworkIsolationLog -Action 'skip' -Adapter $adapter -Category $category -Reason 'not-present'
        continue
    }

    if ($dryRun) {
        Write-NetworkIsolationLog -Action 'would-disable' -Adapter $adapter -Category $category -Reason 'dry-run'
        continue
    }

    Disable-NetAdapter -Name (Get-AdapterProperty -Adapter $adapter -Name 'Name') -Confirm:$false -ErrorAction Stop
    Write-NetworkIsolationLog -Action 'disable' -Adapter $adapter -Category $category -Reason 'policy'
}

if (-not $dryRun) {
    Save-NetworkIsolationState -Path $statePath -BaselineAdapters $baselineAdapters -CurrentRunIsolating $Isolating
}
