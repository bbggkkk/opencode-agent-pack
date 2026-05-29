# Korean Creative Agents for opencode

A hierarchical Korean creative agent pack for opencode. The **Novelist** router analyzes requests and delegates to specialized sub-agents through two separate pipelines: a Draft Pipeline for source manuscript work, and a Build Pipeline for verified EPUB output.

## Agents

### Novelist System

| Agent | Role |
|-------|------|
| `/novelist` | **Router** — routes draft work and EPUB build work into separate pipelines |
| `/novelist-writer` | Fiction writing: scenes, dialogue, plot, character emotion, episode drafts |
| `/novelist-editor` | Fiction editing: plot logic, character consistency, prose rhythm, pacing |
| `/novelist-researcher` | Fiction-context research: checks real-world plausibility and gathers external facts through the current story context |
| `/novelist-loremaster` | Setting archivist: searches files for setting info, compiles structured documents |
| `/novelist-otaku` | Setting verifier: cross-examines drafts against setting for consistency |
| `/novelist-publisher` | EPUB build agent: creates editable EPUB source from verified drafts and packages `.epub` files using zip commands |

Model assignment guidance is documented in [Model Recommendations](docs/model-recommendations.md).

### Skill (installed alongside agents)

| Skill | Used By | Purpose |
|-------|---------|---------|
| `setting-collapse-detector` | Loremaster, Otaku | Systematic framework for detecting character, timeline, geography, world rules, possession, and dialogue inconsistencies |

## Draft And Build Pipelines

Plain novel-writing requests go to the **Draft Pipeline**. If you describe the novel, scene, chapter, continuation, or revision you want, `/novelist` writes and verifies source drafts only. It does not create EPUB output.

Use an explicit build command such as `build`, `epub build`, `publish`, `create EPUB`, or `package` to activate the **Build Pipeline**. The Build Pipeline reads already verified drafts, creates or updates editable EPUB source in `epub-src/`, then packages `volume-N.epub`.

EPUB edits are source-based: layout, CSS, metadata, TOC, title page, and XHTML packaging fixes happen in `epub-src/` and are rebuilt. Story prose or canon edits must go back through the Draft Pipeline first, then be rebuilt.

## Draft Feedback Loop

The Novelist router runs a structured, paragraph-by-paragraph / beat-by-beat buildup feedback loop. Instead of drafting the entire scene at once, it generates and strictly verifies each segment sequentially using a prefix-constrained architecture:

Writing and revision steps are intentionally sequential, not parallel. The router never runs multiple Writer/Editor/Otaku manuscript passes at the same time, because each beat or editable span must consume the latest verified prefix, locked context, ledger state, and verification result from the previous step.

The pipeline is non-negotiable. Requests such as "quick", "simple", "just write", "skip verification", or similar shortcut language do not authorize the router or sub-agents to omit required context loading, artifact preflight, Writer/Editor/Otaku passes, ledger updates, manifest updates, Verification Evidence, publication gates, or commits. Each production workflow records a Pipeline Step Ledger in `writing-session.md`, and final delivery requires a Pipeline Completion Audit with concrete evidence for every mandatory step.

The user's initial request defines the completion target. Unless the user intervenes, changes scope, pauses/stops the job, or a blocking protocol requires user input, `/novelist` continues draft and revision work until the requested scope is done: a full work, a full book, a chapter, a scene, a named continuation endpoint, or a specific revision span. It records the Requested Scope of Work and Completion Target in `writing-session.md` and does not stop at an intermediate beat or pass when the request is larger.

The Draft Pipeline follows a Seed-to-Fruit Narrative Growth model. The user's request is the **Seed**. The router then grows **Branches** by adopting or authoring a Macro Skeleton, Length Budget, and Execution Unit Queue. The existing feedback loop creates **Leaves** by drafting each unit to its target/minimum character budget, then develops **Flowers** through micro-level Editor refinement and rigorous Otaku macro-flow and length verification. The **Fruit** is the verified completion artifact: requested scope complete, promised length satisfied, final Otaku PASS, style/voice audits, narrative ledgers, manifest, evidence, and commits.

```
 ① Seed → capture requested scope and completion target
        │
 ② Loremaster → collect setting & narrative state (facts only)
        │
 ③ Branches → create Macro Skeleton, Length Budget, and Execution Unit Queue
        │
 ┌─────►④ Leaves/Flowers Loop: For each execution unit:
 │      │
 │   ⑤ Writer → write next beat/paragraph based on accumulated prefix, branch, & settings
 │      │
 │   ⑥ Otaku → verify next beat draft (initial lore + branch traversal check) & produce report
 │      │
 │   ⑦ Editor → ALWAYS runs. Polishes micro-level prose, speech style, formatting, & resolves Otaku-flagged errors
 │      │
 │   ⑧ Otaku (Final Verify) → verifies polished beat
 │     ╱ ╲
 │  PASS  FAIL ──> Loop back to ⑦ Editor to fix and re-verify
 │    │      (Or if unresolvable, Halt Loop & Initiate Collaborative Discussion)
 │    ▼
 └─── Consolidate unit, update Completed Units, and run Skeleton Drift Check
        │
        ▼
    ⑨ Fruit → verified source draft, ledger, manifest, and evidence updated
```

### Loop Safety & Collaborative Discussion
- **Step-by-Step Buildup**: Each beat/paragraph is verified and revised individually. Once verified, it becomes part of the permanent "accumulated prefix text" that serves as the absolute canon context for subsequent beats.
- **Seed-to-Fruit Narrative Growth**: Drafting does not start from isolated prose. The router first records the seed, grows a Macro Skeleton with a Length Budget, builds an Execution Unit Queue, drafts leaves through the existing feedback loop, refines flowers through review, and delivers fruit only after verification and artifact updates.
- **Agent-Authored Macro Skeleton**: If the user does not provide a large-scale outline, the router authors a provisional Macro Skeleton from the request, canon artifacts, genre expectations, and reasonable creative defaults. It asks the user only for mutually exclusive, high-impact choices that cannot be inferred.
- **Length Budget**: Branches and execution units carry target/minimum character counts from the start. The router counts actual characters from canonical draft files after consolidation, and no unit, branch, chapter, volume, or work is complete while it is `UNDER_LENGTH`.
- **Editor Micro Focus**: The Editor focuses on prose, speech style, formatting, local causality, pacing, and immediate scene readability. It uses the Macro Skeleton only as a guardrail and does not make whole-flow decisions.
- **Otaku Branch Traversal Audit**: Otaku is the primary sub-agent responsible for checking whether the draft is still traveling along the correct branch. Every final PASS requires a Branch Traversal Audit before the router consolidates the unit.
- **Skeleton Drift Check**: After every verified unit, the router checks Otaku's Branch Traversal Audit to confirm whether the prose still serves its parent branch. Safe improvements update the skeleton with rationale; changes to requested scope, endpoint, genre promise, or Priority 1/2/3 canon require user approval.
- **Non-Negotiable Pipeline Completion Gate**: Required workflow steps cannot be skipped, merged, simulated, or retroactively marked complete. If evidence for a required step is missing, the router continues from the earliest missing step or halts with a blocking report.
- **Scope-Complete Execution**: The initial user request is the completion target. The router continues until that target is fully drafted or revised, verified, recorded, evidenced, and committed unless the user intervenes or a blocking condition requires user input.
- **No Parallel Drafting Or Revision**: Writer, Editor, Otaku verification, manuscript edits, ledger updates, manifest updates, and commits run sequentially. Parallel execution is reserved for independent read-only context gathering only.
- **Interruptible Sessions**: Long writing, continuation, revision, setting migration, and build work records a file-based checkpoint in `writing-session.md`, with unverified temporary work isolated under `.session/`. If the process stops, `/novelist resume` or a continuation request validates hashes, manifest rows, evidence, ledger state, and locked revision context before continuing.
- **Setting-First Conflict Resolution Hierarchy**: When resolving contradictions, agents follow a strict priority order: 
  - **Priority 1: Individual Entity Settings** — Ultimate canon (e.g. character profiles).
  - **Priority 2: General Lore & World-Building Settings** — Overrides plot progression.
  - **Priority 3: Recent Narrative State** — Overrides transient user prompts.
  - **Priority 4: User Brief / Transient Prompt** — Lowest priority. Cannot violate established settings.
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

The interactive installer prompts for install target:
- **Project-local install** — installs into a selected project's `.opencode/agents/`
- **Global install** — installs into `~/.config/opencode/agents/`

You can also run the interactive installer without cloning the repository first:

* **Linux / macOS (Bash)**:
  ```bash
  sh -c "$(curl -sSL https://raw.githubusercontent.com/bbggkkk/opencode-novelist/master/install.sh)"
  ```

* **Windows (PowerShell)**:
  ```powershell
  & ([scriptblock]::Create((irm https://raw.githubusercontent.com/bbggkkk/opencode-novelist/master/install.ps1)))
  ```

Templates are installed outside agent discovery, while support skills are installed in OpenCode's skill discovery path. Project installs use `.opencode/novelist/templates/` and `.opencode/skills/`; global installs use `~/.config/opencode/novelist/templates/` and `~/.config/opencode/skills/`. Do not copy templates or skills into an `agents/` directory; opencode may expose Markdown support files as callable agents there.

### Option 2: Agent / Script One-liner

Use non-interactive flags when an agent or automation installs the pack. Project-local installs default to the command's current working directory unless a project path is provided.

#### Linux / macOS (Bash)

* **Project-local install into current directory**:
  ```bash
  curl -sSL https://raw.githubusercontent.com/bbggkkk/opencode-novelist/master/install.sh | sh -s -- --project
  ```

* **Project-local install into an explicit path**:
  ```bash
  curl -sSL https://raw.githubusercontent.com/bbggkkk/opencode-novelist/master/install.sh | sh -s -- --project /path/to/project
  ```

* **Global install** (`~/.config/opencode/agents/`):
  ```bash
  curl -sSL https://raw.githubusercontent.com/bbggkkk/opencode-novelist/master/install.sh | sh -s -- --global
  ```

#### Windows (PowerShell)

* **Project-local install into current directory**:
  ```powershell
  & ([scriptblock]::Create((irm https://raw.githubusercontent.com/bbggkkk/opencode-novelist/master/install.ps1))) --project
  ```

* **Project-local install into an explicit path**:
  ```powershell
  & ([scriptblock]::Create((irm https://raw.githubusercontent.com/bbggkkk/opencode-novelist/master/install.ps1))) --project C:\path\to\project
  ```

* **Global install** (`~/.config/opencode/agents/`):
  ```powershell
  & ([scriptblock]::Create((irm https://raw.githubusercontent.com/bbggkkk/opencode-novelist/master/install.ps1))) --global
  ```

Backward-compatible aliases remain available: `./install.sh 1 [project-dir]`, `./install.sh 2`, `.\install.ps1 1 [project-dir]`, and `.\install.ps1 2`.

### Option 3: Manual Copy

```bash
# Global install
mkdir -p ~/.config/opencode/agents
mkdir -p ~/.config/opencode/novelist/templates
mkdir -p ~/.config/opencode/skills
cp -r agents/* ~/.config/opencode/agents/
cp -r templates/* ~/.config/opencode/novelist/templates/
cp -r skills/* ~/.config/opencode/skills/

# Per-project install
mkdir -p .opencode/agents
mkdir -p .opencode/novelist/templates
mkdir -p .opencode/skills
cp -r agents/* .opencode/agents/
cp -r templates/* .opencode/novelist/templates/
cp -r skills/* .opencode/skills/
```

Restart opencode for changes to take effect:

```bash
exit  # or Ctrl+D, then restart opencode
```

## 3-Level Franchise, Work & Volume Hierarchy Layout

To support writing complex shared-universe franchises, multi-volume series, or a single current novel that may grow into multiple works later, projects use one unified 3-level hierarchy layout:

1. **Franchise Level**: The project root directory (workspace root). Contains global `settings/` (shared lore, characters, worldview).
2. **Work Level**: A subdirectory representing a specific novel/series (e.g., `work-a/`). Contains `series-bible.md` and work-specific `settings/` (local characters, items, overrides).
3. **Volume Level**: A subdirectory within the active work (e.g., `work-a/volume-1/`). Contains `outline.md` and `drafts/`.

### 1. Shared Universe Franchise Layout
```text
[project-root]/               # === Level 1: Franchise ===
├── settings/                # Shared franchise lore
│   ├── magic-system.md
│   └── characters/
│       └── legendary-hero.md
│
├── [work-a]/                # === Level 2: Work A ===
│   ├── series-bible.md      # Work A series bible
│   ├── settings/            # Work A local settings
│   │
│   ├── volume-1/            # === Level 3: Volume 1 of Work A ===
│   │   ├── outline.md       # Volume 1 outline and beats
│   │   ├── drafts/          # Volume 1 paragraph/chapter drafts
│   │   ├── epub-src/        # editable EPUB source generated by build
│   │   └── volume-1.epub    # built EPUB artifact
│   └── volume-2/            # Level 3: Volume 2 of Work A
│
└── [work-b]/                # === Level 2: Work B ===
    ├── series-bible.md
    └── volume-1/            # === Level 3: Volume 1 of Work B ===
```

### 2. Single Work Franchise Layout
Even if there is only one current work, keep the same structure as a multi-work franchise. The project root remains the Franchise level, and the work gets its own subdirectory so more works can be added later without migration:
```text
[project-root]/               # === Level 1: Franchise ===
├── settings/                # Optional shared settings for future works
│
└── [first-work]/            # === Level 2: Work ===
    ├── series-bible.md
    ├── settings/
    ├── volume-1/            # === Level 3: Volume ===
    │   ├── outline.md
    │   └── drafts/
    └── volume-2/
```

Root-level `series-bible.md` is not a valid production layout. Move it into a work directory such as `[project-root]/[work-slug]/series-bible.md`.

### Series Bible & Style Guide (`series-bible.md` & `settings/style-guide.md`)
The `series-bible.md` file tracks chronology, summaries of previous volumes, character evolution logs (e.g. ages, injuries, relationship modifications), and unresolved plot threads for the active work. 

**Work-Level Style Guide**: The prose style (style, tone, vocabulary preferences, broad reference traits, and character voice rules) is formally declared in either the `## Style Guide` section of `series-bible.md` or a local config file at `settings/style-guide.md` at the active Work level. The `@novelist` router automatically inherits and propagates these style settings to the Writer and Editor, ensuring that all volumes and drafts written under this Work maintain a consistent, unified prose style without requiring manual style declarations in every prompt.

If no style is declared, the default is **elegant, controlled, and assured literary prose by a renowned, seasoned professional novelist**. This baseline favors precise imagery, natural rhythm, emotional restraint, and scene-based feeling over generic explanation.

`settings/style-guide.md` stores the durable Style Contract and Character Voice Matrix for the work. Its narrative mode lock records POV person, tense, viewpoint anchor, and head-hopping rule so scene pressure cannot silently shift the narrator. The Character Voice Matrix records each character's speech register, vocabulary limits, taboo expressions, habitual phrases, silence patterns, and emotional tells. Writer and Editor use it to preserve style; Otaku uses it to detect character drift.

Each volume's `narrative-state.md` is the continuity ledger for current timeline point, locked-prefix summary, character locations, injuries, inventory, Location / World Canon References, Inventory Canon References, emotional state, relationship deltas, and open hooks. It is updated after each verified beat is consolidated.

Each volume's `writing-session.md` is the restart checkpoint for interrupted work. It records the operation type (`NEW_DRAFT`, `CONTINUATION`, `REVISION`, `SETTING_CHANGE_MIGRATION`, `BUILD`, or `VERIFY_ONLY`), target draft, current unit, next action, last final-PASS beat or span, draft/canon hashes, manifest row, evidence path, narrative-state update, Git commit, and locked context hashes for revisions. Unverified work stays in `.session/current-work.md` until final Otaku PASS.

Each volume's `verification-manifest.md` records each draft exactly once with the template's exact column order, `Draft SHA256`, `Canon Snapshot SHA256`, final Otaku PASS status, Editor Style Drift Audit PASS, Editor Character Voice Audit PASS, ledger update summaries, approved unknowns, and a linked Verification Evidence report. Publisher refuses to create an EPUB unless the manifest schema is intact, every packaged draft exists on disk, matches its recorded `Draft SHA256`, the canon bundle matches its recorded `Canon Snapshot SHA256`, the draft is listed with `Final Otaku Verdict: PASS`, `Style Drift Audit: PASS`, and `Character Voice Audit: PASS`, approved unknowns are either `None` or still tracked in `narrative-state.md` Open Hooks, the linked evidence report repeats the same proof fields, the report marks PASS for continuity, retcon safety, style, prose baseline, and character voice checklist items, Retcon Approval is `None` or points to an approved `retcons/*.md` proposal with user approval evidence and impacted canon proof, its Evidence Anchors table covers every checklist item with safe source paths and evidence phrases that appear verbatim in the referenced files, its Ledger Update Anchors prove each durable ledger fact appears in both the manifest summary and `narrative-state.md`, and the report contains no `FAIL`, `PENDING`, or `UNVERIFIED` verdicts.

Starter scaffolds are included under `templates/` for `style-guide.md`, `character-sheet.md`, `item-sheet.md`, `location-sheet.md`, `world-rule-sheet.md`, `series-bible.md`, `narrative-state.md`, `writing-session.md`, `verification-manifest.md`, `verification-evidence.md`, and `retcon-proposal.md`.

Before production writing, run `scripts/validate-production-artifacts.sh [work-path] [volume-path]` or let the router perform the same Artifact Preflight Gate. This blocks placeholder `TBD` fields, blank style contract entries, missing Required Style Anchors, missing Forbidden Style Drift, missing Style Verification Questions, missing POV person, missing tense, missing viewpoint anchor, missing head-hopping rule, artifact table schema drift, missing Series Bible chronology source files, missing Chronology evidence phrases, missing character voice rows, missing character sheets, voice matrix and character sheet mismatches, missing character knowledge boundaries, missing forbidden drift guards, missing active state anchors, active state anchors absent from `narrative-state.md`, active narrative-state characters or Series Bible evolution characters that are not covered by the voice matrix and character sheets, active locations or world-rule hooks without Location / World Canon References, missing location/world setting files, missing location active constraints, missing world rule statements, trackable possessions without Inventory Canon References, missing item setting files, item holder mismatches, missing item limitations, and weak narrative-state ledgers before Writer is allowed to draft.

## Usage Examples

### Novelist Router (auto-routing with feedback loop)

```text
/novelist Write the opening scene of a dark fantasy Chapter 1
  → ①Loremaster → ②Writer → ③Otaku (Lore Check) → ④Editor (Polishes style/fixes facts) → ⑤Otaku (Final Verify) → ⑥Done

/novelist This scene's pacing feels slow, please fix it
  → @novelist-editor → @novelist-otaku verify

/novelist Research whether the emergency room procedure in this scene is realistic
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

New durable setting facts introduced during drafting use Canon Expansion Review instead of automatic rejection. The router prefers accepting coherent additions because they enrich the work, but it first checks the new fact for internal consistency, scans prior drafts and canon for contradictions, then either records the fact, requests user approval for a migration, or sends the beat back for rewrite.

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
