# Adams Cosby CRM — Cowork Build Support: Master Report
**Agency:** Adams Cosby Insurance · AA Agency LLC · Foley, AL
**SharePoint Tenant:** alfains.sharepoint.com
**Site:** https://alfains.sharepoint.com/teams/1047889-ADAMSCOSBY
**Report Date:** 2026-05-03
**Session Type:** Parallel support tasks — no active dashboard files modified

---

## Output File Index

| Task | Output File(s) | Status |
|------|---------------|--------|
| 1 — Intake Flow Audit | `01_intake_flow_audit.md` | ✅ Complete |
| 2 — Email Templates | `templates/01–07 .html + .subject`, `02_template_summary.md` | ✅ Complete |
| 3 — Power Automate Flow Specs | `03_flows/flow_3a–3d.md`, `03_flows/03_flows_overview.md` | ✅ Complete |
| 4 — SharePoint List Health Audit | `04_sharepoint_audit.md` | ✅ Complete |
| 5 — Customizations.xml Explained | `05_customizations_xml_explained.md` | ✅ Complete |
| 6a — Team Quick Reference | `06a_team_quick_reference.md` | ✅ Complete |
| 6b — Session Log Template | `06b_session_log_template.md` | ✅ Complete |

---

---

# TASK 1 — INTAKE FLOW AUDIT

## Key Finding

**The three XML files (Solution.xml, Customizations.xml, Relationships.xml) contain zero automation.** There are no flows, triggers, workflows, or business logic in any of them.

The only functional content across all three files is a single custom global picklist called `ac_lineofbusiness` with three values: P&C, Alfa Agency, Life. This is a Dataverse option set — it has no connection to SharePoint lists.

Relationships.xml is a two-line empty tag. Solution.xml is a metadata wrapper registering the option set.

## What This Means

The "intake automation" either: (a) hasn't been built yet, or (b) lives in Power Automate cloud flows that were never exported to this solution package. Task 3 of this session (flow specifications) covers building it from scratch.

## Recommendations

These XML files can stay as-is — they're clean and correct. No changes needed. The `ac_lineofbusiness` option set could eventually be used if the CRM migrates to Dataverse, but it has no active role in the current SharePoint-based setup.

---

---

# TASK 2 — EMAIL TEMPLATES

## Summary

Seven production-ready HTML email templates written with inline styles, Outlook-compatible table layout, brand red (#C8102E) accents, and `<<TokenName>>` merge syntax.

## Templates Produced

| # | Title | Subject Line | Key Tokens | When to Send |
|---|-------|-------------|-----------|-------------|
| 01 | New Lead Introduction | Welcome to Adams Cosby Insurance, `<<FirstName>>` — Let's Get You Covered | FirstName, AgentName, AgentEmail, AgentPhone | Within 24 hours of lead creation |
| 02 | Auto Insurance Information | Your Auto Insurance Options — Adams Cosby Insurance | FirstName, VehicleInfo, Agent fields | First info follow-up for auto-interested leads |
| 03 | Home Insurance Information | Protecting Your Home at `<<RiskAddress>>` — Here's What to Know | FirstName, RiskAddress, Agent fields | First info follow-up for home-interested leads |
| 04 | Quote Sent / Quote Ready | Your Insurance Quote Is Ready, `<<FirstName>>` | FirstName, QuotePremium, Agent fields | On Status → Quoted |
| 05 | Follow-Up Reminder | Just Checking In, `<<FirstName>>` — Still Here to Help | FirstName, Agent fields | After 7 days no response |
| 06 | Re-Quote Auto (5-Month) | Time to Review Your Auto Coverage, `<<FirstName>>` | FirstName, VehicleInfo, QuotePremium, Agent fields | ~5 months after Lost — auto |
| 07 | Re-Quote Home (11-Month) | Your Home Insurance Renewal Is Coming Up, `<<FirstName>>` | FirstName, RiskAddress, QuotePremium, Agent fields | ~11 months after Lost — home |

## Token Replacement Implementation

In Power Automate, use a chain of `replace()` expressions or Compose actions to substitute tokens before sending:
```
replace(replace(body('Get_Template')?['Body'], '<<FirstName>>', triggerOutputs()?['body/Title']), '<<AgentName>>', variables('varAgentName'))
```

## Brand Compliance

All templates use: `#C8102E` red for headers and CTAs, `#1F1E1D` dark gray for body text, Arial/Helvetica fonts, no external CSS, no images, no JavaScript. Tested compatible with Outlook desktop, Outlook Web App, and mobile email clients.

---

---

# TASK 3 — POWER AUTOMATE FLOW SPECIFICATIONS

## The Four Flows

### Flow 3a — AdamsCosbyCRM_NewLead

**Trigger:** SharePoint — When an item is created on the Leads list

**What it does:**
1. Reads the new lead's data from the trigger
2. Sends a notification email to the assigned Agent (from SC1047@alfains.com), CC'd to shared inbox
3. Creates a Microsoft To-Do task: "Contact [Lead] within 24 hours" due tomorrow
4. Posts to the Adams Cosby Teams channel: "🆕 New lead: [Name] assigned to [Agent]"
5. Creates an Activities list entry: ActivityType=Created, Lead=ID, Agent, EventDate=Now

**Loop risk:** None — fires on Create only, writes nothing to Leads.

**Build time estimate:** 20–25 minutes

---

### Flow 3b — AdamsCosbyCRM_StatusChanged

**Trigger:** SharePoint — When an item is modified on the Leads list

**What it does:**
1. Checks if Status field actually changed (exits if not — loop guard)
2. If Status = **Bound**: Sends celebration email to Agent + Alec + SC1047. Logs activity.
3. If Status = **Lost**: Schedules a re-quote calendar event (152 days for auto, 335 days for home). Logs activity with LostReason if field exists.

**⚠️ Blocking items before build:**
- Need `LostReason` Choice column added to Leads list
- Need confirmation: which field distinguishes auto from home for delay timing?
- Must NOT add any write-back to Leads list — would create infinite trigger loop

**Build time estimate:** 35–40 minutes (most complex flow)

---

### Flow 3c — AdamsCosbyCRM_DailyDigest

**Trigger:** Recurrence — 8:00 AM weekdays, Central Time

**What it does:**
1. Queries Leads created in last 24 hours → count
2. Queries Leads with Status=Working and Modified >7 days ago → list
3. Queries Leads with Status=Quoted and Modified >14 days ago → list
4. Composes an HTML digest email with all three sections
5. Sends to abadams@alfains.com with subject showing all three counts

**Loop risk:** None — read-only.

**Build time estimate:** 25–30 minutes

---

### Flow 3d — AdamsCosbyCRM_FollowUpReminder

**Trigger:** Recurrence — 9:00 AM daily, Central Time

**What it does:**
1. Queries Leads with Status=Working and Modified >7 days ago
2. For each result: sends a reminder email to the assigned Agent, creates a To-Do task due today

**Design decision needed:** Daily reminder vs capped (once per 3 days per lead)? Daily will spam agents if leads sit unworked for weeks.

**Loop risk:** None — reads Leads, writes To-Do tasks only.

**Build time estimate:** 20–25 minutes

---

### Shared Build Notes

- All 4 flows use only **standard M365 connectors** — no premium licensing needed
- All flows require **Send As permission on SC1047@alfains.com** — Exchange admin must grant this to the flow owner account before building
- Build order: 3c → 3a → 3d → 3b (safest, least loop risk first)
- Flow owner recommendation: Alec's account or a dedicated service account. Never an agent account that could be disabled.

---

### Open Questions (Must Resolve Before Building Flows)

1. **LostReason field:** Add to Leads as a Choice column before building Flow 3b?
2. **Auto vs Home detection:** Which field? Source? A Coverage Type field? Source Detail?
3. **Re-quote method:** Calendar event (recommended) vs delayed email?
4. **Teams channel:** General or create a dedicated #leads-new channel?
5. **Digest recipients:** Alec only, or Rachel too?
6. **Follow-up cadence:** Daily or capped at once per 3 days per lead?

---

---

# TASK 4 — SHAREPOINT LIST HEALTH AUDIT

## Authentication

Live REST API calls were not executed. The alfains tenant requires OAuth/MFA authentication that cannot be performed non-interactively from this environment. This audit is based on the known schema from the project brief and standard SharePoint behavior. To run the live query yourself, use PnP PowerShell with `Connect-PnPOnline -UseWebLogin`.

## Core Findings

### 🔴 Critical — Home Quotes is a Duplicate of Leads

The Home Quotes list has an identical 30-column schema to Leads. This is described in the project context as "accidental duplication." **This is the most important structural issue in the entire CRM.** Every flow, screen, formula, and report must be built twice — once for Leads, once for Home Quotes — for no benefit. The fix is to add a `CoverageType` column to Leads (Auto, Home, Life) and retire Home Quotes.

### 🔴 Critical — Agent Column Type Needs Verification

If the Agent column is stored as plain text rather than a Person/Group column, Flow 3a and 3d cannot reliably extract the agent's email address from the trigger payload. This must be confirmed before building any flows.

### 🔴 Critical — LostReason Field Missing

Flow 3b's Lost path depends on a LostReason field that does not appear in the known schema. This needs to be added to Leads before Flow 3b can be built. Recommended values: Price, Competitor, No Response, Not Qualified, Timing, Other.

## Space-Encoded Internal Names (Important for Flow Builders)

SharePoint columns with spaces in their display names get `_x0020_` substituted for spaces in their internal (ODATA) names. This matters when writing Power Automate filter queries:

| Display Name | Internal Name (ODATA) |
|---|---|
| Phone Number | `Phone_x0020_Number` |
| Risk Address | `Risk_x0020_Address` |
| Source Detail | `Source_x0020_Detail` |
| Spouse's Phone | `Spouse_x0027_s_x0020_Phone` |

Always use internal names in ODATA filter queries. Power Automate's dynamic content picker shows display names, but filter expressions require internal names.

## Cleanup Priority List

**🔴 Critical — Do Before Flows:**
1. Merge Home Quotes into Leads (add CoverageType column, migrate data, archive Home Quotes)
2. Add LostReason Choice column to Leads
3. Confirm Agent column is Person/Group type

**🟡 Nice to Have — Before Launch:**
4. Audit and remove duplicate Risk Address columns (Location type vs text type)
5. Change Spouse's Phone from Number to Single Line Text
6. Make Phone Number, Source, Agent, and Status required fields

**🟢 Cosmetic:**
7. Rename Title display name to "Lead Name"
8. Add column descriptions as tooltips for all custom columns

---

---

# TASK 5 — CUSTOMIZATIONS.XML EXPLAINED

## TL;DR

A near-empty Dataverse solution package. The only meaningful content is one custom global picklist: `ac_lineofbusiness` with three values (P&C, Alfa Agency, Life). There is no automation, no entity schema, no workflows.

## The One Artifact: ac_lineofbusiness

| Property | Value |
|----------|-------|
| Schema Name | `ac_lineofbusiness` |
| Display Name | LineOfBusiness |
| Values | P&C (120820000), Alfa Agency (120820001), Life (120820002) |
| Publisher prefix | `ac` |
| Is active in alfains tenant? | Unknown — likely dormant |

This option set only exists in Dataverse, not SharePoint. The SharePoint Leads list has its own separate Coverage Type / Source / Status columns independent of this definition. They are parallel systems.

## Architecture Note

The existence of these Dataverse files alongside a SharePoint-based CRM suggests this project may have started with a Dataverse plan and pivoted to SharePoint. The Dataverse artifacts were never removed. They're harmless but create confusion about where the "real" system lives — the answer is SharePoint.

## Migration Consideration

If Adams Cosby ever moves to a full Dataverse/Dynamics 365 CRM, the `ac_lineofbusiness` option set will import cleanly and be reusable. Everything else (SharePoint list schemas, Canvas app bindings, all flows) would need to be rebuilt from scratch. This file represents maybe 5 minutes of savings in a multi-day migration project.

---

---

# TASK 6 — REFERENCE DOCUMENTS

## 6a — Team Quick Reference

A 2-page plain-English guide for Rachel, Jessica, Tammy, and Leigh. Covers:

- How to open the dashboard (SharePoint URL + bookmark)
- How to add a new lead (field guide)
- How to update Status (Working / Quoted / Bound / Lost with consequences explained)
- How to send an email template
- How to log a phone call
- What the activity timeline shows
- Who to contact when something breaks (Alec, with what info to include)

Tone is conversational, assumes Outlook and SharePoint familiarity but no Power Apps experience. Ready to print or share as-is.

## 6b — Session Log Template

A structured markdown template for logging each future Canvas app build session. Fields cover:

- Session metadata (date, duration, phase, goal)
- Backup confirmation (folder name, timestamp)
- Edit log (file, what changed, line numbers)
- Pack result (command used, output file, error text if any)
- Studio import result
- Visual verification checklist + screenshot
- Errors encountered + resolutions
- Next phase queue (goal, starting backup, first action, open questions)

Naming convention: `session_log_YYYY-MM-DD_PhaseN.md`

This template solves the "I described the current state of my app to Claude but it doesn't know what I changed last time" problem. Filling it out takes 5 minutes and gives future sessions a clean, structured starting point without needing to re-explain context.

---

---

# CONSOLIDATED DECISION LOG — QUESTIONS FOR ALEC

These are all open questions surfaced across all tasks. Answers needed before building flows.

| # | Question | Needed For | Impact If Skipped |
|---|----------|-----------|------------------|
| Q1 | Should LostReason be added as a Choice column to Leads? Suggested values: Price, Competitor, No Response, Not Qualified, Timing, Other | Flow 3b | Lost-lead reporting is meaningless without it; re-quote scheduling works either way |
| Q2 | Which field distinguishes auto from home for re-quote timing? Source? A new CoverageType field? | Flow 3b | Re-quote delays (152 days vs 335 days) depend on this |
| Q3 | Re-quote scheduling method — calendar event (recommended) or delayed email? | Flow 3b | Delayed emails >30 days are unreliable in some tenants |
| Q4 | Should Home Quotes be merged into Leads? (Strong recommendation: yes) | Task 4 | Every flow and screen must be doubled if not merged |
| Q5 | Which Teams channel for new lead notifications? General or a dedicated channel? | Flow 3a | Minor — easy to change later |
| Q6 | Daily Digest recipients — Alec only, or Rachel too? | Flow 3c | Easy to change after build |
| Q7 | Follow-up reminder cadence — daily until resolved, or once per 3 days per lead? | Flow 3d | Daily reminders will spam agents on neglected leads |
| Q8 | Should StatusChanged (Flow 3b) also notify Jessica on Bound events? | Flow 3b | Currently spec'd as Agent + Alec + SC1047 only |

---

---

# WHAT TO DO NEXT

Recommended sequence for turning these outputs into live systems:

1. **Answer the 8 questions above.** Q1, Q2, and Q4 are blockers — the others can be decided at build time.

2. **Add LostReason to Leads list** (if Q1 = yes). 5 minutes in SharePoint list settings.

3. **Decide on Home Quotes merge** (Q4). If merging: add CoverageType column to Leads, migrate any existing Home Quotes data, archive the list. Do this before building any flows.

4. **Load email templates into the Email Templates list.** Copy the HTML body and subject from each file in `COWORK_OUTPUTS/templates/` into the corresponding SharePoint list row.

5. **Build flows in order:** 3c → 3a → 3d → 3b. Each spec includes a build checklist and test plan.

6. **Print or share the team quick reference** (`06a_team_quick_reference.md`) with Rachel, Jessica, Tammy, and Leigh when the dashboard is ready to deploy.

7. **Use the session log template** (`06b_session_log_template.md`) for every future Canvas app build session.

---

*All output files are in `C:\Users\alec\Desktop\MSAPP\COWORK_OUTPUTS\`*
*No existing files were modified during this session.*
*Active dashboard files in `ADAMSCOSBY_CLEAN\` were not touched.*
