# Adams Cosby CRM — Dataverse for Teams Schema Spec

**Environment:** Dataverse for Teams, scoped to the **Adams Cosby Agency** team.
**Created via:** Power Apps tab inside Teams → Build → Tables → "Start with a blank table".
**Owner:** Alec B. Adams (you).

This document defines every table, every column, and every choice list you need for the
CRM. Build the tables in the order listed — each later table references earlier ones.

For the Power Apps Studio table editor, click **Add data → Create new table → Start
with a blank table** and follow the Display Name + columns below for each section.

---

## Table 1 — `Lead`

The core CRM record. One row per insurance lead in your office's pipeline.

**Display name:** Lead
**Plural:** Leads
**Primary column:** FullName (Text)

| Column display name | Internal name guidance | Type | Notes |
|---|---|---|---|
| FullName | (primary column) | Single line of text | Insured's legal name. Required. |
| FirstName | first_name | Single line of text | |
| LastName | last_name | Single line of text | |
| Phone | phone | Single line of text, format Phone | |
| Email | email | Single line of text, format Email | |
| DOB | dob | Date only | |
| MailingAddress | mailing_address | Multiple lines of text | |
| RiskAddress | risk_address | Multiple lines of text | |
| City | city | Single line of text | |
| State | state | Single line of text | Default "AL" |
| Zip | zip | Single line of text | |
| LineOfBusiness | line_of_business | Choice (single) | Choices: P&C, Alfa Agency, Life |
| Status | status | Choice (single) | Choices: New, In Progress, Quoted, Follow-up, Bound, Lost |
| Source | source | Choice (single) | Choices: Walk-in, Call-in, Referral, Cross-sell, Re-quote |
| SourceDetail | source_detail | Single line of text | Free-text e.g. referral name |
| Agent | agent | Lookup → SystemUser | Person record, NOT a choice |
| Temperature | temperature | Choice (single) | Choices: Hot, Warm, Cold, None |
| Pinned | pinned | Yes/No | Default No |
| FollowUpDate | follow_up_date | Date and time | |
| LastTouch | last_touch | Date and time | |
| WorkingBy | working_by | Lookup → SystemUser | Auto-cleared after idle |
| IsRequote | is_requote | Yes/No | Default No |
| LostReason | lost_reason | Choice (single) | Choices: Price, Coverage, Carrier preference, No response, Other. Optional, only filled when Status = Lost |
| Notes | notes | Multiple lines of text | Owner-only edit/delete (enforced in form) |
| CurrentCarrier | current_carrier | Single line of text | |
| CurrentPremium | current_premium | Currency | |
| QuotedPremium | quoted_premium | Currency | |
| Products | products | Multiple lines of text | What products quoted (HO, Auto, Life, etc.) |

**Permissions on this table:**
- Owner (Alec): Create / Read / Write / Delete / Append / AppendTo / Assign / Share
- Admin (Rachel): Create / Read / Write / Append / AppendTo / Assign / Share — NO Delete
- Agent: Create / Read (own + team) / Write (own) — NO Delete
- Inputter: Create / Read (own) / Write (own) — NO Delete

---

## Table 2 — `AgentGoal`

One row per agent per month per line-of-business. Drives the Reports → Goals tab.

**Display name:** Agent Goal
**Plural:** Agent Goals
**Primary column:** GoalName (Text, auto-formatted as "{Agent} {Month} {LOB}")

| Column display name | Type | Notes |
|---|---|---|
| GoalName | Single line of text | Calculated/auto-named |
| Agent | Lookup → SystemUser | Required |
| Month | Date only | Use the 1st of the month as canonical value |
| LineOfBusiness | Choice (single) | Choices: P&C, Alfa Agency, Life |
| TargetPremium | Currency | What agent committed to hit |
| CurrentPremium | Currency | Rolled up from bound Lead records via calculated formula or flow |

---

## Table 3 — `RequoteOpp`

Re-quote opportunities. Power Automate flow populates this daily.

**Display name:** Re-quote Opp
**Plural:** Re-quote Opps
**Primary column:** OppName (Text — auto "{Lead.FullName} {Product} {MarkDate}")

| Column display name | Type | Notes |
|---|---|---|
| OppName | Single line of text | Auto-named |
| Lead | Lookup → Lead | The lead this opportunity is for |
| Product | Choice (single) | Choices: Auto, Home, Wind, Flood, Life |
| QuotedDate | Date only | When original quote was given |
| MarkDate | Date only | Anniversary date when re-quote should fire (5mo for auto, 11mo for home) |
| DaysOut | Whole number | Calculated: MarkDate - Today() |
| Premium | Currency | Original premium |
| Activated | Yes/No | When flipped to Yes by user, also flips IsRequote=true on the linked Lead |
| Agent | Lookup → SystemUser | |

---

## Table 4 — `Alert`

The notification feed for the top-bar alert button. Flows write here, app dismisses.

**Display name:** Alert
**Plural:** Alerts
**Primary column:** Message (Text)

| Column display name | Type | Notes |
|---|---|---|
| Message | Single line of text | The alert text |
| User | Lookup → SystemUser | Who this alert is for |
| Type | Choice (single) | Choices: Requote, StaleQuote, GoalPacing, Mention |
| RelatedLead | Lookup → Lead | Optional |
| CreatedAt | Date and time | |
| Dismissed | Yes/No | Default No |
| DismissedAt | Date and time | |

---

## Table 5 — `Template`

Email and text templates for staff. Editable from the Templates screen.

**Display name:** Template
**Plural:** Templates
**Primary column:** Name (Text)

| Column display name | Type | Notes |
|---|---|---|
| Name | Single line of text | Display name |
| Type | Choice (single) | Choices: Email, Text |
| Subject | Single line of text | Email only |
| Body | Multiple lines of text | Body content |
| Channel | Choice (single) | Choices: Quote follow-up, Cold lead, Bound thank-you, Re-quote intro, Other |
| Disabled | Yes/No | Default No |
| Owner | Lookup → SystemUser | |

---

## Table 6 — `SavedView`

Each user's personal saved filter combinations. The floppy disk button writes here.

**Display name:** Saved View
**Plural:** Saved Views
**Primary column:** Name (Text)

| Column display name | Type | Notes |
|---|---|---|
| Name | Single line of text | View name (e.g. "My P&C quoted") |
| User | Lookup → SystemUser | Owner |
| FilterJSON | Multiple lines of text | Serialized filter state — agent, status, line, search, extras |

---

## Table 7 — `AuditLog`

Owner-only viewable. Every status change, reassignment, edit-after-bound is written here by a Power Automate flow.

**Display name:** Audit Log Entry
**Plural:** Audit Log Entries
**Primary column:** Summary (Text)

| Column display name | Type | Notes |
|---|---|---|
| Summary | Single line of text | Auto-generated one-liner |
| Who | Lookup → SystemUser | Person who made the change |
| What | Choice (single) | Choices: Reassign, StatusChange, EditBound, LostReason |
| Lead | Lookup → Lead | The affected lead |
| OldValue | Single line of text | |
| NewValue | Single line of text | |
| Timestamp | Date and time | |

---

## Choice Lists — Consolidated

If you build choices as **global option sets** (recommended), define each once and reuse.

### LineOfBusiness
- P&C
- Alfa Agency
- Life

### LeadStatus
- New
- In Progress
- Quoted
- Follow-up
- Bound
- Lost

### LeadSource
- Walk-in
- Call-in
- Referral
- Cross-sell
- Re-quote

### Temperature
- Hot
- Warm
- Cold
- None

### LostReason
- Price
- Coverage
- Carrier preference
- No response
- Other

### Product (RequoteOpp.Product)
- Auto
- Home
- Wind
- Flood
- Life

### AlertType
- Requote
- StaleQuote
- GoalPacing
- Mention

### AuditWhat
- Reassign
- StatusChange
- EditBound
- LostReason

### TemplateType
- Email
- Text

### TemplateChannel
- Quote follow-up
- Cold lead
- Bound thank-you
- Re-quote intro
- Other

---

## Build order — sequence matters because of lookups

1. **Global choice lists** — create all 11 choice lists first (Power Apps → Choices in left nav). This way every table uses the canonical values from the start.
2. **Lead** — has no lookups except SystemUser (built in). Build first.
3. **AgentGoal** — only lookup is to SystemUser. Build second.
4. **Template** — only lookup is to SystemUser. Build any time.
5. **SavedView** — only lookup is to SystemUser. Build any time.
6. **Alert** — has Lookup → Lead. Build after Lead.
7. **RequoteOpp** — has Lookup → Lead. Build after Lead.
8. **AuditLog** — has Lookup → Lead. Build after Lead.

---

## Hand-off prompt for Claude Code

Paste the following into a Claude Code session **after `pac` has been re-authed against the Adams Cosby Agency Dataverse for Teams environment** (`pac auth create` will pick it up; verify with `pac org list` showing the new environment alongside Alfa Companies (Upgrade)).

```
Build the Adams Cosby CRM schema in Dataverse for Teams.

Working spec: /home/claude/spec/adams_cosby_crm_schema.md (paste it inline below if not on the same machine).

Constraints:
- The Adams Cosby Agency Teams Dataverse environment is the target. Confirm with `pac org who` before doing anything.
- Do NOT touch the Alfa Companies (Upgrade) environment.
- Use solution-based deployment: create a new unmanaged solution called "AdamsCosbyCRM", and add every choice list and table to it. This makes future export/migration clean.
- Build choice lists FIRST, then tables in the order specified.
- After each table is created, pause and print the schema confirmation (table name + every column name + type) and wait for me to type "next" before proceeding to the next table.
- If any column type or lookup target fails, STOP. Do not retry, do not improvise. Print the error and wait.
- Do not seed sample data — empty tables only. We migrate data later via flow.

Start with: confirm `pac org who` is pointing at the Adams Cosby Agency Teams environment, then create the unmanaged solution. Then build choice lists. Wait for "next" between each block.
```

---

## What this spec deliberately does NOT include

- Migration of the existing 66-column SharePoint Leads list. That happens via a one-off Power Automate flow after the Dataverse schema exists. The flow reads SharePoint, maps fields per a translation table (which we'll write next), and writes to Dataverse Lead.
- The Power Apps screens themselves. Those are a separate spec — we build the data layer first, then layer the screens on top.
- The four Power Automate flows (audit writer, re-quote, stale quote, goal pacing). They each get their own spec doc once the schema is locked.
- Permissions setup. Dataverse for Teams has a simpler permission model than full Dataverse — Team membership = access — but the granular Owner/Admin/Agent/Inputter rules from the original SharePoint plan need to be implemented as in-app filtering instead of table-level security.

These four pieces are the next four spec docs after this one. Schema first.

---

*End of schema spec. Saved to /home/claude/spec/adams_cosby_crm_schema.md*
