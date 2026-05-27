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
$GLOBAL_TEMPLATE_TARGET = Join-Path $HOME ".config/opencode/novelist/templates"
$GLOBAL_SKILL_TARGET = Join-Path $HOME ".config/opencode/novelist/skills"
$PROJECT_TARGET = Join-Path $SCRIPT_DIR ".opencode/agents"
$PROJECT_TEMPLATE_TARGET = Join-Path $SCRIPT_DIR ".opencode/novelist/templates"
$PROJECT_SKILL_TARGET = Join-Path $SCRIPT_DIR ".opencode/novelist/skills"

# Determine running mode
$RunningFromRepo = $false
if (Test-Path (Join-Path $SCRIPT_DIR "agents")) {
    $RunningFromRepo = $true
}
if ($RunningFromRepo) {
    Write-Host "Running from the repository."
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
    $TemplateTarget = $PROJECT_TEMPLATE_TARGET
    $SkillTarget = $PROJECT_SKILL_TARGET
    Write-Host ""
    Write-Host "Project-local install: $Target" -ForegroundColor Yellow
    Write-Host "Project-local templates: $TemplateTarget" -ForegroundColor Yellow
    Write-Host "Project-local skills: $SkillTarget" -ForegroundColor Yellow
} elseif ($Choice -eq "2" -or $Choice -eq 2) {
    $Target = $GLOBAL_TARGET
    $TemplateTarget = $GLOBAL_TEMPLATE_TARGET
    $SkillTarget = $GLOBAL_SKILL_TARGET
    Write-Host ""
    Write-Host "Global install: $Target" -ForegroundColor Yellow
    Write-Host "Global templates: $TemplateTarget" -ForegroundColor Yellow
    Write-Host "Global skills: $SkillTarget" -ForegroundColor Yellow
} else {
    Write-Error "Invalid choice. Enter 1 (project) or 2 (global)."
    exit 1
}

# Create target directory
if (-not (Test-Path $Target)) {
    New-Item -ItemType Directory -Force -Path $Target | Out-Null
}
if (-not (Test-Path $TemplateTarget)) {
    New-Item -ItemType Directory -Force -Path $TemplateTarget | Out-Null
}
if (-not (Test-Path $SkillTarget)) {
    New-Item -ItemType Directory -Force -Path $SkillTarget | Out-Null
}

Write-Host ""
Write-Host "Installing agents and production templates..."

# Older releases installed templates and skills under the agent directory, which
# can make Markdown support files appear as callable agents in recursive agent discovery.
$LegacyTemplateTarget = Join-Path $Target "templates"
if (Test-Path $LegacyTemplateTarget) {
    Remove-Item -Path $LegacyTemplateTarget -Recurse -Force
}
$LegacySkillTarget = Join-Path $Target "setting-collapse-detector"
if (Test-Path $LegacySkillTarget) {
    Remove-Item -Path $LegacySkillTarget -Recurse -Force
}

$Agents = @(
    "novelist", "novelist-writer", "novelist-editor", "novelist-researcher",
    "novelist-loremaster", "novelist-otaku", "novelist-publisher"
)

if ($RunningFromRepo) {
    # Copy agent files only. Support files live outside agent discovery.
    Copy-Item -Path (Join-Path $SCRIPT_DIR "agents\*.md") -Destination $Target -Force
    $SkillSource = Join-Path $SCRIPT_DIR "skills"
    if (Test-Path $SkillSource) {
        Copy-Item -Path (Join-Path $SkillSource "*") -Destination $SkillTarget -Recurse -Force
    }
    $TemplateSource = Join-Path $SCRIPT_DIR "templates"
    if (Test-Path $TemplateSource) {
        Copy-Item -Path (Join-Path $TemplateSource "*") -Destination $TemplateTarget -Recurse -Force
    }
} else {
    # Download from GitHub
    foreach ($Agent in $Agents) {
        $Url = "$REPO_URL/agents/$($Agent).md"
        $OutPath = Join-Path $Target "$($Agent).md"
        Invoke-WebRequest -Uri $Url -OutFile $OutPath -UseBasicParsing
    }
    # Download supporting skill outside agent discovery
    $SkillDir = Join-Path $SkillTarget "setting-collapse-detector"
    if (-not (Test-Path $SkillDir)) {
        New-Item -ItemType Directory -Force -Path $SkillDir | Out-Null
    }
    $SkillUrl = "$REPO_URL/skills/setting-collapse-detector/SKILL.md"
    $SkillOutPath = Join-Path $SkillDir "SKILL.md"
    Invoke-WebRequest -Uri $SkillUrl -OutFile $SkillOutPath -UseBasicParsing

    # Download production continuity templates
    foreach ($Template in @("style-guide", "character-sheet", "item-sheet", "location-sheet", "world-rule-sheet", "series-bible", "narrative-state", "verification-manifest", "verification-evidence", "retcon-proposal")) {
        $TemplateUrl = "$REPO_URL/templates/$($Template).md"
        $TemplateOutPath = Join-Path $TemplateTarget "$($Template).md"
        Invoke-WebRequest -Uri $TemplateUrl -OutFile $TemplateOutPath -UseBasicParsing
    }
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
Write-Host "   /novelist-publisher     - EPUB build pipeline"
Write-Host ""
Write-Host " Skills installed outside agent discovery:"
Write-Host "   $SkillTarget/setting-collapse-detector/SKILL.md"
Write-Host ""
Write-Host " Templates installed outside agent discovery:"
Write-Host "   $TemplateTarget/style-guide.md"
Write-Host "   $TemplateTarget/character-sheet.md"
Write-Host "   $TemplateTarget/item-sheet.md"
Write-Host "   $TemplateTarget/location-sheet.md"
Write-Host "   $TemplateTarget/world-rule-sheet.md"
Write-Host "   $TemplateTarget/series-bible.md"
Write-Host "   $TemplateTarget/narrative-state.md"
Write-Host "   $TemplateTarget/verification-manifest.md"
Write-Host "   $TemplateTarget/verification-evidence.md"
Write-Host "   $TemplateTarget/retcon-proposal.md"
Write-Host "=================================================="
