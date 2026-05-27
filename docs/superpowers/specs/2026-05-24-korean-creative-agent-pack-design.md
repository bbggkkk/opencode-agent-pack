# Korean Creative Agent Pack Design

## Goal

Create a GitHub-distributable opencode agent pack for Korean-first creative writing, with English support when explicitly requested. The pack provides separate writer and editor roles for fiction.

## Scope

The repository will contain three opencode agent definitions, documentation, and usage examples. It will not include an npm package, installer script, plugin, or model-specific runtime integration in the first version.

## Repository Structure

```text
novelist/
  README.md
  LICENSE
  agents/
    novelist.md
    novel-editor.md
  examples/
    novel-brief.md
    revision-request.md
  docs/
    agent-design.md
```

## Agents

### novelist

Korean-first fiction writer. Produces scenes, dialogue, narration, character emotions, episode openings, and prose drafts. Supports English fiction when the user explicitly asks for English or provides an English brief.

### novel-editor

Fiction editor and feedback agent. Reviews plot logic, character consistency, prose rhythm, pacing, scene purpose, emotional continuity, and reader engagement. Provides concrete revision notes and optional rewritten samples.

### novel-publisher

EPUB build pipeline. Formats verified drafts into persistent editable `epub-src/` XHTML/CSS/metadata source, then packages that source into valid EPUB files using the system `zip` command. Story edits return to the draft pipeline first; layout and metadata edits can be made in `epub-src/` and rebuilt.



## Language, Culture & Creative Profiling Policy

Agents write in the language and style explicitly requested by the user. 

1. **Upfront Information Gathering**: If key parameters such as Style/Tone, Mood/Atmosphere, Language, or Cultural Background are missing, ambiguous, or unclear from the user's initial prompt, the router agent (`/novelist`) will ask the user *once* at the beginning to gather and align these parameters.
2. **Unified Profile Enforcement**: These parameters are compiled into a unified **Writing & Creative Profile**. The router propagates this profile to all sub-agents (Writer, Editor, Otaku, Researcher, Loremaster). Every stage of the workflow—including initial drafting, context research, review, editing/revising, and setting verification—strictly adheres to this profile to maintain creative consistency.
3. **Language Defaults**: If unspecified, the language defaults to Korean.
4. **Cultural Context Inference**: The cultural context is inferred based on the target language and its corresponding country/countries. If ambiguous, the agents prompt the user to input it.
5. **Web Novel Layout Format**: By default, agents write drafts in standard web novel format: paragraphs are separated strictly by a standard blank line (double newlines `\n\n`), without any hardcoded space indentation characters at the beginning. Dialogues are wrapped in double quotes `"..."` on a new line. All visual formatting (margins, indents, margins-bottom) is handled by the EPUB's CSS stylesheet during compilation.
6. **Korean-First Creative Writing**: Korean is the default context. When writing in Korean, outputs should prioritize natural sentence rhythm, believable dialogue, genre conventions, emotional continuity, and avoidance of stale cliches, representing a Korean cultural background.
7. **Default Prose Baseline**: If no style is declared, the default is elegant, controlled, and assured literary prose by a renowned, seasoned professional novelist.
8. **Character Voice Matrix**: Character speech register, vocabulary limits, taboo expressions, habitual phrases, silence patterns, and emotional tells are persisted in the work-level style guide.

## Style & Originality Policy

The system supports flexible style enforcement. The user can specify the prose style using direct descriptions (e.g. "concise, cold, hardboiled") or reference a creator/person as shorthand for broad traits such as atmosphere, pacing, sentence density, vocabulary preferences, or dialogue texture. The agents convert named-author requests into broad traits and produce original prose; they do not directly imitate living authors.

## Distribution

The pack will be distributed as a normal GitHub repository. Users can copy agent files into either global or project-local opencode agent directories.

Global install:

```bash
mkdir -p ~/.config/opencode/agents
cp agents/*.md ~/.config/opencode/agents/
```

Project install:

```bash
mkdir -p .opencode/agents
cp agents/*.md .opencode/agents/
```

After installing or changing agent files, users must restart opencode because config-time files are not hot-reloaded.

## Agent Configuration

Each agent will use file-based opencode definitions under `agents/*.md`. The default mode is `primary`, so users can select each creative role directly.

Permissions are intentionally conservative. Local reads are allowed for reviewing briefs and drafts. Edits are allowed so agents can write or revise project files through opencode's standard edit permission. Web access is `ask` to reduce accidental reference copying and copyright risk.

```yaml
mode: primary
permission:
  read: allow
  grep: allow
  glob: allow
  list: allow
  webfetch: ask
  websearch: ask
  edit: allow
  bash: ask
```

## Loop Safety and Narrative Continuity

1. **Step-by-Step Paragraph/Scene-Beat Loop**:
   - The Novelist system builds drafts sequentially, beat-by-beat or paragraph-by-paragraph.
   - For each segment, it runs the `Writer -> Otaku (Lore Check) -> Editor (Always runs to polish style/formatting/어투 & fix facts) -> Otaku (Final Verify)` cycle. Once verified, the segment is committed to the **Accumulated Prefix Text** (absolute canon prefix context) and cannot be rewritten or modified by subsequent iterations.
2. **Loop Safety & Collaborative Discussion**:
   - There are **no maximum loop limits or safety bypasses** that auto-approve failed drafts. Verification is 100% strict at the segment level.
   - To resolve deadlocks or contradictions:
     - **Setting-First Conflict Resolution Hierarchy**: Sub-agents automatically resolve contradictions using the priority order:
       - **Priority 1: Individual Entity Settings (개별 캐릭터/대상 설정 문서)** — Ultimate canon (e.g., character profiles, item sheets).
       - **Priority 2: General Lore & World-Building Settings (일반 세계관/시스템 설정 문서)** — Overrides plot progression.
       - **Priority 3: Recent Narrative State (최근 서사 상태/이전 장 내용)** — Overrides transient user prompts.
       - **Priority 4: User Brief / Transient Prompt (사용자 지시어)** — Lowest priority. Cannot violate established settings.
     - **Collaborative Discussion Protocol**: If a conflict is unresolvable (e.g., direct settings contradiction) or the user intervenes to override settings, the loop **halts**. The agent initiates a structured discussion in the chat: presenting the related Priority 1, 2, and 3 settings details, explaining the contradiction, and proposing how to align the files (e.g., editing the character profile vs general lore) for the user's decision.
3. **EPUB Publishing**:
   - The verified draft is passed to `@novelist-publisher` which converts Markdown paragraphs to HTML `<p>` tags.
   - Decoupled styling is enforced: indentations, padding, and line spacing are written inside the EPUB's `stylesheet.css`, allowing CSS to drive rendering.
   - Packaging is completed via standard system `zip` shell commands, keeping the pack lightweight and free of Python runtime dependencies.
4. **Change Log**: The Editor maintains a Change Log to prevent circular or conflicting modifications.
5. **Series Bible, Style Guide & Narrative Continuity in 3-Level Hierarchy**:
   - The system organizes creative projects into an isomorphic 3-level hierarchy: Franchise (shared settings at root), Work (required subdirectory with `series-bible.md` and work local `settings/`), and Volume (subdirectory like `volume-N/` inside the work).
   - Root-level `series-bible.md` is not a valid production layout; even a one-work franchise must use a work subdirectory so more works can be added later.
   - The `series-bible.md` ledger (at Work level) tracks chronology, summaries of previous volumes, character evolution states, and active plot threads for that specific work.
   - **Work-Level Style Guide**: The prose style (style, tone, vocabulary preferences, broad reference traits, and Character Voice Matrix) is formally declared in either the `## Style Guide` section of `series-bible.md` or a local config file at `settings/style-guide.md` at the active Work level. The `@novelist` router automatically inherits and propagates these style settings to the Writer and Editor, ensuring that all volumes and drafts written under this Work maintain a consistent, unified prose style.
   - **Volume Narrative State**: Each active volume maintains `narrative-state.md` as a continuity ledger for current timeline point, locked-prefix summary, character locations, inventory, injuries, emotional state, relationship deltas, and open hooks.
   - For Volume N (where N > 1), `@novelist-loremaster` retrieves previous volume summaries from the Work-level Series Bible to construct the backstory context.
   - Character attributes (ages, injuries) must align with the active volume's Evolution Log in the Work-level `series-bible.md`.
   - Local narrative states (previous chapter outlines, character conditions) are loaded relative to the active volume directory (`[Active Work Path][Active Volume Path]`).

## Testing And Verification

Verification will check that:

- All expected files exist.
- Agent frontmatter uses allowed opencode fields.
- Agent filenames match the documented names.
- README install instructions match the generated layout.
- No incomplete marker text remains in the generated files.

## Non-Goals

- No custom opencode plugin.
- No package manager distribution.
- No automatic installer.
- No scraping or copying of copyrighted novels.
- No claim that outputs match a specific real author.
