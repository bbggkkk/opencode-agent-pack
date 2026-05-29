# Writing Session

## Session Identity

- Session ID: TBD
- Status: IDLE
- Operation Type: TBD
- Requested Scope of Work: TBD
- Completion Target: TBD
- Seed Summary: TBD
- Macro Skeleton Reference: TBD
- Length Contract Reference: TBD
- Active Work Path: TBD
- Active Volume Path: TBD
- Target Draft: TBD
- Started At: TBD
- Last Updated: TBD

## Recovery Contract

- Last Stable Stage: NONE
- Last Completed Beat / Span: NONE
- Last Verified Draft SHA256: NONE
- Last Verified Canon Snapshot SHA256: NONE
- Last Verification Manifest Row: NONE
- Last Verification Evidence: NONE
- Last Narrative State Update: NONE
- Last Git Commit: NONE
- Resume Policy: validate hashes and manifest before continuing; never trust unverified temporary text

## Current Unit

- Current Branch ID: TBD
- Unit Type: TBD
- Unit ID: TBD
- Unit Target Characters: TBD
- Unit Minimum Characters: TBD
- Unit Actual Characters: TBD
- Unit Remaining Characters: TBD
- Scene / Chapter Outline Reference: TBD
- Accumulated Prefix Source: TBD
- Editable Span Source: TBD
- Locked Before Context SHA256: NONE
- Locked After Context SHA256: NONE
- Temporary Work File: `.session/current-work.md`
- Current Stage: IDLE
- Next Action: TBD

## Macro Skeleton

| Branch ID | Purpose | Required Setup | Required Payoff | Character / Emotional Movement | Constraints | Endpoint | Target Chars | Min Chars |
|-----------|---------|----------------|-----------------|--------------------------------|-------------|----------|--------------|-----------|
| TBD | TBD | TBD | TBD | TBD | TBD | TBD | TBD | TBD |

## Length Contract

- Count Method: Unicode character count of canonical draft body text, excluding frontmatter, manifests, verification reports, and session metadata
- Total Target Characters: TBD
- Total Minimum Characters: TBD
- Allowed Variance: TBD
- User Approved Length Change: NONE

## Length Budget

| Scope ID | Scope Type | Draft Path | Target Chars | Min Chars | Actual Chars | Remaining Chars | Status | Evidence |
|----------|------------|------------|--------------|-----------|--------------|-----------------|--------|----------|
| TBD | TBD | TBD | TBD | TBD | TBD | TBD | TBD | TBD |

## Execution Unit Queue

| Unit ID | Parent Branch | Unit Type | Required Outcome | Target Chars | Min Chars | Actual Chars | Remaining Chars | Status | Evidence |
|---------|---------------|-----------|------------------|--------------|-----------|--------------|-----------------|--------|----------|
| TBD | TBD | TBD | TBD | TBD | TBD | TBD | TBD | TBD | TBD |

## Skeleton Drift Log

| Unit ID | Drift Check Result | Decision | Rationale / Approval Evidence |
|---------|--------------------|----------|-------------------------------|
| TBD | TBD | TBD | TBD |

## Length Check Log

| Scope ID | Count Method | Count Command / Evidence | Actual Chars | Min Chars | Remaining Chars | Verdict |
|----------|--------------|--------------------------|--------------|-----------|-----------------|---------|
| TBD | TBD | TBD | TBD | TBD | TBD | TBD |

## Pending Verification

- Writer Output: NONE
- Initial Otaku Report: NONE
- Editor Output: NONE
- Final Otaku Verdict: NONE
- Length Verification: NONE
- Style Drift Audit: NONE
- Character Voice Audit: NONE
- Ledger Update Pending: NONE
- Manifest Update Pending: NONE

## Pipeline Step Ledger

| Step ID | Required Step | Current Unit / Span | Status | Evidence |
|---------|---------------|---------------------|--------|----------|
| TBD | TBD | TBD | TBD | TBD |

Completion rule: every mandatory step for the active route must have concrete evidence before `Status` can be set to `COMPLETED`. Do not mark steps complete from assumptions, simulations, summaries, or user requests to skip verification. Evidence can include invoked sub-agent name, source files read, validator command/result, Otaku report, Editor audit result, draft hash, canon snapshot hash, manifest row, Verification Evidence path, and commit hash.

Scope rule: `Status` cannot be set to `COMPLETED` until the Requested Scope of Work and Completion Target are satisfied. Do not stop at a beat, paragraph, scene, chapter, or intermediate revision pass when the user's initial request requires a larger unit such as a full section, full book, or full work.

Growth rule: do not start leaf drafting until the Macro Skeleton and Execution Unit Queue exist. Every drafted unit must map to a Parent Branch, and every completed unit must have a Skeleton Drift Log entry proving it still serves the branch or that an approved/safe skeleton update was recorded.

Length rule: do not start leaf drafting until the Length Contract and Length Budget exist. After every consolidation, count actual characters from the canonical draft file and update Actual Chars and Remaining Chars. Do not mark any unit, branch, chapter, volume, or work complete while its Length Budget Status is `UNDER_LENGTH`.

## Resume Checklist

- [ ] Confirm Requested Scope of Work and Completion Target are recorded.
- [ ] Confirm Macro Skeleton and Execution Unit Queue exist before drafting.
- [ ] Confirm Length Contract and Length Budget exist before drafting.
- [ ] Confirm every completed unit has a Length Check Log entry with count evidence.
- [ ] Confirm Actual Chars and Remaining Chars were refreshed from canonical draft files.
- [ ] Confirm no required Length Budget row is UNDER_LENGTH before marking completion.
- [ ] Confirm each completed unit has a Skeleton Drift Log entry.
- [ ] Confirm target draft exists or is intentionally new.
- [ ] Confirm target draft hash matches Last Verified Draft SHA256, unless Last Stable Stage is NONE.
- [ ] Confirm canon snapshot hash matches Last Verified Canon Snapshot SHA256, unless Last Stable Stage is NONE.
- [ ] Confirm verification-manifest.md contains Last Verification Manifest Row, unless Last Stable Stage is NONE.
- [ ] Confirm Last Verification Evidence exists and matches the manifest row, unless Last Stable Stage is NONE.
- [ ] Confirm narrative-state.md includes Last Narrative State Update, unless Last Stable Stage is NONE.
- [ ] Confirm locked context hashes before applying any revision.
- [ ] Re-run verification for any temporary work before applying or consolidating it.

## Recovery Log

- TBD
