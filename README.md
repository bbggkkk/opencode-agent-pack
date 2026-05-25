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

## Feedback Loop

The Novelist router runs a structured feedback loop for every writing request:

```
 ① Loremaster → collect setting documents from project files
 ② Writer → write draft based on setting documents
 ③ Otaku → verify draft against setting (PASS → ⑥, FAIL → ④)
 ④ Editor → fix all Otaku-flagged inconsistencies
 ⑤ → ③ re-verify (repeat until PASS)
 ⑥ Return final result
```

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
cp agents/*.md ~/.config/opencode/agents/

# Per-project install
mkdir -p .opencode/agents
cp agents/*.md .opencode/agents/
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

## Language Policy

Korean is the default language for creative writing. Agents write with Korean sentence rhythm, natural dialogue, genre conventions, emotional continuity, and cliche avoidance in mind.

English is supported when the user explicitly asks for English, provides an English draft, or requests bilingual variants. The `novelist-researcher` agent supports bilingual LaTeX paper writing.

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
