<#
.SYNOPSIS
Inspects supported startup and user-application control targets.

.DESCRIPTION
Runs the first dry-run Startup and User-Application Control module path for
BootProfile Switcher.

The module is allow-list based. The initial supported application targets are
Teams, OneDrive, ownCloud and Microsoft Office. This first implementation is
read-only: it inventories known startup surfaces and logs what would be
controlled, but it does not edit registry values, change scheduled tasks or
terminate processes.
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

function Write-StartupUserApplicationControlLog {
    param(
        [string]$Action,
        [string]$ApplicationId,
        [string]$Surface,
        [string]$Reason,
        [object]$Details
    )

    $timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss zzz'
    $logFile = Join-Path $LogDir 'module-actions.log'
    $detailsJson = if ($null -eq $Details) { 'null' } else { $Details | ConvertTo-Json -Compress -Depth 8 }
    $line = '{0} | module=startup-user-application-control | mode={1} | name={2} | identifier={3} | application={4} | surface={5} | action={6} | reason={7} | details={8}' -f `
        $timestamp,
        $Mode,
        $Name,
        $Identifier,
        $ApplicationId,
        $Surface,
        $Action,
        $Reason,
        $detailsJson

    Add-Content -Path $logFile -Value $line -Encoding UTF8
}

function Read-StartupUserApplicationControlState {
    param([string]$Path)

    if (-not (Test-Path $Path)) {
        return $null
    }

    Get-Content -Path $Path -Raw | ConvertFrom-Json
}

function Save-StartupUserApplicationControlState {
    param(
        [string]$Path,
        [object[]]$BaselineRegistryValues,
        [object[]]$BaselineScheduledTasks,
        [bool]$CurrentRunControlling
    )

    $generatedAt = (Get-Date).ToString('o')
    $state = [ordered]@{
        schemaVersion = 1
        generatedAt = $generatedAt
        lastRun = [ordered]@{
            generatedAt = $generatedAt
            controlling = $CurrentRunControlling
            detected = $Detected
            mode = $Mode
            name = $Name
            identifier = $Identifier
        }
        baseline = [ordered]@{
            updatedAt = $generatedAt
            registryValues = @($BaselineRegistryValues)
            scheduledTasks = @($BaselineScheduledTasks)
        }
    }

    New-Item -ItemType Directory -Path (Split-Path -Parent $Path) -Force | Out-Null
    $state | ConvertTo-Json -Depth 10 | Set-Content -Path $Path -Encoding UTF8
}

function Get-StartupRegistryValueSnapshots {
    param([object[]]$Definitions)

    $snapshots = @()

    foreach ($definition in @($Definitions)) {
        foreach ($registryValue in @($definition.registryValues)) {
            $path = [string]$registryValue.path
            $valueName = [string]$registryValue.valueName

            if (-not (Test-Path $path)) {
                $snapshots += [ordered]@{
                    applicationId = [string]$definition.id
                    registryPath = $path
                    valueName = $valueName
                    exists = $false
                    command = $null
                    valueKind = $null
                }
                continue
            }

            $key = Get-Item -Path $path -ErrorAction Stop
            $item = Get-ItemProperty -Path $path -Name $valueName -ErrorAction SilentlyContinue
            $exists = $null -ne $item -and $null -ne $item.PSObject.Properties[$valueName]
            $command = if ($exists) { [string]$item.$valueName } else { $null }
            $valueKind = if ($exists) {
                try { [string]$key.GetValueKind($valueName) } catch { $null }
            } else {
                $null
            }

            $snapshots += [ordered]@{
                applicationId = [string]$definition.id
                registryPath = $path
                valueName = $valueName
                exists = [bool]$exists
                command = $command
                valueKind = $valueKind
            }
        }
    }

    return @($snapshots)
}

function Get-ScheduledTaskMatches {
    param([object[]]$Definitions)

    $patterns = @($Definitions | ForEach-Object { @($_.scheduledTaskNamePatterns) } | Where-Object { -not [string]::IsNullOrWhiteSpace([string]$_) })
    if ($patterns.Count -eq 0) {
        return @()
    }

    if (-not (Get-Command -Name Get-ScheduledTask -ErrorAction SilentlyContinue)) {
        return @()
    }

    $allTasks = @(Get-ScheduledTask -ErrorAction Stop)
    $matches = @()

    foreach ($definition in @($Definitions)) {
        foreach ($taskPattern in @($definition.scheduledTaskNamePatterns)) {
            $matches += @($allTasks | Where-Object {
                ([string]$_.TaskName) -like ([string]$taskPattern)
            } | ForEach-Object {
                [ordered]@{
                    applicationId = [string]$definition.id
                    taskPath = [string]$_.TaskPath
                    taskName = [string]$_.TaskName
                    exists = $true
                    state = [string]$_.State
                    enabled = try { [bool]$_.Settings.Enabled } catch { $null }
                }
            })
        }
    }

    return @($matches)
}

function Get-ProcessMatches {
    param([object[]]$Definitions)

    $allProcesses = @(Get-Process -ErrorAction Stop)
    $matches = @()

    foreach ($definition in @($Definitions)) {
        foreach ($processName in @($definition.processNames)) {
            $matches += @($allProcesses | Where-Object {
                [string]$_.ProcessName -eq [string]$processName
            } | ForEach-Object {
                [ordered]@{
                    applicationId = [string]$definition.id
                    name = [string]$_.ProcessName
                    id = [int]$_.Id
                    path = try { [string]$_.Path } catch { $null }
                }
            })
        }
    }

    return @($matches | Sort-Object -Property applicationId, id -Unique)
}

function Get-BaselineRegistryValue {
    param(
        [object[]]$BaselineRegistryValues,
        [string]$ApplicationId,
        [string]$RegistryPath,
        [string]$ValueName
    )

    $BaselineRegistryValues | Where-Object {
        [string]$_.applicationId -eq $ApplicationId -and
        [string]$_.registryPath -eq $RegistryPath -and
        [string]$_.valueName -eq $ValueName
    } | Select-Object -First 1
}

function Get-BaselineScheduledTask {
    param(
        [object[]]$BaselineScheduledTasks,
        [string]$ApplicationId,
        [string]$TaskPath,
        [string]$TaskName
    )

    $BaselineScheduledTasks | Where-Object {
        [string]$_.applicationId -eq $ApplicationId -and
        [string]$_.taskPath -eq $TaskPath -and
        [string]$_.taskName -eq $TaskName
    } | Select-Object -First 1
}

function Write-RegistryTargetPlan {
    param(
        [object]$Snapshot,
        [AllowNull()]
        [object]$TargetEnabled
    )

    if ($null -eq $TargetEnabled) {
        return
    }

    if (-not [bool]$TargetEnabled -and -not [bool]$Snapshot.exists) {
        Write-StartupUserApplicationControlLog -Action 'skip' -ApplicationId ([string]$Snapshot.applicationId) -Surface 'startup-registry' -Reason 'already-target-state' -Details $Snapshot
        return
    }

    Write-StartupUserApplicationControlLog `
        -Action 'would-set-startup-enabled' `
        -ApplicationId ([string]$Snapshot.applicationId) `
        -Surface 'startup-registry' `
        -Reason 'dry-run' `
        -Details ([ordered]@{
            registryPath = $Snapshot.registryPath
            valueName = $Snapshot.valueName
            exists = [bool]$Snapshot.exists
            command = $Snapshot.command
            targetEnabled = [bool]$TargetEnabled
            plannedActions = if ([bool]$TargetEnabled) { @('inspect-existing-registry-value') } else { @('remove-registry-value') }
        })
}

function Write-ScheduledTaskTargetPlan {
    param(
        [object]$Snapshot,
        [AllowNull()]
        [object]$TargetEnabled
    )

    if ($null -eq $TargetEnabled) {
        return
    }

    $plannedActions = @()
    if ($Snapshot.enabled -ne $TargetEnabled) {
        $plannedActions += "set-task-enabled:$TargetEnabled"
    }

    if (@($plannedActions).Count -eq 0) {
        Write-StartupUserApplicationControlLog -Action 'skip' -ApplicationId ([string]$Snapshot.applicationId) -Surface 'scheduled-task' -Reason 'already-target-state' -Details $Snapshot
        return
    }

    Write-StartupUserApplicationControlLog `
        -Action 'would-set-startup-enabled' `
        -ApplicationId ([string]$Snapshot.applicationId) `
        -Surface 'scheduled-task' `
        -Reason 'dry-run' `
        -Details ([ordered]@{
            taskPath = $Snapshot.taskPath
            taskName = $Snapshot.taskName
            state = $Snapshot.state
            enabled = $Snapshot.enabled
            targetEnabled = [bool]$TargetEnabled
            plannedActions = @($plannedActions)
        })
}

function Restore-RegistryValueBaseline {
    param(
        [object]$Baseline,
        [AllowNull()]
        [object]$Current
    )

    if ($null -eq $Baseline) {
        return
    }

    if (-not [bool]$Baseline.exists) {
        if ($null -ne $Current -and [bool]$Current.exists) {
            Write-StartupUserApplicationControlLog `
                -Action 'would-restore-baseline' `
                -ApplicationId ([string]$Baseline.applicationId) `
                -Surface 'startup-registry' `
                -Reason 'dry-run' `
                -Details ([ordered]@{
                    plannedActions = @('remove-registry-value')
                    baseline = $Baseline
                    current = $Current
                })
            return
        }

        Write-StartupUserApplicationControlLog -Action 'skip-restore' -ApplicationId ([string]$Baseline.applicationId) -Surface 'startup-registry' -Reason 'baseline-value-did-not-exist' -Details $Baseline
        return
    }

    $currentExists = $null -ne $Current -and [bool]$Current.exists
    $currentCommand = if ($currentExists) { [string]$Current.command } else { $null }
    if ($currentExists -and $currentCommand -eq [string]$Baseline.command) {
        Write-StartupUserApplicationControlLog -Action 'skip-restore' -ApplicationId ([string]$Baseline.applicationId) -Surface 'startup-registry' -Reason 'already-baseline-state' -Details $Baseline
        return
    }

    Write-StartupUserApplicationControlLog `
        -Action 'would-restore-baseline' `
        -ApplicationId ([string]$Baseline.applicationId) `
        -Surface 'startup-registry' `
        -Reason 'dry-run' `
        -Details ([ordered]@{
            plannedActions = @('set-registry-value')
            baseline = $Baseline
            current = $Current
        })
}

function Restore-ScheduledTaskBaseline {
    param(
        [object]$Baseline,
        [AllowNull()]
        [object]$Current
    )

    if ($null -eq $Baseline) {
        return
    }

    if (-not [bool]$Baseline.exists) {
        Write-StartupUserApplicationControlLog -Action 'skip-restore' -ApplicationId ([string]$Baseline.applicationId) -Surface 'scheduled-task' -Reason 'baseline-task-did-not-exist' -Details $Baseline
        return
    }

    if ($null -eq $Current) {
        Write-StartupUserApplicationControlLog -Action 'skip-restore' -ApplicationId ([string]$Baseline.applicationId) -Surface 'scheduled-task' -Reason 'task-not-found' -Details $Baseline
        return
    }

    if ($Current.enabled -eq $Baseline.enabled) {
        Write-StartupUserApplicationControlLog -Action 'skip-restore' -ApplicationId ([string]$Baseline.applicationId) -Surface 'scheduled-task' -Reason 'already-baseline-state' -Details $Baseline
        return
    }

    Write-StartupUserApplicationControlLog `
        -Action 'would-restore-baseline' `
        -ApplicationId ([string]$Baseline.applicationId) `
        -Surface 'scheduled-task' `
        -Reason 'dry-run' `
        -Details ([ordered]@{
            plannedActions = @("set-task-enabled:$($Baseline.enabled)")
            baseline = $Baseline
            current = $Current
        })
}

New-Item -ItemType Directory -Path $LogDir -Force | Out-Null

$dryRun = [bool](Get-SettingValue -Object $ModuleSettings -Name 'dryRun' -Default $true)
if (-not $dryRun) {
    throw 'Startup and User-Application Control currently supports dryRun only.'
}

$statePathWasProvided = -not [string]::IsNullOrWhiteSpace($StatePath)
if (-not $statePathWasProvided) {
    $StatePath = Join-Path $env:ProgramData 'BootProfileSwitcher\state\startup-user-application-control-state.json'
}

$applications = ConvertTo-Array -Value (Get-SettingValue -Object $ModuleSettings -Name 'applications' -Default @())

$targetDefinitions = @(
    [ordered]@{
        id = 'teams'
        registryValues = @(
            [ordered]@{ path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Run'; valueName = 'com.squirrel.Teams.Teams' },
            [ordered]@{ path = 'HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Run'; valueName = 'TeamsMachineInstaller' }
        )
        scheduledTaskNamePatterns = @()
        processNames = @('Teams', 'ms-teams', 'MSTeams')
    },
    [ordered]@{
        id = 'onedrive'
        registryValues = @()
        scheduledTaskNamePatterns = @('OneDrive Startup Task-*')
        processNames = @('OneDrive')
    },
    [ordered]@{
        id = 'owncloud'
        registryValues = @(
            [ordered]@{ path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Run'; valueName = 'ownCloud' }
        )
        scheduledTaskNamePatterns = @()
        processNames = @('owncloud', 'ownCloud')
    },
    [ordered]@{
        id = 'microsoft-office'
        registryValues = @()
        scheduledTaskNamePatterns = @(
            'Office Automatic Updates 2.0',
            'Office ClickToRun Service Monitor',
            'Office Feature Updates',
            'Office Feature Updates Logon'
        )
        processNames = @('OUTLOOK', 'olk')
    }
)

$previousState = Read-StartupUserApplicationControlState -Path $StatePath
$previousRunWasControlling = $false
$baselineRegistryValues = @()
$baselineScheduledTasks = @()

if ($null -ne $previousState -and $null -ne $previousState.PSObject.Properties['lastRun']) {
    $previousRunWasControlling = [bool]$previousState.lastRun.controlling
}

if ($null -ne $previousState -and $null -ne $previousState.PSObject.Properties['baseline']) {
    $baselineRegistryValues = @($previousState.baseline.registryValues)
    $baselineScheduledTasks = @($previousState.baseline.scheduledTasks)
}

$currentRegistryValues = @()
$currentScheduledTasks = @()
$applicationPlans = @()

foreach ($application in @($applications)) {
    $applicationId = [string](Get-SettingValue -Object $application -Name 'id' -Default '')
    $startup = Get-SettingValue -Object $application -Name 'startup' -Default $null
    $processes = Get-SettingValue -Object $application -Name 'processes' -Default $null
    $startupEnabled = Get-SettingValue -Object $startup -Name 'enabled' -Default $null
    $processAction = [string](Get-SettingValue -Object $processes -Name 'action' -Default 'inspect-only')
    $definition = $targetDefinitions | Where-Object { [string]$_.id -eq $applicationId } | Select-Object -First 1

    if ($null -eq $definition) {
        Write-StartupUserApplicationControlLog -Action 'skip' -ApplicationId $applicationId -Surface 'application' -Reason 'unsupported-application' -Details $null
        continue
    }

    $registryEntries = @(Get-StartupRegistryValueSnapshots -Definitions @($definition))
    $taskMatches = @()
    try {
        $taskMatches = @(Get-ScheduledTaskMatches -Definitions @($definition))
    } catch {
        Write-StartupUserApplicationControlLog `
            -Action 'inspect-error' `
            -ApplicationId $applicationId `
            -Surface 'scheduled-task' `
            -Reason 'read-failed' `
            -Details ([ordered]@{ error = $_.Exception.Message })
    }

    $processMatches = @(Get-ProcessMatches -Definitions @($definition))
    $currentRegistryValues += @($registryEntries)
    $currentScheduledTasks += @($taskMatches)
    $applicationPlans += [ordered]@{
        applicationId = $applicationId
        startupEnabled = $startupEnabled
        processAction = $processAction
        registryEntries = @($registryEntries)
        taskMatches = @($taskMatches)
        processMatches = @($processMatches)
    }

    Write-StartupUserApplicationControlLog `
        -Action 'inspect' `
        -ApplicationId $applicationId `
        -Surface 'application' `
        -Reason 'current-startup-user-application-state' `
        -Details ([ordered]@{
            startupEnabled = $startupEnabled
            processAction = $processAction
            startupRegistryMatches = @($registryEntries | Where-Object { [bool]$_.exists }).Count
            scheduledTaskMatches = @($taskMatches).Count
            processMatches = @($processMatches).Count
        })
}

if (-not $previousRunWasControlling) {
    $baselineRegistryValues = @($currentRegistryValues)
    $baselineScheduledTasks = @($currentScheduledTasks)

    foreach ($snapshot in @($baselineRegistryValues)) {
        Write-StartupUserApplicationControlLog -Action 'update-baseline' -ApplicationId ([string]$snapshot.applicationId) -Surface 'startup-registry' -Reason 'previous-run-not-controlling' -Details $snapshot
    }

    foreach ($snapshot in @($baselineScheduledTasks)) {
        Write-StartupUserApplicationControlLog -Action 'update-baseline' -ApplicationId ([string]$snapshot.applicationId) -Surface 'scheduled-task' -Reason 'previous-run-not-controlling' -Details $snapshot
    }
}

if ((-not $Controlling) -and $previousRunWasControlling) {
    foreach ($baseline in @($baselineRegistryValues)) {
        $current = Get-BaselineRegistryValue `
            -BaselineRegistryValues $currentRegistryValues `
            -ApplicationId ([string]$baseline.applicationId) `
            -RegistryPath ([string]$baseline.registryPath) `
            -ValueName ([string]$baseline.valueName)

        Restore-RegistryValueBaseline -Baseline $baseline -Current $current
    }

    foreach ($baseline in @($baselineScheduledTasks)) {
        $current = Get-BaselineScheduledTask `
            -BaselineScheduledTasks $currentScheduledTasks `
            -ApplicationId ([string]$baseline.applicationId) `
            -TaskPath ([string]$baseline.taskPath) `
            -TaskName ([string]$baseline.taskName)

        Restore-ScheduledTaskBaseline -Baseline $baseline -Current $current
    }
}

if ($Controlling) {
    if ($dryRun -and -not $statePathWasProvided) {
        Write-StartupUserApplicationControlLog `
            -Action 'skip-state-write' `
            -ApplicationId 'all' `
            -Surface 'state' `
            -Reason 'dry-run-default-state-path' `
            -Details ([ordered]@{
                statePath = $StatePath
            })
    } else {
        try {
            Save-StartupUserApplicationControlState `
                -Path $StatePath `
                -BaselineRegistryValues $baselineRegistryValues `
                -BaselineScheduledTasks $baselineScheduledTasks `
                -CurrentRunControlling $true
        } catch {
            if (-not $dryRun) {
                throw
            }

            Write-StartupUserApplicationControlLog `
                -Action 'skip-state-write' `
                -ApplicationId 'all' `
                -Surface 'state' `
                -Reason 'dry-run-state-write-failed' `
                -Details ([ordered]@{
                    statePath = $StatePath
                    error = $_.Exception.Message
                })
        }
    }

    foreach ($plan in @($applicationPlans)) {
        foreach ($entry in @($plan.registryEntries)) {
            Write-RegistryTargetPlan -Snapshot $entry -TargetEnabled $plan.startupEnabled
        }

        foreach ($task in @($plan.taskMatches)) {
            Write-ScheduledTaskTargetPlan -Snapshot $task -TargetEnabled $plan.startupEnabled
        }

        foreach ($process in @($plan.processMatches)) {
            Write-StartupUserApplicationControlLog `
                -Action 'inspect-process' `
                -ApplicationId ([string]$plan.applicationId) `
                -Surface 'process' `
                -Reason 'inspect-only' `
                -Details $process
        }
    }
}
