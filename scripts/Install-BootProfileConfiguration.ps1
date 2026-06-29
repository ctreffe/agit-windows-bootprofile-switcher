<#
.SYNOPSIS
Installs the machine-wide BootProfile Switcher profile configuration.

.DESCRIPTION
Validates a profile configuration JSON file and copies it to the default
machine-wide configuration location used by the profile engine:
C:\ProgramData\BootProfileSwitcher\config\profiles.json.

The script is intentionally narrow. It does not install boot menu entries,
scheduled tasks or modules. Existing configuration is preserved unless the user
confirms replacement or passes -Force.
#>

[CmdletBinding(SupportsShouldProcess = $true)]
param(
    [string]$SourcePath,

    [string]$DestinationPath,

    [switch]$Force
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Test-Administrator {
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = [Security.Principal.WindowsPrincipal]::new($identity)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Read-YesNo {
    param(
        [string]$Prompt
    )

    $answer = Read-Host "$Prompt [y/N]"
    return $answer -match '^(y|yes|j|ja)$'
}

$repoRoot = Split-Path -Parent (Split-Path -Parent $PSCommandPath)

if (-not $SourcePath) {
    $SourcePath = Join-Path $repoRoot 'config\profiles.v2.example.json'
}

if (-not $DestinationPath) {
    $DestinationPath = Join-Path $env:ProgramData 'BootProfileSwitcher\config\profiles.json'
}

if (-not $WhatIfPreference -and -not (Test-Administrator)) {
    throw 'This script must be run from an elevated PowerShell session.'
}

if (-not (Test-Path $SourcePath)) {
    throw "Profile configuration source file not found: $SourcePath"
}

$validatorScript = Join-Path $repoRoot 'scripts\Test-BootProfileConfiguration.ps1'

if (-not (Test-Path $validatorScript)) {
    throw "Configuration validator not found at $validatorScript"
}

$validationOutput = & powershell.exe `
    -NoProfile `
    -ExecutionPolicy Bypass `
    -File $validatorScript `
    -ConfigPath $SourcePath `
    -AsJson 2>&1
$validationExitCode = $LASTEXITCODE
$validation = (($validationOutput | Out-String).Trim()) | ConvertFrom-Json

if (-not $validation.valid) {
    Write-Warning 'Profile configuration is invalid and will not be installed.'
    foreach ($validationError in @($validation.errors)) {
        Write-Host "- $validationError"
    }

    exit 1
}

$destinationDirectory = Split-Path -Parent $DestinationPath
$destinationExists = Test-Path $DestinationPath

if ($destinationExists -and -not $Force) {
    Write-Host "Existing profile configuration found: $DestinationPath"
    $shouldReplace = Read-YesNo -Prompt 'Replace existing profile configuration'

    if (-not $shouldReplace) {
        throw 'Configuration installation cancelled. Existing profile configuration was left unchanged.'
    }
}

if ($PSCmdlet.ShouldProcess($destinationDirectory, 'Create configuration directory')) {
    New-Item -ItemType Directory -Path $destinationDirectory -Force | Out-Null
}

if ($PSCmdlet.ShouldProcess($DestinationPath, "Copy validated profile configuration from $SourcePath")) {
    Copy-Item -Path $SourcePath -Destination $DestinationPath -Force
}

if ($WhatIfPreference) {
    Write-Host 'BootProfile Switcher profile configuration validated. WhatIf mode did not install files.'
} else {
    Write-Host 'BootProfile Switcher profile configuration installed.'
}

Write-Host "Source:      $SourcePath"
Write-Host "Destination: $DestinationPath"
Write-Host "Validation:  valid"
Write-Host "Exit code:   $validationExitCode"
