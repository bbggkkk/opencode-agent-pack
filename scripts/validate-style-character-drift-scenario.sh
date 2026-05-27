#!/bin/sh
set -eu

SCENARIO="${1:-examples/style-character-drift-scenario.md}"

fail() {
    printf 'FAIL: %s\n' "$1" >&2
    exit 1
}

require_text() {
    pattern="$1"
    label="$2"
    grep -Fq -- "$pattern" "$SCENARIO" || fail "$label missing from $SCENARIO"
}

[ -s "$SCENARIO" ] || fail "missing or empty scenario: $SCENARIO"

require_text "renowned, seasoned professional novelist" "default prose baseline"
require_text "Style Contract" "style contract"
require_text "Character Voice Matrix" "character voice matrix"
require_text "no internet slang" "style diction guard"
require_text "Metaphor density: low" "metaphor density guard"
require_text "never says \"대박\"" "Seo-yun forbidden slang"
require_text "never calls Seo-yun \"누나\"" "I-an forbidden address"
require_text "Good Locked Context" "locked context"

require_text "완전 신나서" "bad comic register"
require_text "레전드급" "bad internet slang"
require_text "\"대박, 이거 그냥 밀면 되는 거 아냐?\"" "bad Seo-yun dialogue"
require_text "\"누나, 내가 과학적으로 분석해 봤는데" "bad I-an dialogue"

require_text "Style Drift: internet slang" "expected style drift finding"
require_text "Style Drift: exaggerated metaphor density" "expected metaphor drift finding"
require_text "POV Drift" "expected POV drift finding"
require_text "Character Voice Drift: Seo-yun" "expected Seo-yun voice drift"
require_text "Character Voice Drift: I-an" "expected I-an voice drift"
require_text "The unrepaired span must be **FAIL**" "expected fail verdict"
require_text "Style contract drift: comic internet register" "expected Otaku style contract drift"
require_text "Expected Repair Direction" "repair direction"

printf 'style and character drift scenario ok\n'
