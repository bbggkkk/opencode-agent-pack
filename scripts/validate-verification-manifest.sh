#!/bin/sh
set -eu

VOLUME="${1:-examples/sample-work/volume-1}"
WORK="${2:-$(dirname "$VOLUME")}"
MANIFEST="$VOLUME/verification-manifest.md"
DRAFT_DIR="$VOLUME/drafts"

fail() {
    printf 'FAIL: %s\n' "$1" >&2
    exit 1
}

draft_sha256() {
    file="$1"
    if command -v sha256sum >/dev/null 2>&1; then
        sha256sum "$file" | awk '{ print $1 }'
    elif command -v shasum >/dev/null 2>&1; then
        shasum -a 256 "$file" | awk '{ print $1 }'
    else
        fail "sha256sum or shasum is required for draft fingerprint validation"
    fi
}

canon_snapshot_sha256() {
    work="$1"
    volume="$2"
    tmp="$(mktemp)"

    [ -s "$work/series-bible.md" ] || fail "missing series-bible for canon snapshot: $work/series-bible.md"
    [ -d "$work/settings" ] || fail "missing settings directory for canon snapshot: $work/settings"
    [ -s "$volume/narrative-state.md" ] || fail "missing narrative-state for canon snapshot: $volume/narrative-state.md"

    {
        printf '%s\n' "$work/series-bible.md"
        find "$work/settings" -type f -name '*.md' | sort
        printf '%s\n' "$volume/narrative-state.md"
    } | while IFS= read -r file; do
        [ -s "$file" ] || fail "empty canon file in snapshot: $file"
        rel="${file#$work/}"
        hash="$(draft_sha256 "$file")"
        printf '%s  %s\n' "$hash" "$rel"
    done > "$tmp"

    snapshot_hash="$(draft_sha256 "$tmp")"
    rm -f "$tmp"
    printf '%s\n' "$snapshot_hash"
}

[ -d "$DRAFT_DIR" ] || fail "missing drafts directory: $DRAFT_DIR"
[ -s "$MANIFEST" ] || fail "missing or empty verification manifest: $MANIFEST"

EXPECTED_HEADER='| Draft Path | Draft SHA256 | Canon Snapshot SHA256 | Beat / Chapter | Final Otaku Verdict | Style Drift Audit | Character Voice Audit | Ledger Update Summary | Approved Unknowns | Verification Evidence |'
EXPECTED_SEPARATOR='|------------|--------------|------------------------|----------------|---------------------|-------------------|-----------------------|-----------------------|-------------------|-----------------------|'

grep -Fq -- "Draft SHA256" "$MANIFEST" || fail "manifest missing Draft SHA256 column"
grep -Fq -- "Canon Snapshot SHA256" "$MANIFEST" || fail "manifest missing Canon Snapshot SHA256 column"
grep -Fq -- "Final Otaku Verdict" "$MANIFEST" || fail "manifest missing Final Otaku Verdict column"
grep -Fq -- "Style Drift Audit" "$MANIFEST" || fail "manifest missing Style Drift Audit column"
grep -Fq -- "Character Voice Audit" "$MANIFEST" || fail "manifest missing Character Voice Audit column"
grep -Fq -- "Ledger Update Summary" "$MANIFEST" || fail "manifest missing Ledger Update Summary column"
grep -Fq -- "Verification Evidence" "$MANIFEST" || fail "manifest missing Verification Evidence column"
grep -Fxq -- "$EXPECTED_HEADER" "$MANIFEST" || fail "manifest schema header does not match expected column order"
grep -Fxq -- "$EXPECTED_SEPARATOR" "$MANIFEST" || fail "manifest schema separator does not match expected column order"

if grep -Eiq -- '\|[^|]*(FAIL|PENDING|UNVERIFIED)[^|]*\|' "$MANIFEST"; then
    fail "manifest contains FAIL, PENDING, or UNVERIFIED draft verdict"
fi

manifest_entries_tmp="$(mktemp)"
duplicate_entries_tmp="$(mktemp)"
taboo_expressions_tmp="$(mktemp)"
forbidden_literals_tmp="$(mktemp)"
trap 'rm -f "$manifest_entries_tmp" "$duplicate_entries_tmp" "$taboo_expressions_tmp" "$forbidden_literals_tmp"' EXIT INT TERM

awk -F'|' '
    /^\|/ {
        path = $2
        gsub(/^[ \t`]+|[ \t`]+$/, "", path)
        if (path ~ /^drafts\/.*\.md$/) {
            print path
        }
    }
' "$MANIFEST" | sort > "$manifest_entries_tmp"

if [ -s "$WORK/settings/style-guide.md" ]; then
    awk -F'|' '
        /^\|/ && $0 !~ /Character \| Register/ && $0 !~ /^\|[- ]+\|/ {
            field = $6
            while (match(field, /"[^"]+"/)) {
                print substr(field, RSTART + 1, RLENGTH - 2)
                field = substr(field, RSTART + RLENGTH)
            }
        }
    ' "$WORK/settings/style-guide.md" | sort -u > "$taboo_expressions_tmp"
    awk -F':' '/^- Forbidden Literal Phrases:/ {
        text = $2
        for (i = 3; i <= NF; i++) {
            text = text ":" $i
        }
        n = split(text, parts, ",")
        for (i = 1; i <= n; i++) {
            phrase = parts[i]
            gsub(/^[ \t.]+|[ \t.]+$/, "", phrase)
            if (phrase != "") {
                print phrase
            }
        }
    }' "$WORK/settings/style-guide.md" | sort -u > "$forbidden_literals_tmp"
fi

sort "$manifest_entries_tmp" | uniq -d > "$duplicate_entries_tmp"
if [ -s "$duplicate_entries_tmp" ]; then
    duplicate="$(sed -n '1p' "$duplicate_entries_tmp")"
    fail "duplicate draft entry in manifest: $duplicate"
fi

while IFS= read -r manifest_draft; do
    [ -n "$manifest_draft" ] || continue
    [ -s "$VOLUME/$manifest_draft" ] || fail "manifest lists draft missing on disk: $manifest_draft"
done < "$manifest_entries_tmp"

found=0
for draft in "$DRAFT_DIR"/*.md; do
    [ -e "$draft" ] || continue
    found=1
    rel="drafts/$(basename "$draft")"
    grep -Fxq -- "$rel" "$manifest_entries_tmp" || fail "draft missing from manifest: $rel"
    line="$(grep -F -- "\`$rel\`" "$MANIFEST")"
    column_count="$(printf '%s\n' "$line" | awk -F'|' '{ print NF - 1 }')"
    [ "$column_count" -eq 11 ] || fail "manifest row has wrong column count for draft: $rel"
    recorded_hash="$(printf '%s\n' "$line" | awk -F'|' '{ gsub(/^[ \t]+|[ \t]+$/, "", $3); print $3 }')"
    recorded_canon_hash="$(printf '%s\n' "$line" | awk -F'|' '{ gsub(/^[ \t]+|[ \t]+$/, "", $4); print $4 }')"
    verdict="$(printf '%s\n' "$line" | awk -F'|' '{ gsub(/^[ \t]+|[ \t]+$/, "", $6); print $6 }')"
    style_audit="$(printf '%s\n' "$line" | awk -F'|' '{ gsub(/^[ \t]+|[ \t]+$/, "", $7); print $7 }')"
    voice_audit="$(printf '%s\n' "$line" | awk -F'|' '{ gsub(/^[ \t]+|[ \t]+$/, "", $8); print $8 }')"
    ledger="$(printf '%s\n' "$line" | awk -F'|' '{ gsub(/^[ \t]+|[ \t]+$/, "", $9); print $9 }')"
    approved_unknowns="$(printf '%s\n' "$line" | awk -F'|' '{ gsub(/^[ \t]+|[ \t]+$/, "", $10); print $10 }')"
    evidence_path="$(printf '%s\n' "$line" | awk -F'|' '{ gsub(/^[ \t`]+|[ \t`]+$/, "", $11); print $11 }')"
    [ -n "$recorded_hash" ] || fail "draft has no recorded SHA256 in manifest: $rel"
    [ "$recorded_hash" != "TBD" ] || fail "draft has placeholder SHA256 in manifest: $rel"
    [ -n "$recorded_canon_hash" ] || fail "draft has no recorded canon snapshot SHA256 in manifest: $rel"
    [ "$recorded_canon_hash" != "TBD" ] || fail "draft has placeholder canon snapshot SHA256 in manifest: $rel"
    actual_hash="$(draft_sha256 "$draft")"
    [ "$recorded_hash" = "$actual_hash" ] || fail "draft SHA256 mismatch; re-run final verification before publishing: $rel"
    actual_canon_hash="$(canon_snapshot_sha256 "$WORK" "$VOLUME")"
    [ "$recorded_canon_hash" = "$actual_canon_hash" ] || fail "canon snapshot SHA256 mismatch; re-run final verification before publishing: $rel"
    if grep -Eq -- '^[[:space:]]+[^[:space:]]' "$draft"; then
        fail "draft contains hardcoded leading indentation: $rel"
    fi
    if grep -Eq -- '[[:space:]]+$' "$draft"; then
        fail "draft contains trailing whitespace: $rel"
    fi
    if grep -Eq -- '^(<<<<<<<|=======|>>>>>>>)' "$draft"; then
        fail "draft contains merge conflict marker: $rel"
    fi
    if grep -Eiq -- '<[[:space:]]*/?[[:space:]]*(script|style|div|span|p|html|body)([[:space:]>]|$)' "$draft"; then
        fail "draft contains raw HTML or unsafe markup: $rel"
    fi
    while IFS= read -r taboo_expression; do
        [ -n "$taboo_expression" ] || continue
        if grep -Fq -- "$taboo_expression" "$draft"; then
            fail "draft contains Character Voice Matrix taboo expression: $rel"
        fi
    done < "$taboo_expressions_tmp"
    while IFS= read -r forbidden_literal; do
        [ -n "$forbidden_literal" ] || continue
        if grep -Fq -- "$forbidden_literal" "$draft"; then
            fail "draft contains Forbidden Literal Phrase: $rel"
        fi
    done < "$forbidden_literals_tmp"
    [ "$verdict" = "PASS" ] || fail "draft is not marked PASS in manifest: $rel"
    [ "$style_audit" = "PASS" ] || fail "draft style drift audit is not marked PASS in manifest: $rel"
    [ "$voice_audit" = "PASS" ] || fail "draft character voice audit is not marked PASS in manifest: $rel"
    [ -n "$ledger" ] || fail "draft has no ledger update summary: $rel"
    [ "$ledger" != "TBD" ] || fail "draft has placeholder ledger update summary: $rel"
    [ -n "$approved_unknowns" ] || fail "draft has no approved unknowns value: $rel"
    [ "$approved_unknowns" != "TBD" ] || fail "draft has placeholder approved unknowns: $rel"
    [ -n "$evidence_path" ] || fail "draft has no verification evidence report: $rel"
    [ "$evidence_path" != "TBD" ] || fail "draft has placeholder verification evidence report: $rel"
    case "$evidence_path" in
        /*|*../*) fail "verification evidence report path must stay inside the active volume: $evidence_path" ;;
    esac
    case "$evidence_path" in
        verification-reports/*.md) ;;
        *) fail "verification evidence report must live under verification-reports/: $evidence_path" ;;
    esac
    evidence_file="$VOLUME/$evidence_path"
    [ -s "$evidence_file" ] || fail "verification evidence report missing: $evidence_path"
    if grep -Eiq -- '(FAIL|PENDING|UNVERIFIED)' "$evidence_file"; then
        fail "verification evidence report contains FAIL, PENDING, or UNVERIFIED: $evidence_path"
    fi
    grep -Fq -- "Draft Path: \`$rel\`" "$evidence_file" || fail "verification evidence draft path mismatch: $evidence_path"
    grep -Fq -- "Draft SHA256: $recorded_hash" "$evidence_file" || fail "verification evidence draft hash mismatch: $evidence_path"
    grep -Fq -- "Canon Snapshot SHA256: $recorded_canon_hash" "$evidence_file" || fail "verification evidence canon snapshot hash mismatch: $evidence_path"
    grep -Fq -- "Final Otaku Verdict: PASS" "$evidence_file" || fail "verification evidence Otaku verdict missing PASS: $evidence_path"
    grep -Fq -- "Style Drift Audit: PASS" "$evidence_file" || fail "verification evidence style drift audit missing PASS: $evidence_path"
    grep -Fq -- "Character Voice Audit: PASS" "$evidence_file" || fail "verification evidence character voice audit missing PASS: $evidence_path"
    grep -Fq -- "Ledger Update Summary: $ledger" "$evidence_file" || fail "verification evidence ledger summary mismatch: $evidence_path"
    grep -Fq -- "Approved Unknowns: $approved_unknowns" "$evidence_file" || fail "verification evidence approved unknowns mismatch: $evidence_path"
    retcon_approval="$(awk -F':' '/^- Retcon Approval:/ {
        value = $2
        for (i = 3; i <= NF; i++) {
            value = value ":" $i
        }
        gsub(/^[ \t`]+|[ \t`]+$/, "", value)
        print value
        exit
    }' "$evidence_file")"
    [ -n "$retcon_approval" ] || fail "verification evidence retcon approval missing: $evidence_path"
    case "$retcon_approval" in
        TBD|PENDING|FAIL|UNVERIFIED) fail "verification evidence retcon approval has placeholder or failed value: $evidence_path" ;;
    esac
    if [ "$retcon_approval" != "None" ]; then
        case "$retcon_approval" in
            /*|*../*) fail "retcon approval path must stay inside the active work: $retcon_approval" ;;
        esac
        case "$retcon_approval" in
            retcons/*.md) ;;
            *) fail "retcon approval must live under retcons/: $retcon_approval" ;;
        esac
        retcon_file="$WORK/$retcon_approval"
        [ -s "$retcon_file" ] || fail "retcon approval file missing: $retcon_approval"
        if grep -Eiq -- '(TBD|PENDING|FAIL|UNVERIFIED)' "$retcon_file"; then
            fail "retcon approval file contains placeholder, failed, pending, or unverified text: $retcon_approval"
        fi
        grep -Fq -- "Status: APPROVED" "$retcon_file" || fail "retcon approval file is not approved: $retcon_approval"
        grep -Fq -- "User Approval:" "$retcon_file" || fail "retcon approval file missing user approval: $retcon_approval"
        grep -Fq -- "Approval Evidence:" "$retcon_file" || fail "retcon approval file missing approval evidence: $retcon_approval"
        grep -Fq -- "## Impacted Drafts" "$retcon_file" || fail "retcon approval file missing impacted drafts: $retcon_approval"
        grep -Fq -- "## Impacted Canon Files" "$retcon_file" || fail "retcon approval file missing impacted canon files: $retcon_approval"
        grep -Fq -- "## Continuity Risks" "$retcon_file" || fail "retcon approval file missing continuity risks: $retcon_approval"
        grep -Fq -- "## Required Updates" "$retcon_file" || fail "retcon approval file missing required updates: $retcon_approval"
        grep -Fq -- "## Verification Plan" "$retcon_file" || fail "retcon approval file missing verification plan: $retcon_approval"
        retcon_canon_tmp="$(mktemp)"
        awk -F'|' '
            /^## Impacted Canon Files/ {
                in_canon = 1
                next
            }
            /^## / && in_canon {
                exit
            }
            in_canon && /^\|/ && $0 !~ /^\|[- ]+\|/ && $0 !~ /\|[ \t]*Canon File[ \t]*\|/ {
                file = $2
                update = $3
                phrase = $4
                gsub(/^[ \t`]+|[ \t`]+$/, "", file)
                gsub(/^[ \t`]+|[ \t`]+$/, "", update)
                gsub(/^[ \t`]+|[ \t`]+$/, "", phrase)
                if (file != "" || update != "" || phrase != "") {
                    print file "\t" update "\t" phrase
                }
            }
        ' "$retcon_file" > "$retcon_canon_tmp"
        [ -s "$retcon_canon_tmp" ] || {
            rm -f "$retcon_canon_tmp"
            fail "retcon approval file has no impacted canon rows: $retcon_approval"
        }
        while IFS='	' read -r canon_file required_update verification_phrase; do
            [ -n "$canon_file" ] || fail "retcon impacted canon file missing: $retcon_approval"
            [ -n "$required_update" ] || fail "retcon impacted canon required update missing: $retcon_approval"
            [ -n "$verification_phrase" ] || fail "retcon impacted canon verification evidence missing: $retcon_approval"
            case "$canon_file" in
                /*|../*|*/../*) fail "retcon impacted canon path must stay inside work: $canon_file" ;;
            esac
            case "$canon_file" in
                series-bible.md|settings/*.md|settings/*/*.md|volume-*/narrative-state.md) canon_path="$WORK/$canon_file" ;;
                *) fail "retcon impacted canon file must be series-bible, settings, or volume narrative-state: $canon_file" ;;
            esac
            [ -s "$canon_path" ] || {
                rm -f "$retcon_canon_tmp"
                fail "retcon impacted canon file missing on disk: $canon_file"
            }
            grep -Fq -- "$verification_phrase" "$canon_path" || {
                rm -f "$retcon_canon_tmp"
                fail "retcon impacted canon verification phrase not found: $canon_file"
            }
        done < "$retcon_canon_tmp"
        rm -f "$retcon_canon_tmp"
    fi
    grep -Fq -- "Physical Continuity: PASS" "$evidence_file" || fail "verification evidence physical continuity missing PASS: $evidence_path"
    grep -Fq -- "Possession / Inventory Continuity: PASS" "$evidence_file" || fail "verification evidence possession continuity missing PASS: $evidence_path"
    grep -Fq -- "Knowledge Boundary Continuity: PASS" "$evidence_file" || fail "verification evidence knowledge continuity missing PASS: $evidence_path"
    grep -Fq -- "Location / World Rule Continuity: PASS" "$evidence_file" || fail "verification evidence location world continuity missing PASS: $evidence_path"
    grep -Fq -- "Timeline Continuity: PASS" "$evidence_file" || fail "verification evidence timeline continuity missing PASS: $evidence_path"
    grep -Fq -- "Retcon Safety: PASS" "$evidence_file" || fail "verification evidence retcon safety missing PASS: $evidence_path"
    grep -Fq -- "Style Contract Match: PASS" "$evidence_file" || fail "verification evidence style contract match missing PASS: $evidence_path"
    grep -Fq -- "Default / Requested Prose Baseline: PASS" "$evidence_file" || fail "verification evidence prose baseline missing PASS: $evidence_path"
    grep -Fq -- "POV, Diction, and Rhythm Match: PASS" "$evidence_file" || fail "verification evidence prose mechanics missing PASS: $evidence_path"
    grep -Fq -- "Character Voice Matrix Match: PASS" "$evidence_file" || fail "verification evidence voice matrix missing PASS: $evidence_path"
    grep -Fq -- "Forbidden Expression Check: PASS" "$evidence_file" || fail "verification evidence forbidden expression check missing PASS: $evidence_path"
    grep -Fq -- "Character Evolution Justification: PASS" "$evidence_file" || fail "verification evidence character evolution justification missing PASS: $evidence_path"
    grep -Fq -- "## Evidence Anchors" "$evidence_file" || fail "verification evidence anchors missing: $evidence_path"
    evidence_anchors_tmp="$(mktemp)"
    awk -F'|' '
        /^## Evidence Anchors/ {
            in_anchors = 1
            next
        }
        /^## / && in_anchors {
            exit
        }
        in_anchors && /^\|/ && $0 !~ /^\|[- ]+\|/ && $0 !~ /\|[ \t]*Check[ \t]*\|/ {
            check = $2
            source = $3
            phrase = $4
            gsub(/^[ \t`]+|[ \t`]+$/, "", check)
            gsub(/^[ \t`]+|[ \t`]+$/, "", source)
            gsub(/^[ \t`]+|[ \t`]+$/, "", phrase)
            if (check != "" || source != "" || phrase != "") {
                print check "\t" source "\t" phrase
            }
        }
    ' "$evidence_file" > "$evidence_anchors_tmp"
    [ -s "$evidence_anchors_tmp" ] || fail "verification evidence anchors missing: $evidence_path"
    while IFS='	' read -r anchor_check anchor_source anchor_phrase; do
        [ -n "$anchor_check" ] || fail "verification evidence anchor check missing: $evidence_path"
        [ -n "$anchor_source" ] || fail "verification evidence anchor source missing: $evidence_path"
        [ "$anchor_source" != "TBD" ] || fail "verification evidence anchor source missing: $evidence_path"
        [ -n "$anchor_phrase" ] || fail "verification evidence anchor phrase missing: $evidence_path"
        [ "$anchor_phrase" != "TBD" ] || fail "verification evidence anchor phrase missing: $evidence_path"
        case "$anchor_source" in
            /*|../*|*/../*) fail "verification evidence anchor source path must stay inside work or volume: $anchor_source" ;;
        esac
        case "$anchor_source" in
            drafts/*.md|narrative-state.md) anchor_file="$VOLUME/$anchor_source" ;;
            series-bible.md|settings/*.md|settings/*/*.md) anchor_file="$WORK/$anchor_source" ;;
            *) fail "verification evidence anchor source must be volume-relative draft/narrative-state or work-relative settings/series-bible: $anchor_source" ;;
        esac
        [ -s "$anchor_file" ] || fail "verification evidence anchor source missing: $anchor_source"
        grep -Fq -- "$anchor_phrase" "$anchor_file" || fail "verification evidence anchor phrase not found in source: $anchor_source"
    done < "$evidence_anchors_tmp"
    for required_anchor in \
        "Physical Continuity" \
        "Possession / Inventory Continuity" \
        "Knowledge Boundary Continuity" \
        "Location / World Rule Continuity" \
        "Timeline Continuity" \
        "Retcon Safety" \
        "Style Contract Match" \
        "Default / Requested Prose Baseline" \
        "POV, Diction, and Rhythm Match" \
        "Character Voice Matrix Match" \
        "Forbidden Expression Check" \
        "Character Evolution Justification"
    do
        awk -F'	' -v check="$required_anchor" '$1 == check { found = 1 } END { exit !found }' "$evidence_anchors_tmp" || fail "verification evidence required anchor missing: $required_anchor"
    done
    rm -f "$evidence_anchors_tmp"
    grep -Fq -- "## Ledger Update Anchors" "$evidence_file" || fail "verification evidence ledger update anchors missing: $evidence_path"
    ledger_anchors_tmp="$(mktemp)"
    awk -F'|' '
        /^## Ledger Update Anchors/ {
            in_anchors = 1
            next
        }
        /^## / && in_anchors {
            exit
        }
        in_anchors && /^\|/ && $0 !~ /^\|[- ]+\|/ && $0 !~ /\|[ \t]*Ledger Fact[ \t]*\|/ {
            fact = $2
            summary = $3
            state = $4
            gsub(/^[ \t`]+|[ \t`]+$/, "", fact)
            gsub(/^[ \t`]+|[ \t`]+$/, "", summary)
            gsub(/^[ \t`]+|[ \t`]+$/, "", state)
            if (fact != "" || summary != "" || state != "") {
                print fact "\t" summary "\t" state
            }
        }
    ' "$evidence_file" > "$ledger_anchors_tmp"
    [ -s "$ledger_anchors_tmp" ] || fail "verification evidence ledger update anchors missing: $evidence_path"
    while IFS='	' read -r ledger_fact summary_phrase state_phrase; do
        [ -n "$ledger_fact" ] || fail "verification evidence ledger anchor fact missing: $evidence_path"
        [ -n "$summary_phrase" ] || fail "verification evidence ledger summary phrase missing: $evidence_path"
        [ "$summary_phrase" != "TBD" ] || fail "verification evidence ledger summary phrase missing: $evidence_path"
        [ -n "$state_phrase" ] || fail "verification evidence ledger state phrase missing: $evidence_path"
        [ "$state_phrase" != "TBD" ] || fail "verification evidence ledger state phrase missing: $evidence_path"
        printf '%s\n' "$ledger" | grep -Fq -- "$summary_phrase" || {
            rm -f "$ledger_anchors_tmp"
            fail "verification evidence ledger summary phrase not found in manifest ledger: $summary_phrase"
        }
        grep -Fq -- "$state_phrase" "$VOLUME/narrative-state.md" || {
            rm -f "$ledger_anchors_tmp"
            fail "verification evidence ledger state phrase not found in narrative-state: $state_phrase"
        }
    done < "$ledger_anchors_tmp"
    for required_ledger_fact in \
        "Timeline / Position" \
        "Character Physical State" \
        "Inventory State" \
        "Knowledge Boundary" \
        "Location / World State"
    do
        awk -F'	' -v fact="$required_ledger_fact" '$1 == fact { found = 1 } END { exit !found }' "$ledger_anchors_tmp" || {
            rm -f "$ledger_anchors_tmp"
            fail "verification evidence required ledger anchor missing: $required_ledger_fact"
        }
    done
    rm -f "$ledger_anchors_tmp"
    if [ "$approved_unknowns" != "None" ]; then
        approved_unknowns_tmp="$(mktemp)"
        printf '%s\n' "$approved_unknowns" | awk '
            {
                n = split($0, parts, ";")
                for (i = 1; i <= n; i++) {
                    unknown = parts[i]
                    gsub(/^[ \t.]+|[ \t.]+$/, "", unknown)
                    if (unknown != "") {
                        print unknown
                    }
                }
            }
        ' > "$approved_unknowns_tmp"
        [ -s "$approved_unknowns_tmp" ] || {
            rm -f "$approved_unknowns_tmp"
            fail "draft approved unknowns has no usable value: $rel"
        }
        while IFS= read -r approved_unknown; do
            [ -n "$approved_unknown" ] || continue
            [ "$approved_unknown" != "None" ] || continue
            grep -Fq -- "$approved_unknown" "$VOLUME/narrative-state.md" || {
                rm -f "$approved_unknowns_tmp"
                fail "approved unknown is not tracked in narrative-state open hooks: $approved_unknown"
            }
        done < "$approved_unknowns_tmp"
        rm -f "$approved_unknowns_tmp"
    fi
    if grep -Eq -- 'Status: UNVERIFIED (DRAFT|REVISION)|UNVERIFIED DRAFT|UNVERIFIED REVISION' "$draft"; then
        fail "draft contains standalone unverified status label: $rel"
    fi
done

[ "$found" -eq 1 ] || fail "no markdown drafts found in $DRAFT_DIR"

printf 'verification manifest ok\n'
