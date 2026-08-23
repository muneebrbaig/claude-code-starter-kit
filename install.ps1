#!/usr/bin/env pwsh
# Windows equivalent of install.sh. Run from PowerShell — no admin/Developer
# Mode needed (uses directory junctions instead of symlinks).
$ErrorActionPreference = "Stop"

$KitDir = $PSScriptRoot
$ClaudeDir = Join-Path $env:USERPROFILE ".claude"
$SkillsSrcDir = Join-Path $env:USERPROFILE "projects\skills"

Write-Host "== preflight =="
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Host "Missing required tool: git"
    Write-Host "Install it first (e.g. 'winget install --id Git.Git'), then re-run this script."
    exit 1
}
Write-Host "git found."

$optionalMissing = @()
if (-not (Get-Command gh -ErrorAction SilentlyContinue)) { $optionalMissing += "gh" }
if (-not (Get-Command glab -ErrorAction SilentlyContinue)) { $optionalMissing += "glab" }
if ($optionalMissing.Count -gt 0) {
    Write-Host "Note: $($optionalMissing -join ', ') not found. Not required for this install, but"
    Write-Host "the pr-summary/glab skills need it (and its own 'auth login') once you use them."
    Write-Host "  gh:   winget install --id GitHub.cli"
    Write-Host "  glab: winget install glab.glab"
}

New-Item -ItemType Directory -Force -Path (Join-Path $ClaudeDir "skills") | Out-Null
New-Item -ItemType Directory -Force -Path $SkillsSrcDir | Out-Null

function Copy-WithConfirm($src, $dst) {
    if (Test-Path $dst) {
        $ans = Read-Host "$dst already exists. Overwrite? [y/N]"
        if ($ans -notmatch '^[Yy]$') { Write-Host "Skipped $dst"; return }
    }
    Copy-Item -Path $src -Destination $dst -Force
    Write-Host "Wrote $dst"
}

Write-Host "== CLAUDE.md =="
Copy-WithConfirm (Join-Path $KitDir "CLAUDE.md") (Join-Path $ClaudeDir "CLAUDE.md")

Write-Host "== settings.json =="
if (Test-Path (Join-Path $ClaudeDir "settings.json")) {
    Write-Host "NOTE: this replaces the WHOLE file, not a merge. If your existing"
    Write-Host "$ClaudeDir\settings.json has its own hooks/permissions/model overrides,"
    Write-Host "back them up or merge by hand instead of overwriting (see SETUP.md step 2)."
}
Copy-WithConfirm (Join-Path $KitDir "settings.json") (Join-Path $ClaudeDir "settings.json")

Write-Host "== hooks =="
$HooksDst = Join-Path $ClaudeDir "hooks"
New-Item -ItemType Directory -Force -Path $HooksDst | Out-Null
Copy-Item (Join-Path $KitDir "hooks" "*.sh") $HooksDst -Force
Write-Host "Installed hooks to $HooksDst"

Write-Host "== vendored skills (graphify, pr-summary) =="
foreach ($skill in @("graphify", "pr-summary")) {
    $dst = Join-Path $ClaudeDir "skills\$skill"
    if (Test-Path $dst) {
        Write-Host "$dst already exists, skipping."
    } else {
        Copy-Item -Path (Join-Path $KitDir "skills\$skill") -Destination $dst -Recurse
        Write-Host "Installed $skill"
    }
}

Write-Host "== external skills (cloned from their own repos) =="
$skills = Get-Content (Join-Path $KitDir "external-skills.json") -Raw | ConvertFrom-Json
foreach ($s in $skills) {
    $srcDir = Join-Path $SkillsSrcDir $s.name
    $linkDst = Join-Path $ClaudeDir "skills\$($s.name)"
    if (Test-Path $srcDir) {
        Write-Host "$srcDir already exists, skipping clone."
    } else {
        git clone $s.repo $srcDir
    }
    if (-not (Test-Path $linkDst)) {
        # Junction, not symlink: works without admin rights or Developer Mode.
        New-Item -ItemType Junction -Path $linkDst -Target $srcDir -ErrorAction Stop | Out-Null
        if (-not (Test-Path $linkDst)) {
            throw "Failed to create junction at $linkDst (junctions are Windows/NTFS-only)."
        }
        Write-Host "Linked $($s.name)"
    }
    Write-Host "Note: $($s.note)"
}

Write-Host "Done. Restart Claude Code to pick up the new skills/settings."
Write-Host "Optional: rtk/gh/glab CLIs - see SETUP.md step 5 or README for install commands."
