# ======================================================
# LIGGGHTS Syntax Skill Installer
# For Claude Code on Windows (PowerShell)
# ======================================================
param()

$ErrorActionPreference = "Stop"
$Version = "1.0.0"
$SkillHome = "$env:USERPROFILE\.claude\skills"
$SkillName = "liggghts-syntax"
$RepoUrl = "https://github.com/qxyanda/liggghts-syntax-skill.git"
$RawUrl  = "https://raw.githubusercontent.com/qxyanda/liggghts-syntax-skill/main"

Write-Host "=== LIGGGHTS Syntax Skill Installer v$Version ===" -ForegroundColor Green
Write-Host ""

# Target: ~/.claude/skills/liggghts-syntax/
$TargetDir = "$SkillHome\$SkillName"
New-Item -ItemType Directory -Force -Path $TargetDir | Out-Null

# Download SKILL.md directly
Write-Host "Downloading SKILL.md..." -ForegroundColor Yellow
try {
    Invoke-WebRequest -Uri "$RawUrl/skills/liggghts-syntax/SKILL.md" `
        -OutFile "$TargetDir\SKILL.md" -ErrorAction Stop
    Write-Host "  OK: SKILL.md -> $TargetDir\SKILL.md" -ForegroundColor Green
} catch {
    Write-Host "  FAILED: $_" -ForegroundColor Red
    exit 1
}

# Download example
Write-Host "Downloading example script..." -ForegroundColor Yellow
try {
    New-Item -ItemType Directory -Force -Path "$TargetDir\example" | Out-Null
    Invoke-WebRequest -Uri "$RawUrl/example/in.simple" `
        -OutFile "$TargetDir\example\in.simple" -ErrorAction SilentlyContinue
} catch { }

Write-Host ""
Write-Host "Installation complete!" -ForegroundColor Green
Write-Host "Skill installed to: $TargetDir"
Write-Host ""
Write-Host "Trigger phrases: 'LIGGGHTS syntax', 'LIGGGHTS script', 'DEM script syntax'"
Write-Host "Or use: /liggghts-syntax"
Write-Host ""
Write-Host "Restart Claude Code or run /reload-skill to activate." -ForegroundColor Yellow
