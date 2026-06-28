<#
.SYNOPSIS
Resolves the selected BootProfile Switcher boot profile.

.DESCRIPTION
Reads the current Windows Boot Configuration Data entry, resolves it against the
managed BootProfile Switcher state file and writes a structured resolver result.

The resolver is intentionally limited to identification. It does not execute
profile scripts, apply configuration, modify BCD state or make system changes.

GUID-based detection is used first. Description-based detection remains as a
fallback and diagnostic path.
#>

[CmdletBinding()]
param(
    [switch]$AsJson,

    [string]$OutputPath
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Get-BcdProperty {
    param(
        [Parameter(Mandatory = $true)]
        [AllowEmptyString()]
        [string[]]$Output,

        [Parameter(Mandatory = $true)]
        [string[]]$Names
    )

    foreach ($line in $Output) {
        if ([string]::IsNullOrWhiteSpace($line)) {
            continue
        }

        foreach ($name in $Names) {
            if ($line -match ('^{0}\s+(.+)$' -f [regex]::Escape($name))) {
                return $Matches[1].Trim()
            }
        }
    }

    return $null
}

function Read-BcdCurrentEntry {
    param([switch]$VerboseIdentifier)

    $arguments = @('/enum', '{current}')
    if ($VerboseIdentifier) {
        $arguments += '/v'
    }

    $output = & bcdedit @arguments 2>&1
    if ($LASTEXITCODE -ne 0) {
        $message = ($output | Out-String).Trim()
        throw "Could not read current BCD entry: $message"
    }

    return @($output | ForEach-Object { [string]$_ })
}

function Get-CurrentBcdIdentity {
    $identifier = $null
    $description = $null
    $identifierError = $null
    $descriptionError = $null

    try {
        $verboseOutput = Read-BcdCurrentEntry -VerboseIdentifier
        $candidate = Get-BcdProperty -Output $verboseOutput -Names @('identifier', 'Bezeichner')

        if ($candidate -match '^\{[0-9a-fA-F-]{36}\}$') {
            $identifier = $candidate
        } else {
            $identifierError = "Verbose current BCD entry did not expose a GUID identifier."
        }
    } catch {
        $identifierError = $_.Exception.Message
    }

    try {
        $normalOutput = Read-BcdCurrentEntry
        $description = Get-BcdProperty -Output $normalOutput -Names @('description', 'Beschreibung')

        if (-not $description) {
            $descriptionError = "Current BCD entry did not expose a description."
        }
    } catch {
        $descriptionError = $_.Exception.Message
    }

    return [pscustomobject]@{
        identifier = $identifier
        description = $description
        identifierError = $identifierError
        descriptionError = $descriptionError
    }
}

function Read-ManagedBootProfileState {
    param([string]$StateFile)

    if (-not (Test-Path $StateFile)) {
        return [pscustomobject]@{
            entries = @()
            error = "Managed boot profile state file not found: $StateFile"
        }
    }

    try {
        $state = Get-Content -Path $StateFile -Raw | ConvertFrom-Json
        return [pscustomobject]@{
            entries = @($state.entries)
            error = $null
        }
    } catch {
        return [pscustomobject]@{
            entries = @()
            error = $_.Exception.Message
        }
    }
}

function Find-ManagedEntry {
    param(
        [object[]]$Entries,
        [string]$Identifier,
        [string]$Description
    )

    if ($Identifier) {
        foreach ($entry in $Entries) {
            if ($entry.identifier -eq $Identifier) {
                return [pscustomobject]@{
                    entry = $entry
                    source = 'bcdedit /enum "{current}" /v identifier'
                }
            }
        }
    }

    if ($Description) {
        foreach ($entry in $Entries) {
            if ($entry.name -eq $Description) {
                return [pscustomobject]@{
                    entry = $entry
                    source = 'bcdedit /enum "{current}" description fallback'
                }
            }
        }
    }

    return $null
}

$repoRoot = Split-Path -Parent (Split-Path -Parent $PSCommandPath)
$stateFile = Join-Path $repoRoot 'state\boot-menu.json'

if (-not $OutputPath) {
    $OutputPath = Join-Path $repoRoot 'state\current-boot-profile.json'
}

$identity = Get-CurrentBcdIdentity
$managedState = Read-ManagedBootProfileState -StateFile $stateFile
$match = Find-ManagedEntry -Entries $managedState.entries -Identifier $identity.identifier -Description $identity.description

$errorMessages = @(
    $managedState.error,
    $identity.identifierError,
    $identity.descriptionError
) | Where-Object { -not [string]::IsNullOrWhiteSpace($_) }

$result = [ordered]@{
    schemaVersion = 1
    generatedAt = (Get-Date).ToString('o')
    detected = $null -ne $match
    mode = $null
    name = $null
    identifier = $null
    source = $null
    description = $identity.description
    currentIdentifier = $identity.identifier
    outputPath = $OutputPath
    stateFile = $stateFile
    error = if (@($errorMessages).Count -gt 0) { @($errorMessages) -join ' | ' } else { $null }
}

if ($match) {
    $result.mode = $match.entry.mode
    $result.name = $match.entry.name
    $result.identifier = $match.entry.identifier
    $result.source = $match.source
} elseif (-not $result.error) {
    $result.source = 'unmanaged current boot entry'
}

$outputDirectory = Split-Path -Parent $OutputPath
if (-not (Test-Path $outputDirectory)) {
    New-Item -ItemType Directory -Path $outputDirectory -Force | Out-Null
}

$json = $result | ConvertTo-Json -Depth 5
$json | Set-Content -Path $OutputPath -Encoding UTF8

if ($AsJson) {
    $json
    return
}

if ($result.detected) {
    Write-Host 'Boot profile resolved.'
    Write-Host "Mode:       $($result.mode)"
    Write-Host "Name:       $($result.name)"
    Write-Host "Identifier: $($result.identifier)"
    Write-Host "Source:     $($result.source)"
    Write-Host "Output:     $OutputPath"
} else {
    Write-Host 'No managed BootProfile Switcher profile detected.'
    if ($result.currentIdentifier) {
        Write-Host "Current identifier: $($result.currentIdentifier)"
    }
    if ($result.description) {
        Write-Host "Description:        $($result.description)"
    }
    if ($result.error) {
        Write-Host "Diagnostic:         $($result.error)"
    }
    Write-Host "Output:             $OutputPath"
}
