#!/bin/bash
# Korean Creative Agents for opencode - Interactive Installation Script
# https://github.com/bbggkkk/opencode-agent-pack

set -e

REPO_URL="https://raw.githubusercontent.com/bbggkkk/opencode-agent-pack/master"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "=================================================="
echo " KOREAN CREATIVE AGENTS FOR OPENCODE"
echo "=================================================="
echo ""

# Detect if running from the repo or via curl
RUNNING_FROM_REPO=false
if [[ "$SCRIPT_DIR" == *"opencode-agent-pack"* ]] || [[ -d "$SCRIPT_DIR/agents" ]]; then
    RUNNING_FROM_REPO=true
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
if [[ -z "$1" ]]; then
    if [[ ! -t 0 ]]; then
        echo "This script requires interactive input or an argument."
        echo ""
        echo "Usage:"
        echo ""
        echo "  # Interactive (download then run)"
        echo "  curl -sSL https://raw.githubusercontent.com/bbggkkk/opencode-agent-pack/master/install.sh -o install.sh"
        echo "  chmod +x install.sh"
        echo "  ./install.sh"
        echo ""
        echo "  # One-liner (pass argument)"
        echo "  curl -sSL https://raw.githubusercontent.com/bbggkkk/opencode-agent-pack/master/install.sh | sh -s -- 1"
        echo "  curl -sSL https://raw.githubusercontent.com/bbggkkk/opencode-agent-pack/master/install.sh | sh -s -- 2"
        echo ""
        echo "  # Clone then run (interactive)"
        echo "  git clone https://github.com/bbggkkk/opencode-agent-pack.git"
        echo "  cd opencode-agent-pack"
        echo "  ./install.sh"
        echo ""
        exit 1
    fi
    read -p "Choose (1/2): " choice
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

# Copy/install agents
echo ""
echo "Installing agents..."

if [[ "$RUNNING_FROM_REPO" == "true" && -d "$SCRIPT_DIR/agents" ]]; then
    # Copy from local repo
    cp "$SCRIPT_DIR/agents"/*.md "$TARGET/"
else
    # Download from GitHub
    for agent in novelist novelist-writer novelist-editor novelist-researcher novelist-loremaster novelist-otaku lyricist lyricist-writer lyricist-editor; do
        curl -sSL "$REPO_URL/agents/${agent}.md" -o "$TARGET/${agent}.md"
    done
fi

echo "Installation complete!"
echo ""
echo "=================================================="
echo " Restart opencode:"
echo "   opencode exit  (or Ctrl+D)"
echo " Then restart to use the new agents."
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
echo ""
echo "  [Lyricist System]"
echo "   /lyricist               - Router (writing/editing dispatcher)"
echo "   /lyricist-writer        - Lyric writer"
echo "   /lyricist-editor        - Lyric editor"
echo "=================================================="
