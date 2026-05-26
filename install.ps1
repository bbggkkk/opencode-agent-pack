# Korean Creative Agents for opencode - PowerShell Installation Script
# https://github.com/bbggkkk/opencode-novelist

$ErrorActionPreference = "Stop"

$REPO_URL = "https://raw.githubusercontent.com/bbggkkk/opencode-novelist/master"
$SCRIPT_DIR = if ($PSScriptRoot) { $PSScriptRoot } else { $PWD.Path }

Write-Host "==================================================" -ForegroundColor Cyan
Write-Host " KOREAN CREATIVE AGENTS FOR OPENCODE" -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host ""

$GLOBAL_TARGET = Join-Path $HOME ".config/opencode/agents"
$PROJECT_TARGET = Join-Path $SCRIPT_DIR ".opencode/agents"

# Determine running mode
$RunningFromRepo = $false
if ($SCRIPT_DIR -like "*opencode-novelist*" -and (Test-Path (Join-Path $SCRIPT_DIR "agents"))) {
    $RunningFromRepo = $true
}

# Ask choice if argument not provided
$Choice = $null
if ($args.Count -ge 1) {
    $Choice = $args[0]
} else {
    Write-Host "Select installation target:"
    Write-Host "1) Current project  (.opencode/agents)"
    Write-Host "2) Global install   ($GLOBAL_TARGET)"
    Write-Host ""
    $Choice = Read-Host "Choose (1/2)"
}

$Target = $null
if ($Choice -eq "1" -or $Choice -eq 1) {
    $Target = $PROJECT_TARGET
    Write-Host ""
    Write-Host "Project-local install: $Target" -ForegroundColor Yellow
} elseif ($Choice -eq "2" -or $Choice -eq 2) {
    $Target = $GLOBAL_TARGET
    Write-Host ""
    Write-Host "Global install: $Target" -ForegroundColor Yellow
} else {
    Write-Error "Invalid choice. Enter 1 (project) or 2 (global)."
    exit 1
}

# Create target directory
if (-not (Test-Path $Target)) {
    New-Item -ItemType Directory -Force -Path $Target | Out-Null
}

Write-Host ""
Write-Host "Installing agents..."

$Agents = @(
    "novelist", "novelist-writer", "novelist-editor", "novelist-researcher",
    "novelist-loremaster", "novelist-otaku", "novelist-publisher"
)

if ($RunningFromRepo) {
    # Copy from local repo
    Copy-Item -Path (Join-Path $SCRIPT_DIR "agents\*") -Destination $Target -Recurse -Force
} else {
    # Download from GitHub
    foreach ($Agent in $Agents) {
        $Url = "$REPO_URL/agents/$($Agent).md"
        $OutPath = Join-Path $Target "$($Agent).md"
        Invoke-WebRequest -Uri $Url -OutFile $OutPath -UseBasicParsing
    }
    # Download skill
    $SkillDir = Join-Path $Target "setting-collapse-detector"
    if (-not (Test-Path $SkillDir)) {
        New-Item -ItemType Directory -Force -Path $SkillDir | Out-Null
    }
    $SkillUrl = "$REPO_URL/agents/setting-collapse-detector/SKILL.md"
    $SkillOutPath = Join-Path $SkillDir "SKILL.md"
    Invoke-WebRequest -Uri $SkillUrl -OutFile $SkillOutPath -UseBasicParsing
}

Write-Host "Installation complete!" -ForegroundColor Green
Write-Host ""
Write-Host "=================================================="
Write-Host " Restart opencode:"
Write-Host "   exit  (or Ctrl+D) to close the active session."
Write-Host " Then restart opencode to use the new agents."
Write-Host ""
Write-Host " Available agents:"
Write-Host ""
Write-Host "  [Novelist System]"
Write-Host "   /novelist               - Router (feedback loop orchestrator)"
Write-Host "   /novelist-writer        - Fiction writer"
Write-Host "   /novelist-editor        - Fiction editor"
Write-Host "   /novelist-researcher    - Research / LaTeX papers"
Write-Host "   /novelist-loremaster    - Setting archivist"
Write-Host "   /novelist-otaku         - Setting consistency verifier"
Write-Host "   /novelist-publisher     - EPUB book compiler"
Write-Host "=================================================="
