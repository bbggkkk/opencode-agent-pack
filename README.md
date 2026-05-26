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

The Novelist router runs a structured feedback loop for every writing request, using a deterministic setting-first hierarchy for automatic conflict resolution, strict verification (no safety bypasses), and a collaborative discussion protocol to handle unresolvable contradictions or user overrides:

```
 ① Loremaster → collect setting & narrative state
        │
 ② Writer → write draft based on setting & narrative state
        │
 ③ Otaku → verify draft against setting, profile, & narrative state
       ╱ ╲
    PASS  FAIL
      │      ├── [Resolved by Hierarchy] ──> ④ Editor → fix based on Otaku report & change log ──> ⑤ re-verify
      │      └── [Unresolvable or User Intervention] ──> ⑥ Halt Loop & Initiate Collaborative Discussion
      ▼
  ⑦ Return final result
```

### Loop Safety & Collaborative Discussion
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

### After Installation

Restart opencode for changes to take effect:

```bash
opencode exit  # or Ctrl+D, then restart
```

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
