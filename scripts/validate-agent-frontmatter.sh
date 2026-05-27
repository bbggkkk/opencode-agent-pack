#!/bin/sh
set -eu

fail() {
    printf 'FAIL: %s\n' "$1" >&2
    exit 1
}

frontmatter() {
    file="$1"
    awk '
        NR == 1 && $0 != "---" { exit 2 }
        NR == 1 { next }
        $0 == "---" { exit 0 }
        { print }
    ' "$file"
}

require_fm_text() {
    file="$1"
    pattern="$2"
    label="$3"
    frontmatter "$file" | grep -Fq -- "$pattern" || fail "$label missing in $file frontmatter"
}

require_body_text() {
    file="$1"
    pattern="$2"
    label="$3"
    grep -Fq -- "$pattern" "$file" || fail "$label missing in $file"
}

for file in agents/*.md; do
    [ "$(sed -n '1p' "$file")" = "---" ] || fail "frontmatter start missing in $file"
    require_fm_text "$file" "description:" "description"
    require_fm_text "$file" "mode:" "mode"
    require_fm_text "$file" "temperature:" "temperature"
    require_fm_text "$file" "color:" "color"
    require_fm_text "$file" "permission:" "permission block"
    require_fm_text "$file" "read: allow" "read permission"
    require_fm_text "$file" "grep: allow" "grep permission"
    require_fm_text "$file" "glob: allow" "glob permission"
    require_fm_text "$file" "list: allow" "list permission"
    require_fm_text "$file" "edit: allow" "edit permission"
    require_body_text "$file" "##" "section headings"
done

require_fm_text agents/novelist.md "mode: primary" "router primary mode"
for file in agents/novelist-writer.md agents/novelist-editor.md agents/novelist-loremaster.md agents/novelist-otaku.md agents/novelist-publisher.md agents/novelist-researcher.md; do
    require_fm_text "$file" "mode: subagent" "subagent mode"
done

for file in agents/novelist.md agents/novelist-writer.md agents/novelist-editor.md agents/novelist-loremaster.md agents/novelist-otaku.md agents/novelist-publisher.md; do
    require_fm_text "$file" "skill: allow" "skill permission"
done

require_fm_text agents/novelist.md "task: allow" "router task permission"
require_fm_text agents/novelist-researcher.md "webfetch: allow" "researcher webfetch permission"
require_fm_text agents/novelist-researcher.md "websearch: allow" "researcher websearch permission"

printf 'agent frontmatter ok\n'
