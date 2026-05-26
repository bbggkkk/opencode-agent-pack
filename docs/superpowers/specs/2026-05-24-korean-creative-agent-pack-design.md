# Korean Creative Agent Pack Design

## Goal

Create a GitHub-distributable opencode agent pack for Korean-first creative writing, with English support when explicitly requested. The pack provides separate writer and editor roles for fiction and lyrics.

## Scope

The repository will contain four opencode agent definitions, documentation, and usage examples. It will not include an npm package, installer script, plugin, or model-specific runtime integration in the first version.

## Repository Structure

```text
novelist/
  README.md
  LICENSE
  agents/
    novelist.md
    novel-editor.md
    lyricist.md
    lyric-editor.md
  examples/
    novel-brief.md
    lyric-brief.md
    revision-request.md
  docs/
    agent-design.md
```

## Agents

### novelist

Korean-first fiction writer. Produces scenes, dialogue, narration, character emotions, episode openings, and prose drafts. Supports English fiction when the user explicitly asks for English or provides an English brief.

### novel-editor

Fiction editor and feedback agent. Reviews plot logic, character consistency, prose rhythm, pacing, scene purpose, emotional continuity, and reader engagement. Provides concrete revision notes and optional rewritten samples.

### lyricist

Korean-first lyric writer. Produces lyrics for K-pop, ballad, hip-hop, indie, OST, and adjacent genres. Prioritizes Korean pronunciation, hook strength, repetition, rhyme, syllable feel, imagery, and singability. Supports English lyrics when requested.

### lyric-editor

Lyric editor and feedback agent. Reviews hook clarity, verse/pre-chorus/chorus structure, rhyme, flow, pronunciation, message clarity, cliche usage, and fit to genre or melody constraints.

## Language, Culture & Creative Profiling Policy

Agents write in the language and style explicitly requested by the user. 

1. **Upfront Information Gathering**: If key parameters such as Style/Tone, Mood/Atmosphere, Language, or Cultural Background are missing, ambiguous, or unclear from the user's initial prompt, the router agents (`/novelist`, `/lyricist`) will ask the user *once* at the beginning to gather and align these parameters.
2. **Unified Profile Enforcement**: These parameters are compiled into a unified **Writing & Creative Profile** (or **Lyric Profile**). The routers propagate this profile to all sub-agents (Writer, Editor, Otaku, Researcher, Loremaster). Every stage of the workflow—including initial drafting, review, editing/revising, and setting verification—strictly adheres to this profile to maintain creative consistency.
3. **Language Defaults**: If unspecified, the language defaults to Korean.
4. **Cultural Context Inference**: The cultural context is inferred based on the target language and its corresponding country/countries. If ambiguous, the agents prompt the user to input it.
5. **Korean-First Creative Writing**: Korean is the default context. When writing in Korean, outputs should prioritize natural sentence rhythm, believable dialogue, genre conventions, emotional continuity, and avoidance of stale cliches, representing a Korean cultural background.

## Copyright And Style Policy

Agents should not imitate living authors, specific copyrighted songs, or protected lyrics directly. They may use broad genre, mood, structure, and craft references. If a user asks for direct imitation of a specific artist or song, the agent should redirect to a non-infringing alternative based on abstract traits such as atmosphere, tempo, emotional arc, or narrative structure.

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

1. **Loop Safety & Collaborative Discussion**:
   - There are **no maximum loop limits or safety bypasses** that auto-approve failed drafts. Verification remains 100% strict.
   - To resolve deadlocks or contradictions:
     - **Setting-First Conflict Resolution Hierarchy**: Sub-agents automatically resolve contradictions using the priority order:
       - **Priority 1: Individual Entity Settings (개별 캐릭터/대상 설정 문서)** — Ultimate canon (e.g., character profiles, item sheets).
       - **Priority 2: General Lore & World-Building Settings (일반 세계관/시스템 설정 문서)** — Overrides plot progression.
       - **Priority 3: Recent Narrative State (최근 서사 상태/이전 장 내용)** — Overrides transient user prompts.
       - **Priority 4: User Brief / Transient Prompt (사용자 지시어)** — Lowest priority. Cannot violate established settings.
     - **Collaborative Discussion Protocol**: If a conflict is unresolvable (e.g., direct settings contradiction) or the user intervenes to override settings, the loop **halts**. The agent initiates a structured discussion in the chat: presenting the related Priority 1, 2, and 3 settings details, explaining the contradiction, and proposing how to align the files (e.g., editing the character profile vs general lore) for the user's decision.
2. **Change Log**: The Editor maintains a Change Log to prevent circular or conflicting modifications.
3. **Narrative Continuity**: Loremaster retrieves the latest Narrative State (previous episode summary, character states, timeline details) to ensure natural flow and logical transitions.

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
- No scraping or copying of copyrighted lyrics or novels.
- No claim that outputs match a specific real author or musician.
