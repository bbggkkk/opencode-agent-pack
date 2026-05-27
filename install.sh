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
PROJECT_TARGET="$SCRIPT_DIR/.opencode/agents"

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
        echo ""
        echo "Project-local install: $TARGET"
        ;;
    2)
        TARGET="$GLOBAL_TARGET"
        echo ""
        echo "Global install: $TARGET"
        ;;
    *)
        echo "Invalid choice. Enter 1 (project) or 2 (global)."
        exit 1
        ;;
esac

# Create directory
mkdir -p "$TARGET"

# Copy/install agents and production templates
echo ""
echo "Installing agents and production templates..."

if [ "$RUNNING_FROM_REPO" = "true" ] && [ -d "$SCRIPT_DIR/agents" ]; then
    # Copy from local repo (handles both .md files and skill subdirectories)
    cp -r "$SCRIPT_DIR/agents"/* "$TARGET/"
    if [ -d "$SCRIPT_DIR/templates" ]; then
        mkdir -p "$TARGET/templates"
        cp -r "$SCRIPT_DIR/templates"/* "$TARGET/templates/"
    fi
else
    # Download from GitHub
    for agent in novelist novelist-writer novelist-editor novelist-researcher novelist-loremaster novelist-otaku novelist-publisher; do
        curl -sSL "$REPO_URL/agents/${agent}.md" -o "$TARGET/${agent}.md"
    done
    # Download skill
    mkdir -p "$TARGET/setting-collapse-detector"
    curl -sSL "$REPO_URL/agents/setting-collapse-detector/SKILL.md" -o "$TARGET/setting-collapse-detector/SKILL.md"
    # Download production continuity templates
    mkdir -p "$TARGET/templates"
    for template in style-guide character-sheet item-sheet location-sheet world-rule-sheet series-bible narrative-state verification-manifest verification-evidence retcon-proposal; do
        curl -sSL "$REPO_URL/templates/${template}.md" -o "$TARGET/templates/${template}.md"
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
echo " Templates installed:"
echo "   templates/style-guide.md"
echo "   templates/character-sheet.md"
echo "   templates/item-sheet.md"
echo "   templates/location-sheet.md"
echo "   templates/world-rule-sheet.md"
echo "   templates/series-bible.md"
echo "   templates/narrative-state.md"
echo "   templates/verification-manifest.md"
echo "   templates/verification-evidence.md"
echo "   templates/retcon-proposal.md"
echo "=================================================="
