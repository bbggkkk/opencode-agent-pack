#!/bin/sh
set -eu

fail() {
    printf 'FAIL: %s\n' "$1" >&2
    exit 1
}

expect_fail() {
    label="$1"
    work="$2"
    if scripts/validate-production-artifacts.sh "$work" volume-1 >/tmp/opencode-novelist-artifact-negative.log 2>&1; then
        cat /tmp/opencode-novelist-artifact-negative.log >&2
        fail "$label unexpectedly passed"
    fi
}

copy_fixture() {
    dest="$1"
    mkdir -p "$dest"
    cp -R examples/sample-work/. "$dest/"
}

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT INT TERM

style_placeholder="$tmp/style-placeholder"
copy_fixture "$style_placeholder"
sed 's/Sentence rhythm: measured medium-length sentences with short turns at moments of threat./Sentence rhythm: TBD/' "$style_placeholder/settings/style-guide.md" > "$style_placeholder/settings/style-guide.tmp"
mv "$style_placeholder/settings/style-guide.tmp" "$style_placeholder/settings/style-guide.md"
expect_fail "style placeholder" "$style_placeholder"

missing_forbidden_style="$tmp/missing-forbidden-style"
copy_fixture "$missing_forbidden_style"
awk '/^- Forbidden Style Drift:/ { next } { print }' "$missing_forbidden_style/settings/style-guide.md" > "$missing_forbidden_style/settings/style-guide.tmp"
mv "$missing_forbidden_style/settings/style-guide.tmp" "$missing_forbidden_style/settings/style-guide.md"
expect_fail "missing forbidden style drift" "$missing_forbidden_style"

missing_forbidden_literal="$tmp/missing-forbidden-literal"
copy_fixture "$missing_forbidden_literal"
awk '/^- Forbidden Literal Phrases:/ { next } { print }' "$missing_forbidden_literal/settings/style-guide.md" > "$missing_forbidden_literal/settings/style-guide.tmp"
mv "$missing_forbidden_literal/settings/style-guide.tmp" "$missing_forbidden_literal/settings/style-guide.md"
expect_fail "missing forbidden literal phrases" "$missing_forbidden_literal"

missing_style_questions="$tmp/missing-style-questions"
copy_fixture "$missing_style_questions"
awk '/^- Style Verification Questions:/ { next } { print }' "$missing_style_questions/settings/style-guide.md" > "$missing_style_questions/settings/style-guide.tmp"
mv "$missing_style_questions/settings/style-guide.tmp" "$missing_style_questions/settings/style-guide.md"
expect_fail "missing style verification questions" "$missing_style_questions"

missing_head_hopping_rule="$tmp/missing-head-hopping-rule"
copy_fixture "$missing_head_hopping_rule"
awk '/^- Head-hopping rule:/ { next } { print }' "$missing_head_hopping_rule/settings/style-guide.md" > "$missing_head_hopping_rule/settings/style-guide.tmp"
mv "$missing_head_hopping_rule/settings/style-guide.tmp" "$missing_head_hopping_rule/settings/style-guide.md"
expect_fail "missing head-hopping rule" "$missing_head_hopping_rule"

blank_voice="$tmp/blank-voice"
copy_fixture "$blank_voice"
sed 's/- Speech: formal under pressure; clipped sentences; no slang./- Speech:/' "$blank_voice/settings/characters/han-seo-yun.md" > "$blank_voice/settings/characters/han-seo-yun.tmp"
mv "$blank_voice/settings/characters/han-seo-yun.tmp" "$blank_voice/settings/characters/han-seo-yun.md"
expect_fail "blank character speech" "$blank_voice"

missing_character_locks="$tmp/missing-character-locks"
copy_fixture "$missing_character_locks"
awk '/^- Knowledge Boundaries:/ { next } { print }' "$missing_character_locks/settings/characters/baek-i-an.md" > "$missing_character_locks/settings/characters/baek-i-an.tmp"
mv "$missing_character_locks/settings/characters/baek-i-an.tmp" "$missing_character_locks/settings/characters/baek-i-an.md"
expect_fail "missing character knowledge boundaries" "$missing_character_locks"

missing_forbidden_drift="$tmp/missing-forbidden-drift"
copy_fixture "$missing_forbidden_drift"
awk '/^- Forbidden Drift:/ { next } { print }' "$missing_forbidden_drift/settings/characters/han-seo-yun.md" > "$missing_forbidden_drift/settings/characters/han-seo-yun.tmp"
mv "$missing_forbidden_drift/settings/characters/han-seo-yun.tmp" "$missing_forbidden_drift/settings/characters/han-seo-yun.md"
expect_fail "missing character forbidden drift" "$missing_forbidden_drift"

missing_character_state_anchor="$tmp/missing-character-state-anchor"
copy_fixture "$missing_character_state_anchor"
awk '/^- Active Physical Anchor:/ { next } { print }' "$missing_character_state_anchor/settings/characters/han-seo-yun.md" > "$missing_character_state_anchor/settings/characters/han-seo-yun.tmp"
mv "$missing_character_state_anchor/settings/characters/han-seo-yun.tmp" "$missing_character_state_anchor/settings/characters/han-seo-yun.md"
expect_fail "missing character active physical anchor" "$missing_character_state_anchor"

broken_character_state_anchor="$tmp/broken-character-state-anchor"
copy_fixture "$broken_character_state_anchor"
sed 's/right shoulder wounded; cannot bear weight/right shoulder healed; can force doors/' "$broken_character_state_anchor/volume-1/narrative-state.md" > "$broken_character_state_anchor/volume-1/narrative-state.tmp"
mv "$broken_character_state_anchor/volume-1/narrative-state.tmp" "$broken_character_state_anchor/volume-1/narrative-state.md"
expect_fail "character active physical anchor not found" "$broken_character_state_anchor"

state_placeholder="$tmp/state-placeholder"
copy_fixture "$state_placeholder"
sed 's/Current beat: deciding whether to speak legal names at the sealed door./Current beat: TBD/' "$state_placeholder/volume-1/narrative-state.md" > "$state_placeholder/volume-1/narrative-state.tmp"
mv "$state_placeholder/volume-1/narrative-state.tmp" "$state_placeholder/volume-1/narrative-state.md"
expect_fail "narrative state placeholder" "$state_placeholder"

missing_character="$tmp/missing-character"
copy_fixture "$missing_character"
rm -f "$missing_character/settings/characters/"*.md
expect_fail "missing character files" "$missing_character"

missing_voice_row="$tmp/missing-voice-row"
copy_fixture "$missing_voice_row"
awk '/Baek I-an/ { next } { print }' "$missing_voice_row/settings/style-guide.md" > "$missing_voice_row/settings/style-guide.tmp"
mv "$missing_voice_row/settings/style-guide.tmp" "$missing_voice_row/settings/style-guide.md"
expect_fail "active character missing voice matrix row" "$missing_voice_row"

voice_sheet_mismatch="$tmp/voice-sheet-mismatch"
copy_fixture "$voice_sheet_mismatch"
sed 's/never calls Seo-yun "누나"/never calls Seo-yun "형님"/' "$voice_sheet_mismatch/settings/style-guide.md" > "$voice_sheet_mismatch/settings/style-guide.tmp"
mv "$voice_sheet_mismatch/settings/style-guide.tmp" "$voice_sheet_mismatch/settings/style-guide.md"
expect_fail "character taboo expression from voice matrix" "$voice_sheet_mismatch"

voice_schema_drift="$tmp/voice-schema-drift"
copy_fixture "$voice_schema_drift"
sed 's/| Character | Register | Vocabulary Limits | Habitual Expressions | Taboo Expressions | Silence Pattern | Emotional Tells |/| Character | Vocabulary Limits | Register | Habitual Expressions | Taboo Expressions | Silence Pattern | Emotional Tells |/' "$voice_schema_drift/settings/style-guide.md" > "$voice_schema_drift/settings/style-guide.tmp"
mv "$voice_schema_drift/settings/style-guide.tmp" "$voice_schema_drift/settings/style-guide.md"
expect_fail "style-guide voice matrix schema drift" "$voice_schema_drift"

chronology_schema_drift="$tmp/chronology-schema-drift"
copy_fixture "$chronology_schema_drift"
sed 's/| Order | Date \/ Time | Event | Source | Evidence Phrase |/| Order | Event | Date \/ Time | Source | Evidence Phrase |/' "$chronology_schema_drift/series-bible.md" > "$chronology_schema_drift/series-bible.tmp"
mv "$chronology_schema_drift/series-bible.tmp" "$chronology_schema_drift/series-bible.md"
expect_fail "series bible chronology schema drift" "$chronology_schema_drift"

missing_chronology_source="$tmp/missing-chronology-source"
copy_fixture "$missing_chronology_source"
sed 's/`volume-1\/drafts\/chapter-01.md`/`volume-1\/drafts\/missing-source.md`/' "$missing_chronology_source/series-bible.md" > "$missing_chronology_source/series-bible.tmp"
mv "$missing_chronology_source/series-bible.tmp" "$missing_chronology_source/series-bible.md"
expect_fail "series bible chronology source file missing" "$missing_chronology_source"

missing_chronology_evidence="$tmp/missing-chronology-evidence"
copy_fixture "$missing_chronology_evidence"
sed 's/| 계단 위에서 경보가 울렸다 |/| |/' "$missing_chronology_evidence/series-bible.md" > "$missing_chronology_evidence/series-bible.tmp"
mv "$missing_chronology_evidence/series-bible.tmp" "$missing_chronology_evidence/series-bible.md"
expect_fail "series bible chronology evidence phrase missing" "$missing_chronology_evidence"

bad_chronology_evidence="$tmp/bad-chronology-evidence"
copy_fixture "$bad_chronology_evidence"
sed 's/계단 위에서 경보가 울렸다/없는 근거 문구/' "$bad_chronology_evidence/series-bible.md" > "$bad_chronology_evidence/series-bible.tmp"
mv "$bad_chronology_evidence/series-bible.tmp" "$bad_chronology_evidence/series-bible.md"
expect_fail "series bible chronology evidence phrase not found" "$bad_chronology_evidence"

evolution_schema_drift="$tmp/evolution-schema-drift"
copy_fixture "$evolution_schema_drift"
sed 's/| Volume | Character | Age \/ Status | Injuries | Relationship Changes | Notes |/| Volume | Age \/ Status | Character | Injuries | Relationship Changes | Notes |/' "$evolution_schema_drift/series-bible.md" > "$evolution_schema_drift/series-bible.tmp"
mv "$evolution_schema_drift/series-bible.tmp" "$evolution_schema_drift/series-bible.md"
expect_fail "series bible evolution schema drift" "$evolution_schema_drift"

orphan_evolution_character="$tmp/orphan-evolution-character"
copy_fixture "$orphan_evolution_character"
sed 's/| 1 | Baek I-an | active second witness |/| 1 | Choi Min | active second witness |/' "$orphan_evolution_character/series-bible.md" > "$orphan_evolution_character/series-bible.tmp"
mv "$orphan_evolution_character/series-bible.tmp" "$orphan_evolution_character/series-bible.md"
expect_fail "series bible evolution character missing character sheet" "$orphan_evolution_character"

orphan_state_character="$tmp/orphan-state-character"
copy_fixture "$orphan_state_character"
sed 's/Baek I-an | lower archive corridor/Choi Min | lower archive corridor/' "$orphan_state_character/volume-1/narrative-state.md" > "$orphan_state_character/volume-1/narrative-state.tmp"
mv "$orphan_state_character/volume-1/narrative-state.tmp" "$orphan_state_character/volume-1/narrative-state.md"
expect_fail "active character missing character sheet" "$orphan_state_character"

missing_inventory_ref="$tmp/missing-inventory-ref"
copy_fixture "$missing_inventory_ref"
awk '
    /Inventory Canon References/ { skip = 1; next }
    skip && /Timeline/ { skip = 0 }
    !skip { print }
' "$missing_inventory_ref/volume-1/narrative-state.md" > "$missing_inventory_ref/volume-1/narrative-state.tmp"
mv "$missing_inventory_ref/volume-1/narrative-state.tmp" "$missing_inventory_ref/volume-1/narrative-state.md"
expect_fail "missing inventory canon references" "$missing_inventory_ref"

missing_item_file="$tmp/missing-item-file"
copy_fixture "$missing_item_file"
rm -f "$missing_item_file/settings/items/brass-witness-key.md"
expect_fail "inventory canon reference setting file missing" "$missing_item_file"

missing_item_limitations="$tmp/missing-item-limitations"
copy_fixture "$missing_item_limitations"
awk '/^- Limitations:/ { next } { print }' "$missing_item_limitations/settings/items/brass-witness-key.md" > "$missing_item_limitations/settings/items/brass-witness-key.tmp"
mv "$missing_item_limitations/settings/items/brass-witness-key.tmp" "$missing_item_limitations/settings/items/brass-witness-key.md"
expect_fail "inventory item limitations missing" "$missing_item_limitations"

item_holder_mismatch="$tmp/item-holder-mismatch"
copy_fixture "$item_holder_mismatch"
sed 's/- Current Holder: Han Seo-yun, carried in her left coat pocket unless explicitly moved on-page./- Current Holder: Baek I-an, carried in his tool roll unless explicitly moved on-page./' "$item_holder_mismatch/settings/items/brass-witness-key.md" > "$item_holder_mismatch/settings/items/brass-witness-key.tmp"
mv "$item_holder_mismatch/settings/items/brass-witness-key.tmp" "$item_holder_mismatch/settings/items/brass-witness-key.md"
expect_fail "inventory item current holder value" "$item_holder_mismatch"

inactive_item_holder="$tmp/inactive-item-holder"
copy_fixture "$inactive_item_holder"
sed 's/| brass witness key | Han Seo-yun |/| brass witness key | Director Chae |/' "$inactive_item_holder/volume-1/narrative-state.md" > "$inactive_item_holder/volume-1/narrative-state.tmp"
mv "$inactive_item_holder/volume-1/narrative-state.tmp" "$inactive_item_holder/volume-1/narrative-state.md"
expect_fail "inventory canon reference inactive holder" "$inactive_item_holder"

missing_world_refs="$tmp/missing-world-refs"
copy_fixture "$missing_world_refs"
awk '
    /Location \/ World Canon References/ { skip = 1; next }
    skip && /Locked Prefix Summary/ { skip = 0 }
    !skip { print }
' "$missing_world_refs/volume-1/narrative-state.md" > "$missing_world_refs/volume-1/narrative-state.tmp"
mv "$missing_world_refs/volume-1/narrative-state.tmp" "$missing_world_refs/volume-1/narrative-state.md"
expect_fail "missing location world canon references" "$missing_world_refs"

missing_location_file="$tmp/missing-location-file"
copy_fixture "$missing_location_file"
rm -f "$missing_location_file/settings/locations/lower-archive-corridor.md"
expect_fail "location world canon reference setting file missing" "$missing_location_file"

missing_location_constraints="$tmp/missing-location-constraints"
copy_fixture "$missing_location_constraints"
awk '/^- Active Constraints:/ { next } { print }' "$missing_location_constraints/settings/locations/lower-archive-corridor.md" > "$missing_location_constraints/settings/locations/lower-archive-corridor.tmp"
mv "$missing_location_constraints/settings/locations/lower-archive-corridor.tmp" "$missing_location_constraints/settings/locations/lower-archive-corridor.md"
expect_fail "location active constraints missing" "$missing_location_constraints"

missing_location_state_anchor="$tmp/missing-location-state-anchor"
copy_fixture "$missing_location_state_anchor"
awk '/^- Active State Anchors:/ { next } { print }' "$missing_location_state_anchor/settings/locations/lower-archive-corridor.md" > "$missing_location_state_anchor/settings/locations/lower-archive-corridor.tmp"
mv "$missing_location_state_anchor/settings/locations/lower-archive-corridor.tmp" "$missing_location_state_anchor/settings/locations/lower-archive-corridor.md"
expect_fail "location active state anchors missing" "$missing_location_state_anchor"

missing_world_rule="$tmp/missing-world-rule"
copy_fixture "$missing_world_rule"
awk '/^- World Rule:/ { next } { print }' "$missing_world_rule/settings/world/archive-rules.md" > "$missing_world_rule/settings/world/archive-rules.tmp"
mv "$missing_world_rule/settings/world/archive-rules.tmp" "$missing_world_rule/settings/world/archive-rules.md"
expect_fail "world rule statement missing" "$missing_world_rule"

broken_world_state_anchor="$tmp/broken-world-state-anchor"
copy_fixture "$broken_world_state_anchor"
sed 's/recorded voices cannot satisfy the witness requirement/recorded voices can satisfy the witness requirement/' "$broken_world_state_anchor/volume-1/narrative-state.md" > "$broken_world_state_anchor/volume-1/narrative-state.tmp"
mv "$broken_world_state_anchor/volume-1/narrative-state.tmp" "$broken_world_state_anchor/volume-1/narrative-state.md"
expect_fail "world rule active state anchors not found" "$broken_world_state_anchor"

blank_world_constraint="$tmp/blank-world-constraint"
copy_fixture "$blank_world_constraint"
awk '
    /sealed archive door/ && /settings\/world\/archive-rules.md/ {
        print "| sealed archive door | `settings/world/archive-rules.md` | |"
        next
    }
    { print }
' "$blank_world_constraint/volume-1/narrative-state.md" > "$blank_world_constraint/volume-1/narrative-state.tmp"
mv "$blank_world_constraint/volume-1/narrative-state.tmp" "$blank_world_constraint/volume-1/narrative-state.md"
expect_fail "location world canon reference missing active constraint" "$blank_world_constraint"

world_schema_drift="$tmp/world-schema-drift"
copy_fixture "$world_schema_drift"
sed 's/| Canon Topic | Setting File | Active Constraint |/| Setting File | Canon Topic | Active Constraint |/' "$world_schema_drift/volume-1/narrative-state.md" > "$world_schema_drift/volume-1/narrative-state.tmp"
mv "$world_schema_drift/volume-1/narrative-state.tmp" "$world_schema_drift/volume-1/narrative-state.md"
expect_fail "location world reference schema drift" "$world_schema_drift"

character_state_schema_drift="$tmp/character-state-schema-drift"
copy_fixture "$character_state_schema_drift"
sed 's/| Character | Location | Physical State \/ Injuries | Emotional State | Inventory | Relationship Deltas |/| Character | Inventory | Location | Physical State \/ Injuries | Emotional State | Relationship Deltas |/' "$character_state_schema_drift/volume-1/narrative-state.md" > "$character_state_schema_drift/volume-1/narrative-state.tmp"
mv "$character_state_schema_drift/volume-1/narrative-state.tmp" "$character_state_schema_drift/volume-1/narrative-state.md"
expect_fail "character state schema drift" "$character_state_schema_drift"

inventory_schema_drift="$tmp/inventory-schema-drift"
copy_fixture "$inventory_schema_drift"
sed 's/| Item \/ Possession | Current Holder | Setting File | Current State |/| Item \/ Possession | Setting File | Current Holder | Current State |/' "$inventory_schema_drift/volume-1/narrative-state.md" > "$inventory_schema_drift/volume-1/narrative-state.tmp"
mv "$inventory_schema_drift/volume-1/narrative-state.tmp" "$inventory_schema_drift/volume-1/narrative-state.md"
expect_fail "inventory reference schema drift" "$inventory_schema_drift"

printf 'production artifact negative tests ok\n'
