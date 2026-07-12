<#
.SYNOPSIS
Installs the machine-wide BootProfile Switcher runtime.

.DESCRIPTION
Copies the executable scripts, modules and configuration schemas from a source
repository into ProgramData. Scheduled hooks run only from this runtime so they
do not depend on the profile directory of the user who installed the project.
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$SourceRoot,

    [string]$RuntimeRoot = (Join-Path $env:ProgramData 'BootProfileSwitcher\runtime')
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Assert-Administrator {
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = [Security.Principal.WindowsPrincipal]::new($identity)

    if (-not $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        throw 'Administrator privileges are required to install the machine-wide runtime.'
    }
}

Assert-Administrator

New-Item -ItemType Directory -Path $RuntimeRoot -Force | Out-Null

foreach ($directory in @('scripts', 'modules', 'config')) {
    $source = Join-Path $SourceRoot $directory
    if (-not (Test-Path $source)) {
        throw "Runtime source directory not found: $source"
    }

    $destination = Join-Path $RuntimeRoot $directory
    New-Item -ItemType Directory -Path $destination -Force | Out-Null
    Get-ChildItem -Path $source -Force | Copy-Item -Destination $destination -Recurse -Force
}

foreach ($directory in @('state', 'logs', 'backups')) {
    New-Item -ItemType Directory -Path (Join-Path $RuntimeRoot $directory) -Force | Out-Null
}

# User-logon hooks need to append diagnostics but not modify runtime code or state.
$logDirectory = Join-Path $RuntimeRoot 'logs'
$acl = Get-Acl -Path $logDirectory
$usersSid = [Security.Principal.SecurityIdentifier]::new('S-1-5-32-545')
$rule = [Security.AccessControl.FileSystemAccessRule]::new(
    $usersSid,
    [Security.AccessControl.FileSystemRights]::Modify,
    [Security.AccessControl.InheritanceFlags]'ContainerInherit, ObjectInherit',
    [Security.AccessControl.PropagationFlags]::None,
    [Security.AccessControl.AccessControlType]::Allow
)
$acl.SetAccessRule($rule)
Set-Acl -Path $logDirectory -AclObject $acl

Write-Host "BootProfile Switcher runtime installed: $RuntimeRoot"
