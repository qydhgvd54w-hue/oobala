# Flow 3c — AdamsCosbyCRM_DailyDigest
**Trigger:** Scheduled recurrence — 8:00 AM weekdays, Central Time
**Purpose:** Send Alec a morning summary of new leads, overdue follow-ups, and stale quotes.

---

## 1. Trigger Configuration

| Setting | Value |
|---------|-------|
| Connector | Schedule — Recurrence |
| Interval | 1 |
| Frequency | Week |
| On these days | Monday, Tuesday, Wednesday, Thursday, Friday |
| At these hours | 8 |
| At these minutes | 0 |
| Time zone | (UTC-06:00) Central Time (US & Canada) |

> **Note:** Power Automate recurrence time zones are set at the trigger level. Select "Central Time (US & Canada)" from the time zone dropdown — do NOT leave it as UTC, or the digest will arrive at 2:00 AM or 3:00 AM local time depending on DST.

---

## 2. Step-by-Step Actions

### Step 1 — Query: New Leads in Last 24 Hours
**Action type:** `SharePoint — Get items`

| Field | Value |
|-------|-------|
| Site Address | `https://alfains.sharepoint.com/teams/1047889-ADAMSCOSBY` |
| List Name | `Leads` |
| Filter Query | `Created ge '@{addDays(utcNow(), -1)}'` |
| Top Count | 500 |

Store result count: `@{length(outputs('Get_New_Leads')?['body/value'])}` → Variable `varNewLeadCount`

---

### Step 2 — Query: Follow-Ups Due (Working, Not Touched in 7 Days)
**Action type:** `SharePoint — Get items`

| Field | Value |
|-------|-------|
| List Name | `Leads` |
| Filter Query | `Status eq 'Working' and Modified le '@{addDays(utcNow(), -7)}'` |
| Top Count | 500 |

Store result: Variable `varFollowUpLeads` (Array)

---

### Step 3 — Query: Stale Quotes (Quoted, Not Touched in 14 Days)
**Action type:** `SharePoint — Get items`

| Field | Value |
|-------|-------|
| List Name | `Leads` |
| Filter Query | `Status eq 'Quoted' and Modified le '@{addDays(utcNow(), -14)}'` |
| Top Count | 500 |

Store result: Variable `varStaleQuotes` (Array)

---

### Step 4 — Compose: Build Follow-Up HTML Rows

**Action type:** `Control — Apply to each` on `varFollowUpLeads`

Inside the loop, append to a string variable `varFollowUpRows`:
```
<tr><td>@{items('Apply_to_each')?['Title']}</td><td>@{items('Apply_to_each')?['Agent/DisplayName']}</td><td>@{items('Apply_to_each')?['Modified']}</td></tr>
```

Do the same for `varStaleQuotes` → `varStaleQuoteRows`

---

### Step 5 — Compose: Build Full Email Body
**Action type:** `Data Operation — Compose`

```html
<h2 style="color:#C8102E;">Adams Cosby CRM — Daily Digest</h2>
<p style="color:#555;">@{formatDateTime(utcNow(), 'dddd, MMMM d, yyyy')} · 8:00 AM</p>

<h3>🆕 New Leads (Last 24 Hours)</h3>
<p><strong>@{variables('varNewLeadCount')}</strong> new lead(s) entered the pipeline.</p>

<h3>⏰ Follow-Ups Due (Working, 7+ Days No Contact)</h3>
<table border="1" cellpadding="6" cellspacing="0" style="border-collapse:collapse;width:100%;">
  <tr style="background:#C8102E;color:white;"><th>Lead Name</th><th>Agent</th><th>Last Modified</th></tr>
  @{variables('varFollowUpRows')}
</table>

<h3>📋 Stale Quotes (Quoted, 14+ Days No Activity)</h3>
<table border="1" cellpadding="6" cellspacing="0" style="border-collapse:collapse;width:100%;">
  <tr style="background:#C8102E;color:white;"><th>Lead Name</th><th>Agent</th><th>Last Modified</th></tr>
  @{variables('varStaleQuoteRows')}
</table>

<hr/>
<p style="font-size:11px;color:#888;">Sent automatically by AdamsCosbyCRM_DailyDigest · flow.microsoft.com</p>
```

---

### Step 6 — Send Email to Alec
**Action type:** `Office 365 Outlook — Send an email (V2)`

| Field | Value |
|-------|-------|
| To | `abadams@alfains.com` |
| From | `SC1047@alfains.com` *(Send As)* |
| Subject | `CRM Digest @{formatDateTime(utcNow(), 'M/d')} — @{variables('varNewLeadCount')} new, @{length(variables('varFollowUpLeads'))} follow-ups, @{length(variables('varStaleQuotes'))} stale quotes` |
| Body | `@{outputs('Compose_Email_Body')}` |
| Is HTML | Yes |

---

## 3. Error Handling

Wrap all SharePoint queries in a Scope. On failure: send error notification to `abadams@alfains.com`. The digest is informational — a failure should not be silent, but it's not critical enough to page anyone.

Add a **Condition** before Step 6: if all three counts are 0, change the email subject to `CRM Digest @{formatDateTime(utcNow(), 'M/d')} — All Clear ✅` and simplify the body. This prevents "wall of empty tables" emails on slow days.

---

## 4. Loop Prevention

No risk. This flow only reads from SharePoint and sends one email. It writes nothing.

---

## 5. Permissions Required

| Permission | Needed For |
|------------|-----------|
| SharePoint — Read on Leads list | Steps 1–3 |
| Office 365 — Send As on SC1047@alfains.com | Step 6 |

---

## 6. Test Plan

| Test Case | Setup | Expected Result |
|-----------|-------|-----------------|
| TC-1: Normal weekday | Manually trigger with at least 1 new lead, 1 working lead >7 days old | Digest email arrives with correct counts and table rows |
| TC-2: All-clear day | Trigger when no new leads, no overdue items | Email arrives with "All Clear" message, no empty tables |
| TC-3: Weekend check | Verify trigger does NOT fire Saturday/Sunday | No email received on weekend days |

---

## 7. Build Checklist

- [ ] Confirm internal column names for Status and Modified (may be `OData__Modified` depending on list version)
- [ ] Set time zone to Central Time at trigger — verify after saving that it shows correct local time
- [ ] Run TC-1 manually before scheduling to confirm email format
- [ ] Decide: should Rachel Cosby also receive the digest? (Currently Alec only per spec)
