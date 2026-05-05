# Task 12 — SharePoint Column Additions (Round 2)
**Supplements:** `COWORK_OUTPUTS/04_sharepoint_audit.md`
*These are specs only — Alec executes the column adds*
*Documented: 2026-05-03*

---

## Overview

Four new columns must be added to the **Leads** SP list before Flow 3b can be built. The same four columns should also be added to **Home Quotes** to keep both lists in sync (or add only to Leads if you proceed with the list merge).

Additionally, two columns must be added or verified on the **Calendar Events** list for Flow 3b's re-quote scheduling to work.

---

## New Leads List Columns

### Column 1 — LostReason

| Property | Value |
|----------|-------|
| Display Name | `LostReason` |
| Internal Name | `LostReason` *(no spaces — will not be space-encoded)* |
| Type | **Choice** |
| Required | No *(flow handles the missing-value case with a reminder email)* |
| Default value | *(blank)* |
| Allow fill-in choices | No |

**Choices (enter exactly as shown):**
1. Price
2. Competitor
3. No Response
4. Not Qualified
5. Timing
6. Other

**Used by:** Flow 3b Lost branch (Step 4a — LostReason check). Daily Digest future reporting.

---

### Column 2 — RequoteMonthsOut

| Property | Value |
|----------|-------|
| Display Name | `RequoteMonthsOut` |
| Internal Name | `RequoteMonthsOut` |
| Type | **Number** |
| Required | No |
| Default value | *(blank)* |
| Min value | 1 |
| Max value | 24 |
| Decimal places | 0 |

**Used by:** Flow 3b Lost branch (Step 4b — re-quote date calculation). If set, calculates `RequoteDate = LostDate + (RequoteMonthsOut × 30 days)`. Ignored if RequoteDate is explicitly set.

**Typical values agents will enter:** 5 (auto re-quote), 11 (home re-quote). No hard constraint in the column — agent can type any number 1–24.

---

### Column 3 — RequoteDate

| Property | Value |
|----------|-------|
| Display Name | `RequoteDate` |
| Internal Name | `RequoteDate` |
| Type | **Date and Time** |
| Date format | Date Only *(no time needed for a re-quote reminder)* |
| Required | No |
| Default value | *(blank)* |

**Used by:** Flow 3b Lost branch (Step 4b). If set, this exact date is used for the Calendar Event — overrides RequoteMonthsOut. Agent sets this when they want to schedule a re-quote on a specific date rather than calculating from months.

**Logic priority:** RequoteDate (explicit) > RequoteMonthsOut (calculated) > neither (no re-quote scheduled).

---

### Column 4 — LineOfBusiness

| Property | Value |
|----------|-------|
| Display Name | `LineOfBusiness` |
| Internal Name | `LineOfBusiness` |
| Type | **Choice** |
| Required | No |
| Default value | *(blank)* |
| Allow fill-in choices | No |

**Choices:**
1. P&C
2. Auto
3. Home
4. Life
5. Commercial

**Notes:** This column mirrors the `ac_lineofbusiness` Dataverse option set (P&C, Alfa Agency, Life) from Customizations.xml, but expands it with Auto, Home, and Commercial for more granular pipeline filtering. The Dataverse option set can be updated to match if needed. This column is used for reporting/filtering in the dashboard; it is not yet required by any flow but will be needed for future re-quote template selection (auto vs home email templates 06 and 07).

---

## Step-by-Step Add Procedure (Repeat for Each Column)

### For the Leads List:

1. Navigate to: `https://alfains.sharepoint.com/teams/1047889-ADAMSCOSBY/Lists/Leads`
2. Click **+ Add column** (rightmost column header, or Settings gear → List settings → Create column)
3. Select the column type per the table above
4. Enter the **Display Name** exactly as shown *(no spaces for LostReason, RequoteMonthsOut, RequoteDate, LineOfBusiness — this ensures clean internal names)*
5. For Choice columns: enter each choice on its own line in the "Choices" box
6. Leave "Required" set to **No**
7. Leave default value **blank** for all four columns
8. Click **Save**
9. Verify the column appears in the default list view

**Repeat steps 1–9 for the Home Quotes list** (same columns, same settings):
`https://alfains.sharepoint.com/teams/1047889-ADAMSCOSBY/Lists/Home%20Quotes`

---

## Calendar Events List — Required Columns

Flow 3b writes to the Calendar Events list. Verify or add these columns:

### Column A — EventType

| Property | Value |
|----------|-------|
| Display Name | `EventType` |
| Type | Choice |
| Required | No |

**Choices to add (may have existing values — add without removing them):**
- `Re-Quote Check-In`
- `Follow-Up`
- `Appointment`
- `Other`

### Column B — LeadRef (Lookup)

| Property | Value |
|----------|-------|
| Display Name | `LeadRef` |
| Type | **Lookup** |
| Get information from | `Leads` list |
| In this column | `Title` |
| Required | No |

This column links a Calendar Event back to the specific Lead record it was created for. It's what allows the dashboard's Calendar screen to show which lead a re-quote check-in is for when the agent clicks on the event.

---

## Verification REST Query

After adding all columns, confirm they exist by running this in a browser while logged into the tenant, or in PnP PowerShell:

**Browser REST check** (paste URL, must be logged into alfains tenant):
```
https://alfains.sharepoint.com/teams/1047889-ADAMSCOSBY/_api/web/lists/getbytitle('Leads')/fields?$filter=Title eq 'LostReason' or Title eq 'RequoteMonthsOut' or Title eq 'RequoteDate' or Title eq 'LineOfBusiness'&$select=Title,InternalName,TypeAsString&$orderby=Title
```

**Expected response:** 4 field objects with TypeAsString values of "Choice", "Number", "DateTime", "Choice" respectively.

**PnP PowerShell equivalent:**
```powershell
Connect-PnPOnline -Url "https://alfains.sharepoint.com/teams/1047889-ADAMSCOSBY" -UseWebLogin
Get-PnPField -List "Leads" | Where-Object { $_.Title -in @('LostReason','RequoteMonthsOut','RequoteDate','LineOfBusiness') } | Select-Object Title, InternalName, TypeAsString | Format-Table
```

---

## Post-Add Validation Checklist

- [ ] LostReason added to Leads list — 6 choices visible in dropdown
- [ ] RequoteMonthsOut added to Leads list — accepts whole numbers
- [ ] RequoteDate added to Leads list — Date Only format
- [ ] LineOfBusiness added to Leads list — 5 choices visible
- [ ] All 4 columns also added to Home Quotes list
- [ ] EventType column exists on Calendar Events list with "Re-Quote Check-In" as an option
- [ ] LeadRef lookup column exists on Calendar Events list pointing to Leads.Title
- [ ] Open a test lead and confirm all 4 new fields appear as editable
- [ ] Confirm no existing required-field errors on existing lead records after adding columns

---

## Impact on Existing Data

Adding new optional (non-required) columns to an SP list with existing rows is safe — existing rows will simply have blank values in the new columns. No data migration is needed. Existing Power Apps formulas and flow bindings are not affected unless they explicitly reference these column names (which they don't yet, since the columns don't exist).
