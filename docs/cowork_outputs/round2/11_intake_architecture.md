# Task 11 — Lead Intake Architecture
**Adams Cosby CRM · Dual-Path Design Spec**
*SharePoint-backed only — no Dataverse*
*Documented: 2026-05-03*

---

## Architecture Overview

Two entry points exist for creating pipeline records in the CRM. Both paths ultimately produce a **Leads** record. Only Path A also produces a **Home Quotes** record.

```
┌─────────────────────────────────────────────────────────┐
│                  Adams Cosby CRM                        │
│                                                         │
│  PATH A ─ Home Quote First (PRIMARY)                   │
│  ┌──────────────────┐    Power Automate Flow            │
│  │  Homeowner Quote │ ──────────────────────►  Leads    │
│  │  Form (full)     │                    ►  Home Quotes │
│  └──────────────────┘                    ►  Activities  │
│         ▲                                               │
│    Microsoft Forms (public/QR)                          │
│    OR SharePoint List Form (agent-initiated)            │
│                                                         │
│  PATH B ─ Lead First (ALTERNATIVE)                     │
│  ┌──────────────────┐    Power Apps Patch               │
│  │  + Add Lead      │ ──────────────────────►  Leads    │
│  │  (quick form)    │                    ►  Activities  │
│  └──────────────────┘                                   │
│         ▲                                               │
│    Canvas App modal (in-dashboard)                      │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

---

## Section 1 — Path A: Home Quote First (PRIMARY)

### Why Path A is Primary

Most Adams Cosby leads begin with a homeowner quote request — a prospect fills out a full quote form (either at the agency counter, via QR code, or from the website). This form collects all the information needed to both quote the policy AND create the lead record. It is the richest, most complete intake path.

---

### Form Delivery Options

#### Option A1 — Microsoft Forms (Recommended for Public-Facing Intake)

**How it works:** A Microsoft Form hosted at forms.office.com collects the homeowner quote data. On submission, Power Automate's "When a new response is submitted" trigger fires and writes the response to the Home Quotes SP list and creates a linked Leads record.

**Pros:**
- Shareable via URL, QR code, or embedded on the agency website
- No SharePoint license required for the person submitting — anyone can fill it out
- Mobile-friendly out of the box
- Supports file uploads (e.g., photos of existing dec pages)
- Fully anonymous submission available (tenant permitting — see Section 4)

**Cons:**
- Requires a Power Automate flow to move data from Forms to SharePoint (extra plumbing)
- Limited field types — no cascading dropdowns, no conditional logic without Power Apps
- Response data lives in Forms storage temporarily before being moved to SP

**Best for:** Printed QR codes at the agency counter, Outlook signature links, website embed, anything where the submitter is a prospect (not an agent).

---

#### Option A2 — SharePoint List Form (Recommended for Agent-Initiated Entry)

**How it works:** The "Home Quotes" SP list has a built-in list form (the default New Item form). An agent opens the list form from within the CRM dashboard ("+ New Home Quote" button) and fills it out directly. On save, a small Power Automate flow or SP list workflow creates the linked Leads record and Activity entry.

**Pros:**
- Zero extra plumbing — SP handles storage natively
- No Forms infrastructure to maintain
- Agents are already logged in, so no auth friction
- All 30+ columns available without custom connectors

**Cons:**
- Requires a SharePoint license (agents already have one, so non-issue for this team)
- Less polished mobile UX than Microsoft Forms
- Can't be used by external prospects (requires login)

**Best for:** Agent-initiated quote entry when a prospect calls in or walks in and the agent is entering data directly.

---

### Recommended Split

| Scenario | Delivery Method |
|----------|----------------|
| Prospect fills out form themselves (QR code, website, email link) | **Option A1 — Microsoft Forms** |
| Agent fills out form on behalf of prospect (phone intake, walk-in) | **Option A2 — SharePoint List Form** |
| Quick lead capture without full quote (see Path B) | **Path B — Canvas App modal** |

Both A1 and A2 must be available. They feed the same SP lists.

---

### Option A1 — Form Fields (Microsoft Forms)

> ⚠️ **Note:** The homeowner quote PDF (`Homeowner_fixed_1.pdf`) could not be parsed by automation tools in this session. The field list below is based on the known Leads/Home Quotes SP list schema and standard Alfa Insurance homeowner quote requirements. **Alec must verify this list against the actual paper form before building the Microsoft Form.**

**Recommended Microsoft Form structure:**

**Section 1 — Applicant Information**
- Full Name *(required, Short Answer)*
- Date of Birth *(required, Date)*
- Phone Number *(required, Short Answer — use text, not number, to preserve formatting)*
- Email Address *(Short Answer)*
- Spouse / Co-applicant Name *(Short Answer)*
- Spouse Date of Birth *(Date)*
- Spouse Phone *(Short Answer)*

**Section 2 — Property Information**
- Risk / Property Address *(required, Short Answer)*
- City, State, ZIP *(Short Answer)*
- Year Built *(Short Answer)*
- Square Footage *(Short Answer)*
- Number of Stories *(Choice: 1, 2, 3+)*
- Construction Type *(Choice: Brick, Frame, Vinyl, Other)*
- Roof Type *(Choice: Shingle, Metal, Tile, Other)*
- Roof Year *(Short Answer)*

**Section 3 — Coverage Details**
- Current Carrier *(Short Answer)*
- Current Premium *(Short Answer)*
- Coverage Amount Requested *(Short Answer)*
- Deductible Preference *(Choice: $500, $1,000, $2,500, $5,000)*
- Any claims in last 3 years? *(Choice: Yes / No)*
- If yes — describe *(Long Text, shown conditionally)*

**Section 4 — Additional Information**
- Dogs on property? *(Choice: Yes / No)*
- Dog breed(s) *(Short Answer, shown conditionally)*
- Pool or trampoline? *(Choice: Yes / No)*
- How did you hear about us? *(Choice: Referral, Website, Social Media, Walk-In, Mailer, Other)*
- Notes / Additional Information *(Long Text)*

**Confirmation:** After submit, show message: "Thank you — an Adams Cosby agent will be in touch within one business day."

---

### Option A1 — Power Automate Flow: Forms → SP + Leads

**Flow name:** `AdamsCosbyCRM_HomeQuoteFormSubmission`

**Trigger:** Microsoft Forms — When a new response is submitted
- Form ID: *(select the homeowner quote form)*

**Step 1 — Get Response Details:**
`Microsoft Forms — Get response details`
- Form ID: same as trigger
- Response ID: `@{triggerOutputs()?['body/resourceData/responseId']}`

**Step 2 — Create Home Quotes SP item:**
`SharePoint — Create item` → Home Quotes list

Map each form answer to the corresponding SP column. All columns use `outputs('Get_response_details')?['body/r[N]']` where N is the response field index, or use the named dynamic content if available.

**Step 3 — Create Leads SP item:**
`SharePoint — Create item` → Leads list

| Leads Column | Value |
|-------------|-------|
| Title | `@{outputs('Create_Home_Quote')?['body/ApplicantName']}` *(or mapped field)* |
| Phone Number | Form answer — phone |
| Email | Form answer — email |
| Source | `Homeowner Quote` *(hardcoded)* |
| Source Detail | Form answer — "How did you hear about us?" |
| Status | `Active` |
| Agent | `abadams@alfains.com` *(default — agent can reassign in CRM)* |
| QuoteID | `@{outputs('Create_Home_Quote')?['body/ID']}` *(link to Home Quote)* |

**Step 4 — Log Activity:**
`SharePoint — Create item` → Activities list

| Field | Value |
|-------|-------|
| ActivityType | `Homeowner Quote Submitted` |
| Lead | `@{outputs('Create_Leads_Item')?['body/ID']}` |
| Agent | `abadams@alfains.com` |
| EventDate | `@{utcNow()}` |
| Notes | `Homeowner quote submitted via Microsoft Forms` |

> **Flow 3a fires automatically** after Step 3 creates the Leads item. No need to send a separate notification — Flow 3a handles agent notification and To-Do task creation.

---

### Option A2 — SP List Form Flow: Home Quotes → Leads

**Flow name:** `AdamsCosbyCRM_HomeQuoteListItem_CreateLead`

**Trigger:** SharePoint — When an item is created → Home Quotes list

**Step 1 — Check if Linked Lead Already Exists:**
`SharePoint — Get items` → Leads list, filter: `QuoteID eq @{triggerOutputs()?['body/ID']}`

**Step 2 — Condition: Lead exists?**
- YES → terminate (agent may have created the lead manually already)
- NO → continue

**Step 3 — Create Leads item** (same mapping as Option A1 Step 3)

**Step 4 — Log Activity** (same as Option A1 Step 4)

---

## Section 2 — Path B: Lead First (ALTERNATIVE)

### When to Use Path B

Path B is for "other to-dos outside of main quotes" — capturing a person's contact info for follow-up when no quote has been requested yet. Examples: a referral name and phone number, a cold call prospect, someone who asked a general question at a community event.

---

### Form Delivery — Canvas App Modal (Recommended)

**Option B1 — Power Apps Canvas Modal (Recommended)**

The `+ Add Lead` button on the dashboard header opens an in-app modal with a minimal quick-add form. This is the smoothest UX since the agent never leaves the dashboard.

Fields in the modal:
- Name *(required)*
- Phone Number
- Email
- Source *(Choice dropdown)*
- Source Detail *(Choice or text)*
- Notes *(multi-line)*

On submit: `Patch(Leads, Defaults(Leads), { Title: txtName.Text, Phone_x0020_Number: txtPhone.Text, Email: txtEmail.Text, Source: ddlSource.Selected.Value, Source_x0020_Detail: ddlSourceDetail.Selected.Value, Notes: txtNotes.Text, Status: "Active", Agent: { '@odata.type': '#Microsoft.Azure.Connectors.SharePoint.SPListExpandedUser', Claims: "i:0#.f|membership|" & User().Email } })`

After patch, Flow 3a fires automatically on the new Leads item.

**Option B2 — Microsoft Forms link (not recommended)**

A separate "Quick Lead" Microsoft Form could be used as a fallback for mobile capture, but this adds an extra form to maintain and fragments the intake path. Prefer Option B1.

**Option B3 — SharePoint list form directly**

Navigating to the Leads list New Item form is always available as a fallback but provides no guided UX. Acceptable for power users; not recommended as the primary path.

---

## Section 3 — Both Paths Co-Exist in the Dashboard

The dashboard header will have two distinct action buttons:

| Button | Path | What It Creates |
|--------|------|----------------|
| `+ New Lead` | Path B | Leads record only (quick add) |
| `+ New Home Quote` | Path A (Option A2) | Home Quotes record + auto-creates Leads record |

Both buttons are present simultaneously. Agents choose based on what they have:
- Full quote data available → `+ New Home Quote`
- Just contact info → `+ New Lead`

---

## Section 4 — Form-to-SharePoint Authentication

### How Microsoft Forms Submissions Reach SharePoint Without Auth Issues

When a prospect submits the Microsoft Form, Power Automate handles the data transfer — the prospect never touches SharePoint directly. The flow runs as the **flow owner's account** (Alec's account, `abadams@alfains.com`), so the SP write uses Alec's permissions regardless of who submitted the form.

### Anonymous / External Submissions

For the form to accept responses from anyone (not just alfains.com users):

1. In Microsoft Forms, click Share → *(toggle)* "Anyone with the link can respond"
2. The form must NOT be set to "Only people in my organization"

**Tenant-level requirement:** The `alfains` tenant must allow Forms to be shared externally. This is controlled by an admin setting in the Microsoft 365 admin center under Settings → Org settings → Microsoft Forms → External sharing. 

> ⚠️ **Blocker — confirm with admin before building:** If the tenant has restricted external Forms responses, the public-facing QR code / website intake will not work. Alec should confirm with whoever manages the alfains M365 tenant (likely the Alfa Insurance IT team) whether external Forms responses are permitted.

If external Forms are blocked, **Option A2 (SharePoint List Form via the dashboard) becomes the only Path A option**, and agents must enter all quote data on the prospect's behalf.

---

## Section 5 — Compatibility with Round 1 Findings

Round 1 recommended merging Leads and Home Quotes into one list. This section explains both scenarios:

### If Lists Are Kept Separate (Current State)

- **Path A** creates 2 records: one in Home Quotes + one in Leads, linked by QuoteID
- Power Automate flow must write to both lists
- Quote Documents' `RelatedQuote` lookup continues to point to Leads.QuoteID
- All flows (3a, 3b, 3c, 3d) target the Leads list only — Home Quotes is the source record, Leads is the pipeline record

### If Lists Are Merged (Round 1 Recommendation)

- **Path A** creates 1 record in the merged Leads list with both quote fields AND pipeline fields populated
- `CoverageType = "Home"` column distinguishes home quote records from other lead types
- Simpler flow (one SP Create instead of two)
- Quote Documents lookup retains its QuoteID reference — no change needed
- This is the cleaner architecture and remains the recommended path

**Decision still pending** — see Section 6.

---

## Section 6 — Open Decisions for Alec

| # | Question | Impact |
|---|----------|--------|
| A | **Anonymous Microsoft Forms allowed in the alfains tenant?** Must confirm with M365 admin before building the public-facing QR form. | If NO: Path A public intake is impossible; agents must enter all data manually via Option A2 |
| B | **Merge Leads + Home Quotes into one list?** (Round 1's #1 recommendation, still open) | If YES: Path A creates 1 record instead of 2; simpler flows; do before building Path A flow |
| C | **Public-facing form URL hosting:** QR code at the counter? Embedded on website? Both? Outlook signature link? | Determines how the Microsoft Form is shared and where the URL lives |
| D | **Default agent on Forms submission:** Currently spec'd as Alec. Should it be unassigned (blank) and agent assigns manually in the CRM, or always default to Alec? | Affects how Flow 3a routes the new-lead notification |
| E | **Homeowner_fixed_1.pdf field review:** Alec should verify the Microsoft Form field list in Section 1 against the actual paper form to confirm all fields are captured and none are missing | If fields don't match, the Forms submission creates incomplete Home Quote records |
