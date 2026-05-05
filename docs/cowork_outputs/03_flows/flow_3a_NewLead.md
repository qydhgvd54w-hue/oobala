# Flow 3a — AdamsCosbyCRM_NewLead
**Trigger:** New item created in Leads list
**Purpose:** Notify the assigned agent, create a To-Do task, post to Teams, and log the activity.

---

## 1. Trigger Configuration

| Setting | Value |
|---------|-------|
| Connector | SharePoint — When an item is created |
| Site Address | `https://alfains.sharepoint.com/teams/1047889-ADAMSCOSBY` |
| List Name | `Leads` |

No filter conditions needed — fire on every new Leads item.

---

## 2. Step-by-Step Actions

### Step 1 — Initialize Variables
**Action type:** `Variable — Initialize variable`

Create two variables to hold computed values across steps:
- `varAgentEmail` (String) — will hold the assigned agent's email
- `varLeadTitle` (String) — shortcut for `triggerOutputs()?['body/Title']`

Set `varLeadTitle` = `triggerOutputs()?['body/Title']`

> **Why a variable?** The Lead Title is referenced in 3 later actions. Using a variable avoids repeating the dynamic expression and makes the flow easier to edit later.

---

### Step 2 — Get Agent Email
**Action type:** `SharePoint — Get item` OR use direct field binding

The Leads list stores the assigned Agent as a Person/Group column. Bind directly from the trigger:

```
Assigned Agent Email: triggerOutputs()?['body/Agent/Email']
```

Set `varAgentEmail` = `triggerOutputs()?['body/Agent/Email']`

> **Note:** If the Agent column is a text field rather than a Person/Group column, you will need a lookup step — see Loop Prevention Notes below.

---

### Step 3 — Send Email to Agent
**Action type:** `Office 365 Outlook — Send an email (V2)`

| Field | Value |
|-------|-------|
| To | `@{variables('varAgentEmail')}` |
| CC | `SC1047@alfains.com` |
| Subject | `New Lead: @{variables('varLeadTitle')}` |
| Body (HTML) | See below |
| From (Send As) | `SC1047@alfains.com` *(requires Send As permission — see Permissions section)* |

**Email body:**
```html
<p>A new lead has been assigned to you.</p>
<ul>
  <li><strong>Name:</strong> @{triggerOutputs()?['body/Title']}</li>
  <li><strong>Phone:</strong> @{triggerOutputs()?['body/PhoneNumber']}</li>
  <li><strong>Email:</strong> @{triggerOutputs()?['body/Email']}</li>
  <li><strong>Source:</strong> @{triggerOutputs()?['body/Source']}</li>
  <li><strong>Source Detail:</strong> @{triggerOutputs()?['body/SourceDetail']}</li>
</ul>
<p>Please make contact within 24 hours.</p>
```

---

### Step 4 — Create Microsoft To-Do Task
**Action type:** `Microsoft To Do (Business) — Create a task`

| Field | Value |
|-------|-------|
| List ID | Select the "Adams Cosby CRM" To-Do list (create this list manually first if it doesn't exist) |
| Title | `Contact @{variables('varLeadTitle')} within 24 hours` |
| Due Date | `@{addDays(utcNow(), 1)}` |
| Assigned To | `@{variables('varAgentEmail')}` |
| Notes | `Source: @{triggerOutputs()?['body/Source']} · Phone: @{triggerOutputs()?['body/PhoneNumber']}` |

---

### Step 5 — Post to Teams Channel
**Action type:** `Microsoft Teams — Post a message in a chat or channel`

| Field | Value |
|-------|-------|
| Post as | Flow bot |
| Post in | Channel |
| Team | Adams Cosby (select your team) |
| Channel | General (or create a dedicated #new-leads channel) |
| Message | `🆕 **New Lead:** @{variables('varLeadTitle')} has been assigned to @{triggerOutputs()?['body/Agent/DisplayName']}. Source: @{triggerOutputs()?['body/Source']}. Phone: @{triggerOutputs()?['body/PhoneNumber']}.` |

---

### Step 6 — Log to Activities List
**Action type:** `SharePoint — Create item`

| Field | Value |
|-------|-------|
| Site Address | `https://alfains.sharepoint.com/teams/1047889-ADAMSCOSBY` |
| List Name | `Activities` |
| ActivityType | `Created` |
| Lead (lookup) | `@{triggerOutputs()?['body/ID']}` |
| Agent | `@{triggerOutputs()?['body/Agent/Email']}` |
| EventDate | `@{utcNow()}` |
| Notes | `Lead created via @{triggerOutputs()?['body/Source']}` |

---

## 3. Error Handling

Wrap Steps 3–6 in a **Scope** action named "Notify and Log." Configure a parallel branch:

- **Configure run after** on a new Compose action set to run on **Has failed** from the Scope
- In the failure branch: Send email to `abadams@alfains.com` with subject `⚠️ Flow Error: AdamsCosbyCRM_NewLead` and body including the lead ID (`@{triggerOutputs()?['body/ID']}`) and workflow run URL (`@{workflow()['run']['id']}`)

This ensures Alec is alerted if the notification chain fails without silently dropping leads.

---

## 4. Loop Prevention

This flow fires on item **created**, not modified — so there is **no infinite loop risk**. A Teams post and Activities log entry do not trigger the Leads list, so the flow cannot call itself.

> ⚠️ Do NOT add a "Modify Leads item" action in this flow. That would trigger Flow 3b (StatusChanged), which could create cascading runs.

---

## 5. Permissions Required

| Permission | Needed For | How to Grant |
|------------|-----------|--------------|
| SharePoint — Read on Leads list | Trigger | Flow owner must have Site Member or higher |
| SharePoint — Write on Activities list | Step 6 | Same as above |
| Office 365 — Send As on SC1047@alfains.com | Step 3 | Exchange admin must grant "Send As" permission to the flow owner's account or to a service account |
| Microsoft Teams — Post message | Step 5 | Flow owner must be a member of the Adams Cosby Teams team |
| Microsoft To-Do (Business) — Create task | Step 4 | Flow owner must have access to the target To-Do list |

---

## 6. Test Plan

| Test Case | Setup | Expected Result |
|-----------|-------|-----------------|
| TC-1: Standard new lead | Create a Leads item with Title="Test Lead A", Agent=Alec, Source=Website, Phone=555-1234 | Agent email received, To-Do task created, Teams message posted, Activities log entry created |
| TC-2: Lead with no Agent assigned | Create a Leads item with Agent field empty | Flow should not error silently — Step 2 will produce null email. Add a Condition before Step 3: if `varAgentEmail` is empty, send notification to `abadams@alfains.com` instead |
| TC-3: Teams channel unavailable | Temporarily remove flow bot from test channel | Step 5 fails, failure branch emails Alec with error detail |

---

## 7. Build Checklist

- [ ] Confirm Leads list internal column name for Agent (Person/Group type vs text)
- [ ] Confirm internal column name for PhoneNumber (may be `Phone_x0020_Number` with space-encoded)
- [ ] Create "Adams Cosby CRM" To-Do list manually before first run
- [ ] Grant Send As on SC1047@alfains.com to flow owner account
- [ ] Test with TC-1 before enabling in production
