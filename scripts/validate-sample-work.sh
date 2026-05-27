#!/bin/sh
set -eu

WORK="${1:-examples/sample-work}"

fail() {
    printf 'FAIL: %s\n' "$1" >&2
    exit 1
}

require_file() {
    [ -s "$1" ] || fail "missing or empty file: $1"
}

require_text() {
    file="$1"
    pattern="$2"
    label="$3"
    grep -Fq -- "$pattern" "$file" || fail "$label missing in $file"
}

reject_text() {
    file="$1"
    pattern="$2"
    label="$3"
    if grep -Eq -- "$pattern" "$file"; then
        fail "$label found in $file"
    fi
}

require_file "$WORK/settings/style-guide.md"
require_file "$WORK/settings/characters/han-seo-yun.md"
require_file "$WORK/settings/characters/baek-i-an.md"
require_file "$WORK/settings/items/brass-witness-key.md"
require_file "$WORK/settings/locations/lower-archive-corridor.md"
require_file "$WORK/settings/world/archive-rules.md"
require_file "$WORK/series-bible.md"
require_file "$WORK/volume-1/narrative-state.md"
require_file "$WORK/volume-1/verification-manifest.md"
require_file "$WORK/volume-1/verification-reports/chapter-01.md"
require_file "$WORK/volume-1/drafts/chapter-01.md"
require_file "$WORK/volume-1/expected-ledger-update.md"

require_text "$WORK/settings/style-guide.md" "renowned, seasoned professional novelist" "default renowned seasoned prose baseline"
require_text "$WORK/settings/style-guide.md" "Style Contract" "style contract"
require_text "$WORK/settings/style-guide.md" "Required Style Anchors" "required style anchors"
require_text "$WORK/settings/style-guide.md" "Forbidden Style Drift" "forbidden style drift"
require_text "$WORK/settings/style-guide.md" "Forbidden Literal Phrases" "forbidden literal phrases"
require_text "$WORK/settings/style-guide.md" "Style Verification Questions" "style verification questions"
require_text "$WORK/settings/style-guide.md" "Revision Guardrails" "style revision guardrails"
require_text "$WORK/settings/style-guide.md" "POV person: third-person narration" "style POV person lock"
require_text "$WORK/settings/style-guide.md" "Tense: past tense narration" "style tense lock"
require_text "$WORK/settings/style-guide.md" "Viewpoint anchor: Han Seo-yun's perceptions" "style viewpoint anchor lock"
require_text "$WORK/settings/style-guide.md" "Head-hopping rule: no unmarked interiority" "style head-hopping lock"
require_text "$WORK/settings/style-guide.md" "Character Voice Matrix" "character voice matrix"
require_text "$WORK/settings/style-guide.md" "never says \"대박\"" "Seo-yun forbidden slang"
require_text "$WORK/settings/style-guide.md" "never calls Seo-yun \"누나\"" "I-an forbidden address"

require_text "$WORK/settings/characters/han-seo-yun.md" "left-handed" "Seo-yun handedness"
require_text "$WORK/settings/characters/han-seo-yun.md" "right shoulder wound" "Seo-yun injury"
require_text "$WORK/settings/characters/han-seo-yun.md" "left coat pocket" "Seo-yun key possession"
require_text "$WORK/settings/characters/han-seo-yun.md" "Forbidden Drift" "Seo-yun forbidden drift field"
require_text "$WORK/settings/characters/han-seo-yun.md" "Allowed Evolution" "Seo-yun allowed evolution field"
require_text "$WORK/settings/characters/han-seo-yun.md" "Active Physical Anchor: right shoulder wounded; cannot bear weight" "Seo-yun active physical anchor"
require_text "$WORK/settings/characters/han-seo-yun.md" "Active Inventory Anchor: brass witness key in left coat pocket" "Seo-yun active inventory anchor"
require_text "$WORK/settings/characters/baek-i-an.md" "has never met Director Chae" "I-an knowledge boundary"
require_text "$WORK/settings/characters/baek-i-an.md" "never calls Han Seo-yun \"누나\"" "I-an forbidden address in character sheet"
require_text "$WORK/settings/characters/baek-i-an.md" "Knowledge Boundaries" "I-an knowledge boundaries field"
require_text "$WORK/settings/characters/baek-i-an.md" "Forbidden Drift" "I-an forbidden drift field"
require_text "$WORK/settings/characters/baek-i-an.md" "Active Knowledge Anchor: cannot identify the voice" "I-an active knowledge anchor"
require_text "$WORK/settings/world/archive-rules.md" "two living witnesses speak their legal names" "archive door rule"
require_text "$WORK/settings/world/archive-rules.md" "recorded voices cannot satisfy" "recorded voice limitation"
require_text "$WORK/settings/world/archive-rules.md" "World Rule:" "world rule field"
require_text "$WORK/settings/world/archive-rules.md" "Evidence Requirements:" "world rule evidence requirements"
require_text "$WORK/settings/world/archive-rules.md" "Active State Anchors:" "world rule active state anchors"
require_text "$WORK/settings/items/brass-witness-key.md" "brass witness key" "witness key item sheet"
require_text "$WORK/settings/items/brass-witness-key.md" "cannot open the sealed archive door alone" "witness key limitation"
require_text "$WORK/settings/items/brass-witness-key.md" "Active State Anchors:" "witness key active state anchors"
require_text "$WORK/settings/items/brass-witness-key.md" "Transfer Rules:" "witness key transfer rules"
require_text "$WORK/settings/items/brass-witness-key.md" "Continuity Risks:" "witness key continuity risks"
require_text "$WORK/settings/locations/lower-archive-corridor.md" "lower archive corridor" "lower archive location sheet"
require_text "$WORK/settings/locations/lower-archive-corridor.md" "sealed archive door" "lower archive sealed door reference"
require_text "$WORK/settings/locations/lower-archive-corridor.md" "Active Constraints:" "lower archive active constraints"
require_text "$WORK/settings/locations/lower-archive-corridor.md" "Active State Anchors:" "lower archive active state anchors"
require_text "$WORK/settings/locations/lower-archive-corridor.md" "Continuity Risks:" "lower archive continuity risks"

require_text "$WORK/series-bible.md" "Default prose baseline" "series bible style inheritance"
require_text "$WORK/series-bible.md" "Character Evolution Log" "series bible evolution log"
require_text "$WORK/series-bible.md" "right shoulder cannot bear weight" "series bible injury continuity"
require_text "$WORK/series-bible.md" "has never met Director Chae" "series bible knowledge continuity"

require_text "$WORK/volume-1/narrative-state.md" "Locked Prefix Summary" "narrative-state locked prefix"
require_text "$WORK/volume-1/narrative-state.md" "Location / World Canon References" "narrative-state location world references"
require_text "$WORK/volume-1/narrative-state.md" "settings/locations/lower-archive-corridor.md" "narrative-state location setting reference"
require_text "$WORK/volume-1/narrative-state.md" "Inventory Canon References" "narrative-state inventory canon references"
require_text "$WORK/volume-1/narrative-state.md" "settings/items/brass-witness-key.md" "narrative-state item setting reference"
require_text "$WORK/volume-1/narrative-state.md" "brass witness key in her left coat pocket" "narrative-state possession"
require_text "$WORK/volume-1/narrative-state.md" "right shoulder wounded; cannot bear weight" "narrative-state injury"
require_text "$WORK/volume-1/narrative-state.md" "cannot identify the voice" "narrative-state knowledge boundary"
require_text "$WORK/volume-1/narrative-state.md" "Seo-yun does not know who triggered the alarm" "narrative-state Seo-yun knowledge boundary"
require_text "$WORK/volume-1/narrative-state.md" "The door has not opened" "narrative-state world rule state"

require_text "$WORK/volume-1/drafts/chapter-01.md" "확인했습니다" "draft preserves Seo-yun habitual expression"
require_text "$WORK/volume-1/drafts/chapter-01.md" "왼손으로 코트 자락" "draft preserves left-hand/key continuity"
require_text "$WORK/volume-1/drafts/chapter-01.md" "오른쪽 어깨" "draft preserves injury continuity"
require_text "$WORK/volume-1/drafts/chapter-01.md" "이름을 말해야 한다는 규칙" "draft preserves archive door rule"
reject_text "$WORK/volume-1/drafts/chapter-01.md" "대박|누나" "forbidden voice drift"

require_text "$WORK/volume-1/expected-ledger-update.md" "Must Not Change Without Approved Retcon" "retcon guard section"
require_text "$WORK/volume-1/expected-ledger-update.md" "cannot open from the key alone" "ledger world-rule guard"

require_text "$WORK/volume-1/verification-manifest.md" "Final Otaku Verdict" "verification manifest verdict column"
require_text "$WORK/volume-1/verification-manifest.md" "Draft SHA256" "verification manifest draft hash column"
require_text "$WORK/volume-1/verification-manifest.md" "Canon Snapshot SHA256" "verification manifest canon hash column"
require_text "$WORK/volume-1/verification-manifest.md" "Style Drift Audit" "verification manifest style audit column"
require_text "$WORK/volume-1/verification-manifest.md" "Character Voice Audit" "verification manifest character voice audit column"
require_text "$WORK/volume-1/verification-manifest.md" "Verification Evidence" "verification manifest evidence column"
require_text "$WORK/volume-1/verification-manifest.md" '`drafts/chapter-01.md`' "verification manifest chapter entry"
require_text "$WORK/volume-1/verification-manifest.md" '`verification-reports/chapter-01.md`' "verification manifest evidence report entry"
require_text "$WORK/volume-1/verification-manifest.md" "PASS" "verification manifest pass status"
require_text "$WORK/volume-1/verification-manifest.md" "Ledger Update Summary" "verification manifest ledger summary"
require_text "$WORK/volume-1/verification-manifest.md" "Do not publish" "verification manifest publication gate"

require_text "$WORK/volume-1/verification-reports/chapter-01.md" "Draft Path: \`drafts/chapter-01.md\`" "verification evidence draft path"
require_text "$WORK/volume-1/verification-reports/chapter-01.md" "Draft SHA256: e177ff1d15e193e65745d2d239e1501a66e417e83d877245c72d7a99d21a5971" "verification evidence draft hash"
require_text "$WORK/volume-1/verification-reports/chapter-01.md" "Canon Snapshot SHA256: 90dc60dc3127ac7b1afd287309971a32ece5bffe89eb52fd9bd592b472fa76dd" "verification evidence canon hash"
require_text "$WORK/volume-1/verification-reports/chapter-01.md" "Final Otaku Verdict: PASS" "verification evidence otaku pass"
require_text "$WORK/volume-1/verification-reports/chapter-01.md" "Style Drift Audit: PASS" "verification evidence style pass"
require_text "$WORK/volume-1/verification-reports/chapter-01.md" "Character Voice Audit: PASS" "verification evidence voice pass"
require_text "$WORK/volume-1/verification-reports/chapter-01.md" "Approved Unknowns: None" "verification evidence approved unknowns"
require_text "$WORK/volume-1/verification-reports/chapter-01.md" "Physical Continuity: PASS" "verification evidence physical continuity"
require_text "$WORK/volume-1/verification-reports/chapter-01.md" "Possession / Inventory Continuity: PASS" "verification evidence possession continuity"
require_text "$WORK/volume-1/verification-reports/chapter-01.md" "Knowledge Boundary Continuity: PASS" "verification evidence knowledge continuity"
require_text "$WORK/volume-1/verification-reports/chapter-01.md" "Location / World Rule Continuity: PASS" "verification evidence location world continuity"
require_text "$WORK/volume-1/verification-reports/chapter-01.md" "Style Contract Match: PASS" "verification evidence style contract"
require_text "$WORK/volume-1/verification-reports/chapter-01.md" "Character Voice Matrix Match: PASS" "verification evidence voice matrix"
require_text "$WORK/volume-1/verification-reports/chapter-01.md" "## Evidence Anchors" "verification evidence anchors section"
require_text "$WORK/volume-1/verification-reports/chapter-01.md" "| Physical Continuity | \`drafts/chapter-01.md\` | 오른쪽 어깨 |" "verification evidence physical anchor"
require_text "$WORK/volume-1/verification-reports/chapter-01.md" "| Knowledge Boundary Continuity | \`narrative-state.md\` | cannot identify the voice |" "verification evidence knowledge anchor"
require_text "$WORK/volume-1/verification-reports/chapter-01.md" "| Location / World Rule Continuity | \`settings/world/archive-rules.md\` | two living witnesses speak their legal names |" "verification evidence world rule anchor"
require_text "$WORK/volume-1/verification-reports/chapter-01.md" "| Timeline Continuity | \`narrative-state.md\` | 02:10 before dawn |" "verification evidence timeline anchor"
require_text "$WORK/volume-1/verification-reports/chapter-01.md" "| POV, Diction, and Rhythm Match | \`settings/style-guide.md\` | Han Seo-yun's perceptions, knowledge, and pressure lead the scene |" "verification evidence POV diction rhythm anchor"
require_text "$WORK/volume-1/verification-reports/chapter-01.md" "| Character Voice Matrix Match | \`settings/style-guide.md\` | 확인했습니다 |" "verification evidence voice matrix anchor"
require_text "$WORK/volume-1/verification-reports/chapter-01.md" "| Character Evolution Justification | \`series-bible.md\` | right shoulder cannot bear weight |" "verification evidence character evolution anchor"
require_text "$WORK/volume-1/verification-reports/chapter-01.md" "## Ledger Update Anchors" "verification evidence ledger update anchors section"
require_text "$WORK/volume-1/verification-reports/chapter-01.md" "| Character Physical State | right shoulder injury | right shoulder wounded; cannot bear weight |" "verification evidence physical ledger anchor"
require_text "$WORK/volume-1/verification-reports/chapter-01.md" "| Inventory State | key in left coat pocket | brass witness key in left coat pocket |" "verification evidence inventory ledger anchor"
require_text "$WORK/volume-1/verification-reports/chapter-01.md" "| Location / World State | unopened door | The door has not opened |" "verification evidence world ledger anchor"

scripts/validate-verification-manifest.sh "$WORK/volume-1"

printf 'sample work fixture ok\n'
