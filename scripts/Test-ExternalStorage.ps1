[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)][string]$ProjectPath,
    [Parameter(Mandatory = $true)][string]$ProjectId,
    [string[]]$RelativeFile = @(),
    [hashtable]$ExpectedSha256 = @{}
)

# Only exact, already authorized files. No discovery, download or provider API.
$ErrorActionPreference = 'Stop'
if ($ProjectId -notmatch '\A[a-zA-Z0-9][a-zA-Z0-9_-]{0,63}\z') {
    throw 'Use a non-sensitive project ID containing 1-64 letters, digits, underscores or hyphens.'
}
if (-not [IO.Path]::IsPathRooted($ProjectPath) -or
    $ProjectPath -match '^[\\/]{2}' -or
    $ProjectPath -match '(^[a-zA-Z]:[^\\/]|[<>|?*])') {
    throw 'Select an absolute local project directory; network and device paths are unsupported.'
}
try { $root = [IO.Path]::GetFullPath($ProjectPath) }
catch { throw 'Invalid local project directory.' }
if ([IO.Path]::DirectorySeparatorChar -eq '\' -and
    $ProjectPath -notmatch '\A[a-zA-Z]:[\\/][^:]*\z') {
    throw 'Select a fully qualified local drive path without alternate streams.'
}

$selected = @()
foreach ($relative in $RelativeFile) {
    $normalized = $relative.Replace('\', '/')
    $segments = @($normalized.Split('/'))
    if ($normalized -match '[:<>|?*]' -or
        @($segments | Where-Object {
            $_ -in @('', '.', '..') -or $_ -match '[. ]\z'
        }).Count -gt 0 -or
        $normalized -notmatch '\A(input/local/|materials/|output/).+\z') {
        throw 'Select exact files below input/local, materials or deliberate output; traversal and other zones are refused.'
    }
    $selected += $normalized
}
foreach ($key in $ExpectedSha256.Keys) {
    if ($key -notin $selected -or
        [string]$ExpectedSha256[$key] -notmatch '\A[0-9a-fA-F]{64}\z') {
        throw 'Each expected SHA-256 must match an exact selected file and contain 64 hexadecimal digits.'
    }
}

function Get-LocalPathState {
    param([string]$Path)
    try {
        # Check parents first, without following a link to inspect its child.
        $parent = [IO.Directory]::GetParent($Path)
        if ($null -ne $parent) {
            $parentState = Get-LocalPathState -Path $parent.FullName
            if ($parentState -ne 'directory') { return $parentState }
        }
        $attributes = [IO.File]::GetAttributes($Path)
        # Offline, recall-on-open, recall-on-data-access: never hydrate here.
        if (([int]$attributes -band 0x441000) -ne 0) { return 'placeholder' }
        if (($attributes -band [IO.FileAttributes]::ReparsePoint) -ne 0) {
            return 'unsupported_reparse_point'
        }
        if (($attributes -band [IO.FileAttributes]::Directory) -ne 0) {
            return 'directory'
        }
        return 'local_file'
    } catch [IO.FileNotFoundException] { return 'missing' }
    catch [IO.DirectoryNotFoundException] { return 'missing' }
    catch { return 'unavailable' }
}

$projectState = Get-LocalPathState -Path $root
if ($projectState -eq 'directory') {
    $marker = Join-Path $root 'PROJECT_ID.txt'
    $markerState = Get-LocalPathState -Path $marker
    if ($markerState -eq 'local_file') {
        try {
            if (([IO.FileInfo]$marker).Length -gt 256) {
                $projectState = 'invalid_marker'
            } else {
                $lines = [IO.File]::ReadAllLines($marker)
                if ($lines.Count -gt 0 -and $lines[0].Trim() -ceq $ProjectId) {
                    $projectState = 'verified'
                } else { $projectState = 'project_mismatch' }
            }
        } catch { $projectState = 'unavailable_marker' }
    } else { $projectState = 'marker_' + $markerState }
}

$results = @()
for ($index = 0; $index -lt $selected.Count; $index++) {
    $state = 'not_checked'
    $integrity = 'not_checked'
    if ($projectState -eq 'verified') {
        $filePath = Join-Path $root $selected[$index]
        $state = Get-LocalPathState -Path $filePath
        if ($state -eq 'local_file' -and $ExpectedSha256.ContainsKey($selected[$index])) {
            try {
                $digest = (Get-FileHash -LiteralPath $filePath -Algorithm SHA256).Hash
                if ($digest -ieq $ExpectedSha256[$selected[$index]]) {
                    $integrity = 'match'
                } else { $integrity = 'mismatch' }
            } catch { $integrity = 'unavailable' }
        }
    }
    # Index identifies the caller's selection without printing paths or hashes.
    $results += [pscustomobject]@{
        Index = $index; Availability = $state; Integrity = $integrity
    }
}
[pscustomobject]@{
    Project = $projectState
    Files = $results
    SyncStatus = 'not_checked'
}
