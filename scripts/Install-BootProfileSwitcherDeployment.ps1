<#
.SYNOPSIS
Installs the machine-wide BootProfile Switcher runtime for unattended deployment.

.DESCRIPTION
Provides the first v1.7.0 deployment path for MDT and similar tools. The
script copies the runtime to ProgramData, optionally validates and installs a
profile configuration, then optionally registers the machine startup and
user-logon hooks. It never prompts for input and does not manage BCD entries.

The source directory is supplied explicitly so the script works from an MDT
package location without depending on its current working directory. After a
successful install, hooks refer only to the copied local runtime.
#>

[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory = $true)]
    [string]$SourceRoot,

    [string]$ConfigurationPath,

    [switch]$InstallStartupHook,

    [switch]$InstallUserLogonHook,

    [switch]$Force,

    [switch]$AsJson
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$machineRoot = Join-Path $env:ProgramData 'BootProfileSwitcher'
$runtimeRoot = Join-Path $machineRoot 'runtime'
$installedConfigurationPath = Join-Path $machineRoot 'config\profiles.json'
$deploymentLogPath = Join-Path $machineRoot 'logs\deployment.log'
$script:failureExitCode = 1
$actions = [System.Collections.Generic.List[string]]::new()

function Test-Administrator {
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = [Security.Principal.WindowsPrincipal]::new($identity)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Set-Failure {
    param(
        [int]$ExitCode,
        [string]$Message
    )

    $script:failureExitCode = $ExitCode
    throw $Message
}

function Write-DeploymentLog {
    param([string]$Message)

    $logDirectory = Split-Path -Parent $deploymentLogPath
    New-Item -ItemType Directory -Path $logDirectory -Force | Out-Null
    $timestamp = (Get-Date).ToString('o')
    Add-Content -Path $deploymentLogPath -Value "$timestamp | $Message" -Encoding UTF8
}

function Get-Sha256Hash {
    param([string]$Path)

    # Get-FileHash can be suppressed by WhatIf. This direct read keeps the
    # configuration comparison available during a no-change deployment preview.
    $stream = [System.IO.File]::Open(
        $Path,
        [System.IO.FileMode]::Open,
        [System.IO.FileAccess]::Read,
        [System.IO.FileShare]::Read
    )
    $hasher = [System.Security.Cryptography.SHA256]::Create()

    try {
        return ([System.BitConverter]::ToString($hasher.ComputeHash($stream))).Replace('-', '')
    }
    finally {
        $hasher.Dispose()
        $stream.Dispose()
    }
}

function Test-ConfigurationFile {
    param(
        [string]$ValidatorScript,
        [string]$Path
    )

    $output = & powershell.exe `
        -NoProfile `
        -ExecutionPolicy Bypass `
        -File $ValidatorScript `
        -ConfigPath $Path `
        -AsJson 2>&1
    $validatorExitCode = $LASTEXITCODE

    try {
        $result = (($output | Out-String).Trim()) | ConvertFrom-Json
    }
    catch {
        Set-Failure -ExitCode 1 -Message "Could not parse configuration validation output for ${Path}: $($_.Exception.Message)"
    }

    if ($validatorExitCode -ne 0 -or -not $result.valid) {
        $errors = @($result.errors) -join '; '
        Set-Failure -ExitCode 1 -Message "Profile configuration is invalid: $errors"
    }
}

function Invoke-DeploymentStep {
    param(
        [string]$Name,
        [int]$ExitCode,
        [scriptblock]$Action
    )

    try {
        & $Action
        $actions.Add($Name)
    }
    catch {
        $script:failureExitCode = $ExitCode
        throw
    }
}

function Write-DeploymentResult {
    param(
        [bool]$Succeeded,
        [int]$ExitCode,
        [string]$ErrorMessage,
        [string]$ConfigurationAction
    )

    $result = [ordered]@{
        schemaVersion = 1
        succeeded = $Succeeded
        exitCode = $ExitCode
        whatIf = [bool]$WhatIfPreference
        sourceRoot = $SourceRoot
        runtimeRoot = $runtimeRoot
        configurationPath = $installedConfigurationPath
        configurationAction = $ConfigurationAction
        startupHookRequested = [bool]$InstallStartupHook
        userLogonHookRequested = [bool]$InstallUserLogonHook
        actions = @($actions)
        error = $ErrorMessage
    }

    if ($AsJson) {
        $result | ConvertTo-Json -Depth 4
    } else {
        [pscustomobject]$result
    }
}

$configurationAction = 'not-requested'

try {
    # Resolve-Path participates in PowerShell WhatIf handling on some systems.
    # Path.GetFullPath keeps validation read-only and therefore makes WhatIf a
    # useful complete deployment preview.
    $SourceRoot = [System.IO.Path]::GetFullPath($SourceRoot)

    foreach ($requiredDirectory in @('scripts', 'modules', 'config')) {
        if (-not (Test-Path -LiteralPath (Join-Path $SourceRoot $requiredDirectory))) {
            Set-Failure -ExitCode 1 -Message "Deployment source is missing required directory: $requiredDirectory"
        }
    }

    $sourceRuntimeInstaller = Join-Path $SourceRoot 'scripts\Install-BootProfileRuntime.ps1'
    $sourceValidator = Join-Path $SourceRoot 'scripts\Test-BootProfileConfiguration.ps1'

    foreach ($requiredScript in @($sourceRuntimeInstaller, $sourceValidator)) {
        if (-not (Test-Path -LiteralPath $requiredScript)) {
            Set-Failure -ExitCode 1 -Message "Deployment source is missing required script: $requiredScript"
        }
    }

    if ($ConfigurationPath) {
        $ConfigurationPath = [System.IO.Path]::GetFullPath($ConfigurationPath)
        Test-ConfigurationFile -ValidatorScript $sourceValidator -Path $ConfigurationPath

        if (Test-Path -LiteralPath $installedConfigurationPath) {
            $sourceHash = Get-Sha256Hash -Path $ConfigurationPath
            $installedHash = Get-Sha256Hash -Path $installedConfigurationPath

            if ($sourceHash -eq $installedHash) {
                $configurationAction = 'unchanged'
            }
            elseif (-not $Force) {
                Set-Failure -ExitCode 1 -Message "A different managed configuration already exists at $installedConfigurationPath. Re-run with -Force to replace it."
            }
            else {
                $configurationAction = 'replace'
            }
        }
        else {
            $configurationAction = 'install'
        }
    }

    if ($WhatIfPreference) {
        $actions.Add('would-install-or-update-runtime')
        if ($configurationAction -in @('install', 'replace')) {
            $actions.Add("would-$configurationAction-configuration")
        }
        if ($InstallStartupHook) {
            $actions.Add('would-install-startup-hook')
        }
        if ($InstallUserLogonHook) {
            $actions.Add('would-install-user-logon-hook')
        }

        Write-DeploymentResult -Succeeded $true -ExitCode 0 -ErrorMessage $null -ConfigurationAction $configurationAction
        exit 0
    }

    if (-not (Test-Administrator)) {
        Set-Failure -ExitCode 1 -Message 'Administrator privileges are required for machine deployment.'
    }

    try {
        Write-DeploymentLog -Message "deployment-start sourceRoot=$SourceRoot"
    }
    catch {
        Set-Failure -ExitCode 2 -Message "Could not create the deployment log: $($_.Exception.Message)"
    }

    Invoke-DeploymentStep -Name 'runtime-installed' -ExitCode 2 -Action {
        & $sourceRuntimeInstaller -SourceRoot $SourceRoot -RuntimeRoot $runtimeRoot
    }

    if ($configurationAction -in @('install', 'replace')) {
        $installedConfigurationInstaller = Join-Path $runtimeRoot 'scripts\Install-BootProfileConfiguration.ps1'
        if (-not (Test-Path -LiteralPath $installedConfigurationInstaller)) {
            Set-Failure -ExitCode 2 -Message "Installed configuration installer not found: $installedConfigurationInstaller"
        }

        Invoke-DeploymentStep -Name "configuration-$configurationAction" -ExitCode 1 -Action {
            & $installedConfigurationInstaller `
                -SourcePath $ConfigurationPath `
                -DestinationPath $installedConfigurationPath `
                -Force
        }
    }

    if ($InstallStartupHook) {
        $startupHookInstaller = Join-Path $runtimeRoot 'scripts\Install-StartupHook.ps1'
        Invoke-DeploymentStep -Name 'startup-hook-installed' -ExitCode 3 -Action {
            & $startupHookInstaller
        }
    }

    if ($InstallUserLogonHook) {
        $userLogonHookInstaller = Join-Path $runtimeRoot 'scripts\Install-UserLogonHook.ps1'
        Invoke-DeploymentStep -Name 'user-logon-hook-installed' -ExitCode 3 -Action {
            & $userLogonHookInstaller
        }
    }

    Write-DeploymentLog -Message "deployment-success actions=$(@($actions) -join ',') configurationAction=$configurationAction"
    Write-DeploymentResult -Succeeded $true -ExitCode 0 -ErrorMessage $null -ConfigurationAction $configurationAction
    exit 0
}
catch {
    $message = $_.Exception.Message

    if (-not $WhatIfPreference) {
        try {
            Write-DeploymentLog -Message "deployment-failed exitCode=$script:failureExitCode error=$message"
        }
        catch {
            # Preserve the original deployment error when logging is unavailable.
        }
    }

    Write-DeploymentResult `
        -Succeeded $false `
        -ExitCode $script:failureExitCode `
        -ErrorMessage $message `
        -ConfigurationAction $configurationAction
    exit $script:failureExitCode
}
