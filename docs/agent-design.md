# Agent Design

## Architecture

This pack uses a **hierarchical agent architecture** with two router agents at the top level, each managing specialized sub-agents.

```
Novelist (Router) — feedback loop orchestrator
├── novelist-writer — fiction writing (scenes, dialogue, plot, narration)
├── novelist-editor — fiction editing (plot, character, prose, pacing)
├── novelist-researcher — research & LaTeX paper writing
├── novelist-loremaster — setting archivist (context retrieval from files)
└── novelist-otaku — setting verifier (consistency checking)

Lyricist (Router)
├── lyricist-writer — lyric writing (K-pop, ballad, hip-hop, indie, OST)
└── lyricist-editor — lyric editing (hook, rhyme, flow, pronunciation)
```

## Feedback Loop

The Novelist router runs a **structured feedback loop** for all writing requests. Every draft passes through verification before delivery.

```
 ① Loremaster → searches project files, compiles setting document
        │
 ② Writer → writes draft based on setting document
        │
 ③ Otaku → cross-examines draft against setting
       ╱ ╲
    PASS  FAIL
      │      │
      │   ④ Editor → fixes every flagged inconsistency
      │      │
      │   ⑤ → ③ re-verify (loop until PASS)
      │
      ▼
  ⑥ final result delivered to user
```

The same agents can also be invoked directly:

| Command | Behavior |
|---------|----------|
| `/novelist write Chapter 3` | Full feedback loop (①→②→③→④↺→⑥) |
| `/novelist-loremaster collect setting on protagonist` | Setting document only |
| `/novelist-otaku verify this draft` | Verification only |
| `/novelist-otaku PASS` | Verification passed |
| `/novelist-otaku FAIL + report` | Needs revision |

## Router Design

Each router agent analyzes the user's natural language request and **delegates** to the appropriate sub-agent via opencode's `@agent-name` syntax:

| Router | Input Signal | Routes To |
|--------|-------------|-----------|
| `novelist` | create, write, draft, scene, chapter | Full feedback loop → loremaster → writer → otaku → editor → otaku |
| `novelist` | fix, review, feedback, revise, edit | `@novelist-editor` → `@novelist-otaku` |
| `novelist` | paper, latex, experiment, research | `@novelist-researcher` |
| `novelist` | setting, context, lore, find | `@novelist-loremaster` |
| `novelist` | verify, check, validate | `@novelist-otaku` |
| `lyricist` | create, write, draft, verse, chorus, lyric | `@lyricist-writer` |
| `lyricist` | fix, review, feedback, revise, polish | `@lyricist-editor` |

Routers never attempt to perform the work themselves — they evaluate the request and hand off a complete brief to the sub-agent.

## Separation of Concerns

The design separates creation from feedback at every level:

- **Writer agents** (`novelist-writer`, `lyricist-writer`) produce drafts with high temperature (0.8)
- **Editor agents** (`novelist-editor`, `lyricist-editor`) diagnose problems with low temperature (0.4–0.45)
- **Research agent** (`novelist-researcher`) combines analysis and writing with low temperature (0.3)
- **Setting agents** (`novelist-loremaster`, `novelist-otaku`) provide factual grounding with low temperature (0.2)
- **Router agents** (`novelist`, `lyricist`) classify and delegate with low temperature (0.3)

The **loremaster → writer → otaku → editor → otaku** feedback loop ensures that every draft is:
1. Grounded in established setting (loremaster)
2. Creatively written (writer)
3. Rigorously verified (otaku)
4. Corrected if needed (editor)
5. Re-verified until clean (otaku)

This separation helps users run a draft-review-rewrite loop without mixing creative generation and critique in a single role.

## Korean-First Behavior

Korean is the default language for creative writing. All agents prioritize natural Korean prose, believable dialogue, emotional continuity, Korean lyric pronunciation, and genre-specific expectations.

English is available when requested, but English support should not weaken the Korean-first defaults. The `novelist-researcher` agent supports bilingual LaTeX paper writing in both Korean and English.

## Safety And Originality

The agents should avoid direct imitation of living authors, specific copyrighted songs, and protected lyrics. They can work from broad creative traits such as atmosphere, structure, emotion, tempo, or genre.

## Distribution Model

Users install agents via the interactive `install.sh` script:

```bash
git clone https://github.com/bbggkkk/opencode-agent-pack.git
cd opencode-agent-pack
./install.sh
```

The script accepts an optional argument for non-interactive use:

```bash
curl -sSL https://raw.githubusercontent.com/bbggkkk/opencode-agent-pack/master/install.sh | sh -s -- 1
curl -sSL https://raw.githubusercontent.com/bbggkkk/opencode-agent-pack/master/install.sh | sh -s -- 2
```

- `1` → project-local install (`.opencode/agents/`)
- `2` → global install (`~/.config/opencode/agents/`)

Manual copy is also supported:

```bash
cp agents/*.md ~/.config/opencode/agents/
```

After installation, restart opencode for changes to take effect.
