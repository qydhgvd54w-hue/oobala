# Task 4 — SharePoint List Health Audit
**Adams Cosby CRM · Schema Analysis**
*Site: `https://alfains.sharepoint.com/teams/1047889-ADAMSCOSBY`*
*Audited: 2026-05-03*

---

## Authentication Note

A live REST API call (`/_api/web/lists/getbytitle('Leads')/fields`) was not executed against the tenant during this audit. SharePoint REST API access from outside the tenant requires OAuth token authentication with MFA, which cannot be performed non-interactively from this environment without a registered app and client credentials. Rather than attempt an auth call that would result in a 401/403 and produce no useful data, this audit is based on:

- The 30-column schema described in the project brief
- Standard SharePoint list behavior and field naming conventions
- Known issues flagged in the project context (e.g., "Home Quotes is an accidental duplication of Leads")

**To run the live REST audit yourself:** Open PowerShell on a machine logged into the alfains tenant and run:
```powershell
$site = "https://alfains.sharepoint.com/teams/1047889-ADAMSCOSBY"
$listName = "Leads"
Invoke-RestMethod -Uri "$site/_api/web/lists/getbytitle('$listName')/fields?`$select=Title,InternalName,TypeAsString,Required,Hidden" `
  -UseDefaultCredentials | Select-Object -ExpandProperty value | Format-Table Title,InternalName,TypeAsString,Required -AutoSize
```

---

## 1. Schema Comparison — Leads vs. Home Quotes

Both lists are described as having identical 30-column schemas, which is the core architectural issue. The table below compares expected columns:

| Display Name | Expected Internal Name | Type | In Leads | In Home Quotes | Notes |
|---|---|---|---|---|---|
| Title | Title | Single line text | ✅ | ✅ | Lead/contact name |
| Phone Number | Phone_x0020_Number | Single line text | ✅ | ✅ | Space-encoded in internal name |
| Email | Email | Single line text | ✅ | ✅ | |
| Risk Address | Risk_x0020_Address | Single line text | ✅ | ✅ | Also may exist as a Location column — see §2 |
| Source | Source | Choice | ✅ | ✅ | |
| Source Detail | Source_x0020_Detail | Single line text | ✅ | ✅ | |
| Status | Status | Choice | ✅ | ✅ | Values: Working, Quoted, Bound, Lost (assumed) |
| Notes | Notes | Multiple lines of text | ✅ | ✅ | |
| Agent | Agent | Person or Group | ✅ | ✅ | |
| Modified | Modified | Date/Time | ✅ | ✅ | System column — auto-managed |
| DOB | DOB | Date/Time | ✅ | ✅ (assumed) | See §4 — naming inconsistency risk |
| Spouse's Phone | Spouse_x0027_s_x0020_Phone | Number | ✅ | ✅ (assumed) | May also exist as text — see §2 |
| QuoteID | QuoteID | Calculated (or text) | ✅ | ✅ (assumed) | See §2 — duplicate type risk |
| Quote Documents (related) | RelatedQuote | Lookup | ✅ | ❓ | Quote Documents links to Leads.QuoteID — unclear if Home Quotes has same linkage |
| ID | ID | Counter | ✅ | ✅ | System column |
| Created | Created | Date/Time | ✅ | ✅ | System column |
| Created By | Author | Person or Group | ✅ | ✅ | System column |
| Modified By | Editor | Person or Group | ✅ | ✅ | System column |

> **⚠️ Core Finding:** Home Quotes being a duplicate of Leads is the single largest structural problem in this CRM. Every process, flow, and Power App screen that handles Leads must be duplicated or made generic to also handle Home Quotes — or the two lists need to be merged. See §7 for the recommendation.

---

## 2. Duplicate Columns Flagged

### 2a — Risk Address (two probable representations)
SharePoint sometimes stores address data in both a **Location** column (structured, pulls from Bing Maps) and a plain **text** column. If both exist:

- `Risk_x0020_Address` (Single line text) — manually typed
- A Location column variant — structured, with lat/long and formatted address

**Risk:** Power Apps may bind to one but not the other. Flows may write to one and read from the other. Audit by checking the list's column list in SharePoint settings.

### 2b — Spouse's Phone (Number vs. Text)
A "Spouse's Phone" column stored as Number type will strip leading zeros, break 10-digit formatting, and fail for entries like `(251) 555-1234`. If there is also a text version, one of them is authoritative and the other is stale.

### 2c — QuoteID (Calculated vs. Text)
If QuoteID is a Calculated column (formula-generated) AND a separate plain text column exists, edits to one don't propagate to the other. The Quote Documents list's `RelatedQuote` lookup must target one specific column — whichever one it doesn't target is dead weight.

---

## 3. Stale Columns (Likely Never Populated)

Based on the known schema, the following are flagged as high-probability stale (requires live count to confirm):

| Column | Reason for Suspicion |
|--------|---------------------|
| Any Location-type column | Location columns require explicit user interaction; rarely populated in data-entry flows |
| Spouse's Phone | Rarely collected for insurance prospects unless explicitly prompted |
| DOB | Not typically required until application stage; may be empty in prospect records |
| Any custom metadata columns added during early CRM setup but not surfaced in the Canvas app UI | If a column isn't visible in the app, it's never filled |

---

## 4. Naming Inconsistencies

| Issue | Detail | Risk |
|-------|--------|------|
| "DOB" vs "DateOfBirth" | If Activities or other lists use "DateOfBirth" while Leads uses "DOB", cross-list lookups and flow bindings will mismatch | Medium |
| Space-encoded internal names | Columns with spaces in display names get `_x0020_` in their internal names (e.g., `Phone_x0020_Number`). Power Automate dynamic content often shows display names, but ODATA filter queries require internal names. | High — causes flow build errors if not known |
| "Title" used for lead name | SharePoint's "Title" column is the default required field. Using it for the contact's full name is fine, but it means you can't also have a "Title" field for Mr./Ms. prefix without renaming. | Low |
| Source vs Source Detail | These are distinct, which is good. Ensure they're consistently named across Leads and Home Quotes — the internal names likely differ (`Source` vs `Source_x0020_Detail`). | Low |

---

## 5. Unused / Empty Columns

Cannot confirm without a live data sample, but the following should be investigated:

- `Audit Log` list — if it exists in SharePoint but flows haven't been built yet, every row is empty
- `Calendar Events` list — if no calendar integration exists in the Canvas app yet, likely empty
- `Document Library` — may have documents but no metadata columns populated

**Recommended action:** Run this query against each list to find zero-population columns:
```powershell
# For each column, count non-null values in last 100 items
# (run interactively in SharePoint REST API or PnP PowerShell)
Get-PnPListItem -List "Leads" -PageSize 100 | Group-Object { $_["ColumnInternalName"] } | Where-Object { $_.Count -eq 0 }
```

---

## 6. Required Field Analysis

| Column | Currently Required? | Should Be Required? | Notes |
|--------|--------------------|--------------------|-------|
| Title (Lead Name) | Yes (default) | Yes | ✅ Correct |
| Phone Number | Unknown | Yes — for contact | Should be required; leads without a phone number are unworkable |
| Email | Unknown | Recommended | Not strictly required but enables email templates |
| Source | Unknown | Yes | Required for attribution reporting |
| Agent | Unknown | Yes | Required for flow notifications; empty Agent breaks Flow 3a |
| Status | Unknown | Yes | Required for Flow 3b to function correctly |
| Risk Address | Unknown | For home leads only | Conditional requirement — hard to enforce in SharePoint without Power Apps validation |

---

## 7. Cleanup Recommendations

### 🔴 Critical — Fix Before Building Flows

1. **Merge Leads and Home Quotes into one list.** This is the most impactful cleanup. Add a "Coverage Type" choice column (Auto, Home, Life, Commercial) to the Leads list and retire Home Quotes. Every flow, formula, and screen only needs to be built once. Estimated effort: 2–3 hours including data migration if any Home Quotes rows exist.

2. **Add LostReason column to Leads.** Flow 3b's Lost path and re-quote logic depend on this. Add as a Choice column: Price, Competitor, No Response, Not Qualified, Timing, Other.

3. **Confirm and standardize Agent column type.** The Agent column must be a Person/Group column (not text) for flow email lookups to work. If it's currently text, flows cannot reliably extract the agent's email address.

### 🟡 Nice to Have — Fix Before Launch

4. **Audit and remove duplicate Risk Address columns.** Keep only one — the plain text column is simpler and more compatible across flows and Power Apps.

5. **Change Spouse's Phone to Single Line Text.** A Number type column for a phone number is wrong. If data exists, back it up first.

6. **Make Phone Number, Source, Agent, and Status required.** Prevents incomplete leads from being saved and breaking downstream flows.

7. **Add a CoverageType or LineOfBusiness column to Leads.** Needed by Flow 3b for auto vs home re-quote timing. Can map to the `ac_lineofbusiness` Dataverse option set values (P&C, Alfa Agency, Life).

### 🟢 Cosmetic — Low Priority

8. **Rename "Title" display name to "Lead Name" or "Contact Name."** The internal name stays `Title`, but the display name shown to users would be clearer.

9. **Add column descriptions** in SharePoint list settings for every custom column. These descriptions appear as tooltips in SharePoint and Power Apps, which helps the team understand what goes where.

---

## 8. Risk of Cleanup

| Cleanup Action | What Breaks If Done Incorrectly |
|----------------|--------------------------------|
| Merge Home Quotes into Leads | Any Canvas app screens bound to `Home Quotes` list data source must be updated. Any flows using `Home Quotes` as a trigger list must be updated. If Home Quotes has existing data rows, they must be migrated before the list is archived. |
| Delete duplicate Risk Address column | If Power Apps formulas reference the deleted column by internal name, the app will show formula errors on next edit. Check all `.fx.yaml` files for `Risk_x0020_Address` or similar before deleting. |
| Change Spouse's Phone to text | Existing Number values will be preserved as text. Low risk. |
| Add Required constraints to existing columns | Any existing rows that are missing data in the newly-required field will not be editable until the field is populated. For a list with existing leads, audit for nulls first. |
| Delete QuoteID calculated version | Quote Documents' `RelatedQuote` lookup must still resolve. If it targets the calculated column, switching to text breaks the lookup. Verify lookup target before deleting. |
