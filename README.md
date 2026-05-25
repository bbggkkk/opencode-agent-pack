# Korean Creative Agents for opencode

Korean-first creative agents for opencode. The pack separates writer and editor roles for fiction and lyrics, while supporting English when the user explicitly asks for it. Also includes a research scientist agent for academic paper writing.

## Agents

| Agent | Role |
| --- | --- |
| `novelist` | Writes Korean-first fiction: scenes, dialogue, narration, character emotion, and episode drafts. |
| `novel-editor` | Reviews fiction for plot logic, character consistency, prose rhythm, pacing, and reader engagement. |
| `lyricist` | Writes Korean-first lyrics for K-pop, ballad, hip-hop, indie, OST, and related styles. |
| `lyric-editor` | Reviews lyrics for hook clarity, rhyme, flow, pronunciation, structure, and message clarity. |
| `scientist` | Research scientist — analyzes project context, discovers patterns, and writes LaTeX papers. |

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

스크립트는 **항상 사용자 입력을 기다립니다**. 파이프 실행 시에는 인자(`1` 또는 `2`)를 반드시 전달해야 합니다.
- `sh -s -- 1` → 프로젝트 설치
- `sh -s -- 2` → 전역 설치

### Option 3: Manual Copy

**Global install:**
```bash
mkdir -p ~/.config/opencode/agents
cp agents/*.md ~/.config/opencode/agents/
```

**Per-project install:**
```bash
mkdir -p .opencode/agents
cp agents/*.md .opencode/agents/
```

### After Installation

Restart opencode after installing or changing agent files:

```bash
opencode exit  # or Ctrl+D
# Then restart opencode
```

**Available agents:** `/novelist`, `/novel-editor`, `/lyricist`, `/lyric-editor`, `/scientist`

## Usage Examples

### Fiction Writing

```text
/novelist 어두운 도시 판타지 분위기의 1화 도입을 써줘.
```

### Fiction Editing

```text
/novel-editor 이 장면의 플롯과 캐릭터 일관성을 검토해줘.
```

### Lyric Writing

```text
/lyricist 90년대 발라드 감성으로 이별 후렴을 써줘.
```

### Lyric Editing

```text
/lyric-editor 이 가사의 훅과 운율을 개선해줘.
```

### Research Paper Writing

```text
/scientist 이 프로젝트의 실험 결과를 바탕으로 논문 초안을 작성해줘.
```

## Language Policy

Korean is the default language. Agents write and review with Korean sentence rhythm, natural dialogue, genre conventions, emotional continuity, and cliche avoidance in mind.

English is supported when the user explicitly asks for English, provides an English draft, or requests bilingual variants. The `scientist` agent supports bilingual LaTeX paper writing in both Korean and English.

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
