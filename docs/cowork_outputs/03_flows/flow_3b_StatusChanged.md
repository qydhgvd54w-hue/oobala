# Flow 3b — AdamsCosbyCRM_StatusChanged
**Trigger:** Item modified in Leads list where Status field has changed
**Purpose:** React to Bound (celebrate + log) or Lost (schedule re-quote + log) status transitions.

---

## 1. Trigger Configuration

| Setting | Value |
|---------|-------|
| Connector | SharePoint — When an item is modified |
| Site Address | `https://alfains.sharepoint.com/teams/1047889-ADAMSCOSBY` |
| List Name | `Leads` |

> ⚠️ **Critical:** SharePoint's "When an item is modified" trigger fires for EVERY field change. You MUST add a condition immediately after the trigger to check whether Status actually changed. Without this, the flow runs on every edit — a major performance and email-spam risk.

---

## 2. Step-by-Step Actions

### Step 1 — Get Previous Item Value (Status Change Detection)

**Action type:** `SharePoint — Get changes for an item or a file (properties only)`

This action returns the previous values of fields before the current edit. Use it to detect whether Status actually changed.

| Field | Value |
|-------|-------|
| Site Address | `https://alfains.sharepoint.com/teams/1047889-ADAMSCOSBY` |
| List Name | `Leads` |
| ID | `@{triggerOutputs()?['body/ID']}` |

Extract previous Status: `outputs('Get_changes')?['body/Status']` *(internal field name — verify in list settings)*

---

### Step 2 — Condition: Did Status Change?

**Action type:** `Control — Condition`

```
@{triggerOutputs()?['body/Status']}  is not equal to  @{outputs('Get_changes')?['body/Status']}
```

- **YES branch:** Continue to Step 3
- **NO branch:** Terminate (do nothing) — use `Control — Terminate` with status Succeeded

---

### Step 3 — Switch on New Status

**Action type:** `Control — Switch`

Expression: `@{triggerOutputs()?['body/Status']}`

**Case: "Bound"** → Go to Bound Actions (Steps 4–5)
**Case: "Lost"** → Go to Lost Actions (Steps 6–8)
**Default:** Terminate (no action needed for other status values)

---

### Step 4 (Bound) — Send Celebration Email
**Action type:** `Office 365 Outlook — Send an email (V2)`

| Field | Value |
|-------|-------|
| To | `@{triggerOutputs()?['body/Agent/Email']}` |
| CC | `abadams@alfains.com`, `SC1047@alfains.com` |
| Subject | `🎉 Bound! @{triggerOutputs()?['body/Title']}` |
| From | `SC1047@alfains.com` *(Send As required)* |
| Body | `Congratulations — @{triggerOutputs()?['body/Title']} has been marked Bound! Great work. This has been logged in the CRM.` |

---

### Step 5 (Bound) — Log Activity
**Action type:** `SharePoint — Create item` on Activities list

| Field | Value |
|-------|-------|
| ActivityType | `Status Change` |
| Lead | `@{triggerOutputs()?['body/ID']}` |
| Agent | `@{triggerOutputs()?['body/Agent/Email']}` |
| EventDate | `@{utcNow()}` |
| Notes | `Status changed to Bound` |

---

### Step 6 (Lost) — Check for Lost Reason Field

**Action type:** `Control — Condition`

```
@{triggerOutputs()?['body/LostReason']}  is not equal to  (empty)
```

> ⚠️ **Flag:** The Leads list schema provided does not include a `LostReason` field. **This step will fail or be skipped until that field is created.** See Questions for Alec below.

- **NO (field is empty):** Log Activity with Notes = "Marked Lost — no reason captured" and skip Step 7

---

### Step 7 (Lost) — Schedule Re-Quote Reminder

**Action type:** `Office 365 Outlook — Send an email (V2)` with **Delay Until**

The re-quote timing depends on the line of business (auto = 5 months, home = 11 months). Since the Leads list has a `Source` or type field, use a Condition to determine delay:

**Condition:** If `@{triggerOutputs()?['body/Source']}` contains "Home" or "Property" → delay = 335 days (11 months). Otherwise → delay = 152 days (5 months).

> ⚠️ **Flag:** This logic depends on a "Type" or coverage-type field in Leads. If Source is used to distinguish auto vs home, the condition above works. If a dedicated Type/LineOfBusiness field exists, use that instead. Alec to confirm.

**Action type:** `Office 365 Outlook — Send an email (V2)`

Send the appropriate re-quote template (Template 06 for auto, Template 07 for home) to the lead's email address. Use a Compose action before sending to build the token-replaced body by calling the Email Templates list and performing find/replace.

| Field | Value |
|-------|-------|
| To | `@{triggerOutputs()?['body/Email']}` |
| From | `@{triggerOutputs()?['body/Agent/Email']}` |
| Subject | *(from Email Templates list — Template 06 or 07 subject)* |
| Delay Until | `@{addDays(utcNow(), 152)}` or `@{addDays(utcNow(), 335)}` |

> **Important:** Power Automate's built-in Delay Until caps at 30 days in some connectors. For 5- and 11-month delays, the recommended approach is to **create a Calendar Event** in the agent's calendar as a reminder, or to create a scheduled Leads item with a "FollowUpDate" field that Flow 3d picks up. The calendar event approach is simpler and more reliable.

**Recommended alternative for re-quote scheduling:**

**Action type:** `Office 365 Outlook — Create event (V4)`

| Field | Value |
|-------|-------|
| Calendar ID | Agent's calendar |
| Subject | `Re-Quote Follow-Up: @{triggerOutputs()?['body/Title']}` |
| Start time | `@{addDays(utcNow(), 152)}` *(or 335 for home)* |
| Body | `This lead was marked Lost. Reach out to re-quote. Phone: @{triggerOutputs()?['body/PhoneNumber']}` |

---

### Step 8 (Lost) — Log Activity
**Action type:** `SharePoint — Create item` on Activities list

| Field | Value |
|-------|-------|
| ActivityType | `Status Change` |
| Lead | `@{triggerOutputs()?['body/ID']}` |
| Agent | `@{triggerOutputs()?['body/Agent/Email']}` |
| EventDate | `@{utcNow()}` |
| Notes | `Status changed to Lost. Reason: @{triggerOutputs()?['body/LostReason']}` |

---

## 3. Error Handling

Same Scope + failure branch pattern as Flow 3a. On failure, email `abadams@alfains.com` with Lead ID and run ID.

---

## 4. Loop Prevention

**High risk.** This flow modifies nothing in the Leads list, so it cannot trigger itself directly. However:

- **Do NOT** add a "Update item" action that writes back to the Leads list in this flow — that would re-trigger this flow immediately.
- If you add a `FlowProcessed` boolean column to Leads and try to write to it here, that write will re-trigger this flow. Use the Activities list for all logging instead.
- The trigger condition check (Step 2) is the primary loop guard — if it's bypassed or broken, this flow will run on every Leads edit.

---

## 5. Permissions Required

Same as Flow 3a, plus:

| Permission | Needed For |
|------------|-----------|
| Office 365 Calendar — Create event | Step 7 (re-quote scheduling) |
| Leads list — Read previous values | Step 1 (Get Changes) |

---

## 6. Test Plan

| Test Case | Setup | Expected Result |
|-----------|-------|-----------------|
| TC-1: Status → Bound | Change lead Status from "Working" to "Bound" | Celebration email sent, Activity log created, no re-quote scheduled |
| TC-2: Status → Lost (auto) | Change lead Status from "Working" to "Lost", Source = auto-related | Activity log created, calendar event created 152 days out |
| TC-3: Non-status edit | Change lead Notes field only | Flow runs but exits at Step 2 condition — NO email sent |
| TC-4: Status changes twice | Change Bound → Lost | Both events log correctly; only one set of Lost actions fires |

---

## 7. Questions for Alec

1. **LostReason field:** Should a "Lost Reason" dropdown be added to the Leads list? Suggested values: Price, Went with competitor, No response, Not qualified, Timing. This would make lost-lead reporting much more useful.
2. **Auto vs Home detection:** Is the coverage type stored in the Source field, a separate Type field, or the Source Detail field? The re-quote delay logic (152 vs 335 days) depends on this.
3. **Bound celebration — who gets CC'd?** Currently spec'd as Agent + Alec + SC1047. Should Rachel Cosby always be CC'd on Bound events too?

---

## 8. Build Checklist

- [ ] Confirm internal column name for Status (check in List Settings → Columns)
- [ ] Confirm "Get changes for an item" action is available in your Power Automate license tier
- [ ] Decide on LostReason field (add to Leads list before building this flow)
- [ ] Confirm auto vs home detection field
- [ ] Test TC-3 first to validate the loop guard before enabling in production
