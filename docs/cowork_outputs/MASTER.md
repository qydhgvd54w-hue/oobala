# Adams Cosby CRM — Complete Build Reference
**Agency:** Adams Cosby Insurance · AA Agency LLC · Foley, AL
**SharePoint Tenant:** alfains.sharepoint.com/teams/1047889-ADAMSCOSBY
**Compiled:** 2026-05-04 · Rounds 1 & 2 combined

> **How to use this document:** Start with Part 1 (Decisions Locked). It is the single source of truth for every decision made. The version table at the end of Part 1 tells you which spec to use for each asset. All individual specs follow in Parts 2–12.

---

## TABLE OF CONTENTS

- [Part 1 — Decisions Locked Master Summary](#part-1--decisions-locked-master-summary)
- [Part 2 — XML Intake Flow Audit](#part-2--xml-intake-flow-audit)
- [Part 3 — Email Templates](#part-3--email-templates)
- [Part 4 — Flow 3a: NewLead (FINAL)](#part-4--flow-3a-newlead-final)
- [Part 5 — Flow 3b: StatusChanged (FINAL)](#part-5--flow-3b-statuschanged-final)
- [Part 6 — Flow 3c: DailyDigest (FINAL)](#part-6--flow-3c-dailydigest-final)
- [Part 7 — Flow 3d: FollowUpReminder](#part-7--flow-3d-followupreminder)
- [Part 8 — SharePoint List Audit](#part-8--sharepoint-list-audit)
- [Part 9 — Photo Audit: Lists, Schema & Forms](#part-9--photo-audit-lists-schema--forms)
- [Part 10 — SharePoint Column Additions](#part-10--sharepoint-column-additions)
- [Part 11 — Dual-Path Intake Architecture](#part-11--dual-path-intake-architecture)
- [Part 12 — Homeowner Form Field Inventory](#part-12--homeowner-form-field-inventory)
- [Part 13 — Microsoft Forms Build Spec](#part-13--microsoft-forms-build-spec)
- [Part 14 — Agent Claims-Syntax Fixes](#part-14--agent-claims-syntax-fixes)
- [Part 15 — Customizations.xml Explained](#part-15--customizationsxml-explained)

---

---

# PART 1 — DECISIONS LOCKED MASTER SUMMARY

*Canonical reference. When a spec below conflicts with this section, this section wins.*

## Meta-Rules (Always Apply)

**MR-1 — List Parity:** Leads and Home Quotes are one schema in two physical lists. Every column add or change on one list must be applied to the other in the same session. No exceptions. After every column add, verify the date auto-fill formula still works on both lists.

**MR-2 — No Round-Robin:** Automatic lead assignment between Alec and Rachel is out of scope. Assignment is always manual. Default on automated intakes = Alec.

**MR-3 — Agent Roster Locked:**
- Agents (assignable): Alec Adams `abadams@alfains.com`, Rachel Cosby `rcosby@alfains.com`
- Inputters (never assigned): Leigh Marsh, Jessica Adams, Tammy Dennis
- Removed: Brooklyn — not in any dropdown or flow

**MR-4 — SharePoint Only, No Dataverse:** All lists, flows, and Canvas data sources target the SharePoint site. The XML files (`Customizations.xml`, `Solution.xml`, `Relationships.xml`) are inert Dataverse artifacts. Do not modify them or add Dataverse connections anywhere.

**MR-5 — Additive Only:** No existing project files may be edited, modified, or deleted. Only new files are created.

## All Resolved Decisions

| # | Decision | Resolution |
|---|----------|-----------|
| R1-1 | What does the XML do? | Nothing. Zero automation. `ac_lineofbusiness` option set is the only content. Inert. |
| R1-2 | Email templates | 7 templates (01–07). Template 08 added in Round 2. |
| R1-3 | From address | `SC1047@alfains.com` — Send As required on Alec's account |
| R1-4 | Reply-to | `teamac@alfains.com` (alias) |
| R1-5 | Daily Digest time | 7:00 AM Central |
| Q1 | LostReason field | Add as Choice: Price, Competitor, No Response, Not Qualified, Timing, Other |
| Q2 | Re-quote timing | Two fields: `RequoteMonthsOut` (Number) + `RequoteDate` (Date). RequoteDate takes priority. |
| Q3 | Re-quote delivery | Calendar Events SP list item (PRIMARY, required). Outlook event is optional. |
| Q4 | Flow owner | Alec's account (`abadams@alfains.com`). No service account. |
| Q5 | Teams channel | REJECTED. Replaced with branded HTML email to agent + CC to SC1047. |
| Q6 | Daily Digest recipients | Both Alec AND Rachel — single To: field, semicolon-separated. |
| Q7 | Follow-up cadence | Deferred. Default: once per 7 days. |
| Q8 | Intake architecture | Dual-path: Path A (Home Quote First, primary) + Path B (Lead First, quick-add). |
| Item 1 | Form delivery | Both MS Forms (prospect self-service) and SP List Form (agent-initiated). |
| Item 2 | Agent dropdown | Alec and Rachel only. |
| Item 3 | Forms access | Internal-org only. "Only people in my organization can respond." |
| Item 4 | Forms spec | See Part 13. Alec must verify `[VERIFY]` fields against physical paper form. |
| Item 5 | LineOfBusiness choices | 4 choices: Auto, Home, Life, Commercial. P&C removed. |
| Item 6 | Agent Claims syntax | All SP Person/Group writes require Claims object — never plain email string. See Part 14. |

## Version Table

| Asset | Use This Version |
|-------|----------------|
| Flow 3a — NewLead | **Part 4 of this document (FINAL)** |
| Flow 3b — StatusChanged | **Part 5 of this document (FINAL)** |
| Flow 3c — DailyDigest | **Part 6 of this document (FINAL)** |
| Flow 3d — FollowUpReminder | **Part 7 of this document** |
| SP column additions | **Part 10 (LineOfBusiness = 4 choices, not 5)** |
| Intake architecture | **Part 11** |
| Microsoft Forms spec | **Part 13** |
| Agent Claims-syntax | **Part 14** |

## Build Order

**Phase 0 — Decisions First:**
1. Verify Microsoft Forms spec (Part 13) against physical paper form
2. Confirm Year Built / Sq Ft / Construction Type / Roof Type / Roof Year columns exist in SP (scroll to bottom of Home Quotes List Settings)
3. Confirm GW ACCT / ID PH / ID Spouse are intake fields or post-binding
4. Confirm which Status vocabulary the live Leads list uses (Active/Working/Quoted/Bound/Lost vs New/Contacted/etc.)
5. Run Phone Number internal name REST query before flow build

**Phase 1 — SharePoint Schema:**
6. Add LostReason, RequoteMonthsOut, RequoteDate, LineOfBusiness to Leads (per Part 10)
7. Add same 4 columns to Home Quotes (MR-1)
8. Add EventType + LeadRef to Calendar Events
9. Add any missing property columns (Year Built, etc.) to both lists
10. Run verification REST query

**Phase 2 — Email Templates:**
11. Load all 8 HTML templates into the Email Templates SP list

**Phase 3 — Flows (in order):**
12. Flow 3c (Daily Digest) — read-only, safest first
13. Flow 3a (NewLead) — verifies Send As permission
14. Flow 3d (FollowUpReminder) — validates overdue query
15. Flow 3b (StatusChanged) — most complex, last

**Phase 4 — Path A Intake:**
16. Build Microsoft Forms from Part 13 (after Phase 0 verification)
17. Build `AdamsCosbyCRM_HomeQuoteFormSubmission` flow
18. Apply Claims syntax per Part 14
19. End-to-end test

**Phase 5 — Dashboard Integration:**
20. Add `+ New Lead` button (Path B Canvas modal)
21. Add `+ New Home Quote` button (Path A SP List Form)
22. Add LeadRef drill-through on Calendar screen
23. Update `<<DashboardLeadURL>>` token in Template 08

## Critical Build-Day Reminders

1. **Send As first.** Confirm SC1047@alfains.com Send As is active on abadams@alfains.com in Exchange Admin Center before testing any flow.
2. **Flow 3b last.** Enter trigger condition before saving. Never write back to the Leads list from inside Flow 3b.
3. **Calendar Events write is required, not optional.** The re-quote feature does not exist without it.
4. **MR-1 every time.** Open Leads and Home Quotes in parallel tabs whenever adding columns.
5. **Do not touch ADAMSCOSBY_CLEAN.** Canvas app build files are off-limits.

## Open Items Still Pending Alec's Action

| # | Item | Blocks |
|---|------|--------|
| A | Verify form spec (Part 13) against physical paper form | Phase 4 |
| B | Confirm property columns exist in SP | Phase 1 |
| C | Confirm GW ACCT / ID PH / ID Spouse purpose | Phase 4 |
| D | Confirm Status vocabulary | Phase 3 — Flow 3b trigger |
| E | Phone Number internal name REST query | Phase 3 |
| F | List all existing PA flows touching these lists | Phase 3 |
| G | Follow-up cadence decision | Flow 3d |
| H | Merge Leads + Home Quotes? (Round 1 recommendation, still open) | Simplifies Phase 4 to 1 SP write |

---

---

# PART 2 — XML INTAKE FLOW AUDIT

## Key Finding

**The three XML files (Solution.xml, Customizations.xml, Relationships.xml) contain zero automation.** No flows, triggers, workflows, or business logic exist in any of them.

The only functional content is a single custom global picklist: `ac_lineofbusiness` with values P&C, Alfa Agency, Life. This is a Dataverse option set — it has no connection to SharePoint lists and is irrelevant to this CRM.

`Relationships.xml` is a two-line empty tag. `Solution.xml` is a metadata wrapper. `Customizations.xml` contains the one option set and nothing else.

## What This Means

The "intake automation" either hasn't been built yet, or lives in Power Automate cloud flows that were never exported to this solution package. Parts 4–7 of this document are the specifications to build it for the first time.

## What To Do With These Files

Leave them as-is — they're clean and correct. Do not modify them. The `ac_lineofbusiness` option set could be reused if the CRM ever migrates to Dataverse, but it has no active role in the current SharePoint-based setup.

---

---

# PART 3 — EMAIL TEMPLATES

## Summary

Eight production-ready HTML email templates with inline styles, Outlook-compatible table layout, brand red (`#C8102E`) accents, and `<<TokenName>>` merge syntax.

| # | Title | Subject Line | When to Send |
|---|-------|-------------|-------------|
| 01 | New Lead Introduction | `Welcome to Adams Cosby Insurance, <<FirstName>> — Let's Get You Covered` | Within 24 hours of lead creation |
| 02 | Auto Insurance Information | `Your Auto Insurance Options — Adams Cosby Insurance` | First follow-up for auto leads |
| 03 | Home Insurance Information | `Protecting Your Home at <<RiskAddress>> — Here's What to Know` | First follow-up for home leads |
| 04 | Quote Sent / Quote Ready | `Your Insurance Quote Is Ready, <<FirstName>>` | On Status → Quoted |
| 05 | Follow-Up Reminder | `Just Checking In, <<FirstName>> — Still Here to Help` | After 7 days no response |
| 06 | Re-Quote Auto (5-Month) | `Time to Review Your Auto Coverage, <<FirstName>>` | ~5 months after Lost — auto |
| 07 | Re-Quote Home (11-Month) | `Your Home Insurance Renewal Is Coming Up, <<FirstName>>` | ~11 months after Lost — home |
| 08 | New Lead Notification to Agent | `New Lead: <<LeadName>> — <<Source>>` | On new lead creation (Flow 3a) |

## Token Replacement in Power Automate

Use a chain of `replace()` expressions or Compose actions:
```
replace(replace(body('Get_Template')?['Body'], '<<FirstName>>', triggerOutputs()?['body/Title']), '<<AgentName>>', variables('varAgentName'))
```

For Template 08 specifically, embed the HTML directly in the Flow 3a Compose step (faster, no list lookup per run). See Part 4 Step 3 for the full token substitution map.

## Brand Compliance

All templates: `#C8102E` red for headers/CTAs, `#1F1E1D` dark gray for body text, Arial/Helvetica, no external CSS, no images, no JavaScript. Compatible with Outlook desktop, OWA, and mobile.

## Template File Locations

Templates 01–07: `COWORK_OUTPUTS/templates/`
Template 08: `COWORK_OUTPUTS/round2/templates/08_new_lead_notification_to_agent.html`

---

---

# PART 4 — FLOW 3A: NEWLEAD (FINAL)

**Flow name:** `AdamsCosbyCRM_NewLead`
*Supersedes Round 1 spec. Teams post removed; replaced with branded HTML email (Template 08).*

## Trigger

| Setting | Value |
|---------|-------|
| Connector | SharePoint — When an item is created |
| Site | `https://alfains.sharepoint.com/teams/1047889-ADAMSCOSBY` |
| List | `Leads` |

No trigger condition — fires on every new Leads item.

## Steps

### Step 1 — Initialize Variables

| Variable | Type | Value |
|----------|------|-------|
| `varLeadTitle` | String | `@{triggerOutputs()?['body/Title']}` |
| `varAgentEmail` | String | `@{triggerOutputs()?['body/Agent/Email']}` |

### Step 2 — Condition: Agent Assigned?

```
@{empty(variables('varAgentEmail'))}  is equal to  false
```

YES (agent set) → use `varAgentEmail`. NO (empty) → set `varAgentEmail` = `abadams@alfains.com`. Continue to Step 3 either way.

### Step 3 — Compose Email Body

Embed Template 08 HTML with these token substitutions:

| Token | Expression |
|-------|-----------|
| `<<LeadName>>` | `@{triggerOutputs()?['body/Title']}` |
| `<<AgentName>>` | `@{triggerOutputs()?['body/Agent/DisplayName']}` |
| `<<PhoneNumber>>` | `@{triggerOutputs()?['body/Phone_x0020_Number']}` |
| `<<LeadEmail>>` | `@{triggerOutputs()?['body/Email']}` |
| `<<Source>>` | `@{triggerOutputs()?['body/Source']}` |
| `<<SourceDetail>>` | `@{triggerOutputs()?['body/Source_x0020_Detail']}` |
| `<<RiskAddress>>` | `@{triggerOutputs()?['body/Risk_x0020_Address']}` |
| `<<DOB>>` | `@{triggerOutputs()?['body/DOB']}` |
| `<<Notes>>` | `@{triggerOutputs()?['body/Notes']}` |
| `<<CreatedDate>>` | `@{formatDateTime(triggerOutputs()?['body/Created'], 'M/d/yyyy h:mm tt')}` |
| `<<DashboardLeadURL>>` | `https://alfains.sharepoint.com/teams/1047889-ADAMSCOSBY/Lists/Leads/DispForm.aspx?ID=@{triggerOutputs()?['body/ID']}` |

### Step 4 — Send Notification Email

| Field | Value |
|-------|-------|
| To | `@{variables('varAgentEmail')}` |
| CC | `SC1047@alfains.com` |
| From | `SC1047@alfains.com` *(Send As required)* |
| Subject | `New Lead: @{variables('varLeadTitle')} — @{triggerOutputs()?['body/Source']}` |
| Body | `@{outputs('Compose_Email_Body')}` |
| Is HTML | Yes |

### Step 5 — Create Microsoft To-Do Task

| Field | Value |
|-------|-------|
| List ID | Adams Cosby CRM *(create manually before first run)* |
| Title | `Contact @{variables('varLeadTitle')} within 24 hours` |
| Due Date | `@{addDays(utcNow(), 1)}` |
| Assigned To | `@{variables('varAgentEmail')}` |
| Notes | `Source: @{triggerOutputs()?['body/Source']} · Phone: @{triggerOutputs()?['body/Phone_x0020_Number']}` |

### Step 6 — Log to Activities

| Field | Value |
|-------|-------|
| List | `Activities` |
| ActivityType | `Created` |
| Lead | `@{triggerOutputs()?['body/ID']}` |
| Agent | *(Claims syntax — see Part 14 Instance 5)* |
| EventDate | `@{utcNow()}` |
| Notes | `Lead created via @{triggerOutputs()?['body/Source']}` |

## Error Handling

Wrap Steps 3–6 in a Scope. On failure: email `abadams@alfains.com` with Lead ID and Run ID.

## Loop Risk

None. Fires on Create only. Never add a write to the Leads list in this flow.

## Permissions

SharePoint Read (Leads), SharePoint Write (Activities), Send As SC1047, Microsoft To-Do Business.

## Build Checklist

- [ ] Create "Adams Cosby CRM" To-Do list before first run
- [ ] Grant Send As on SC1047 to abadams@alfains.com
- [ ] Embed Template 08 HTML with token map above
- [ ] Apply Claims syntax (Part 14) to Step 6 Agent field
- [ ] Update `<<DashboardLeadURL>>` once Canvas app has stable deeplink

## Test Plan

| Test | Setup | Expected |
|------|-------|---------|
| TC-1 | New lead, agent=Alec | Branded email to agent, CC at SC1047, To-Do created, Activity logged |
| TC-2 | New lead, no agent | Email redirects to abadams@alfains.com, all other steps normal |
| TC-3 | Lead created by HomeQuote flow | Flow 3a fires on auto-created Leads item, no double notification |

---

---

# PART 5 — FLOW 3B: STATUSCHANGED (FINAL)

**Flow name:** `AdamsCosbyCRM_StatusChanged`
*Supersedes Round 1 spec. Teams post removed. RequoteMonthsOut/RequoteDate logic. Calendar Events required.*

## Pre-Build Requirements

Leads list must have: `LostReason` (Choice), `RequoteMonthsOut` (Number), `RequoteDate` (Date).
Calendar Events list must have: `EventDate` (Date), `Agent` (Person), `LeadRef` (Lookup → Leads), `EventType` (Choice with "Re-Quote Check-In").

## Trigger

| Setting | Value |
|---------|-------|
| Connector | SharePoint — When an item is modified |
| Site | `https://alfains.sharepoint.com/teams/1047889-ADAMSCOSBY` |
| List | `Leads` |
| **Trigger Condition** | `@or(equals(triggerOutputs()?['body/Status'], 'Bound'), equals(triggerOutputs()?['body/Status'], 'Lost'))` |

> **Critical:** Set this in the trigger's Advanced → Trigger Conditions field — NOT as a runtime Condition action. This prevents the flow from starting at all on other field edits, eliminating quota consumption and loop risk.
>
> After saving, re-open the trigger and confirm the condition still appears. Power Automate sometimes silently drops it on save.

## Steps

### Step 1 — Initialize Variables

| Variable | Type | Value |
|----------|------|-------|
| `varLeadTitle` | String | `@{triggerOutputs()?['body/Title']}` |
| `varAgentEmail` | String | `@{triggerOutputs()?['body/Agent/Email']}` |
| `varRequoteDate` | String | *(blank)* |

### Step 2 — Switch on Status

Expression: `@{triggerOutputs()?['body/Status']}`

---

### BOUND BRANCH

**Step 3a — Send Celebration Email**

| Field | Value |
|-------|-------|
| To | `@{variables('varAgentEmail')}` |
| CC | `abadams@alfains.com`, `SC1047@alfains.com` |
| From | `SC1047@alfains.com` |
| Subject | `🎉 Bound! @{variables('varLeadTitle')}` |
| Body (HTML) | Branded table: Lead Name, Agent, Bound On date |

```html
<table style="font-family:Arial,sans-serif;max-width:600px;width:100%;">
  <tr><td style="background:#C8102E;padding:20px 30px;">
    <p style="margin:0;color:#fff;font-size:20px;font-weight:bold;">Adams Cosby Insurance</p>
  </td></tr>
  <tr><td style="padding:28px 30px;color:#1F1E1D;">
    <p style="font-size:16px;">🎉 <strong>Great news — a lead just went Bound!</strong></p>
    <table style="border-collapse:collapse;width:100%;margin-top:12px;">
      <tr><td style="padding:6px 12px;background:#f9f9f9;font-weight:bold;width:140px;">Lead Name</td>
          <td style="padding:6px 12px;">@{triggerOutputs()?['body/Title']}</td></tr>
      <tr><td style="padding:6px 12px;background:#f0f0f0;font-weight:bold;">Agent</td>
          <td style="padding:6px 12px;">@{triggerOutputs()?['body/Agent/DisplayName']}</td></tr>
      <tr><td style="padding:6px 12px;background:#f9f9f9;font-weight:bold;">Bound On</td>
          <td style="padding:6px 12px;">@{formatDateTime(utcNow(), 'M/d/yyyy h:mm tt')}</td></tr>
    </table>
  </td></tr>
</table>
```

**Step 3b — Log Activity (Bound)**

| Field | Value |
|-------|-------|
| List | `Activities` |
| ActivityType | `Status Change` |
| Lead | `@{triggerOutputs()?['body/ID']}` |
| Agent | *(Claims syntax — see Part 14)* |
| EventDate | `@{utcNow()}` |
| Notes | `Status changed to Bound` |

---

### LOST BRANCH

**Step 4a — Check LostReason Populated**

Condition: `@{empty(triggerOutputs()?['body/LostReason'])}  is equal to  true`

YES (blank) → send warning email to agent: subject `⚠️ Lost Reason Missing: @{variables('varLeadTitle')}`. Continue to 4b regardless.

**Step 4b — Calculate Re-Quote Date**

Condition 1: Is `RequoteDate` set?
```
@{empty(triggerOutputs()?['body/RequoteDate'])}  is equal to  false
```
YES → `varRequoteDate` = `@{triggerOutputs()?['body/RequoteDate']}`

NO → Condition 2: Is `RequoteMonthsOut` set?
```
@{empty(triggerOutputs()?['body/RequoteMonthsOut'])}  is equal to  false
```
YES → `varRequoteDate` = `@{addDays(utcNow(), mul(int(triggerOutputs()?['body/RequoteMonthsOut']), 30))}`
NO → `varRequoteDate` = `""`

**Step 4c — Condition: Schedule Re-Quote?**

```
@{empty(variables('varRequoteDate'))}  is equal to  false
```

YES (date is set) → Steps 5a + 5b. NO → skip to Step 6.

**Step 5a — Create Calendar Events SP Item** *(PRIMARY — Required)*

| Field | Value |
|-------|-------|
| List | `Calendar Events` |
| Title | `Re-quote check-in: @{variables('varLeadTitle')}` |
| EventDate | `@{variables('varRequoteDate')}` |
| Agent | *(Claims syntax — see Part 14 Instance 7)* |
| LeadRef | `@{triggerOutputs()?['body/ID']}` |
| EventType | `Re-Quote Check-In` |
| Notes | `Lead marked Lost (@{triggerOutputs()?['body/LostReason']}). Scheduled re-quote.` |

> This is the CRM-visible event. It appears on the dashboard Calendar screen. This step is mandatory — Outlook calendar event (5b) is optional.

**Step 5b — Create Outlook Calendar Event** *(Secondary — Optional)*

| Field | Value |
|-------|-------|
| Calendar ID | `@{variables('varAgentEmail')}` |
| Subject | `Re-quote: @{variables('varLeadTitle')}` |
| Start | `@{variables('varRequoteDate')}` |
| End | `@{addMinutes(variables('varRequoteDate'), 30)}` |
| Reminder | 1440 minutes (1 day) |

**Step 6 — Log Activity (Lost)**

| Field | Value |
|-------|-------|
| List | `Activities` |
| ActivityType | `Status Change` |
| Notes | `Status changed to Lost. Reason: @{if(empty(triggerOutputs()?['body/LostReason']), '(not provided)', triggerOutputs()?['body/LostReason'])}. Re-quote: @{if(empty(variables('varRequoteDate')), 'None', variables('varRequoteDate'))}` |

## Error Handling

Wrap Switch (Steps 2–6) in a Scope. On failure: email `abadams@alfains.com` with Lead ID and Run ID.

## Loop Prevention

Primary: Trigger condition fires only on Bound/Lost — all other edits skip the flow.
Secondary: Flow never writes to the Leads list. Writes to Activities and Calendar Events only.

## Test Plan

| Test | Setup | Expected |
|------|-------|---------|
| TC-1 | Mark lead Bound | Celebration email to agent + Alec + SC1047. Activity logged. No Calendar Event. |
| TC-2 | Lost, no LostReason | Warning email to agent. Activity logged "(not provided)". No Calendar Event (no date set). |
| TC-3 | Lost, LostReason=Price, RequoteMonthsOut=5 | No warning. Calendar Event created at today+150 days. Activity logged with date. |
| TC-4 | Lost, explicit RequoteDate set | Calendar Event on exact date. RequoteDate overrides RequoteMonthsOut. |

## Build Checklist

- [ ] Add LostReason, RequoteMonthsOut, RequoteDate to Leads (Part 10)
- [ ] Add EventType "Re-Quote Check-In" to Calendar Events
- [ ] Add LeadRef lookup to Calendar Events
- [ ] Enter trigger condition before first save
- [ ] Verify trigger condition persists after save
- [ ] Apply Claims syntax to Step 3b and Step 5a Agent fields (Part 14)
- [ ] Run TC-2 first before enabling production

---

---

# PART 6 — FLOW 3C: DAILYDIGEST (FINAL)

**Flow name:** `AdamsCosbyCRM_DailyDigest`
*Supersedes Round 1 spec. Both Alec + Rachel as recipients. 4th section: re-quote check-ins.*

## Trigger

| Setting | Value |
|---------|-------|
| Connector | Schedule — Recurrence |
| Frequency | Week |
| Days | Monday, Tuesday, Wednesday, Thursday, Friday |
| Hour | 8 · Minute | 0 |
| Time zone | (UTC-06:00) Central Time (US & Canada) |

## Steps

### Step 1 — New Leads in Last 24 Hours
`SharePoint — Get items` → Leads · Filter: `Created ge '@{addDays(utcNow(), -1)}'` · Top 500
→ Set `varNewLeadCount` = `@{length(outputs('Get_New_Leads')?['body/value'])}`

### Step 2 — Follow-Ups Due (Working, 7+ Days)
`SharePoint — Get items` → Leads · Filter: `Status eq 'Working' and Modified le '@{addDays(utcNow(), -7)}'` · Top 500
→ Set `varFollowUpLeads` (Array)

### Step 3 — Stale Quotes (Quoted, 14+ Days)
`SharePoint — Get items` → Leads · Filter: `Status eq 'Quoted' and Modified le '@{addDays(utcNow(), -14)}'` · Top 500
→ Set `varStaleQuotes` (Array)

### Step 4 — Re-Quote Check-Ins Due This Week *(New)*
`SharePoint — Get items` → Calendar Events
Filter: `EventDate ge '@{utcNow()}' and EventDate le '@{addDays(utcNow(), 7)}' and EventType eq 'Re-Quote Check-In'`
Order By: `EventDate asc` · Top 500
→ Set `varRequoteEvents` (Array)

### Step 5 — Build HTML Row Variables

Four `Apply to Each` loops building table row strings (`varFollowUpRows`, `varStaleQuoteRows`, `varRequoteRows`). Pattern per loop:

```html
<tr>
  <td style="padding:7px 10px;border-bottom:1px solid #eee;">@{items()?['Title']}</td>
  <td style="padding:7px 10px;border-bottom:1px solid #eee;">@{items()?['Agent/DisplayName']}</td>
  <td style="padding:7px 10px;border-bottom:1px solid #eee;">@{formatDateTime(items()?['Modified'], 'M/d/yyyy')}</td>
</tr>
```

Re-quote rows use `EventDate` instead of `Modified`.

### Step 6 — Compose Full Email Body

```html
<table style="font-family:Arial,sans-serif;max-width:660px;width:100%;border-collapse:collapse;">
  <tr>
    <td style="background:#C8102E;padding:20px 28px;">
      <p style="margin:0;color:#fff;font-size:18px;font-weight:bold;">Adams Cosby CRM — Daily Digest</p>
      <p style="margin:4px 0 0 0;font-size:13px;color:#f9d0d6;">@{formatDateTime(utcNow(), 'dddd, MMMM d, yyyy')} · 8:00 AM Central</p>
    </td>
  </tr>
  <tr><td style="padding:24px 28px 8px 28px;">
    <p style="font-size:15px;font-weight:bold;color:#1F1E1D;margin:0 0 6px 0;">🆕 New Leads (Last 24 Hours)</p>
    <p style="font-size:14px;color:#333;margin:0 0 20px 0;">
      <strong style="font-size:22px;color:#C8102E;">@{variables('varNewLeadCount')}</strong> new lead(s) entered the pipeline.
    </p>
    <p style="font-size:15px;font-weight:bold;">⏰ Follow-Ups Due (Working, 7+ Days No Contact)</p>
    <table width="100%" style="border-collapse:collapse;font-size:13px;margin-bottom:20px;">
      <tr style="background:#C8102E;">
        <th style="padding:8px 10px;color:#fff;text-align:left;">Lead Name</th>
        <th style="padding:8px 10px;color:#fff;text-align:left;">Agent</th>
        <th style="padding:8px 10px;color:#fff;text-align:left;">Last Touched</th>
      </tr>
      @{if(empty(variables('varFollowUpRows')), '<tr><td colspan="3" style="padding:8px 10px;color:#888;">None — all leads up to date.</td></tr>', variables('varFollowUpRows'))}
    </table>
    <p style="font-size:15px;font-weight:bold;">📋 Stale Quotes (Quoted, 14+ Days No Activity)</p>
    <table width="100%" style="border-collapse:collapse;font-size:13px;margin-bottom:20px;">
      <tr style="background:#C8102E;">
        <th style="padding:8px 10px;color:#fff;text-align:left;">Lead Name</th>
        <th style="padding:8px 10px;color:#fff;text-align:left;">Agent</th>
        <th style="padding:8px 10px;color:#fff;text-align:left;">Last Modified</th>
      </tr>
      @{if(empty(variables('varStaleQuoteRows')), '<tr><td colspan="3" style="padding:8px 10px;color:#888;">None — no stale quotes.</td></tr>', variables('varStaleQuoteRows'))}
    </table>
    <p style="font-size:15px;font-weight:bold;">📅 Re-Quote Check-Ins Due This Week</p>
    <table width="100%" style="border-collapse:collapse;font-size:13px;margin-bottom:20px;">
      <tr style="background:#C8102E;">
        <th style="padding:8px 10px;color:#fff;text-align:left;">Lead / Event</th>
        <th style="padding:8px 10px;color:#fff;text-align:left;">Agent</th>
        <th style="padding:8px 10px;color:#fff;text-align:left;">Scheduled Date</th>
      </tr>
      @{if(empty(variables('varRequoteRows')), '<tr><td colspan="3" style="padding:8px 10px;color:#888;">No re-quote check-ins this week.</td></tr>', variables('varRequoteRows'))}
    </table>
  </td></tr>
  <tr><td style="background:#f4f4f4;padding:14px 28px;border-top:1px solid #e8e8e8;">
    <p style="margin:0;font-size:11px;color:#888888;">Sent automatically by AdamsCosbyCRM_DailyDigest</p>
  </td></tr>
</table>
```

### Step 7 — All Clear Check

If all four counts are zero → override subject with `CRM Digest @{formatDateTime(utcNow(), 'M/d')} — ✅ All Clear`

### Step 8 — Send Digest Email

| Field | Value |
|-------|-------|
| To | `abadams@alfains.com; rcosby@alfains.com` |
| From | `SC1047@alfains.com` |
| Subject | `CRM Digest @{formatDateTime(utcNow(), 'M/d')} — @{variables('varNewLeadCount')} new · @{length(variables('varFollowUpLeads'))} follow-ups · @{length(variables('varStaleQuotes'))} stale · @{length(variables('varRequoteEvents'))} re-quotes` |
| Body | `@{outputs('Compose_Email_Body')}` |
| Is HTML | Yes |

## Build Checklist

- [ ] Set time zone to Central on recurrence trigger
- [ ] Enter both emails in To: field (semicolon-separated)
- [ ] Confirm Calendar Events has EventDate, EventType, Agent columns
- [ ] Confirm "Re-Quote Check-In" choice value exists in EventType

---

---

# PART 7 — FLOW 3D: FOLLOWUPREMINDER

**Flow name:** `AdamsCosbyCRM_FollowUpReminder`
*Round 1 spec — no changes in Round 2.*

## Trigger

| Setting | Value |
|---------|-------|
| Connector | Schedule — Recurrence |
| Frequency | Day · Hour | 9 · Minute | 0 |
| Time zone | Central Time |

## Steps

### Step 1 — Query Overdue Working Leads
`SharePoint — Get items` → Leads
Filter: `Status eq 'Working' and Modified le '@{addDays(utcNow(), -7)}'`
Order By: `Modified asc` · Top 500

### Step 2 — Condition: Any Results?
`@{length(outputs('Get_Overdue_Leads')?['body/value'])}  is greater than  0`
NO → terminate. YES → Step 3.

### Step 3 — Apply to Each Overdue Lead

**Step 3a — Send Reminder Email**

```html
<p>Hi @{items('Apply_to_each')?['Agent/DisplayName']},</p>
<p>Friendly reminder — this lead hasn't been updated in 7+ days:</p>
<ul>
  <li><strong>Name:</strong> @{items('Apply_to_each')?['Title']}</li>
  <li><strong>Phone:</strong> @{items('Apply_to_each')?['Phone_x0020_Number']}</li>
  <li><strong>Status:</strong> @{items('Apply_to_each')?['Status']}</li>
  <li><strong>Last Modified:</strong> @{formatDateTime(items('Apply_to_each')?['Modified'], 'M/d/yyyy')}</li>
</ul>
<p>Please update this lead's status or add a note after contact.</p>
<p>— Adams Cosby CRM</p>
```

**Step 3b — Create To-Do Task**

Title: `Follow up: @{items('Apply_to_each')?['Title']} — last touched @{formatDateTime(items('Apply_to_each')?['Modified'], 'M/d')}`
Due: `@{utcNow()}`

## Design Note

This flow sends a reminder every day a lead stays overdue. To cap at once per 3 days: add a filter before sending — check Activities for a "Reminder Sent" entry on this Lead ID within the last 3 days. If found, skip.

## Build Checklist

- [ ] Confirm Agent/Email path works (Person/Group column)
- [ ] Set Apply to Each concurrency to 1 (sequential, prevents Outlook throttling)
- [ ] Decide: weekdays only or daily?
- [ ] Decide: daily reminders or capped?

---

---

# PART 8 — SHAREPOINT LIST AUDIT

## Authentication Note

Live REST API calls cannot be performed from this environment (MFA/OAuth required). This audit is based on the project brief schema, photo evidence (Part 9), and standard SharePoint behavior. To verify live: use PnP PowerShell with `Connect-PnPOnline -UseWebLogin`.

## Confirmed SP Lists (from photo audit)

| # | List | Purpose |
|---|------|---------|
| 1 | Leads | Pipeline / lead management |
| 2 | Home Quotes | Homeowner quote intake records |
| 3 | Activities | Lead activity log |
| 4 | Calendar Events | Re-quote check-ins, scheduled events |
| 5 | Email Templates | Template storage for flows |
| 6 | Quote Documents | Documents linked to quotes |
| 7 | Audit Log | Change/event audit trail |
| 8 | Document Library | General file storage |

## Critical Issues

**🔴 Home Quotes is a structural duplicate of Leads** — identical 30-column schema. Round 1's #1 recommendation: merge by adding a `CoverageType` column to Leads and retiring Home Quotes. Decision still open.

**🔴 3 confirmed duplicate column pairs in Home Quotes:**
- QuoteID × 2 (Calculated + plain text — same display name, different types)
- Spouse's Phone × 2 (Number + Single line of text — Number is wrong for phone data)
- Risk Address × 2 (Location + Single line of text — Microsoft Forms CANNOT write to Location columns)

**Rule: Always use the text versions for flows and forms:**
- `Risk Address` → row 26 (Single line of text), NOT row 14 (Location)
- `Spouse's Phone` → row 25 (Single line of text), NOT row 11 (Number)

**🔴 Only "Name" is required** — all other columns accept blank. Incomplete records enter the pipeline silently.

## Space-Encoded Internal Names (Required for ODATA Filters)

| Display Name | Internal Name (ODATA) |
|---|---|
| Phone Number | `Phone_x0020_Number` |
| Risk Address | `Risk_x0020_Address` |
| Source Detail | `Source_x0020_Detail` |
| Spouse's Phone | `Spouse_x0027_s_x0020_Phone` |

Always use internal names in ODATA filter queries. Dynamic content picker shows display names; filter expressions require internal names.

## Cleanup Priority

🔴 Before flows: confirm Agent column is Person/Group type (not plain text). If plain text, flow cannot extract agent email from trigger.

🟡 Before launch: migrate Spouse's Phone Number data → text column, delete Number column. Standardize Risk Address on text version. Make Phone Number, Source, Agent, Status required.

---

---

# PART 9 — PHOTO AUDIT: LISTS, SCHEMA & FORMS

*Source: 5 images from `.project-cache`. Read-only audit.*

## Confirmed SP List Names

All 8 lists confirmed in site left-nav photo (`c6e19370.JPG`): Leads, Quote Documents, Home Quotes, Audit Log, Document Library, Activities, Email Templates, Calendar Events.

## Home Quotes Full Column Schema

*Source: `7ade5d14.JPG` + `edb34678.JPG`*

| # | Display Name | Type | Required | Notes |
|---|-------------|------|----------|-------|
| 1 | QuoteID | Calculated | No | ⚠️ DUPLICATE — see row 23 |
| 2 | Date | Date and Time | No | |
| 3 | Source | Choice | No | |
| 4 | Source Detail | Choice | No | |
| 5 | Referral | Single line of text | No | |
| 6 | Name | Single line of text | **✓ YES** | Only required field |
| 7 | DOB | Date and Time | No | |
| 8 | ID Spouse | Number | No | Purpose unclear |
| 9 | Spouse's Name | Single line of text | No | |
| 10 | Spouse's DOB | Date and Time | No | |
| 11 | Spouse's Phone | **Number** | No | ⚠️ DUPLICATE — wrong type for phone |
| 12 | GW ACCT | Number | No | Purpose undocumented |
| 13 | Email | Single line of text | No | |
| 14 | Risk Address | **Location** | No | ⚠️ DUPLICATE — Forms cannot write here |
| 15 | Occupancy | Choice | No | |
| 16 | Products | Choice | No | |
| 17 | Status | Choice | No | |
| 18 | Current Carriers | Single line of text | No | |
| 19 | Current Premiums | Single line of text | No | |
| 20 | Notes | Multiple lines of text | No | |
| 21 | ID PH | Number | No | Purpose undocumented |
| 22 | Link | Hyperlink or Picture | No | |
| 23 | QuoteID | **Single line of text** | No | ⚠️ DUPLICATE of row 1 |
| 24 | Phone Number | Single line of text | No | |
| 25 | Spouse's Phone | **Single line of text** | No | ⚠️ DUPLICATE of row 11 — **use this one** |
| 26 | Risk Address | **Single line of text** | No | ⚠️ DUPLICATE of row 14 — **use this one** |
| 27 | Agent | Person or Group | No | |
| 28–31 | Modified, Created, Created By, Modified By | System | — | Auto-managed |

## Three Entry Points to Home Quotes

All three write independently with no coordination or deduplication:

```
HOME QUOTES SP LIST
         ▲              ▲                    ▲
         │              │                    │
┌────────┴──────┐ ┌─────┴──────────┐ ┌──────┴──────────────┐
│ Power Apps    │ │ Microsoft Forms│ │ Microsoft Forms      │
│ Canvas Form   │ │ Version 1      │ │ Version 2 (fixed)   │
│ ("Full Home   │ │ (Homeowner_1)  │ │ (Homeowner_fixed_1) │
│  Quote" tab)  │ │ → Power Auto-  │ │ → Power Automate    │
│ Direct Patch()│ │   mate flow    │ │   flow              │
│ ✅ Confirmed  │ │ ⚠️ May still   │ │ ⚠️ May still        │
│ wired         │ │ be live        │ │ be live             │
└───────────────┘ └────────────────┘ └──────────────────────┘
```

**Action needed:** Confirm whether Forms v1 is still published. If so, take it offline — v2 is the current version. Two live forms writing to the same list with different field mappings will create mismatched records.

## Status Vocabulary Mismatch

The active ADAMSCOSBY_CLEAN build uses: **Active, Working, Quoted, Bound, Lost**
The reference AA Agency CRM build uses: **New, Contacted, Quote Sent, Follow-Up, Negotiating, Bound, Lost**

**Must resolve before Flow 3b is built.** Flow 3b's trigger fires on exact string matches.

## Type Column Values Confirmed

From live test data in ADAMSCOSBY_CLEAN: `Home`, `Auto`, `Home + Auto` — confirmed as the coverage type field. Flow 3b re-quote logic should filter on this column, not on Source.

---

---

# PART 10 — SHAREPOINT COLUMN ADDITIONS

*These are the 4 new Leads columns required before Flow 3b can be built. Apply to both Leads and Home Quotes per MR-1.*

## New Columns — Leads List (and Home Quotes, same settings)

### LostReason

| Property | Value |
|----------|-------|
| Type | Choice |
| Required | No |
| Choices | Price · Competitor · No Response · Not Qualified · Timing · Other |

### RequoteMonthsOut

| Property | Value |
|----------|-------|
| Type | Number |
| Required | No |
| Min | 1 · Max | 24 · Decimal places | 0 |

If set, calculates `RequoteDate = LostDate + (RequoteMonthsOut × 30 days)`. Ignored if RequoteDate is explicitly set. Typical values: 5 (auto), 11 (home).

### RequoteDate

| Property | Value |
|----------|-------|
| Type | Date and Time |
| Format | Date Only |
| Required | No |

If set, this exact date is used for the Calendar Event — overrides RequoteMonthsOut. Logic priority: RequoteDate > RequoteMonthsOut > neither (no re-quote).

### LineOfBusiness *(corrected — 4 choices, not 5; P&C removed)*

| Property | Value |
|----------|-------|
| Type | Choice |
| Required | No |
| Choices | **Auto · Home · Life · Commercial** |

> ⚠️ Task 12 (earlier spec) listed 5 choices including P&C. **That is superseded.** Use these 4 choices only.

## Calendar Events Columns (Verify or Add)

| Column | Type | Notes |
|--------|------|-------|
| `EventType` | Choice | Add: Re-Quote Check-In, Follow-Up, Appointment, Other |
| `LeadRef` | Lookup → Leads.Title | Links calendar event back to lead |

## Add Procedure (Each Column)

1. `https://alfains.sharepoint.com/teams/1047889-ADAMSCOSBY/Lists/Leads`
2. Click **+ Add column** → select type
3. Enter Display Name exactly as shown (no spaces in these names)
4. For Choice: enter each choice on its own line
5. Required = No, Default = blank
6. Save → verify column appears
7. **Repeat all steps for Home Quotes** (MR-1)

## Verification REST Query

```
https://alfains.sharepoint.com/teams/1047889-ADAMSCOSBY/_api/web/lists/getbytitle('Leads')/fields?$filter=Title eq 'LostReason' or Title eq 'RequoteMonthsOut' or Title eq 'RequoteDate' or Title eq 'LineOfBusiness'&$select=Title,InternalName,TypeAsString
```

Expected: 4 field objects with TypeAsString = Choice, Number, DateTime, Choice.

For LineOfBusiness choices specifically:
```
https://alfains.sharepoint.com/teams/1047889-ADAMSCOSBY/_api/web/lists/getbytitle('Leads')/fields?$filter=Title eq 'LineOfBusiness'&$select=Title,InternalName,TypeAsString,Choices
```

Expected Choices array: `["Auto", "Home", "Life", "Commercial"]` — 4 items, no P&C.

## Post-Add Validation

- [ ] LostReason — 6 choices in dropdown
- [ ] RequoteMonthsOut — accepts whole numbers
- [ ] RequoteDate — Date Only format
- [ ] LineOfBusiness — 4 choices (Auto, Home, Life, Commercial)
- [ ] All 4 added to Home Quotes (MR-1)
- [ ] EventType and LeadRef on Calendar Events
- [ ] Date auto-fill formula still works on both lists after adds

---

---

# PART 11 — DUAL-PATH INTAKE ARCHITECTURE

## Overview

```
Adams Cosby CRM — Two entry points, both produce a Leads record

PATH A — Home Quote First (PRIMARY)
┌──────────────────┐    Power Automate Flow
│  Homeowner Quote │ ────────────────────► Leads
│  Form (full)     │                   ► Home Quotes
└──────────────────┘                   ► Activities
       ▲
  Microsoft Forms (internal-org)
  OR SharePoint List Form (agent-initiated)

PATH B — Lead First (ALTERNATIVE)
┌──────────────────┐    Power Apps Patch
│  + Add Lead      │ ────────────────────► Leads
│  (quick modal)   │                   ► Activities
└──────────────────┘
       ▲
  Canvas App modal (in-dashboard)
```

## Path A — Home Quote First

**Option A1 — Microsoft Forms (for agent-initiated intake):**
- Set to: "Only people in my organization can respond" (internal-org, confirmed decision)
- Shareable via URL in Outlook signature, Teams, or bookmarked by agents
- On submission: Power Automate flow `AdamsCosbyCRM_HomeQuoteFormSubmission` fires
- Flow creates Home Quotes record → Leads record → Activities entry → Flow 3a fires automatically

**Option A2 — SharePoint List Form (agent opens from dashboard `+ New Home Quote` button):**
- Agent-initiated direct entry
- Trigger: `AdamsCosbyCRM_HomeQuoteListItem_CreateLead` — When item is created on Home Quotes
- Step 1: Check if Linked Lead already exists (`QuoteID eq trigger ID`)
- Step 2: If yes → terminate. If no → create Leads item + Activity

## Path B — Lead First (Quick Add)

`+ Add Lead` button on dashboard opens Canvas modal with minimal fields (Name, Phone, Email, Source, Notes). On submit:

```
Patch(Leads, Defaults(Leads), {
  Title: txtName.Text,
  Phone_x0020_Number: txtPhone.Text,
  Email: txtEmail.Text,
  Source: ddlSource.Selected.Value,
  Notes: txtNotes.Text,
  Status: "Active",
  Agent: {
    '@odata.type': '#Microsoft.Azure.Connectors.SharePoint.SPListExpandedUser',
    Claims: "i:0#.f|membership|" & User().Email
  }
})
```

Flow 3a fires automatically on the new Leads item.

## Dashboard Buttons

| Button | Path | Creates |
|--------|------|---------|
| `+ New Lead` | Path B | Leads record only |
| `+ New Home Quote` | Path A (Option A2) | Home Quotes + auto-creates Leads |

## If Lists Are Merged (Recommended)

Path A creates 1 record in the merged Leads list with `CoverageType = "Home"`. Simpler flow (one SP write instead of two). Still the recommended path — decision pending.

## Open Decisions

| # | Question | Impact |
|---|----------|--------|
| A | Confirm SP columns for Year Built / Sq Ft / Construction Type / Roof Type / Roof Year | Phase 4 |
| B | Merge Leads + Home Quotes? | Simplifies Path A to 1 SP write |
| C | Default agent on Forms submission (currently = Alec) | Flow 3a routing |

---

---

# PART 12 — HOMEOWNER FORM FIELD INVENTORY

*~55 total fields across 10 sections. Built from SP schema photo audit + screenshot evidence + confirmed branching rules. Fields marked `[VERIFY]` require comparison against physical paper form.*

## Field Count Summary

| Section | Fields | Conditional | Total |
|---------|--------|------------|-------|
| 1. Administrative | 5 | 0 | 5 |
| 2. Primary Applicant | 6 | 0 | 6 |
| 3. Spouse / Co-Applicant | 5 | 0 | 5 |
| 4. Property Information | 10 | 0 | 10 |
| 5. Coverage & Policy | 5 | 0 | 5 |
| 6. Risk — Structures | 6 | 5 | 11 |
| 7. Risk — Animals | 2 | 2 | 4 |
| 8. Risk — Claims | 1 | 3 | 4 |
| 9. Additional Info | 4 | 0 | 4 |
| 10. Agent Assignment | 1 | 0 | 1 |
| **TOTAL** | **45** | **10** | **~55** |

## Sections

**Section 1 — Administrative:** Quote Date (auto-fills today), Agent (Alec/Rachel only), Source, Source Detail, Referral Name.

**Section 2 — Primary Applicant:** Full Name (REQUIRED), DOB, Phone Number (text—not number), Email, GW Account # `[VERIFY]`, ID PH `[VERIFY]`.

**Section 3 — Spouse / Co-Applicant:** Spouse Name, Spouse DOB, Spouse Phone *(use text version row 25 — NOT number column row 11)*, ID Spouse `[VERIFY]`, Spouse included? `[VERIFY]`.

**Section 4 — Property Information:** Risk Address *(use text version row 26 — NOT Location column)*, City, State (pre-fill AL), ZIP, Occupancy Type, Year Built `[VERIFY SP column]`, Square Footage `[VERIFY SP column]`, Construction Type `[VERIFY SP column]`, Roof Type `[VERIFY SP column]`, Roof Year `[VERIFY SP column]`.

**Section 5 — Coverage & Policy:** Products Requested, Coverage Amount, Deductible Preference, Current Carrier, Current Premium.

**Section 6 — Risk Qualifiers (Structures):**
- Mobile Home? → YES → Inspection Decal #
- Pool on property? → YES → Slide?, Diving Board?, Fenced?
- Trampoline on property?
- Other structures?

**Section 7 — Risk Qualifiers (Animals):**
- Dogs on property? → YES → Dog breed(s)

**Section 8 — Risk Qualifiers (Claims):**
- Claims in last 5 years? → YES → Claim Date, Claim Description, Claim Amount

**Section 9 — Additional Information:** Notes, Quote Link/URL, Business conducted on premises? `[VERIFY]`, How did you hear about us? (may duplicate Section 1 Source).

**Section 10 — Agent Assignment:** Assign to Agent (Alec / Rachel only).

## Confirmed Branching Tree

```
Q: Mobile Home?
  └── YES → Inspection Decal #

Q: Pool on property?
  └── YES → Slide? (Y/N)
           → Diving Board? (Y/N)
           → Pool Fenced? (Y/N)

Q: Dogs on property?
  └── YES → Breed(s)

Q: Claims in last 5 years?
  └── YES → Claim Date
           → Claim Description
           → Claim Amount
```

## SP Columns With No Confirmed Form Field

QuoteID (Calculated), QuoteID (text duplicate), ID PH, ID Spouse, GW ACCT, Link, Status — all agent-managed post-intake, not form fields.

## Fields in Screenshots But Not in SP Schema

Year Built, Square Footage, Construction Type, Roof Type, Roof Year — visible in Quick Entry form screenshot but no dedicated SP column confirmed in photo audit. **Action:** Scroll to bottom of SP List Settings for Home Quotes and verify. If missing, add per MR-1 before building the form.

---

---

# PART 13 — MICROSOFT FORMS BUILD SPEC

*Full question-by-question spec for `AdamsCosbyCRM_HomeQuoteFormSubmission` (Path A, Option A1).*

## Pre-Build

- Form access: **"Only people in my organization can respond"**
- Title: `Adams Cosby — Homeowner Quote Request`
- Description: *"Please complete all fields as thoroughly as possible. An Adams Cosby agent will contact you within one business day."*
- Confirmation message: *"Thank you — your homeowner quote request has been received. An Adams Cosby agent will be in touch within one business day."*
- Progress bar: ON · Shuffle: OFF

## Questions

**SECTION: Applicant Information**

| Q | Label | Type | Required | SP Column | Notes |
|---|-------|------|----------|-----------|-------|
| 1 | Full Name | Text (short) | **Yes** | `Name` | |
| 2 | Date of Birth | Date | No | `DOB` | |
| 3 | Phone Number | Text (short) | No | `Phone Number` (text) | NOT Number type |
| 4 | Email Address | Text (short) | No | `Email` | |
| 5 | GW Account # (if known) | Text (short) | No | `GW ACCT` | `[VERIFY]` — include only if on paper form at intake |

**SECTION: Spouse / Co-Applicant**

| Q | Label | Type | Required | SP Column |
|---|-------|------|----------|-----------|
| 6 | Spouse Full Name | Text (short) | No | `Spouse's Name` |
| 7 | Spouse Date of Birth | Date | No | `Spouse's DOB` |
| 8 | Spouse Phone Number | Text (short) | No | `Spouse's Phone` (row 25 text — NOT row 11 Number) |

**SECTION: Property Information**

| Q | Label | Type | Required | SP Column | Notes |
|---|-------|------|----------|-----------|-------|
| 9 | Property Street Address | Text (short) | **Yes** | `Risk Address` (row 26 text — NOT Location) | |
| 10 | City | Text (short) | No | `[VERIFY]` | Pre-fill: Foley |
| 11 | State | Text (short) | No | `[VERIFY]` | Pre-fill: AL |
| 12 | ZIP Code | Text (short) | No | `[VERIFY]` | |
| 13 | Occupancy Type | Choice (dropdown) | No | `Occupancy` | Choices: Primary Residence · Secondary/Vacation · Rental/Investment · Other |
| 14 | Year Built | Text (short) | No | `[VERIFY]` | |
| 15 | Square Footage | Text (short) | No | `[VERIFY]` | |
| 16 | Construction Type | Choice (dropdown) | No | `[VERIFY]` | Choices: Brick · Brick Veneer · Frame · Vinyl Siding · Other |
| 17 | Roof Type | Choice (dropdown) | No | `[VERIFY]` | Choices: Architectural Shingle · 3-Tab Shingle · Metal · Tile · Other |
| 18 | Roof Year | Text (short) | No | `[VERIFY]` | |

**SECTION: Coverage Details**

| Q | Label | Type | SP Column |
|---|-------|------|-----------|
| 19 | Current Insurance Carrier | Text (short) | `Current Carriers` |
| 20 | Current Annual Premium | Text (short) | `Current Premiums` |
| 21 | Coverage Amount Requested | Text (short) | `[VERIFY]` |
| 22 | Deductible Preference | Choice (dropdown) | `[VERIFY]` | Choices: $500 · $1,000 · $2,500 · $5,000 · No Preference |
| 23 | Additional Products of Interest | Choice (multi-select) | `Products` | Choices: Homeowner · Auto · Life · Renter · Commercial |

**SECTION: Property Risk Information**

| Q | Label | Type | Branching | SP Column |
|---|-------|------|-----------|-----------|
| 24 | Is this property a mobile home? | Choice (Yes/No) | YES → Q25; NO → Q26 | `[VERIFY]` |
| 25 | Mobile Home Inspection Decal Number *(conditional)* | Text (short) | → Q26 | `[VERIFY]` |
| 26 | Is there a swimming pool? | Choice (Yes/No) | YES → Q27; NO → Q30 | `[VERIFY]` |
| 27 | Does the pool have a slide? *(conditional)* | Choice (Yes/No) | → Q28 | `[VERIFY]` |
| 28 | Does the pool have a diving board? *(conditional)* | Choice (Yes/No) | → Q29 | `[VERIFY]` |
| 29 | Is the pool enclosed by a fence? *(conditional)* | Choice (Yes/No) | → Q30 | `[VERIFY]` |
| 30 | Is there a trampoline on the property? | Choice (Yes/No) | None | `[VERIFY]` |
| 31 | Are there any other structures? | Choice (Yes/No) | `[VERIFY]` | `[VERIFY]` |
| 32 | Are there dogs on the property? | Choice (Yes/No) | YES → Q33; NO → Q34 | `[VERIFY]` |
| 33 | Please list all dog breed(s) *(conditional)* | Text (long) | → Q34 | `[VERIFY]` |

**SECTION: Claims History**

| Q | Label | Type | Branching | SP Column |
|---|-------|------|-----------|-----------|
| 34 | Claims in the last 5 years? | Choice (Yes/No) | YES → Q35; NO → Q38 | `[VERIFY]` |
| 35 | Date of most recent claim *(conditional)* | Date | → Q36 | `[VERIFY]` |
| 36 | Brief description of claim(s) *(conditional)* | Text (long) | → Q37 | `[VERIFY]` |
| 37 | Approximate claim payout amount *(conditional)* | Text (short) | → Q38 | `[VERIFY]` |

**SECTION: Additional Information**

| Q | Label | Type | SP Column |
|---|-------|------|-----------|
| 38 | Business conducted on this property? | Choice (Yes/No) | `[VERIFY]` |
| 39 | How did you hear about Adams Cosby? | Choice (dropdown) | `Source` | Choices: Referral · Website · Social Media · Walk-In/Drive-By · Mailer/Postcard · Existing Customer · Other |
| 39a | Referral Name (if referred) | Text (short) | `Referral` | Branch from Q39 "Referral" if possible |
| 40 | Additional Notes | Text (long) | `Notes` | |

## Branching Summary Table

| Trigger | Answer | Go To |
|---------|--------|-------|
| Q24 — Mobile Home? | Yes | Q25 |
| Q24 — Mobile Home? | No | Q26 |
| Q25 — Decal | any | Q26 |
| Q26 — Pool? | Yes | Q27 |
| Q26 — Pool? | No | Q30 |
| Q27–Q29 | any | next conditional |
| Q29 — Fenced | any | Q30 |
| Q32 — Dogs? | Yes | Q33 |
| Q32 — Dogs? | No | Q34 |
| Q33 — Breeds | any | Q34 |
| Q34 — Claims? | Yes | Q35 |
| Q34 — Claims? | No | Q38 |
| Q35–Q37 | any | next conditional |
| Q37 — Amount | any | Q38 |

## Fields NOT in This Form (Agent-Managed Only)

QuoteID (Calculated — auto), Date (auto via flow `utcNow()`), Status (default Active), Agent (default Alec, reassignable in app), ID PH, ID Spouse, Link.

## Alec's Verification Checklist

- [ ] Compare this question list against physical paper form — add or remove fields as needed
- [ ] Confirm `[VERIFY]` SP columns exist (Year Built, Sq Ft, Construction Type, Roof Type, Roof Year)
- [ ] Confirm GW ACCT is captured at intake, or remove Q5
- [ ] Confirm exact SP Choice column values for Occupancy, Products, Construction Type, Roof Type
- [ ] After building form: note response field names (r1, r2, etc.) for the flow mapping step

---

---

# PART 14 — AGENT CLAIMS-SYNTAX FIXES

## The Problem

SP Person/Group columns cannot be written from Power Automate using a plain email string. This fails silently or throws a runtime error:

```
❌ FAILS:   Agent: "abadams@alfains.com"

✅ WORKS:   Agent: {
              "@odata.type": "#Microsoft.Azure.Connectors.SharePoint.SPListExpandedUser",
              "Claims": "i:0#.f|membership|abadams@alfains.com"
            }
```

## Claims Syntax Reference

**Static (known email):**
```json
{
  "@odata.type": "#Microsoft.Azure.Connectors.SharePoint.SPListExpandedUser",
  "Claims": "i:0#.f|membership|abadams@alfains.com"
}
```

**Dynamic (from trigger/variable):**
```json
{
  "@odata.type": "#Microsoft.Azure.Connectors.SharePoint.SPListExpandedUser",
  "Claims": "i:0#.f|membership|@{variables('AgentEmail')}"
}
```

**In Power Automate expression editor:**
```
concat('i:0#.f|membership|', variables('AgentEmail'))
```

**How to enter in PA UI:** In Create/Update SP item action → click Agent field → "Enter custom value" → "Switch to input entire array" → paste the JSON object.

## Retrieving Agent Email from a Person/Group Column

| Context | Path |
|---------|------|
| Trigger output | `triggerOutputs()?['body/Agent/Email']` |
| Get item action | `outputs('Get_item')?['body/Agent/Email']` |
| Loop (Apply to each) | `items('Apply_to_each')?['Agent/Email']` |

Do NOT use `body/Agent` (returns full object) or `body/Agent/DisplayName` (returns name, not email).

## All Affected Instances

| Flow | Step | Column | Claims Expression |
|------|------|--------|------------------|
| HomeQuoteFormSubmission | Step 3 — Create Leads | Agent | Static: `i:0#.f|membership|abadams@alfains.com` |
| HomeQuoteFormSubmission | Step 4 — Create Activity | Agent | Static: `i:0#.f|membership|abadams@alfains.com` |
| HomeQuoteListItem_CreateLead | Step 3 — Create Leads | Agent | Static: `i:0#.f|membership|abadams@alfains.com` |
| HomeQuoteListItem_CreateLead | Step 4 — Create Activity | Agent | Static: `i:0#.f|membership|abadams@alfains.com` |
| Flow 3a — NewLead | Step 6 — Create Activity | Agent | Dynamic: `triggerOutputs()?['body/Agent/Email']` |
| Flow 3b — StatusChanged | Step 3b — Create Activity (Bound) | Agent | Dynamic: `triggerOutputs()?['body/Agent/Email']` |
| Flow 3b — StatusChanged | Step 5a — Create Calendar Event | Agent | Dynamic: `triggerOutputs()?['body/Agent/Email']` |
| Flow 3b — StatusChanged | Step 6 — Create Activity (Lost) | Agent | Dynamic: `triggerOutputs()?['body/Agent/Email']` |
| Flow 3d — FollowUpReminder | Activity create (if present) | Agent | Loop: `items('Apply_to_each')?['Agent/Email']` |
| Flow 3c — DailyDigest | None — read-only | — | No fix needed |

> ⚠️ Flow 3b must NEVER write back to the Leads list — infinite loop risk. If any step in Flow 3b shows a SP write to Leads, remove it.

## Pre-Build Verification

1. Run this REST query to confirm `Agent` is a Person/Group column (TypeAsString = "User"):
```
https://alfains.sharepoint.com/teams/1047889-ADAMSCOSBY/_api/web/lists/getbytitle('Leads')/fields?$filter=Title eq 'Agent'&$select=Title,InternalName,TypeAsString
```

2. Run same query for Activities and Calendar Events lists.

3. Confirm Send As permission before testing any flow.

---

---

# PART 15 — CUSTOMIZATIONS.XML EXPLAINED

## TL;DR

A near-empty Dataverse solution package. The only meaningful content is one custom global picklist: `ac_lineofbusiness` with three values. Zero automation, zero workflows, zero entity schema.

## The One Artifact

| Property | Value |
|----------|-------|
| Schema Name | `ac_lineofbusiness` |
| Display Name | LineOfBusiness |
| Values | P&C (120820000) · Alfa Agency (120820001) · Life (120820002) |
| Publisher prefix | `ac` |
| Active in alfains tenant? | Unknown — likely dormant |

This option set only exists in Dataverse, not SharePoint. The SharePoint LineOfBusiness Choice column (Part 10) is a completely separate, independent column. The two are not linked. Do not attempt to sync them.

## Architecture Context

These Dataverse files suggest this project started with a Dataverse/Dynamics 365 plan and pivoted to SharePoint. The artifacts were never removed. They're harmless and should stay as-is. If Adams Cosby ever migrates to full Dataverse, the `ac_lineofbusiness` option set will import cleanly — but everything else (SP lists, Canvas app, all flows) would need to be rebuilt from scratch.

## What Each File Contains

- **Solution.xml** — Metadata wrapper registering the option set. Publisher: dynamics365agency, prefix: ac.
- **Customizations.xml** — The `ac_lineofbusiness` option set definition. Everything else is empty boilerplate.
- **Relationships.xml** — A two-line self-closing empty tag. Contains nothing.

---

---

*Adams Cosby CRM — Complete Build Reference · All Rounds Combined*
*Compiled: 2026-05-04 · Source files: `COWORK_OUTPUTS\` and `COWORK_OUTPUTS\round2\`*
*No existing project files were modified. This document is additive only.*
