<#
.SYNOPSIS
    Verify that every official skill in .agents/skills/ matches the
    SHA-256 hash recorded in skills-lock.json.

.DESCRIPTION
    For each entry in skills-lock.json, computes the SHA-256 hash of the
    on-disk SKILL.md content (normalized to LF line endings) and compares to
    `computedHash`. Reports missing skills + locally-modified skills.

    Project-tuned skills (add-feature, add-api, add-language) are NOT in
    the lockfile and are skipped.

    Used by CI (.github/workflows/docs.yml) and runnable locally before a
    PR. If anything drifted, the suggested fix is `npx skills update`,
    which re-pulls upstream content and rewrites the lockfile.

.EXAMPLE
    .\scripts\check_skills_drift.ps1
    Exit 0 on clean state, exit 1 with a per-skill diff summary on drift.
#>

[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'

$RepoRoot   = Resolve-Path (Join-Path $PSScriptRoot '../..')
$LockPath   = Join-Path $RepoRoot 'skills-lock.json'
$SkillsDir  = Join-Path $RepoRoot '.agents\skills'

if (-not (Test-Path $LockPath)) {
    Write-Host "skills-lock.json not found at $LockPath" -ForegroundColor Red
    exit 2
}

$lock = Get-Content -Raw $LockPath | ConvertFrom-Json
if (-not $lock.skills) {
    Write-Host "skills-lock.json has no .skills object" -ForegroundColor Red
    exit 2
}

function Get-SkillFolderHash {
    # Reproduces the algorithm used by vercel-labs/skills `computeSkillFolderHash`:
    #   for each file in the skill folder (sorted by relative path, forward slashes),
    #   feed the path bytes and then the content bytes into a single rolling SHA-256.
    # See: https://github.com/vercel-labs/skills/blob/main/src/skill-lock.ts
    param([string]$SkillDir)
    $sha = [System.Security.Cryptography.SHA256]::Create()
    $base = (Resolve-Path $SkillDir).Path
    $files = Get-ChildItem $SkillDir -File -Recurse -Force |
        Where-Object { $_.FullName -notmatch '\\\.git\\' -and $_.FullName -notmatch '\\node_modules\\' } |
        ForEach-Object {
            $rel = $_.FullName.Substring($base.Length + 1) -replace '\\', '/'
            [PSCustomObject]@{ FullName = $_.FullName; Rel = $rel }
        } |
        Sort-Object Rel

    foreach ($f in $files) {
        $pathBytes = [System.Text.Encoding]::UTF8.GetBytes($f.Rel)
        $contentBytes = [System.IO.File]::ReadAllBytes($f.FullName)
        [void]$sha.TransformBlock($pathBytes, 0, $pathBytes.Length, $null, 0)
        [void]$sha.TransformBlock($contentBytes, 0, $contentBytes.Length, $null, 0)
    }
    [void]$sha.TransformFinalBlock([byte[]]@(), 0, 0)
    return (-join ($sha.Hash | ForEach-Object { $_.ToString('x2') }))
}

$drift     = @()
$missing   = @()
$ok        = 0
$total     = 0

$skillNames = $lock.skills.PSObject.Properties | ForEach-Object { $_.Name }
foreach ($name in $skillNames) {
    $total++
    $entry = $lock.skills.$name
    $expected = $entry.computedHash
    $skillDir = Join-Path $SkillsDir $name

    if (-not (Test-Path $skillDir)) {
        $missing += $name
        Write-Host ("  [{0,-5}] {1}" -f 'MISS', $name) -ForegroundColor Red
        continue
    }

    $actual = Get-SkillFolderHash -SkillDir $skillDir
    if ($actual -ne $expected) {
        $drift += [PSCustomObject]@{
            Name = $name
            Expected = $expected
            Actual = $actual
        }
        Write-Host ("  [{0,-5}] {1}" -f 'DRIFT', $name) -ForegroundColor Yellow
        Write-Host ("         expected: {0}" -f $expected) -ForegroundColor DarkGray
        Write-Host ("         actual:   {0}" -f $actual)   -ForegroundColor DarkGray
    } else {
        $ok++
    }
}

Write-Host ''
Write-Host ("Summary: {0} ok / {1} drift / {2} missing (of {3} locked skills)" -f $ok, $drift.Count, $missing.Count, $total) -ForegroundColor Cyan

if ($drift.Count -gt 0 -or $missing.Count -gt 0) {
    Write-Host ''
    Write-Host 'Official skills drifted from skills-lock.json.' -ForegroundColor Red
    Write-Host 'To resync from upstream (flutter/skills + dart-lang/skills), run:' -ForegroundColor Yellow
    Write-Host '    npx skills update' -ForegroundColor Yellow
    Write-Host 'If you intended to fork an upstream skill, do not edit it in-place — copy it into a project-tuned folder (sibling of add-feature/) and reference the copy in AGENTS.md.' -ForegroundColor Yellow
    exit 1
}

Write-Host 'All official skills match skills-lock.json.' -ForegroundColor Green
exit 0
