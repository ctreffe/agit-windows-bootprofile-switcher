<#
.SYNOPSIS
Removes an inactive BootProfile Switcher runtime from outside that runtime.
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$RuntimeRoot,

    [Parameter(Mandatory = $true)]
    [string]$ResultPath,

    [ValidateRange(1, 60)]
    [int]$DelaySeconds = 5
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$result = [ordered]@{
    schemaVersion = 1
    startedAt = (Get-Date).ToString('o')
    runtimeRoot = $RuntimeRoot
    succeeded = $false
    error = $null
}

try {
    Start-Sleep -Seconds $DelaySeconds
    if (Test-Path -LiteralPath $RuntimeRoot) {
        Remove-Item -LiteralPath $RuntimeRoot -Recurse -Force
    }
    $result.succeeded = -not (Test-Path -LiteralPath $RuntimeRoot)
    if (-not $result.succeeded) {
        throw "Runtime directory still exists after cleanup: $RuntimeRoot"
    }
}
catch {
    $result.error = $_.Exception.Message
}

$result.completedAt = (Get-Date).ToString('o')
New-Item -ItemType Directory -Path (Split-Path -Parent $ResultPath) -Force | Out-Null
$result | ConvertTo-Json -Depth 4 | Set-Content -Path $ResultPath -Encoding UTF8

if (-not $result.succeeded) { exit 5 }
