<#
.SYNOPSIS
Runs the BootProfile Switcher configuration validator against known fixtures.

.DESCRIPTION
Executes Test-BootProfileConfiguration.ps1 for the valid example configuration
and a small set of intentionally invalid fixtures. The runner verifies expected
valid/invalid outcomes without applying system changes or executing profile
configuration.
#>

[CmdletBinding()]
param(
    [switch]$AsJson
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Invoke-ValidatorFixture {
    param(
        [string]$Name,
        [string]$Path,
        [bool]$ExpectedValid,
        [string]$ValidatorScript
    )

    $output = & powershell.exe `
        -NoProfile `
        -ExecutionPolicy Bypass `
        -File $ValidatorScript `
        -ConfigPath $Path `
        -AsJson 2>&1
    $exitCode = $LASTEXITCODE
    $jsonText = ($output | Out-String).Trim()
    $result = $jsonText | ConvertFrom-Json
    $actualValid = [bool]$result.valid
    $passed = $actualValid -eq $ExpectedValid

    if ($ExpectedValid -and $exitCode -ne 0) {
        $passed = $false
    }

    if ((-not $ExpectedValid) -and $exitCode -eq 0) {
        $passed = $false
    }

    return [ordered]@{
        name = $Name
        path = $Path
        expectedValid = $ExpectedValid
        actualValid = $actualValid
        exitCode = $exitCode
        passed = $passed
        errors = @($result.errors)
    }
}

$repoRoot = Split-Path -Parent (Split-Path -Parent $PSCommandPath)
$validatorScript = Join-Path $repoRoot 'scripts\Test-BootProfileConfiguration.ps1'

if (-not (Test-Path $validatorScript)) {
    throw "Configuration validator not found at $validatorScript"
}

$fixtures = @(
    [ordered]@{
        name = 'valid-example'
        path = Join-Path $repoRoot 'config\profiles.example.json'
        expectedValid = $true
    },
    [ordered]@{
        name = 'valid-v2-example'
        path = Join-Path $repoRoot 'config\profiles.v2.example.json'
        expectedValid = $true
    },
    [ordered]@{
        name = 'network-isolation-valid'
        path = Join-Path $repoRoot 'config\test\network-isolation-valid.json'
        expectedValid = $true
    },
    [ordered]@{
        name = 'network-isolation-demo'
        path = Join-Path $repoRoot 'config\demos\network-isolation.json'
        expectedValid = $true
    },
    [ordered]@{
        name = 'duplicate-profile-name'
        path = Join-Path $repoRoot 'config\test\duplicate-profile-name.json'
        expectedValid = $false
    },
    [ordered]@{
        name = 'duplicate-profile-mode'
        path = Join-Path $repoRoot 'config\test\duplicate-profile-mode.json'
        expectedValid = $false
    },
    [ordered]@{
        name = 'missing-scripts-array'
        path = Join-Path $repoRoot 'config\test\missing-scripts-array.json'
        expectedValid = $false
    },
    [ordered]@{
        name = 'unknown-module'
        path = Join-Path $repoRoot 'config\test\unknown-module.json'
        expectedValid = $false
    },
    [ordered]@{
        name = 'network-isolation-missing-settings'
        path = Join-Path $repoRoot 'config\test\network-isolation-missing-settings.json'
        expectedValid = $false
    },
    [ordered]@{
        name = 'v2-duplicate-profile-id'
        path = Join-Path $repoRoot 'config\test\v2-duplicate-profile-id.json'
        expectedValid = $false
    },
    [ordered]@{
        name = 'v2-duplicate-display-name'
        path = Join-Path $repoRoot 'config\test\v2-duplicate-display-name.json'
        expectedValid = $false
    },
    [ordered]@{
        name = 'v2-invalid-default-entry'
        path = Join-Path $repoRoot 'config\test\v2-invalid-default-entry.json'
        expectedValid = $false
    },
    [ordered]@{
        name = 'v2-invalid-module-settings'
        path = Join-Path $repoRoot 'config\test\v2-invalid-module-settings.json'
        expectedValid = $false
    }
)

$results = @()

foreach ($fixture in $fixtures) {
    if (-not (Test-Path $fixture.path)) {
        $results += [ordered]@{
            name = $fixture.name
            path = $fixture.path
            expectedValid = $fixture.expectedValid
            actualValid = $null
            exitCode = $null
            passed = $false
            errors = @("Fixture file not found: $($fixture.path)")
        }
        continue
    }

    $results += Invoke-ValidatorFixture `
        -Name $fixture.name `
        -Path $fixture.path `
        -ExpectedValid $fixture.expectedValid `
        -ValidatorScript $validatorScript
}

$failed = @($results | Where-Object { -not $_.passed })
$summary = [ordered]@{
    schemaVersion = 1
    generatedAt = (Get-Date).ToString('o')
    passed = $failed.Count -eq 0
    total = $results.Count
    failed = $failed.Count
    results = @($results)
}

$json = $summary | ConvertTo-Json -Depth 8

if ($AsJson) {
    $json
} else {
    foreach ($result in $results) {
        $status = if ($result.passed) { 'PASS' } else { 'FAIL' }
        Write-Host "$status $($result.name)"
    }
}

if (-not $summary.passed) {
    exit 1
}
