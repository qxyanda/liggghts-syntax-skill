# ======================================================
# LIGGGHTS Syntax Skill Installer
# For Claude Code on Windows (PowerShell)
# ======================================================
param()

$ErrorActionPreference = "Stop"
$Version = "1.0.0"
$SkillDir = "$env:USERPROFILE\.claude\skills"
$SkillName = "liggghts-syntax"
$RepoUrl = "https://github.com/qxyanda/liggghts-syntax-skill.git"
$RawUrl = "https://raw.githubusercontent.com/qxyanda/liggghts-syntax-skill/main"

Write-Host "=== LIGGGHTS Syntax Skill Installer v$Version ===" -ForegroundColor Green
Write-Host ""

# Create directories
$TargetDir = "$SkillDir\skills\$SkillName"
New-Item -ItemType Directory -Force -Path $TargetDir | Out-Null
New-Item -ItemType Directory -Force -Path "$SkillDir\.claude-plugin" | Out-Null

# Download SKILL.md
Write-Host "Downloading SKILL.md..." -ForegroundColor Yellow
try {
    Invoke-WebRequest -Uri "$RawUrl/skills/liggghts-syntax/SKILL.md" `
        -OutFile "$TargetDir\SKILL.md" -ErrorAction Stop
    Write-Host "  OK: SKILL.md" -ForegroundColor Green
} catch {
    Write-Host "  FAILED to download SKILL.md: $_" -ForegroundColor Red
    exit 1
}

# Download plugin.json
try {
    Invoke-WebRequest -Uri "$RawUrl/.claude-plugin/plugin.json" `
        -OutFile "$SkillDir\.claude-plugin\plugin.json" -ErrorAction SilentlyContinue
} catch { }

# Download marketplace.json
try {
    Invoke-WebRequest -Uri "$RawUrl/.claude-plugin/marketplace.json" `
        -OutFile "$SkillDir\.claude-plugin\marketplace.json" -ErrorAction SilentlyContinue
} catch { }

Write-Host ""
Write-Host "Installation complete!" -ForegroundColor Green
Write-Host "Skill installed to: $TargetDir"
Write-Host ""
Write-Host "Trigger phrases: 'LIGGGHTS syntax', 'LIGGGHTS script', 'DEM script syntax'"
Write-Host "Or use: /liggghts-syntax"
Write-Host ""
Write-Host "Restart your Claude Code session or run /reload-skill to activate." -ForegroundColor Yellow
