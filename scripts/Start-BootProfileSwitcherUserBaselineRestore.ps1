<#
.SYNOPSIS
Schedules per-user baseline restoration through the installed user-logon hook.
#>
[CmdletBinding(SupportsShouldProcess)]
param([string]$ConfigPath, [switch]$AsJson)
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$runtimeRoot = Split-Path -Parent (Split-Path -Parent $PSCommandPath)
$machineRoot = Split-Path -Parent $runtimeRoot
if (-not $ConfigPath) { $ConfigPath = Join-Path $machineRoot 'config\profiles.json' }
$markerPath = Join-Path $machineRoot 'state\pending-user-baseline-restore.json'

function Result([bool]$Succeeded, [int]$ExitCode, [string]$ErrorMessage, [string]$RestoreId) {
    $value = [ordered]@{ schemaVersion = 1; succeeded = $Succeeded; exitCode = $ExitCode; whatIf = [bool]$WhatIfPreference; markerPath = $markerPath; configurationPath = $ConfigPath; restoreId = $RestoreId; error = $ErrorMessage }
    if ($AsJson) { $value | ConvertTo-Json -Depth 4 } else { [pscustomobject]$value }
}

try {
    $ConfigPath = [System.IO.Path]::GetFullPath($ConfigPath)
    $validator = Join-Path $runtimeRoot 'scripts\Test-BootProfileConfiguration.ps1'
    foreach ($path in @($ConfigPath, $validator)) { if (-not (Test-Path -LiteralPath $path)) { throw "User baseline restore prerequisite not found: $path" } }
    $output = & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $validator -ConfigPath $ConfigPath -AsJson 2>&1
    $validation = (($output | Out-String).Trim()) | ConvertFrom-Json
    if ($LASTEXITCODE -ne 0 -or -not $validation.valid) { throw "User baseline restore requires a valid configuration: $(@($validation.errors) -join '; ')" }
    $configuration = Get-Content -LiteralPath $ConfigPath -Raw | ConvertFrom-Json
    $settings = @($configuration.profiles | ForEach-Object { $_.modules.PSObject.Properties['startup-user-application-control'] } | Where-Object { $null -ne $_ })
    if ($settings.Count -eq 0) { throw 'The configuration does not contain startup-user-application-control.' }
    if (@($settings | Where-Object { $_.Value.PSObject.Properties['dryRun'] -and [bool]$_.Value.dryRun }).Count -gt 0) { throw 'User baseline restore requires dryRun=false for startup-user-application-control.' }
    $restoreId = [guid]::NewGuid().ToString()
    if ($WhatIfPreference) { Result $true 0 $null $restoreId; exit 0 }
    $marker = [ordered]@{ schemaVersion = 1; restoreId = $restoreId; createdAt = (Get-Date).ToString('o'); configPath = $ConfigPath; source = 'deployment-uninstall'; purpose = 'Restore per-user Startup and User-Application Control baselines before final cleanup.' }
    New-Item -ItemType Directory -Path (Split-Path -Parent $markerPath) -Force | Out-Null
    $marker | ConvertTo-Json -Depth 4 | Set-Content -Path $markerPath -Encoding UTF8
    Result $true 0 $null $restoreId; exit 0
} catch { Result $false 1 $_.Exception.Message $null; exit 1 }
