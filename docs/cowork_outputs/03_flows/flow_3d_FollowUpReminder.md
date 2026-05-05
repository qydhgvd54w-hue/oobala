# Flow 3d — AdamsCosbyCRM_FollowUpReminder
**Trigger:** Scheduled recurrence — 9:00 AM daily, Central Time
**Purpose:** Find every "Working" lead that hasn't been touched in 7+ days and remind the assigned agent.

---

## 1. Trigger Configuration

| Setting | Value |
|---------|-------|
| Connector | Schedule — Recurrence |
| Interval | 1 |
| Frequency | Day |
| At these hours | 9 |
| At these minutes | 0 |
| Time zone | (UTC-06:00) Central Time (US & Canada) |

> This fires every day including weekends. If you want weekday-only reminders, switch to a Weekly recurrence like Flow 3c and add all 5 weekdays. Weekend reminders may be harmless but could feel intrusive — Alec's call.

---

## 2. Step-by-Step Actions

### Step 1 — Query Overdue Working Leads
**Action type:** `SharePoint — Get items`

| Field | Value |
|-------|-------|
| Site Address | `https://alfains.sharepoint.com/teams/1047889-ADAMSCOSBY` |
| List Name | `Leads` |
| Filter Query | `Status eq 'Working' and Modified le '@{addDays(utcNow(), -7)}'` |
| Top Count | 500 |
| Order By | `Modified asc` *(oldest first)* |

---

### Step 2 — Condition: Any Results?
**Action type:** `Control — Condition`

```
@{length(outputs('Get_Overdue_Leads')?['body/value'])}  is greater than  0
```

- **NO:** Terminate with Succeeded — nothing to do today
- **YES:** Continue to Step 3

---

### Step 3 — Loop: For Each Overdue Lead
**Action type:** `Control — Apply to each`

Input: `@{outputs('Get_Overdue_Leads')?['body/value']}`

Inside the loop:

#### Step 3a — Send Reminder Email to Agent
**Action type:** `Office 365 Outlook — Send an email (V2)`

| Field | Value |
|-------|-------|
| To | `@{items('Apply_to_each')?['Agent/Email']}` |
| From | `SC1047@alfains.com` *(Send As)* |
| Subject | `Follow-Up Reminder: @{items('Apply_to_each')?['Title']}` |
| Body (HTML) | See below |

**Email body:**
```html
<p>Hi @{items('Apply_to_each')?['Agent/DisplayName']},</p>
<p>This is a friendly reminder that the following lead hasn't been updated in 7 or more days:</p>
<ul>
  <li><strong>Name:</strong> @{items('Apply_to_each')?['Title']}</li>
  <li><strong>Phone:</strong> @{items('Apply_to_each')?['PhoneNumber']}</li>
  <li><strong>Status:</strong> @{items('Apply_to_each')?['Status']}</li>
  <li><strong>Last Modified:</strong> @{formatDateTime(items('Apply_to_each')?['Modified'], 'M/d/yyyy')}</li>
</ul>
<p>Please update this lead's status or add a note in the CRM after you make contact.</p>
<p>— Adams Cosby CRM</p>
```

#### Step 3b — Create Microsoft To-Do Task
**Action type:** `Microsoft To Do (Business) — Create a task`

| Field | Value |
|-------|-------|
| List ID | Adams Cosby CRM To-Do list |
| Title | `Follow up: @{items('Apply_to_each')?['Title']} — last touched @{formatDateTime(items('Apply_to_each')?['Modified'], 'M/d')}` |
| Due Date | `@{utcNow()}` *(due today)* |
| Assigned To | `@{items('Apply_to_each')?['Agent/Email']}` |

---

## 3. Error Handling

Wrap the entire Apply to Each in a Scope. Configure a failure branch to send a summary error email to `abadams@alfains.com` with the failing lead's ID. Use `Configure run after` so the error handler runs on both Failure and Skipped states.

**Important:** Set the concurrency control on the Apply to Each to **1** (sequential). This prevents parallel email sends from hitting Outlook throttle limits if there are many overdue leads.

---

## 4. Loop Prevention

No risk — this flow only reads from SharePoint and writes To-Do tasks. It does not modify any Leads items.

---

## 5. Permissions Required

Same as Flow 3a.

---

## 6. Test Plan

| Test Case | Setup | Expected Result |
|-----------|-------|-----------------|
| TC-1: One overdue lead | Set one Lead to Status=Working, manually set Modified to 8 days ago (requires direct list edit or PowerShell) | One reminder email sent to assigned agent, one To-Do task created |
| TC-2: No overdue leads | All leads modified within last 7 days | Flow exits at Step 2 condition — no email sent |
| TC-3: Lead with no agent | Create a lead with empty Agent field | Loop iteration fails gracefully; error branch emails Alec with lead ID |
| TC-4: Multiple overdue leads | Set 3 leads overdue | Three separate emails sent (one per agent, not one batch); verify correct lead names in each |

---

## 7. Design Notes & Considerations

**De-duplication:** This flow sends a reminder every day a lead stays overdue. After 7 days, the agent gets 7 days' worth of reminders. Consider adding a check: only send if no Activities log entry of type "Reminder Sent" exists for this lead in the last 24 hours. This prevents reminder flooding without requiring a Leads schema change.

**Reminder cap:** A reasonable cap is one reminder per lead per 3 days. Implement with a filter: `EventDate ge '@{addDays(utcNow(), -3)}'` on the Activities list for a given Lead ID before sending.

---

## 8. Build Checklist

- [ ] Confirm internal column name for Agent (Person/Group → Agent/Email path)
- [ ] Confirm internal column name for PhoneNumber
- [ ] Decide: weekdays only or every day?
- [ ] Decide: daily reminder or capped reminder (see Design Notes above)?
- [ ] Test TC-1 manually before enabling schedule
