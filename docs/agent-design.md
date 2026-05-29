# Agent Design

## Architecture

This pack uses a **hierarchical agent architecture** with one router agent at the top level managing specialized sub-agents.

```
Novelist (Router) — draft/build pipeline router
├── novelist-writer — fiction writing (scenes, dialogue, plot, narration)
├── novelist-editor — fiction editing (plot, character, prose, pacing)
├── novelist-researcher — fiction-context research for real-world plausibility
├── novelist-loremaster — setting archivist (context retrieval from files)
├── novelist-otaku — setting verifier (consistency checking)
└── novelist-publisher — EPUB build pipeline (editable source + zip package)
```

Recommended model capability tiers for each role are documented in [Model Recommendations](model-recommendations.md). A Korean version is available at [model-recommendations.ko.md](model-recommendations.ko.md). The guide uses `gemma 4 31b` for creative prose/editing examples and `deepseek v4 flash` for routing, verification, retrieval, research, and publishing examples.

## Draft And Build Pipelines

The router keeps source manuscript work and EPUB output work separate.

- **Draft Pipeline**: default for ordinary writing, continuation, chapter, scene, and revision requests. It writes verified source drafts, updates narrative ledgers, updates Verification Manifest/Evidence, and commits draft/canon changes. It does not build EPUB output.
- **Build Pipeline**: activated only by explicit build/publish commands such as `build`, `epub build`, `EPUB로 만들어`, `출판`, or `패키징`. It verifies the manifest, generates editable EPUB source under `epub-src/`, packages `volume-N.epub`, and commits build artifacts separately.
- **EPUB Editing**: layout, metadata, CSS, TOC, title page, XHTML validity, and packaging fixes are made in `epub-src/` and rebuilt. Story/prose/canon changes return to the Draft Pipeline first.

## Draft Feedback Loop

The Novelist router runs a **structured feedback loop** for all draft writing requests, using a sequential paragraph-by-paragraph / beat-by-beat buildup model to guarantee near-perfect narrative consistency and logical transitions:

Drafting and revision are strictly sequential. The router must not run multiple Writer, Editor, or Otaku manuscript passes in parallel, because each beat or editable span depends on the latest accepted prefix, locked context, ledger state, and verification outcome.

The pipeline is treated as a mandatory production contract. The router and sub-agents must refuse shortcut language such as "quick", "simple", "just write", "skip verification", or `검증 생략` when it would omit required context loading, artifact preflight, Writer/Editor/Otaku passes, ledger updates, manifest updates, Verification Evidence, publication gates, or commits. Every production workflow records a Pipeline Step Ledger in `writing-session.md`; final delivery requires a Pipeline Completion Audit that proves every mandatory step completed with concrete evidence.

The initial user request defines the completion target. Unless the user intervenes, changes scope, pauses/stops the job, or a blocking protocol requires user input, the router keeps executing until the requested scope is complete. A request for a full work means full-work completion; a request for a book means full-volume completion; a request for a specific revision means that exact span is revised, verified, applied, ledgered, evidenced, and committed. The router records the Requested Scope of Work and Completion Target in `writing-session.md` so resume and final audit use the same boundary.

The Draft Pipeline uses a **Seed-to-Fruit Narrative Growth** model without replacing the existing feedback loop:

- **Seed**: capture the user's initial request as Requested Scope of Work and Completion Target.
- **Branches**: adopt the user's macro outline or author a provisional Macro Skeleton from canon artifacts, genre expectations, and reasonable creative defaults. The skeleton records major arcs, chapter/sequence purposes, turning points, escalation, endpoint, character movement, constraints, and the Length Budget for each branch/execution unit.
- **Leaves**: decompose the skeleton into an Execution Unit Queue and draft each unit through the existing Writer → Otaku → Editor → Otaku loop. Every leaf must attach to a parent branch and target/minimum character budget.
- **Flowers**: refine each unit through micro-level prose/style editing by Editor, voice/style audit, and macro branch traversal plus length verification by Otaku.
- **Fruit**: deliver only after the requested scope and promised minimum length are complete and verified with ledgers, manifest, evidence, and commits.

The router does not require the user to provide the branches. It asks only when a missing macro decision is mutually exclusive, high-impact, and impossible to infer from the request or canon. Editor stays focused on micro-level prose, speech style, formatting, local causality, pacing, immediate scene readability, and length preservation. Otaku owns the macro Branch Traversal Audit and Length Verification, checking whether the draft is still traveling along the assigned branch and whether actual character-count evidence meets the Length Budget. After every verified unit, the router performs a Skeleton Drift Check and Length Check using Otaku's reports. Safe improvements update the Macro Skeleton with rationale; changes to requested scope, endpoint, genre promise, Priority 1/2/3 canon, or promised length budget require user approval.

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
    ⑧ Done → verified source draft, ledger, manifest, and evidence updated
```

### Loop Safety & Collaborative Discussion
- **Step-by-Step Buildup**: Rather than drafting a whole chapter, the router decomposes the scene brief. Each segment/paragraph is generated, verified, and revised in isolation. Once verified, it is locked into the **Accumulated Prefix Text** which acts as canon context for all subsequent segments.
- **Seed-to-Fruit Narrative Growth**: The router records the seed, grows branches as a Macro Skeleton with Length Budget, attaches leaves through the existing feedback loop, refines flowers with verification and editing, and delivers fruit only after the requested scope and promised length are verified and recorded.
- **Agent-Authored Macro Skeleton**: Missing user-provided outlines do not block progress. The router authors a provisional Macro Skeleton unless the missing macro choice is mutually exclusive, high-impact, and impossible to infer.
- **Length Budget**: Every branch and execution unit has target/minimum character counts before drafting. Actual counts come from canonical draft files or router-supplied draft candidate counts using the declared method; no scope is complete while it is `UNDER_LENGTH`.
- **Editor Micro Focus**: Editor polishes prose, speech style, formatting, local causality, pacing, and immediate scene readability. It uses Macro Skeleton as a guardrail only and does not own whole-flow judgment.
- **Otaku Branch Traversal Audit**: Otaku owns the macro-flow check. Every final PASS must include evidence that the unit still travels along the assigned branch.
- **Skeleton Drift Check**: After every verified unit, the router checks Otaku's Branch Traversal Audit. Safe skeleton updates are logged; scope, endpoint, genre-promise, or canon-changing drift requires approval.
- **Non-Negotiable Pipeline Completion Gate**: Required workflow steps cannot be skipped, merged, simulated, or retroactively marked complete. If the Pipeline Completion Audit finds missing evidence for any required step, the router continues from the earliest missing step or halts with a blocking report.
- **Scope-Complete Execution**: The initial user request is the completion target. The router continues until that target is fully drafted or revised, verified, recorded, evidenced, and committed unless the user intervenes or a blocking condition requires user input.
- **No Parallel Drafting Or Revision**: Writer, Editor, Otaku verification, manuscript edits, ledger updates, manifest updates, and commits run sequentially. Parallelism is allowed only for independent read-only context gathering.
- **Canon Expansion Review**: New durable setting facts introduced by a beat are treated as canon expansion candidates. The default bias is to accept coherent additions, but the router first verifies internal consistency and scans prior drafts, settings, Series Bible, and narrative state for contradictions before recording or migrating them.
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
| `/novelist write Chapter 3` | Draft Pipeline only (①→②→③→④↺→⑧ Done), no EPUB build |
| `/novelist build` | Build Pipeline only: verify existing drafts, update editable `epub-src/`, and package `.epub` |
| `/novelist publish Chapter 3` | Build Pipeline via `@novelist-publisher` |
| `/novelist-loremaster collect setting on protagonist` | Setting document only |
| `/novelist-otaku verify this draft` | Verification only |
| `/novelist-otaku PASS` | Verification passed |
| `/novelist-otaku FAIL + report` | Needs revision |
| `/novelist-publisher compile book` | EPUB compilation only |

Direct `novelist-writer` output is always labeled `UNVERIFIED DRAFT`, and direct `novelist-editor` output is always labeled `UNVERIFIED REVISION`. These standalone results are exploration or proposed edits only; they are not canon, publishable, or safe to apply until final `@novelist-otaku` PASS is recorded in `verification-manifest.md` by the router workflow.

## Router Design

The router agent analyzes the user's natural language request and **delegates** to the appropriate sub-agent via opencode's `@agent-name` syntax:

| Router | Input Signal | Routes To |
|--------|-------------|-----------|
| `novelist` | create, write, draft, scene, chapter | Full feedback loop & publishing → loremaster → writer → otaku → editor → publisher |
| `novelist` | publish, epub, package, compile | `@novelist-publisher` |
| `novelist` | fix, review, feedback, revise, edit | `@novelist-editor` → `@novelist-otaku` |
| `novelist` | reality check, procedure, external facts, current facts, regional or historical research | `@novelist-researcher` |
| `novelist` | setting, context, lore, find | `@novelist-loremaster` |
| `novelist` | verify, check, validate | `@novelist-otaku` |

Router never attempts to perform the work itself — it evaluates the request and hands off a complete brief to the sub-agent.

## 3-Level Franchise, Work & Volume Hierarchy Architecture

The system supports dynamically expanding shared-universe franchises, multi-volume series, and single-work projects through one isomorphic 3-level hierarchy layout:
- **Franchise Level (Global settings - `settings/` at root)**: World rules, magic systems, and base character profiles that are shared across all works in the same universe.
- **Work Level (Specific novel/series - `[Active Work Path]`)**: A subdirectory representing a specific work containing its own `series-bible.md` ledger and work-specific `settings/` local overrides/additions. This subdirectory is required even when the franchise currently has only one work.
- Root-level `series-bible.md` is not a valid production layout; move it under `[franchise-root]/[work-slug]/series-bible.md`.
- **Volume Level (Individual books - `[Active Work Path][Active Volume Path]`)**: Individual folders for each volume (e.g. `volume-1/`, `volume-2/`) containing local outlines (`outline.md`) and chapter drafts (`drafts/`).
- **Cascading Context Routing**: The router detects the active Work directory and active Volume number/path from the request context or directory structure. It propagates this `Hierarchy Context` (`Active Work Path`, `Active Volume Number`, `Active Volume Path`) to sub-agents. The `@novelist-loremaster` cascades the settings resolution (Franchise settings + Work local overrides + Series Bible evolution log + Volume narrative state), and `@novelist-publisher` compiles EPUBs using the system `zip` utility relative to the volume path.

## Separation of Concerns

The design separates creation from feedback at every level:

- **Writer agent** (`novelist-writer`) produces drafts with high temperature (0.8)
- **Editor agent** (`novelist-editor`) diagnoses problems with low temperature (0.4)
- **Research agent** (`novelist-researcher`) gathers real-world facts through the current story's viewpoint, style, and canon constraints with low temperature (0.25)
- **Setting agents** (`novelist-loremaster`, `novelist-otaku`) provide factual grounding with low temperature (0.2)
- **Router agent** (`novelist`) classifies and delegates with low temperature (0.3)

The **loremaster → writer → otaku → editor → otaku** feedback loop ensures that every draft is:
1. Grounded in established setting (loremaster - facts only)
2. Creatively written (writer)
3. Verified for factual setting consistency (otaku - initial check)
4. Polished for style, 어투, formatting, and factual errors (editor - always runs)
5. Re-verified for absolute lore consistency (otaku - final verify)

This separation helps users run a draft-review-rewrite loop without mixing creative generation and critique in a single role.

## Revision And Retcon Safety

Existing manuscript edits use a protected revision loop:

1. Loremaster loads relevant canon, Style Contract, Character Voice Matrix, Series Bible, and Narrative State.
2. Router defines the exact editable span and locks surrounding context.
3. Editor revises only the editable span and reports Style Drift Audit plus Character Voice Audit results.
4. Otaku verifies the revised span against locked context and canon.
5. Router applies the edit only after Otaku PASS, then updates ledgers and commits.

Requests to change canon are classified as additive clarification, compatible retcon, breaking retcon, style-contract change, or character-voice change. Breaking changes require impact scanning and a collaborative discussion before any setting file or manuscript text is modified.

## Language, Culture & Creative Profiling Policy

Agents write in the language and style explicitly requested by the user. 

1. **Upfront Information Gathering**: If key parameters such as Style/Tone, Mood/Atmosphere, Language, or Cultural Background are missing, ambiguous, or unclear from the user's initial prompt, the router agent (`/novelist`) will ask the user *once* at the beginning to gather and align these parameters.
2. **Unified Profile Enforcement**: These parameters are compiled into a unified **Writing & Creative Profile**. The router propagates this profile to all sub-agents (Writer, Editor, Otaku, Researcher, Loremaster). Every stage of the workflow—including initial drafting, review, editing/revising, and setting verification—strictly adheres to this profile to maintain creative consistency.
3. **Language Defaults**: If unspecified, the language defaults to Korean.
4. **Cultural Context Inference**: The cultural context is inferred based on the target language and its corresponding country/countries. If ambiguous, the agents prompt the user to input it.
5. **Korean-First Creative Writing**: Korean is the default context. When writing in Korean, all agents prioritize natural Korean prose, believable dialogue, emotional continuity, and genre-specific expectations, representing a Korean cultural background.
6. **Default Prose Baseline**: If no style is declared, the router uses elegant, controlled, and assured literary prose by a renowned, seasoned professional novelist as the default. The default is persisted in `[Active Work Path]settings/style-guide.md` so future turns inherit the same standard.
7. **Character Voice Matrix**: Per-character speech register, vocabulary limits, taboo expressions, habitual phrases, silence patterns, and emotional tells are stored in the style guide and propagated to Writer, Editor, and Otaku.

## Production Continuity Artifacts

Every active work uses durable artifacts instead of relying on transient prompt memory:

| Artifact | Path | Purpose |
|----------|------|---------|
| Style Guide | `[Active Work Path]settings/style-guide.md` | Style Contract, default prose baseline, narrative mode lock, forbidden drift, formatting rules, and Character Voice Matrix |
| Series Bible | `[Active Work Path]series-bible.md` | Chronology, volume summaries, character evolution logs, relationship changes, and unresolved threads |
| Volume Narrative State | `[Active Work Path][Active Volume Path]narrative-state.md` | Current timeline point, locked-prefix summary, Location / World Canon References, Inventory Canon References, injuries, locations, emotional state, and open hooks |
| Writing Session | `[Active Work Path][Active Volume Path]writing-session.md` | Restart checkpoint for interrupted writing, continuation, revision, setting migration, and build work |
| Verification Manifest | `[Active Work Path][Active Volume Path]verification-manifest.md` | Per-draft proof of matching Draft SHA256, matching Canon Snapshot SHA256, final Otaku PASS status, Style Drift Audit PASS, Character Voice Audit PASS, ledger updates, and linked Verification Evidence before publication |
| Retcon Proposal | `[Active Work Path]retcons/*.md` | User-approved record for non-additive canon migrations, including impacted drafts, impacted canon files, risks, required updates, and verification plan |
| Editable EPUB Source | `[Active Work Path][Active Volume Path]epub-src/` | Persistent XHTML/CSS/metadata source generated by the Build Pipeline so EPUB layout and packaging can be edited and rebuilt without mutating verified drafts |

The router loads the relevant artifacts before writing or editing. If an artifact is missing, it scaffolds it from `templates/style-guide.md`, `templates/character-sheet.md`, `templates/item-sheet.md`, `templates/location-sheet.md`, `templates/world-rule-sheet.md`, `templates/series-bible.md`, `templates/narrative-state.md`, `templates/writing-session.md`, `templates/verification-manifest.md`, `templates/verification-evidence.md`, or `templates/retcon-proposal.md` when available. After each verified beat is consolidated, it updates the Volume Narrative State and Writing Session with only facts established by verified text and records Draft SHA256, Canon Snapshot SHA256, final Otaku PASS, Style Drift Audit PASS, Character Voice Audit PASS, ledger summary, approved unknowns, Retcon Approval, and a linked Verification Evidence report in the Verification Manifest. Approved unknowns must be `None` or still tracked in `narrative-state.md` Open Hooks. Verification Evidence reports live under `verification-reports/` and must PASS physical, possession, knowledge, location/world, timeline, retcon, style, prose baseline, and character voice checklist items. They must also include Retcon Approval as `None` or a safe approved `retcons/*.md` file with user approval evidence and impacted canon proof, Evidence Anchors for every checklist item whose safe source paths and evidence phrases resolve to real draft, `narrative-state.md`, `series-bible.md`, or `settings/**/*.md` text, plus Ledger Update Anchors proving each durable ledger fact appears in both the manifest summary and `narrative-state.md`. After a chapter or volume is completed, it updates the Series Bible.

Publisher reads `verification-manifest.md` before packaging. If the manifest schema column order drifts, any draft is missing from the manifest, appears more than once, is listed but missing on disk, has a `Draft SHA256` mismatch, has a `Canon Snapshot SHA256` mismatch, contains hardcoded leading indentation, trailing whitespace, merge conflict markers, raw HTML layout tags, unsafe markup, Character Voice Matrix taboo expressions, or Style Guide Forbidden Literal Phrases, has placeholder approved unknowns, has approved unknowns absent from `narrative-state.md` Open Hooks, lacks matching Verification Evidence, has Retcon Approval pointing outside `retcons/*.md` or to an unapproved/missing retcon proposal, has missing Evidence Anchors, has missing Ledger Update Anchors, has evidence anchor phrases absent from their source files, contains contradictory `FAIL`, `PENDING`, or `UNVERIFIED` evidence verdicts, or lacks `Final Otaku Verdict: PASS`, `Style Drift Audit: PASS`, or `Character Voice Audit: PASS`, publication halts.

Before any Writer call, the router runs an Artifact Preflight Gate equivalent to `scripts/validate-production-artifacts.sh [work-path] [volume-path]`. Preflight rejects unresolved `TBD` placeholders, blank required style fields, missing Required Style Anchors, missing Forbidden Style Drift, missing Style Verification Questions, missing POV person, missing tense, missing viewpoint anchor, missing head-hopping rule, artifact table schema drift, missing Series Bible chronology source files, missing Chronology evidence phrases in source files, missing character voice rows, missing character setting files, voice matrix and character sheet mismatches, missing character knowledge boundaries, missing forbidden drift guards, missing active state anchors, active state anchors absent from `narrative-state.md`, active narrative-state characters without matching Character Voice Matrix rows, active narrative-state characters without matching character sheets, Series Bible evolution characters without matching voice rows or character sheets, active locations or world-rule hooks without Location / World Canon References, missing location/world setting files, missing location active constraints, missing world rule statements, trackable possessions without Inventory Canon References, missing item setting files, item holder mismatches, missing item limitations, and weak narrative-state ledgers. If preflight fails, the router fills missing canon from explicit user-provided facts or halts for the required style/voice/canon decisions instead of drafting from placeholders.

## Safety And Originality

The agents avoid direct imitation of living authors. They convert named-author requests into broad creative traits such as atmosphere, structure, emotion, tempo, sentence density, or genre, then produce original prose.

## Distribution Model

Humans install agents via the interactive `install.sh` or `install.ps1` script. The installer lets the user choose project-local or global installation; project-local installs can point at the selected project directory:

```bash
git clone https://github.com/bbggkkk/opencode-novelist.git
cd opencode-novelist
./install.sh
```

Clone-free interactive install is also supported by downloading and executing the installer without leaving a script file behind:

```bash
sh -c "$(curl -sSL https://raw.githubusercontent.com/bbggkkk/opencode-novelist/master/install.sh)"
```

Agents and automation must use non-interactive one-line commands. Project-local installs default to the command's current working directory, or can receive an explicit project directory:

```bash
curl -sSL https://raw.githubusercontent.com/bbggkkk/opencode-novelist/master/install.sh | sh -s -- --project
curl -sSL https://raw.githubusercontent.com/bbggkkk/opencode-novelist/master/install.sh | sh -s -- --project /path/to/project
curl -sSL https://raw.githubusercontent.com/bbggkkk/opencode-novelist/master/install.sh | sh -s -- --global
```

Backward-compatible aliases remain supported: `1 [project-dir]` for project-local install and `2` for global install.

Templates are deliberately installed outside agent discovery, and support skills are installed in OpenCode skill discovery:

- project-local templates: `.opencode/novelist/templates/`
- project-local skills: `.opencode/skills/`
- global templates: `~/.config/opencode/novelist/templates/`
- global skills: `~/.config/opencode/skills/`

Manual copy is also supported:

```bash
mkdir -p ~/.config/opencode/agents ~/.config/opencode/novelist/templates ~/.config/opencode/skills
cp -r agents/* ~/.config/opencode/agents/
cp -r templates/* ~/.config/opencode/novelist/templates/
cp -r skills/* ~/.config/opencode/skills/
```

After installation, restart opencode for changes to take effect.

## Interruption Recovery

Long-running writing, continuation, revision, setting migration, and build workflows use a file-based checkpoint so the agent can resume after a forced stop without trusting chat history. The router creates or updates `[Active Work Path][Active Volume Path]writing-session.md` and keeps unverified temporary work under `[Active Work Path][Active Volume Path]/.session/`.

The session records the operation type (`NEW_DRAFT`, `CONTINUATION`, `REVISION`, `SETTING_CHANGE_MIGRATION`, `BUILD`, or `VERIFY_ONLY`), target draft, current unit, current stage, next action, last stable final-PASS beat/span, draft hash, canon snapshot hash, manifest row, evidence path, narrative-state update, and last Git commit. Revision sessions additionally record locked before/after context hashes so a stored edit cannot be applied after surrounding text changes.

On resume, the router validates the target draft hash, canon snapshot hash, manifest row, matching Verification Evidence, narrative-state update phrase, and revision locked context before continuing. Temporary `.session/` output is never considered canonical; it must be reverified or regenerated. If validation fails, the router enters recovery mode instead of writing new prose.

## Skill Mapping

Each agent is paired with specific opencode skills that enhance its capabilities.

| Skill | Used By | Purpose |
|-------|---------|---------|
| `brainstorming` | novelist-writer, novelist-editor | Creative exploration before drafting or revision |
| `writing-plans` | novelist-writer | Multi-step plan generation for episode outlines |
| `setting-collapse-detector` | novelist-loremaster, novelist-otaku | Systematic setting consistency verification |
| `dispatching-parallel-agents` | novelist | Parallel read-only context gathering only |
| `executing-plans` | novelist | Structured execution of multi-step plans |

### Skill Invocation

- **setting-collapse-detector** is invoked automatically by `@novelist-otaku` on every draft verification, and by `@novelist-loremaster` after collecting setting info to check for internal contradictions.
- **brainstorming** is invoked by writer/editor agents when the brief is open-ended or when multiple creative approaches need exploration.
- **dispatching-parallel-agents** is used by routers only when multiple independent read-only context gathering tasks can run simultaneously. It is not used for Writer, Editor, Otaku verification, manuscript edits, ledger updates, manifest updates, or commits.
- All agents with skill access declare `skill: allow` in their YAML permission block to enable skill invocation.

## Production Verification

The repository includes `make validate` and `scripts/validate-all.sh` as the release gate. The full suite runs frontmatter validation, continuity scenario validation, sample work validation, production invariant checks, and a Bash installer smoke test.

The same release gate is wired to `.github/workflows/validate.yml` so push and pull request changes run `make validate` in CI. A separate `windows-latest` job executes `install.ps1` and verifies agents, skills, and templates are installed.

`scripts/validate-production-invariants.sh` checks that:

- Agent prompts preserve the default professional prose baseline, Style Contract propagation, Character Voice Matrix propagation, strict Otaku failure conditions, and continuity ledger workflow.
- Direct Writer and Editor calls preserve standalone safety labels so unverified drafts or revisions cannot be mistaken for approved manuscript text.
- Templates for `style-guide.md`, `series-bible.md`, and `narrative-state.md` exist and contain the required scaffold sections.
- Installers distribute the templates alongside the agents.
- Deprecated direct-imitation wording does not re-enter docs or prompts.

`examples/production-continuity-scenario.md` provides a concrete smoke scenario for setting collapse, voice drift, knowledge collapse, physical continuity, and ledger update behavior.

`scripts/validate-continuity-scenario.sh` validates that this fixture still contains the canon facts, bad beat contradictions, and expected findings needed to exercise those failure modes.

`examples/style-character-drift-scenario.md` provides a concrete smoke scenario for style drift, POV drift, metaphor-density drift, and character voice drift. `scripts/validate-style-character-drift-scenario.sh` verifies the fixture contains the bad span and expected FAIL findings.

`examples/sample-work/` provides a complete sample work hierarchy with settings, character sheets, world rules, `series-bible.md`, `volume-1/narrative-state.md`, and a draft chapter. `scripts/validate-sample-work.sh` checks that the fixture preserves style baseline, character voice, possession, injury, knowledge, world-rule, and retcon guard coverage.

`scripts/validate-verification-manifest.sh [volume-path] [work-path]` checks the exact Verification Manifest table schema, then checks that every Markdown draft in a volume's `drafts/` directory is listed exactly once in `verification-manifest.md` with matching `Draft SHA256`, matching `Canon Snapshot SHA256`, `Final Otaku Verdict: PASS`, `Style Drift Audit: PASS`, `Character Voice Audit: PASS`, a non-placeholder ledger update summary, a non-placeholder Approved Unknowns value, and a linked Verification Evidence report that repeats the same proof fields and marks all required continuity, style, and character voice checklist items PASS. If Approved Unknowns is not `None`, each approved unknown must still appear in `narrative-state.md` Open Hooks. If Retcon Approval is not `None`, it must point to an approved `retcons/*.md` proposal with user approval evidence, impacted canon rows, and verification phrases present in each impacted canon file. It rejects linked evidence reports that still contain `FAIL`, `PENDING`, or `UNVERIFIED`; it requires Evidence Anchors for every checklist item, including timeline, retcon safety, prose baseline, POV/diction/rhythm, forbidden-expression, and character-evolution checks, then verifies that each source path is safe and each evidence phrase appears in the referenced source file; it also requires Ledger Update Anchors for timeline, physical state, inventory, knowledge boundary, and location/world facts, then verifies that each summary phrase appears in the manifest ledger and each state phrase appears in `narrative-state.md`; it rejects drafts with hardcoded leading indentation, trailing whitespace, merge conflict markers, raw HTML layout tags, unsafe markup, Character Voice Matrix taboo expressions, or Style Guide Forbidden Literal Phrases; and it also rejects manifest entries for draft files that no longer exist on disk.

`scripts/test-verification-manifest-negative.sh` mutates a temporary copy of the sample work to confirm the manifest validator rejects missing entries, duplicate entries, stale entries, schema drift, malformed rows, hash mismatches after draft mutation, canon snapshot mismatches after settings mutation, `PENDING` verdicts, failed style audits, pending character voice audits, placeholder ledger summaries, placeholder or untracked approved unknowns, standalone unverified draft labels, missing or mismatched Verification Evidence reports, missing or unapproved Retcon Approval files, missing impacted canon files, missing Evidence Anchors, missing Ledger Update Anchors, unsafe evidence anchor paths, evidence anchor phrases absent from their source files, and extra drafts that are not listed in the manifest.

`scripts/validate-production-artifacts.sh [work-path] [volume-name]` checks that the actual work artifacts are filled enough for production writing and that their table schemas still match the templates. `scripts/test-production-artifacts-negative.sh` confirms the gate rejects placeholder style fields, missing Required Style Anchors, missing Forbidden Style Drift, missing Style Verification Questions, missing narrative mode locks such as head-hopping rules, blank character speech constraints, voice matrix and character sheet mismatches, missing character knowledge boundaries, missing forbidden drift guards, missing or unmatched active state anchors, placeholder narrative-state entries, schema drift in voice/chronology/evolution/location/character-state/inventory tables, missing Series Bible chronology sources, missing or unmatched Chronology evidence phrases, orphan Series Bible evolution characters, missing character files, missing location/world canon references, missing location setting files, missing location active constraints, missing world rule statements, blank world constraints, missing inventory canon references, missing item setting files, item holder mismatches, missing item limitations, and inactive item holders.

`docs/production-readiness-audit.md` maps the core requirements to concrete files and validation gates.
