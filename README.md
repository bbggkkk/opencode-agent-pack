# Korean Creative Agents for opencode

A hierarchical Korean creative agent pack for opencode. The **Novelist** router analyzes requests and delegates to specialized sub-agents through two separate pipelines: a Draft Pipeline for source manuscript work, and a Build Pipeline for verified EPUB output.

## Agents

### Novelist System

| Agent | Role |
|-------|------|
| `/novelist` | **Router** — routes draft work and EPUB build work into separate pipelines |
| `/novelist-writer` | Fiction writing: scenes, dialogue, plot, character emotion, episode drafts |
| `/novelist-editor` | Fiction editing: plot logic, character consistency, prose rhythm, pacing |
| `/novelist-researcher` | Research & LaTeX paper writing: experiment analysis, academic writing |
| `/novelist-loremaster` | Setting archivist: searches files for setting info, compiles structured documents |
| `/novelist-otaku` | Setting verifier: cross-examines drafts against setting for consistency |
| `/novelist-publisher` | EPUB build agent: creates editable EPUB source from verified drafts and packages `.epub` files using zip commands |

### Skill (installed alongside agents)

| Skill | Used By | Purpose |
|-------|---------|---------|
| `setting-collapse-detector` | Loremaster, Otaku | Systematic framework for detecting character, timeline, geography, world rules, possession, and dialogue inconsistencies |

## Draft And Build Pipelines

Plain novel-writing requests go to the **Draft Pipeline**. If you describe the novel, scene, chapter, continuation, or revision you want, `/novelist` writes and verifies source drafts only. It does not create EPUB output.

Use an explicit build command such as `build`, `epub build`, `publish`, `EPUB로 만들어`, `출판`, or `패키징` to activate the **Build Pipeline**. The Build Pipeline reads already verified drafts, creates or updates editable EPUB source in `epub-src/`, then packages `volume-N.epub`.

EPUB edits are source-based: layout, CSS, metadata, TOC, title page, and XHTML packaging fixes happen in `epub-src/` and are rebuilt. Story prose or canon edits must go back through the Draft Pipeline first, then be rebuilt.

## Draft Feedback Loop

The Novelist router runs a structured, paragraph-by-paragraph / beat-by-beat buildup feedback loop. Instead of drafting the entire scene at once, it generates and strictly verifies each segment sequentially using a prefix-constrained architecture:

```
 ① Loremaster → collect setting & narrative state (facts only)
        │
 ② Router → Decompose scene brief into sequential beats/paragraphs
        │
 ┌─────►③ Loop: For each scene-beat:
 │      │
 │   ④ Writer → write next beat/paragraph based on accumulated prefix & settings
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
    ⑧ Done → verified source draft, ledger, manifest, and evidence updated
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

* **Linux / macOS (Bash)**:
  ```bash
  git clone https://github.com/bbggkkk/opencode-novelist.git
  cd opencode-novelist
  ./install.sh
  ```

* **Windows (PowerShell)**:
  ```powershell
  git clone https://github.com/bbggkkk/opencode-novelist.git
  cd opencode-novelist
  .\install.ps1
  ```

Prompts for install target:
- **`1`** — Project-local install (`.opencode/agents/`)
- **`2`** — Global install (`~/.config/opencode/agents/`)

### Option 2: One-liner (pass argument)

#### Linux / macOS (Bash)

* **Project-local install** (`.opencode/agents/`):
  ```bash
  curl -sSL https://raw.githubusercontent.com/bbggkkk/opencode-novelist/master/install.sh | sh -s -- 1
  ```

* **Global install** (`~/.config/opencode/agents/`):
  ```bash
  curl -sSL https://raw.githubusercontent.com/bbggkkk/opencode-novelist/master/install.sh | sh -s -- 2
  ```

#### Windows (PowerShell)

* **Project-local install** (`.opencode/agents/`):
  ```powershell
  & ([scriptblock]::Create((irm https://raw.githubusercontent.com/bbggkkk/opencode-novelist/master/install.ps1))) 1
  ```

* **Global install** (`~/.config/opencode/agents/`):
  ```powershell
  & ([scriptblock]::Create((irm https://raw.githubusercontent.com/bbggkkk/opencode-novelist/master/install.ps1))) 2
  ```

### Option 3: Manual Copy

```bash
# Global install
mkdir -p ~/.config/opencode/agents
cp -r agents/* ~/.config/opencode/agents/
cp -r templates ~/.config/opencode/agents/

# Per-project install
mkdir -p .opencode/agents
cp -r agents/* .opencode/agents/
cp -r templates .opencode/agents/
```

Restart opencode for changes to take effect:

```bash
exit  # or Ctrl+D, then restart opencode
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
│   │   ├── epub-src/        # editable EPUB source generated by build
│   │   └── volume-1.epub    # built EPUB artifact
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

### Series Bible & Style Guide (`series-bible.md` & `settings/style-guide.md`)
The `series-bible.md` file tracks chronology, summaries of previous volumes, character evolution logs (e.g. ages, injuries, relationship modifications), and unresolved plot threads for the active work. 

**Work-Level Style Guide**: The prose style (style, tone, vocabulary preferences, broad reference traits, and character voice rules) is formally declared in either the `## Style Guide` section of `series-bible.md` or a local config file at `settings/style-guide.md` at the active Work level. The `@novelist` router automatically inherits and propagates these style settings to the Writer and Editor, ensuring that all volumes and drafts written under this Work maintain a consistent, unified prose style without requiring manual style declarations in every prompt.

If no style is declared, the default is **elegant, controlled, and assured literary prose by a renowned, seasoned professional novelist**. This baseline favors precise imagery, natural rhythm, emotional restraint, and scene-based feeling over generic explanation.

`settings/style-guide.md` stores the durable Style Contract and Character Voice Matrix for the work. Its narrative mode lock records POV person, tense, viewpoint anchor, and head-hopping rule so scene pressure cannot silently shift the narrator. The Character Voice Matrix records each character's speech register, vocabulary limits, taboo expressions, habitual phrases, silence patterns, and emotional tells. Writer and Editor use it to preserve style; Otaku uses it to detect character drift.

Each volume's `narrative-state.md` is the continuity ledger for current timeline point, locked-prefix summary, character locations, injuries, inventory, Location / World Canon References, Inventory Canon References, emotional state, relationship deltas, and open hooks. It is updated after each verified beat is consolidated.

Each volume's `verification-manifest.md` records each draft exactly once with the template's exact column order, `Draft SHA256`, `Canon Snapshot SHA256`, final Otaku PASS status, Editor Style Drift Audit PASS, Editor Character Voice Audit PASS, ledger update summaries, approved unknowns, and a linked Verification Evidence report. Publisher refuses to create an EPUB unless the manifest schema is intact, every packaged draft exists on disk, matches its recorded `Draft SHA256`, the canon bundle matches its recorded `Canon Snapshot SHA256`, the draft is listed with `Final Otaku Verdict: PASS`, `Style Drift Audit: PASS`, and `Character Voice Audit: PASS`, approved unknowns are either `None` or still tracked in `narrative-state.md` Open Hooks, the linked evidence report repeats the same proof fields, the report marks PASS for continuity, retcon safety, style, prose baseline, and character voice checklist items, Retcon Approval is `None` or points to an approved `retcons/*.md` proposal with user approval evidence and impacted canon proof, its Evidence Anchors table covers every checklist item with safe source paths and evidence phrases that appear verbatim in the referenced files, its Ledger Update Anchors prove each durable ledger fact appears in both the manifest summary and `narrative-state.md`, and the report contains no `FAIL`, `PENDING`, or `UNVERIFIED` verdicts.

Starter scaffolds are included under `templates/` for `style-guide.md`, `character-sheet.md`, `item-sheet.md`, `location-sheet.md`, `world-rule-sheet.md`, `series-bible.md`, `narrative-state.md`, `verification-manifest.md`, `verification-evidence.md`, and `retcon-proposal.md`.

Before production writing, run `scripts/validate-production-artifacts.sh [work-path] [volume-path]` or let the router perform the same Artifact Preflight Gate. This blocks placeholder `TBD` fields, blank style contract entries, missing Required Style Anchors, missing Forbidden Style Drift, missing Style Verification Questions, missing POV person, missing tense, missing viewpoint anchor, missing head-hopping rule, artifact table schema drift, missing Series Bible chronology source files, missing Chronology evidence phrases, missing character voice rows, missing character sheets, voice matrix and character sheet mismatches, missing character knowledge boundaries, missing forbidden drift guards, missing active state anchors, active state anchors absent from `narrative-state.md`, active narrative-state characters or Series Bible evolution characters that are not covered by the voice matrix and character sheets, active locations or world-rule hooks without Location / World Canon References, missing location/world setting files, missing location active constraints, missing world rule statements, trackable possessions without Inventory Canon References, missing item setting files, item holder mismatches, missing item limitations, and weak narrative-state ledgers before Writer is allowed to draft.

## Usage Examples

### Novelist Router (auto-routing with feedback loop)

```text
/novelist Write the opening scene of a dark fantasy Chapter 1
  → ①Loremaster → ②Writer → ③Otaku (Lore Check) → ④Editor (Polishes style/fixes facts) → ⑤Otaku (Final Verify) → ⑥Done

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

Direct `novelist-writer` and `novelist-editor` calls are provisional only. They must label their output `UNVERIFIED DRAFT` or `UNVERIFIED REVISION`, and the result is not canon, publishable, or safe to apply until the router runs final `@novelist-otaku` verification and records the PASS in `verification-manifest.md`.

## Language, Culture & Creative Profiling Policy

Agents write in the language and style explicitly requested by the user. 

1. **Upfront Information Gathering**: If key parameters such as Style/Tone, Mood/Atmosphere, Language, or Cultural Background are missing, ambiguous, or unclear from the user's initial prompt, the router agent (`/novelist`) will ask the user *once* at the beginning to gather and align these parameters.
2. **Unified Profile Enforcement**: These parameters are compiled into a unified **Writing & Creative Profile**. The router propagates this profile to all sub-agents (Writer, Editor, Otaku, Researcher, Loremaster). Every stage of the workflow—including initial drafting, review, editing/revising, and setting verification—strictly adheres to this profile to maintain creative consistency.
3. **Language Defaults**: If unspecified, the language defaults to Korean.
4. **Cultural Context Inference**: The cultural context is inferred based on the target language and its corresponding country/countries. If ambiguous, the agents prompt the user to input it.
5. **Korean-First Creative Writing**: Korean is the default context. When writing in Korean, agents write with Korean sentence rhythm, natural dialogue, genre conventions, emotional continuity, and cliche avoidance in mind, representing a Korean cultural background.

## Style and Originality Policy

The system supports flexible style enforcement. Users can define the prose style in two ways:
1. **Direct Description**: Explicitly describe the stylistic attributes (e.g., "concise, hardboiled, short sentences, cold tone").
2. **Author/Person Reference**: Use a creator or person as shorthand for broad traits such as atmosphere, pacing, sentence density, or dialogue texture.

Writer and Editor convert named-author requests into broad traits and produce original prose. They do not directly imitate living authors.

Good requests:

```text
Write the opening of a dark urban fantasy Chapter 1 with quiet surreal loneliness, restrained imagery, and measured pacing.
Write the next paragraph using a concise, hardboiled prose style.
```

## Examples

See:

- `examples/novel-brief.md`
- `examples/revision-request.md`
- `examples/production-continuity-scenario.md`
- `examples/style-character-drift-scenario.md`
- `examples/sample-work/` — full sample work layout with settings, style guide, series bible, narrative state, and draft

## Revision And Retcon Safety

Revision requests use a protected revision loop: `@novelist-loremaster` loads canon and style context, `@novelist-editor` revises only the approved editable span, and `@novelist-otaku` must PASS the revised span against locked surrounding context before the file is changed.

Requests that change established setting, character traits, relationships, style contracts, or prior events are treated as setting-change requests. The router must classify the change, scan impacted files, and halt for user approval when the requested change contradicts existing Priority 1/2/3 canon. Canon is never silently retconned. Approved migrations are recorded in `retcons/*.md` from `templates/retcon-proposal.md`, and any affected Verification Evidence report must link that approved Retcon Approval file.

Publishing is gated by `verification-manifest.md`; drafts that are missing, duplicated in the manifest, stale in the manifest, draft-hash-mismatched, canon-hash-mismatched, pending, failed, unverified, style-drifted, character-voice-drifted, hard-indented, conflict-marked, raw-HTML-contaminated, contain Character Voice Matrix taboo expressions, or contain Style Guide Forbidden Literal Phrases cannot be packaged.

## Validation

Run the full validation suite before publishing changes:

```bash
make validate
```

or:

```bash
scripts/validate-all.sh
```

For the production invariant check only:

```bash
scripts/validate-production-invariants.sh
```

The full suite verifies agent frontmatter, prompt invariants, templates, installer behavior, the continuity scenario, and the sample work fixture.

For the concrete continuity fixture only:

```bash
scripts/validate-continuity-scenario.sh
```

For the style and character drift fixture only:

```bash
scripts/validate-style-character-drift-scenario.sh
```

For the full sample work fixture:

```bash
scripts/validate-sample-work.sh
```

For production artifact preflight:

```bash
scripts/validate-production-artifacts.sh examples/sample-work volume-1
```

For a volume verification manifest only:

```bash
scripts/validate-verification-manifest.sh examples/sample-work/volume-1
```

The full suite also runs manifest negative tests to prove that missing draft entries, `PENDING` verdicts, placeholder ledger summaries, placeholder or untracked approved unknowns, extra unpublished drafts, missing or mismatched Verification Evidence reports, missing Evidence Anchors, missing Ledger Update Anchors, unsafe anchor paths, and anchor phrases absent from their source files are rejected.

The same suite is wired into `.github/workflows/validate.yml` for push and pull request validation. CI also runs a Windows PowerShell installer smoke test to verify `install.ps1` installs agents, skills, and templates.

See `docs/production-readiness-audit.md` for the requirement-by-requirement release audit.

## License

MIT
