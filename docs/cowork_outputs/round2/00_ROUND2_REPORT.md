# Adams Cosby CRM — Round 2 Master Report
**Agency:** Adams Cosby Insurance · AA Agency LLC · Foley, AL
**Session:** Cowork Parallel Tasks — Round 2
**Date:** 2026-05-03
**Rule:** No existing files modified — all outputs are new files in `round2\`

---

## Output File Index

| Task | File | Summary |
|------|------|---------|
| Task 8 | `08_flow_3b_StatusChanged_FINAL.md` | Fully rebuilt Flow 3b with LostReason validation, flexible re-quote date logic, and SP Calendar Events creation as the primary delivery mechanism |
| Task 9 | `09_flow_3a_NewLead_FINAL.md` | Flow 3a with Teams post removed, replaced by branded HTML tabular email matching the SC1047 intake format |
| Task 9 | `templates/08_new_lead_notification_to_agent.html` | Template 08 — branded agent notification email, table layout, all lead fields, CTA button |
| Task 9 | `templates/08_new_lead_notification_to_agent.subject` | Subject line for Template 08 |
| Task 10 | `10_flow_3c_DailyDigest_FINAL.md` | Daily Digest updated for dual recipients (Alec + Rachel) and a new 4th section: re-quote check-ins due in the next 7 days |
| Task 11 | `11_intake_architecture.md` | Full dual-path intake architecture — Path A (Home Quote First via Microsoft Forms or SP List Form) and Path B (Lead First via Canvas modal) |
| Task 12 | `12_sharepoint_audit_round2_additions.md` | Spec and step-by-step procedure for adding 4 new Leads columns (LostReason, RequoteMonthsOut, RequoteDate, LineOfBusiness) plus 2 Calendar Events columns |

---

## Decisions Resolved (Alec's Answers, Round 2)

| # | Question | Decision |
|---|----------|----------|
| Q1 | LostReason field | **YES** — add as Choice column. Values: Price, Competitor, No Response, Not Qualified, Timing, Other. Cowork writes the spec (Task 12), Alec adds the column. |
| Q2 | Auto vs Home re-quote timing | **Flexible** — two new Leads fields: `RequoteMonthsOut` (Number, agent types 5 or 11) and `RequoteDate` (Date, agent sets explicit date). RequoteDate takes priority. Neither field set = no re-quote. |
| Q3 | Re-quote delivery method | **Calendar Events SP list item (PRIMARY, required).** Must appear on the CRM Calendar screen. Outlook calendar event is secondary/optional. Email-only delivery rejected. |
| Q4 | Flow owner | **Alec's account** (`abadams@alfains.com`). No service account. |
| Q5 | Teams channel notification | **REJECTED.** Teams post removed from Flow 3a. Replaced with branded HTML email to agent + CC to SC1047, matching the scan-to-shared-inbox intake format. |
| Q6 | Daily Digest recipients | **Both Alec AND Rachel** (`abadams@alfains.com; rcosby@alfains.com`) in a single To: field. |
| Q7 | Follow-up reminder cadence | **Deferred to future decision.** Default: once per 7 days. No change to Flow 3d spec this round. |
| Q8 | Lead intake architecture | **Dual-path system.** Path A (Home Quote First) is primary — full homeowner form creates both a Home Quotes record and a linked Leads record. Path B (Lead First) is the quick-add for non-quote leads. Both surface as buttons in the dashboard. |

---

## Open Decisions Still Pending

These were not resolved in Round 2 and must be decided before certain features can be built:

| # | Decision Needed | Blocks |
|---|----------------|--------|
| A | **Anonymous Microsoft Forms allowed in alfains tenant?** Needs M365 admin confirmation. | Path A public-facing intake (QR code, website embed). If no: agents must enter all quote data manually via SP List Form. |
| B | **Merge Leads + Home Quotes into one list?** Round 1's #1 recommendation, still open. | Affects Path A flow design: 1 SP write (merged) vs 2 SP writes (separate). Do this first if proceeding. |
| C | **Public-facing form URL:** QR code at counter? Website embed? Outlook signature? All three? | Determines how the Microsoft Form is distributed and where links need to be added. |
| D | **Default agent on Forms submission:** Always Alec, or leave blank for manual assignment? | Affects Flow 3a routing when leads come in via Forms. |
| E | **Homeowner_fixed_1.pdf field verification:** Alec must compare the Microsoft Form field list in Task 11 Section 1 against the actual paper form. | If fields don't match, the Forms submission creates incomplete records. PDF could not be parsed by automation tools in this session. |
| F | **Follow-up reminder cadence (Q7):** Daily until resolved, or capped at once per 3 days? | Flow 3d — currently deferred. |

---

## Build-Order Recommendation

This sequence minimizes dependency failures and wasted rework:

### Phase 0 — Decisions First (Before Any Build)
1. Answer open decisions A and B above
2. If B = YES (merge lists): perform the list merge before proceeding. All flows target the Leads list — if the merge happens after flows are built, they must be updated.

### Phase 1 — SharePoint Schema (Task 12)
3. Add 4 new columns to Leads list: LostReason, RequoteMonthsOut, RequoteDate, LineOfBusiness
4. Add same columns to Home Quotes list (or skip if merging)
5. Add EventType and LeadRef columns to Calendar Events list
6. Run verification REST query to confirm all columns exist

### Phase 2 — Email Templates
7. Load all 8 templates (7 from Round 1 + Template 08 from Round 2) into the Email Templates SP list

### Phase 3 — Power Automate Flows (in order)
8. **Flow 3c** (Daily Digest FINAL) — read-only, safest to build first, validates SP list access
9. **Flow 3a** (NewLead FINAL) — creates Activities items, verifies Send As permission
10. **Flow 3d** (FollowUpReminder — no change from Round 1) — validates overdue lead query
11. **Flow 3b** (StatusChanged FINAL) — most complex, highest loop risk, build last

### Phase 4 — Intake Path A
12. Build Microsoft Forms homeowner quote form (verify field list against Homeowner_fixed_1.pdf first)
13. Build `AdamsCosbyCRM_HomeQuoteFormSubmission` flow (Forms → Home Quotes → Leads)
14. Test end-to-end: submit form → verify both SP records created → verify Flow 3a fires

### Phase 5 — Dashboard Integration
15. Add `+ New Home Quote` button to Canvas app dashboard header (Path A trigger)
16. Add `LeadRef` drill-through from Calendar screen to the source Lead record
17. Update `<<DashboardLeadURL>>` token in Template 08 once the Canvas app has a stable deeplink URL

---

## Critical Reminders for the Team

### 1 — SharePoint-Backed Only. No Dataverse.

Every SP list, every Power Automate flow, and every Canvas app data source must target the SharePoint lists at `alfains.sharepoint.com/teams/1047889-ADAMSCOSBY`. The Dataverse option set (`ac_lineofbusiness`) in the XML source files is inert and has no role in this CRM. Do not add Dataverse connections to any flow or app.

### 2 — The XML Files Do Nothing

`Customizations.xml`, `Solution.xml`, and `Relationships.xml` contain no automation and no intake logic. They are a historical artifact of a Dataverse plan that was abandoned. They are correct as-is and should not be touched. The "intake automation" was never built — Round 2's Tasks 8–11 are the specifications to build it for the first time.

### 3 — Calendar Event Delivery Is Required, Not Optional

Per Alec's Q3 decision, the re-quote scheduling feature **must** create a `Calendar Events` SP list item. This is what surfaces in the CRM dashboard's Calendar screen. Email-only re-quote notifications are not sufficient — the calendar item IS the feature. Flow 3b's Step 5a (Calendar Events SP write) is mandatory; Step 5b (Outlook calendar event) is optional but recommended for redundancy.

### 4 — Build Flow 3b Last

Flow 3b has the highest infinite-loop risk of all four flows. The trigger condition `@or(equals(...'Bound'), equals(...'Lost'))` must be entered and verified before the flow is saved. Never add a write-back to the Leads list inside Flow 3b. Build and test Flows 3a, 3c, and 3d first so you have confidence in the SP connections and Send As permissions before tackling 3b.

### 5 — Send As Permission Must Be Granted Before Any Flow Goes Live

All four flows send email from `SC1047@alfains.com`. This requires "Send As" permission granted at the Exchange level by the alfains M365 admin. Without it, every email step in every flow will fail. Confirm this permission is in place before testing any flow in production.

---

## Relationship to Round 1 Outputs

Round 2 files supplement — not replace — the Round 1 outputs. Use the FINAL versions for building:

| Flow | Use This Version |
|------|----------------|
| Flow 3a (NewLead) | **Round 2: `09_flow_3a_NewLead_FINAL.md`** |
| Flow 3b (StatusChanged) | **Round 2: `08_flow_3b_StatusChanged_FINAL.md`** |
| Flow 3c (DailyDigest) | **Round 2: `10_flow_3c_DailyDigest_FINAL.md`** |
| Flow 3d (FollowUpReminder) | **Round 1: `03_flows/flow_3d_FollowUpReminder.md`** *(no changes this round)* |
| Email templates 01–07 | **Round 1: `templates/`** |
| Email template 08 | **Round 2: `round2/templates/08_*.html+subject`** |
| SP list audit | **Round 1: `04_sharepoint_audit.md`** + **Round 2: `12_sharepoint_audit_round2_additions.md`** |
| Intake architecture | **Round 2: `11_intake_architecture.md`** *(new — did not exist in Round 1)* |

---

*All Round 2 output files are in `C:\Users\alec\Desktop\MSAPP\COWORK_OUTPUTS\round2\`*
*No existing files were modified in either round.*
