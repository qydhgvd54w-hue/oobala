# Flow 3c — AdamsCosbyCRM_DailyDigest (FINAL)
**Supersedes:** `COWORK_OUTPUTS/03_flows/flow_3c_DailyDigest.md`
**Updated:** 2026-05-03 per Alec's Round 2 decisions

Changes from Round 1:
- Recipients expanded: both Alec (abadams@alfains.com) AND Rachel (rcosby@alfains.com) in a single To: field
- Added 4th digest section: "Re-Quote Check-Ins Due in Next 7 Days" querying Calendar Events SP list
- All other logic unchanged (8 AM weekdays Central, same 3 existing queries)

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

Set variable `varNewLeadCount` = `@{length(outputs('Get_New_Leads')?['body/value'])}`

---

### Step 2 — Query: Follow-Ups Due (Working, 7+ Days No Contact)
**Action type:** `SharePoint — Get items`

| Field | Value |
|-------|-------|
| List Name | `Leads` |
| Filter Query | `Status eq 'Working' and Modified le '@{addDays(utcNow(), -7)}'` |
| Top Count | 500 |

Set variable `varFollowUpLeads` (Array)

---

### Step 3 — Query: Stale Quotes (Quoted, 14+ Days No Activity)
**Action type:** `SharePoint — Get items`

| Field | Value |
|-------|-------|
| List Name | `Leads` |
| Filter Query | `Status eq 'Quoted' and Modified le '@{addDays(utcNow(), -14)}'` |
| Top Count | 500 |

Set variable `varStaleQuotes` (Array)

---

### Step 4 — Query: Re-Quote Check-Ins Due in Next 7 Days *(NEW)*
**Action type:** `SharePoint — Get items`

| Field | Value |
|-------|-------|
| List Name | `Calendar Events` |
| Filter Query | `EventDate ge '@{utcNow()}' and EventDate le '@{addDays(utcNow(), 7)}' and EventType eq 'Re-Quote Check-In'` |
| Top Count | 500 |
| Order By | `EventDate asc` |

Set variable `varRequoteEvents` (Array)

> **Note on EventType filter:** Uses the `EventType` Choice column added to Calendar Events per Task 8's pre-build requirements. If EventType doesn't exist yet, omit the `and EventType eq 'Re-Quote Check-In'` clause and filter all upcoming calendar events instead.

---

### Step 5 — Build HTML Row Variables

Run four **Apply to Each** loops, one per result set, building string variables for the table rows:

**`varFollowUpRows`** — loop over `varFollowUpLeads`:
```
<tr>
  <td style="padding:7px 10px;border-bottom:1px solid #eee;">@{items()?['Title']}</td>
  <td style="padding:7px 10px;border-bottom:1px solid #eee;">@{items()?['Agent/DisplayName']}</td>
  <td style="padding:7px 10px;border-bottom:1px solid #eee;">@{formatDateTime(items()?['Modified'], 'M/d/yyyy')}</td>
</tr>
```

**`varStaleQuoteRows`** — loop over `varStaleQuotes` (same column pattern)

**`varRequoteRows`** — loop over `varRequoteEvents`:
```
<tr>
  <td style="padding:7px 10px;border-bottom:1px solid #eee;">@{items()?['Title']}</td>
  <td style="padding:7px 10px;border-bottom:1px solid #eee;">@{items()?['Agent/DisplayName']}</td>
  <td style="padding:7px 10px;border-bottom:1px solid #eee;">@{formatDateTime(items()?['EventDate'], 'M/d/yyyy')}</td>
</tr>
```

---

### Step 6 — Compose Full Email Body
**Action type:** `Data Operation — Compose`

```html
<table style="font-family:Arial,sans-serif;max-width:660px;width:100%;border-collapse:collapse;">
  <tr>
    <td style="background:#C8102E;padding:20px 28px;">
      <p style="margin:0;color:#fff;font-size:18px;font-weight:bold;">Adams Cosby CRM — Daily Digest</p>
      <p style="margin:4px 0 0 0;font-size:13px;color:#f9d0d6;">@{formatDateTime(utcNow(), 'dddd, MMMM d, yyyy')} &middot; 8:00 AM Central</p>
    </td>
  </tr>
  <tr>
    <td style="padding:24px 28px 8px 28px;">

      <!-- New Leads -->
      <p style="font-size:15px;font-weight:bold;color:#1F1E1D;margin:0 0 6px 0;">🆕 New Leads (Last 24 Hours)</p>
      <p style="font-size:14px;color:#333;margin:0 0 20px 0;">
        <strong style="font-size:22px;color:#C8102E;">@{variables('varNewLeadCount')}</strong> new lead(s) entered the pipeline.
      </p>

      <!-- Follow-Ups Due -->
      <p style="font-size:15px;font-weight:bold;color:#1F1E1D;margin:0 0 8px 0;">⏰ Follow-Ups Due (Working, 7+ Days No Contact)</p>
      <table width="100%" cellpadding="0" cellspacing="0" style="border-collapse:collapse;font-size:13px;margin-bottom:20px;">
        <tr style="background:#C8102E;">
          <th style="padding:8px 10px;color:#fff;text-align:left;">Lead Name</th>
          <th style="padding:8px 10px;color:#fff;text-align:left;">Agent</th>
          <th style="padding:8px 10px;color:#fff;text-align:left;">Last Touched</th>
        </tr>
        @{if(empty(variables('varFollowUpRows')), '<tr><td colspan="3" style="padding:8px 10px;color:#888;">None — all leads are up to date.</td></tr>', variables('varFollowUpRows'))}
      </table>

      <!-- Stale Quotes -->
      <p style="font-size:15px;font-weight:bold;color:#1F1E1D;margin:0 0 8px 0;">📋 Stale Quotes (Quoted, 14+ Days No Activity)</p>
      <table width="100%" cellpadding="0" cellspacing="0" style="border-collapse:collapse;font-size:13px;margin-bottom:20px;">
        <tr style="background:#C8102E;">
          <th style="padding:8px 10px;color:#fff;text-align:left;">Lead Name</th>
          <th style="padding:8px 10px;color:#fff;text-align:left;">Agent</th>
          <th style="padding:8px 10px;color:#fff;text-align:left;">Last Modified</th>
        </tr>
        @{if(empty(variables('varStaleQuoteRows')), '<tr><td colspan="3" style="padding:8px 10px;color:#888;">None — no stale quotes.</td></tr>', variables('varStaleQuoteRows'))}
      </table>

      <!-- Re-Quote Check-Ins (NEW) -->
      <p style="font-size:15px;font-weight:bold;color:#1F1E1D;margin:0 0 8px 0;">📅 Re-Quote Check-Ins Due This Week</p>
      <table width="100%" cellpadding="0" cellspacing="0" style="border-collapse:collapse;font-size:13px;margin-bottom:20px;">
        <tr style="background:#C8102E;">
          <th style="padding:8px 10px;color:#fff;text-align:left;">Lead / Event</th>
          <th style="padding:8px 10px;color:#fff;text-align:left;">Agent</th>
          <th style="padding:8px 10px;color:#fff;text-align:left;">Scheduled Date</th>
        </tr>
        @{if(empty(variables('varRequoteRows')), '<tr><td colspan="3" style="padding:8px 10px;color:#888;">No re-quote check-ins this week.</td></tr>', variables('varRequoteRows'))}
      </table>

    </td>
  </tr>
  <tr>
    <td style="background:#f4f4f4;padding:14px 28px;border-top:1px solid #e8e8e8;">
      <p style="margin:0;font-size:11px;color:#888888;">
        Sent automatically by AdamsCosbyCRM_DailyDigest &middot; <a href="https://flow.microsoft.com" style="color:#C8102E;text-decoration:none;">flow.microsoft.com</a>
      </p>
    </td>
  </tr>
</table>
```

---

### Step 7 — Condition: All Clear?
**Action type:** `Control — Condition`

```
@{and(equals(variables('varNewLeadCount'), 0), empty(variables('varFollowUpRows')), empty(variables('varStaleQuoteRows')), empty(variables('varRequoteRows')))}  is equal to  true
```

**YES (all clear):** Override subject with `CRM Digest @{formatDateTime(utcNow(), 'M/d')} — ✅ All Clear`
**NO:** Use standard subject with counts (Step 8)

---

### Step 8 — Send Digest Email
**Action type:** `Office 365 Outlook — Send an email (V2)`

| Field | Value |
|-------|-------|
| To | `abadams@alfains.com; rcosby@alfains.com` |
| From | `SC1047@alfains.com` *(Send As)* |
| Subject | `CRM Digest @{formatDateTime(utcNow(), 'M/d')} — @{variables('varNewLeadCount')} new · @{length(variables('varFollowUpLeads'))} follow-ups · @{length(variables('varStaleQuotes'))} stale · @{length(variables('varRequoteEvents'))} re-quotes` |
| Body | `@{outputs('Compose_Email_Body')}` |
| Is HTML | Yes |

> **Single email, two recipients.** Entering both addresses in the To: field (semicolon-separated) sends one email rather than two separate ones. Both Alec and Rachel see each other on the To line, which is intentional — it confirms both are in the loop.

---

## 3. Error Handling

Wrap all SharePoint queries (Steps 1–4) in a single Scope. On failure: email `abadams@alfains.com` with the error detail. The digest is informational — a missed day is acceptable; a silent failure is not.

---

## 4. Loop Prevention

None needed. Read-only flow — writes nothing to any SP list.

---

## 5. Permissions Required

| Permission | Needed For |
|------------|-----------|
| SharePoint Read — Leads list | Steps 1–3 |
| SharePoint Read — Calendar Events list | Step 4 |
| Office 365 — Send As SC1047@alfains.com | Step 8 |
| Flow owner | Alec's account |

---

## 6. Test Plan

| # | Test Case | Setup | Expected Result |
|---|-----------|-------|-----------------|
| TC-1 | Normal weekday with data | At least 1 new lead, 1 overdue lead, 1 calendar event in next 7 days | Digest arrives at both Alec and Rachel with all 4 sections populated |
| TC-2 | All-clear day | No new leads, no overdue items, no re-quotes this week | Digest arrives with "✅ All Clear" subject, empty-state messages in each table |
| TC-3 | Re-quote section only | No new leads or overdue items, but 1 Calendar Events item due in 3 days | Only re-quote section has data; other sections show "None" message |
| TC-4 | Weekend | Saturday/Sunday | Flow does NOT fire — verify no email received |

---

## 7. Build Checklist

- [ ] Confirm Calendar Events list has `EventDate`, `EventType`, and `Agent` columns
- [ ] Confirm `EventType` choice value "Re-Quote Check-In" exists (set up in Task 8 pre-build)
- [ ] Set time zone to Central Time on the trigger (not UTC)
- [ ] Enter both email addresses in the To: field with semicolon separator
- [ ] Run TC-1 manually before activating the schedule
