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
template_target="$tmp_home/.config/opencode/novelist/templates"
skill_target="$tmp_home/.config/opencode/novelist/skills"

[ -s "$target/novelist.md" ] || fail "novelist agent was not installed"
[ -s "$target/novelist-writer.md" ] || fail "writer agent was not installed"
[ -s "$target/novelist-editor.md" ] || fail "editor agent was not installed"
[ -s "$target/novelist-loremaster.md" ] || fail "loremaster agent was not installed"
[ -s "$target/novelist-otaku.md" ] || fail "otaku agent was not installed"
[ -s "$target/novelist-publisher.md" ] || fail "publisher agent was not installed"
[ ! -e "$target/setting-collapse-detector" ] || fail "setting-collapse-detector must not be installed inside agent discovery path"
[ ! -e "$target/templates" ] || fail "templates must not be installed inside agent discovery path"
[ -s "$skill_target/setting-collapse-detector/SKILL.md" ] || fail "setting-collapse-detector skill was not installed"
[ -s "$template_target/style-guide.md" ] || fail "style guide template was not installed"
[ -s "$template_target/character-sheet.md" ] || fail "character sheet template was not installed"
[ -s "$template_target/item-sheet.md" ] || fail "item sheet template was not installed"
[ -s "$template_target/location-sheet.md" ] || fail "location sheet template was not installed"
[ -s "$template_target/world-rule-sheet.md" ] || fail "world rule sheet template was not installed"
[ -s "$template_target/series-bible.md" ] || fail "series bible template was not installed"
[ -s "$template_target/narrative-state.md" ] || fail "narrative state template was not installed"
[ -s "$template_target/verification-manifest.md" ] || fail "verification manifest template was not installed"
[ -s "$template_target/verification-evidence.md" ] || fail "verification evidence template was not installed"
[ -s "$template_target/retcon-proposal.md" ] || fail "retcon proposal template was not installed"

printf 'install smoke ok\n'
