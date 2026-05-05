# Adams Cosby CRM — Decisions Locked Master Summary
**Agency:** Adams Cosby Insurance · AA Agency LLC · Foley, AL
**Canonical reference for all resolved decisions, meta-rules, build order, and version table**
*Documented: 2026-05-04 · Supersedes all prior decision notes in Round 1 and Round 2 files*

---

## How to Use This Document

This is the single source of truth for every decision made during Rounds 1 and 2 of the Adams Cosby CRM build support sessions. When a spec file conflicts with this document, **this document wins.**

When building flows, canvas screens, or SP columns — if you have a question about what was decided, check here first before re-reading individual task files.

---

## Part 1 — Meta-Rules (Always Apply)

These rules govern every build decision across the entire project. They do not expire and cannot be overridden by individual task specs.

### MR-1 — List Parity (Leads ↔ Home Quotes)

> "Leads and Home Quotes are one schema in two physical lists. Every column add or change on one list must be applied to the other in the same session. No exceptions."

- When you add a column to Leads, you MUST add the same column to Home Quotes before closing the SP session.
- The reverse is also true — Home Quotes column adds must propagate to Leads.
- After every column add session, verify the date auto-fill formula still works on both lists.
- This rule applies to: column adds, column renames, column type changes, choice value changes.

### MR-2 — Round-Robin Assignment Is Out of Scope

> "Automatic round-robin lead assignment between Alec and Rachel is not part of this build. Agent assignment is always manual."

- No flow, canvas formula, or SP column should attempt to auto-rotate assignments between agents.
- Default agent on all automated intakes = Alec (`abadams@alfains.com`). Agent reassigns in the Canvas app if needed.

### MR-3 — Agent Roster Is Locked

> "The agent roster is final. No additions without explicit decision."

**Agents (assignable in Agent dropdown, notification recipients):**
- Alec Adams — `abadams@alfains.com`
- Rachel Cosby — `rcosby@alfains.com`

**Inputters (data entry only — never selectable as assigned agent):**
- Leigh Marsh
- Jessica Adams
- Tammy Dennis

**Removed:** Brooklyn — removed from all dropdowns, not included in any flow or notification.

### MR-4 — SharePoint Only, No Dataverse

> "Every SP list, every Power Automate flow, and every Canvas app data source must target the SharePoint lists at `alfains.sharepoint.com/teams/1047889-ADAMSCOSBY`. No Dataverse connections."

- The XML files (`Customizations.xml`, `Solution.xml`, `Relationships.xml`) are inert Dataverse artifacts. They contain no automation. Do not modify them. Do not create Dataverse connections in any flow or Canvas app.
- The `ac_lineofbusiness` option set in the XML is irrelevant to the SP `LineOfBusiness` Choice column.

### MR-5 — No Existing Files Modified

> "Cowork sessions are additive only. No existing files in `COWORK_OUTPUTS\`, `ADAMSCOSBY_CLEAN\`, or any other project folder may be edited, modified, or deleted. Only new files are created."

---

## Part 2 — All Resolved Decisions

### Round 1 Decisions

| # | Decision | Resolution |
|---|----------|-----------|
| R1-1 | What does the XML do? | Nothing. No automation in any XML file. `ac_lineofbusiness` option set is the only artifact. Confirmed inert. |
| R1-2 | How many email templates? | 7 templates (01–07). Template 08 added in Round 2. |
| R1-3 | From address for all emails | `SC1047@alfains.com` — Send As permission required on Alec's account |
| R1-4 | Reply-to address | `teamac@alfains.com` (alias for the shared mailbox) |
| R1-5 | Daily Digest time | 7:00 AM Central (Recurrence trigger in Flow 3c) |

---

### Round 2 Decisions

| # | Decision | Resolution |
|---|----------|-----------|
| Q1 | LostReason field | **Add as Choice column.** 6 values: Price, Competitor, No Response, Not Qualified, Timing, Other. See `15_task12_lineofbusiness_fix.md` for MR-1 parity. |
| Q2 | Re-quote timing | **Flexible — two fields:** `RequoteMonthsOut` (Number, agent enters 5 or 11 for typical auto/home cycles) and `RequoteDate` (Date, agent sets explicit date). RequoteDate takes priority. Neither = no re-quote scheduled. |
| Q3 | Re-quote delivery | **Calendar Events SP list item (PRIMARY, required).** This is what surfaces in the CRM Calendar screen. Outlook calendar event is secondary (optional). Email-only delivery was rejected. |
| Q4 | Flow owner | **Alec's account** (`abadams@alfains.com`). No service account. |
| Q5 | Teams channel | **REJECTED.** Teams post removed from Flow 3a. Replaced with branded HTML email to agent + CC to SC1047 inbox, matching the scan-to-shared-inbox intake format. |
| Q6 | Daily Digest recipients | **Both Alec AND Rachel** — `abadams@alfains.com; rcosby@alfains.com` in a single To: field. Not BCC. |
| Q7 | Follow-up cadence | **Deferred.** Default: once per 7 days. No change to Flow 3d this session. |
| Q8 | Intake architecture | **Dual-path.** Path A (Home Quote First, primary) and Path B (Lead First, quick-add alternative). Both surface as dashboard buttons. |

---

### Final Decisions Doc Items (Round 2, Session End)

| # | Item | Resolution |
|---|------|-----------|
| 1 | Microsoft Forms vs SP form | **Both delivery options supported.** Forms for prospect self-service (internal-org). SP List Form for agent-initiated entry. |
| 2 | Agent dropdown in Form | **Alec and Rachel only** — not inputters, not Brooklyn. |
| 3 | Forms access | **Internal-org only** (no anonymous/external). No M365 admin check needed. "Only people in my organization can respond" setting. |
| 4 | Microsoft Form field spec | **Built in `14_homeowner_microsoft_form_spec.md`.** ~41 total questions, 9 conditional. Branching matches paper form. Alec must verify `[VERIFY]` fields against physical form. |
| 5 | LineOfBusiness choices | **4 choices: Auto, Home, Life, Commercial.** P&C removed. See `15_task12_lineofbusiness_fix.md`. Task 12's 5-choice list is superseded. |
| 6 | Agent Claims syntax | **All SP Person/Group column writes require Claims object syntax.** Plain email strings fail at runtime. See `16_agent_claims_syntax_fixes.md` for all instances. |
| 7 | Build order | See Part 3 below. |

---

## Part 3 — Build Order (Final)

Follow this sequence. Earlier steps unblock later ones. Do not skip phases.

### Phase 0 — Decisions Only (Before Any Build)

1. Alec verifies `14_homeowner_microsoft_form_spec.md` against the physical paper homeowner form. Flags any missing or wrong fields.
2. Alec confirms the 5 unverified SP columns exist (Year Built, Square Footage, Construction Type, Roof Type, Roof Year) by scrolling to the bottom of SP List Settings for Home Quotes. If they don't exist, add them per MR-1 before building the Microsoft Form.
3. Alec confirms GW ACCT, ID PH, ID Spouse are or are not on the paper form at intake time.
4. Alec confirms which Status vocabulary the live Leads list uses (Active/Working/Quoted/Bound/Lost vs New/Contacted/Quote Sent/etc.) — this must match Flow 3b's trigger condition exactly.
5. Alec runs the Phone Number internal name REST query to confirm `Phone_x0020_Number` encoding before flow build.

### Phase 1 — SharePoint Schema

6. Add 4 new columns to Leads list per `15_task12_lineofbusiness_fix.md`: LostReason, RequoteMonthsOut, RequoteDate, LineOfBusiness (4 choices)
7. Add same 4 columns to Home Quotes list (MR-1)
8. Add EventType and LeadRef columns to Calendar Events list
9. Add any unconfirmed columns (Year Built, Sq Ft, Construction Type, Roof Type, Roof Year) to both lists if not present
10. Run verification REST query — confirm all columns exist with correct types

### Phase 2 — Email Templates

11. Load all 8 HTML templates into the Email Templates SP list (01–07 from Round 1 + 08 from Round 2 `templates/` folder)

### Phase 3 — Power Automate Flows (in order)

12. **Flow 3c** (Daily Digest FINAL — `10_flow_3c_DailyDigest_FINAL.md`) — read-only, build first, validates SP list access
13. **Flow 3a** (NewLead FINAL — `09_flow_3a_NewLead_FINAL.md`) — creates Activities items, verifies Send As
14. **Flow 3d** (FollowUpReminder — Round 1 `flow_3d_FollowUpReminder.md`) — validates overdue lead query
15. **Flow 3b** (StatusChanged FINAL — `08_flow_3b_StatusChanged_FINAL.md`) — most complex, highest loop risk, build last

> ⚠️ **Claims syntax:** Every flow that writes to a Person/Group column must use the Claims object format per `16_agent_claims_syntax_fixes.md`. Confirm before saving any flow.

> ⚠️ **Send As:** Confirm `SC1047@alfains.com` Send As permission is active on `abadams@alfains.com` in Exchange Admin Center before testing any flow in production.

> ⚠️ **Flow 3b trigger condition:** Must enter `@or(equals(triggerOutputs()?['body/Status'], 'Bound'), equals(triggerOutputs()?['body/Status'], 'Lost'))` in the trigger's Advanced → Trigger Conditions field before saving. This prevents quota consumption and infinite loops.

### Phase 4 — Path A Intake

16. Build Microsoft Forms homeowner quote form from `14_homeowner_microsoft_form_spec.md` (after Phase 0 paper form verification)
17. Build `AdamsCosbyCRM_HomeQuoteFormSubmission` flow (Forms → Home Quotes → Leads → Activities)
18. Apply Claims syntax per `16_agent_claims_syntax_fixes.md` Instances 1 and 2
19. Test end-to-end: submit form → verify Home Quotes + Leads + Activities records created → verify Flow 3a fires for agent notification

### Phase 5 — Dashboard Integration

20. Add `+ New Lead` button to Canvas app dashboard (Path B — opens quick-add modal, Patch to Leads)
21. Add `+ New Home Quote` button to Canvas app dashboard (Path A Option A2 — opens SP List Form for Home Quotes)
22. Add `LeadRef` drill-through from Calendar screen → source Lead record
23. Update `<<DashboardLeadURL>>` token in Template 08 once Canvas app has a stable deeplink URL

---

## Part 4 — Version Table (Which File to Use for Each Asset)

When building, always use the FINAL version. Do not mix Round 1 and Round 2 versions for the same flow.

| Asset | Use This Version | File Path |
|-------|----------------|-----------|
| Flow 3a — NewLead | **Round 2 FINAL** | `round2/09_flow_3a_NewLead_FINAL.md` |
| Flow 3b — StatusChanged | **Round 2 FINAL** | `round2/08_flow_3b_StatusChanged_FINAL.md` |
| Flow 3c — DailyDigest | **Round 2 FINAL** | `round2/10_flow_3c_DailyDigest_FINAL.md` |
| Flow 3d — FollowUpReminder | **Round 1 (no changes)** | `03_flows/flow_3d_FollowUpReminder.md` |
| Email templates 01–07 | **Round 1** | `templates/01_*.html` … `07_*.html` |
| Email template 08 | **Round 2** | `round2/templates/08_new_lead_notification_to_agent.html` |
| SP schema — original audit | **Round 1** | `04_sharepoint_audit.md` |
| SP schema — new columns | **Round 2 (Task 15 supersedes Task 12)** | `round2/15_task12_lineofbusiness_fix.md` + `round2/12_sharepoint_audit_round2_additions.md` (LostReason, RequoteMonthsOut, RequoteDate sections only) |
| Intake architecture | **Round 2** | `round2/11_intake_architecture.md` |
| Microsoft Forms build spec | **Round 2** | `round2/14_homeowner_microsoft_form_spec.md` |
| Agent Claims-syntax reference | **Round 2** | `round2/16_agent_claims_syntax_fixes.md` |
| Homeowner form field inventory | **Round 2** | `round2/13_homeowner_form_field_audit.md` |
| SP + Forms photo audit | **Round 2** | `round2/13_photo_audit_forms_and_schema.md` |
| Customizations.xml explanation | **Round 1** | `05_customizations_xml_explained.md` |
| Team quick reference | **Round 1** | `06a_team_quick_reference.md` |
| Session log template | **Round 1** | `06b_session_log_template.md` |
| **This document (decisions)** | **Round 2** | `round2/17_decisions_locked_summary.md` |

---

## Part 5 — Still-Open Items (Not Yet Decided)

These require Alec's action before the corresponding build step can proceed.

| # | Item | Blocks |
|---|------|--------|
| A | Verify `[VERIFY]` fields in `14_homeowner_microsoft_form_spec.md` against physical paper form | Phase 4 — cannot build the Microsoft Form without this |
| B | Confirm Year Built / Sq Ft / Construction Type / Roof Type / Roof Year columns exist in SP | Phase 1 — must add before flow build if missing |
| C | Confirm GW ACCT / ID PH / ID Spouse are intake fields or post-binding fields | Phase 4 — determines whether Q5 stays in the Microsoft Form |
| D | Confirm which Status vocabulary the live Leads list uses | Phase 3 — Flow 3b trigger fires on exact string match |
| E | Run Phone Number internal name REST query | Phase 3 — Flow 3a uses this column in the activity log |
| F | List all existing Power Automate flows touching Leads, Home Quotes, Calendar Events, Activities, or SC1047 | Phase 3 — need to know what exists to avoid duplicates or conflicts |
| G | Follow-up cadence decision (Q7 deferred) | Flow 3d — currently once per 7 days by default |
| H | Merge Leads + Home Quotes? (Round 1 recommendation, still open) | If YES: simplifies Path A to 1 SP write; recommend deciding before Phase 4 |

---

## Part 6 — Critical Reminders for Build Day

**1. Send As permission must be confirmed before any flow goes live.**
All 4 flows + both Path A flows send email FROM `SC1047@alfains.com`. Requires Send As permission granted at Exchange level by the alfains M365 admin. Check in Exchange Admin Center → Recipients → Mailboxes → SC1047 → Mailbox delegation → Send As. Must show `abadams@alfains.com` listed.

**2. Build Flow 3b last.**
Flow 3b has the highest infinite-loop risk. The trigger condition must be set before saving. Never add a write-back to the Leads list inside Flow 3b. Test Flows 3a, 3c, 3d first to confirm SP connections and permissions.

**3. Calendar Event delivery is required, not optional.**
Re-quote scheduling MUST create a Calendar Events SP list item. This is what surfaces in the CRM Calendar screen. Outlook calendar event is optional/redundant. If the Calendar Events write is missing from Flow 3b, the re-quote feature does not exist in the CRM.

**4. MR-1 every time.**
Any time you're in SP List Settings adding or changing a column — open both Leads AND Home Quotes in tabs and make the identical change to both before closing either tab.

**5. Do not touch ADAMSCOSBY_CLEAN.**
The active Canvas app build files in `C:\Users\alec\Desktop\MSAPP\ADAMSCOSBY_CLEAN\` are off-limits. No `.fx.yaml` or `.msapp` files may be modified during Cowork sessions.

---

*File: `COWORK_OUTPUTS/round2/17_decisions_locked_summary.md`*
*All Cowork session outputs: `C:\Users\alec\Desktop\MSAPP\COWORK_OUTPUTS\` (Round 1) and `COWORK_OUTPUTS\round2\` (Round 2)*
