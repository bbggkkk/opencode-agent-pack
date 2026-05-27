#!/bin/sh
# Korean Creative Agents for opencode - Interactive Installation Script
# https://github.com/bbggkkk/opencode-novelist

set -e

REPO_URL="https://raw.githubusercontent.com/bbggkkk/opencode-novelist/master"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "=================================================="
echo " KOREAN CREATIVE AGENTS FOR OPENCODE"
echo "=================================================="
echo ""

# Detect if running from the repo or via curl
RUNNING_FROM_REPO=false
case "$SCRIPT_DIR" in
    *"opencode-novelist"*)
        RUNNING_FROM_REPO=true
        ;;
esac
if [ "$RUNNING_FROM_REPO" = "false" ] && [ -d "$SCRIPT_DIR/agents" ]; then
    RUNNING_FROM_REPO=true
fi
if [ "$RUNNING_FROM_REPO" = "true" ]; then
    echo "Running from the repository."
fi

# Detect available installation targets
GLOBAL_TARGET="$HOME/.config/opencode/agents"
GLOBAL_TEMPLATE_TARGET="$HOME/.config/opencode/novelist/templates"
GLOBAL_SKILL_TARGET="$HOME/.config/opencode/novelist/skills"
PROJECT_TARGET="$SCRIPT_DIR/.opencode/agents"
PROJECT_TEMPLATE_TARGET="$SCRIPT_DIR/.opencode/novelist/templates"
PROJECT_SKILL_TARGET="$SCRIPT_DIR/.opencode/novelist/skills"

echo "Select installation target:"
echo "1) Current project  (.opencode/agents)"
echo "2) Global install   ($GLOBAL_TARGET)"
echo ""

# If no argument provided, prompt interactively
if [ -z "$1" ]; then
    if [ ! -t 0 ]; then
        echo "This script requires interactive input or an argument."
        echo ""
        echo "Usage:"
        echo ""
        echo "  # Interactive (download then run)"
        echo "  curl -sSL https://raw.githubusercontent.com/bbggkkk/opencode-novelist/master/install.sh -o install.sh"
        echo "  chmod +x install.sh"
        echo "  ./install.sh"
        echo ""
        echo "  # One-liner (pass argument)"
        echo "  curl -sSL https://raw.githubusercontent.com/bbggkkk/opencode-novelist/master/install.sh | sh -s -- 1"
        echo "  curl -sSL https://raw.githubusercontent.com/bbggkkk/opencode-novelist/master/install.sh | sh -s -- 2"
        echo ""
        echo "  # Clone then run (interactive)"
        echo "  git clone https://github.com/bbggkkk/opencode-novelist.git"
        echo "  cd opencode-novelist"
        echo "  ./install.sh"
        echo ""
        exit 1
    fi
    printf "Choose (1/2): "
    read choice
else
    choice="$1"
fi

case "$choice" in
    1)
        TARGET="$PROJECT_TARGET"
        TEMPLATE_TARGET="$PROJECT_TEMPLATE_TARGET"
        SKILL_TARGET="$PROJECT_SKILL_TARGET"
        echo ""
        echo "Project-local install: $TARGET"
        echo "Project-local templates: $TEMPLATE_TARGET"
        echo "Project-local skills: $SKILL_TARGET"
        ;;
    2)
        TARGET="$GLOBAL_TARGET"
        TEMPLATE_TARGET="$GLOBAL_TEMPLATE_TARGET"
        SKILL_TARGET="$GLOBAL_SKILL_TARGET"
        echo ""
        echo "Global install: $TARGET"
        echo "Global templates: $TEMPLATE_TARGET"
        echo "Global skills: $SKILL_TARGET"
        ;;
    *)
        echo "Invalid choice. Enter 1 (project) or 2 (global)."
        exit 1
        ;;
esac

# Create directories
mkdir -p "$TARGET"
mkdir -p "$TEMPLATE_TARGET"
mkdir -p "$SKILL_TARGET"

# Copy/install agents and production templates
echo ""
echo "Installing agents and production templates..."

# Older releases installed templates and skills under the agent directory, which
# can make Markdown support files appear as callable agents in recursive agent discovery.
rm -rf "$TARGET/templates"
rm -rf "$TARGET/setting-collapse-detector"

if [ "$RUNNING_FROM_REPO" = "true" ] && [ -d "$SCRIPT_DIR/agents" ]; then
    # Copy agent files only. Support files live outside agent discovery.
    cp "$SCRIPT_DIR/agents"/*.md "$TARGET/"
    if [ -d "$SCRIPT_DIR/skills" ]; then
        cp -r "$SCRIPT_DIR/skills"/* "$SKILL_TARGET/"
    fi
    if [ -d "$SCRIPT_DIR/templates" ]; then
        cp -r "$SCRIPT_DIR/templates"/* "$TEMPLATE_TARGET/"
    fi
else
    # Download from GitHub
    for agent in novelist novelist-writer novelist-editor novelist-researcher novelist-loremaster novelist-otaku novelist-publisher; do
        curl -sSL "$REPO_URL/agents/${agent}.md" -o "$TARGET/${agent}.md"
    done
    # Download supporting skill outside agent discovery
    mkdir -p "$SKILL_TARGET/setting-collapse-detector"
    curl -sSL "$REPO_URL/skills/setting-collapse-detector/SKILL.md" -o "$SKILL_TARGET/setting-collapse-detector/SKILL.md"
    # Download production continuity templates
    for template in style-guide character-sheet item-sheet location-sheet world-rule-sheet series-bible narrative-state verification-manifest verification-evidence retcon-proposal; do
        curl -sSL "$REPO_URL/templates/${template}.md" -o "$TEMPLATE_TARGET/${template}.md"
    done
fi

echo "Installation complete!"
echo ""
echo "=================================================="
echo "Restart opencode:"
echo "   exit  (or Ctrl+D) to close the active session."
echo " Then restart opencode to use the new agents."
echo ""
echo " Available agents:"
echo ""
echo "  [Novelist System]"
echo "   /novelist               - Router (feedback loop orchestrator)"
echo "   /novelist-writer        - Fiction writer"
echo "   /novelist-editor        - Fiction editor"
echo "   /novelist-researcher    - Research / LaTeX papers"
echo "   /novelist-loremaster    - Setting archivist"
echo "   /novelist-otaku         - Setting consistency verifier"
echo "   /novelist-publisher     - EPUB build pipeline"
echo ""
echo " Skills installed outside agent discovery:"
echo "   $SKILL_TARGET/setting-collapse-detector/SKILL.md"
echo ""
echo " Templates installed outside agent discovery:"
echo "   $TEMPLATE_TARGET/style-guide.md"
echo "   $TEMPLATE_TARGET/character-sheet.md"
echo "   $TEMPLATE_TARGET/item-sheet.md"
echo "   $TEMPLATE_TARGET/location-sheet.md"
echo "   $TEMPLATE_TARGET/world-rule-sheet.md"
echo "   $TEMPLATE_TARGET/series-bible.md"
echo "   $TEMPLATE_TARGET/narrative-state.md"
echo "   $TEMPLATE_TARGET/verification-manifest.md"
echo "   $TEMPLATE_TARGET/verification-evidence.md"
echo "   $TEMPLATE_TARGET/retcon-proposal.md"
echo "=================================================="
