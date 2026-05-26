# Agent Design

## Architecture

This pack uses a **hierarchical agent architecture** with one router agent at the top level managing specialized sub-agents.

```
Novelist (Router) — feedback loop orchestrator
├── novelist-writer — fiction writing (scenes, dialogue, plot, narration)
├── novelist-editor — fiction editing (plot, character, prose, pacing)
├── novelist-researcher — research & LaTeX paper writing
├── novelist-loremaster — setting archivist (context retrieval from files)
├── novelist-otaku — setting verifier (consistency checking)
└── novelist-publisher — EPUB book compiler (packages drafts using zip)
```

## Feedback Loop

The Novelist router runs a **structured feedback loop** for all writing requests, using a sequential paragraph-by-paragraph / beat-by-beat buildup model to guarantee near-perfect narrative consistency and logical transitions:

```
 ① Loremaster → collect setting & narrative state (facts only)
        │
 ② Router → Decompose scene brief into sequential beats/paragraphs
        │
 ┌─────►③ Loop: For each scene-beat:
 │      │
 │   ④ Writer → writes next beat/paragraph based on accumulated prefix & settings
 │      │
 │   ⑤ Otaku → verify next beat draft (initial lore check) & produce report
 │      │
 │   ⑥ Editor → ALWAYS runs. Polishes prose style, 어투, formatting, & resolves Otaku-flagged errors
 │      │
 │   ⑦ Otaku (Final Verify) → verifies polished beat
 │     ╱ ╲
 │  PASS  FAIL ──> Loop back to ⑥ Editor to fix and re-verify
 │    │      (Or if unresolvable, Halt Loop & Initiate Collaborative Discussion)
 │    ▼
 └─── Consolidate beat into accumulated prefix (repeat until all beats done)
        │
        ▼
    ⑧ Done & Publish → compile final consolidated draft into EPUB using zip
```

### Loop Safety & Collaborative Discussion
- **Step-by-Step Buildup**: Rather than drafting a whole chapter, the router decomposes the scene brief. Each segment/paragraph is generated, verified, and revised in isolation. Once verified, it is locked into the **Accumulated Prefix Text** which acts as canon context for all subsequent segments.
- **Setting-First Conflict Resolution Hierarchy**: Sub-agents automatically resolve contradictions using the priority order:
  - **Priority 1: Individual Entity Settings (개별 캐릭터/대상 설정 문서)** — Ultimate canon (e.g. character profiles).
  - **Priority 2: General Lore & World-Building Settings (일반 세계관/시스템 설정 문서)** — Overrides plot progression.
  - **Priority 3: Recent Narrative State (최근 서사 상태/이전 장 내용)** — Overrides transient user prompts.
  - **Priority 4: User Brief / Transient Prompt (사용자 지시어)** — Lowest priority. Cannot violate established settings.
- **Strict Verification**: Loop safety iteration limits and relaxed warnings are removed. Verification is always 100% strict.
- **Collaborative Discussion Protocol**: If settings directly contradict each other or if the user intervenes, the loop halts, and the agent initiates a discussion presenting Priority 1, 2, and 3 settings details to align them.

The same agents can also be invoked directly:

| Command | Behavior |
|---------|----------|
| `/novelist write Chapter 3` | Sequential feedback loop & EPUB compilation (①→②→③→④↺→⑧) |
| `/novelist publish Chapter 3` | EPUB compilation only via `@novelist-publisher` |
| `/novelist-loremaster collect setting on protagonist` | Setting document only |
| `/novelist-otaku verify this draft` | Verification only |
| `/novelist-otaku PASS` | Verification passed |
| `/novelist-otaku FAIL + report` | Needs revision |
| `/novelist-publisher compile book` | EPUB compilation only |

## Router Design

The router agent analyzes the user's natural language request and **delegates** to the appropriate sub-agent via opencode's `@agent-name` syntax:

| Router | Input Signal | Routes To |
|--------|-------------|-----------|
| `novelist` | create, write, draft, scene, chapter | Full feedback loop & publishing → loremaster → writer → otaku → editor → publisher |
| `novelist` | publish, epub, package, compile | `@novelist-publisher` |
| `novelist` | fix, review, feedback, revise, edit | `@novelist-editor` → `@novelist-otaku` |
| `novelist` | paper, latex, experiment, research | `@novelist-researcher` |
| `novelist` | setting, context, lore, find | `@novelist-loremaster` |
| `novelist` | verify, check, validate | `@novelist-otaku` |

Router never attempts to perform the work itself — it evaluates the request and hands off a complete brief to the sub-agent.

## 3-Level Franchise, Work & Volume Hierarchy Architecture

The system supports dynamically expanding shared-universe franchises, multi-volume series, or standalone novels through an isomorphic 3-level hierarchy layout:
- **Franchise Level (Global settings - `settings/` at root)**: World rules, magic systems, and base character profiles that are shared across all works in the same universe.
- **Work Level (Specific novel/series - `[Active Work Path]`)**: A subdirectory representing a specific work containing its own `series-bible.md` ledger and work-specific `settings/` local overrides/additions. If `series-bible.md` is at the project root, the project is treated as a standalone work (root acts as both Franchise and Work).
- **Volume Level (Individual books - `[Active Work Path][Active Volume Path]`)**: Individual folders for each volume (e.g. `volume-1/`, `volume-2/`) containing local outlines (`outline.md`) and chapter drafts (`drafts/`).
- **Cascading Context Routing**: The router detects the active Work directory and active Volume number/path from the request context or directory structure. It propagates this `Hierarchy Context` (`Active Work Path`, `Active Volume Number`, `Active Volume Path`) to sub-agents. The `@novelist-loremaster` cascades the settings resolution (Franchise settings + Work local overrides + Series Bible evolution log + Volume narrative state), and `@novelist-publisher` compiles EPUBs using the system `zip` utility relative to the volume path.

## Separation of Concerns

The design separates creation from feedback at every level:

- **Writer agent** (`novelist-writer`) produces drafts with high temperature (0.8)
- **Editor agent** (`novelist-editor`) diagnoses problems with low temperature (0.4)
- **Research agent** (`novelist-researcher`) combines analysis and writing with low temperature (0.3)
- **Setting agents** (`novelist-loremaster`, `novelist-otaku`) provide factual grounding with low temperature (0.2)
- **Router agent** (`novelist`) classifies and delegates with low temperature (0.3)

The **loremaster → writer → otaku → editor → otaku** feedback loop ensures that every draft is:
1. Grounded in established setting (loremaster - facts only)
2. Creatively written (writer)
3. Verified for factual setting consistency (otaku - initial check)
4. Polished for style, 어투, formatting, and factual errors (editor - always runs)
5. Re-verified for absolute lore consistency (otaku - final verify)

This separation helps users run a draft-review-rewrite loop without mixing creative generation and critique in a single role.

## Language, Culture & Creative Profiling Policy

Agents write in the language and style explicitly requested by the user. 

1. **Upfront Information Gathering**: If key parameters such as Style/Tone, Mood/Atmosphere, Language, or Cultural Background are missing, ambiguous, or unclear from the user's initial prompt, the router agent (`/novelist`) will ask the user *once* at the beginning to gather and align these parameters.
2. **Unified Profile Enforcement**: These parameters are compiled into a unified **Writing & Creative Profile**. The router propagates this profile to all sub-agents (Writer, Editor, Otaku, Researcher, Loremaster). Every stage of the workflow—including initial drafting, review, editing/revising, and setting verification—strictly adheres to this profile to maintain creative consistency.
3. **Language Defaults**: If unspecified, the language defaults to Korean.
4. **Cultural Context Inference**: The cultural context is inferred based on the target language and its corresponding country/countries. If ambiguous, the agents prompt the user to input it.
5. **Korean-First Creative Writing**: Korean is the default context. When writing in Korean, all agents prioritize natural Korean prose, believable dialogue, emotional continuity, and genre-specific expectations, representing a Korean cultural background.

## Safety And Originality

The agents should avoid direct imitation of living authors. They can work from broad creative traits such as atmosphere, structure, emotion, tempo, or genre.

## Distribution Model

Users install agents via the interactive `install.sh` script:

```bash
git clone https://github.com/bbggkkk/opencode-novelist.git
cd opencode-novelist
./install.sh
```

The script accepts an optional argument for non-interactive use:

```bash
curl -sSL https://raw.githubusercontent.com/bbggkkk/opencode-novelist/master/install.sh | sh -s -- 1
curl -sSL https://raw.githubusercontent.com/bbggkkk/opencode-novelist/master/install.sh | sh -s -- 2
```

- `1` → project-local install (`.opencode/agents/`)
- `2` → global install (`~/.config/opencode/agents/`)

Manual copy is also supported:

```bash
cp -r agents/* ~/.config/opencode/agents/
```

After installation, restart opencode for changes to take effect.

## Skill Mapping

Each agent is paired with specific opencode skills that enhance its capabilities.

| Skill | Used By | Purpose |
|-------|---------|---------|
| `brainstorming` | novelist-writer, novelist-editor | Creative exploration before drafting or revision |
| `writing-plans` | novelist-writer | Multi-step plan generation for episode outlines |
| `brainstorming-research-ideas` | novelist-researcher | Ideation for new research directions |
| `dispatching-parallel-agents` | novelist | Parallel execution of independent sub-agent calls |
| `executing-plans` | novelist | Structured execution of multi-step plans |
| `setting-collapse-detector` | novelist-loremaster, novelist-otaku | Systematic setting consistency verification |

### Skill Invocation

- **setting-collapse-detector** is invoked automatically by `@novelist-otaku` on every draft verification, and by `@novelist-loremaster` after collecting setting info to check for internal contradictions.
- **brainstorming** is invoked by writer/editor agents when the brief is open-ended or when multiple creative approaches need exploration.
- **dispatching-parallel-agents** is used by routers when multiple independent sub-agent tasks can run simultaneously.
- All agents with skill access declare `skill: allow` in their YAML permission block to enable skill invocation.
