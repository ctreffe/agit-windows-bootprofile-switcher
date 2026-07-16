<#
.SYNOPSIS
Restores the current user's Startup and User-Application Control baseline.
#>
[CmdletBinding()]
param([switch]$AsJson)
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$runtimeRoot = Split-Path -Parent (Split-Path -Parent $PSCommandPath)
$machineRoot = Split-Path -Parent $runtimeRoot
$markerPath = Join-Path $machineRoot 'state\pending-user-baseline-restore.json'
$completionPath = Join-Path $env:LOCALAPPDATA 'BootProfileSwitcher\state\pending-user-baseline-restore.json'
function Result([bool]$Succeeded, [int]$ExitCode, [string]$ErrorMessage, [string]$RestoreId) { $value = [ordered]@{ schemaVersion = 1; succeeded = $Succeeded; exitCode = $ExitCode; restoreId = $RestoreId; completionPath = $completionPath; error = $ErrorMessage }; if ($AsJson) { $value | ConvertTo-Json -Depth 4 } else { [pscustomobject]$value } }
try {
    if (-not (Test-Path -LiteralPath $markerPath)) { Result $true 0 $null $null; exit 0 }
    $marker = Get-Content -LiteralPath $markerPath -Raw | ConvertFrom-Json
    if ((Test-Path -LiteralPath $completionPath) -and ((Get-Content -LiteralPath $completionPath -Raw | ConvertFrom-Json).restoreId -eq $marker.restoreId)) { Result $true 0 $null ([string]$marker.restoreId); exit 0 }
    $config = Get-Content -LiteralPath ([string]$marker.configPath) -Raw | ConvertFrom-Json
    $settings = @($config.profiles | ForEach-Object { $_.modules.PSObject.Properties['startup-user-application-control'] } | Where-Object { $null -ne $_ } | Select-Object -First 1)
    if ($settings.Count -eq 0) { throw 'Pending user restore configuration has no startup-user-application-control settings.' }
    $module = Join-Path $runtimeRoot 'modules\startup-user-application-control\Invoke-StartupUserApplicationControlModule.ps1'
    $logDir = Join-Path $runtimeRoot 'logs'
    & $module -Mode 'unmanaged' -Name 'Unmanaged Windows startup' -Identifier 'unmanaged' -RepoRoot $runtimeRoot -LogDir $logDir -ModuleSettings $settings[0].Value -Controlling $false -Detected $false -ExecutionScope UserLogon
    New-Item -ItemType Directory -Path (Split-Path -Parent $completionPath) -Force | Out-Null
    ([ordered]@{ schemaVersion = 1; restoreId = $marker.restoreId; completedAt = (Get-Date).ToString('o'); user = [Security.Principal.WindowsIdentity]::GetCurrent().Name }) | ConvertTo-Json | Set-Content -Path $completionPath -Encoding UTF8
    Result $true 0 $null ([string]$marker.restoreId); exit 0
} catch { Result $false 1 $_.Exception.Message $null; exit 1 }
