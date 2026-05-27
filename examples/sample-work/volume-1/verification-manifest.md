# Verification Manifest

## Volume

- Work: The Lower Archive.
- Volume: 1.
- Last updated: sample fixture.

## Verified Drafts

| Draft Path | Draft SHA256 | Canon Snapshot SHA256 | Beat / Chapter | Final Otaku Verdict | Style Drift Audit | Character Voice Audit | Ledger Update Summary | Approved Unknowns | Verification Evidence |
|------------|--------------|------------------------|----------------|---------------------|-------------------|-----------------------|-----------------------|-------------------|-----------------------|
| `drafts/chapter-01.md` | e177ff1d15e193e65745d2d239e1501a66e417e83d877245c72d7a99d21a5971 | 90dc60dc3127ac7b1afd287309971a32ece5bffe89eb52fd9bd592b472fa76dd | Chapter 1 locked prefix | PASS | PASS | PASS | Narrative state records 02:10 lower archive corridor, key in left coat pocket, right shoulder injury, unopened door, and I-an's Director Chae knowledge boundary. | None | `verification-reports/chapter-01.md` |

## Publication Gate

- Every packaged draft must be listed above.
- The Verified Drafts table must keep the exact column order shown in this template.
- Each packaged draft must appear exactly once, and every listed draft must exist on disk.
- Every packaged draft must match the recorded `Draft SHA256`.
- Every packaged draft must match the recorded `Canon Snapshot SHA256`.
- Every packaged draft must have `Final Otaku Verdict: PASS`.
- Every packaged draft must have `Style Drift Audit: PASS`.
- Every packaged draft must have `Character Voice Audit: PASS`.
- Every packaged draft must have a ledger update summary or `No durable ledger changes`.
- Every packaged draft must have a Verification Evidence report matching the same draft path, `Draft SHA256`, `Canon Snapshot SHA256`, final Otaku PASS, Style Drift Audit PASS, Character Voice Audit PASS, and ledger update summary.
- Do not publish if any draft is `FAIL`, `PENDING`, `UNVERIFIED`, or missing.
