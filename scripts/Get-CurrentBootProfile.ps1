<#
.SYNOPSIS
Detects the currently selected managed BootProfile Switcher boot profile.

.DESCRIPTION
Reads the current Windows Boot Configuration Data entry by calling
`bcdedit /enum "{current}" /v`, extracts the real BCD entry identifier, and maps
it to the managed boot menu entries stored in state/boot-menu.json.

If GUID-based detection is unavailable, the script falls back to the BCD entry
description exposed by `bcdedit /enum "{current}"`.
#>

[CmdletBinding()]
param(
    [switch]$AsJson
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

function Get-BcdCurrentIdentifier {
    $output = Read-BcdCurrentEntry -VerboseIdentifier
    $identifier = Get-BcdProperty -Output $output -Names @('identifier', 'Bezeichner')

    if ($identifier -match '^\{[0-9a-fA-F-]{36}\}$') {
        return $identifier
    }

    $joined = ($output | Out-String).Trim()
    throw "Could not parse current BCD entry GUID from verbose bcdedit output: $joined"
}

function Get-BcdCurrentDescription {
    $output = Read-BcdCurrentEntry
    $description = Get-BcdProperty -Output $output -Names @('description', 'Beschreibung')

    if ($description) {
        return $description
    }

    $joined = ($output | Out-String).Trim()
    throw "Could not parse current BCD entry description from bcdedit output: $joined"
}

$repoRoot = Split-Path -Parent (Split-Path -Parent $PSCommandPath)
$stateFile = Join-Path $repoRoot 'state\boot-menu.json'

if (-not (Test-Path $stateFile)) {
    throw "No BootProfile Switcher state file found at $stateFile. Run install.cmd or scripts/Install-BootProfileMenu.ps1 first."
}

$state = Get-Content -Path $stateFile -Raw | ConvertFrom-Json
$currentIdentifier = $null
$currentDescription = $null
$source = $null

$matchedEntry = $null
$guidError = $null

try {
    $currentIdentifier = Get-BcdCurrentIdentifier
    foreach ($entry in $state.entries) {
        if ($entry.identifier -eq $currentIdentifier) {
            $matchedEntry = $entry
            $source = 'bcdedit /enum "{current}" /v identifier'
            break
        }
    }
} catch {
    $guidError = $_.Exception.Message
}

if (-not $matchedEntry) {
    $currentDescription = Get-BcdCurrentDescription
    foreach ($entry in $state.entries) {
        if ($entry.name -eq $currentDescription) {
            $matchedEntry = $entry
            $source = 'bcdedit /enum "{current}" description fallback'
            break
        }
    }
}

$result = [ordered]@{
    detected = $null -ne $matchedEntry
    source = $source
    currentIdentifier = $currentIdentifier
    currentDescription = $currentDescription
    guidError = $guidError
    mode = $null
    name = $null
    identifier = $null
}

if ($matchedEntry) {
    $result.mode = $matchedEntry.mode
    $result.name = $matchedEntry.name
    $result.identifier = $matchedEntry.identifier
}

if ($AsJson) {
    $result | ConvertTo-Json -Depth 5
    return
}

if ($matchedEntry) {
    Write-Host 'Current BootProfile Switcher profile detected.'
    Write-Host "Mode:        $($matchedEntry.mode)"
    Write-Host "Name:        $($matchedEntry.name)"
    Write-Host "Identifier:  $($matchedEntry.identifier)"
    Write-Host "Source:      $source"
} else {
    Write-Warning 'Current boot entry is not a managed BootProfile Switcher profile.'
    if ($currentIdentifier) {
        Write-Host "Identifier:  $currentIdentifier"
    }
    if ($currentDescription) {
        Write-Host "Description: $currentDescription"
    }
}
