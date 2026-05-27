---
name: setting-collapse-detector
description: "Systematically detects setting collapses in fiction: character, timeline, geography, world rules, possession, and dialogue inconsistencies."
version: 1.0.0
author: Novelist System
tags: [fiction, setting, consistency, verification, lore]
dependencies: []
---

# Setting Collapse Detector

A systematic framework for detecting setting collapses — contradictions, omissions, and distortions between a draft and its established lore. This skill is designed for `@novelist-loremaster` (during setting collection) and `@novelist-otaku` (during draft verification).

## When to Use This Skill

- After collecting setting information from source files (loremaster)
- After a draft is written, before delivery (otaku)
- When the user reports something "feels off" about consistency
- Before beginning a new chapter that depends on established lore

## Detection Categories

### 1. Character Collapse

Check every named character in the draft against the setting document:

| Check | What to look for |
|-------|-----------------|
| Name | Spelling consistency across all mentions |
| Age | Birth year, age at specific events, aging rate |
| Appearance | Height, build, hair/eye color, distinguishing features, scars, tattoos |
| Personality | Temperament, speech patterns, values, fears, habits |
| Abilities | Skills, powers, limitations, training level |
| Relationships | Family, friends, enemies, romantic connections, affiliations |
| Backstory | Past events they experienced, places they've been, people they've met |
| Injuries | Wounds, scars, disabilities, recovery state |
| Voice Matrix | Register, vocabulary limits, habitual expressions, taboo terms, silence patterns, emotional tells |

### 2. Timeline Collapse

Map every time reference in the draft against the established timeline:

| Check | What to look for |
|-------|-----------------|
| Event order | Sequence of referenced past events |
| Duration | How long events take (travel time, battle duration, recovery) |
| Character age | Age at each story point |
| Season/weather | Consistency with the current in-story season |
| Time of day | Light conditions, character activity patterns |
| Relative timing | "Three days later" — verify three days actually passed |
| Flashbacks | Placement, trigger, content accuracy |

### 3. Geography & Space Collapse

Check all location references:

| Check | What to look for |
|-------|-----------------|
| Distance | Travel time between locations matches established geography |
| Direction | Relative positions of landmarks, cities, regions |
| Architecture | Building layout, room positions, floor count, style |
| Environment | Climate, terrain, flora, fauna match the region |
| Interior | Room contents, furniture, lighting, size |
| Weather | Consistency with season and regional climate |

### 4. World Rules Collapse

Check the internal logic of the fictional world:

| Check | What to look for |
|-------|-----------------|
| Magic system | Rules, costs, limitations, who can use it, known exceptions |
| Technology | Available tech level, power sources, limitations |
| Society | Laws, customs, social hierarchy, taboos, currency |
| Politics | Faction relationships, leadership, treaties, conflicts |
| Religion | Deities, practices, clergy, holy sites, taboos |
| Economy | Trade routes, valuable resources, currency, class structure |

### 5. Possession & Physical Continuity Collapse

Track items and physical state across scenes:

| Check | What to look for |
|-------|-----------------|
| Inventory | Items carried, gained, lost, or used between scenes |
| Clothing | What the character is wearing, changes, damage |
| Weapons | Current weapon, ammunition, condition, maintenance |
| Injuries | Fresh wounds in wrong scenes, miraculous recovery without explanation |
| Resources | Money, food, supplies — gain and depletion tracking |

### 6. Dialogue & Knowledge Collapse

Check what characters say against what they know:

| Check | What to look for |
|-------|-----------------|
| Knowledge | Character mentioning events they didn't witness or weren't told about |
| Vocabulary | Words/terms the character wouldn't use given their background |
| Register | Formality level, dialect, honorifics, profanity, and intimacy level matching the character and relationship |
| Emotional tell | Whether the character's phrasing under stress matches established behavior |
| Secrets | Revealing information they promised to keep hidden |
| Anachronism | References to things that don't exist yet in the timeline |
| Meta-knowledge | Character knowing something the author knows but they shouldn't |

### 7. Style & Voice Continuity Collapse

Check durable prose and voice constraints without judging aesthetic taste:

| Check | What to look for |
|-------|-----------------|
| Style contract | Sentence rhythm, diction, metaphor density, POV distance, and emotional temperature remain within the declared style guide |
| Default baseline | If no style is declared, prose remains elegant, controlled, and assured rather than generic, flat, or tonally erratic |
| Character voice | Dialogue and internal narration preserve each character's established linguistic fingerprint |
| Drift | Sudden unmotivated shifts in comedy level, melodrama, exposition density, or genre register |
| Living-author request | Named living author references are converted into broad traits, not direct imitation |

## Output Format

Always produce a structured table:

```markdown
## Setting Collapse Report: [Target Name]

### Collapses Found
| # | Category | Location | Description | Evidence | Fix |
|---|----------|----------|-------------|----------|-----|
| 1 | Character | Ch.3 para 12 | Lee is left-handed but uses right hand for sword | Setting doc p.2 "left-handed", Ch.1 para 5 "his left hand gripped the hilt" | "right hand" → "left hand" |

### PASS / FAIL
- **PASS**: No collapses detected
- **FAIL**: {n} collapses found — must fix before proceeding
```

## Rules

- Every claim must cite a source (file path + line number)
- If uncertain, mark as "Unverified" — do not guess
- Include concrete fix suggestions for every finding
- Zero tolerance: even one wrong adjective counts as a finding
- For loremaster: also flag incomplete or contradictory setting info during collection
