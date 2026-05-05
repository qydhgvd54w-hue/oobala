# Task 16 — Agent Claims-Syntax Patches for All Flows
**Adams Cosby CRM · Power Automate Fix Reference**
*Applies to: All flows that write to SharePoint Person or Group columns*
*Per final decisions doc Item #6 — plain email strings DO NOT work for Person/Group writes*
*Documented: 2026-05-04*

---

## The Problem

SharePoint "Person or Group" columns cannot be written by Power Automate using a plain email string.

**This FAILS at runtime:**
```
Agent: abadams@alfains.com
```

**This WORKS:**
```json
"Agent": {
  "@odata.type": "#Microsoft.Azure.Connectors.SharePoint.SPListExpandedUser",
  "Claims": "i:0#.f|membership|abadams@alfains.com"
}
```

If the wrong syntax is used, the "Create item" or "Update item" SP action fails with an error such as:
> *"The field 'Agent' is of type 'User' and its value cannot be set directly using REST API."*

Every flow that writes a Person/Group column must use the Claims object syntax. This document catalogs every instance across all four flows and the Path A Forms submission flow.

---

## Claims Syntax Reference

### Static email (known at flow build time):
```json
{
  "@odata.type": "#Microsoft.Azure.Connectors.SharePoint.SPListExpandedUser",
  "Claims": "i:0#.f|membership|abadams@alfains.com"
}
```

### Dynamic email (from a variable or trigger output):
```json
{
  "@odata.type": "#Microsoft.Azure.Connectors.SharePoint.SPListExpandedUser",
  "Claims": "i:0#.f|membership|@{variables('AgentEmail')}"
}
```

> In Power Automate's expression editor, the `Claims` value is a concatenated string:
> `concat('i:0#.f|membership|', variables('AgentEmail'))`

### How to enter this in Power Automate UI:
1. In the "Create item" or "Update item" SP action, click the **Agent** field
2. Switch to **"Enter custom value"** (click the dropdown toggle next to the field)
3. Click **"Switch to input entire array"** if prompted
4. Paste the JSON object above into the field

---

## All Affected Flows — Instance Inventory

---

### Flow: `AdamsCosbyCRM_HomeQuoteFormSubmission` (Path A — Forms submission)
**File:** `14_homeowner_microsoft_form_spec.md` (Step 3, Step 4)

#### Instance 1 — Create Leads item, Agent column

**Location:** Step 3 — Create item → Leads list

**Incorrect (do NOT use):**
```
Agent: abadams@alfains.com
```

**Correct:**
```json
"Agent": {
  "@odata.type": "#Microsoft.Azure.Connectors.SharePoint.SPListExpandedUser",
  "Claims": "i:0#.f|membership|abadams@alfains.com"
}
```

**Note:** This defaults to Alec. Per final decisions Item #D (default agent on Forms submission = Alec). Agent can be reassigned in the Canvas app after intake.

---

#### Instance 2 — Create Activities item, Agent column

**Location:** Step 4 — Create item → Activities list

**Correct:**
```json
"Agent": {
  "@odata.type": "#Microsoft.Azure.Connectors.SharePoint.SPListExpandedUser",
  "Claims": "i:0#.f|membership|abadams@alfains.com"
}
```

---

### Flow: `AdamsCosbyCRM_HomeQuoteListItem_CreateLead` (Path A — SP List Form)
**File:** `11_intake_architecture.md` (Step 3, Step 4)

#### Instance 3 — Create Leads item, Agent column

**Location:** Step 3 — Create item → Leads list

**Correct:**
```json
"Agent": {
  "@odata.type": "#Microsoft.Azure.Connectors.SharePoint.SPListExpandedUser",
  "Claims": "i:0#.f|membership|abadams@alfains.com"
}
```

---

#### Instance 4 — Create Activities item, Agent column

**Location:** Step 4 — Create item → Activities list

**Correct:**
```json
"Agent": {
  "@odata.type": "#Microsoft.Azure.Connectors.SharePoint.SPListExpandedUser",
  "Claims": "i:0#.f|membership|abadams@alfains.com"
}
```

---

### Flow 3a: `AdamsCosbyCRM_NewLead`
**File:** `09_flow_3a_NewLead_FINAL.md`

#### Instance 5 — Create To-Do task, AssignedTo or Owner field

**Location:** Step 3 — Create a task in Microsoft To-Do

Microsoft To-Do tasks are assigned via the flow's connection identity (Alec's account), not a Person column. **This step does NOT require Claims syntax** — the To-Do connector uses the connection owner automatically. No fix needed here.

#### Instance 6 — Create Activities item, Agent column

**Location:** Step 2 — Create item → Activities list

**Review status:** Check the `09_flow_3a_NewLead_FINAL.md` file for the Activities create step. If Agent is written as a plain string, apply:

```json
"Agent": {
  "@odata.type": "#Microsoft.Azure.Connectors.SharePoint.SPListExpandedUser",
  "Claims": "i:0#.f|membership|@{triggerOutputs()?['body/Agent/Email']}"
}
```

> The trigger is "When an item is created" on the Leads list. The lead's assigned agent email is available as `triggerOutputs()?['body/Agent/Email']` (if Agent is a Person column on the Leads list — which it is). This dynamically uses whoever the lead is assigned to, rather than hardcoding Alec.

---

### Flow 3b: `AdamsCosbyCRM_StatusChanged`
**File:** `08_flow_3b_StatusChanged_FINAL.md`

#### Instance 7 — Create Calendar Events item, Agent column (**CRITICAL**)

**Location:** Step 5a — Create item → Calendar Events list

This is the most critical instance. Flow 3b creates a Calendar Event when a lead is marked Lost with a re-quote date. If the Agent field in Calendar Events is a Person/Group column, it requires Claims syntax.

**Correct:**
```json
"Agent": {
  "@odata.type": "#Microsoft.Azure.Connectors.SharePoint.SPListExpandedUser",
  "Claims": "i:0#.f|membership|@{triggerOutputs()?['body/Agent/Email']}"
}
```

> Use the trigger's `Agent/Email` dynamic output so the calendar event is assigned to whoever owns the lead, not hardcoded to Alec.

#### Instance 8 — Update Leads item in Flow 3b

**⚠️ FORBIDDEN.** Flow 3b must NEVER write back to the Leads list — this creates an infinite trigger loop. No Agent write needed here. If the spec shows any SP write to Leads from within Flow 3b, remove it.

---

### Flow 3c: `AdamsCosbyCRM_DailyDigest`
**File:** `10_flow_3c_DailyDigest_FINAL.md`

Flow 3c is a scheduled digest that reads (GET) from the Leads and Calendar Events lists and sends an email. It does **not** write to any SP Person/Group columns. **No Claims-syntax fix needed.**

---

### Flow 3d: `AdamsCosbyCRM_FollowUpReminder`
**File:** `03_flows/flow_3d_FollowUpReminder.md` (Round 1, no changes)

Flow 3d reads overdue leads and sends reminder emails. If it writes any SP updates (e.g., logging a "reminder sent" activity), check the Activities create step for an Agent field. Apply Claims syntax if present:

```json
"Agent": {
  "@odata.type": "#Microsoft.Azure.Connectors.SharePoint.SPListExpandedUser",
  "Claims": "i:0#.f|membership|@{items('Apply_to_each')?['Agent/Email']}"
}
```

> `items('Apply_to_each')` refers to the current lead item in the loop. The `Agent/Email` path retrieves the email from the Person column.

---

## Retrieving Agent Email from a Person/Group Column

When a trigger fires on a Leads item, Power Automate exposes the Agent Person column through nested dynamic content. The correct path to the email is:

| Context | Expression |
|---------|-----------|
| Trigger output (item created/modified) | `triggerOutputs()?['body/Agent/Email']` |
| Get item action output | `outputs('Get_item')?['body/Agent/Email']` |
| Loop item (Apply to each) | `items('Apply_to_each')?['Agent/Email']` |

**Do NOT use:**
- `triggerOutputs()?['body/Agent']` — returns the full object, not the email string
- `triggerOutputs()?['body/Agent/DisplayName']` — returns the display name, not the email; won't work in Claims

---

## Pre-Build Verification Steps

Before building any flow, confirm the following in the SP tenant:

1. **Confirm `Agent` column internal name on Leads list:**
   The internal name of a Person column named "Agent" may be `Agent` or `AgentId` depending on how SP created it. Run:
   ```
   https://alfains.sharepoint.com/teams/1047889-ADAMSCOSBY/_api/web/lists/getbytitle('Leads')/fields?$filter=Title eq 'Agent'&$select=Title,InternalName,TypeAsString
   ```
   If `TypeAsString` = "User", Claims syntax is required. If the InternalName differs from `Agent`, update the `@odata.type` block's field key name accordingly in the flow.

2. **Confirm `Agent` column exists on Activities and Calendar Events lists** — same query, change list name.

3. **Confirm Send As permission** — All flows send email FROM `SC1047@alfains.com`. Alec's account (`abadams@alfains.com`) must have Send As permission on that mailbox in Exchange. Without this, every email action in every flow fails regardless of Claims syntax correctness.

---

## Quick Reference Card

| Flow | Step | Column | Fix Required? | Claims Expression |
|------|------|--------|--------------|-------------------|
| HomeQuoteFormSubmission | Step 3 — Create Leads | Agent | ✅ Yes | `i:0#.f|membership|abadams@alfains.com` |
| HomeQuoteFormSubmission | Step 4 — Create Activity | Agent | ✅ Yes | `i:0#.f|membership|abadams@alfains.com` |
| HomeQuoteListItem_CreateLead | Step 3 — Create Leads | Agent | ✅ Yes | `i:0#.f|membership|abadams@alfains.com` |
| HomeQuoteListItem_CreateLead | Step 4 — Create Activity | Agent | ✅ Yes | `i:0#.f|membership|abadams@alfains.com` |
| Flow 3a — NewLead | Step 2 — Create Activity | Agent | ✅ Yes | Dynamic: `triggerOutputs()?['body/Agent/Email']` |
| Flow 3b — StatusChanged | Step 5a — Create Calendar Event | Agent | ✅ Yes | Dynamic: `triggerOutputs()?['body/Agent/Email']` |
| Flow 3b — StatusChanged | Any SP write to Leads | Agent | 🚫 Never write to Leads from 3b | Loop risk |
| Flow 3c — DailyDigest | None — read-only | — | ✅ No fix needed | — |
| Flow 3d — FollowUpReminder | Activity create (if present) | Agent | ✅ If SP write exists | Loop item: `items('Apply_to_each')?['Agent/Email']` |

---

*File: `COWORK_OUTPUTS/round2/16_agent_claims_syntax_fixes.md`*
*Next: `17_decisions_locked_summary.md` — Canonical master summary of all decisions, meta-rules, and build order*
