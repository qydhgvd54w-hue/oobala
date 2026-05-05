# SharePoint List Schema Documentation

Reference docs for the SharePoint lists the canvas app binds to.
These are NOT JSON formatting files — they're schema documentation
so we know what columns exist, what types they are, and what
the canvas app expects.

## Lists in scope

| List | Internal name | Purpose |
|---|---|---|
| Leads | Leads | Lead pipeline |
| Home Quotes | Home Quotes | 76-field quote details |
| Activities | Activities | Call/email/meeting log |
| Calendar Events | Calendar Events | Follow-ups + appointments |
| Email Templates | Email Templates | Token-substituted templates |
| Quote Documents | Quote Documents | PDFs per lead |
| Audit Log | Audit Log | Compliance trail |

## Schema files (to be written)

Each list gets its own .md documenting:
- Column display name → internal name (e.g., EventDate → Start)
- Column type (Text, Choice, Lookup, Person, Date)
- Choice column values (for Status, Type, Source, ActivityType)
- Lookup column targets
- Required vs optional
- Default values

Pull schema via REST query:

```
https://alfains.sharepoint.com/teams/1047889-ADAMSCOSBY/_api/web/lists/getbytitle('Leads')/fields
```

Or via the unpacked Power Apps DataSources/*.json — those contain
the canonical list of columns the canvas app sees.
