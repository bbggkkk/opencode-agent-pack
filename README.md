# Korean Creative Agents for opencode

계층형 한국어 창작 에이전트 팩입니다. **소설가**와 **작사가** 두 라우터가 요청을 분석하여 하위 전담 에이전트로 연결합니다.

## Agents

### 소설가 시스템

| Agent | 역할 |
|-------|------|
| `/소설가` | **라우터** — 창작/편집/연구 요청 자동 분석 후 하위 에이전트로 위임 |
| `/소설가-작성가` | 장면, 대사, 플롯, 감정선, 회차형 원고 창작 |
| `/소설가-편집자` | 플롯, 개연성, 캐릭터, 문체, 장면 리듬 분석 및 피드백 |
| `/소설가-연구자` | 프로젝트 컨텍스트 분석 → LaTeX 논문 작성 |

### 작사가 시스템

| Agent | 역할 |
|-------|------|
| `/작사가` | **라우터** — 창작/편집 요청 자동 분석 후 하위 에이전트로 위임 |
| `/작사가-작성가` | K-pop, 발라드, 힙합, 인디, OST 가사 창작 |
| `/작사가-편집자` | 훅, 운율, 발음감, 구조, 메시지 선명도 분석 및 피드백 |

## Install & Setup

### Option 1: Clone & Interactive (Recommended)

```bash
git clone https://github.com/bbggkkk/opencode-agent-pack.git
cd opencode-agent-pack
./install.sh
```

스크립트가 설치 위치를 물어봅니다:
- **`1`** — 현재 프로젝트에 설치 (`.opencode/agents/`)
- **`2`** — 전역으로 설치 (`~/.config/opencode/agents/`)

### Option 2: One-liner (인자 전달)

```bash
curl -sSL https://raw.githubusercontent.com/bbggkkk/opencode-agent-pack/master/install.sh | sh -s -- 1
curl -sSL https://raw.githubusercontent.com/bbggkkk/opencode-agent-pack/master/install.sh | sh -s -- 2
```

- `sh -s -- 1` → 프로젝트 설치
- `sh -s -- 2` → 전역 설치

### Option 3: Manual Copy

```bash
# Global install
mkdir -p ~/.config/opencode/agents
cp agents/*.md ~/.config/opencode/agents/

# Per-project install
mkdir -p .opencode/agents
cp agents/*.md .opencode/agents/
```

### After Installation

Restart opencode after installing or changing agent files:

```bash
opencode exit  # or Ctrl+D, then restart
```

## Usage Examples

### 소설가 라우터 (자동 연결)

```text
/소설가 퇴마 판타지 1화 도입을 써줘
  → @소설가-작성가에게 자동 위임

/소설가 이 장면 전개가 느린데 고쳐줘
  → @소설가-편집자에게 자동 위임

/소설가 프로젝트 실험 결과를 논문으로 작성해줘
  → @소설가-연구자에게 자동 위임
```

### 작사가 라우터 (자동 연결)

```text
/작사가 이별 후회하는 발라드 후렴을 써줘
  → @작사가-작성가에게 자동 위임

/작사가 이 가사 훅이 약한데 다듬어줘
  → @작사가-편집자에게 자동 위임
```

### 직접 하위 에이전트 호출

```text
/소설가-작성가 어두운 도시 판타지 1화 도입을 써줘.
/소설가-편집자 이 장면의 플롯과 캐릭터 일관성을 검토해줘.
/소설가-연구자 이 프로젝트 분석해서 논문 초안 작성해줘.
/작사가-작성가 90년대 발라드 감성으로 이별 후렴을 써줘.
/작사가-편집자 이 가사의 훅과 운율을 개선해줘.
```

## Language Policy

Korean is the default language. Agents write and review with Korean sentence rhythm, natural dialogue, genre conventions, emotional continuity, and cliche avoidance in mind.

English is supported when the user explicitly asks for English, provides an English draft, or requests bilingual variants. The `소설가-연구자` agent supports bilingual LaTeX paper writing in both Korean and English.

## Copyright And Style Policy

These agents should not imitate a living author, a specific copyrighted song, or protected lyrics directly. Ask for broad traits instead: mood, genre, tempo, emotional arc, narrative structure, or imagery.

Good requests:

```text
어두운 도시 판타지 분위기의 1화 도입을 써줘.
90년대 발라드 감성으로 이별 후렴을 써줘.
K-pop 댄스곡처럼 강한 훅이 있는 가사를 써줘.
```

Avoid requests like:

```text
특정 작가 문체 그대로 써줘.
특정 노래 후렴과 비슷하게 써줘.
이 가사를 살짝 바꿔줘.
```

## Examples

See:

- `examples/novel-brief.md`
- `examples/lyric-brief.md`
- `examples/revision-request.md`

## License

MIT
