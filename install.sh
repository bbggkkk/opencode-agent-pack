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
echo "한국어 창작 에이전트 설치"
echo ""

# Detect if running from the repo or via curl
RUNNING_FROM_REPO=false
if [[ "$SCRIPT_DIR" == *"opencode-agent-pack"* ]] || [[ -d "$SCRIPT_DIR/agents" ]]; then
    RUNNING_FROM_REPO=true
    echo "이 저장소에서 실행 중입니다."
fi

# Detect available installation targets
GLOBAL_TARGET="$HOME/.config/opencode/agents"
PROJECT_TARGET="$SCRIPT_DIR/.opencode/agents"

echo "설치 위치 선택:"
echo "1) 현재 프로젝트에 설치  (.opencode/agents)"
echo "2) 전역으로 설치          ($GLOBAL_TARGET)"
echo ""

# If no argument provided, prompt interactively
if [[ -z "$1" ]]; then
    if [[ ! -t 0 ]]; then
        echo "⚠️  이 스크립트는 대화형 실행 또는 인자 전달이 필요합니다."
        echo ""
        echo "사용법:"
        echo ""
        echo "  # 직접 실행 (대화형)"
        echo "  curl -sSL https://raw.githubusercontent.com/bbggkkk/opencode-agent-pack/master/install.sh -o install.sh"
        echo "  chmod +x install.sh"
        echo "  ./install.sh"
        echo ""
        echo "  # 원라이너 (인자 전달)"
        echo "  curl -sSL https://raw.githubusercontent.com/bbggkkk/opencode-agent-pack/master/install.sh | sh -s -- 1"
        echo "  curl -sSL https://raw.githubusercontent.com/bbggkkk/opencode-agent-pack/master/install.sh | sh -s -- 2"
        echo ""
        echo "  # git clone 후 실행 (대화형)"
        echo "  git clone https://github.com/bbggkkk/opencode-agent-pack.git"
        echo "  cd opencode-agent-pack"
        echo "  ./install.sh"
        echo ""
        exit 1
    fi
    read -p "선택 (1/2): " choice
else
    choice="$1"
fi

case "$choice" in
    1)
        TARGET="$PROJECT_TARGET"
        echo ""
        echo "프로젝트 로컬 설치: $TARGET"
        ;;
    2)
        TARGET="$GLOBAL_TARGET"
        echo ""
        echo "전역 설치: $TARGET"
        ;;
    *)
        echo "❌ 잘못된 선택입니다."
        echo "1 (프로젝트) 또는 2 (전역)을 입력해주세요."
        exit 1
        ;;
esac

# Create directory
mkdir -p "$TARGET"

# Copy/install agents
echo ""
echo "에이전트 설치 중..."

if [[ "$RUNNING_FROM_REPO" == "true" && -d "$SCRIPT_DIR/agents" ]]; then
    # Copy from local repo
    cp "$SCRIPT_DIR/agents"/*.md "$TARGET/"
else
    # Download from GitHub
    for agent in 소설가 소설가-작성가 소설가-편집자 소설가-연구자 작사가 작사가-작성가 작사가-편집자; do
        curl -sSL "$REPO_URL/agents/${agent}.md" -o "$TARGET/${agent}.md"
    done
fi

echo "✓ 설치 완료!"
echo ""
echo "=================================================="
echo " opencode를 재시작하세요:"
echo "   opencode exit  (또는 Ctrl+D)"
echo " 그 다음 다시 실행하면 새 에이전트를 사용할 수 있습니다."
echo ""
echo " 사용 가능한 에이전트:"
echo ""
echo "  [소설가 시스템]"
echo "   /소설가         - 라우터 (창작/편집/연구 자동 연결)"
echo "   /소설가-작성가   - 소설 창작"
echo "   /소설가-편집자   - 소설 편집/피드백"
echo "   /소설가-연구자   - 연구/LaTeX 논문"
echo ""
echo "  [작사가 시스템]"
echo "   /작사가         - 라우터 (창작/편집 자동 연결)"
echo "   /작사가-작성가   - 가사 창작"
echo "   /작사가-편집자   - 가사 편집/피드백"
echo "=================================================="