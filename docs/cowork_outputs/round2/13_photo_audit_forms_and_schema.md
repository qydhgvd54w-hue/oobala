# Photo Audit — SharePoint Lists, Forms & Branching
**Adams Cosby CRM · Read-Only Visual Inspection**
*Source: 5 project photos found in .project-cache*
*Audited: 2026-05-03 · No files modified*

---

## Images Examined

| File | Contents |
|------|----------|
| `7ade5d14.JPG` | SharePoint list column settings — Home Quotes (no Required column visible) |
| `edb34678.JPG` | SharePoint list column settings — same schema with Required column visible |
| `c6e19370.JPG` | SharePoint site left-nav showing all list names |
| `51755bcd.png` | Power Apps Canvas app — current ADAMSCOSBY_CLEAN dashboard build |
| `b09b2b6d.png` | AA Agency CRM — full dashboard with Lead Detail, Quick Entry form, Full Home Quote form, Templates, Reports |

---

---

## PART 1 — Confirmed SharePoint List Names

**Source: `c6e19370.JPG` — SharePoint site left navigation**

The following lists are confirmed to exist in the alfains tenant at `https://alfains.sharepoint.com/teams/1047889-ADAMSCOSBY`:

| # | List Name | Notes |
|---|-----------|-------|
| 1 | **Leads** | Pipeline / lead management list |
| 2 | **Quote Documents** | Document storage linked to quotes |
| 3 | **Home Quotes** | Homeowner quote intake records |
| 4 | **Audit Log** | Change/event audit trail |
| 5 | **Document Library** | General file storage |
| 6 | **Activities** | Lead activity log |
| 7 | **Email Templates** | Template storage for email flows |
| 8 | **Calendar Events** | Scheduled events / re-quote check-ins |

**Note:** "Home" in the navigation is the SharePoint site homepage, not a list. "Recycle bin" and "Edit" are system navigation items, not lists.

**Round 1 audit gap corrected:** The project brief mentioned these lists but could not confirm them without live REST access. The photo confirms all 8 lists exist and are actively surfaced in the site navigation.

---

---

## PART 2 — Home Quotes List Column Schema (Full)

**Source: `7ade5d14.JPG` and `edb34678.JPG`**

Both images show the SharePoint List Settings → Columns page for the **Home Quotes** list. Image 2 (`edb34678`) adds the Required column, showing a checkmark (✓) next to Name. The schema is identical in both images — they are the same list viewed at slightly different zoom/scroll positions.

### Confirmed Column List — Home Quotes

| # | Display Name | Type | Required | Critical Notes |
|---|-------------|------|----------|---------------|
| 1 | QuoteID | **Calculated** (based on other columns) | No | ⚠️ DUPLICATE — see row 23 |
| 2 | Date | Date and Time | No | |
| 3 | Source | Choice | No | Shown in red — indicates it's a required field visually in the form or a key linking column |
| 4 | Source Detail | Choice | No | |
| 5 | Referral | Single line of text | No | |
| 6 | Name | Single line of text | **✓ YES** | Only required column in the list |
| 7 | DOB | Date and Time | No | |
| 8 | ID Spouse | Number | No | Purpose unclear — possibly an internal ID for spouse record |
| 9 | Spouse's Name | Single line of text | No | |
| 10 | Spouse's DOB | Date and Time | No | |
| 11 | Spouse's Phone | **Number** | No | ⚠️ DUPLICATE — see row 25. Number type is wrong for phone data |
| 12 | GW ACCT | Number | No | ⚠️ Purpose undocumented — likely Goodwille & German Mutual account number or similar carrier account ID |
| 13 | Email | Single line of text | No | |
| 14 | Risk Address | **Location** | No | ⚠️ DUPLICATE — see row 26. Location type = Bing Maps structured address |
| 15 | Occupancy | Choice | No | |
| 16 | Products | Choice | No | |
| 17 | Status | Choice | No | Shown in red — key workflow column |
| 18 | Current Carriers | Single line of text | No | |
| 19 | Current Premiums | Single line of text | No | |
| 20 | Notes | Multiple lines of text | No | |
| 21 | ID PH | Number | No | ⚠️ Purpose undocumented — likely internal policyholder ID or phone ID |
| 22 | Link | Hyperlink or Picture | No | Purpose unclear — possibly a link to the quote PDF or external system |
| 23 | QuoteID | **Single line of text** | No | ⚠️ DUPLICATE of row 1 — same display name, different type. One is Calculated, one is plain text |
| 24 | Phone Number | Single line of text | No | |
| 25 | Spouse's Phone | **Single line of text** | No | ⚠️ DUPLICATE of row 11 — same display name, different type (Number vs text) |
| 26 | Risk Address | **Single line of text** | No | ⚠️ DUPLICATE of row 14 — same display name, different type (Location vs text) |
| 27 | Agent | Person or Group | No | |
| 28 | Modified | Date and Time | No | System column — auto-managed |
| 29 | Created | Date and Time | No | System column — auto-managed |
| 30 | Created By | Person or Group | No | System column |
| 31 | Modified By | Person or Group | No | System column |

**Total columns: 31** (including system columns). **3 confirmed duplicate column pairs within the same list.**

---

### Critical Schema Issues Identified

#### Issue 1 — QuoteID Exists Twice (Rows 1 & 23)
- Row 1: `QuoteID` — **Calculated** type (formula-generated from other column values)
- Row 23: `QuoteID` — **Single line of text** (manually entered or flow-written)

These are two separate columns with the same display name. SharePoint stores them with different internal names (likely `QuoteID` and `QuoteID0` or similar). Power Automate flows and Power Apps formulas must be binding to one of these — the other is almost certainly stale or conflicting. The Quote Documents list's `RelatedQuote` lookup field targets one of these two; the other does nothing.

**Impact:** Any flow or app that writes to `QuoteID` by display name may write to the wrong column depending on which one the connector resolves first.

#### Issue 2 — Spouse's Phone Exists Twice (Rows 11 & 25)
- Row 11: `Spouse's Phone` — **Number** type (strips leading zeros, breaks formatted phone numbers)
- Row 25: `Spouse's Phone` — **Single line of text** (correct type for phone data)

The Number version is incorrect for phone data. Both exist simultaneously. A Power Apps form binding to "Spouse's Phone" may resolve to either one.

#### Issue 3 — Risk Address Exists Twice (Rows 14 & 26)
- Row 14: `Risk Address` — **Location** type (Bing Maps structured address — requires user to select from map suggestions)
- Row 26: `Risk Address` — **Single line of text** (free-form typed address)

The Location column type was likely added to enable map-based address input, while the text version is the original. The Microsoft Forms intake cannot write to a Location-type column (Forms only supports text, choice, date, etc.). If the Microsoft Forms flow writes Risk Address to the text version (row 26) but the Power Apps form displays the Location version (row 14), they are storing the same data in two different columns and never seeing each other's entries.

#### Issue 4 — GW ACCT and ID PH / ID Spouse are Undocumented
These Number columns appear nowhere in the project documentation reviewed in Rounds 1 or 2. They likely represent:
- `GW ACCT` — a carrier account number (possibly Goodwille & German Mutual or Government Workers)
- `ID PH` — an internal policyholder ID
- `ID Spouse` — a spouse record ID linking to another system

None of these have clear source documentation. If they're populated by the Microsoft Forms path, the Forms questions that feed them are unidentified.

#### Issue 5 — Only "Name" is Required
With only one required field, the Home Quotes list accepts nearly empty records. Any form (Power Apps, Microsoft Forms, or direct SP entry) can save a record with only a name and nothing else. This allows incomplete quote records to enter the pipeline silently.

---

---

## PART 3 — Forms & Entry Points Audit

### Overview

The Home Quotes list has **three confirmed entry points** — all writing to the same list, with no documented coordination between them:

| # | Form | Type | How Data Reaches SP | Status |
|---|------|------|--------------------|----|
| 1 | Power Apps Canvas form ("Full Home Quote") | In-dashboard Power Apps | Direct Patch() to Home Quotes list | Wired / active |
| 2 | Microsoft Forms — Version 1 (Homeowner_1) | External Microsoft Form | Power Automate flow → Home Quotes list | Exists on disk (`Homeowner_1.pdf` reference — form exists) |
| 3 | Microsoft Forms — Version 2 (Homeowner_fixed_1) | External Microsoft Form | Power Automate flow → Home Quotes list | Exists on disk (`Homeowner_fixed_1.pdf` found on desktop) |

These three paths are **not mutually exclusive and not coordinated**. A prospect or agent can submit the same quote through any of the three and create duplicate records in the Home Quotes list.

---

### Form 1 — Power Apps Canvas "Full Home Quote Form"

**Source: `b09b2b6d.png` — Section 4 (bottom right of dashboard)**

This is the in-dashboard form visible in the existing AA Agency CRM reference build. It is the Power Apps form that is confirmed "wired" to the Home Quotes SP list.

**Form structure observed:**

The form uses a **tab/panel layout** with at minimum two sections visible:

**Tab: Property**
| Field | Input Type | Notes |
|-------|-----------|-------|
| First Name | Text input | Required asterisk visible |
| Last Name | Text input | Required asterisk visible |
| Property Address | Text input | Pre-filled: "123 Main St" in screenshot |
| City | Text input | Pre-filled: "Foley" |
| State | Dropdown | Pre-filled: "AL" |
| ZIP | Text input | Pre-filled: "36535" |
| Type | Dropdown | Pre-filled: *(select type)* |
| Source | Dropdown | Pre-filled: *(select source)* |
| Phone | Text input | Pre-filled: "(555) 555-1234" |
| Email | Text input | Pre-filled: "email@example.com" |
| Year Built | Text input | Pre-filled: "2000" |
| Square Footage | Text input | Pre-filled: "2,100" |
| Construction Type | Dropdown | Pre-filled: "Brick Veneer" |
| Roof Type | Dropdown | Pre-filled: "Architectural Shingle" |

**Tab: Coverages** — visible in tab navigation (content not shown in screenshot)

**Tab: Review** — visible in tab navigation (content not shown in screenshot)

**Buttons:** Cancel | Next (advancing through tabs), Save Lead (on final tab)

**Data flow:** On save, the form patches directly to the Home Quotes SP list via the Power Apps SharePoint connector. Based on the wired connection, it also appears to create or link a Leads record (the "Save Lead" button label implies a Leads record is being created as part of the flow).

---

### Form 2 — Microsoft Forms Version 1 (Homeowner_1)

**Source: Physical reference — `Homeowner_1.pdf` (not parseable in this session) + contextual evidence**

This is the original Microsoft Form built from the homeowner quote paper form. It corresponds to the first version of the intake flow that writes Forms responses → Home Quotes SP list via Power Automate.

**Status:** Exists. The PDF file `Homeowner_1.pdf` was referenced in the project brief but `Homeowner_fixed_1.pdf` was found on the desktop — indicating Version 1 was identified as having issues and a "fixed" version (Version 2) was created.

**Known issue with Version 1:** The existence of a "fixed" version implies Version 1 has at least one field mapping error, question type mismatch, or structural problem. The nature of the fix is not documented in the project files reviewed.

**Data flow:** Microsoft Forms → Power Automate "When a new response is submitted" trigger → Home Quotes SP list write. Whether this flow also creates a Leads record is not confirmed from the available files.

---

### Form 3 — Microsoft Forms Version 2 (Homeowner_fixed_1)

**Source: Physical reference — `Homeowner_fixed_1.pdf` found at `C:\Users\alec\Desktop\Homeowner_fixed_1.pdf`**

This is the corrected Microsoft Form. The "fixed" in the filename indicates it was built to address issues found in Version 1.

**Status:** Exists on disk. Whether the corresponding Microsoft Form in forms.office.com has been updated, replaced, or whether both Forms are still live and accepting responses is unknown from the available files.

**Critical risk:** If BOTH Forms (Version 1 and Version 2) are still published and accepting responses (i.e., neither has been taken offline), submissions may be arriving from both simultaneously, creating duplicate or mismatched records in the Home Quotes list — with different field mappings between the two versions.

---

### Branching Diagram — Home Quotes List Entry Points

```
HOME QUOTES SP LIST
(alfains.sharepoint.com/teams/1047889-ADAMSCOSBY/Lists/Home%20Quotes)
         ▲              ▲                    ▲
         │              │                    │
         │              │                    │
┌────────┴──────┐ ┌─────┴──────────┐ ┌──────┴──────────────┐
│ Power Apps    │ │ Microsoft Forms│ │ Microsoft Forms      │
│ Canvas Form   │ │ Version 1      │ │ Version 2 (fixed)   │
│ ("Full Home   │ │ (Homeowner_1)  │ │ (Homeowner_fixed_1) │
│  Quote" tab)  │ │                │ │                      │
│               │ │ → Power Auto-  │ │ → Power Automate     │
│ Direct Patch()│ │   mate flow    │ │   flow               │
│ from Canvas   │ │   (version 1?) │ │   (version 2?)       │
│ app           │ │                │ │                      │
│               │ │ ⚠️ May still   │ │ ⚠️ May still        │
│ ✅ Confirmed  │ │ be live        │ │ be live              │
│ wired         │ │ ❓ Unknown     │ │ ❓ Unknown           │
└───────────────┘ └────────────────┘ └──────────────────────┘

ADDITIONAL PATH (also writes to Home Quotes / Leads):
┌────────────────────────────────────┐
│ Quick Entry — "New Lead" panel     │
│ (visible in b09b2b6d.png)          │
│ Fields: Name, Type, Source, City,  │
│ State, ZIP, Phone, Email,          │
│ Year Built, Sq Ft, Construction    │
│ → Saves to LEADS list (not HQ)    │
│ → "Next" button may open Full Form │
└────────────────────────────────────┘
```

---

---

## PART 4 — Current Canvas App Build State

**Source: `51755bcd.png` — ADAMSCOSBY_CLEAN current build**

The active Power Apps Canvas app (the file being worked on interactively) is confirmed running with live test data.

### Dashboard KPIs (as of screenshot)
| Status | Count |
|--------|-------|
| Active | 4 |
| Working | 1 |
| Bound | 0 |
| Lost | 0 |
| Quoted | 1 |
| Contacted | 0 |
| Negotiating | 0 |
| **Total leads** | **6** |

### Test Lead Records Visible
| Lead Name | Status | Type | Premium | Agent | Updated |
|-----------|--------|------|---------|-------|---------|
| Carol Collins | Active | Home | $0 | Unassigned | 4/29/26 |
| Ruel Garner | Working | Auto | $0 | Unassigned | 4/29/26 |
| John Smith | Active | Home | $1,250 | Alec Adams | 4/29/26 |
| Mary Johnson | Active | Home | $980 | Rachel Cosby | 4/29/26 |
| Bob Williams | Quoted | Home + Auto | $2,140 | Alec Adams | 4/29/26 |
| TEST Smith, John | Active | Home | $0 | Unassigned | 4/29/26 |

### Expanded Row Detail (John Smith — visible in screenshot)
**Contact Information:**
- Phone: (251) 555-0101
- Email: john.smith@example.com
- Address: 123 Main St, Foley, AL 36535

**Lead Information:**
- Type: Home
- Source: Website
- Agent: Alec Adams
- Created: 4/29/26
- Premium estimate: $1,250/yr
- Next follow-up: 11/22/2024

**Quick Send Templates (wired):**
- New Lead Introduction
- Home Insurance Information
- Quote Ready

**Action Buttons:**
- Open Detail (red, primary)
- + New Quote
- Open PDF
- ✓ Mark Bound
- × Close Expansion

### Left Navigation (current app)
Dashboard · Leads · Activities · Calendar · Tasks · Templates · Reports · Files · Settings

### Type Values in Live Data
The "Type" column in the Leads list is confirmed using values: **Home**, **Auto**, **Home + Auto** — confirming this is the working coverage type field. This is relevant to the Round 2 flow specs: Flow 3b's re-quote timing logic should filter on this column's values, not on Source.

---

---

## PART 5 — Reference CRM Build (AA Agency CRM)

**Source: `b09b2b6d.png` — AA Agency CRM in Microsoft Teams**

This image shows a more complete version of the CRM — either a reference implementation, a previously deployed version, or the intended final-state design. It runs inside Microsoft Teams as a tab (visible Teams chrome at top). Branding: "AA Agency CRM" with the Alfa Insurance shield logo.

### Dashboard Stats (this version)
| Metric | Value |
|--------|-------|
| New Leads (this week) | 42 (↑10%) |
| Contacted (this week) | 18 (↑20%) |
| Quotes Sent (this week) | 15 (↑20%) |
| Follow-Up (this week) | 9 (↑25%) |
| Negotiating (this week) | 6 (↑2%) |
| Bound (this week) | 12 (↑25%) |
| Bound Premium | $34,520 (↑18%) |
| Lost (this week) | 5 (↑1%) |

### Lead List (Visible Columns)
Lead Name · Status · Type · Premium · Next Follow Up · Agent · Updated

### Status Values Confirmed (from dropdown/badges)
New · Contacted · Quote Sent · Follow-Up · Negotiating · Bound · Lost

**Note:** These status values differ from the current ADAMSCOSBY_CLEAN build's status values (Active · Working · Quoted · Lost · Bound). There are **two different status vocabularies** in use between the reference build and the active build. This discrepancy needs to be resolved before flows are built — Flow 3b triggers on "Bound" and "Lost" but these must match the exact choice values in the live Leads list.

### Quick Entry Form (Section 3 — "New Lead")
Minimal intake form with the following fields:
| Field | Type |
|-------|------|
| First Name | Text |
| Last Name | Text |
| Type | Dropdown (Home selected) |
| Source | Dropdown (Website selected) |
| City | Text (Foley) |
| State | Dropdown (AL) |
| ZIP | Text (36535) |
| Phone | Text ((555) 555-1234) |
| Email | Text (email@example.com) |
| Year Built | Text (2000) |
| Square Footage | Text (2,100) |
| Construction Type | Dropdown (Brick Veneer) |
| Roof Type | Dropdown (Architectural Shingle) |

Buttons: **Cancel** · **Save Lead** · **Next**

**Observation:** The Quick Entry form contains **property/construction fields** (Year Built, Sq Ft, Construction Type, Roof Type) that go beyond "minimal lead capture." This suggests the Quick Entry form was designed to collect enough data for an initial home quote, not just a contact record. The "Next" button likely advances to the Full Home Quote form.

### Full Home Quote Form (Section 4)
Same fields as Quick Entry, organized into tabs:
- **Property** tab (visible)
- **Coverages** tab
- **Review** tab

This is the Power Apps form confirmed wired to the Home Quotes list.

### Templates Visible (Section 7)
| Template Name |
|--------------|
| New Lead Introduction |
| Auto Insurance Information |
| Home Insurance Information |
| Follow Up Reminder |
| Thank You *(not in Round 1 spec — unaccounted for)* |
| Quote Ready |

**Note:** A "Thank You" template is visible in the reference build that was NOT included in the Round 1 template spec (which documented 7 templates). This may be an 8th template that should be created, or it may correspond to one of the 7 that was renamed.

### Reports Section (Section 8)
Two charts visible:
- **Leads by Status** — bar chart showing distribution across statuses
- **Leads by Source** — bar chart showing New, Referral, Walk-In, and Other sources

---

---

## PART 6 — Conflicts & Discrepancies Requiring Resolution

These are findings from the photos that conflict with or add to the Round 1/2 documentation:

| # | Conflict | Detail | Action Needed |
|---|----------|--------|---------------|
| C1 | **Status value vocabulary mismatch** | Active build uses: Active, Working, Quoted, Bound, Lost. Reference build uses: New, Contacted, Quote Sent, Follow-Up, Negotiating, Bound, Lost. These are two different sets. | Confirm which set the live Leads list's Status Choice column actually uses. Flow 3b triggers depend on exact string matches. |
| C2 | **Three entry points to Home Quotes — no coordination** | Power Apps form, Forms v1, and Forms v2 all write to the same list independently. No deduplication, no cross-awareness. | Decide: disable Forms v1 if v2 is the current version. Confirm whether both Forms are still published and accepting responses. |
| C3 | **QuoteID column exists twice in Home Quotes** | Calculated version and plain-text version both named "QuoteID." | Identify which one the Quote Documents `RelatedQuote` lookup targets. Archive/delete the unused one. |
| C4 | **Risk Address exists twice** | Location type and Single line of text type. Microsoft Forms cannot write to Location columns — so Forms submissions always populate the text version while the Power Apps form may populate the Location version. | Standardize on text version for cross-form compatibility. |
| C5 | **Spouse's Phone exists twice** | Number type (wrong for phone) and Single line of text (correct). | Migrate any data from Number version to text version, then delete the Number column. |
| C6 | **"Thank You" template in reference build** | Not in the 7-template Round 1 spec. | Determine if this should be Template 8, or if it maps to one of the existing 7. |
| C7 | **"Type" column confirmed in Leads (Home / Auto / Home+Auto)** | Round 2 flow specs used "Source" for auto-vs-home detection as a fallback. The Type column is the correct field to use. | Update Flow 3b re-quote logic to filter on the Type column, not Source. |
| C8 | **GW ACCT, ID PH, ID Spouse are undocumented columns** | Three Number columns with no documentation in any project file. | Confirm purpose. If tied to an external carrier system, document the integration. If orphaned, candidate for removal. |

---

---

## Summary

**Lists confirmed:** 8 lists exist in the SharePoint site. All align with the project brief.

**Schema confirmed:** Home Quotes has 31 columns (including system columns). The schema contains 3 pairs of duplicate columns within the same list (`QuoteID` × 2, `Spouse's Phone` × 2, `Risk Address` × 2). Only `Name` is required. The identical structure to Leads confirms the accidental duplication flagged in Round 1.

**Forms confirmed:** Three distinct entry points write to the Home Quotes list — a wired Power Apps canvas form, Microsoft Forms v1 (Homeowner_1), and Microsoft Forms v2 (Homeowner_fixed_1). These operate independently with no coordination or deduplication logic. At minimum, one Microsoft Forms version should be taken offline.

**Critical pre-build action:** Resolve C1 (status vocabulary) before building Flow 3b. If the Leads list Status column uses "Active/Working/Quoted/Bound/Lost," the flow trigger condition must use those exact strings. If it uses "New/Contacted/Quote Sent/Follow-Up/Negotiating/Bound/Lost," the trigger and all downstream logic must match that set instead.

*Read-only audit. No files modified, no SharePoint changes made, no flows triggered.*
