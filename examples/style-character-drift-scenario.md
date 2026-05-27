# Style And Character Drift Scenario

Use this scenario to smoke-test the Editor and Otaku behavior for prose style and character voice drift. The expected behavior is that `@novelist-editor` rewrites the bad span back into the Style Contract and Character Voice Matrix, and `@novelist-otaku` fails any revision that preserves the drift.

## Style Contract

- Prose baseline: elegant, controlled, and assured literary prose by a renowned, seasoned professional novelist.
- POV: close third-person anchored to Han Seo-yun.
- Sentence rhythm: measured, restrained, and tense.
- Diction: concrete sensory nouns, clean verbs, no internet slang.
- Metaphor density: low.
- Emotional temperature: controlled surface, pressure shown through gesture.
- Dialogue texture: compressed, purposeful, subtext-heavy.

## Character Voice Matrix

| Character | Register | Vocabulary Limits | Habitual Expressions | Taboo Expressions | Silence Pattern | Emotional Tells |
|-----------|----------|-------------------|----------------------|-------------------|-----------------|-----------------|
| Han Seo-yun | formal under pressure, clipped sentences | no slang, no military jargon | "확인했습니다" when accepting risk | never says "대박" | answers after one measured pause | touches her left cuff when lying |
| Baek I-an | informal but never flippant in danger | no academic jargon | "그건 내가 볼게" when taking responsibility | never calls Seo-yun "누나" | fills silence with practical questions | checks exits before confessing fear |

## Good Locked Context

서윤은 한 박자 늦게 고개를 끄덕였다. "확인했습니다."

그들은 봉인 기록실의 문 앞에 섰다. 이름을 말해야 한다는 규칙은 둘 다 알고 있었지만, 먼저 입을 여는 사람이 무엇을 잃게 될지는 아직 아무도 몰랐다.

## Bad Revision Span

서윤은 갑자기 완전 신나서 문을 쾅쾅 두드렸다. 심장은 롤러코스터처럼 미친 듯이 날뛰었고, 이 모든 상황은 솔직히 레전드급이었다.

"대박, 이거 그냥 밀면 되는 거 아냐?" 서윤이 웃었다.

이안은 어깨를 으쓱했다. "누나, 내가 과학적으로 분석해 봤는데 이 문은 그냥 분위기야."

## Expected Editor Findings

- Style Drift: internet slang and comic register violate the restrained literary baseline.
- Style Drift: exaggerated metaphor density violates the low-metaphor Style Contract.
- POV Drift: broad comic commentary pulls away from close third-person pressure.
- Character Voice Drift: Seo-yun uses forbidden slang and loses formal pressure register.
- Character Voice Drift: I-an uses the forbidden address "누나".
- Character Voice Drift: I-an uses academic framing despite the vocabulary limit.

## Expected Otaku / Verification Result

The unrepaired span must be **FAIL** for:

- Character voice drift: Seo-yun says "대박".
- Character voice drift: I-an calls Seo-yun "누나".
- Style contract drift: comic internet register violates the declared prose baseline.
- Style contract drift: exaggerated metaphor density violates the low-metaphor rule.
- Style contract drift: the revision does not preserve the requested close third-person emotional temperature.

## Expected Repair Direction

- Keep Seo-yun formal, clipped, and controlled.
- Keep I-an informal but practical, without forbidden address or academic jargon.
- Restore restrained sensory prose.
- Show pressure through gesture and choice instead of slang or comic summary.
