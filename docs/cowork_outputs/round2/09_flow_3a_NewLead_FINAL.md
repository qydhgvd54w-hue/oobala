# Flow 3a — AdamsCosbyCRM_NewLead (FINAL)
**Supersedes:** `COWORK_OUTPUTS/03_flows/flow_3a_NewLead.md`
**Updated:** 2026-05-03 per Alec's Round 2 decisions

Changes from Round 1:
- Teams channel post removed entirely
- Agent notification email upgraded to branded HTML tabular format (Template 08)
- Email now matches the scan-to-shared-inbox intake format (tabular lead details)
- CTA button links to the lead's CRM record
- SC1047 CC'd on every new lead notification

---

## 1. Trigger Configuration

| Setting | Value |
|---------|-------|
| Connector | SharePoint — When an item is created |
| Site Address | `https://alfains.sharepoint.com/teams/1047889-ADAMSCOSBY` |
| List Name | `Leads` |

No trigger condition needed — fires on every new Leads item creation.

---

## 2. Step-by-Step Actions

### Step 1 — Initialize Variables
**Action type:** `Variable — Initialize variable` (run 2 times)

| Variable | Type | Initial Value |
|----------|------|---------------|
| `varLeadTitle` | String | `@{triggerOutputs()?['body/Title']}` |
| `varAgentEmail` | String | `@{triggerOutputs()?['body/Agent/Email']}` |

> If Agent field is empty, `varAgentEmail` will be null. The Condition in Step 2 catches this and redirects to Alec.

---

### Step 2 — Condition: Agent Assigned?
**Action type:** `Control — Condition`

```
@{empty(variables('varAgentEmail'))}  is equal to  false
```

- **YES (agent is set):** Use `varAgentEmail` as the To: address → continue to Step 3
- **NO (agent is empty):** Set `varAgentEmail` = `abadams@alfains.com` → continue to Step 3

This ensures a lead with no assigned agent still generates a notification to Alec instead of silently failing.

---

### Step 3 — Compose Email Body (Token Replace)
**Action type:** `Data Operation — Compose`

Build the HTML body by loading Template 08 from the Email Templates SP list and substituting tokens. The simplest approach at build time is to embed the HTML directly in this Compose action rather than fetching from the list each run (the list lookup adds latency and a failure point):

```html
<!-- Paste the full contents of:
     COWORK_OUTPUTS/round2/templates/08_new_lead_notification_to_agent.html
     then replace <<TokenName>> placeholders with Power Automate dynamic expressions as shown below -->
```

**Token substitution map:**

| Token | Power Automate Expression |
|-------|--------------------------|
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

> **On `<<DashboardLeadURL>>`:** This links to the SharePoint list form view for the lead. Once the Canvas app is deployed and has a stable URL with a lead ID parameter, update this to link directly into the dashboard instead.

---

### Step 4 — Send Notification Email to Agent
**Action type:** `Office 365 Outlook — Send an email (V2)`

| Field | Value |
|-------|-------|
| To | `@{variables('varAgentEmail')}` |
| CC | `SC1047@alfains.com` |
| From | `SC1047@alfains.com` *(Send As required)* |
| Subject | `New Lead: @{variables('varLeadTitle')} — @{triggerOutputs()?['body/Source']}` |
| Body | `@{outputs('Compose_Email_Body')}` |
| Is HTML | Yes |

> **Subject format note:** This mirrors the existing scan-to-shared-inbox intake format. The pattern `New Lead: [Name] — [Source]` matches what the SC1047 mailbox currently receives from scanned intake forms, so this notification will visually blend with the existing intake email stream.

---

### Step 5 — Create Microsoft To-Do Task
**Action type:** `Microsoft To Do (Business) — Create a task`

| Field | Value |
|-------|-------|
| List ID | Adams Cosby CRM *(create manually before first run)* |
| Title | `Contact @{variables('varLeadTitle')} within 24 hours` |
| Due Date | `@{addDays(utcNow(), 1)}` |
| Assigned To | `@{variables('varAgentEmail')}` |
| Notes | `Source: @{triggerOutputs()?['body/Source']} · Phone: @{triggerOutputs()?['body/Phone_x0020_Number']}` |

---

### Step 6 — Log to Activities List
**Action type:** `SharePoint — Create item`

| Field | Value |
|-------|-------|
| Site Address | `https://alfains.sharepoint.com/teams/1047889-ADAMSCOSBY` |
| List Name | `Activities` |
| ActivityType | `Created` |
| Lead | `@{triggerOutputs()?['body/ID']}` |
| Agent | `@{variables('varAgentEmail')}` |
| EventDate | `@{utcNow()}` |
| Notes | `Lead created via @{triggerOutputs()?['body/Source']}` |

---

## 3. Error Handling

Wrap Steps 3–6 in a **Scope** named "Notify and Log." Add a parallel branch on **Has failed**:

- Send email to `abadams@alfains.com`
- Subject: `⚠️ Flow Error: AdamsCosbyCRM_NewLead`
- Body: `Lead ID: @{triggerOutputs()?['body/ID']} · Run ID: @{workflow()['run']['id']}`

---

## 4. Loop Prevention

No risk. This flow fires on item **created**, not modified. Writing to Activities and To-Do does not trigger the Leads list. Never add a "Modify Leads item" step to this flow.

---

## 5. Permissions Required

| Permission | Needed For |
|------------|-----------|
| SharePoint Read — Leads list | Trigger |
| SharePoint Write — Activities list | Step 6 |
| Office 365 — Send As SC1047@alfains.com | Step 4 |
| Microsoft To-Do (Business) — Create task | Step 5 |
| Flow owner | Alec's account (abadams@alfains.com) |

*(Teams permission removed — Teams post step eliminated per Round 2 decision)*

---

## 6. Test Plan

| # | Test Case | Setup | Expected Result |
|---|-----------|-------|-----------------|
| TC-1 | Standard new lead, agent assigned | Create Leads item: Title="Test Lead A", Agent=Alec, Source="Website", Phone=2515551234 | Agent receives branded HTML email with all fields populated. CC arrives at SC1047. To-Do task created. Activity logged. |
| TC-2 | New lead, no agent assigned | Create Leads item with Agent field empty | Email redirects to abadams@alfains.com. All other steps complete normally. |
| TC-3 | New lead from Home Quote path | Flow 11a (Microsoft Forms) creates a Leads item via Power Automate | Flow 3a fires on the auto-created Leads item — same behavior as TC-1. Verify no double-notification. |

---

## 7. Build Checklist

- [ ] Create "Adams Cosby CRM" To-Do list manually before first run
- [ ] Grant Send As on SC1047@alfains.com to abadams@alfains.com
- [ ] Confirm internal column names: `Phone_x0020_Number`, `Source_x0020_Detail`, `Risk_x0020_Address`
- [ ] Embed Template 08 HTML into the Compose step with token substitution
- [ ] Update `<<DashboardLeadURL>>` once Canvas app has a stable deeplink URL
- [ ] Test TC-1 before enabling in production
