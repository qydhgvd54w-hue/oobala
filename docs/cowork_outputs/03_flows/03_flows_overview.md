# Task 3 — Power Automate Flows Overview
**Adams Cosby CRM · 4 Cloud Flows**
*Spec only — no flows have been built or deployed*

---

## The Four Flows at a Glance

| Flow | Trigger | Fires When | Key Outputs |
|------|---------|-----------|-------------|
| **3a — NewLead** | Item created in Leads | Any new Leads item is created | Agent email, To-Do task, Teams post, Activity log |
| **3b — StatusChanged** | Item modified in Leads | Status field changes to Bound or Lost | Celebration/lost email, re-quote calendar event, Activity log |
| **3c — DailyDigest** | Schedule: 8 AM weekdays | Every weekday morning | Morning summary email to Alec |
| **3d — FollowUpReminder** | Schedule: 9 AM daily | Every day | Per-agent reminder emails + To-Do tasks for overdue leads |

---

## How They Fit Together

```
New lead enters Leads list
    └──► Flow 3a: Notify agent + Teams + To-Do + log

Agent works lead, updates Status
    └──► Flow 3b: If Bound → celebrate + log
                  If Lost → schedule re-quote + log

7 days pass with no contact
    └──► Flow 3d: Remind agent + create To-Do task

Every weekday at 8 AM
    └──► Flow 3c: Digest to Alec (new leads, overdue, stale quotes)
```

---

## Shared Configuration Across All Flows

**SharePoint site:** `https://alfains.sharepoint.com/teams/1047889-ADAMSCOSBY`
**Leads list:** `Leads`
**Activities list:** `Activities`
**Shared mailbox From address:** `SC1047@alfains.com`
**Send As permission required:** Yes — Exchange admin must grant Send As on SC1047 to the flow owner account

---

## Build Order Recommendation

Build and test in this order to minimize dependency risk:

1. **Flow 3c** (DailyDigest) — read-only, no side effects, easiest to validate
2. **Flow 3a** (NewLead) — creates items, no modify risk
3. **Flow 3d** (FollowUpReminder) — read + email, no modify risk
4. **Flow 3b** (StatusChanged) — most complex, highest loop risk, build last after confirming the others work

---

## Open Questions (Blocking Items Before Build)

These ambiguities need Alec's decision before building:

1. **LostReason field** — Does one exist in the Leads list? If not, should it be added before Flow 3b is built? (Recommended: yes)
2. **Auto vs Home detection** — Which field distinguishes auto from home for the re-quote delay (152 days vs 335 days)?
3. **Re-quote delivery method** — Calendar event (recommended) vs. delayed email (unreliable beyond 30 days in some tenants)?
4. **Flow owner account** — Which account should own these flows? Recommended: a service account or Alec's admin account. Not an agent account that could lose access.
5. **Teams channel** — Which channel should Flow 3a post new lead notifications to? General, or a dedicated #leads channel?
6. **Daily digest recipients** — Alec only, or also Rachel Cosby?
7. **Follow-up reminder cadence** — Daily until resolved, or capped at once per 3 days per lead?

---

## Connectors Required

All four flows use only Microsoft 365 native connectors — no third-party connectors, no premium connectors required (assuming standard Power Automate license):

- SharePoint (standard)
- Office 365 Outlook (standard)
- Microsoft Teams (standard)
- Microsoft To Do (Business) (standard)
- Schedule/Recurrence (built-in)

> ✅ No premium connectors = no additional licensing cost beyond existing M365 subscription.
