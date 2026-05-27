# Production Continuity Scenario

Use this scenario to smoke-test the novelist loop before relying on it for a long project. The expected behavior is that `@novelist-otaku` fails the bad beat, `@novelist-editor` repairs it without changing canon, and the router records durable facts in `narrative-state.md` only after final PASS.

## Work Artifacts

### `settings/style-guide.md`

- Prose baseline: elegant, controlled, and assured literary prose by a renowned, seasoned professional novelist.
- Style Contract: restrained third-person close POV, precise sensory images, low metaphor density, no comedic register drift.
- Character Voice Matrix:

| Character | Register | Vocabulary Limits | Habitual Expressions | Taboo Expressions | Silence Pattern | Emotional Tells |
|-----------|----------|-------------------|----------------------|-------------------|-----------------|-----------------|
| Han Seo-yun | formal under pressure, clipped sentences | no slang, no military jargon | "확인했습니다" when accepting risk | never says "대박" | answers after one measured pause | touches her left cuff when lying |
| Baek I-an | informal but never flippant in danger | no academic jargon | "그건 내가 볼게" when taking responsibility | never calls Seo-yun "누나" | fills silence with practical questions | checks exits before confessing fear |

### `series-bible.md`

- Han Seo-yun is left-handed.
- Baek I-an has never met Director Chae.
- The sealed archive door opens only when two living witnesses speak their legal names.
- Volume 1 character evolution: Seo-yun's right shoulder is wounded and cannot bear weight.

### `volume-1/narrative-state.md`

- Current time: 02:10 before dawn.
- Current location: lower archive corridor.
- Seo-yun carries the brass witness key in her left coat pocket.
- I-an knows the archive rule but does not know Director Chae's face or voice.
- Locked prefix: Seo-yun and I-an reached the sealed archive door while alarms sounded above them.

## Bad Next Beat

Seo-yun shoved the brass key into her right sleeve and shouldered the iron door open with a laugh.

"대박, 그냥 열리네."

I-an recognized Director Chae's recorded voice at once. "누나, 저 사람 또 거짓말이야. 내가 볼게."

## Expected Verification Result

`@novelist-otaku` must return FAIL with findings for:

- Physical continuity: Seo-yun uses the wounded right shoulder.
- Possession continuity: the key moves from left coat pocket to right sleeve without cause.
- World rule collapse: the sealed door opens without two living witnesses speaking legal names.
- Character voice drift: Seo-yun uses slang that is explicitly forbidden.
- Character voice drift: I-an calls Seo-yun "누나", explicitly forbidden.
- Knowledge collapse: I-an recognizes Director Chae despite never meeting them.

## Expected Repair Direction

`@novelist-editor` should preserve the setting and revise the beat so:

- Seo-yun protects her right shoulder and uses the left hand or asks I-an to handle force.
- The witness key remains in or is deliberately taken from the left coat pocket.
- The door does not open until both witnesses speak legal names.
- Seo-yun's dialogue remains formal and controlled.
- I-an remains informal but practical, without the forbidden address.

## Expected Ledger Updates After PASS

- Whether the witness key was removed from the left coat pocket.
- Whether the door opened, and by which legal names.
- Any new injury strain, emotional state, or relationship delta established by the repaired beat.
