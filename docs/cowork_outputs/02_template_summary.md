# Task 2 — Email Template Summary
**Adams Cosby Insurance Agency · Foley, AL**
*7 templates · Outlook-compatible inline HTML · Brand red #C8102E*

---

## Template 01 — New Lead Introduction

**Subject:** `Welcome to Adams Cosby Insurance, <<FirstName>> — Let's Get You Covered`

**When to use:** First-touch email immediately after a lead enters the pipeline. Send within 24 hours of the lead being created, regardless of source.

**Merge tokens used:**
- `<<FirstName>>` `<<AgentName>>` `<<AgentEmail>>` `<<AgentPhone>>`

**CTA:** Reply to agent email

---

## Template 02 — Auto Insurance Information

**Subject:** `Your Auto Insurance Options — Adams Cosby Insurance`

**When to use:** When a lead has expressed interest in auto coverage. Send as the first informational follow-up after initial contact, or when the lead's Source Detail indicates auto interest.

**Merge tokens used:**
- `<<FirstName>>` `<<VehicleInfo>>` `<<AgentName>>` `<<AgentEmail>>` `<<AgentPhone>>`

**CTA:** Call agent

---

## Template 03 — Home Insurance Information

**Subject:** `Protecting Your Home at <<RiskAddress>> — Here's What to Know`

**When to use:** When a lead is interested in home/property coverage. Personalizing the subject line with the risk address makes this highly relevant. Send after initial contact when home coverage is the primary interest.

**Merge tokens used:**
- `<<FirstName>>` `<<RiskAddress>>` `<<AgentName>>` `<<AgentEmail>>` `<<AgentPhone>>`

**CTA:** Get a home quote (reply to agent)

---

## Template 04 — Quote Sent / Quote Ready

**Subject:** `Your Insurance Quote Is Ready, <<FirstName>>`

**When to use:** Immediately after a quote has been prepared and is ready for the prospect's review. Trigger when lead Status is changed to "Quoted."

**Merge tokens used:**
- `<<FirstName>>` `<<QuotePremium>>` `<<AgentName>>` `<<AgentEmail>>` `<<AgentPhone>>`

**CTA:** Call agent to review quote

---

## Template 05 — Follow-Up Reminder

**Subject:** `Just Checking In, <<FirstName>> — Still Here to Help`

**When to use:** After 7 days with no response from a lead in "Working" or "Quoted" status. Warm, low-pressure re-engagement. Do not use more than once per 7-day period.

**Merge tokens used:**
- `<<FirstName>>` `<<AgentName>>` `<<AgentEmail>>` `<<AgentPhone>>`

**CTA:** Reply to agent email

---

## Template 06 — Re-Quote 5-Month (Auto)

**Subject:** `Time to Review Your Auto Coverage, <<FirstName>>`

**When to use:** ~5 months after a lead was marked "Lost" with auto coverage as the line of business. Triggered by the 5-month follow-up reminder scheduled in Flow 3b. References prior quote premium for context.

**Merge tokens used:**
- `<<FirstName>>` `<<VehicleInfo>>` `<<QuotePremium>>` `<<AgentName>>` `<<AgentEmail>>` `<<AgentPhone>>`

**CTA:** Call to request a re-quote

---

## Template 07 — Re-Quote 11-Month (Home)

**Subject:** `Your Home Insurance Renewal Is Coming Up, <<FirstName>>`

**When to use:** ~11 months after a lead was marked "Lost" with home coverage as the line of business. Timed to arrive approximately 1 month before a typical annual policy renewal. References prior quote and property address.

**Merge tokens used:**
- `<<FirstName>>` `<<RiskAddress>>` `<<QuotePremium>>` `<<AgentName>>` `<<AgentEmail>>` `<<AgentPhone>>`

**CTA:** Call to review home coverage

---

## Master Token Reference

| Token | Description | Used In |
|-------|-------------|---------|
| `<<FirstName>>` | Lead's first name | All 7 |
| `<<LastName>>` | Lead's last name | Available, not used in body (can add to any) |
| `<<FullName>>` | Lead's full name | Available, not used in body |
| `<<AgentName>>` | Assigned agent's display name | All 7 |
| `<<AgentEmail>>` | Assigned agent's email address | All 7 |
| `<<AgentPhone>>` | Assigned agent's direct phone | All 7 |
| `<<AgencyName>>` | Always "Adams Cosby Insurance" | Available (hardcoded in templates) |
| `<<AgencyPhone>>` | Main agency phone | Available, not used in body |
| `<<AgencyEmail>>` | Main agency email | Available, not used in body |
| `<<QuotePremium>>` | Quoted premium amount | 04, 06, 07 |
| `<<RiskAddress>>` | Property/risk address | 03, 07 |
| `<<VehicleInfo>>` | Vehicle year/make/model | 02, 06 |

---

## Implementation Notes for SharePoint Email Templates List

When loading these into the **Email Templates** SharePoint list, map fields as follows:

| Template File | List Column: Title | List Column: Subject | List Column: Body | IsActive |
|--------------|-------------------|---------------------|-------------------|---------|
| 01_new_lead_intro | New Lead Introduction | *(contents of .subject file)* | *(contents of .html file)* | Yes |
| 02_auto_info | Auto Insurance Information | *(contents of .subject file)* | *(contents of .html file)* | Yes |
| 03_home_info | Home Insurance Information | *(contents of .subject file)* | *(contents of .html file)* | Yes |
| 04_quote_sent | Quote Ready | *(contents of .subject file)* | *(contents of .html file)* | Yes |
| 05_followup_reminder | Follow-Up Reminder | *(contents of .subject file)* | *(contents of .html file)* | Yes |
| 06_requote_auto | Re-Quote Auto (5-Month) | *(contents of .subject file)* | *(contents of .html file)* | Yes |
| 07_requote_home | Re-Quote Home (11-Month) | *(contents of .subject file)* | *(contents of .html file)* | Yes |

Token replacement should be performed by Power Automate at send time using the `replace()` function or Compose actions.
