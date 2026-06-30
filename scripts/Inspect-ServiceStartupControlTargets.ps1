<#
.SYNOPSIS
Inspects candidate service and startup control targets without changing system state.

.DESCRIPTION
Collects a read-only inventory for the v1.4.0 Service and Startup Control
Discovery milestone. The script looks for services, scheduled tasks, startup
registry entries, startup-folder entries and running processes related to the
current target interests:

- Windows Update
- Bitdefender
- Microsoft Teams
- OneDrive
- ownCloud
- Outlook
- Windows Search / drive indexing

The script does not stop services, disable scheduled tasks, edit registry
values, remove startup entries or terminate processes.
#>

[CmdletBinding()]
param(
    [switch]$AsJson
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function New-TargetDefinition {
    param(
        [string]$Name,
        [string]$Category,
        [string[]]$ServiceNamePatterns,
        [string[]]$DisplayNamePatterns,
        [string[]]$TaskPathPatterns,
        [string[]]$TaskNamePatterns,
        [string[]]$StartupValuePatterns,
        [string[]]$ProcessNamePatterns,
        [string]$InitialClassification,
        [string]$Notes
    )

    [ordered]@{
        name = $Name
        category = $Category
        serviceNamePatterns = @($ServiceNamePatterns)
        displayNamePatterns = @($DisplayNamePatterns)
        taskPathPatterns = @($TaskPathPatterns)
        taskNamePatterns = @($TaskNamePatterns)
        startupValuePatterns = @($StartupValuePatterns)
        processNamePatterns = @($ProcessNamePatterns)
        initialClassification = $InitialClassification
        notes = $Notes
    }
}

function Test-AnyPattern {
    param(
        [AllowNull()]
        [string]$Value,
        [string[]]$Patterns
    )

    if ([string]::IsNullOrWhiteSpace($Value)) {
        return $false
    }

    foreach ($pattern in @($Patterns)) {
        if ([string]::IsNullOrWhiteSpace($pattern)) {
            continue
        }

        if ($Value -like $pattern) {
            return $true
        }
    }

    return $false
}

function Find-MatchingTargets {
    param(
        [object[]]$Targets,
        [string]$Surface,
        [string]$ServiceName,
        [string]$DisplayName,
        [string]$TaskPath,
        [string]$TaskName,
        [string]$StartupValue,
        [string]$ProcessName
    )

    $matches = @()

    foreach ($target in @($Targets)) {
        $isMatch = $false

        switch ($Surface) {
            'service' {
                $isMatch =
                    (Test-AnyPattern -Value $ServiceName -Patterns $target.serviceNamePatterns) -or
                    (Test-AnyPattern -Value $DisplayName -Patterns $target.displayNamePatterns)
            }
            'scheduled-task' {
                $isMatch =
                    (Test-AnyPattern -Value $TaskPath -Patterns $target.taskPathPatterns) -or
                    (Test-AnyPattern -Value $TaskName -Patterns $target.taskNamePatterns)
            }
            'startup-entry' {
                $isMatch =
                    (Test-AnyPattern -Value $StartupValue -Patterns $target.startupValuePatterns) -or
                    (Test-AnyPattern -Value $DisplayName -Patterns $target.displayNamePatterns)
            }
            'process' {
                $isMatch =
                    (Test-AnyPattern -Value $ProcessName -Patterns $target.processNamePatterns) -or
                    (Test-AnyPattern -Value $DisplayName -Patterns $target.displayNamePatterns)
            }
        }

        if ($isMatch) {
            $matches += [ordered]@{
                name = $target.name
                category = $target.category
                initialClassification = $target.initialClassification
            }
        }
    }

    return @($matches)
}

function Read-Services {
    $services = @()

    try {
        $services = @(Get-CimInstance -ClassName Win32_Service | ForEach-Object {
            [ordered]@{
                name = [string]$_.Name
                displayName = [string]$_.DisplayName
                state = [string]$_.State
                startMode = [string]$_.StartMode
                startName = [string]$_.StartName
                pathName = [string]$_.PathName
            }
        })
    } catch {
        return [ordered]@{
            items = @()
            error = $_.Exception.Message
        }
    }

    [ordered]@{
        items = @($services)
        error = $null
    }
}

function Read-ScheduledTasks {
    if (-not (Get-Command -Name Get-ScheduledTask -ErrorAction SilentlyContinue)) {
        return [ordered]@{
            items = @()
            error = 'Get-ScheduledTask is not available in this PowerShell environment.'
        }
    }

    try {
        $tasks = @(Get-ScheduledTask | ForEach-Object {
            [ordered]@{
                taskName = [string]$_.TaskName
                taskPath = [string]$_.TaskPath
                state = [string]$_.State
                author = [string]$_.Author
                uri = [string]$_.URI
            }
        })

        return [ordered]@{
            items = @($tasks)
            error = $null
        }
    } catch {
        return [ordered]@{
            items = @()
            error = $_.Exception.Message
        }
    }
}

function Read-StartupRegistryEntries {
    $locations = @(
        [ordered]@{ scope = 'Machine'; path = 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Run' },
        [ordered]@{ scope = 'Machine'; path = 'HKLM:\Software\Microsoft\Windows\CurrentVersion\RunOnce' },
        [ordered]@{ scope = 'User'; path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Run' },
        [ordered]@{ scope = 'User'; path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\RunOnce' },
        [ordered]@{ scope = 'MachineWow6432'; path = 'HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Run' }
    )

    $entries = @()
    $errors = @()

    foreach ($location in $locations) {
        if (-not (Test-Path $location.path)) {
            continue
        }

        try {
            $item = Get-ItemProperty -Path $location.path
            foreach ($property in @($item.PSObject.Properties)) {
                if ($property.Name -in @('PSPath', 'PSParentPath', 'PSChildName', 'PSDrive', 'PSProvider')) {
                    continue
                }

                $entries += [ordered]@{
                    scope = $location.scope
                    registryPath = $location.path
                    valueName = [string]$property.Name
                    command = [string]$property.Value
                }
            }
        } catch {
            $errors += "$($location.path): $($_.Exception.Message)"
        }
    }

    [ordered]@{
        items = @($entries)
        error = if ($errors.Count -gt 0) { @($errors) -join ' | ' } else { $null }
    }
}

function Read-StartupFolderEntries {
    $locations = @(
        [ordered]@{ scope = 'User'; path = [Environment]::GetFolderPath('Startup') },
        [ordered]@{ scope = 'Common'; path = [Environment]::GetFolderPath('CommonStartup') }
    )

    $entries = @()
    $errors = @()

    foreach ($location in $locations) {
        if ([string]::IsNullOrWhiteSpace($location.path) -or -not (Test-Path $location.path)) {
            continue
        }

        try {
            $entries += @(Get-ChildItem -LiteralPath $location.path -Force | ForEach-Object {
                [ordered]@{
                    scope = $location.scope
                    folder = $location.path
                    name = [string]$_.Name
                    fullName = [string]$_.FullName
                    extension = [string]$_.Extension
                }
            })
        } catch {
            $errors += "$($location.path): $($_.Exception.Message)"
        }
    }

    [ordered]@{
        items = @($entries)
        error = if ($errors.Count -gt 0) { @($errors) -join ' | ' } else { $null }
    }
}

function Read-Processes {
    try {
        $processes = @(Get-Process | ForEach-Object {
            [ordered]@{
                name = [string]$_.ProcessName
                id = [int]$_.Id
                path = try { [string]$_.Path } catch { $null }
            }
        })

        return [ordered]@{
            items = @($processes)
            error = $null
        }
    } catch {
        return [ordered]@{
            items = @()
            error = $_.Exception.Message
        }
    }
}

$targets = @(
    New-TargetDefinition `
        -Name 'Windows Update' `
        -Category 'system-update' `
        -ServiceNamePatterns @('wuauserv', 'UsoSvc', 'BITS', 'DoSvc', 'WaaSMedicSvc') `
        -DisplayNamePatterns @('*Windows Update*', '*Update Orchestrator*', '*Background Intelligent Transfer*', '*Delivery Optimization*', '*Medic*') `
        -TaskPathPatterns @('\Microsoft\Windows\WindowsUpdate\*', '\Microsoft\Windows\UpdateOrchestrator\*', '\Microsoft\Windows\WaaSMedic\*') `
        -TaskNamePatterns @('*Windows Update*', '*USO*', '*WaaSMedic*', 'Schedule Scan', 'ScanForUpdates', 'ScanForUpdatesAsUser', 'WakeUpAndContinueUpdates', 'WakeUpAndScanForUpdates') `
        -StartupValuePatterns @() `
        -ProcessNamePatterns @('wuauclt', 'usoclient', 'MoUsoCoreWorker', 'TiWorker') `
        -InitialClassification 'policy-or-vendor-guidance' `
        -Notes 'Windows Update may self-heal or be policy-managed; direct service control needs careful validation.'

    New-TargetDefinition `
        -Name 'Bitdefender' `
        -Category 'security-vendor' `
        -ServiceNamePatterns @('BDESVC', 'BDAux*', 'VSSERV', 'EPIntegrationService', 'EPProtectedService', 'EPRedline', 'EPSecurityService', 'EPUpdateService', '*Bitdefender*') `
        -DisplayNamePatterns @('*Bitdefender*') `
        -TaskPathPatterns @('*Bitdefender*') `
        -TaskNamePatterns @('*Bitdefender*') `
        -StartupValuePatterns @('*Bitdefender*') `
        -ProcessNamePatterns @('bdagent', 'bdservicehost', 'bdredline', 'bdntwrk', 'bduserhost', '*Bitdefender*') `
        -InitialClassification 'policy-or-vendor-guidance' `
        -Notes 'Security products may use tamper protection; do not bypass vendor protections.'

    New-TargetDefinition `
        -Name 'Microsoft Teams' `
        -Category 'user-application' `
        -ServiceNamePatterns @() `
        -DisplayNamePatterns @('*Teams*') `
        -TaskPathPatterns @('*Teams*') `
        -TaskNamePatterns @('*Teams*') `
        -StartupValuePatterns @('*Teams*') `
        -ProcessNamePatterns @('Teams', 'ms-teams', 'MSTeams') `
        -InitialClassification 'startup-control-or-user-app-control' `
        -Notes 'Teams is usually per-user startup and process state rather than a normal system service.'

    New-TargetDefinition `
        -Name 'OneDrive' `
        -Category 'user-application' `
        -ServiceNamePatterns @() `
        -DisplayNamePatterns @('*OneDrive*') `
        -TaskPathPatterns @('*OneDrive*') `
        -TaskNamePatterns @('*OneDrive*') `
        -StartupValuePatterns @('*OneDrive*') `
        -ProcessNamePatterns @('OneDrive') `
        -InitialClassification 'startup-control-or-user-app-control' `
        -Notes 'OneDrive is typically controlled through per-user startup and policy.'

    New-TargetDefinition `
        -Name 'ownCloud' `
        -Category 'user-application' `
        -ServiceNamePatterns @('*ownCloud*') `
        -DisplayNamePatterns @('*ownCloud*') `
        -TaskPathPatterns @('*ownCloud*') `
        -TaskNamePatterns @('*ownCloud*') `
        -StartupValuePatterns @('*ownCloud*') `
        -ProcessNamePatterns @('owncloud', 'ownCloud') `
        -InitialClassification 'startup-control-or-user-app-control' `
        -Notes 'ownCloud may be a per-user sync client; inventory determines whether any service exists.'

    New-TargetDefinition `
        -Name 'Outlook' `
        -Category 'user-application' `
        -ServiceNamePatterns @() `
        -DisplayNamePatterns @('*Outlook*') `
        -TaskPathPatterns @('*Outlook*', '*Office*') `
        -TaskNamePatterns @('*Outlook*', '*Office*') `
        -StartupValuePatterns @('*Outlook*', '*Office*') `
        -ProcessNamePatterns @('OUTLOOK', 'olk') `
        -InitialClassification 'startup-control-or-user-app-control' `
        -Notes 'Outlook is a user application; automatic startup can involve Office or user startup surfaces.'

    New-TargetDefinition `
        -Name 'Windows Search / Indexing' `
        -Category 'system-service' `
        -ServiceNamePatterns @('WSearch') `
        -DisplayNamePatterns @('*Windows Search*') `
        -TaskPathPatterns @('\Microsoft\Windows\Search\*') `
        -TaskNamePatterns @('*Search*', '*Indexer*') `
        -StartupValuePatterns @() `
        -ProcessNamePatterns @('SearchIndexer', 'SearchProtocolHost', 'SearchFilterHost') `
        -InitialClassification 'service-control-candidate' `
        -Notes 'Likely first service-control candidate because WSearch has a clear service identity.'
)

$serviceRead = Read-Services
$taskRead = Read-ScheduledTasks
$startupRegistryRead = Read-StartupRegistryEntries
$startupFolderRead = Read-StartupFolderEntries
$processRead = Read-Processes

$matchedServices = @($serviceRead.items | ForEach-Object {
    $matches = Find-MatchingTargets -Targets $targets -Surface 'service' -ServiceName $_.name -DisplayName $_.displayName
    if (@($matches).Count -eq 0) {
        return
    }

    [ordered]@{
        service = $_
        targets = @($matches)
    }
})

$matchedTasks = @($taskRead.items | ForEach-Object {
    $matches = Find-MatchingTargets -Targets $targets -Surface 'scheduled-task' -TaskPath $_.taskPath -TaskName $_.taskName
    if (@($matches).Count -eq 0) {
        return
    }

    [ordered]@{
        scheduledTask = $_
        targets = @($matches)
    }
})

$matchedStartupRegistry = @($startupRegistryRead.items | ForEach-Object {
    $startupText = "$($_.valueName) $($_.command)"
    $matches = Find-MatchingTargets -Targets $targets -Surface 'startup-entry' -StartupValue $startupText -DisplayName $_.valueName
    if (@($matches).Count -eq 0) {
        return
    }

    [ordered]@{
        startupEntry = $_
        targets = @($matches)
    }
})

$matchedStartupFolders = @($startupFolderRead.items | ForEach-Object {
    $startupText = "$($_.name) $($_.fullName)"
    $matches = Find-MatchingTargets -Targets $targets -Surface 'startup-entry' -StartupValue $startupText -DisplayName $_.name
    if (@($matches).Count -eq 0) {
        return
    }

    [ordered]@{
        startupEntry = $_
        targets = @($matches)
    }
})

$matchedProcesses = @($processRead.items | ForEach-Object {
    $matches = Find-MatchingTargets -Targets $targets -Surface 'process' -ProcessName $_.name -DisplayName $_.name
    if (@($matches).Count -eq 0) {
        return
    }

    [ordered]@{
        process = $_
        targets = @($matches)
    }
})

$targetSummaries = @($targets | ForEach-Object {
    $targetName = $_.name
    [ordered]@{
        name = $targetName
        category = $_.category
        initialClassification = $_.initialClassification
        serviceMatches = @($matchedServices | Where-Object { @($_.targets | ForEach-Object { $_.name }) -contains $targetName }).Count
        scheduledTaskMatches = @($matchedTasks | Where-Object { @($_.targets | ForEach-Object { $_.name }) -contains $targetName }).Count
        startupRegistryMatches = @($matchedStartupRegistry | Where-Object { @($_.targets | ForEach-Object { $_.name }) -contains $targetName }).Count
        startupFolderMatches = @($matchedStartupFolders | Where-Object { @($_.targets | ForEach-Object { $_.name }) -contains $targetName }).Count
        processMatches = @($matchedProcesses | Where-Object { @($_.targets | ForEach-Object { $_.name }) -contains $targetName }).Count
        notes = $_.notes
    }
})

$result = [ordered]@{
    schemaVersion = 1
    generatedAt = (Get-Date).ToString('o')
    readOnly = $true
    description = 'Service and startup control discovery inventory. No system state is modified.'
    targets = @($targetSummaries)
    matches = [ordered]@{
        services = @($matchedServices)
        scheduledTasks = @($matchedTasks)
        startupRegistry = @($matchedStartupRegistry)
        startupFolders = @($matchedStartupFolders)
        processes = @($matchedProcesses)
    }
    inventoryErrors = [ordered]@{
        services = $serviceRead.error
        scheduledTasks = $taskRead.error
        startupRegistry = $startupRegistryRead.error
        startupFolders = $startupFolderRead.error
        processes = $processRead.error
    }
}

$json = $result | ConvertTo-Json -Depth 10

if ($AsJson) {
    $json
    return
}

Write-Host 'Service and startup control discovery inventory completed.'
Write-Host 'No system state was modified.'
Write-Host ''
foreach ($target in $targetSummaries) {
    Write-Host ("{0}: services={1}, tasks={2}, startupRegistry={3}, startupFolders={4}, processes={5}, classification={6}" -f `
        $target.name,
        $target.serviceMatches,
        $target.scheduledTaskMatches,
        $target.startupRegistryMatches,
        $target.startupFolderMatches,
        $target.processMatches,
        $target.initialClassification)
}
