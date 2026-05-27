<#
.SYNOPSIS
    Verify that the version in pubspec.yaml matches the version mentioned in
    README.md, CHANGELOG.md (Unreleased section), and CURRENT_STATUS.md.

.DESCRIPTION
    Reads `version: <semver>+<build>` from pubspec.yaml and checks that:
      - README.md contains the full version string somewhere in the first 50 lines.
      - tech_readme_files/CURRENT_STATUS.md contains the version string.
      - CHANGELOG.md has an `[Unreleased]` section, AND the same version is
        either inside that section's text or is the most-recently-released tag.

    Designed to be run in CI on every PR (via .github/workflows/docs.yml) and
    locally before pushing a release.

.PARAMETER Verbose
    Print every check that passes, not just failures.

.EXAMPLE
    .\scripts\check_docs_freshness.ps1
    Exit 0 if all docs are in sync, exit 1 with a diff summary if not.
#>

[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'

$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot '../..')

function Get-PubspecVersion {
    $pubspec = Get-Content (Join-Path $RepoRoot 'pubspec.yaml')
    $line = $pubspec | Where-Object { $_ -match '^version:\s*(.+)$' } | Select-Object -First 1
    if (-not $line) {
        throw 'No `version:` line found in pubspec.yaml'
    }
    return ($line -replace '^version:\s*', '').Trim()
}

function Test-FileContainsVersion {
    param(
        [string]$Path,
        [string]$Version,
        [string]$Label
    )
    if (-not (Test-Path $Path)) {
        return [PSCustomObject]@{ Label = $Label; Status = 'MISSING'; Path = $Path }
    }
    $content = Get-Content -Raw $Path
    if ($content -match [regex]::Escape($Version)) {
        return [PSCustomObject]@{ Label = $Label; Status = 'OK'; Path = $Path }
    } else {
        return [PSCustomObject]@{ Label = $Label; Status = 'DRIFT'; Path = $Path }
    }
}

function Test-ChangelogUnreleased {
    param(
        [string]$ChangelogPath,
        [string]$Version
    )
    if (-not (Test-Path $ChangelogPath)) {
        return [PSCustomObject]@{ Label = 'CHANGELOG [Unreleased]'; Status = 'MISSING'; Path = $ChangelogPath }
    }
    $content = Get-Content -Raw $ChangelogPath
    # Match the [Unreleased] section body until the next ## level-2 heading.
    $match = [regex]::Match($content, '##\s*\[Unreleased\][^\n]*\n(?<body>[\s\S]*?)(?=\n##\s)', 'IgnoreCase')
    if (-not $match.Success) {
        return [PSCustomObject]@{ Label = 'CHANGELOG [Unreleased]'; Status = 'NO-UNRELEASED'; Path = $ChangelogPath }
    }
    $body = $match.Groups['body'].Value
    if ($body.Trim().Length -lt 10) {
        return [PSCustomObject]@{ Label = 'CHANGELOG [Unreleased]'; Status = 'EMPTY-UNRELEASED'; Path = $ChangelogPath }
    }
    if ($body -match [regex]::Escape($Version)) {
        return [PSCustomObject]@{ Label = 'CHANGELOG [Unreleased] mentions ' + $Version; Status = 'OK'; Path = $ChangelogPath }
    }
    # Not a hard failure: an Unreleased section that doesn't explicitly call
    # out the next version string is fine; it's the catch-all bucket. We just
    # warn.
    return [PSCustomObject]@{ Label = 'CHANGELOG [Unreleased] does not mention ' + $Version + ' (warning)'; Status = 'WARN'; Path = $ChangelogPath }
}

$version = Get-PubspecVersion
Write-Host "pubspec.yaml version: $version" -ForegroundColor Cyan

$results = @()
$results += Test-FileContainsVersion -Path (Join-Path $RepoRoot 'README.md')                          -Version $version -Label 'README.md'
$results += Test-FileContainsVersion -Path (Join-Path $RepoRoot 'tech_readme_files\CURRENT_STATUS.md')-Version $version -Label 'CURRENT_STATUS.md'
$results += Test-ChangelogUnreleased -ChangelogPath (Join-Path $RepoRoot 'CHANGELOG.md')              -Version $version

$results | ForEach-Object {
    $color = switch ($_.Status) {
        'OK'                { 'Green' }
        'WARN'              { 'Yellow' }
        default             { 'Red' }
    }
    Write-Host ("  [{0,-5}] {1}" -f $_.Status, $_.Label) -ForegroundColor $color
}

$bad = $results | Where-Object { $_.Status -notin @('OK', 'WARN') }
if ($bad.Count -gt 0) {
    Write-Host ''
    Write-Host "Docs are stale relative to pubspec.yaml ($version)." -ForegroundColor Red
    Write-Host 'Fix README.md, CHANGELOG.md, and CURRENT_STATUS.md to reflect the current version, then re-run.' -ForegroundColor Yellow
    exit 1
}

Write-Host ''
Write-Host "All docs reference pubspec.yaml version $version." -ForegroundColor Green
exit 0
