<#
.SYNOPSIS
Inspects whether the current Windows boot entry can be mapped to a real BCD GUID.

.DESCRIPTION
This read-only diagnostic script compares the current BCD entry exposed through
`bcdedit /enum "{current}"` with the complete BCD store exposed through
`bcdedit /enum all`.

The current A2 implementation detects the selected BootProfile Switcher mode by
reading the current BCD entry description. This script investigates whether a
more direct GUID-based mapping is available by comparing normal and verbose
bcdedit output with the managed A1 state file.

The script does not modify Windows Boot Configuration Data.
#>

[CmdletBinding()]
param(
    [switch]$AsJson
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Invoke-BcdeditRead {
    param(
        [Parameter(Mandatory = $true)]
        [string[]]$Arguments
    )

    $output = & bcdedit @Arguments 2>&1
    $exitCode = $LASTEXITCODE

    [pscustomobject]@{
        command = "bcdedit $($Arguments -join ' ')"
        exitCode = $exitCode
        output = @($output | ForEach-Object { [string]$_ })
    }
}

function ConvertTo-BcdSections {
    param(
        [Parameter(Mandatory = $true)]
        [AllowEmptyString()]
        [string[]]$Output
    )

    $sections = @()
    $current = $null
    $pendingHeader = $null

    foreach ($line in $Output) {
        if ([string]::IsNullOrWhiteSpace($line)) {
            continue
        }

        $trimmed = $line.Trim()

        if ([string]::IsNullOrWhiteSpace($trimmed)) {
            continue
        }

        if ($trimmed -match '^-{3,}$') {
            if ($pendingHeader) {
                if ($current) {
                    $sections += [pscustomobject]$current
                }

                $current = [ordered]@{
                    type = $pendingHeader
                    properties = [ordered]@{}
                    raw = @($pendingHeader, $line)
                }
                $pendingHeader = $null
            } elseif ($current) {
                $current.raw += $line
            }

            continue
        }

        if (-not $current) {
            $pendingHeader = $trimmed
            continue
        }

        $current.raw += $line

        if ($line -match '^([A-Za-z][A-Za-z0-9 _-]*?)\s{2,}(.+)$') {
            $name = $Matches[1].Trim()
            $value = $Matches[2].Trim()
            $current.properties[$name] = $value
        }
    }

    if ($current) {
        $sections += [pscustomobject]$current
    }

    return @($sections)
}

function Get-BcdProperty {
    param(
        [Parameter(Mandatory = $true)]
        [object]$Section,

        [Parameter(Mandatory = $true)]
        [string]$Name
    )

    $aliases = @{
        identifier = @('identifier', 'Bezeichner')
        description = @('description', 'Beschreibung')
    }

    $names = if ($aliases.ContainsKey($Name)) { $aliases[$Name] } else { @($Name) }

    if (
        $null -ne $Section -and
        $Section.PSObject.Properties.Name -contains 'properties' -and
        $null -ne $Section.properties
    ) {
        foreach ($propertyName in $names) {
            if ($Section.properties.Contains($propertyName)) {
                return [string]$Section.properties[$propertyName]
            }
        }
    }

    return $null
}

function Get-LoaderSections {
    param([object[]]$Sections)

    return @(
        $Sections |
            Where-Object { $null -ne $_ -and $_.PSObject.Properties.Name -contains 'type' } |
            Where-Object {
                $_.type -eq 'Windows Boot Loader' -or
                (Get-BcdProperty -Section $_ -Name 'path') -or
                (Get-BcdProperty -Section $_ -Name 'description')
            }
    )
}

function Get-ManagedState {
    param([string]$StateFile)

    if (-not (Test-Path $StateFile)) {
        return $null
    }

    return Get-Content -Path $StateFile -Raw | ConvertFrom-Json
}

$repoRoot = Split-Path -Parent (Split-Path -Parent $PSCommandPath)
$stateFile = Join-Path $repoRoot 'state\boot-menu.json'
$state = Get-ManagedState -StateFile $stateFile

$currentRead = Invoke-BcdeditRead -Arguments @('/enum', '{current}')
$currentVerboseRead = Invoke-BcdeditRead -Arguments @('/enum', '{current}', '/v')
$allRead = Invoke-BcdeditRead -Arguments @('/enum', 'all')
$allVerboseRead = Invoke-BcdeditRead -Arguments @('/enum', 'all', '/v')

$currentSections = ConvertTo-BcdSections -Output $currentRead.output
$currentVerboseSections = ConvertTo-BcdSections -Output $currentVerboseRead.output
$allSections = ConvertTo-BcdSections -Output $allRead.output
$allVerboseSections = ConvertTo-BcdSections -Output $allVerboseRead.output

$currentLoaderCandidates = @(Get-LoaderSections -Sections $currentSections | Select-Object -First 1)
$currentVerboseLoaderCandidates = @(Get-LoaderSections -Sections $currentVerboseSections | Select-Object -First 1)
$currentLoader = if ($currentLoaderCandidates.Count -gt 0) { $currentLoaderCandidates[0] } else { $null }
$currentVerboseLoader = if ($currentVerboseLoaderCandidates.Count -gt 0) { $currentVerboseLoaderCandidates[0] } else { $null }
$allLoaders = Get-LoaderSections -Sections $allSections
$allVerboseLoaders = Get-LoaderSections -Sections $allVerboseSections

$currentDescription = if ($currentLoader) { Get-BcdProperty -Section $currentLoader -Name 'description' } else { $null }
$currentIdentifier = if ($currentLoader) { Get-BcdProperty -Section $currentLoader -Name 'identifier' } else { $null }
$currentVerboseIdentifier = if ($currentVerboseLoader) { Get-BcdProperty -Section $currentVerboseLoader -Name 'identifier' } else { $null }

$descriptionCandidates = @(
    $allLoaders |
        Where-Object { (Get-BcdProperty -Section $_ -Name 'description') -eq $currentDescription } |
        ForEach-Object {
            [ordered]@{
                source = 'bcdedit /enum all'
                identifier = Get-BcdProperty -Section $_ -Name 'identifier'
                description = Get-BcdProperty -Section $_ -Name 'description'
                device = Get-BcdProperty -Section $_ -Name 'device'
                path = Get-BcdProperty -Section $_ -Name 'path'
                osdevice = Get-BcdProperty -Section $_ -Name 'osdevice'
            }
        }
)

$verboseDescriptionCandidates = @(
    $allVerboseLoaders |
        Where-Object { (Get-BcdProperty -Section $_ -Name 'description') -eq $currentDescription } |
        ForEach-Object {
            [ordered]@{
                source = 'bcdedit /enum all /v'
                identifier = Get-BcdProperty -Section $_ -Name 'identifier'
                description = Get-BcdProperty -Section $_ -Name 'description'
                device = Get-BcdProperty -Section $_ -Name 'device'
                path = Get-BcdProperty -Section $_ -Name 'path'
                osdevice = Get-BcdProperty -Section $_ -Name 'osdevice'
            }
        }
)

$managedMatches = @()
if ($state -and $state.entries) {
    foreach ($entry in $state.entries) {
        $managedMatches += [ordered]@{
            mode = $entry.mode
            name = $entry.name
            managedIdentifier = $entry.identifier
            matchesCurrentDescription = $entry.name -eq $currentDescription
            appearsInAllByIdentifier = @($descriptionCandidates | Where-Object { $_.identifier -eq $entry.identifier }).Count -gt 0
            appearsInAllVerboseByIdentifier = @($verboseDescriptionCandidates | Where-Object { $_.identifier -eq $entry.identifier }).Count -gt 0
        }
    }
}

$directGuidCandidate = $null
$uniqueGuidCandidate = $null
$guidCandidates = @(
    @($descriptionCandidates + $verboseDescriptionCandidates) |
        Where-Object { $_.identifier -match '^\{[0-9a-fA-F-]{36}\}$' } |
        Select-Object -Property identifier, description, source -Unique
)

if ($currentVerboseIdentifier -match '^\{[0-9a-fA-F-]{36}\}$') {
    $directGuidCandidate = $currentVerboseIdentifier
}

if ($guidCandidates.Count -eq 1) {
    $uniqueGuidCandidate = $guidCandidates[0].identifier
}

$result = [ordered]@{
    stateFile = $stateFile
    stateFileExists = $null -ne $state
    current = [ordered]@{
        description = $currentDescription
        identifier = $currentIdentifier
        verboseIdentifier = $currentVerboseIdentifier
    }
    candidatesByDescription = @($descriptionCandidates)
    verboseCandidatesByDescription = @($verboseDescriptionCandidates)
    managedEntries = @($managedMatches)
    directGuidCandidate = $directGuidCandidate
    uniqueGuidCandidate = $uniqueGuidCandidate
    commands = [ordered]@{
        current = $currentRead
        currentVerbose = $currentVerboseRead
        all = [ordered]@{
            command = $allRead.command
            exitCode = $allRead.exitCode
            parsedLoaderCount = @($allLoaders).Count
        }
        allVerbose = [ordered]@{
            command = $allVerboseRead.command
            exitCode = $allVerboseRead.exitCode
            parsedLoaderCount = @($allVerboseLoaders).Count
        }
    }
}

if ($AsJson) {
    $result | ConvertTo-Json -Depth 10
    return
}

Write-Host 'BootProfile Switcher current boot entry inspection'
Write-Host "State file:            $stateFile"
Write-Host "State file exists:     $($result.stateFileExists)"
Write-Host "Current description:   $currentDescription"
Write-Host "Current identifier:    $currentIdentifier"
Write-Host "Verbose identifier:    $currentVerboseIdentifier"
Write-Host "Direct GUID candidate: $directGuidCandidate"
Write-Host "Unique GUID candidate: $uniqueGuidCandidate"
Write-Host ''

Write-Host 'Managed entries:'
if ($managedMatches.Count -eq 0) {
    Write-Host '  No managed entries found. Install the A1 boot menu first.'
} else {
    foreach ($entry in $managedMatches) {
        Write-Host ("  Mode {0}: {1}" -f $entry.mode, $entry.name)
        Write-Host ("    managedIdentifier:              {0}" -f $entry.managedIdentifier)
        Write-Host ("    matchesCurrentDescription:       {0}" -f $entry.matchesCurrentDescription)
        Write-Host ("    appearsInAllByIdentifier:        {0}" -f $entry.appearsInAllByIdentifier)
        Write-Host ("    appearsInAllVerboseByIdentifier: {0}" -f $entry.appearsInAllVerboseByIdentifier)
    }
}

Write-Host ''
Write-Host 'Candidates with the same description:'
$allCandidates = @($descriptionCandidates + $verboseDescriptionCandidates)
if ($allCandidates.Count -eq 0) {
    Write-Host '  None found.'
} else {
    foreach ($candidate in $allCandidates) {
        Write-Host ("  [{0}] {1} | {2}" -f $candidate.source, $candidate.identifier, $candidate.description)
        Write-Host ("    device={0}; osdevice={1}; path={2}" -f $candidate.device, $candidate.osdevice, $candidate.path)
    }
}

Write-Host ''
Write-Host 'Interpretation:'
if ($directGuidCandidate) {
    Write-Host "  bcdedit /enum `"{current}`" /v exposes a direct GUID candidate: $directGuidCandidate"
    Write-Host '  Compare it with Mode A and Mode B after booting both entries before changing detection logic.'
} elseif ($uniqueGuidCandidate) {
    Write-Host "  A unique GUID candidate was found by matching all entries: $uniqueGuidCandidate"
    Write-Host '  Compare it with the selected Mode A/Mode B managed identifier before changing detection logic.'
} else {
    Write-Host '  No unique GUID candidate was found from bcdedit output alone.'
    Write-Host '  The current description-based detection remains the validated mechanism.'
}
