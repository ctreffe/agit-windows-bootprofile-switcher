<#
.SYNOPSIS
Inspects planned Service Control actions for supported Windows services.

.DESCRIPTION
Runs the first dry-run Service Control path for BootProfile Switcher.

The module is allow-list based. The initial supported service is Windows Search
(`WSearch`). This first implementation inspects service baseline information,
dependency information and planned target actions without changing service
state.
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

    [object]$ModuleSettings
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

if (-not $dryRun) {
    throw 'service-control real apply/restore is not implemented yet; dryRun must be true.'
}

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

    $plannedActions = @()

    if ($snapshot.startMode -ne $targetStartupType) {
        $plannedActions += "set-startup-type:$targetStartupType"
    }

    if ($snapshot.state -ne $targetRunningState) {
        $plannedActions += "set-running-state:$targetRunningState"
    }

    if (@($plannedActions).Count -eq 0) {
        Write-ServiceControlLog `
            -Action 'skip' `
            -ServiceName $serviceName `
            -Reason 'already-target-state' `
            -Details ([ordered]@{
                dryRun = $dryRun
                targetStartupType = $targetStartupType
                targetRunningState = $targetRunningState
            })
        continue
    }

    Write-ServiceControlLog `
        -Action 'would-apply-target' `
        -ServiceName $serviceName `
        -Reason 'dry-run' `
        -Details ([ordered]@{
            plannedActions = @($plannedActions)
            targetStartupType = $targetStartupType
            targetRunningState = $targetRunningState
            currentStartupType = $snapshot.startMode
            currentRunningState = $snapshot.state
        })
}
