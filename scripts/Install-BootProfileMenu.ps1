<#
.SYNOPSIS
Creates managed BootProfile Switcher boot menu entries from Configuration Format v2.

.DESCRIPTION
Reads a validated Configuration Format v2 file, copies the configured source
boot entry for each enabled managed profile and stores the created BCD
identifiers in state/boot-menu.json.

The default configuration source is the machine-wide profile configuration at
C:\ProgramData\BootProfileSwitcher\config\profiles.json. Use -ConfigPath to
install from a repository demo or test configuration.

Existing managed entries are never duplicated intentionally. Local interactive
use can confirm cleanup when existing entries are found. Automated deployment
should pass -CleanupExisting -Force.

This script changes Windows Boot Configuration Data and must be run from an
elevated PowerShell session.
#>

[CmdletBinding(SupportsShouldProcess = $true)]
param(
    [string]$ConfigPath,

    [int]$TimeoutSeconds = -1,

    [Alias('RemoveExisting')]
    [switch]$CleanupExisting,

    [switch]$Force
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Test-Administrator {
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = [Security.Principal.WindowsPrincipal]::new($identity)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Get-JsonProperty {
    param(
        [object]$Object,
        [string]$Name
    )

    if ($null -eq $Object) {
        return $null
    }

    $property = $Object.PSObject.Properties[$Name]
    if ($null -eq $property) {
        return $null
    }

    return $property.Value
}

function Get-GuidFromBcdeditOutput {
    param([string[]]$Output)

    $joined = $Output -join "`n"
    $match = [regex]::Match($joined, '\{[0-9a-fA-F-]{36}\}')
    if (-not $match.Success) {
        throw "Could not parse boot entry identifier from bcdedit output: $joined"
    }

    return $match.Value
}

function Get-BcdProperty {
    param(
        [string[]]$Output,
        [string[]]$Names
    )

    foreach ($line in $Output) {
        foreach ($name in $Names) {
            if ($line -match ('^{0}\s+(.+)$' -f [regex]::Escape($name))) {
                return $Matches[1].Trim()
            }
        }
    }

    return $null
}

function Read-BcdEntry {
    param([string]$Identifier)

    $output = & bcdedit /enum $Identifier 2>&1
    if ($LASTEXITCODE -ne 0) {
        $message = ($output | Out-String).Trim()
        throw "Could not read BCD entry ${Identifier}: $message"
    }

    return @($output | ForEach-Object { [string]$_ })
}

function Resolve-BcdIdentifier {
    param([string]$Identifier)

    $output = & bcdedit /enum $Identifier /v 2>&1
    if ($LASTEXITCODE -ne 0) {
        $message = ($output | Out-String).Trim()
        throw "Could not resolve BCD entry ${Identifier}: $message"
    }

    $resolvedIdentifier = Get-BcdProperty -Output @($output | ForEach-Object { [string]$_ }) -Names @('identifier', 'Bezeichner')

    if ($resolvedIdentifier -match '^\{[0-9a-fA-F-]{36}\}$') {
        return $resolvedIdentifier
    }

    return $Identifier
}

function Read-BootManagerDefault {
    $output = & bcdedit /enum '{bootmgr}' 2>&1
    if ($LASTEXITCODE -ne 0) {
        $message = ($output | Out-String).Trim()
        throw "Could not read Windows Boot Manager default entry: $message"
    }

    return Get-BcdProperty -Output @($output | ForEach-Object { [string]$_ }) -Names @('default', 'Standard')
}

function Resolve-BootManagerDefault {
    $bootManagerDefault = Read-BootManagerDefault

    if ([string]::IsNullOrWhiteSpace($bootManagerDefault)) {
        return $null
    }

    return Resolve-BcdIdentifier -Identifier $bootManagerDefault
}

function Get-BcdBlocks {
    $output = & bcdedit /enum all 2>&1
    if ($LASTEXITCODE -ne 0) {
        $message = ($output | Out-String).Trim()
        throw "Could not read Windows Boot Configuration Data: $message"
    }

    $blocks = @()
    $currentBlock = @()

    foreach ($line in $output) {
        if ([string]::IsNullOrWhiteSpace($line)) {
            if ($currentBlock.Count -gt 0) {
                $blocks += ,@($currentBlock)
                $currentBlock = @()
            }
            continue
        }

        $currentBlock += [string]$line
    }

    if ($currentBlock.Count -gt 0) {
        $blocks += ,@($currentBlock)
    }

    return @($blocks)
}

function Get-BootProfileEntriesFromBcd {
    param(
        [object[]]$ManagedEntries,
        [string[]]$ConfiguredDisplayNames
    )

    $entries = @()

    foreach ($block in Get-BcdBlocks) {
        $joined = $block -join "`n"
        $idMatch = [regex]::Match($joined, '\{[0-9a-fA-F-]{36}\}')
        if (-not $idMatch.Success) {
            continue
        }

        $description = Get-BcdProperty -Output $block -Names @('description', 'Beschreibung')
        if (-not $description) {
            continue
        }

        $identifier = $idMatch.Value
        $managedEntry = $ManagedEntries | Where-Object {
            [string]$_.identifier -eq $identifier -or
            [string]$_.name -eq $description -or
            [string]$_.displayName -eq $description
        } | Select-Object -First 1

        $looksLikeKnownManagedEntry =
            $description -match '^BootProfile Switcher - Mode [AB]$' -or
            $description -eq 'Network Isolation' -or
            $ConfiguredDisplayNames -contains $description

        if ($null -eq $managedEntry -and -not $looksLikeKnownManagedEntry) {
            continue
        }

        $entries += [pscustomobject]@{
            ProfileId = if ($null -ne $managedEntry) { [string]$managedEntry.profileId } else { $null }
            Mode = if ($null -ne $managedEntry -and $managedEntry.PSObject.Properties['mode']) { [string]$managedEntry.mode } else { $null }
            Name = $description
            Identifier = $identifier
        }
    }

    return @($entries)
}

function Read-YesNo {
    param([string]$Prompt)

    $answer = Read-Host "$Prompt [y/N]"
    return $answer -match '^(y|yes|j|ja)$'
}

function Restore-DefaultEntryState {
    param([object]$State)

    if ($null -eq $State -or -not $State.PSObject.Properties['defaultEntry'] -or $null -eq $State.defaultEntry) {
        return
    }

    $defaultEntry = $State.defaultEntry
    $sourceEntry = if ($defaultEntry.PSObject.Properties['sourceEntry']) { [string]$defaultEntry.sourceEntry } else { [string]$State.sourceEntry }
    $sourceIdentifier = if ($defaultEntry.PSObject.Properties['sourceIdentifier']) { [string]$defaultEntry.sourceIdentifier } else { $sourceEntry }

    if ([string]::IsNullOrWhiteSpace($sourceEntry)) {
        $sourceEntry = '{default}'
    }

    if ([string]::IsNullOrWhiteSpace($sourceIdentifier)) {
        $sourceIdentifier = $sourceEntry
    }

    if ($defaultEntry.PSObject.Properties['renameApplied'] -and [bool]$defaultEntry.renameApplied) {
        $originalDescription = [string]$defaultEntry.originalDescription

        if (-not [string]::IsNullOrWhiteSpace($originalDescription)) {
            if ($PSCmdlet.ShouldProcess($sourceEntry, "Restore default entry description to $originalDescription")) {
                & bcdedit /set $sourceEntry description $originalDescription | Out-Null
            }
        }
    }

    if ($defaultEntry.PSObject.Properties['restoreDisplayOrder'] -and [bool]$defaultEntry.restoreDisplayOrder) {
        if ($PSCmdlet.ShouldProcess('Windows Boot Manager', "Restore $sourceIdentifier as first display order entry before reinstall")) {
            & bcdedit /displayorder $sourceIdentifier /addfirst | Out-Null
        }
    }

    if ($defaultEntry.PSObject.Properties['originalBootManagerDefault']) {
        $originalDefault = if ($defaultEntry.PSObject.Properties['originalBootManagerDefaultIdentifier']) {
            [string]$defaultEntry.originalBootManagerDefaultIdentifier
        } else {
            [string]$defaultEntry.originalBootManagerDefault
        }

        if ($originalDefault -in @('{default}', '{current}')) {
            $originalDefault = $sourceIdentifier
        }

        if (-not [string]::IsNullOrWhiteSpace($originalDefault)) {
            if ($PSCmdlet.ShouldProcess('Windows Boot Manager', "Restore boot manager default to $originalDefault before reinstall")) {
                & bcdedit /default $originalDefault | Out-Null
            }
        }
    }
}

function Remove-BootProfileEntries {
    param(
        [object[]]$Entries,
        [string]$StateFile
    )

    foreach ($entry in $Entries) {
        $id = [string]$entry.Identifier
        $name = [string]$entry.Name

        if ($PSCmdlet.ShouldProcess($id, "Delete existing boot entry $name")) {
            try {
                & bcdedit /delete $id /f | Out-Null
                Write-Host "Deleted existing boot entry $name ($id)."
            } catch {
                Write-Warning "Could not delete existing boot entry ${id}: $($_.Exception.Message)"
            }
        }
    }

    if (Test-Path $StateFile) {
        try {
            $state = Get-Content -Path $StateFile -Raw | ConvertFrom-Json
            Restore-DefaultEntryState -State $state
        } catch {
            Write-Warning "Could not restore default entry state from ${StateFile}: $($_.Exception.Message)"
        }

        $timestamp = Get-Date -Format 'yyyyMMdd-HHmmss'
        $archivedStateFile = Join-Path (Split-Path -Parent $StateFile) "boot-menu.replaced-$timestamp.json"

        if ($PSCmdlet.ShouldProcess($StateFile, "Archive existing state file as $archivedStateFile")) {
            Move-Item -Path $StateFile -Destination $archivedStateFile -Force
            Write-Host "Archived existing state file: $archivedStateFile"
        }
    }
}

function Invoke-ConfigurationValidator {
    param(
        [string]$ValidatorScript,
        [string]$Path
    )

    $validationOutput = & powershell.exe `
        -NoProfile `
        -ExecutionPolicy Bypass `
        -File $ValidatorScript `
        -ConfigPath $Path `
        -AsJson 2>&1
    $validation = (($validationOutput | Out-String).Trim()) | ConvertFrom-Json

    if (-not $validation.valid) {
        Write-Warning 'Boot profile configuration is invalid and will not be used for boot menu installation.'
        foreach ($validationError in @($validation.errors)) {
            Write-Host "- $validationError"
        }

        exit 1
    }

    if ([int]$validation.schemaVersion -ne 2) {
        throw "Boot menu installation requires Configuration Format v2. Validated schemaVersion was $($validation.schemaVersion)."
    }
}

if (-not (Test-Administrator)) {
    throw 'This script must be run from an elevated PowerShell session.'
}

$repoRoot = Split-Path -Parent (Split-Path -Parent $PSCommandPath)
$stateDir = Join-Path $repoRoot 'state'
$backupDir = Join-Path $repoRoot 'backups'
$stateFile = Join-Path $stateDir 'boot-menu.json'

if (-not $ConfigPath) {
    $ConfigPath = Join-Path $env:ProgramData 'BootProfileSwitcher\config\profiles.json'
}

if (-not (Test-Path $ConfigPath)) {
    throw "Boot profile configuration not found: $ConfigPath"
}

$validatorScript = Join-Path $repoRoot 'scripts\Test-BootProfileConfiguration.ps1'
Invoke-ConfigurationValidator -ValidatorScript $validatorScript -Path $ConfigPath

$configuration = Get-Content -Path $ConfigPath -Raw | ConvertFrom-Json
$bootMenu = Get-JsonProperty -Object $configuration -Name 'bootMenu'
$sourceEntry = [string](Get-JsonProperty -Object $bootMenu -Name 'sourceEntry')
$configuredTimeout = [int](Get-JsonProperty -Object $bootMenu -Name 'timeoutSeconds')
$defaultEntry = Get-JsonProperty -Object $bootMenu -Name 'defaultEntry'

if ([string]::IsNullOrWhiteSpace($sourceEntry)) {
    $sourceEntry = '{default}'
}

if ($TimeoutSeconds -lt 0) {
    $TimeoutSeconds = $configuredTimeout
}

$enabledProfiles = @(
    @($configuration.profiles) | Where-Object {
        $profileBootMenu = Get-JsonProperty -Object $_ -Name 'bootMenu'
        [bool](Get-JsonProperty -Object $profileBootMenu -Name 'enabled')
    }
)

if ($enabledProfiles.Count -eq 0) {
    throw 'Configuration contains no profiles with bootMenu.enabled = true.'
}

$configuredDisplayNames = @($enabledProfiles | ForEach-Object { [string]$_.displayName })
$managedEntries = @()
$stateFileExists = Test-Path $stateFile

if ($stateFileExists) {
    try {
        $existingState = Get-Content -Path $stateFile -Raw | ConvertFrom-Json
        $managedEntries = @($existingState.entries)
    } catch {
        Write-Warning "Could not parse existing state file ${stateFile}: $($_.Exception.Message)"
    }
}

$existingEntries = @(Get-BootProfileEntriesFromBcd -ManagedEntries $managedEntries -ConfiguredDisplayNames $configuredDisplayNames)

if ($stateFileExists -or $existingEntries.Count -gt 0) {
    Write-Host 'Existing BootProfile Switcher installation data was found.'

    if ($stateFileExists) {
        Write-Host "State file: $stateFile"
    }

    if ($existingEntries.Count -gt 0) {
        Write-Host 'BCD entries:'
        foreach ($entry in $existingEntries) {
            Write-Host "  $($entry.Name): $($entry.Identifier)"
        }
    }

    if (-not $CleanupExisting) {
        if ($Force) {
            throw 'Existing BootProfile Switcher entries were found. Use -CleanupExisting -Force for automated replacement.'
        }

        $shouldRemove = Read-YesNo -Prompt 'Remove existing BootProfile Switcher entries and install fresh'

        if (-not $shouldRemove) {
            throw 'Installation cancelled. Existing BootProfile Switcher entries were left unchanged.'
        }
    }

    Remove-BootProfileEntries -Entries $existingEntries -StateFile $stateFile
}

if ($PSCmdlet.ShouldProcess($stateDir, 'Create directory')) {
    New-Item -ItemType Directory -Path $stateDir -Force | Out-Null
}

if ($PSCmdlet.ShouldProcess($backupDir, 'Create directory')) {
    New-Item -ItemType Directory -Path $backupDir -Force | Out-Null
}

if ($PSCmdlet.ShouldProcess('Windows Boot Configuration Data store', 'Create configured BootProfile Switcher menu entries')) {
    $timestamp = Get-Date -Format 'yyyyMMdd-HHmmss'
    $backupFile = Join-Path $backupDir "bcd-before-bootprofile-menu-$timestamp.bak"

    & bcdedit /export $backupFile | Out-Null

    $sourceEntryOutput = Read-BcdEntry -Identifier $sourceEntry
    $sourceIdentifier = Resolve-BcdIdentifier -Identifier $sourceEntry
    $sourceDescription = Get-BcdProperty -Output $sourceEntryOutput -Names @('description', 'Beschreibung')
    $originalBootManagerDefault = Read-BootManagerDefault
    $originalBootManagerDefaultIdentifier = Resolve-BootManagerDefault
    $renameDefaultEntry = [bool](Get-JsonProperty -Object $defaultEntry -Name 'rename')
    $hideDefaultEntry = [bool](Get-JsonProperty -Object $defaultEntry -Name 'hide')
    $defaultDisplayName = Get-JsonProperty -Object $defaultEntry -Name 'displayName'

    $createdEntries = @()

    foreach ($profile in $enabledProfiles) {
        $profileId = [string]$profile.id
        $displayName = [string]$profile.displayName

        $copyOutput = & bcdedit /copy $sourceEntry /d $displayName
        $identifier = Get-GuidFromBcdeditOutput -Output $copyOutput

        & bcdedit /displayorder $identifier /addlast | Out-Null

        $createdEntries += [ordered]@{
            id = $profileId
            profileId = $profileId
            name = $displayName
            displayName = $displayName
            identifier = $identifier
        }
    }

    if ($renameDefaultEntry) {
        & bcdedit /set $sourceEntry description $defaultDisplayName | Out-Null
    }

    if ($hideDefaultEntry) {
        & bcdedit /displayorder $sourceIdentifier /remove | Out-Null
        & bcdedit /default ([string]$createdEntries[0].identifier) | Out-Null
    }

    & bcdedit /timeout $TimeoutSeconds | Out-Null

    $state = [ordered]@{
        schemaVersion = 2
        createdAt = (Get-Date).ToString('o')
        configPath = (Resolve-Path $ConfigPath).Path
        sourceEntry = $sourceEntry
        entries = @($createdEntries)
        timeoutSeconds = $TimeoutSeconds
        defaultEntry = [ordered]@{
            sourceEntry = $sourceEntry
            sourceIdentifier = $sourceIdentifier
            originalBootManagerDefault = $originalBootManagerDefault
            originalBootManagerDefaultIdentifier = $originalBootManagerDefaultIdentifier
            originalDescription = $sourceDescription
            renameApplied = $renameDefaultEntry
            configuredDisplayName = if ($null -ne $defaultDisplayName) { [string]$defaultDisplayName } else { $null }
            hideApplied = $hideDefaultEntry
            restoreDisplayOrder = $hideDefaultEntry
        }
        backupFile = $backupFile
    }

    $state | ConvertTo-Json -Depth 8 | Set-Content -Path $stateFile -Encoding UTF8

    Write-Host 'BootProfile Switcher boot menu entries created from Configuration Format v2.'
    foreach ($entry in $createdEntries) {
        Write-Host "$($entry.displayName): $($entry.identifier)"
    }
    Write-Host "Config: $ConfigPath"
    Write-Host "State:  $stateFile"
    Write-Host "Backup: $backupFile"
}
