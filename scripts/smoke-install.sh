#!/bin/sh
set -eu

fail() {
    printf 'FAIL: %s\n' "$1" >&2
    exit 1
}

tmp_home="$(mktemp -d)"
trap 'rm -rf "$tmp_home"' EXIT INT TERM

HOME="$tmp_home" ./install.sh 2 >/tmp/opencode-novelist-install.log

target="$tmp_home/.config/opencode/agents"

[ -s "$target/novelist.md" ] || fail "novelist agent was not installed"
[ -s "$target/novelist-writer.md" ] || fail "writer agent was not installed"
[ -s "$target/novelist-editor.md" ] || fail "editor agent was not installed"
[ -s "$target/novelist-loremaster.md" ] || fail "loremaster agent was not installed"
[ -s "$target/novelist-otaku.md" ] || fail "otaku agent was not installed"
[ -s "$target/novelist-publisher.md" ] || fail "publisher agent was not installed"
[ -s "$target/setting-collapse-detector/SKILL.md" ] || fail "setting-collapse-detector skill was not installed"
[ -s "$target/templates/style-guide.md" ] || fail "style guide template was not installed"
[ -s "$target/templates/character-sheet.md" ] || fail "character sheet template was not installed"
[ -s "$target/templates/item-sheet.md" ] || fail "item sheet template was not installed"
[ -s "$target/templates/location-sheet.md" ] || fail "location sheet template was not installed"
[ -s "$target/templates/world-rule-sheet.md" ] || fail "world rule sheet template was not installed"
[ -s "$target/templates/series-bible.md" ] || fail "series bible template was not installed"
[ -s "$target/templates/narrative-state.md" ] || fail "narrative state template was not installed"
[ -s "$target/templates/verification-manifest.md" ] || fail "verification manifest template was not installed"
[ -s "$target/templates/verification-evidence.md" ] || fail "verification evidence template was not installed"
[ -s "$target/templates/retcon-proposal.md" ] || fail "retcon proposal template was not installed"

printf 'install smoke ok\n'
