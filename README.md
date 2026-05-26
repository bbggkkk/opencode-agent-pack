# Korean Creative Agents for opencode

A hierarchical Korean creative agent pack for opencode. The **Novelist** and **Lyricist** routers analyze requests and delegate to specialized sub-agents through a structured feedback loop.

## Agents

### Novelist System

| Agent | Role |
|-------|------|
| `/novelist` | **Router** — analyzes requests, orchestrates the feedback loop |
| `/novelist-writer` | Fiction writing: scenes, dialogue, plot, character emotion, episode drafts |
| `/novelist-editor` | Fiction editing: plot logic, character consistency, prose rhythm, pacing |
| `/novelist-researcher` | Research & LaTeX paper writing: experiment analysis, academic writing |
| `/novelist-loremaster` | Setting archivist: searches files for setting info, compiles structured documents |
| `/novelist-otaku` | Setting verifier: cross-examines drafts against setting for consistency |
| `/novelist-publisher` | EPUB book compiler: compiles verified drafts into standard CSS-styled EPUB books using zip commands |

### Lyricist System

| Agent | Role |
|-------|------|
| `/lyricist` | **Router** — analyzes lyric writing/editing requests |
| `/lyricist-writer` | Lyric writing: K-pop, ballad, hip-hop, indie, OST, and adjacent styles |
| `/lyricist-editor` | Lyric editing: hook clarity, rhyme, flow, pronunciation, structure |

### Skill (installed alongside agents)

| Skill | Used By | Purpose |
|-------|---------|---------|
| `setting-collapse-detector` | Loremaster, Otaku | Systematic framework for detecting character, timeline, geography, world rules, possession, and dialogue inconsistencies |

## Feedback Loop

The Novelist router runs a structured, paragraph-by-paragraph / beat-by-beat buildup feedback loop. Instead of drafting the entire scene at once, it generates and strictly verifies each segment sequentially using a prefix-constrained architecture:

```
 ① Loremaster → collect setting & narrative state
        │
 ② Router → Decompose scene brief into sequential beats/paragraphs
        │
 ┌─────►③ Loop: For each scene-beat:
 │      │
 │   ④ Writer → write next beat/paragraph based on accumulated prefix & settings
 │      │
 │   ⑤ Otaku → verify next beat draft against accumulated prefix, outline, & settings
 │     ╱ ╲
 │  PASS  FAIL
 │    │      ├── [Resolved by Hierarchy] ──> ⑥ Editor → fix next beat draft ──> re-verify
 │    │      └── [Unresolvable or User Intervention] ──> ⑦ Halt Loop & Initiate Collaborative Discussion
 │    ▼
 └─── Consolidate beat into accumulated prefix (repeat until all beats done)
        │
        ▼
    ⑧ Done & Publish → compile final consolidated draft into EPUB using zip
```

### Loop Safety & Collaborative Discussion
- **Step-by-Step Buildup**: Each beat/paragraph is verified and revised individually. Once verified, it becomes part of the permanent "accumulated prefix text" that serves as the absolute canon context for subsequent beats.
- **Setting-First Conflict Resolution Hierarchy**: When resolving contradictions, agents follow a strict priority order: 
  - **Priority 1: Individual Entity Settings (개별 캐릭터/대상 설정 문서)** — Ultimate canon (e.g. character profiles).
  - **Priority 2: General Lore & World-Building Settings (일반 세계관/시스템 설정 문서)** — Overrides plot progression.
  - **Priority 3: Recent Narrative State (최근 서사 상태/이전 장 내용)** — Overrides transient user prompts.
  - **Priority 4: User Brief / Transient Prompt (사용자 지시어)** — Lowest priority. Cannot violate established settings.
- **Strict Verification**: Loop safety iteration limits and relaxed warnings are removed. Verification is always 100% strict.
- **Collaborative Discussion Protocol**: If settings directly contradict each other or if the user intervenes, the loop halts, and the agent initiates a discussion presenting Priority 1, 2, and 3 settings details to align them.

## Install & Setup

### Option 1: Clone & Interactive (Recommended)

```bash
git clone https://github.com/bbggkkk/opencode-agent-pack.git
cd opencode-agent-pack
./install.sh
```

Prompts for install target:
- **`1`** — Project-local install (`.opencode/agents/`)
- **`2`** — Global install (`~/.config/opencode/agents/`)

### Option 2: One-liner (pass argument)

```bash
curl -sSL https://raw.githubusercontent.com/bbggkkk/opencode-agent-pack/master/install.sh | sh -s -- 1
curl -sSL https://raw.githubusercontent.com/bbggkkk/opencode-agent-pack/master/install.sh | sh -s -- 2
```

- `sh -s -- 1` → project install
- `sh -s -- 2` → global install

### Option 3: Manual Copy

```bash
# Global install
mkdir -p ~/.config/opencode/agents
cp -r agents/* ~/.config/opencode/agents/

# Per-project install
mkdir -p .opencode/agents
cp -r agents/* .opencode/agents/
```

Restart opencode for changes to take effect:

```bash
opencode exit  # or Ctrl+D, then restart
```

## 3-Level Franchise, Work & Volume Hierarchy Layout

To support writing complex shared-universe franchises, multi-volume series, or standalone novels, projects use a unified, isomorphic 3-level hierarchy layout:

1. **프랜차이즈 레벨 (Franchise Level)**: The project root directory (workspace root). Contains global `settings/` (shared lore, characters, worldview).
2. **작품 레벨 (Work Level)**: A subdirectory representing a specific novel/series (e.g., `work-a/`). Contains `series-bible.md` and work-specific `settings/` (local characters, items, overrides).
3. **권 레벨 (Volume Level)**: A subdirectory within the active work (e.g., `work-a/volume-1/`). Contains `outline.md` and `drafts/`.

### 1. Shared Universe Franchise Layout (다작품 구조)
```text
[project-root]/               # === 1단계: 프랜차이즈 레벨 (Franchise) ===
├── settings/                # 프랜차이즈 공통 설정 (전역 세계관 로어)
│   ├── magic-system.md
│   └── characters/
│       └── legendary-hero.md
│
├── [work-a]/                # === 2단계: 작품 레벨 (Work A) ===
│   ├── series-bible.md      # 작품 A 시리즈 바이블
│   ├── settings/            # 작품 A 전용 설정 (로컬 캐릭터/아이템)
│   │
│   ├── volume-1/            # === 3단계: 권 레벨 (Volume 1 of Work A) ===
│   │   ├── outline.md       # 1권 아웃라인 및 비트
│   │   ├── drafts/          # 1권 문단/챕터 드래프트
│   │   └── volume-1.epub    # 1권 출판 EPUB
│   └── volume-2/            # 3단계: 권 레벨 (Volume 2 of Work A)
│
└── [work-b]/                # === 2단계: 작품 레벨 (Work B) ===
    ├── series-bible.md
    └── volume-1/            # === 3단계: 권 레벨 (Volume 1 of Work B) ===
```

### 2. Standalone Work Layout (단독 작품 구조 - Isomorphic Fallback)
If `series-bible.md` is located directly at the project root, the project is treated as a single standalone work. The root acts as both the Franchise and Work level, and `volume-N/` directories are placed directly at the root:
```text
[project-root]/               # === 1단계 & 2단계 통합: 프랜차이즈 & 작품 레벨 ===
├── settings/                # 이 작품의 설정
├── series-bible.md          # 이 작품의 시리즈 바이블
│
├── volume-1/                # === 3단계: 권 레벨 (Volume 1) ===
│   ├── outline.md
│   └── drafts/
└── volume-2/                # === 3단계: 권 레벨 (Volume 2) ===
```

### Series Bible (`series-bible.md`)
The `series-bible.md` file tracks chronology, summaries of previous volumes, character evolution logs (e.g. ages, injuries, relationship modifications), and unresolved plot threads for the active work. The `@novelist-loremaster` automatically retrieves these elements to guide sub-agents during drafting.

## Usage Examples

### Novelist Router (auto-routing with feedback loop)

```text
/novelist Write the opening scene of a dark fantasy Chapter 1
  → ①Loremaster → ②Writer → ③Otaku → (④Editor → ③re-verify if needed) → ⑥Done

/novelist This scene's pacing feels slow, please fix it
  → @novelist-editor → @novelist-otaku verify

/novelist Write a LaTeX paper from this project's experiment results
  → @novelist-researcher
```

### Standalone Sub-agent Calls

```text
/novelist-writer Write an urban fantasy Chapter 3 opening scene.
/novelist-editor Review this chapter for plot and character consistency.
/novelist-loremaster Collect all setting info about the main character.
/novelist-otaku Verify this draft against the established setting.
```

### Lyricist Router

```text
/lyricist Write a sad ballad chorus about breakup regret
  → @lyricist-writer

/lyricist The hook in this lyric feels weak, polish it
  → @lyricist-editor
```

## Language, Culture & Creative Profiling Policy

Agents write in the language and style explicitly requested by the user. 

1. **Upfront Information Gathering**: If key parameters such as Style/Tone, Mood/Atmosphere, Language, or Cultural Background are missing, ambiguous, or unclear from the user's initial prompt, the router agents (`/novelist`, `/lyricist`) will ask the user *once* at the beginning to gather and align these parameters.
2. **Unified Profile Enforcement**: These parameters are compiled into a unified **Writing & Creative Profile** (or **Lyric Profile**). The routers propagate this profile to all sub-agents (Writer, Editor, Otaku, Researcher, Loremaster). Every stage of the workflow—including initial drafting, review, editing/revising, and setting verification—strictly adheres to this profile to maintain creative consistency.
3. **Language Defaults**: If unspecified, the language defaults to Korean.
4. **Cultural Context Inference**: The cultural context is inferred based on the target language and its corresponding country/countries. If ambiguous, the agents prompt the user to input it.
5. **Korean-First Creative Writing**: Korean is the default context. When writing in Korean, agents write with Korean sentence rhythm, natural dialogue, genre conventions, emotional continuity, and cliche avoidance in mind, representing a Korean cultural background.

## Copyright And Style Policy

These agents should not imitate a living author, a specific copyrighted song, or protected lyrics directly. Ask for broad traits instead: mood, genre, tempo, emotional arc, narrative structure, or imagery.

Good requests:

```text
Write the opening of a dark urban fantasy Chapter 1.
Write a 90s ballad-style breakup chorus.
Write K-pop dance song lyrics with a strong hook.
```

Avoid requests like:

```text
Write this in the style of [specific author].
Make it sound like [specific song].
Slightly rewrite these existing lyrics.
```

## Examples

See:

- `examples/novel-brief.md`
- `examples/lyric-brief.md`
- `examples/revision-request.md`

## License

MIT
