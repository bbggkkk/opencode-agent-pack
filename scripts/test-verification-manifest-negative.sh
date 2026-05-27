#!/bin/sh
set -eu

fail() {
    printf 'FAIL: %s\n' "$1" >&2
    exit 1
}

expect_fail() {
    label="$1"
    work="$2"
    if scripts/validate-verification-manifest.sh "$work/volume-1" "$work" >/tmp/opencode-novelist-negative.log 2>&1; then
        cat /tmp/opencode-novelist-negative.log >&2
        fail "$label unexpectedly passed"
    fi
}

copy_fixture() {
    dest="$1"
    mkdir -p "$dest"
    cp -R examples/sample-work/. "$dest/"
}

refresh_draft_hash() {
    work="$1"
    hash="$(sha256sum "$work/volume-1/drafts/chapter-01.md" | awk '{ print $1 }')"
    awk -F'|' -v hash="$hash" '
        /drafts\/chapter-01.md/ {
            $3 = " " hash " "
            out = $1
            for (i = 2; i <= NF; i++) {
                out = out "|" $i
            }
            print out
            next
        }
        { print }
    ' "$work/volume-1/verification-manifest.md" > "$work/volume-1/verification-manifest.tmp"
    mv "$work/volume-1/verification-manifest.tmp" "$work/volume-1/verification-manifest.md"
    sed "s/Draft SHA256: .*/Draft SHA256: $hash/" "$work/volume-1/verification-reports/chapter-01.md" > "$work/volume-1/verification-reports/chapter-01.tmp"
    mv "$work/volume-1/verification-reports/chapter-01.tmp" "$work/volume-1/verification-reports/chapter-01.md"
}

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT INT TERM

missing="$tmp/missing"
copy_fixture "$missing"
awk '/drafts\/chapter-01.md/ { next } { print }' "$missing/volume-1/verification-manifest.md" > "$missing/volume-1/verification-manifest.tmp"
mv "$missing/volume-1/verification-manifest.tmp" "$missing/volume-1/verification-manifest.md"
expect_fail "missing draft manifest entry" "$missing"

duplicate="$tmp/duplicate"
copy_fixture "$duplicate"
awk '
    { print }
    /drafts\/chapter-01.md/ { print }
' "$duplicate/volume-1/verification-manifest.md" > "$duplicate/volume-1/verification-manifest.tmp"
mv "$duplicate/volume-1/verification-manifest.tmp" "$duplicate/volume-1/verification-manifest.md"
expect_fail "duplicate draft manifest entry" "$duplicate"

stale="$tmp/stale"
copy_fixture "$stale"
awk '
    { print }
    /drafts\/chapter-01.md/ {
        stale = $0
        gsub(/drafts\/chapter-01.md/, "drafts/missing-chapter.md", stale)
        print stale
    }
' "$stale/volume-1/verification-manifest.md" > "$stale/volume-1/verification-manifest.tmp"
mv "$stale/volume-1/verification-manifest.tmp" "$stale/volume-1/verification-manifest.md"
expect_fail "manifest stale draft entry" "$stale"

schema_drift="$tmp/schema-drift"
copy_fixture "$schema_drift"
sed 's/| Draft Path | Draft SHA256 | Canon Snapshot SHA256 | Beat \/ Chapter |/| Draft Path | Canon Snapshot SHA256 | Draft SHA256 | Beat \/ Chapter |/' "$schema_drift/volume-1/verification-manifest.md" > "$schema_drift/volume-1/verification-manifest.tmp"
mv "$schema_drift/volume-1/verification-manifest.tmp" "$schema_drift/volume-1/verification-manifest.md"
expect_fail "manifest schema header drift" "$schema_drift"

bad_column_count="$tmp/bad-column-count"
copy_fixture "$bad_column_count"
awk -F'|' '
    /drafts\/chapter-01.md/ {
        print "|"$2"|"$3"|"$4"|"$5"|"$6"|"$7"|"$8"|"$9"|"
        next
    }
    { print }
' "$bad_column_count/volume-1/verification-manifest.md" > "$bad_column_count/volume-1/verification-manifest.tmp"
mv "$bad_column_count/volume-1/verification-manifest.tmp" "$bad_column_count/volume-1/verification-manifest.md"
expect_fail "manifest row wrong column count" "$bad_column_count"

pending="$tmp/pending"
copy_fixture "$pending"
sed 's/| PASS |/| PENDING |/' "$pending/volume-1/verification-manifest.md" > "$pending/volume-1/verification-manifest.tmp"
mv "$pending/volume-1/verification-manifest.tmp" "$pending/volume-1/verification-manifest.md"
expect_fail "pending draft verdict" "$pending"

placeholder="$tmp/placeholder"
copy_fixture "$placeholder"
awk -F'|' '
    /drafts\/chapter-01.md/ {
        print "|"$2"|"$3"|"$4"|"$5"|"$6"|"$7"|"$8"| TBD |"$10"|"$11"|"
        next
    }
    { print }
' "$placeholder/volume-1/verification-manifest.md" > "$placeholder/volume-1/verification-manifest.tmp"
mv "$placeholder/volume-1/verification-manifest.tmp" "$placeholder/volume-1/verification-manifest.md"
expect_fail "placeholder ledger summary" "$placeholder"

approved_unknown_placeholder="$tmp/approved-unknown-placeholder"
copy_fixture "$approved_unknown_placeholder"
awk -F'|' '
    /drafts\/chapter-01.md/ {
        print "|"$2"|"$3"|"$4"|"$5"|"$6"|"$7"|"$8"|"$9"| TBD |"$11"|"
        next
    }
    { print }
' "$approved_unknown_placeholder/volume-1/verification-manifest.md" > "$approved_unknown_placeholder/volume-1/verification-manifest.tmp"
mv "$approved_unknown_placeholder/volume-1/verification-manifest.tmp" "$approved_unknown_placeholder/volume-1/verification-manifest.md"
expect_fail "placeholder approved unknowns" "$approved_unknown_placeholder"

style_fail="$tmp/style-fail"
copy_fixture "$style_fail"
awk -F'|' '
    /drafts\/chapter-01.md/ {
        print "|"$2"|"$3"|"$4"|"$5"|"$6"| FAIL |"$8"|"$9"|"$10"|"$11"|"
        next
    }
    { print }
' "$style_fail/volume-1/verification-manifest.md" > "$style_fail/volume-1/verification-manifest.tmp"
mv "$style_fail/volume-1/verification-manifest.tmp" "$style_fail/volume-1/verification-manifest.md"
expect_fail "style drift audit failure" "$style_fail"

voice_pending="$tmp/voice-pending"
copy_fixture "$voice_pending"
awk -F'|' '
    /drafts\/chapter-01.md/ {
        print "|"$2"|"$3"|"$4"|"$5"|"$6"|"$7"| PENDING |"$9"|"$10"|"$11"|"
        next
    }
    { print }
' "$voice_pending/volume-1/verification-manifest.md" > "$voice_pending/volume-1/verification-manifest.tmp"
mv "$voice_pending/volume-1/verification-manifest.tmp" "$voice_pending/volume-1/verification-manifest.md"
expect_fail "character voice audit pending" "$voice_pending"

extra="$tmp/extra"
copy_fixture "$extra"
cp "$extra/volume-1/drafts/chapter-01.md" "$extra/volume-1/drafts/chapter-02.md"
expect_fail "extra draft missing from manifest" "$extra"

unverified="$tmp/unverified"
copy_fixture "$unverified"
{
    printf 'Status: UNVERIFIED DRAFT - requires @novelist-otaku final PASS and verification-manifest.md ledger update before use or publication.\n\n'
    cat "$unverified/volume-1/drafts/chapter-01.md"
} > "$unverified/volume-1/drafts/chapter-01.tmp"
mv "$unverified/volume-1/drafts/chapter-01.tmp" "$unverified/volume-1/drafts/chapter-01.md"
expect_fail "unverified standalone draft label" "$unverified"

mutated="$tmp/mutated"
copy_fixture "$mutated"
printf '\nSilent post-verification edit.\n' >> "$mutated/volume-1/drafts/chapter-01.md"
expect_fail "draft SHA256 mismatch after mutation" "$mutated"

indented_draft="$tmp/indented-draft"
copy_fixture "$indented_draft"
sed 's/^계단/    계단/' "$indented_draft/volume-1/drafts/chapter-01.md" > "$indented_draft/volume-1/drafts/chapter-01.tmp"
mv "$indented_draft/volume-1/drafts/chapter-01.tmp" "$indented_draft/volume-1/drafts/chapter-01.md"
refresh_draft_hash "$indented_draft"
expect_fail "draft contains hardcoded leading indentation" "$indented_draft"

conflict_draft="$tmp/conflict-draft"
copy_fixture "$conflict_draft"
printf '\n<<<<<<< HEAD\nconflict\n=======\nconflict\n>>>>>>> branch\n' >> "$conflict_draft/volume-1/drafts/chapter-01.md"
refresh_draft_hash "$conflict_draft"
expect_fail "draft contains merge conflict marker" "$conflict_draft"

html_draft="$tmp/html-draft"
copy_fixture "$html_draft"
printf '\n<div>layout hack</div>\n' >> "$html_draft/volume-1/drafts/chapter-01.md"
refresh_draft_hash "$html_draft"
expect_fail "draft contains raw HTML or unsafe markup" "$html_draft"

taboo_draft="$tmp/taboo-draft"
copy_fixture "$taboo_draft"
printf '\n"대박." 서윤이 말했다.\n' >> "$taboo_draft/volume-1/drafts/chapter-01.md"
refresh_draft_hash "$taboo_draft"
expect_fail "draft contains Character Voice Matrix taboo expression" "$taboo_draft"

forbidden_literal_draft="$tmp/forbidden-literal-draft"
copy_fixture "$forbidden_literal_draft"
printf '\n그 순간은 레전드급이었다.\n' >> "$forbidden_literal_draft/volume-1/drafts/chapter-01.md"
refresh_draft_hash "$forbidden_literal_draft"
expect_fail "draft contains Forbidden Literal Phrase" "$forbidden_literal_draft"

canon_mutated="$tmp/canon-mutated"
copy_fixture "$canon_mutated"
printf '\n- Silent post-verification canon edit.\n' >> "$canon_mutated/settings/world/archive-rules.md"
expect_fail "canon snapshot SHA256 mismatch after mutation" "$canon_mutated"

approved_unknown_untracked="$tmp/approved-unknown-untracked"
copy_fixture "$approved_unknown_untracked"
awk -F'|' '
    /drafts\/chapter-01.md/ {
        print "|"$2"|"$3"|"$4"|"$5"|"$6"|"$7"|"$8"|"$9"| untracked witness identity |"$11"|"
        next
    }
    { print }
' "$approved_unknown_untracked/volume-1/verification-manifest.md" > "$approved_unknown_untracked/volume-1/verification-manifest.tmp"
mv "$approved_unknown_untracked/volume-1/verification-manifest.tmp" "$approved_unknown_untracked/volume-1/verification-manifest.md"
sed 's/Approved Unknowns: None/Approved Unknowns: untracked witness identity/' "$approved_unknown_untracked/volume-1/verification-reports/chapter-01.md" > "$approved_unknown_untracked/volume-1/verification-reports/chapter-01.tmp"
mv "$approved_unknown_untracked/volume-1/verification-reports/chapter-01.tmp" "$approved_unknown_untracked/volume-1/verification-reports/chapter-01.md"
expect_fail "approved unknown is not tracked in narrative-state open hooks" "$approved_unknown_untracked"

missing_evidence="$tmp/missing-evidence"
copy_fixture "$missing_evidence"
rm -f "$missing_evidence/volume-1/verification-reports/chapter-01.md"
expect_fail "missing verification evidence report" "$missing_evidence"

evidence_hash="$tmp/evidence-hash"
copy_fixture "$evidence_hash"
sed 's/Draft SHA256: e177ff1d15e193e65745d2d239e1501a66e417e83d877245c72d7a99d21a5971/Draft SHA256: bad/' "$evidence_hash/volume-1/verification-reports/chapter-01.md" > "$evidence_hash/volume-1/verification-reports/chapter-01.tmp"
mv "$evidence_hash/volume-1/verification-reports/chapter-01.tmp" "$evidence_hash/volume-1/verification-reports/chapter-01.md"
expect_fail "verification evidence draft hash mismatch" "$evidence_hash"

evidence_approved_unknowns="$tmp/evidence-approved-unknowns"
copy_fixture "$evidence_approved_unknowns"
sed 's/Approved Unknowns: None/Approved Unknowns: untracked alarm source/' "$evidence_approved_unknowns/volume-1/verification-reports/chapter-01.md" > "$evidence_approved_unknowns/volume-1/verification-reports/chapter-01.tmp"
mv "$evidence_approved_unknowns/volume-1/verification-reports/chapter-01.tmp" "$evidence_approved_unknowns/volume-1/verification-reports/chapter-01.md"
expect_fail "verification evidence approved unknowns mismatch" "$evidence_approved_unknowns"

evidence_style="$tmp/evidence-style"
copy_fixture "$evidence_style"
sed 's/Style Drift Audit: PASS/Style Drift Audit: FAIL/' "$evidence_style/volume-1/verification-reports/chapter-01.md" > "$evidence_style/volume-1/verification-reports/chapter-01.tmp"
mv "$evidence_style/volume-1/verification-reports/chapter-01.tmp" "$evidence_style/volume-1/verification-reports/chapter-01.md"
expect_fail "verification evidence style drift audit missing PASS" "$evidence_style"

evidence_physical="$tmp/evidence-physical"
copy_fixture "$evidence_physical"
sed 's/Physical Continuity: PASS/Physical Continuity: FAIL/' "$evidence_physical/volume-1/verification-reports/chapter-01.md" > "$evidence_physical/volume-1/verification-reports/chapter-01.tmp"
mv "$evidence_physical/volume-1/verification-reports/chapter-01.tmp" "$evidence_physical/volume-1/verification-reports/chapter-01.md"
expect_fail "verification evidence physical continuity missing PASS" "$evidence_physical"

evidence_voice_matrix="$tmp/evidence-voice-matrix"
copy_fixture "$evidence_voice_matrix"
sed 's/Character Voice Matrix Match: PASS/Character Voice Matrix Match: FAIL/' "$evidence_voice_matrix/volume-1/verification-reports/chapter-01.md" > "$evidence_voice_matrix/volume-1/verification-reports/chapter-01.tmp"
mv "$evidence_voice_matrix/volume-1/verification-reports/chapter-01.tmp" "$evidence_voice_matrix/volume-1/verification-reports/chapter-01.md"
expect_fail "verification evidence voice matrix missing PASS" "$evidence_voice_matrix"

evidence_prose="$tmp/evidence-prose"
copy_fixture "$evidence_prose"
sed 's/Default \/ Requested Prose Baseline: PASS/Default \/ Requested Prose Baseline: FAIL/' "$evidence_prose/volume-1/verification-reports/chapter-01.md" > "$evidence_prose/volume-1/verification-reports/chapter-01.tmp"
mv "$evidence_prose/volume-1/verification-reports/chapter-01.tmp" "$evidence_prose/volume-1/verification-reports/chapter-01.md"
expect_fail "verification evidence prose baseline missing PASS" "$evidence_prose"

evidence_contradiction="$tmp/evidence-contradiction"
copy_fixture "$evidence_contradiction"
printf '\n- Contradictory later note: PENDING style recheck.\n' >> "$evidence_contradiction/volume-1/verification-reports/chapter-01.md"
expect_fail "verification evidence report contains FAIL, PENDING, or UNVERIFIED" "$evidence_contradiction"

retcon_missing="$tmp/retcon-missing"
copy_fixture "$retcon_missing"
sed 's/Retcon Approval: None/Retcon Approval: retcons\/missing.md/' "$retcon_missing/volume-1/verification-reports/chapter-01.md" > "$retcon_missing/volume-1/verification-reports/chapter-01.tmp"
mv "$retcon_missing/volume-1/verification-reports/chapter-01.tmp" "$retcon_missing/volume-1/verification-reports/chapter-01.md"
expect_fail "retcon approval file missing" "$retcon_missing"

retcon_pending="$tmp/retcon-pending"
copy_fixture "$retcon_pending"
mkdir -p "$retcon_pending/retcons"
sed 's/Retcon Approval: None/Retcon Approval: retcons\/pending.md/' "$retcon_pending/volume-1/verification-reports/chapter-01.md" > "$retcon_pending/volume-1/verification-reports/chapter-01.tmp"
mv "$retcon_pending/volume-1/verification-reports/chapter-01.tmp" "$retcon_pending/volume-1/verification-reports/chapter-01.md"
cat > "$retcon_pending/retcons/pending.md" <<'EOF_RETCON_PENDING'
# Retcon Proposal: Door State

- Status: PENDING
- Requested Change: Make the door already open.
- Reason: Scene rewrite request.
- User Approval: Awaiting approval.
- Approval Evidence: Awaiting approval.

## Impacted Drafts

| Draft Path | Required Update | Verification Evidence |
|------------|-----------------|-----------------------|
| `volume-1/drafts/chapter-01.md` | Revise door state. | unopened door |

## Impacted Canon Files

| Canon File | Required Update | Verification Evidence |
|------------|-----------------|-----------------------|
| `volume-1/narrative-state.md` | Revise door state. | The door has not opened |

## Continuity Risks

- Door continuity contradiction.

## Required Updates

- Revise dependent continuity files.

## Verification Plan

- Re-run final verification.
EOF_RETCON_PENDING
expect_fail "retcon approval file contains placeholder, failed, pending, or unverified text" "$retcon_pending"

retcon_missing_canon="$tmp/retcon-missing-canon"
copy_fixture "$retcon_missing_canon"
mkdir -p "$retcon_missing_canon/retcons"
sed 's/Retcon Approval: None/Retcon Approval: retcons\/approved.md/' "$retcon_missing_canon/volume-1/verification-reports/chapter-01.md" > "$retcon_missing_canon/volume-1/verification-reports/chapter-01.tmp"
mv "$retcon_missing_canon/volume-1/verification-reports/chapter-01.tmp" "$retcon_missing_canon/volume-1/verification-reports/chapter-01.md"
cat > "$retcon_missing_canon/retcons/approved.md" <<'EOF_RETCON_MISSING_CANON'
# Retcon Proposal: Door State

- Status: APPROVED
- Requested Change: Make the archive door open after the witness names.
- Reason: User requested a continuity migration for the next beat.
- User Approval: Approved by user in current session.
- Approval Evidence: User explicitly approved the migration.

## Impacted Drafts

| Draft Path | Required Update | Verification Evidence |
|------------|-----------------|-----------------------|
| `volume-1/drafts/chapter-01.md` | Preserve previous door state before migration. | unopened door |

## Impacted Canon Files

| Canon File | Required Update | Verification Evidence |
|------------|-----------------|-----------------------|
| `settings/world/missing.md` | Update door rule dependency. | missing phrase |

## Continuity Risks

- Door state can contradict the existing chapter.

## Required Updates

- Update canon and re-run final verification.

## Verification Plan

- Confirm impacted canon files and hashes after migration.
EOF_RETCON_MISSING_CANON
expect_fail "retcon impacted canon file missing on disk" "$retcon_missing_canon"

evidence_anchor_missing="$tmp/evidence-anchor-missing"
copy_fixture "$evidence_anchor_missing"
awk '/^\| Knowledge Boundary Continuity \|/ { next } { print }' "$evidence_anchor_missing/volume-1/verification-reports/chapter-01.md" > "$evidence_anchor_missing/volume-1/verification-reports/chapter-01.tmp"
mv "$evidence_anchor_missing/volume-1/verification-reports/chapter-01.tmp" "$evidence_anchor_missing/volume-1/verification-reports/chapter-01.md"
expect_fail "verification evidence required anchor missing" "$evidence_anchor_missing"

evidence_pov_anchor_missing="$tmp/evidence-pov-anchor-missing"
copy_fixture "$evidence_pov_anchor_missing"
awk '/^\| POV, Diction, and Rhythm Match \|/ { next } { print }' "$evidence_pov_anchor_missing/volume-1/verification-reports/chapter-01.md" > "$evidence_pov_anchor_missing/volume-1/verification-reports/chapter-01.tmp"
mv "$evidence_pov_anchor_missing/volume-1/verification-reports/chapter-01.tmp" "$evidence_pov_anchor_missing/volume-1/verification-reports/chapter-01.md"
expect_fail "verification evidence required POV anchor missing" "$evidence_pov_anchor_missing"

evidence_anchor_phrase="$tmp/evidence-anchor-phrase"
copy_fixture "$evidence_anchor_phrase"
sed 's/오른쪽 어깨/없는 근거 문구/' "$evidence_anchor_phrase/volume-1/verification-reports/chapter-01.md" > "$evidence_anchor_phrase/volume-1/verification-reports/chapter-01.tmp"
mv "$evidence_anchor_phrase/volume-1/verification-reports/chapter-01.tmp" "$evidence_anchor_phrase/volume-1/verification-reports/chapter-01.md"
expect_fail "verification evidence anchor phrase not found in source" "$evidence_anchor_phrase"

evidence_anchor_traversal="$tmp/evidence-anchor-traversal"
copy_fixture "$evidence_anchor_traversal"
sed 's/settings\/world\/archive-rules.md/..\/settings\/world\/archive-rules.md/' "$evidence_anchor_traversal/volume-1/verification-reports/chapter-01.md" > "$evidence_anchor_traversal/volume-1/verification-reports/chapter-01.tmp"
mv "$evidence_anchor_traversal/volume-1/verification-reports/chapter-01.tmp" "$evidence_anchor_traversal/volume-1/verification-reports/chapter-01.md"
expect_fail "verification evidence anchor source path must stay inside work or volume" "$evidence_anchor_traversal"

evidence_ledger_anchor_missing="$tmp/evidence-ledger-anchor-missing"
copy_fixture "$evidence_ledger_anchor_missing"
awk '/^\| Knowledge Boundary \|/ { next } { print }' "$evidence_ledger_anchor_missing/volume-1/verification-reports/chapter-01.md" > "$evidence_ledger_anchor_missing/volume-1/verification-reports/chapter-01.tmp"
mv "$evidence_ledger_anchor_missing/volume-1/verification-reports/chapter-01.tmp" "$evidence_ledger_anchor_missing/volume-1/verification-reports/chapter-01.md"
expect_fail "verification evidence required ledger anchor missing" "$evidence_ledger_anchor_missing"

evidence_ledger_summary_phrase="$tmp/evidence-ledger-summary-phrase"
copy_fixture "$evidence_ledger_summary_phrase"
sed 's/key in left coat pocket/key in right coat pocket/' "$evidence_ledger_summary_phrase/volume-1/verification-reports/chapter-01.md" > "$evidence_ledger_summary_phrase/volume-1/verification-reports/chapter-01.tmp"
mv "$evidence_ledger_summary_phrase/volume-1/verification-reports/chapter-01.tmp" "$evidence_ledger_summary_phrase/volume-1/verification-reports/chapter-01.md"
expect_fail "verification evidence ledger summary phrase not found in manifest ledger" "$evidence_ledger_summary_phrase"

evidence_ledger_state_phrase="$tmp/evidence-ledger-state-phrase"
copy_fixture "$evidence_ledger_state_phrase"
sed 's/The door has not opened/The door has opened/' "$evidence_ledger_state_phrase/volume-1/verification-reports/chapter-01.md" > "$evidence_ledger_state_phrase/volume-1/verification-reports/chapter-01.tmp"
mv "$evidence_ledger_state_phrase/volume-1/verification-reports/chapter-01.tmp" "$evidence_ledger_state_phrase/volume-1/verification-reports/chapter-01.md"
expect_fail "verification evidence ledger state phrase not found in narrative-state" "$evidence_ledger_state_phrase"

evidence_path="$tmp/evidence-path"
copy_fixture "$evidence_path"
cp "$evidence_path/volume-1/verification-reports/chapter-01.md" "$evidence_path/volume-1/chapter-01-evidence.md"
sed 's/`verification-reports\/chapter-01.md`/`chapter-01-evidence.md`/' "$evidence_path/volume-1/verification-manifest.md" > "$evidence_path/volume-1/verification-manifest.tmp"
mv "$evidence_path/volume-1/verification-manifest.tmp" "$evidence_path/volume-1/verification-manifest.md"
expect_fail "verification evidence report outside verification-reports" "$evidence_path"

evidence_traversal="$tmp/evidence-traversal"
copy_fixture "$evidence_traversal"
mkdir -p "$evidence_traversal/verification-reports"
cp "$evidence_traversal/volume-1/verification-reports/chapter-01.md" "$evidence_traversal/verification-reports/chapter-01.md"
sed 's/`verification-reports\/chapter-01.md`/`verification-reports\/..\/..\/verification-reports\/chapter-01.md`/' "$evidence_traversal/volume-1/verification-manifest.md" > "$evidence_traversal/volume-1/verification-manifest.tmp"
mv "$evidence_traversal/volume-1/verification-manifest.tmp" "$evidence_traversal/volume-1/verification-manifest.md"
expect_fail "verification evidence path traversal" "$evidence_traversal"

printf 'verification manifest negative tests ok\n'
