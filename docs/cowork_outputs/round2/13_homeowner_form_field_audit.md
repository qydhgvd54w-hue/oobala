# Homeowner Quote Form — Field Inventory & Branching Audit
**Adams Cosby Insurance · Source Document: Paper Homeowner Quote Form**
*Cross-referenced with: Home Quotes SP list schema (photo audit), Quick Entry form screenshot, confirmed branching rules*
*Documented: 2026-05-04 · PDF could not be machine-read; field inventory built from SP column schema + screenshot evidence + confirmed branching rules from final decisions doc*

> ⚠️ **Alec must verify this inventory against the physical paper form before the Microsoft Form is built.** Fields flagged with `[VERIFY]` are inferred from the SP schema or standard Alfa homeowner quote practice — they may differ from the actual paper form layout or label.

---

## Field Count Summary

| Section | Fields | Conditional Sub-Fields | Total |
|---------|--------|----------------------|-------|
| 1. Administrative | 5 | 0 | 5 |
| 2. Primary Applicant | 6 | 0 | 6 |
| 3. Spouse / Co-Applicant | 5 | 0 | 5 |
| 4. Property Information | 10 | 0 | 10 |
| 5. Coverage & Existing Policy | 5 | 0 | 5 |
| 6. Risk Qualifiers — Structures | 6 | 5 | 11 |
| 7. Risk Qualifiers — Animals | 2 | 2 | 4 |
| 8. Risk Qualifiers — Claims | 1 | 3 | 4 |
| 9. Additional Information | 4 | 0 | 4 |
| 10. Agent Assignment | 1 | 0 | 1 |
| **TOTAL** | **45** | **10** | **~55 fields** |

*Remaining ~3 fields to reach 58 are likely section headers or checkboxes not captured here — flag during Alec's paper-form review.*

---

## Section 1 — Administrative (Auto-Filled / Agent-Set)

These fields are typically pre-filled by the agent or auto-populated — they appear at the top of the paper form.

| # | Field Label | Type | SP Column Mapped | Notes |
|---|-------------|------|-----------------|-------|
| 1 | Quote Date | Date | `Date` | Auto-fills to today on SP form — MR-1 formula must survive column adds |
| 2 | Agent | Person selector | `Agent` (Person or Group) | Dropdown: Alec / Rachel only per Item #2 decision |
| 3 | Source | Dropdown | `Source` (Choice) | How the lead originated |
| 4 | Source Detail | Dropdown | `Source Detail` (Choice) | Sub-category of source |
| 5 | Referral Name | Text | `Referral` | Free-form name if Source = Referral |

---

## Section 2 — Primary Applicant

| # | Field Label | Type | SP Column Mapped | Notes |
|---|-------------|------|-----------------|-------|
| 6 | Full Name | Text | `Name` | **REQUIRED** — only required field confirmed in SP schema |
| 7 | Date of Birth | Date | `DOB` | |
| 8 | Phone Number | Text | `Phone Number` | Must be Single line of text to preserve formatting — confirmed in SP schema |
| 9 | Email Address | Text | `Email` | |
| 10 | GW Account # | Text/Number | `GW ACCT` | `[VERIFY]` — likely Goodwille & German Mutual account number or carrier account ID. Appears as Number in SP; may need to be text if account numbers have leading zeros or letters |
| 11 | ID PH | Number | `ID PH` | `[VERIFY]` — likely internal policyholder ID. Purpose undocumented in project files |

---

## Section 3 — Spouse / Co-Applicant

| # | Field Label | Type | SP Column Mapped | Notes |
|---|-------------|------|-----------------|-------|
| 12 | Spouse's Name | Text | `Spouse's Name` | |
| 13 | Spouse's Date of Birth | Date | `Spouse's DOB` | |
| 14 | Spouse's Phone | Text | `Spouse's Phone` (Single line of text — row 25 in SP) | ⚠️ Use the **text** version of this column, NOT the Number version (row 11). The Number column is a known duplicate error — ignore it. |
| 15 | ID Spouse | Number | `ID Spouse` | `[VERIFY]` — likely an internal spouse/secondary applicant ID |
| 16 | Spouse included in policy? | Yes/No | `[VERIFY]` | `[VERIFY]` — may be implied by whether spouse fields are populated, or may be an explicit checkbox on the paper form |

---

## Section 4 — Property Information

| # | Field Label | Type | SP Column Mapped | Notes |
|---|-------------|------|-----------------|-------|
| 17 | Risk / Property Address | Text | `Risk Address` (Single line of text — row 26 in SP) | ⚠️ Use the **text** version, NOT the Location column (row 14). Microsoft Forms cannot write to Location columns. |
| 18 | City | Text | Part of Risk Address or separate `[VERIFY]` | May be embedded in Risk Address or a separate field |
| 19 | State | Text / Dropdown | Part of Risk Address or separate | Pre-filled AL for Alabama |
| 20 | ZIP Code | Text | Part of Risk Address or separate | |
| 21 | Occupancy Type | Dropdown | `Occupancy` (Choice) | `[VERIFY choices]` — likely: Primary Residence, Secondary/Vacation, Rental/Investment |
| 22 | Year Built | Text/Number | `[VERIFY]` | Visible in Quick Entry form screenshot. Not a dedicated SP column — may be stored in Notes or a column not shown |
| 23 | Square Footage | Number | `[VERIFY]` | Visible in Quick Entry form screenshot. Same note as Year Built |
| 24 | Construction Type | Dropdown | `[VERIFY]` | Screenshot shows "Brick Veneer" selected. Likely choices: Frame, Brick, Brick Veneer, Other |
| 25 | Roof Type | Dropdown | `[VERIFY]` | Screenshot shows "Architectural Shingle." Likely choices: Architectural Shingle, 3-Tab Shingle, Metal, Tile, Other |
| 26 | Roof Year | Text/Number | `[VERIFY]` | `[VERIFY]` — standard on homeowner forms, not visible in screenshot |

---

## Section 5 — Coverage & Existing Policy

| # | Field Label | Type | SP Column Mapped | Notes |
|---|-------------|------|-----------------|-------|
| 27 | Products Requested | Multi-select or Checkbox | `Products` (Choice) | `[VERIFY choices]` — likely: Homeowner, Auto, Life, Renter, etc. |
| 28 | Requested Coverage Amount | Text | `[VERIFY]` | `[VERIFY]` — dwelling coverage amount requested |
| 29 | Deductible Preference | Dropdown | `[VERIFY]` | `[VERIFY]` — typical choices: $500, $1,000, $2,500, $5,000 |
| 30 | Current Carrier | Text | `Current Carriers` | Name of existing insurance company |
| 31 | Current Premium | Text | `Current Premiums` | Existing annual/monthly premium |

---

## Section 6 — Risk Qualifiers: Structures

These fields have **confirmed branching logic** per the final decisions document.

| # | Field Label | Type | Branching | SP Column / Notes |
|---|-------------|------|-----------|------------------|
| 32 | Is this a mobile home? | Yes / No | **YES → show field 33** | `[VERIFY]` — gates inspection decal field |
| 33 | *(conditional)* Mobile Home Inspection Decal # | Text | Shown only if Q32 = Yes | `[VERIFY SP column]` |
| 34 | Is there a pool on the property? | Yes / No | **YES → show fields 35, 36, 37** | `[VERIFY]` |
| 35 | *(conditional)* Pool has a slide? | Yes / No | Shown only if Q34 = Yes | `[VERIFY SP column]` |
| 36 | *(conditional)* Pool has a diving board? | Yes / No | Shown only if Q34 = Yes | `[VERIFY SP column]` |
| 37 | *(conditional)* Pool is fenced? | Yes / No | Shown only if Q34 = Yes | `[VERIFY SP column]` |
| 38 | Is there a trampoline on the property? | Yes / No | No sub-fields | `[VERIFY SP column]` |
| 39 | Any other structures on property? | Yes / No | `[VERIFY]` — may gate a description field | `[VERIFY]` |

---

## Section 7 — Risk Qualifiers: Animals

| # | Field Label | Type | Branching | Notes |
|---|-------------|------|-----------|-------|
| 40 | Are there dogs on the property? | Yes / No | **YES → show field 41** | Standard underwriting qualifier |
| 41 | *(conditional)* Dog breed(s) | Text | Shown only if Q40 = Yes | Some breeds may be excluded from coverage |

---

## Section 8 — Risk Qualifiers: Claims History

| # | Field Label | Type | Branching | SP Column / Notes |
|---|-------------|------|-----------|------------------|
| 42 | Any claims filed in the last 5 years? | Yes / No | **YES → show fields 43, 44, 45** | Standard on homeowner forms |
| 43 | *(conditional)* Claim date | Date | Shown only if Q42 = Yes | May be multiple rows on paper form |
| 44 | *(conditional)* Claim description | Text | Shown only if Q42 = Yes | |
| 45 | *(conditional)* Claim amount | Currency/Text | Shown only if Q42 = Yes | |

---

## Section 9 — Additional Information

| # | Field Label | Type | SP Column Mapped | Notes |
|---|-------------|------|-----------------|-------|
| 46 | Notes / Additional comments | Long text | `Notes` | Free-form, anything else the agent or applicant wants to add |
| 47 | Quote link / Reference URL | URL | `Link` (Hyperlink or Picture) | `[VERIFY]` — may link to the quote PDF once generated |
| 48 | How did you hear about us? | Already captured in Section 1 Source/Source Detail | — | `[VERIFY]` — may appear again at bottom of form as a standalone question |
| 49 | Business conducted on premises? | Yes / No | `[VERIFY]` | `[VERIFY]` — standard underwriting qualifier; not confirmed from SP schema |

---

## Section 10 — Agent Assignment

| # | Field Label | Type | SP Column Mapped | Notes |
|---|-------------|------|-----------------|-------|
| 50 | Assign to Agent | Dropdown | `Agent` (Person or Group) | **Two choices only: Alec, Rachel.** Per Item #2 final decision. Inputters (Leigh, Jessica, Tammy) are NOT selectable. |

---

## Confirmed Branching Tree

```
Q32: Mobile Home?
  └── YES → Q33: Inspection Decal #

Q34: Pool on property?
  └── YES → Q35: Slide? (Y/N)
          → Q36: Diving Board? (Y/N)
          → Q37: Pool Fenced? (Y/N)

Q40: Dogs on property?
  └── YES → Q41: Breed(s)

Q42: Claims in last 5 years?
  └── YES → Q43: Claim Date
          → Q44: Claim Description
          → Q45: Claim Amount
```

---

## Fields in SP Schema With No Confirmed Form Field

These SP columns exist in the Home Quotes list but have no clear mapping to a paper form field. Each needs Alec's clarification:

| SP Column | Type | Possible Purpose |
|-----------|------|-----------------|
| `QuoteID` (Calculated) | Calculated | Auto-generated — likely not a form field; generated on save |
| `QuoteID` (text, duplicate) | Text | Unknown — may be a manually entered external quote ID |
| `ID PH` | Number | Policyholder ID from a carrier system? |
| `ID Spouse` | Number | Secondary applicant ID from a carrier system? |
| `GW ACCT` | Number | Carrier account number — may be assigned after binding, not at quote time |
| `Link` | Hyperlink | Quote PDF URL — assigned after document generation, not at intake |
| `Status` | Choice | Pipeline status — agent-managed, not set by applicant |

---

## Fields in Screenshot But Not in SP Schema

These appeared in the Quick Entry / Full Quote Power Apps form but have no visible dedicated SP column in the photo audit. They may be stored in `Notes`, or in columns below the scroll area, or not yet added:

| Form Field | Likely Storage |
|-----------|---------------|
| Year Built | `[VERIFY]` — not in visible SP column list |
| Square Footage | `[VERIFY]` — not in visible SP column list |
| Construction Type | `[VERIFY]` — not in visible SP column list |
| Roof Type | `[VERIFY]` — not in visible SP column list |
| Roof Year | `[VERIFY]` — not in visible SP column list |

> **Action for Alec:** scroll to the bottom of the SP List Settings page for Home Quotes and check whether Year Built, Square Footage, Construction Type, Roof Type, and Roof Year exist as columns below what was visible in the photo. If they don't exist, they need to be added (per MR-1, add to both lists simultaneously).

---

## Paper Form vs. Microsoft Form Mapping Rules

When building the Microsoft Form, the following rules apply:

1. Use the **text version** of `Risk Address` (not the Location column)
2. Use the **text version** of `Spouse's Phone` (not the Number column)
3. `QuoteID` is Calculated — do not include a QuoteID field in the form; SP generates it automatically
4. `Date` auto-fills to today — do not include a Date question in the form; let SP handle it
5. `Status` is agent-managed — do not include in the form; default to "Active" via the flow
6. `GW ACCT`, `ID PH`, `ID Spouse`, `Link` are likely post-intake columns — `[VERIFY]` whether they appear on the paper form at intake time or are added later
