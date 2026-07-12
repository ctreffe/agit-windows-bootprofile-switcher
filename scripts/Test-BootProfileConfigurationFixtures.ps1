<#
.SYNOPSIS
Runs the BootProfile Switcher configuration validator against known fixtures.

.DESCRIPTION
Executes Test-BootProfileConfiguration.ps1 for valid Configuration Format v2
examples and intentionally invalid v2 fixtures. The runner verifies expected
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
        name = 'service-control-wsearch-valid'
        path = Join-Path $repoRoot 'config\test\service-control-wsearch-valid.json'
        expectedValid = $true
    },
    [ordered]@{
        name = 'config-driven-boot-menu-demo'
        path = Join-Path $repoRoot 'config\demos\config-driven-boot-menu.json'
        expectedValid = $true
    },
    [ordered]@{
        name = 'startup-user-application-control-demo'
        path = Join-Path $repoRoot 'config\demos\startup-user-application-control.json'
        expectedValid = $true
    },
    [ordered]@{
        name = 'network-isolation-missing-settings'
        path = Join-Path $repoRoot 'config\test\network-isolation-missing-settings.json'
        expectedValid = $false
    },
    [ordered]@{
        name = 'service-control-unsupported-service'
        path = Join-Path $repoRoot 'config\test\service-control-unsupported-service.json'
        expectedValid = $false
    },
    [ordered]@{
        name = 'service-control-real-apply-valid'
        path = Join-Path $repoRoot 'config\test\service-control-real-apply-valid.json'
        expectedValid = $true
    },
    [ordered]@{
        name = 'startup-user-application-control-valid'
        path = Join-Path $repoRoot 'config\test\startup-user-application-control-valid.json'
        expectedValid = $true
    },
    [ordered]@{
        name = 'startup-user-application-control-unsupported-app'
        path = Join-Path $repoRoot 'config\test\startup-user-application-control-unsupported-app.json'
        expectedValid = $false
    },
    [ordered]@{
        name = 'startup-user-application-control-invalid-process-action'
        path = Join-Path $repoRoot 'config\test\startup-user-application-control-invalid-process-action.json'
        expectedValid = $false
    },
    [ordered]@{
        name = 'startup-user-application-control-real-apply-valid'
        path = Join-Path $repoRoot 'config\test\startup-user-application-control-real-apply-valid.json'
        expectedValid = $true
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
    },
    [ordered]@{
        name = 'v2-legacy-mode'
        path = Join-Path $repoRoot 'config\test\v2-legacy-mode.json'
        expectedValid = $false
    },
    [ordered]@{
        name = 'v2-legacy-module-settings'
        path = Join-Path $repoRoot 'config\test\v2-legacy-module-settings.json'
        expectedValid = $false
    },
    [ordered]@{
        name = 'v2-unknown-top-level'
        path = Join-Path $repoRoot 'config\test\v2-unknown-top-level.json'
        expectedValid = $false
    },
    [ordered]@{
        name = 'v2-invalid-profile-id'
        path = Join-Path $repoRoot 'config\test\v2-invalid-profile-id.json'
        expectedValid = $false
    },
    [ordered]@{
        name = 'v2-empty-modules'
        path = Join-Path $repoRoot 'config\test\v2-empty-modules.json'
        expectedValid = $false
    },
    [ordered]@{
        name = 'v2-invalid-scripts'
        path = Join-Path $repoRoot 'config\test\v2-invalid-scripts.json'
        expectedValid = $false
    },
    [ordered]@{
        name = 'v2-default-display-name-without-rename'
        path = Join-Path $repoRoot 'config\test\v2-default-display-name-without-rename.json'
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
