#!/bin/sh
set -eu

WORK="${1:-examples/sample-work}"
VOLUME="${2:-volume-1}"
VOLUME_PATH="$WORK/$VOLUME"

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

reject_pattern() {
    file="$1"
    pattern="$2"
    label="$3"
    if grep -Eq -- "$pattern" "$file"; then
        fail "$label found in $file"
    fi
}

check_state_anchors() {
    source_file="$1"
    label="$2"
    target_file="$3"
    failure_label="$4"
    anchors_tmp="$(mktemp)"
    awk -F':' -v wanted="$label" '
        index($0, "- " wanted ":") == 1 {
            text = $2
            for (i = 3; i <= NF; i++) {
                text = text ":" $i
            }
            n = split(text, parts, ";")
            for (i = 1; i <= n; i++) {
                anchor = parts[i]
                gsub(/^[ \t.]+|[ \t.]+$/, "", anchor)
                if (anchor != "") {
                    print anchor
                }
            }
        }
    ' "$source_file" > "$anchors_tmp"
    [ -s "$anchors_tmp" ] || {
        rm -f "$anchors_tmp"
        fail "$failure_label missing in $source_file"
    }
    while IFS= read -r anchor; do
        [ -n "$anchor" ] || continue
        [ "$anchor" != "TBD" ] || {
            rm -f "$anchors_tmp"
            fail "$failure_label placeholder in $source_file"
        }
        grep -Fq -- "$anchor" "$target_file" || {
            rm -f "$anchors_tmp"
            fail "$failure_label not found in narrative-state: $anchor"
        }
    done < "$anchors_tmp"
    rm -f "$anchors_tmp"
}

STYLE="$WORK/settings/style-guide.md"
BIBLE="$WORK/series-bible.md"
STATE="$VOLUME_PATH/narrative-state.md"
MANIFEST="$VOLUME_PATH/verification-manifest.md"
item_refs_tmp="$(mktemp)"
world_refs_tmp="$(mktemp)"
evolution_names_tmp="$(mktemp)"
chronology_refs_tmp="$(mktemp)"

require_file "$STYLE"
require_file "$BIBLE"
require_file "$STATE"
require_file "$MANIFEST"

reject_pattern "$STYLE" '(^|[|[:space:]])TBD([|[:space:]]|$)' "style-guide placeholder"
reject_pattern "$BIBLE" '(^|[|[:space:]])TBD([|[:space:]]|$)' "series-bible placeholder"
reject_pattern "$STATE" '(^|[|[:space:]])TBD([|[:space:]]|$)' "narrative-state placeholder"
reject_pattern "$STYLE" '^- [^:]+:[[:space:]]*$' "blank style-guide field"
reject_pattern "$BIBLE" '^- [^:]+:[[:space:]]*$' "blank series-bible field"
reject_pattern "$STATE" '^- [^:]+:[[:space:]]*$' "blank narrative-state field"

require_text "$STYLE" "Prose baseline: elegant, controlled, and assured literary prose by a renowned, seasoned professional novelist" "default prose baseline"
require_text "$STYLE" "Language:" "style language"
require_text "$STYLE" "Cultural background:" "style cultural background"
require_text "$STYLE" "Sentence rhythm:" "style sentence rhythm"
require_text "$STYLE" "Diction:" "style diction"
require_text "$STYLE" "Metaphor density:" "style metaphor density"
require_text "$STYLE" "POV distance:" "style POV distance"
require_text "$STYLE" "POV person:" "style POV person"
require_text "$STYLE" "Tense:" "style tense"
require_text "$STYLE" "Viewpoint anchor:" "style viewpoint anchor"
require_text "$STYLE" "Head-hopping rule:" "style head-hopping rule"
require_text "$STYLE" "Dialogue texture:" "style dialogue texture"
require_text "$STYLE" "Required Style Anchors:" "required style anchors"
require_text "$STYLE" "Forbidden Style Drift:" "forbidden style drift"
require_text "$STYLE" "Forbidden Literal Phrases:" "forbidden literal phrases"
require_text "$STYLE" "Style Verification Questions:" "style verification questions"
require_text "$STYLE" "Revision Guardrails:" "style revision guardrails"
require_text "$STYLE" "Character Voice Matrix" "character voice matrix"

VOICE_HEADER='| Character | Register | Vocabulary Limits | Habitual Expressions | Taboo Expressions | Silence Pattern | Emotional Tells |'
VOICE_SEPARATOR='|-----------|----------|-------------------|----------------------|-------------------|-----------------|-----------------|'
WORLD_HEADER='| Canon Topic | Setting File | Active Constraint |'
WORLD_SEPARATOR='|-------------|--------------|-------------------|'
STATE_CHARACTER_HEADER='| Character | Location | Physical State / Injuries | Emotional State | Inventory | Relationship Deltas |'
STATE_CHARACTER_SEPARATOR='|-----------|----------|---------------------------|-----------------|-----------|---------------------|'
INVENTORY_HEADER='| Item / Possession | Current Holder | Setting File | Current State |'
INVENTORY_SEPARATOR='|-------------------|----------------|--------------|---------------|'
CHRONOLOGY_HEADER='| Order | Date / Time | Event | Source | Evidence Phrase |'
CHRONOLOGY_SEPARATOR='|-------|-------------|-------|--------|-----------------|'
EVOLUTION_HEADER='| Volume | Character | Age / Status | Injuries | Relationship Changes | Notes |'
EVOLUTION_SEPARATOR='|--------|-----------|--------------|----------|----------------------|-------|'

grep -Fxq -- "$VOICE_HEADER" "$STYLE" || fail "style-guide Character Voice Matrix header does not match expected schema"
grep -Fxq -- "$VOICE_SEPARATOR" "$STYLE" || fail "style-guide Character Voice Matrix separator does not match expected schema"

voice_rows="$(awk '
    BEGIN { count = 0 }
    /^\|/ && $0 !~ /Character \| Register/ && $0 !~ /^\|[- ]+\|/ {
        if ($0 !~ /TBD/ && $0 ~ /\|[^|]+[[:space:]]\|[^|]+[[:space:]]\|[^|]+[[:space:]]\|[^|]+[[:space:]]\|[^|]+[[:space:]]\|[^|]+[[:space:]]\|[^|]+[[:space:]]\|/) {
            count++
        }
    }
    END { print count }
' "$STYLE")"
[ "$voice_rows" -ge 1 ] || fail "character voice matrix has no completed character rows"

voice_names_tmp="$(mktemp)"
state_names_tmp="$(mktemp)"
character_names_tmp="$(mktemp)"
trap 'rm -f "$voice_names_tmp" "$state_names_tmp" "$character_names_tmp" "$item_refs_tmp" "$world_refs_tmp" "$evolution_names_tmp" "$chronology_refs_tmp"' EXIT INT TERM

awk -F'|' '
    /^\|/ && $0 !~ /Character \| Register/ && $0 !~ /^\|[- ]+\|/ {
        name = $2
        gsub(/^[ \t]+|[ \t]+$/, "", name)
        if (name != "" && name != "TBD") {
            print name
        }
    }
' "$STYLE" | sort -u > "$voice_names_tmp"

[ -d "$WORK/settings/characters" ] || fail "missing character settings directory: $WORK/settings/characters"
character_count=0
for character_file in "$WORK/settings/characters"/*.md; do
    [ -e "$character_file" ] || continue
    character_count=$((character_count + 1))
    reject_pattern "$character_file" '(^|[|[:space:]])TBD([|[:space:]]|$)' "character placeholder"
    reject_pattern "$character_file" '^- [^:]+:[[:space:]]*$' "blank character field"
    require_text "$character_file" "Name:" "character name"
    require_text "$character_file" "Role:" "character role"
    require_text "$character_file" "Core Traits:" "character core traits"
    require_text "$character_file" "Personality:" "character personality"
    require_text "$character_file" "Physical Continuity:" "character physical continuity"
    require_text "$character_file" "Possessions:" "character possessions"
    require_text "$character_file" "Knowledge Boundaries:" "character knowledge boundaries"
    require_text "$character_file" "Active Physical Anchor:" "character active physical anchor"
    require_text "$character_file" "Active Inventory Anchor:" "character active inventory anchor"
    require_text "$character_file" "Active Knowledge Anchor:" "character active knowledge anchor"
    require_text "$character_file" "Voice Rules:" "character voice rules"
    require_text "$character_file" "Speech:" "character speech"
    require_text "$character_file" "Forbidden Drift:" "character forbidden drift"
    require_text "$character_file" "Emotional Tells:" "character emotional tells"
    require_text "$character_file" "Allowed Evolution:" "character allowed evolution"
    character_name="$(awk -F':' '/^- Name:/ {
        name = $2
        gsub(/^[ \t]+|[ \t.]+$/, "", name)
        if (name != "") {
            print name
        }
    }' "$character_file")"
    [ -n "$character_name" ] || fail "character sheet has no usable Name value: $character_file"
    printf '%s\n' "$character_name" >> "$character_names_tmp"
    voice_line="$(awk -F'|' -v wanted="$character_name" '
        /^\|/ && $0 !~ /Character \| Register/ && $0 !~ /^\|[- ]+\|/ {
            name = $2
            gsub(/^[ \t]+|[ \t]+$/, "", name)
            if (name == wanted) {
                print
            }
        }
    ' "$STYLE")"
    [ -n "$voice_line" ] || fail "character sheet missing from Character Voice Matrix: $character_name"
    habitual_quote="$(printf '%s\n' "$voice_line" | awk -F'|' '{
        field = $5
        if (match(field, /"[^"]+"/)) {
            print substr(field, RSTART + 1, RLENGTH - 2)
        }
    }')"
    taboo_quote="$(printf '%s\n' "$voice_line" | awk -F'|' '{
        field = $6
        if (match(field, /"[^"]+"/)) {
            print substr(field, RSTART + 1, RLENGTH - 2)
        }
    }')"
    if [ -n "$habitual_quote" ]; then
        require_text "$character_file" "$habitual_quote" "character habitual expression from voice matrix"
    fi
    if [ -n "$taboo_quote" ]; then
        require_text "$character_file" "$taboo_quote" "character taboo expression from voice matrix"
    fi
done
[ "$character_count" -ge 1 ] || fail "no character setting files found"
sort -u "$character_names_tmp" -o "$character_names_tmp"

require_text "$BIBLE" "Canon Priority Notes" "canon priority notes"
require_text "$BIBLE" "Chronology" "chronology"
require_text "$BIBLE" "Character Evolution Log" "character evolution log"
require_text "$BIBLE" "Unresolved Plot Threads" "unresolved plot threads"

grep -Fxq -- "$CHRONOLOGY_HEADER" "$BIBLE" || fail "series-bible Chronology header does not match expected schema"
grep -Fxq -- "$CHRONOLOGY_SEPARATOR" "$BIBLE" || fail "series-bible Chronology separator does not match expected schema"
grep -Fxq -- "$EVOLUTION_HEADER" "$BIBLE" || fail "series-bible Character Evolution Log header does not match expected schema"
grep -Fxq -- "$EVOLUTION_SEPARATOR" "$BIBLE" || fail "series-bible Character Evolution Log separator does not match expected schema"

awk -F'|' '
    /^## Chronology/ { in_section = 1; next }
    /^## / && in_section { in_section = 0 }
    in_section && /^\|/ && $0 !~ /Order \| Date \/ Time/ && $0 !~ /^\|[- ]+\|/ {
        source = $5
        evidence = $6
        gsub(/^[ \t`]+|[ \t`]+$/, "", source)
        gsub(/^[ \t]+|[ \t]+$/, "", evidence)
        if (source != "" && source != "TBD") {
            print source "|" evidence
        }
    }
' "$BIBLE" | sort -u > "$chronology_refs_tmp"

[ -s "$chronology_refs_tmp" ] || fail "series-bible Chronology has no completed source rows"

while IFS='|' read -r source_file evidence_phrase; do
    [ -n "$source_file" ] || continue
    [ -s "$WORK/$source_file" ] || fail "series-bible Chronology source file missing: $source_file"
    [ -n "$evidence_phrase" ] || fail "series-bible Chronology evidence phrase missing for source: $source_file"
    [ "$evidence_phrase" != "TBD" ] || fail "series-bible Chronology evidence phrase placeholder for source: $source_file"
    grep -Fq -- "$evidence_phrase" "$WORK/$source_file" || fail "series-bible Chronology evidence phrase not found in source: $source_file"
done < "$chronology_refs_tmp"

awk -F'|' '
    /^## Character Evolution Log/ { in_section = 1; next }
    /^## / && in_section { in_section = 0 }
    in_section && /^\|/ && $0 !~ /Volume \| Character/ && $0 !~ /^\|[- ]+\|/ {
        character = $3
        gsub(/^[ \t]+|[ \t]+$/, "", character)
        if (character != "" && character != "TBD") {
            print character
        }
    }
' "$BIBLE" | sort -u > "$evolution_names_tmp"

[ -s "$evolution_names_tmp" ] || fail "series-bible Character Evolution Log has no completed character rows"

require_text "$STATE" "Locked Prefix Summary" "locked prefix summary"
require_text "$STATE" "Character State" "character state"
require_text "$STATE" "Inventory Canon References" "inventory canon references"
require_text "$STATE" "Location / World Canon References" "location and world canon references"
require_text "$STATE" "Timeline" "timeline"
require_text "$STATE" "Open Hooks" "open hooks"

grep -Fxq -- "$WORLD_HEADER" "$STATE" || fail "narrative-state Location / World Canon References header does not match expected schema"
grep -Fxq -- "$WORLD_SEPARATOR" "$STATE" || fail "narrative-state Location / World Canon References separator does not match expected schema"
grep -Fxq -- "$STATE_CHARACTER_HEADER" "$STATE" || fail "narrative-state Character State header does not match expected schema"
grep -Fxq -- "$STATE_CHARACTER_SEPARATOR" "$STATE" || fail "narrative-state Character State separator does not match expected schema"
grep -Fxq -- "$INVENTORY_HEADER" "$STATE" || fail "narrative-state Inventory Canon References header does not match expected schema"
grep -Fxq -- "$INVENTORY_SEPARATOR" "$STATE" || fail "narrative-state Inventory Canon References separator does not match expected schema"

awk -F'|' '
    /^## Location \/ World Canon References/ { in_section = 1; next }
    /^## / && in_section { in_section = 0 }
    in_section && /^\|/ && $0 !~ /Canon Topic \| Setting File/ && $0 !~ /^\|[- ]+\|/ {
        topic = $2
        file = $3
        constraint = $4
        gsub(/^[ \t]+|[ \t]+$/, "", topic)
        gsub(/^[ \t`]+|[ \t`]+$/, "", file)
        gsub(/^[ \t]+|[ \t]+$/, "", constraint)
        if (topic != "" && topic != "TBD") {
            print topic "|" file "|" constraint
        }
    }
' "$STATE" > "$world_refs_tmp"

[ -s "$world_refs_tmp" ] || fail "Location / World Canon References has no completed rows"

while IFS='|' read -r topic setting_file constraint; do
    [ -n "$topic" ] || continue
    [ -n "$setting_file" ] || fail "location/world canon reference missing setting file: $topic"
    [ -n "$constraint" ] || fail "location/world canon reference missing active constraint: $topic"
    [ -s "$WORK/$setting_file" ] || fail "location/world canon reference setting file missing: $setting_file"
    case "$setting_file" in
        settings/locations/*.md)
            require_text "$WORK/$setting_file" "Name:" "location name"
            require_text "$WORK/$setting_file" "Type:" "location type"
            require_text "$WORK/$setting_file" "Current Access State:" "location current access state"
            require_text "$WORK/$setting_file" "Key Features:" "location key features"
            require_text "$WORK/$setting_file" "Active Constraints:" "location active constraints"
            require_text "$WORK/$setting_file" "Active State Anchors:" "location active state anchors"
            check_state_anchors "$WORK/$setting_file" "Active State Anchors" "$STATE" "location active state anchors"
            require_text "$WORK/$setting_file" "Related World Rules:" "location related world rules"
            require_text "$WORK/$setting_file" "Continuity Risks:" "location continuity risks"
            ;;
        settings/world/*.md)
            require_text "$WORK/$setting_file" "Name:" "world rule name"
            require_text "$WORK/$setting_file" "World Rule:" "world rule statement"
            require_text "$WORK/$setting_file" "Scope:" "world rule scope"
            require_text "$WORK/$setting_file" "Limitations:" "world rule limitations"
            require_text "$WORK/$setting_file" "Exceptions:" "world rule exceptions"
            require_text "$WORK/$setting_file" "Evidence Requirements:" "world rule evidence requirements"
            require_text "$WORK/$setting_file" "Active State Anchors:" "world rule active state anchors"
            check_state_anchors "$WORK/$setting_file" "Active State Anchors" "$STATE" "world rule active state anchors"
            require_text "$WORK/$setting_file" "Continuity Risks:" "world rule continuity risks"
            ;;
    esac
done < "$world_refs_tmp"

awk -F'|' '
    /^## Character State/ { in_section = 1; next }
    /^## / && in_section { in_section = 0 }
    in_section && /^\|/ && $0 !~ /Character \| Location/ && $0 !~ /^\|[- ]+\|/ {
        name = $2
        gsub(/^[ \t]+|[ \t]+$/, "", name)
        if (name != "" && name != "TBD") {
            print name
        }
    }
' "$STATE" | sort -u > "$state_names_tmp"

[ -s "$state_names_tmp" ] || fail "narrative-state character state has no completed character rows"

while IFS= read -r character_name; do
    [ -n "$character_name" ] || continue
    grep -Fxq -- "$character_name" "$voice_names_tmp" || fail "active character missing from Character Voice Matrix: $character_name"
    grep -Fxq -- "$character_name" "$character_names_tmp" || fail "active character missing character sheet: $character_name"
    active_character_file=""
    for candidate_character_file in "$WORK/settings/characters"/*.md; do
        [ -e "$candidate_character_file" ] || continue
        candidate_name="$(awk -F':' '/^- Name:/ {
            name = $2
            gsub(/^[ \t]+|[ \t.]+$/, "", name)
            if (name != "") {
                print name
            }
        }' "$candidate_character_file")"
        if [ "$candidate_name" = "$character_name" ]; then
            active_character_file="$candidate_character_file"
            break
        fi
    done
    [ -n "$active_character_file" ] || fail "active character missing character sheet: $character_name"
    check_state_anchors "$active_character_file" "Active Physical Anchor" "$STATE" "character active physical anchor"
    check_state_anchors "$active_character_file" "Active Inventory Anchor" "$STATE" "character active inventory anchor"
    check_state_anchors "$active_character_file" "Active Knowledge Anchor" "$STATE" "character active knowledge anchor"
done < "$state_names_tmp"

while IFS= read -r character_name; do
    [ -n "$character_name" ] || continue
    grep -Fxq -- "$character_name" "$voice_names_tmp" || fail "series-bible evolution character missing from Character Voice Matrix: $character_name"
    grep -Fxq -- "$character_name" "$character_names_tmp" || fail "series-bible evolution character missing character sheet: $character_name"
done < "$evolution_names_tmp"

awk -F'|' '
    /^## Inventory Canon References/ { in_section = 1; next }
    /^## / && in_section { in_section = 0 }
    in_section && /^\|/ && $0 !~ /Item \/ Possession \| Current Holder/ && $0 !~ /^\|[- ]+\|/ {
        item = $2
        holder = $3
        file = $4
        state = $5
        gsub(/^[ \t]+|[ \t]+$/, "", item)
        gsub(/^[ \t]+|[ \t]+$/, "", holder)
        gsub(/^[ \t`]+|[ \t`]+$/, "", file)
        gsub(/^[ \t]+|[ \t]+$/, "", state)
        if (item != "" && item != "TBD") {
            print item "|" holder "|" file "|" state
        }
    }
' "$STATE" > "$item_refs_tmp"

if grep -Eq -- '\|[^|]*(key|ring|weapon|sword|gun|knife|letter|book|phone|lamp|pick|badge|card|token|map|약|검|칼|총|열쇠|반지|편지|책|휴대폰|지도|카드|등불|락픽)[^|]*\|' "$STATE"; then
    [ -s "$item_refs_tmp" ] || fail "inventory contains trackable possessions but Inventory Canon References has no completed rows"
fi

while IFS='|' read -r item holder setting_file item_state; do
    [ -n "$item" ] || continue
    [ -n "$holder" ] || fail "inventory canon reference missing holder: $item"
    [ -n "$setting_file" ] || fail "inventory canon reference missing setting file: $item"
    [ -n "$item_state" ] || fail "inventory canon reference missing current state: $item"
    grep -Fxq -- "$holder" "$state_names_tmp" || fail "inventory canon reference holder is not active in narrative-state: $holder"
    [ -s "$WORK/$setting_file" ] || fail "inventory canon reference setting file missing: $setting_file"
    require_text "$WORK/$setting_file" "$item" "inventory item name"
    require_text "$WORK/$setting_file" "Name:" "inventory item name field"
    require_text "$WORK/$setting_file" "Current Holder:" "inventory item current holder"
    require_text "$WORK/$setting_file" "Current Holder: $holder" "inventory item current holder value"
    require_text "$WORK/$setting_file" "Function:" "inventory item function"
    require_text "$WORK/$setting_file" "Limitations:" "inventory item limitations"
    require_text "$WORK/$setting_file" "Active State Anchors:" "inventory item active state anchors"
    check_state_anchors "$WORK/$setting_file" "Active State Anchors" "$STATE" "inventory item active state anchors"
    require_text "$WORK/$setting_file" "Transfer Rules:" "inventory item transfer rules"
    require_text "$WORK/$setting_file" "Related World Rules:" "inventory item related world rules"
    require_text "$WORK/$setting_file" "Continuity Risks:" "inventory item continuity risks"
done < "$item_refs_tmp"

scripts/validate-verification-manifest.sh "$VOLUME_PATH"

printf 'production artifacts ok\n'
