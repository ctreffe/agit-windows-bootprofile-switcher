[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$helper = Join-Path $PSScriptRoot 'Test-ExternalStorage.ps1'
$temporaryRoot = [IO.Path]::GetFullPath([IO.Path]::GetTempPath())
$fixtureRoot = Join-Path $temporaryRoot ('Templateverse-ExternalStorage-' + [guid]::NewGuid().ToString('N'))
$junctionPath = $null
$checks = 0
$optional = @()

function Assert-Result {
    param([bool]$Condition, [string]$Message)
    if (-not $Condition) { throw $Message }
    $script:checks++
}
function Assert-Refused {
    param([scriptblock]$Action)
    $refused = $false
    try { & $Action | Out-Null } catch { $refused = $true }
    Assert-Result $refused 'Unsafe or invalid selection was accepted.'
}

try {
    New-Item -ItemType Directory -Path (Join-Path $fixtureRoot 'input/local') -Force | Out-Null
    New-Item -ItemType Directory -Path (Join-Path $fixtureRoot 'materials') -Force | Out-Null
    $marker = Join-Path $fixtureRoot 'PROJECT_ID.txt'
    $source = Join-Path $fixtureRoot 'input/local/source.txt'
    $material = Join-Path $fixtureRoot 'materials/foundation.txt'
    [IO.File]::WriteAllText($marker, "project-a`nversion: 1`n")
    [IO.File]::WriteAllText($source, 'Invented source content')
    [IO.File]::WriteAllText($material, 'Invented working material')
    $before = (Get-FileHash -LiteralPath $source -Algorithm SHA256).Hash

    $result = & $helper -ProjectPath $fixtureRoot -ProjectId 'project-a'
    Assert-Result ($result.Project -eq 'verified' -and @($result.Files).Count -eq 0) 'Marker-only check failed.'
    Assert-Result ($result.SyncStatus -eq 'not_checked') 'Local metadata claimed a provider sync check.'

    $result = & $helper -ProjectPath $fixtureRoot -ProjectId 'project-a' -RelativeFile @(
        'input/local/source.txt', 'materials/foundation.txt', 'materials/absent.txt')
    Assert-Result ($result.Files[0].Availability -eq 'local_file' -and
        $result.Files[1].Availability -eq 'local_file' -and
        $result.Files[2].Availability -eq 'missing') 'Exact selected-file availability failed.'
    Assert-Result ($result.Files[0].Integrity -eq 'not_checked') 'Default check hashed content.'

    $result = & $helper -ProjectPath $fixtureRoot -ProjectId 'project-a' `
        -RelativeFile 'input/local/source.txt' -ExpectedSha256 @{'input/local/source.txt' = $before}
    Assert-Result ($result.Files[0].Integrity -eq 'match') 'Expected hash did not match.'
    $result = & $helper -ProjectPath $fixtureRoot -ProjectId 'project-a' `
        -RelativeFile 'input/local/source.txt' -ExpectedSha256 @{'input/local/source.txt' = ('0' * 64)}
    Assert-Result ($result.Files[0].Integrity -eq 'mismatch') 'Hash mismatch was not detected.'
    $result = & $helper -ProjectPath $fixtureRoot -ProjectId 'another-project' -RelativeFile 'materials/foundation.txt'
    Assert-Result ($result.Project -eq 'project_mismatch' -and
        $result.Files[0].Availability -eq 'not_checked') 'Mismatched marker did not stop dependent checks.'
    [IO.File]::WriteAllText($marker, 'x' * 257)
    $result = & $helper -ProjectPath $fixtureRoot -ProjectId 'project-a'
    Assert-Result ($result.Project -eq 'invalid_marker') 'Oversized marker was accepted.'
    [IO.File]::WriteAllText($marker, 'project-a')

    foreach ($unsafe in @('input/restricted/file.txt', 'input/intake/file.txt',
            'temp/state.txt', '../other.txt', 'materials/../other.txt',
            '/materials/file.txt', 'materials/*.txt', 'materials/file.txt:stream',
            'materials/.. /other.txt', 'materials/file.txt.')) {
        Assert-Refused { & $helper -ProjectPath $fixtureRoot -ProjectId 'project-a' -RelativeFile $unsafe }
    }
    Assert-Refused { & $helper -ProjectPath '.' -ProjectId 'project-a' }
    Assert-Refused { & $helper -ProjectPath $fixtureRoot -ProjectId '../invalid' }
    Assert-Refused { & $helper -ProjectPath $fixtureRoot -ProjectId 'project-a' `
        -RelativeFile 'materials/foundation.txt' -ExpectedSha256 @{'materials/other.txt' = ('0' * 64)} }
    Assert-Refused { & $helper -ProjectPath $fixtureRoot -ProjectId 'project-a' `
        -RelativeFile 'materials/foundation.txt' -ExpectedSha256 @{'materials/foundation.txt' = 'invalid'} }

    if ([IO.Path]::DirectorySeparatorChar -eq '\') {
        [IO.File]::SetAttributes($source, [IO.FileAttributes]::Offline)
        try {
            $result = & $helper -ProjectPath $fixtureRoot -ProjectId 'project-a' `
                -RelativeFile 'input/local/source.txt' -ExpectedSha256 @{'input/local/source.txt' = $before}
            Assert-Result ($result.Files[0].Availability -eq 'placeholder' -and
                $result.Files[0].Integrity -eq 'not_checked') 'Offline file was opened for hashing.'
        } finally { [IO.File]::SetAttributes($source, [IO.FileAttributes]::Normal) }

        $junctionPath = Join-Path $fixtureRoot 'materials/linked'
        New-Item -ItemType Junction -Path $junctionPath -Target (Join-Path $fixtureRoot 'input/local') | Out-Null
        $result = & $helper -ProjectPath $fixtureRoot -ProjectId 'project-a' -RelativeFile 'materials/linked/source.txt'
        Assert-Result ($result.Files[0].Availability -eq 'unsupported_reparse_point') 'Linked parent was followed.'
        $result = & $helper -ProjectPath $junctionPath -ProjectId 'project-a'
        Assert-Result ($result.Project -eq 'unsupported_reparse_point') 'Linked project root was followed.'
    } else { $optional += 'Windows offline and junction cases not applicable.' }

    Assert-Result ((Get-FileHash -LiteralPath $source -Algorithm SHA256).Hash -eq $before) 'Helper modified input.'
    Assert-Result (([IO.File]::ReadAllText($marker)) -ceq 'project-a') 'Helper modified the marker.'
    Write-Output "[PASS] External storage helper: $checks synthetic behavior assertions."
    foreach ($note in $optional) { Write-Output "[N/A] $note" }
} finally {
    # Check the exact generated target before recursive cleanup. Remove the
    # synthetic junction itself first, without traversing its target.
    $cleanupPath = [IO.Path]::GetFullPath($fixtureRoot)
    $cleanupParent = [IO.Directory]::GetParent($cleanupPath).FullName.TrimEnd('\', '/')
    if ($cleanupParent -ne $temporaryRoot.TrimEnd('\', '/') -or
        [IO.Path]::GetFileName($cleanupPath) -notmatch '\ATemplateverse-ExternalStorage-[0-9a-f]{32}\z') {
        throw 'Refusing cleanup outside the generated temporary fixture.'
    }
    if ($null -ne $junctionPath -and [IO.Directory]::Exists($junctionPath)) {
        [IO.Directory]::Delete($junctionPath)
    }
    if (Test-Path -LiteralPath $cleanupPath) {
        Remove-Item -LiteralPath $cleanupPath -Recurse -Force
    }
}
