# Task 15 — Task 12 LineOfBusiness Fix + MR-1 Parity Update
**Supplements:** `COWORK_OUTPUTS/round2/12_sharepoint_audit_round2_additions.md`
*Correction per final decisions doc Item #5 — LineOfBusiness choices changed; P&C removed*
*MR-1 list parity rule applied — both Leads and Home Quotes must receive identical columns*
*Documented: 2026-05-04*

---

## What Changed From Task 12

### LineOfBusiness Column — Choices Corrected

Task 12 specified these choices for `LineOfBusiness`:
> P&C, Auto, Home, Life, Commercial

**Item #5 of the final decisions doc overrides this:**

> "LineOfBusiness choices = Auto, Home, Life, Commercial. P&C is removed. The Dataverse option set is not relevant to this SharePoint column."

**Corrected choices (use these — ignore Task 12's list):**

| # | Choice Value |
|---|-------------|
| 1 | Auto |
| 2 | Home |
| 3 | Life |
| 4 | Commercial |

P&C is removed entirely. Do not add it. The `ac_lineofbusiness` Dataverse option set (which includes P&C) is an inert artifact with no role in this CRM.

---

## MR-1 — List Parity Rule

**Rule (from final decisions meta-rules):**

> "Leads and Home Quotes are one schema in two physical lists. Every column add or change on one list must be applied to the other in the same session. No exceptions."

Task 12 already specified that all 4 new columns should be added to both lists. This file confirms MR-1 compliance and provides a corrected column spec for `LineOfBusiness` as the authoritative source.

---

## Corrected Column Specs (Authoritative)

The following supersedes the LineOfBusiness entry in Task 12. All other columns (LostReason, RequoteMonthsOut, RequoteDate) are correct as written in Task 12.

### LineOfBusiness — Corrected

| Property | Value |
|----------|-------|
| Display Name | `LineOfBusiness` |
| Internal Name | `LineOfBusiness` |
| Type | **Choice** |
| Required | No |
| Default value | *(blank)* |
| Allow fill-in choices | No |

**Choices (enter exactly as shown — 4 choices, no P&C):**
1. Auto
2. Home
3. Life
4. Commercial

**Add to:** Both the **Leads** list AND the **Home Quotes** list in the same session per MR-1.

---

## MR-1 Column Add Checklist (All 4 Columns, Both Lists)

Run through this checklist in a single SharePoint session. Add to Leads first, then Home Quotes.

### Leads List (`/Lists/Leads`)

- [ ] **LostReason** — Choice — 6 values: Price, Competitor, No Response, Not Qualified, Timing, Other
- [ ] **RequoteMonthsOut** — Number — min 1, max 24, 0 decimal places
- [ ] **RequoteDate** — Date and Time — Date Only format
- [ ] **LineOfBusiness** — Choice — **4 values: Auto, Home, Life, Commercial** ← corrected from Task 12

### Home Quotes List (`/Lists/Home%20Quotes`)

- [ ] **LostReason** — Choice — same 6 values as above
- [ ] **RequoteMonthsOut** — Number — same settings as above
- [ ] **RequoteDate** — Date and Time — Date Only format
- [ ] **LineOfBusiness** — Choice — **4 values: Auto, Home, Life, Commercial** ← same as Leads

> **⚠️ Critical:** The date auto-fill formula in the Home Quotes list (`=[Today]` or equivalent calculated column) must still function after adding these columns. Test it: open a new Home Quotes item form and confirm the Date field auto-populates before saving. If it doesn't, the MR-1 formula was broken by a column add — restore it before proceeding.

---

## Calendar Events List Columns (Unchanged from Task 12)

No changes to the Calendar Events column spec. Still required:

| Column | Type | Notes |
|--------|------|-------|
| `EventType` | Choice | Add "Re-Quote Check-In", "Follow-Up", "Appointment", "Other" if not present |
| `LeadRef` | Lookup → Leads.Title | Links calendar event back to the source lead |

---

## Verification REST Query (Updated for Corrected Choices)

After adding all columns, verify the LineOfBusiness choices are correct (4, not 5):

```
https://alfains.sharepoint.com/teams/1047889-ADAMSCOSBY/_api/web/lists/getbytitle('Leads')/fields?$filter=Title eq 'LineOfBusiness'&$select=Title,InternalName,TypeAsString,Choices
```

**Expected response:** TypeAsString = "Choice", Choices array = ["Auto", "Home", "Life", "Commercial"] (4 items, no "P&C").

---

## Version Precedence

| Document | LineOfBusiness Choices | Use? |
|----------|----------------------|------|
| `12_sharepoint_audit_round2_additions.md` | P&C, Auto, Home, Life, Commercial (5 items) | ❌ Superseded |
| `15_task12_lineofbusiness_fix.md` *(this file)* | Auto, Home, Life, Commercial (4 items) | ✅ **Use this** |

---

*File: `COWORK_OUTPUTS/round2/15_task12_lineofbusiness_fix.md`*
*Next: `16_agent_claims_syntax_fixes.md` — Claims-syntax patches for all flows that write to Person/Group columns*
