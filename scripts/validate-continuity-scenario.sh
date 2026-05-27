#!/bin/sh
set -eu

SCENARIO="${1:-examples/production-continuity-scenario.md}"

fail() {
    printf 'FAIL: %s\n' "$1" >&2
    exit 1
}

require_text() {
    pattern="$1"
    label="$2"
    grep -Fq -- "$pattern" "$SCENARIO" || fail "$label missing from $SCENARIO"
}

require_count() {
    pattern="$1"
    expected="$2"
    label="$3"
    actual="$(grep -Fc -- "$pattern" "$SCENARIO" || true)"
    [ "$actual" -ge "$expected" ] || fail "$label count too low in $SCENARIO: expected >= $expected, got $actual"
}

[ -s "$SCENARIO" ] || fail "missing or empty scenario: $SCENARIO"

require_text "Prose baseline: elegant, controlled, and assured literary prose by a renowned, seasoned professional novelist." "default prose baseline"
require_text "Style Contract:" "style contract"
require_text "Character Voice Matrix:" "character voice matrix"
require_text "never says \"대박\"" "Seo-yun forbidden slang"
require_text "never calls Seo-yun \"누나\"" "I-an forbidden address"
require_text "Han Seo-yun is left-handed." "left-handed canon"
require_text "Baek I-an has never met Director Chae." "knowledge boundary canon"
require_text "opens only when two living witnesses speak their legal names" "world rule canon"
require_text "right shoulder is wounded and cannot bear weight" "injury canon"
require_text "left coat pocket" "possession ledger"
require_text "does not know Director Chae's face or voice" "ledger knowledge boundary"
require_text "Locked prefix:" "locked prefix"

require_text "right sleeve" "bad beat possession contradiction"
require_text "shouldered the iron door open" "bad beat physical/world-rule contradiction"
require_text "\"대박, 그냥 열리네.\"" "bad beat Seo-yun voice drift"
require_text "recognized Director Chae's recorded voice" "bad beat knowledge collapse"
require_text "\"누나," "bad beat I-an forbidden address"

require_text "Physical continuity:" "expected physical finding"
require_text "Possession continuity:" "expected possession finding"
require_text "World rule collapse:" "expected world-rule finding"
require_text "Character voice drift: Seo-yun" "expected Seo-yun voice finding"
require_text "Character voice drift: I-an" "expected I-an voice finding"
require_text "Knowledge collapse:" "expected knowledge finding"
require_count "- " 25 "scenario detail bullets"

printf 'continuity scenario ok\n'
