# Flow 3b — AdamsCosbyCRM_StatusChanged (FINAL)
**Supersedes:** `COWORK_OUTPUTS/03_flows/flow_3b_StatusChanged.md`
**Updated:** 2026-05-03 per Alec's Round 2 decisions

Changes from Round 1:
- LostReason field confirmed — add spec included
- Re-quote scheduling replaced with RequoteMonthsOut / RequoteDate flexible logic
- Calendar Events SP list item creation added (PRIMARY delivery — required)
- Outlook calendar event added (SECONDARY / optional)
- Teams post removed entirely
- Loop prevention upgraded to trigger condition on Status field only

---

## 1. Pre-Build Requirements

Before building this flow, the following columns must exist in the **Leads** SP list (see Task 12 for add procedure):

| Column | Type | Used In |
|--------|------|---------|
| `LostReason` | Choice: Price, Competitor, No Response, Not Qualified, Timing, Other | Lost branch Step 6 |
| `RequoteMonthsOut` | Number | Lost branch Step 7 |
| `RequoteDate` | Date and Time | Lost branch Step 7 |

And the following must exist in the **Calendar Events** SP list:

| Column | Type | Notes |
|--------|------|-------|
| `Title` | Single line text | Auto-set by flow |
| `EventDate` | Date and Time | The re-quote date |
| `Agent` | Person or Group | Assigned agent |
| `LeadRef` | Lookup → Leads list | Links event back to lead |
| `EventType` | Choice | Add value: "Re-Quote Check-In" |

---

## 2. Trigger Configuration

| Setting | Value |
|---------|-------|
| Connector | SharePoint — When an item is modified |
| Site Address | `https://alfains.sharepoint.com/teams/1047889-ADAMSCOSBY` |
| List Name | `Leads` |
| **Trigger condition** | `@equals(triggerOutputs()?['body/Status'], 'Bound')` OR `@equals(triggerOutputs()?['body/Status'], 'Lost')` |

> **Critical — use a Trigger Condition, not just a runtime Condition.** A trigger condition is set on the trigger itself (Advanced Options → Trigger Conditions) and prevents the flow run from being created at all when Status is not Bound or Lost. This is the cleanest loop prevention: flows that don't start can't loop. Runtime conditions still count as a flow run against your plan quota; trigger conditions do not.

**Trigger condition expression (paste into the Trigger Conditions field):**
```
@or(equals(triggerOutputs()?['body/Status'], 'Bound'), equals(triggerOutputs()?['body/Status'], 'Lost'))
```

---

## 3. Step-by-Step Actions

### Step 1 — Initialize Variables
**Action type:** `Variable — Initialize variable` (run 3 times for 3 variables)

| Variable | Type | Initial Value |
|----------|------|---------------|
| `varLeadTitle` | String | `@{triggerOutputs()?['body/Title']}` |
| `varAgentEmail` | String | `@{triggerOutputs()?['body/Agent/Email']}` |
| `varRequoteDate` | String | *(blank — calculated in Lost branch)* |

---

### Step 2 — Switch on Status

**Action type:** `Control — Switch`

Expression: `@{triggerOutputs()?['body/Status']}`

---

### ── BOUND BRANCH ──

#### Step 3a — Send Celebration Email
**Action type:** `Office 365 Outlook — Send an email (V2)`

| Field | Value |
|-------|-------|
| To | `@{variables('varAgentEmail')}` |
| CC | `abadams@alfains.com`, `SC1047@alfains.com` |
| From | `SC1047@alfains.com` *(Send As required)* |
| Subject | `🎉 Bound! @{variables('varLeadTitle')}` |
| Body (HTML) | See below |
| Is HTML | Yes |

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
    <p style="margin-top:20px;font-size:14px;color:#555;">This has been logged in the CRM. Keep it up!</p>
    <p style="margin-top:16px;font-size:13px;color:#555;">— Adams Cosby CRM</p>
  </td></tr>
</table>
```

#### Step 3b — Log Activity (Bound)
**Action type:** `SharePoint — Create item`

| Field | Value |
|-------|-------|
| Site Address | `https://alfains.sharepoint.com/teams/1047889-ADAMSCOSBY` |
| List Name | `Activities` |
| ActivityType | `Status Change` |
| Lead | `@{triggerOutputs()?['body/ID']}` |
| Agent | `@{variables('varAgentEmail')}` |
| EventDate | `@{utcNow()}` |
| Notes | `Status changed to Bound` |

---

### ── LOST BRANCH ──

#### Step 4a — Check LostReason Populated
**Action type:** `Control — Condition`

```
@{empty(triggerOutputs()?['body/LostReason'])}  is equal to  true
```

**YES (LostReason is blank) → send reminder to agent:**

**Action type:** `Office 365 Outlook — Send an email (V2)`

| Field | Value |
|-------|-------|
| To | `@{variables('varAgentEmail')}` |
| CC | `abadams@alfains.com` |
| From | `SC1047@alfains.com` |
| Subject | `⚠️ Lost Reason Missing: @{variables('varLeadTitle')}` |
| Body | `@{triggerOutputs()?['body/Title']} was marked Lost but no Lost Reason was recorded. Please open the lead in the CRM and select a Lost Reason so we can track why leads are not converting.` |

> Flow then continues to Step 4b regardless — the re-quote logic runs even if LostReason is missing. The email is a reminder, not a blocker.

**NO (LostReason is set) → continue to Step 4b.**

---

#### Step 4b — Calculate Re-Quote Date
**Action type:** `Control — Condition` (nested)

**Condition 1:** Is `RequoteDate` set?
```
@{empty(triggerOutputs()?['body/RequoteDate'])}  is equal to  false
```

**YES → use the explicit date:**
- Compose: `varRequoteDate` = `@{triggerOutputs()?['body/RequoteDate']}`

**NO → check RequoteMonthsOut:**

  **Condition 2:** Is `RequoteMonthsOut` set?
  ```
  @{empty(triggerOutputs()?['body/RequoteMonthsOut'])}  is equal to  false
  ```

  **YES → calculate date from months:**
  - Compose: `varRequoteDate` = `@{addDays(utcNow(), mul(int(triggerOutputs()?['body/RequoteMonthsOut']), 30))}`

  > **Note on month math:** Power Automate's `addDays()` takes days, not months. Multiplying months × 30 is an approximation. For precision, use `addMonths()` if your tenant has it, or `addDays(utcNow(), mul(int(body/RequoteMonthsOut), 30))`. 5 months = 150 days, 11 months = 330 days — close enough for a re-quote reminder.

  **NO → set varRequoteDate to blank:**
  - Compose: `varRequoteDate` = `""`

---

#### Step 4c — Condition: Schedule Re-Quote?
**Action type:** `Control — Condition`

```
@{empty(variables('varRequoteDate'))}  is equal to  false
```

**YES (date is set) → Steps 5a + 5b (create calendar event)**
**NO (no date) → skip to Step 6 (log activity only)**

---

#### Step 5a — Create Calendar Events SP List Item *(PRIMARY — Required)*
**Action type:** `SharePoint — Create item`

| Field | Value |
|-------|-------|
| Site Address | `https://alfains.sharepoint.com/teams/1047889-ADAMSCOSBY` |
| List Name | `Calendar Events` |
| Title | `Re-quote check-in: @{variables('varLeadTitle')}` |
| EventDate | `@{variables('varRequoteDate')}` |
| Agent | `@{triggerOutputs()?['body/Agent/Email']}` |
| LeadRef | `@{triggerOutputs()?['body/ID']}` *(lookup ID)* |
| EventType | `Re-Quote Check-In` |
| Notes | `Lead was marked Lost (@{triggerOutputs()?['body/LostReason']}). Scheduled re-quote check-in.` |

> **This is the CRM-visible calendar event.** It will appear on the dashboard's Calendar screen when that screen is built. Use this list item as the source of truth for re-quote scheduling — not the Outlook calendar event.

---

#### Step 5b — Create Outlook Calendar Event *(SECONDARY — Optional)*
**Action type:** `Office 365 Outlook — Create event (V4)`

| Field | Value |
|-------|-------|
| Calendar ID | `@{variables('varAgentEmail')}` *(agent's primary calendar)* |
| Subject | `Re-quote: @{variables('varLeadTitle')}` |
| Start time | `@{variables('varRequoteDate')}` |
| End time | `@{addMinutes(variables('varRequoteDate'), 30)}` |
| Body | `This lead was marked Lost (@{triggerOutputs()?['body/LostReason']}). Time to reach back out and re-quote. Phone: @{triggerOutputs()?['body/Phone_x0020_Number']}` |
| Reminder (minutes) | `1440` *(1 day before)* |
| Is HTML Body | Yes |

---

#### Step 6 — Log Activity (Lost)
**Action type:** `SharePoint — Create item`

| Field | Value |
|-------|-------|
| Site Address | `https://alfains.sharepoint.com/teams/1047889-ADAMSCOSBY` |
| List Name | `Activities` |
| ActivityType | `Status Change` |
| Lead | `@{triggerOutputs()?['body/ID']}` |
| Agent | `@{variables('varAgentEmail')}` |
| EventDate | `@{utcNow()}` |
| Notes | `Status changed to Lost. Reason: @{if(empty(triggerOutputs()?['body/LostReason']), '(not provided)', triggerOutputs()?['body/LostReason'])}. Re-quote scheduled: @{if(empty(variables('varRequoteDate')), 'None', variables('varRequoteDate'))}` |

---

## 4. Error Handling

Wrap the entire Switch (Steps 2–6) in a **Scope** action. Add a parallel branch configured to run on **Has failed**:

- Send email to `abadams@alfains.com`
- Subject: `⚠️ Flow Error: AdamsCosbyCRM_StatusChanged`
- Body: `Lead ID: @{triggerOutputs()?['body/ID']} · Status attempted: @{triggerOutputs()?['body/Status']} · Run ID: @{workflow()['run']['id']}`

---

## 5. Loop Prevention

**Primary guard: Trigger Condition (see §2).** The trigger condition `@or(equals(...'Bound'), equals(...'Lost'))` means the flow only runs when Status is exactly Bound or Lost. Any other field edit — including Notes, LostReason, RequoteDate — does not start a flow run at all.

**Secondary guard: No Leads write-back.** This flow never writes to the Leads list. It writes to Activities and Calendar Events only. There is no way for this flow to trigger itself.

**Verify after build:** After saving, confirm the trigger condition appears in the trigger's "Advanced" section. If it shows as empty, re-enter it — Power Automate sometimes silently drops trigger conditions on save.

---

## 6. Permissions Required

| Permission | Needed For |
|------------|-----------|
| SharePoint Read — Leads list | Trigger |
| SharePoint Write — Activities list | Step 3b, Step 6 |
| SharePoint Write — Calendar Events list | Step 5a |
| Office 365 Outlook — Send As SC1047@alfains.com | Steps 3a, 4a |
| Office 365 Outlook — Create event on agent calendars | Step 5b (secondary) |
| Flow owner | Alec's account (abadams@alfains.com) |

---

## 7. Test Plan

| # | Test Case | Setup | Expected Result |
|---|-----------|-------|-----------------|
| TC-1 | Mark lead Bound | Change Status of any lead to "Bound" | Celebration email sent to agent + CC to Alec + SC1047. Activity logged "Status changed to Bound". No Calendar Event created. |
| TC-2 | Mark lead Lost — no LostReason | Change Status to "Lost", leave LostReason blank | Agent receives "Lost Reason Missing" warning email. Activity logged with "(not provided)". No Calendar Event (RequoteDate/months also blank). |
| TC-3 | Mark lead Lost — LostReason="Price", RequoteMonthsOut=5 | Change Status to "Lost", set LostReason="Price", RequoteMonthsOut=5 | No warning email. Calendar Events SP item created with EventDate = today + 150 days. Outlook calendar event created 150 days out. Activity logged with Reason=Price and re-quote date. |
| TC-4 | Mark lead Lost — explicit RequoteDate set | Change Status to "Lost", set RequoteDate = a specific future date | Calendar Events SP item created on the explicit date (not calculated). RequoteDate takes priority over RequoteMonthsOut. |

---

## 8. Build Checklist

- [ ] Add LostReason, RequoteMonthsOut, RequoteDate columns to Leads list (Task 12)
- [ ] Add EventType column to Calendar Events list with value "Re-Quote Check-In"
- [ ] Add LeadRef lookup column to Calendar Events list pointing to Leads
- [ ] Enter Trigger Condition expression before first save
- [ ] Verify trigger condition persists after save (check Advanced options)
- [ ] Run TC-2 first (simplest path, no date logic) before enabling production
- [ ] Grant Send As on SC1047@alfains.com to abadams@alfains.com
