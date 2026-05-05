# Task 14 — Microsoft Forms Build Spec: Homeowner Quote Form
**Adams Cosby Insurance · Path A Option A1**
*Source: `13_homeowner_form_field_audit.md` field inventory + confirmed branching rules from final decisions doc*
*Documented: 2026-05-04 · Internal-org submission only (per final decisions Item #3)*

> **Build instruction:** Follow this spec question-by-question, top to bottom. Every branching condition is marked. Do not use sections that require branching in Microsoft Forms — instead, use Microsoft Forms' native "Branch" feature on each Yes/No question to show or hide follow-up questions. Internal-only form: set to "Only people in my organization can respond."

---

## Pre-Build Checklist

- [ ] Form is set to **"Only people in my organization can respond"** (not public/anonymous)
- [ ] Form title: **Adams Cosby — Homeowner Quote Request**
- [ ] Description text: *"Please complete all fields as thoroughly as possible. An Adams Cosby agent will contact you within one business day."*
- [ ] Shuffle options: **OFF**
- [ ] Progress bar: **ON**
- [ ] Confirmation message: *"Thank you — your homeowner quote request has been received. An Adams Cosby agent will be in touch within one business day."*

---

## Section 1 — Primary Applicant

> *(Microsoft Forms: Add a Section header titled "Applicant Information")*

### Q1 — Full Name
| Property | Value |
|----------|-------|
| Type | **Text** (Short answer) |
| Label | `Full Name` |
| Required | **Yes** |
| Placeholder | *e.g., John A. Smith* |
| SP Column | `Name` (Title) |

---

### Q2 — Date of Birth
| Property | Value |
|----------|-------|
| Type | **Date** |
| Label | `Date of Birth` |
| Required | No |
| SP Column | `DOB` |

---

### Q3 — Phone Number
| Property | Value |
|----------|-------|
| Type | **Text** (Short answer) |
| Label | `Phone Number` |
| Required | No |
| Placeholder | *e.g., (251) 555-1234* |
| SP Column | `Phone Number` (text column — **not** a number column) |

> ⚠️ **Use Text type, NOT Number.** A Number field will strip leading zeros and parentheses from phone numbers. The SP column `Phone Number` is Single line of text — match that here.

---

### Q4 — Email Address
| Property | Value |
|----------|-------|
| Type | **Text** (Short answer) |
| Label | `Email Address` |
| Required | No |
| Placeholder | *e.g., jsmith@email.com* |
| SP Column | `Email` |

---

### Q5 — GW Account # *(if applicable)*
| Property | Value |
|----------|-------|
| Type | **Text** (Short answer) |
| Label | `GW Account # (if known)` |
| Required | No |
| Placeholder | *Leave blank if unknown* |
| SP Column | `GW ACCT` |

> `[VERIFY]` — Include only if this field appears on the paper form at intake time. May be a post-binding field added by the agent later.

---

## Section 2 — Spouse / Co-Applicant

> *(Microsoft Forms: Add a Section header titled "Spouse / Co-Applicant — Leave blank if not applicable")*

### Q6 — Spouse's Full Name
| Property | Value |
|----------|-------|
| Type | **Text** (Short answer) |
| Label | `Spouse / Co-Applicant Full Name` |
| Required | No |
| SP Column | `Spouse's Name` |

---

### Q7 — Spouse's Date of Birth
| Property | Value |
|----------|-------|
| Type | **Date** |
| Label | `Spouse / Co-Applicant Date of Birth` |
| Required | No |
| SP Column | `Spouse's DOB` |

---

### Q8 — Spouse's Phone Number
| Property | Value |
|----------|-------|
| Type | **Text** (Short answer) |
| Label | `Spouse / Co-Applicant Phone Number` |
| Required | No |
| Placeholder | *e.g., (251) 555-5678* |
| SP Column | `Spouse's Phone` (text version — row 25 in SP list; **not** the Number column duplicate at row 11) |

---

## Section 3 — Property Information

> *(Microsoft Forms: Add a Section header titled "Property Information")*

### Q9 — Risk / Property Address
| Property | Value |
|----------|-------|
| Type | **Text** (Short answer) |
| Label | `Property Street Address` |
| Required | **Yes** |
| Placeholder | *e.g., 123 Main Street* |
| SP Column | `Risk Address` (text version — row 26 in SP; **not** the Location column at row 14) |

> ⚠️ Power Automate **cannot write to SP Location columns**. The flow must map this answer to the text `Risk Address` column only.

---

### Q10 — City
| Property | Value |
|----------|-------|
| Type | **Text** (Short answer) |
| Label | `City` |
| Required | No |
| Placeholder | *e.g., Foley* |
| SP Column | Part of address block — `[VERIFY]` whether stored in `Risk Address` or separate column |

---

### Q11 — State
| Property | Value |
|----------|-------|
| Type | **Text** (Short answer) |
| Label | `State` |
| Required | No |
| Default / prefill note | Pre-fill with `AL` — agents can change if needed |
| SP Column | Part of address block — `[VERIFY]` |

---

### Q12 — ZIP Code
| Property | Value |
|----------|-------|
| Type | **Text** (Short answer) |
| Label | `ZIP Code` |
| Required | No |
| Placeholder | *e.g., 36535* |
| SP Column | Part of address block — `[VERIFY]` |

---

### Q13 — Occupancy Type
| Property | Value |
|----------|-------|
| Type | **Choice** (dropdown) |
| Label | `Occupancy Type` |
| Required | No |
| SP Column | `Occupancy` |

**Choices:**
1. Primary Residence
2. Secondary / Vacation Home
3. Rental / Investment Property
4. Other

> `[VERIFY choices]` — Confirm these match the SP `Occupancy` column choice values exactly. Microsoft Forms choice values must match SP choice column values character-for-character for the flow mapping to work correctly.

---

### Q14 — Year Built
| Property | Value |
|----------|-------|
| Type | **Text** (Short answer) |
| Label | `Year Built` |
| Required | No |
| Placeholder | *e.g., 1998* |
| SP Column | `[VERIFY]` — visible in Quick Entry screenshot; SP column not confirmed in schema photo |

---

### Q15 — Square Footage
| Property | Value |
|----------|-------|
| Type | **Text** (Short answer) |
| Label | `Square Footage` |
| Required | No |
| Placeholder | *e.g., 2200* |
| SP Column | `[VERIFY]` — visible in Quick Entry screenshot; SP column not confirmed in schema photo |

---

### Q16 — Construction Type
| Property | Value |
|----------|-------|
| Type | **Choice** (dropdown) |
| Label | `Construction Type` |
| Required | No |
| SP Column | `[VERIFY]` |

**Choices:**
1. Brick
2. Brick Veneer
3. Frame
4. Vinyl Siding
5. Other

> `[VERIFY choices]` — Screenshot shows "Brick Veneer" as a selected value in the Quick Entry form. Adjust to match the exact SP column choices.

---

### Q17 — Roof Type
| Property | Value |
|----------|-------|
| Type | **Choice** (dropdown) |
| Label | `Roof Type` |
| Required | No |
| SP Column | `[VERIFY]` |

**Choices:**
1. Architectural Shingle
2. 3-Tab Shingle
3. Metal
4. Tile
5. Other

> `[VERIFY choices]` — Screenshot shows "Architectural Shingle" selected. Adjust to match SP column choices.

---

### Q18 — Roof Year
| Property | Value |
|----------|-------|
| Type | **Text** (Short answer) |
| Label | `Roof Year` |
| Required | No |
| Placeholder | *e.g., 2015* |
| SP Column | `[VERIFY]` — standard on homeowner forms; SP column not confirmed in schema photo |

---

## Section 4 — Coverage & Existing Policy

> *(Microsoft Forms: Add a Section header titled "Coverage Details")*

### Q19 — Current Insurance Carrier
| Property | Value |
|----------|-------|
| Type | **Text** (Short answer) |
| Label | `Current Insurance Carrier` |
| Required | No |
| Placeholder | *e.g., State Farm, Allstate — or "None"* |
| SP Column | `Current Carriers` |

---

### Q20 — Current Annual Premium
| Property | Value |
|----------|-------|
| Type | **Text** (Short answer) |
| Label | `Current Annual Premium` |
| Required | No |
| Placeholder | *e.g., $1,200 — or "None"* |
| SP Column | `Current Premiums` |

---

### Q21 — Coverage Amount Requested
| Property | Value |
|----------|-------|
| Type | **Text** (Short answer) |
| Label | `Coverage Amount Requested` |
| Required | No |
| Placeholder | *Dwelling replacement value, e.g., $250,000* |
| SP Column | `[VERIFY]` — standard field; SP column not confirmed |

---

### Q22 — Deductible Preference
| Property | Value |
|----------|-------|
| Type | **Choice** (dropdown) |
| Label | `Deductible Preference` |
| Required | No |
| SP Column | `[VERIFY]` |

**Choices:**
1. $500
2. $1,000
3. $2,500
4. $5,000
5. No Preference

---

### Q23 — Products Requested
| Property | Value |
|----------|-------|
| Type | **Choice** (multi-select checkboxes) |
| Label | `Additional Products of Interest` |
| Required | No |
| SP Column | `Products` |

**Choices:**
1. Homeowner
2. Auto
3. Life
4. Renter
5. Commercial

> `[VERIFY choices]` — Confirm these match the SP `Products` Choice column values exactly.

---

## Section 5 — Risk Qualifiers

> *(Microsoft Forms: Add a Section header titled "Property Risk Information")*

---

### Q24 — Mobile Home?
| Property | Value |
|----------|-------|
| Type | **Choice** (Yes / No) |
| Label | `Is this property a mobile home?` |
| Required | No |
| SP Column | `[VERIFY]` |
| **Branching** | **YES → go to Q25. NO → skip to Q26.** |

> **How to set branching in Microsoft Forms:** Click the "..." menu on this question → "Add branching." Set "Yes" to go to Q25. Set "No" to go to Q26 (the pool question).

---

### Q25 — Mobile Home Inspection Decal # *(conditional — shown only if Q24 = Yes)*
| Property | Value |
|----------|-------|
| Type | **Text** (Short answer) |
| Label | `Mobile Home Inspection Decal Number` |
| Required | No |
| Placeholder | *Decal number from inspection sticker* |
| SP Column | `[VERIFY SP column name]` |
| **Branching** | After answering → go to Q26 (pool question) |

---

### Q26 — Pool on Property?
| Property | Value |
|----------|-------|
| Type | **Choice** (Yes / No) |
| Label | `Is there a swimming pool on the property?` |
| Required | No |
| SP Column | `[VERIFY]` |
| **Branching** | **YES → go to Q27. NO → skip to Q30.** |

---

### Q27 — Pool Slide? *(conditional — shown only if Q26 = Yes)*
| Property | Value |
|----------|-------|
| Type | **Choice** (Yes / No) |
| Label | `Does the pool have a slide?` |
| Required | No |
| SP Column | `[VERIFY]` |
| **Branching** | Continue to Q28 |

---

### Q28 — Diving Board? *(conditional — shown only if Q26 = Yes)*
| Property | Value |
|----------|-------|
| Type | **Choice** (Yes / No) |
| Label | `Does the pool have a diving board?` |
| Required | No |
| SP Column | `[VERIFY]` |
| **Branching** | Continue to Q29 |

---

### Q29 — Pool Fenced? *(conditional — shown only if Q26 = Yes)*
| Property | Value |
|----------|-------|
| Type | **Choice** (Yes / No) |
| Label | `Is the pool enclosed by a fence?` |
| Required | No |
| SP Column | `[VERIFY]` |
| **Branching** | After answering → go to Q30 |

---

### Q30 — Trampoline on Property?
| Property | Value |
|----------|-------|
| Type | **Choice** (Yes / No) |
| Label | `Is there a trampoline on the property?` |
| Required | No |
| SP Column | `[VERIFY]` |
| **Branching** | No branching — continue to Q31 |

---

### Q31 — Other Structures on Property?
| Property | Value |
|----------|-------|
| Type | **Choice** (Yes / No) |
| Label | `Are there any other structures on the property? (outbuildings, detached garages, barns, etc.)` |
| Required | No |
| SP Column | `[VERIFY]` |
| **Branching** | `[VERIFY]` — may gate a description field. If paper form has a description line here, add a Q31a text field. |

---

### Q32 — Dogs on Property?
| Property | Value |
|----------|-------|
| Type | **Choice** (Yes / No) |
| Label | `Are there dogs on the property?` |
| Required | No |
| SP Column | `[VERIFY]` |
| **Branching** | **YES → go to Q33. NO → skip to Q34.** |

---

### Q33 — Dog Breed(s) *(conditional — shown only if Q32 = Yes)*
| Property | Value |
|----------|-------|
| Type | **Text** (Long answer) |
| Label | `Please list all dog breed(s)` |
| Required | No |
| Placeholder | *e.g., Labrador Retriever, German Shepherd* |
| SP Column | `[VERIFY SP column name]` |
| **Branching** | After answering → go to Q34 |

> Some breeds may be excluded or surcharged by underwriting. Agent should review after submission.

---

## Section 6 — Claims History

> *(Microsoft Forms: Add a Section header titled "Claims History")*

### Q34 — Any Claims in the Last 5 Years?
| Property | Value |
|----------|-------|
| Type | **Choice** (Yes / No) |
| Label | `Have you filed any homeowner insurance claims in the last 5 years?` |
| Required | No |
| SP Column | `[VERIFY]` |
| **Branching** | **YES → go to Q35. NO → skip to Q38.** |

---

### Q35 — Claim Date *(conditional — shown only if Q34 = Yes)*
| Property | Value |
|----------|-------|
| Type | **Date** |
| Label | `Date of most recent claim` |
| Required | No |
| SP Column | `[VERIFY SP column name]` |
| **Branching** | Continue to Q36 |

> If paper form has multiple claim rows, add Q35a/Q35b/Q35c as separate date fields. Microsoft Forms does not support repeating rows.

---

### Q36 — Claim Description *(conditional — shown only if Q34 = Yes)*
| Property | Value |
|----------|-------|
| Type | **Text** (Long answer) |
| Label | `Brief description of claim(s)` |
| Required | No |
| Placeholder | *e.g., Wind/hail damage to roof, 2022* |
| SP Column | `[VERIFY SP column name]` |
| **Branching** | Continue to Q37 |

---

### Q37 — Claim Amount *(conditional — shown only if Q34 = Yes)*
| Property | Value |
|----------|-------|
| Type | **Text** (Short answer) |
| Label | `Approximate claim payout amount` |
| Required | No |
| Placeholder | *e.g., $8,500* |
| SP Column | `[VERIFY SP column name]` |
| **Branching** | After answering → go to Q38 |

> Use Text (not Number) to allow currency formatting. The flow will store this as-is in SP.

---

## Section 7 — Additional Information

> *(Microsoft Forms: Add a Section header titled "Additional Information")*

### Q38 — Business Conducted on Premises?
| Property | Value |
|----------|-------|
| Type | **Choice** (Yes / No) |
| Label | `Is any business conducted on this property?` |
| Required | No |
| SP Column | `[VERIFY]` — standard underwriting qualifier |
| **Branching** | No branching — continue to Q39 |

---

### Q39 — How Did You Hear About Us?
| Property | Value |
|----------|-------|
| Type | **Choice** (dropdown) |
| Label | `How did you hear about Adams Cosby Insurance?` |
| Required | No |
| SP Column | `Source` / `Source Detail` |

**Choices:**
1. Referral
2. Website
3. Social Media
4. Walk-In / Drive-By
5. Mailer / Postcard
6. Existing Customer
7. Other

> This maps to the `Source` SP column. If the paper form has a second line for "referral name," add Q39a below.

---

### Q39a — Referral Name *(optional follow-up to Q39)*
| Property | Value |
|----------|-------|
| Type | **Text** (Short answer) |
| Label | `Referral Name (if referred by someone)` |
| Required | No |
| Placeholder | *Who referred you?* |
| SP Column | `Referral` |
| **Branching** | `[VERIFY]` — ideally branch from Q39 "Referral" → show Q39a. Set up branching if Microsoft Forms allows it after a dropdown (it does for Choice type). |

---

### Q40 — Additional Notes
| Property | Value |
|----------|-------|
| Type | **Text** (Long answer) |
| Label | `Additional Notes or Information` |
| Required | No |
| Placeholder | *Anything else we should know about the property or your coverage needs* |
| SP Column | `Notes` |

---

## Branching Summary

The following table is the complete branching map for this form. Set all branching in Microsoft Forms under each question's "..." → "Add branching" menu.

| Trigger Question | Trigger Answer | Go To |
|-----------------|---------------|-------|
| Q24 — Mobile Home? | Yes | Q25 (Inspection Decal) |
| Q24 — Mobile Home? | No | Q26 (Pool) |
| Q25 — Inspection Decal | *(any answer)* | Q26 (Pool) |
| Q26 — Pool? | Yes | Q27 (Slide) |
| Q26 — Pool? | No | Q30 (Trampoline) |
| Q27 — Slide? | *(any answer)* | Q28 (Diving Board) |
| Q28 — Diving Board? | *(any answer)* | Q29 (Fenced) |
| Q29 — Fenced? | *(any answer)* | Q30 (Trampoline) |
| Q32 — Dogs? | Yes | Q33 (Breeds) |
| Q32 — Dogs? | No | Q34 (Claims) |
| Q33 — Breeds | *(any answer)* | Q34 (Claims) |
| Q34 — Claims? | Yes | Q35 (Claim Date) |
| Q34 — Claims? | No | Q38 (Business on Premises) |
| Q35 — Claim Date | *(any answer)* | Q36 (Claim Description) |
| Q36 — Claim Description | *(any answer)* | Q37 (Claim Amount) |
| Q37 — Claim Amount | *(any answer)* | Q38 (Business on Premises) |

> **Note on Microsoft Forms branching behavior:** Branching works by skipping questions, not hiding sections. All conditional questions (Q25, Q27–Q29, Q33, Q35–Q37) should be placed immediately after their trigger question in the form order — this makes the skip logic cleaner for respondents.

---

## Question Count Summary

| Section | Questions | Conditional |
|---------|-----------|-------------|
| 1 — Primary Applicant | 5 | 0 |
| 2 — Spouse / Co-Applicant | 3 | 0 |
| 3 — Property Information | 10 | 0 |
| 4 — Coverage & Policy | 5 | 0 |
| 5 — Risk Qualifiers | 10 | 6 (Q25, Q27, Q28, Q29, Q33, and Q31a if added) |
| 6 — Claims History | 4 | 3 (Q35, Q36, Q37) |
| 7 — Additional Information | 4 | 0 |
| **TOTAL** | **~41 visible** | **~9 conditional** |

*Total fields presented to a respondent with no conditionals triggered: ~32. Maximum fields (all branches triggered): ~41. This matches the ~55 total from the field audit when accounting for SP-only fields (QuoteID, Status, Agent, Date, Link) not included in the form.*

---

## Fields NOT in This Form (Agent-Managed Only)

The following SP columns are intentionally excluded from the Microsoft Form. Agents set these manually in SharePoint or Canvas app after receiving the submission:

| SP Column | Why Excluded |
|-----------|-------------|
| `QuoteID` | Calculated column — auto-generated by SP on save |
| `Date` | Auto-fills to today in SP — set by the Power Automate flow via `utcNow()` |
| `Status` | Defaults to `Active` — set by the flow on create |
| `Agent` | Defaults to Alec (`abadams@alfains.com`) — agent reassigns in Canvas app if needed |
| `ID PH` | Post-intake carrier ID — not collected at quote time `[VERIFY]` |
| `ID Spouse` | Post-intake carrier ID — not collected at quote time `[VERIFY]` |
| `Link` | Quote PDF URL — attached after document is generated, not at intake |

---

## Flow Mapping Reference

When building the Power Automate flow `AdamsCosbyCRM_HomeQuoteFormSubmission`, map form responses to SP columns using this table. Response index numbers (`r1`, `r2`, etc.) correspond to the question order in the published form.

> ⚠️ **Confirm response field names after building the form.** Microsoft Forms uses `r1`, `r2`... `rN` by default in Power Automate dynamic content, but named content is also available once the form exists and is selected in the flow trigger.

| Form Question | SP Column | SP Column Type | Notes |
|--------------|-----------|---------------|-------|
| Q1 — Full Name | `Name` (Title) | Single line of text | Required field |
| Q2 — Date of Birth | `DOB` | Date | |
| Q3 — Phone Number | `Phone Number` | Single line of text | Do NOT map to Number column |
| Q4 — Email | `Email` | Single line of text | |
| Q5 — GW Account # | `GW ACCT` | Number or text | `[VERIFY]` column type in SP |
| Q6 — Spouse Name | `Spouse's Name` | Single line of text | |
| Q7 — Spouse DOB | `Spouse's DOB` | Date | |
| Q8 — Spouse Phone | `Spouse's Phone` | Single line of text | Use row 25 text version — NOT row 11 Number |
| Q9 — Property Address | `Risk Address` | Single line of text | Row 26 text version — NOT Location column |
| Q10–Q12 — City/State/ZIP | `Risk Address` or separate | `[VERIFY]` | May concatenate into Risk Address |
| Q13 — Occupancy | `Occupancy` | Choice | Values must match SP choices exactly |
| Q14 — Year Built | `[VERIFY column name]` | Text or Number | |
| Q15 — Square Footage | `[VERIFY column name]` | Number | |
| Q16 — Construction Type | `[VERIFY column name]` | Choice | |
| Q17 — Roof Type | `[VERIFY column name]` | Choice | |
| Q18 — Roof Year | `[VERIFY column name]` | Text or Number | |
| Q19 — Current Carrier | `Current Carriers` | Single line of text | |
| Q20 — Current Premium | `Current Premiums` | Single line of text | |
| Q21 — Coverage Amount | `[VERIFY column name]` | Text | |
| Q22 — Deductible | `[VERIFY column name]` | Choice | |
| Q23 — Products | `Products` | Choice (multi-select) | |
| Q24 — Mobile Home | `[VERIFY column name]` | Yes/No or Choice | |
| Q25 — Decal # | `[VERIFY column name]` | Text | Conditional |
| Q26 — Pool | `[VERIFY column name]` | Yes/No or Choice | |
| Q27 — Pool Slide | `[VERIFY column name]` | Yes/No | Conditional |
| Q28 — Diving Board | `[VERIFY column name]` | Yes/No | Conditional |
| Q29 — Pool Fenced | `[VERIFY column name]` | Yes/No | Conditional |
| Q30 — Trampoline | `[VERIFY column name]` | Yes/No | |
| Q31 — Other Structures | `[VERIFY column name]` | Yes/No | |
| Q32 — Dogs | `[VERIFY column name]` | Yes/No | |
| Q33 — Dog Breeds | `[VERIFY column name]` | Single or Multi-line text | Conditional |
| Q34 — Claims | `[VERIFY column name]` | Yes/No | |
| Q35 — Claim Date | `[VERIFY column name]` | Date | Conditional |
| Q36 — Claim Description | `[VERIFY column name]` | Multi-line text | Conditional |
| Q37 — Claim Amount | `[VERIFY column name]` | Text | Conditional |
| Q38 — Business on Premises | `[VERIFY column name]` | Yes/No | |
| Q39 — How Heard | `Source` | Choice | |
| Q39a — Referral Name | `Referral` | Single line of text | |
| Q40 — Notes | `Notes` | Multi-line text | |

---

## Alec's Verification Checklist Before Building

- [ ] Compare this spec's question list against the physical paper homeowner form — flag any fields missing or mislabeled
- [ ] Confirm `[VERIFY]` SP columns exist: Year Built, Square Footage, Construction Type, Roof Type, Roof Year (scroll to bottom of SP List Settings for Home Quotes)
- [ ] If those columns don't exist: add them per MR-1 to both Home Quotes and Leads before building the flow
- [ ] Confirm GW ACCT is a paper form field at intake time, or remove Q5 from the form
- [ ] Confirm the exact SP `Occupancy`, `Products`, `Construction Type`, `Roof Type` Choice column values — form choices must match SP choices exactly for flow mapping
- [ ] Confirm the mobile home, pool, trampoline, dog, and claims questions appear on the paper form with these exact branching rules
- [ ] After building the form in Microsoft Forms: note the Response ID field names (r1, r2, etc.) for the flow step

---

*File: `COWORK_OUTPUTS/round2/14_homeowner_microsoft_form_spec.md`*
*Next: `15_task12_lineofbusiness_fix.md` — LineOfBusiness choices update + MR-1 parity confirmation*
