<#
.SYNOPSIS
Controls supported Windows services for BootProfile Switcher profiles.

.DESCRIPTION
Runs Service Control for BootProfile Switcher.

The module is allow-list based. The initial supported service is Windows Search
(`WSearch`). The module learns baseline service state, applies configured
target state for controlling profiles and restores the learned baseline when a
later startup no longer requests service control.
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

    [bool]$Controlling = $true,

    [bool]$Detected = $false,

    [string]$StatePath
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

function ConvertTo-Array {
    param([object]$Value)

    if ($null -eq $Value) {
        return @()
    }

    if ($Value -is [array]) {
        return @($Value)
    }

    return @($Value)
}

function Test-IsAdministrator {
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = [Security.Principal.WindowsPrincipal]::new($identity)

    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Get-DelayedAutoStart {
    param([string]$ServiceName)

    $path = "HKLM:\SYSTEM\CurrentControlSet\Services\$ServiceName"

    if (-not (Test-Path $path)) {
        return $null
    }

    $value = Get-ItemProperty -Path $path -Name 'DelayedAutoStart' -ErrorAction SilentlyContinue

    if ($null -eq $value -or $null -eq $value.PSObject.Properties['DelayedAutoStart']) {
        return $false
    }

    return [int]$value.DelayedAutoStart -eq 1
}

function Set-DelayedAutoStart {
    param(
        [string]$ServiceName,
        [AllowNull()]
        [object]$DelayedAutoStart
    )

    if ($null -eq $DelayedAutoStart) {
        return
    }

    $path = "HKLM:\SYSTEM\CurrentControlSet\Services\$ServiceName"

    if (-not (Test-Path $path)) {
        return
    }

    $value = if ([bool]$DelayedAutoStart) { 1 } else { 0 }
    Set-ItemProperty -Path $path -Name 'DelayedAutoStart' -Value $value -Type DWord -ErrorAction Stop
}

function Get-ServiceSnapshot {
    param([string]$ServiceName)

    $cimService = Get-CimInstance -ClassName Win32_Service -Filter "Name='$ServiceName'" -ErrorAction Stop

    if ($null -eq $cimService) {
        return $null
    }

    $service = Get-Service -Name $ServiceName -ErrorAction Stop

    [ordered]@{
        name = [string]$cimService.Name
        displayName = [string]$cimService.DisplayName
        exists = $true
        state = [string]$cimService.State
        status = [string]$service.Status
        startMode = [string]$cimService.StartMode
        delayedAutoStart = Get-DelayedAutoStart -ServiceName $ServiceName
        dependentServices = @($service.DependentServices | ForEach-Object { [string]$_.Name })
        requiredServices = @($service.ServicesDependedOn | ForEach-Object { [string]$_.Name })
    }
}

function Write-ServiceControlLog {
    param(
        [string]$Action,
        [string]$ServiceName,
        [string]$Reason,
        [object]$Details
    )

    $timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss zzz'
    $logFile = Join-Path $LogDir 'module-actions.log'
    $detailsJson = if ($null -eq $Details) { '{}' } else { ($Details | ConvertTo-Json -Depth 6 -Compress) }
    $line = '{0} | module=service-control | mode={1} | name={2} | identifier={3} | action={4} | service={5} | reason={6} | details={7}' -f `
        $timestamp, `
        $Mode, `
        $Name, `
        $Identifier, `
        $Action, `
        $ServiceName, `
        $Reason, `
        $detailsJson

    Add-Content -Path $logFile -Value $line -Encoding UTF8
}

function Read-ServiceControlState {
    param([string]$Path)

    if (-not (Test-Path $Path)) {
        return $null
    }

    Get-Content -Path $Path -Raw | ConvertFrom-Json
}

function Save-ServiceControlState {
    param(
        [string]$Path,
        [object[]]$BaselineServices,
        [bool]$CurrentRunControlling
    )

    $state = [ordered]@{
        schemaVersion = 1
        generatedAt = (Get-Date).ToString('o')
        lastRun = [ordered]@{
            generatedAt = (Get-Date).ToString('o')
            controlling = $CurrentRunControlling
            detected = $Detected
            mode = $Mode
            name = $Name
            identifier = $Identifier
        }
        baseline = [ordered]@{
            updatedAt = (Get-Date).ToString('o')
            services = @($BaselineServices)
        }
    }

    New-Item -ItemType Directory -Path (Split-Path -Parent $Path) -Force | Out-Null
    $state | ConvertTo-Json -Depth 8 | Set-Content -Path $Path -Encoding UTF8
}

function ConvertTo-StartupType {
    param([string]$StartMode)

    switch ($StartMode) {
        'Auto' { return 'Automatic' }
        'Manual' { return 'Manual' }
        'Disabled' { return 'Disabled' }
        default { return $StartMode }
    }
}

function Get-BaselineService {
    param(
        [object[]]$BaselineServices,
        [string]$ServiceName
    )

    $BaselineServices | Where-Object { [string]$_.name -eq $ServiceName } | Select-Object -First 1
}

function Set-ServiceStartupMode {
    param(
        [string]$ServiceName,
        [string]$StartMode
    )

    $startupType = ConvertTo-StartupType -StartMode $StartMode
    Set-Service -Name $ServiceName -StartupType $startupType -ErrorAction Stop
}

function Apply-ServiceTarget {
    param(
        [string]$ServiceName,
        [object]$Snapshot,
        [string]$TargetStartupType,
        [string]$TargetRunningState,
        [bool]$DryRun
    )

    $plannedActions = @()

    if ($Snapshot.startMode -ne $TargetStartupType) {
        $plannedActions += "set-startup-type:$TargetStartupType"
    }

    if ($Snapshot.state -ne $TargetRunningState) {
        $plannedActions += "set-running-state:$TargetRunningState"
    }

    if (@($plannedActions).Count -eq 0) {
        Write-ServiceControlLog `
            -Action 'skip' `
            -ServiceName $ServiceName `
            -Reason 'already-target-state' `
            -Details ([ordered]@{
                dryRun = $DryRun
                targetStartupType = $TargetStartupType
                targetRunningState = $TargetRunningState
            })
        return
    }

    if ($DryRun) {
        Write-ServiceControlLog `
            -Action 'would-apply-target' `
            -ServiceName $ServiceName `
            -Reason 'dry-run' `
            -Details ([ordered]@{
                plannedActions = @($plannedActions)
                targetStartupType = $TargetStartupType
                targetRunningState = $TargetRunningState
                currentStartupType = $Snapshot.startMode
                currentRunningState = $Snapshot.state
            })
        return
    }

    try {
        if ($Snapshot.state -ne $TargetRunningState -and $TargetRunningState -eq 'Stopped') {
            Stop-Service -Name $ServiceName -ErrorAction Stop
            Write-ServiceControlLog -Action 'stop-service' -ServiceName $ServiceName -Reason 'apply-target' -Details ([ordered]@{ targetRunningState = $TargetRunningState })
        }

        if ($Snapshot.startMode -ne $TargetStartupType) {
            Set-ServiceStartupMode -ServiceName $ServiceName -StartMode $TargetStartupType
            Write-ServiceControlLog -Action 'set-startup-type' -ServiceName $ServiceName -Reason 'apply-target' -Details ([ordered]@{ targetStartupType = $TargetStartupType })
        }
    } catch {
        Write-ServiceControlLog -Action 'error' -ServiceName $ServiceName -Reason 'apply-target-failed' -Details ([ordered]@{ error = $_.Exception.Message })
        throw
    }
}

function Restore-ServiceBaseline {
    param(
        [string]$ServiceName,
        [object]$BaselineService,
        [object]$Snapshot,
        [bool]$DryRun
    )

    if ($null -eq $BaselineService) {
        Write-ServiceControlLog -Action 'skip-restore' -ServiceName $ServiceName -Reason 'missing-baseline' -Details $null
        return
    }

    if (-not [bool]$BaselineService.exists) {
        Write-ServiceControlLog -Action 'skip-restore' -ServiceName $ServiceName -Reason 'baseline-service-did-not-exist' -Details $BaselineService
        return
    }

    if ($null -eq $Snapshot) {
        Write-ServiceControlLog -Action 'skip-restore' -ServiceName $ServiceName -Reason 'service-not-found' -Details $BaselineService
        return
    }

    $plannedActions = @()

    if ($Snapshot.startMode -ne [string]$BaselineService.startMode) {
        $plannedActions += "restore-startup-type:$($BaselineService.startMode)"
    }

    if ($Snapshot.delayedAutoStart -ne $BaselineService.delayedAutoStart) {
        $plannedActions += "restore-delayed-auto-start:$($BaselineService.delayedAutoStart)"
    }

    if ($Snapshot.state -ne [string]$BaselineService.state) {
        $plannedActions += "restore-running-state:$($BaselineService.state)"
    }

    if (@($plannedActions).Count -eq 0) {
        Write-ServiceControlLog -Action 'skip-restore' -ServiceName $ServiceName -Reason 'already-baseline-state' -Details $BaselineService
        return
    }

    if ($DryRun) {
        Write-ServiceControlLog `
            -Action 'would-restore-baseline' `
            -ServiceName $ServiceName `
            -Reason 'dry-run' `
            -Details ([ordered]@{
                plannedActions = @($plannedActions)
                baseline = $BaselineService
                current = $Snapshot
            })
        return
    }

    try {
        if ($Snapshot.startMode -ne [string]$BaselineService.startMode) {
            Set-ServiceStartupMode -ServiceName $ServiceName -StartMode ([string]$BaselineService.startMode)
            Write-ServiceControlLog -Action 'restore-startup-type' -ServiceName $ServiceName -Reason 'restore-baseline' -Details ([ordered]@{ baselineStartupType = $BaselineService.startMode })
        }

        if ($Snapshot.delayedAutoStart -ne $BaselineService.delayedAutoStart) {
            Set-DelayedAutoStart -ServiceName $ServiceName -DelayedAutoStart $BaselineService.delayedAutoStart
            Write-ServiceControlLog -Action 'restore-delayed-auto-start' -ServiceName $ServiceName -Reason 'restore-baseline' -Details ([ordered]@{ baselineDelayedAutoStart = $BaselineService.delayedAutoStart })
        }

        $postStartupSnapshot = Get-ServiceSnapshot -ServiceName $ServiceName
        if ($postStartupSnapshot.state -ne [string]$BaselineService.state) {
            if ([string]$BaselineService.state -eq 'Running') {
                Start-Service -Name $ServiceName -ErrorAction Stop
                Write-ServiceControlLog -Action 'start-service' -ServiceName $ServiceName -Reason 'restore-baseline' -Details ([ordered]@{ baselineRunningState = $BaselineService.state })
            } elseif ([string]$BaselineService.state -eq 'Stopped') {
                Stop-Service -Name $ServiceName -ErrorAction Stop
                Write-ServiceControlLog -Action 'stop-service' -ServiceName $ServiceName -Reason 'restore-baseline' -Details ([ordered]@{ baselineRunningState = $BaselineService.state })
            }
        }
    } catch {
        Write-ServiceControlLog -Action 'error' -ServiceName $ServiceName -Reason 'restore-baseline-failed' -Details ([ordered]@{ error = $_.Exception.Message })
        throw
    }
}

$supportedServices = @{
    WSearch = [ordered]@{
        displayPurpose = 'Windows Search indexing'
        allowedTargetStartupTypes = @('Disabled')
        allowedTargetRunningStates = @('Stopped')
    }
}

New-Item -ItemType Directory -Path $LogDir -Force | Out-Null

$dryRun = [bool](Get-SettingValue -Object $ModuleSettings -Name 'dryRun' -Default $true)
$serviceSettings = ConvertTo-Array -Value (Get-SettingValue -Object $ModuleSettings -Name 'services' -Default @())

if (-not $dryRun -and -not (Test-IsAdministrator)) {
    throw 'Service Control requires an elevated PowerShell session when dryRun is false.'
}

if (-not $StatePath) {
    $StatePath = Join-Path $env:ProgramData 'BootProfileSwitcher\state\service-control-state.json'
}

$statePath = $StatePath
$previousState = Read-ServiceControlState -Path $statePath
$previousRunWasControlling = $false
$baselineServices = @()

if ($null -ne $previousState -and $null -ne $previousState.PSObject.Properties['lastRun']) {
    $previousRunWasControlling = [bool]$previousState.lastRun.controlling
}

if ($null -ne $previousState -and $null -ne $previousState.PSObject.Properties['baseline']) {
    $baselineServices = @($previousState.baseline.services)
}

$currentSnapshots = @()

foreach ($serviceSetting in @($serviceSettings)) {
    $serviceName = [string](Get-SettingValue -Object $serviceSetting -Name 'name' -Default '')
    $target = Get-SettingValue -Object $serviceSetting -Name 'target' -Default $null
    $targetStartupType = [string](Get-SettingValue -Object $target -Name 'startupType' -Default '')
    $targetRunningState = [string](Get-SettingValue -Object $target -Name 'runningState' -Default '')

    if (-not $supportedServices.ContainsKey($serviceName)) {
        Write-ServiceControlLog -Action 'skip' -ServiceName $serviceName -Reason 'unsupported-service' -Details $null
        continue
    }

    $snapshot = Get-ServiceSnapshot -ServiceName $serviceName

    if ($null -eq $snapshot) {
        Write-ServiceControlLog -Action 'skip' -ServiceName $serviceName -Reason 'service-not-found' -Details $null
        continue
    }

    $currentSnapshots += $snapshot

    Write-ServiceControlLog `
        -Action 'inspect-baseline' `
        -ServiceName $serviceName `
        -Reason 'current-service-state' `
        -Details $snapshot

    Write-ServiceControlLog `
        -Action 'inspect-dependencies' `
        -ServiceName $serviceName `
        -Reason 'diagnostics-only' `
        -Details ([ordered]@{
            dependentServices = @($snapshot.dependentServices)
            requiredServices = @($snapshot.requiredServices)
        })
}

if (-not $previousRunWasControlling) {
    $baselineServices = @($currentSnapshots)
    $baselineAction = if ($dryRun) { 'would-update-baseline' } else { 'update-baseline' }

    foreach ($snapshot in @($currentSnapshots)) {
        Write-ServiceControlLog -Action $baselineAction -ServiceName ([string]$snapshot.name) -Reason 'previous-run-not-controlling' -Details $snapshot
    }
}

if ((-not $Controlling) -and $previousRunWasControlling) {
    foreach ($serviceSetting in @($serviceSettings)) {
        $serviceName = [string](Get-SettingValue -Object $serviceSetting -Name 'name' -Default '')
        if (-not $supportedServices.ContainsKey($serviceName)) {
            continue
        }

        $snapshot = $currentSnapshots | Where-Object { [string]$_.name -eq $serviceName } | Select-Object -First 1
        $baselineService = Get-BaselineService -BaselineServices $baselineServices -ServiceName $serviceName
        Restore-ServiceBaseline -ServiceName $serviceName -BaselineService $baselineService -Snapshot $snapshot -DryRun $dryRun
    }
}

if ($Controlling -and -not $dryRun) {
    Save-ServiceControlState -Path $statePath -BaselineServices $baselineServices -CurrentRunControlling $true
}

if ($Controlling) {
    foreach ($serviceSetting in @($serviceSettings)) {
        $serviceName = [string](Get-SettingValue -Object $serviceSetting -Name 'name' -Default '')
        $target = Get-SettingValue -Object $serviceSetting -Name 'target' -Default $null
        $targetStartupType = [string](Get-SettingValue -Object $target -Name 'startupType' -Default '')
        $targetRunningState = [string](Get-SettingValue -Object $target -Name 'runningState' -Default '')

        if (-not $supportedServices.ContainsKey($serviceName)) {
            continue
        }

        $snapshot = $currentSnapshots | Where-Object { [string]$_.name -eq $serviceName } | Select-Object -First 1
        if ($null -eq $snapshot) {
            continue
        }

        Apply-ServiceTarget `
            -ServiceName $serviceName `
            -Snapshot $snapshot `
            -TargetStartupType $targetStartupType `
            -TargetRunningState $targetRunningState `
            -DryRun $dryRun
    }
}

if (-not $dryRun) {
    Save-ServiceControlState -Path $statePath -BaselineServices $baselineServices -CurrentRunControlling $Controlling
}
