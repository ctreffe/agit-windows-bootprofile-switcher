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

function Get-StartupRegistryEntries {
    param([object[]]$Definitions)

    $entries = @()

    foreach ($definition in @($Definitions)) {
        foreach ($registryValue in @($definition.registryValues)) {
            $path = [string]$registryValue.path
            $valueName = [string]$registryValue.valueName

            if (-not (Test-Path $path)) {
                continue
            }

            $item = Get-ItemProperty -Path $path -Name $valueName -ErrorAction SilentlyContinue
            if ($null -eq $item -or $null -eq $item.PSObject.Properties[$valueName]) {
                continue
            }

            $entries += [ordered]@{
                applicationId = [string]$definition.id
                registryPath = $path
                valueName = $valueName
                command = [string]$item.$valueName
            }
        }
    }

    return @($entries)
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
                    state = [string]$_.State
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

New-Item -ItemType Directory -Path $LogDir -Force | Out-Null

$dryRun = [bool](Get-SettingValue -Object $ModuleSettings -Name 'dryRun' -Default $true)
if (-not $dryRun) {
    throw 'Startup and User-Application Control currently supports dryRun only.'
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

    $registryEntries = @(Get-StartupRegistryEntries -Definitions @($definition))
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

    Write-StartupUserApplicationControlLog `
        -Action 'inspect' `
        -ApplicationId $applicationId `
        -Surface 'application' `
        -Reason 'current-startup-user-application-state' `
        -Details ([ordered]@{
            startupEnabled = $startupEnabled
            processAction = $processAction
            startupRegistryMatches = @($registryEntries).Count
            scheduledTaskMatches = @($taskMatches).Count
            processMatches = @($processMatches).Count
        })

    foreach ($entry in @($registryEntries)) {
        Write-StartupUserApplicationControlLog `
            -Action 'would-set-startup-enabled' `
            -ApplicationId $applicationId `
            -Surface 'startup-registry' `
            -Reason 'dry-run' `
            -Details ([ordered]@{
                registryPath = $entry.registryPath
                valueName = $entry.valueName
                command = $entry.command
                targetEnabled = $startupEnabled
            })
    }

    foreach ($task in @($taskMatches)) {
        Write-StartupUserApplicationControlLog `
            -Action 'would-set-startup-enabled' `
            -ApplicationId $applicationId `
            -Surface 'scheduled-task' `
            -Reason 'dry-run' `
            -Details ([ordered]@{
                taskPath = $task.taskPath
                taskName = $task.taskName
                state = $task.state
                targetEnabled = $startupEnabled
            })
    }

    foreach ($process in @($processMatches)) {
        Write-StartupUserApplicationControlLog `
            -Action 'inspect-process' `
            -ApplicationId $applicationId `
            -Surface 'process' `
            -Reason 'inspect-only' `
            -Details $process
    }
}
