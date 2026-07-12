<#
.SYNOPSIS
Runs BootProfile Switcher user-logon initialization.

.DESCRIPTION
Invoked by the user-logon scheduled task. The script uses the resolver result
written by the system startup hook, invokes the profile engine in UserLogon
scope and writes the result to logs/user-logon-profile.log.

The user-logon scope is intended for HKCU startup entries and user-session
process handling. Machine-wide startup behavior remains owned by the system
startup hook.
#>

[CmdletBinding()]
param(
    [ValidateRange(0, 300)]
    [int]$DelaySeconds = 30
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$repoRoot = Split-Path -Parent (Split-Path -Parent $PSCommandPath)
$profileEngineScript = Join-Path $repoRoot 'scripts\Invoke-ProfileEngine.ps1'
$resolverStatePath = Join-Path $repoRoot 'state\current-boot-profile.json'
$logDir = Join-Path $repoRoot 'logs'
$logFile = Join-Path $logDir 'user-logon-profile.log'

if (-not (Test-Path $profileEngineScript)) {
    throw "Profile engine script not found at $profileEngineScript"
}

if (-not (Test-Path $resolverStatePath)) {
    throw "Startup resolver state not found at $resolverStatePath"
}

New-Item -ItemType Directory -Path $logDir -Force | Out-Null

$timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss zzz'
$userName = [Security.Principal.WindowsIdentity]::GetCurrent().Name

try {
    if ($DelaySeconds -gt 0) {
        Start-Sleep -Seconds $DelaySeconds
    }

    $result = Get-Content -Path $resolverStatePath -Raw | ConvertFrom-Json
    $engineJson = & $profileEngineScript -ResolverStatePath $resolverStatePath -LogDir $logDir -ExecutionScope UserLogon
    $engineResult = $engineJson | ConvertFrom-Json

    $resolverError = if ($result.error) { ([string]$result.error) -replace "(`r`n|`n|`r)", ' ' } else { $null }
    $moduleNames = @($engineResult.modulesExecuted | ForEach-Object { $_.name }) -join ','
    $configurationErrors = @($engineResult.configurationErrors) -join '; '

    $line = '{0} | user={1} | detected={2} | mode={3} | name={4} | identifier={5} | source={6} | engineStatePath={7} | modulesExecuted={8} | configurationValid={9} | configurationPath={10} | configurationErrors={11} | profileConfigured={12} | dispatchSkippedReason={13} | resolverError={14}' -f `
        $timestamp,
        $userName,
        $result.detected,
        $result.mode,
        $result.name,
        $result.identifier,
        $result.source,
        $result.outputPath,
        $moduleNames,
        $engineResult.configurationValid,
        $engineResult.configurationPath,
        $configurationErrors,
        $engineResult.profileConfigured,
        $engineResult.dispatchSkippedReason,
        $resolverError

    Add-Content -Path $logFile -Value $line -Encoding UTF8
}
catch {
    $message = $_.Exception.Message -replace "(`r`n|`n|`r)", ' '
    $line = '{0} | user={1} | detected=false | error={2}' -f $timestamp, $userName, $message
    Add-Content -Path $logFile -Value $line -Encoding UTF8
    throw
}
