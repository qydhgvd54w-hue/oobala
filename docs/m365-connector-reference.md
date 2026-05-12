# Adams Cosby CRM — Microsoft 365 connector reference

**Single-source-of-truth reference** for every Microsoft 365 connector wired into the Adams Cosby Insurance Agency CRM (Power Apps Canvas + SharePoint Online + Power Automate). All signatures verified against `learn.microsoft.com/connectors/*` as of May 2026. Branch context: `pass-h-templates-fix` (commit `fd3ef41`), Pass I scope upcoming.

**Project constants used throughout:**

```powerfx
Set(gblBrandRed,  "#C8102E");                    // Adams Cosby brand red
Set(gblBrandName, "Adams Cosby");
Set(gblReplyTo,   "teamac@alfains.com");         // NOT SC1047
Set(gblTeam, Table(
    { Name: "Alec",          Email: "alec@alfains.com"    },
    { Name: "Rachel Cosby",  Email: "rachel@alfains.com"  },
    { Name: "Jessica Adams", Email: "jessica@alfains.com" },
    { Name: "Tammy Dennis",  Email: "tammy@alfains.com"   },
    { Name: "Leigh Marsh",   Email: "leigh@alfains.com"   }
));
```

**Connector inventory at a glance:**

| # | Connector (Power Fx name) | Canvas app | Power Automate flows | Status in project |
|---|---|---|---|---|
| 1 | `SharePoint` (list as data source) | ✅ Leads, Activities, Tasks | ✅ 3a, 3b, 3c, 3d | **Wired up** |
| 2 | `Office365Outlook` (no `_1`) | ✅ Mail send + calendar dropdown | ✅ 3a, 3b, 3c, 3d (notifications) | **Wired up** |
| 3 | `Office365Users` | ✅ MyProfile, photos, people-pick | ✅ Resolve assignee | **Wired up** |
| 4 | `Planner` | (optional) | ✅ 3a follow-up task | **Wired up** |
| 5 | `MicrosoftForms` | ❌ (not supported in Canvas) | ✅ Inbound web quote → Lead | **Wired up** (flow only) |
| 6 | `MicrosoftTo-Do(Business)` | not yet | not yet | **Available, not yet wired** — full reference included per user request |

---

# Part 1 — Canvas app connectors (Power Fx)

## 1.1 SharePoint (canvas)

**Purpose:** Primary data store for the CRM. The canvas app binds directly to SharePoint lists (Leads, Activities, Tasks, etc.) as data sources — there is **no `SharePoint.ActionName(siteUrl, listName, …)` form in Power Fx**; the list name *is* the table identifier.

**Reference data model — `Leads` list:**

| Column | Type |
|---|---|
| Title | Single line of text |
| FirstName, LastName, Email, Phone | Single line of text |
| Status | Choice (New, Contacted, Qualified, Won, Lost) |
| AssignedTo | Person or Group |
| FollowUpDate | Date and Time |
| Notes | Multi-line text |
| Tags | Choice (multi-select) |
| Created, Modified, ID, Author, Editor | system |

### Read operations

```powerfx
// Single record by predicate
LookUp( Leads, ID = varSelectedLeadId )
LookUp( Leads, Email = txtEmail.Text )
LookUp( Leads, ID = varSelectedLeadId, Email )      // project to single field

// Filtered table
Filter( Leads,
    Status.Value <> "Won" And Status.Value <> "Lost" And
    AssignedTo.Email = User().Email
)

// Today's follow-ups (delegable date comparison via DateValue)
Filter( Leads,
    Status.Value = "Contacted" And
    FollowUpDate >= Today() And
    FollowUpDate <  DateAdd(Today(), 1, Days)
)

// Substring search across columns (non-delegable)
Search( Leads, txtSearch.Text, "Title", "FirstName", "LastName", "Email" )

// Sorting
Sort( Leads, Created, Descending )
SortByColumns( Filter(Leads, Status.Value = "New"), "FollowUpDate", Ascending )

// Local caching
ClearCollect( colOpenLeads, Filter(Leads, Status.Value <> "Won" And Status.Value <> "Lost") )
Refresh( Leads )

// Choice helper for combo boxes
Choices( Leads.Status )                  // returns table of {Value:"..."}
Choices( Activities.LeadLookup )         // for lookup columns
```

### Write operations — `Patch` signatures

```powerfx
// CREATE
Patch( DataSource, Defaults(DataSource), { Field1: value1, ... } )

// UPDATE
Patch( DataSource, RecordToUpdate,       { Field1: newValue, ... } )

// BULK
Patch( DataSource, TableOfBaseRecords, TableOfChangeRecords )
```

**Field-by-field shapes for SharePoint column types:**

```powerfx
// Simple types
Patch(Leads, Defaults(Leads), {
    Title:        txtFirst.Text & " " & txtLast.Text,
    FirstName:    txtFirst.Text,
    Email:        txtEmail.Text,
    FollowUpDate: DatePicker_FollowUp.SelectedDate,
    Notes:        txtNotes.Text
})

// Choice (single)
Patch(Leads, LookUp(Leads, ID = varLeadId), { Status: { Value: "Qualified" } })

// Multi-select Choice — TABLE of records
Patch(Leads, Defaults(Leads), {
    Tags: Table( { Value: "Auto" }, { Value: "Home" } )
    // or: Tags: cmbTags.SelectedItems
})

// Person/Group (single) — full record shape required
Patch(Leads, LookUp(Leads, ID = varLeadId), {
    AssignedTo: {
        '@odata.type': "#Microsoft.Azure.Connectors.SharePoint.SPListExpandedUser",
        Claims:      "i:0#.f|membership|rachel@alfains.com",
        Department:  "",
        DisplayName: "Rachel Cosby",
        Email:       "rachel@alfains.com",
        JobTitle:    "",
        Picture:     ""
    }
})

// Lookup column
{ LeadLookup: {
    '@odata.type': "#Microsoft.Azure.Connectors.SharePoint.SPListExpandedReference",
    Id:    varLeadId,
    Value: LookUp(Leads, ID = varLeadId).Title
} }

// Clear a value
Patch(Leads, LookUp(Leads, ID = varLeadId), { FollowUpDate: Blank() })
```

### Delete / forms / error handling

```powerfx
Remove( Leads, galLeads.Selected )
RemoveIf( Leads, Status.Value = "Lost" And Modified < DateAdd(Today(), -365, Days) )

// Form control approach (builds correct complex shapes automatically)
NewForm(frmLead); EditForm(frmLead); SubmitForm(frmLead); ResetForm(frmLead)

// Recommended error pattern
IfError(
    Patch(Leads, Defaults(Leads), { Title: txtName.Text, Status: {Value:"New"} }),
    Notify("Save failed: " & FirstError.Message, NotificationType.Error)
)
```

**Reading complex columns:** `ThisItem.Status.Value`, `ThisItem.AssignedTo.Email`, `ThisItem.LeadLookup.Id`, `Concat(ThisItem.Tags, Value, ", ")`.

**Delegation cheat-sheet:** `=`, `<>`, `<`, `<=`, `>`, `>=`, `And`, `Or`, `StartsWith` ✅ delegable. `Search`, `in`, `Not`, `IsBlank`, `Sum/Count/Average/Min/Max` ❌ non-delegable (replace `IsBlank(X)` with `X = Blank()`).

---

## 1.2 Office365Outlook (canvas) — **no `_1` suffix**

**Purpose:** Send branded HTML notification emails to the team/customers; read the user's calendar for the booking screen; populate the `dropdownCalendarSelection3` control.

> ⚠️ **Tenant-specific:** In Alec's tenant the connector is bound as **plain `Office365Outlook`**. If `Office365Outlook_1` ever appears, a duplicate connection was added — remove it from **Data**, re-add, and let formulas rebind.

### Mail — Send

```powerfx
Office365Outlook.SendEmailV2(
    To,        // Text — semicolon-separated
    Subject,   // Text
    Body,      // Text (HTML by default)
    {          // optional record
        From:        Text,            // requires Send-As permission
        Cc:          Text,            // ";" separated
        Bcc:         Text,
        ReplyTo:     Text,            // ";" separated — case-sensitive "ReplyTo"
        Importance:  Text,            // "Low" | "Normal" | "High"
        IsHtml:      Boolean,         // default true
        Attachments: Table( { Name: Text, ContentBytes: Binary } ),
        Sensitivity: Text             // Purview label GUID
    }
)
```

**CRM example — new-lead notification to Rachel Cosby with brand HTML:**

```powerfx
Office365Outlook.SendEmailV2(
    "rachel@alfains.com",
    "New Lead Assigned: " & varLead.FullName,
    "<div style=""font-family:Segoe UI,Arial,sans-serif;"">
       <div style=""background:#C8102E;color:#fff;padding:14px 20px;font-size:18px;font-weight:600;"">
         Adams Cosby Insurance Agency
       </div>
       <div style=""padding:20px;color:#222;line-height:1.5;"">
         <h2 style=""color:#C8102E;margin:0 0 12px 0;"">New Lead Assigned</h2>
         <p>Hi Rachel — a new lead has been assigned to you:</p>
         <p><b>Name:</b> " & varLead.FullName & "<br>
            <b>Phone:</b> " & varLead.Phone & "<br>
            <b>Email:</b> " & varLead.Email & "</p>
         <p><a href=""https://crm.adamscosby.com/lead/" & varLead.Id & """
              style=""background:#C8102E;color:#fff;padding:10px 18px;
                     text-decoration:none;border-radius:4px;"">Open Lead</a></p>
       </div>
       <div style=""border-top:3px solid #C8102E;padding:10px 20px;font-size:11px;color:#777;"">
         © Adams Cosby · Reply-To: teamac@alfains.com
       </div>
     </div>",
    {
        Cc:         "teamac@alfains.com",
        ReplyTo:    "teamac@alfains.com",
        Importance: "High",
        IsHtml:     true
    }
)
```

**With attachments:**

```powerfx
Office365Outlook.SendEmailV2(
    cmbRecipient.Selected.Mail, "Your Adams Cosby Quote", rteBody.HtmlText,
    {
        ReplyTo: "teamac@alfains.com",
        Attachments: ForAll(attQuote.Attachments As A,
                            { Name: A.Name, ContentBytes: A.Value })
    }
)
```

**Shared mailbox send (from `teamac@alfains.com`):**

```powerfx
Office365Outlook.SharedMailboxSendEmailV2({
    MailboxAddress: "teamac@alfains.com",
    To:             "lead@example.com",
    Subject:        "Welcome to Adams Cosby",
    Body:           "<p>Brand HTML…</p>",
    Importance:     "Normal"
})
```

### Mail — Read / Reply / Manage

```powerfx
Office365Outlook.GetEmailsV3({
    folderPath: "Inbox", fetchOnlyUnread: true, toOrCc: "teamac@alfains.com",
    subjectFilter: "Lead", top: 50
}).value

Office365Outlook.GetEmailV2(messageId, { mailboxAddress: Text, includeAttachments: Boolean })
Office365Outlook.GetAttachment_V2(messageId, attachmentId, mailboxAddress)
Office365Outlook.ExportEmail_V2(messageId, mailboxAddress)   // returns .eml binary

Office365Outlook.ReplyToV3(messageId,
    { Body: "<p>…HTML…</p>", ReplyAll: false, Importance: "Normal" }, mailboxAddress)

Office365Outlook.ForwardEmail_V2(messageId, mailboxAddress,
    { ToRecipients: "teamac@alfains.com", Comment: "FYI" })

Office365Outlook.Flag_V2(messageId, mailboxAddress, { flag:{ flagStatus:"flagged" } })
Office365Outlook.MarkAsRead_V3(messageId, mailboxAddress, { isRead: true })
Office365Outlook.MoveV2(messageId, folderPath, mailboxAddress)
Office365Outlook.DeleteEmail_V2(messageId, mailboxAddress)
Office365Outlook.GetMailTips_V2({ MailboxAddress: Text, MailTipsOptions: Text })
```

### Calendar — **uses `GetEventsCalendarViewV3` (V2 retired)**

```powerfx
Office365Outlook.CalendarGetTables_V2({skip, top, orderBy}).value
// returns [{ id, name }, ...]

Office365Outlook.GetEventsCalendarViewV3(
    calendarId,         // Text — REQUIRED
    startDateTimeUtc,   // Text — REQUIRED, ISO 8601 UTC: "2026-05-10T00:00:00Z"
    endDateTimeUtc,     // Text — REQUIRED
    {                   // optional
        '$filter':  Text,
        '$orderby': Text,    // e.g. "start/dateTime asc"
        '$top':     Number,
        '$skip':    Number,
        search:     Text     // case-sensitive
    }
).value
```

**Each event row exposes:** `id`, `subject`, `body.{contentType,content}`, `bodyPreview`, `start.{dateTime,timeZone}`, `end`, `organizer`, `attendees`, `location`, `isAllDay`, `isCancelled`, `isOnlineMeeting`, `onlineMeetingUrl`, `showAs`, `importance`, `recurrence`, `webLink`, `createdDateTime`, `lastModifiedDateTime`.

**CRM pattern — `dropdownCalendarSelection3`:**

```powerfx
// Items
Office365Outlook.CalendarGetTables_V2().value
// DisplayFields = ["name"]
// Default = Blank()        ← confirmed pattern: ensures OnChange fires on any pick
// OnChange:
Set(varCalendarId, dropdownCalendarSelection3.Selected.id);
ClearCollect(
    colCalendarView,
    Office365Outlook.GetEventsCalendarViewV3(
        varCalendarId,
        Text(Today(),             "yyyy-mm-ddThh:mm:ss") & "Z",
        Text(DateAdd(Today(),30), "yyyy-mm-ddThh:mm:ss") & "Z",
        { '$orderby': "start/dateTime asc", '$top': 500 }
    ).value
)
```

**Create / update / delete events:**

```powerfx
Office365Outlook.V4CalendarPostItem(
    calendarId, subject,
    startIsoLocal,    // "yyyy-mm-ddThh:mm:ss"
    endIsoLocal,
    timeZone,         // "Eastern Standard Time" | "UTC" | IANA name
    {
        body:                       Text,        // HTML
        location:                   Text,
        requiredAttendees:          Text,        // ";" separated
        optionalAttendees:          Text,
        importance:                 Text,        // Low/Normal/High
        isAllDay:                   Boolean,
        recurrence:                 Text,        // Daily/Weekly/Monthly/Yearly
        recurrenceEnd:              Text,
        numberOfOccurences:         Number,
        reminderMinutesBeforeStart: Number,
        isReminderOn:               Boolean,
        showAs:                     Text,        // free/tentative/busy/oof
        responseRequested:          Boolean,
        sensitivity:                Text
    }
)

Office365Outlook.V4CalendarPatchItem(calendarId, eventId, { ...same fields... })
Office365Outlook.CalendarDeleteItem_V2(calendarId, eventId)
Office365Outlook.RespondToEvent_V2(eventId, "accept|tentativelyAccept|decline",
                                   { Comment: Text, SendResponse: Boolean })

Office365Outlook.FindMeetingTimes_V2({
    RequiredAttendees:          "rachel@alfains.com;jessica@alfains.com",
    OptionalAttendees:          "leigh@alfains.com",
    MeetingDuration:            30,
    Start:                      Text(Today(),"yyyy-mm-dd"),
    End:                        Text(DateAdd(Today(),7),"yyyy-mm-dd"),
    ActivityDomain:             "Work",
    MaxCandidates:              20,
    MinimumAttendeePercentage:  100
})
```

### Contacts

```powerfx
Office365Outlook.ContactGetTablesV2().value
Office365Outlook.ContactGetItemsV2(folder,
    { '$filter': Text, '$orderby': Text, '$top': Number, '$skip': Number }).value
Office365Outlook.ContactPostItem_V2(folder, {
    GivenName, Surname, DisplayName,
    EmailAddresses: Table({ Address, Name }),
    BusinessPhones: Table({ Value }),
    MobilePhone1, CompanyName, JobTitle,
    BusinessAddress: { Street, City, State, PostalCode, CountryOrRegion },
    Categories: ["..."]
})
Office365Outlook.ContactPatchItem_V2(folder, id, { ...fields... })
Office365Outlook.ContactDeleteItem_V2(folder, id)
Office365Outlook.ContactGetItem_V2(folder, id)
```

**Outlook pitfalls:**

1. **No `_1` suffix** — confirmed for this tenant. Duplicate connection causes the suffix.
2. **`GetEventsCalendarViewV2` is retired** — only V3 works.
3. `dropdownCalendarSelection3.Default = Blank()` is required so OnChange fires every pick.
4. Brand red `#C8102E` must be in **inline `style="..."`** (Outlook strips `<style>` blocks).
5. Record-field casing matters: `ReplyTo`, `Cc`, `Bcc` — wrong case silently drops the field.
6. `From` requires Send-As; otherwise use `SharedMailboxSendEmailV2`.
7. Throttle: **300 calls / 60 s per connection** — batch digest sends.

---

## 1.3 Office365Users (canvas)

**Purpose:** Current-user context on app start; people-picker for "Assign to"; profile photos on lead cards; manager lookup for escalation. **No triggers** on this connector.

```powerfx
// Current user
Office365Users.MyProfileV2()                          // returns GraphUser_V1 (camelCase)
Office365Users.MyProfileV2("id,displayName,mail")     // $select projection
Office365Users.MyProfile()                            // V1 (deprecated, PascalCase)

// Another user (by UPN or id)
Office365Users.UserProfileV2(userIdOrUpn [, "$select fields"])

// Manager / direct reports
Office365Users.ManagerV2(userIdOrUpn [, "$select"])
Office365Users.DirectReportsV2(userIdOrUpn [, "$select", topN]).value

// People search (people-picker)
Office365Users.SearchUserV2({
    searchTerm: Text, top: Number, isSearchTermRequired: Boolean
}).value

// Photo + metadata
Office365Users.UserPhotoV2(userIdOrUpn)               // returns image binary
Office365Users.UserPhotoMetadata(userIdOrUpn)         // { HasPhoto, Height, Width, ContentType }

// Trending / relevant people
Office365Users.MyTrendingDocuments({'$filter': Text}).value
Office365Users.TrendingDocuments(userIdOrUpn, {'$filter': Text}).value
Office365Users.RelevantPeople(userIdOrUpn).value

// Self-write (use cautiously — changes the user's M365 profile)
Office365Users.UpdateMyProfile({
    aboutMe, birthday, interests:[], mySite, pastProjects:[], schools:[], skills:[]
})
```

**`GraphUser_V1` fields:** `id`, `displayName`, `givenName`, `surname`, `mail`, `userPrincipalName`, `jobTitle`, `department`, `companyName`, `officeLocation`, `mobilePhone`, `businessPhones[]`, `city`, `state`, `postalCode`, `country`, `streetAddress`, `accountEnabled`, `aboutMe`, `birthday`, `hireDate`, `interests[]`, `pastProjects[]`, `schools[]`, `skills[]`, `responsibilities[]`, `preferredLanguage`, `preferredName`, `mySite`, `userType`.

> ⚠️ V1 returns PascalCase (`.DisplayName`), V2 returns camelCase (`.displayName`). Don't mix.

**CRM recipes:**

```powerfx
// 1. App OnStart
Set(varMe, Office365Users.MyProfileV2());
Set(varMyEmail, Lower(varMe.mail));
Set(varMyManager, Office365Users.ManagerV2(varMe.id));

// 2. Assignee people-picker
ClearCollect(colAssignResults,
    Office365Users.SearchUserV2({searchTerm: txtAssignSearch.Text, top: 10}).value);

// 3. Lead-card avatar — Image.Image property:
Office365Users.UserPhotoV2(galLeads.Selected.AssignedTo.Email)

// 4. Patch SharePoint Person field from picker
Patch(Leads, galLeads.Selected, {
    AssignedTo: {
        '@odata.type': "#Microsoft.Azure.Connectors.SharePoint.SPListExpandedUser",
        Claims:      "i:0#.f|membership|" & galPicker.Selected.mail,
        DisplayName: galPicker.Selected.displayName,
        Email:       galPicker.Selected.mail,
        Department: "", JobTitle: "", Picture: ""
    }
})
```

Throttle: **1000 calls / 60 s**. Connection is per-user, not shareable. `SearchUserV2` returns `403` for guest users.

---

## 1.4 Microsoft To-Do (Business) — canvas

**Status:** Available, not yet wired. Canvas-side identifier is the unusual `'MicrosoftTo-Do(Business)'` (single-quoted, hyphen + parens included). See Part 2 §2.6 for the full action surface; Power Fx mirrors the same operation IDs:

```powerfx
'MicrosoftTo-Do(Business)'.GetAllTodoListsV2()
'MicrosoftTo-Do(Business)'.CreateToDoListV2({displayName: "Adams Cosby CRM"})
'MicrosoftTo-Do(Business)'.CreateToDoV3(folderId, {
    title: "Call John Smith — $250k Term Life Quote",
    dueDateTime:      {dateTime: "2026-05-11T14:00:00"},
    reminderDateTime: {dateTime: "2026-05-11T13:30:00"},
    importance: "high", status: "notStarted", isReminderOn: true,
    content: "<p>Lead source: Web form…</p>"
})
'MicrosoftTo-Do(Business)'.UpdateToDoV2(folderId, taskId, { status: "completed" })
'MicrosoftTo-Do(Business)'.DeleteToDoV2(folderId, taskId)
'MicrosoftTo-Do(Business)'.ListToDosByFolderV2(folderId, {'$top': 100})
```

**Critical limit:** The connector only operates as the **signed-in user** — it cannot create tasks in another team member's To-Do. Use per-user connection references in Power Automate to fan-out.

---

# Part 2 — Power Automate flow connectors

## 2.1 SharePoint (Power Automate)

**Used by:** `flow_3a_NewLead`, `flow_3b_StatusChanged`, `flow_3c_DailyDigest`, `flow_3d_FollowUpReminder`. All actions take `dataset` (Site Address) and `table` (List Name). Site URL placeholder: `https://adamscosby.sharepoint.com/sites/CRM`.

### Triggers

| Display name | Operation ID | Used in |
|---|---|---|
| When an item is created | `OnNewItems` | flow_3a_NewLead |
| When an item is created or modified | `OnNewOrUpdatedItems` | flow_3b_StatusChanged |
| When an item is deleted | `OnItemDeleted` | — (requires SCA conn) |
| When an item or a file is modified | `OnUpdatedItems` | — |
| When a file is created (properties only) | `OnNewFileItem` | — |
| When a file is created or modified (properties only) | `OnUpdatedFileItems` | — |
| When a file is deleted | `OnFileDeleted` | — |
| For a selected item | `ManualForUserSelectedItem` | — |

**Common inputs:** `dataset` (✅), `table` (✅), `view` (optional), `folderPath` (optional).

```jsonc
"When_an_item_is_created": {
  "type": "OpenApiConnectionWebhook",
  "inputs": {
    "host": { "connectionName": "shared_sharepointonline",
              "operationId":    "OnNewItems",
              "apiId":          "/providers/Microsoft.PowerApps/apis/shared_sharepointonline" },
    "parameters": {
      "dataset": "https://adamscosby.sharepoint.com/sites/CRM",
      "table":   "Leads"
    }
  }
}
```

> **`OnItemDeleted` / `OnFileDeleted`** require the connection to be authenticated by a **site collection administrator** to return item properties.
>
> **`OnNewOrUpdatedItems` cannot read the previous value** — to detect "Status changed" either store `PreviousStatus` in a separate column, OR use the `Get changes for an item or a file` (`GetItemChanges`) action between the trigger window tokens (requires list **Versioning ON**).

### Actions — list/item

| Display name | Operation ID |
|---|---|
| Get items | `GetItems` |
| Get item | `GetItem` |
| Create item | `PostItem` |
| Update item | `PatchItem` |
| Delete item | `DeleteItem` |
| Get changes for an item or a file | `GetItemChanges` |
| Resolve person | `SearchForUser` |
| Send an HTTP request to SharePoint | `HttpRequest` |

**`GetItems` parameters:** `dataset` (✅), `table` (✅), `$filter`, `$orderby`, `$top`, `folderPath`, `viewScopeOption` (`recursiveall`/`filesonly`/`itemsonly`), `view`. `$select` is supported by SP OData but **not** exposed in the designer — add via *Add new parameter* or use `HttpRequest`.

**OData column-reference rules (internal names):**

- Choice: `Status/Value eq 'New'`
- Person email: `AssignedTo/EMail eq 'rachel@alfains.com'`
- Person display: `AssignedTo/Title eq 'Rachel Cosby'`
- Lookup: `BrokerLookupId eq 12`
- Date: `FollowUpDate lt '@{addDays(utcNow(),1,''yyyy-MM-ddTHH:mm:ssZ'')}'`
- Boolean: `IsActive eq 1`
- `startswith(LastName,'S')`, `substringof('Smith',LastName)`

**CRM example — `flow_3c_DailyDigest` fetches today's follow-ups:**

```jsonc
"Get_items_-_TodaysFollowUps": {
  "type": "OpenApiConnection",
  "inputs": {
    "host": { "connectionName": "shared_sharepointonline", "operationId": "GetItems" },
    "parameters": {
      "dataset": "https://adamscosby.sharepoint.com/sites/CRM",
      "table":   "Leads",
      "$filter": "Status/Value ne 'Won' and Status/Value ne 'Lost' and FollowUpDate ge '@{startOfDay(utcNow())}' and FollowUpDate lt '@{startOfDay(addDays(utcNow(),1))}'",
      "$orderby": "FollowUpDate asc",
      "$top":     500
    }
  }
}
```

**`PostItem` — body field shapes:**

- Choice: `"Status/Value": "New"`
- Multi-Choice: `"Tags": { "results": ["Auto","Home"] }`
- Person (Claims): `"AssignedTo/Claims": "i:0#.f|membership|rachel@alfains.com"` *(or `AssignedToId` with int user id)*
- Multi-Person: `"AssignedTo": { "Claims": ["i:0#.f|membership|a@x","i:0#.f|membership|b@x"] }`
- Lookup: `"BrokerLookupId": 7`
- Date: `"FollowUpDate": "2026-05-15T14:00:00Z"`

**CRM example — `flow_3a_NewLead` writes the Lead row:**

```jsonc
"Create_item_-_NewLead": {
  "inputs": {
    "host": { "operationId": "PostItem", "connectionName": "shared_sharepointonline" },
    "parameters": {
      "dataset": "https://adamscosby.sharepoint.com/sites/CRM",
      "table":   "Leads",
      "item": {
        "Title": "@{triggerBody()?['FirstName']} @{triggerBody()?['LastName']}",
        "FirstName": "@triggerBody()?['FirstName']",
        "LastName":  "@triggerBody()?['LastName']",
        "Email":     "@triggerBody()?['Email']",
        "Phone":     "@triggerBody()?['Phone']",
        "Status/Value":      "New",
        "AssignedTo/Claims": "i:0#.f|membership|rachel@alfains.com",
        "FollowUpDate":      "@addDays(utcNow(),1,'yyyy-MM-ddTHH:mm:ssZ')",
        "Notes":             "Submitted via website form."
      }
    }
  }
}
```

**`PatchItem`** — same shape; takes `id` (✅, integer) + `item`. Always include `Title` even on partial updates (the generated body schema requires it).

**`HttpRequest` escape hatch (full REST projection):**

```jsonc
"Send_HTTP_-_OpenLeads": {
  "inputs": {
    "host": { "operationId": "HttpRequest", "connectionName": "shared_sharepointonline" },
    "parameters": {
      "dataset": "https://adamscosby.sharepoint.com/sites/CRM",
      "method":  "GET",
      "uri":     "_api/web/lists/getbytitle('Leads')/items?$select=Id,Title,Status,FollowUpDate,AssignedTo/Title,AssignedTo/EMail&$expand=AssignedTo&$filter=Status/Value eq 'New'&$orderby=Created desc&$top=50",
      "headers": { "Accept": "application/json;odata=nometadata" }
    }
  }
}
```

### Actions — files / attachments

| Display name | Operation ID |
|---|---|
| Get file content | `GetFileContent` |
| Get file content using path | `GetFileContentByPath` |
| Get file metadata | `GetFileMetadata` |
| Get file properties | `GetFileItem` |
| Get files (properties only) | `GetFileItems` |
| Create file | `CreateFile` |
| Update file | `UpdateFile` |
| Update file properties | `PatchFileItem` |
| Delete file | `DeleteFile` |
| Copy file | `CopyFileAsync` |
| Move file | `MoveFileAsync` |
| Create new folder | `CreateNewFolder` |
| List folder | `ListFolder` |
| Get attachments | `GetItemAttachments` |
| Get attachment content | `GetAttachmentContent` |
| Add attachment | `CreateAttachment` |
| Delete attachment | `DeleteAttachment` |

```jsonc
"Create_file_-_QuotePDF": {
  "inputs": { "host": { "operationId": "CreateFile" },
    "parameters": {
      "dataset":    "https://adamscosby.sharepoint.com/sites/CRM",
      "folderPath": "/Quotes/@{formatDateTime(utcNow(),'yyyy')}",
      "name":       "Quote_@{outputs('Create_item_-_NewLead')?['body/ID']}.pdf",
      "body":       "@body('Convert_to_PDF')"
    }
  }
}
```

### Flow skeletons (operation-ID level)

```text
flow_3a_NewLead
  └─ OnNewItems (Leads)
  └─ Office365Outlook.SendEmailV2  (notify assignee — brand HTML)
  └─ Planner.CreateTask_V3         (follow-up task, due tomorrow)
  └─ PatchItem                     (set Status=New, FollowUpDate=+1d)

flow_3b_StatusChanged
  └─ OnNewOrUpdatedItems (Leads)
  └─ GetItemChanges (since/until trigger window tokens)
  └─ Condition: @equals(body('GetItemChanges')?['HasColumnsChanged/Status'], true)
        ├─ True  → Office365Outlook.SendEmailV2 + PostItem (Activities log)
        └─ False → Terminate Succeeded

flow_3c_DailyDigest
  └─ Recurrence (daily 07:30 CT)
  └─ GetItems Leads $filter today's FollowUpDate, Status ∉ {Won,Lost}
  └─ Select → HTML table (brand red #C8102E header row)
  └─ SendEmailV2 to all 5 team members, ReplyTo=teamac@alfains.com

flow_3d_FollowUpReminder
  └─ Recurrence (every 30 min)
  └─ GetItems Leads $filter Status='Contacted' and FollowUpDate lt utcNow() and ReminderSent eq 0
  └─ Apply_to_each:
        ├─ SendEmailV2 to AssignedTo (Importance=High)
        └─ PatchItem set ReminderSent=true
```

---

## 2.2 Office 365 Outlook (Power Automate)

**Used by:** all four flows (notification email, digest email, reminder email).

### Triggers

| Display name | Operation ID |
|---|---|
| When a new email arrives (V3) | `OnNewEmailV3` |
| When an email is flagged (V3) | `OnFlaggedEmailV3` |
| When a new email mentioning me arrives (V3) | `OnNewMentionMeEmailV3` |
| When a new email arrives in a shared mailbox (V2) | `SharedMailboxOnNewEmailV2` |
| When a new event is created (V3) | `CalendarGetOnNewItemsV3` |
| When an event is modified (V3) | `CalendarGetOnUpdatedItemsV3` |
| When an event is added, updated or deleted (V3) | `CalendarGetOnChangedItemsV3` |
| When an upcoming event is starting soon (V3) | `OnUpcomingEventsV3` |

**`OnNewEmailV3` inputs:** `folderPath` (string, default `Inbox`), `to`, `cc`, `toOrCc`, `from` (`;`-separated emails), `importance` (Any/Low/Normal/High), `fetchOnlyWithAttachment` (bool), `includeAttachments` (bool), `subjectFilter` (substring).

**`OnUpcomingEventsV3` inputs:** `table` (calendar id, ✅), `lookAheadTimeInMinutes` (int, default 15).

### Actions

| Display name | Operation ID |
|---|---|
| Send an email (V2) | `SendEmailV2` |
| Send an email from a shared mailbox (V2) | `SharedMailboxSendEmailV2` |
| Reply to email (V3) | `ReplyToV3` |
| Forward an email (V2) | `ForwardEmail_V2` |
| Get emails (V3) | `GetEmailsV3` |
| Get email (V2) | `GetEmailV2` |
| Get attachment (V2) | `GetAttachment_V2` |
| Export email (V2) | `ExportEmail_V2` |
| Flag email (V2) | `Flag_V2` |
| Mark as read or unread (V3) | `MarkAsRead_V3` |
| Move email (V2) | `MoveV2` |
| Delete email (V2) | `DeleteEmail_V2` |
| Get mail tips (V2) | `GetMailTips_V2` |
| Get calendars (V2) | `CalendarGetTables_V2` |
| Get events (V4) | `V4CalendarGetItems` |
| Get calendar view of events (V3) | `GetEventsCalendarViewV3` |
| Create event (V4) | `V4CalendarPostItem` |
| Update event (V4) | `V4CalendarPatchItem` |
| Delete event (V2) | `CalendarDeleteItem_V2` |
| Respond to event (V2) | `RespondToEvent_V2` |
| Find meeting times (V2) | `FindMeetingTimes_V2` |
| Contacts: get folders / items / post / patch / delete | `GetContactFoldersV2` / `ContactGetItemsV2` / `ContactPostItem_V2` / `ContactPatchItem_V2` / `ContactDeleteItem_V2` |

**`SendEmailV2` inputs:** `To` (✅), `Subject` (✅), `Body` (✅ html), `From`, `Cc`, `Bcc`, `ReplyTo`, `Importance` (Low/Normal/High), `Attachments` (`[{Name, ContentBytes}]`), `IsHtml`, `Sensitivity`.

**`ReplyToV3` inputs:** `messageId` (✅), then body record `{ Body (html), Subject, To, Cc, Bcc, ReplyAll, Attachments, Importance }`, plus optional `mailboxAddress`.

> **Throttling:** 300 API calls / 60 s / connection — batch the digest.

---

## 2.3 Planner

**Used by:** `flow_3a_NewLead` (create follow-up task).

**Hard limit:** Basic plans only (no Premium/Project). Throttle: 100 / 60 s.

### Triggers (current GA)

| Display name | Operation ID | Required inputs |
|---|---|---|
| When a new task is created | `OnNewTask_V3` | `groupId`, `id` (Plan Id) |
| When a task is assigned to me | `OnTaskAssignedToMe_V2` | *(none)* |
| When a task is completed | `OnCompleteTask_V3` | `groupId`, `id` (Plan Id) |

### Actions (current GA)

| Display name | Operation ID |
|---|---|
| Create a task | `CreateTask_V3` (V4 Preview adds `priority`) |
| Update a task | `UpdateTask_V2` (V3 Preview adds `bucketId`, categories) |
| Update task details | `UpdateTaskDetails_V2` |
| Get a task | `GetTask_V2` |
| Get task details | `GetTaskDetails_V2` |
| List my tasks | `ListMyTasks_V2` |
| List tasks (in a plan) | `ListTasks_V3` |
| List buckets in a plan | `ListBuckets_V3` |
| List plans for a group | `ListGroupPlans` |
| Create a bucket | `CreateBucket_V2` |
| Add / remove assignees | `AssignUsers` / `UnassignUsers` |
| Delete a task (Preview) | `DeleteTask` |
| Get plan details (Preview) | `GetPlanDetails` |

**`CreateTask_V3` parameters:**

| Key | Required | Type | Description |
|---|---|---|---|
| `groupId` | ✅ | string | M365 Group that owns the plan |
| `planId` | ✅ | string | |
| `title` | ✅ | string | ≤255 chars |
| `bucketId` | | string | |
| `startDateTime` | | date-time | ISO 8601 |
| `dueDateTime` | | date-time | |
| `assignments` | | string | **`;`-separated** AAD object IDs or emails |
| `category1` … `category25` | | boolean | Label colors |

```jsonc
"Create_a_task": {
  "type": "OpenApiConnection",
  "inputs": {
    "host": { "connectionName": "shared_planner", "operationId": "CreateTask_V3" },
    "parameters": {
      "groupId":  "b1f8a4e6-1234-5678-90ab-cdef01234567",
      "planId":   "PLAN_ID_AdamsCosby_Leads",
      "title":    "@{concat('Follow up with new lead - ', triggerBody()?['FirstName'], ' ', triggerBody()?['LastName'])}",
      "bucketId": "BUCKET_ID_NewLeads",
      "startDateTime": "@{utcNow()}",
      "dueDateTime":   "@{addDays(utcNow(), 1)}",
      "assignments":   "rachel@alfains.com",
      "category2":     true
    }
  }
}
```

**Canvas Power Fx equivalent:**

```powerfx
Planner.CreateTaskV3(
    "b1f8a4e6-1234-5678-90ab-cdef01234567",                          // groupId
    "PLAN_ID_AdamsCosby_Leads",                                       // planId
    "Follow up with new lead - " & txtFirstName.Text & " " & txtLastName.Text,
    {
        bucketId:      "BUCKET_ID_NewLeads",
        startDateTime: Now(),
        dueDateTime:   DateAdd(Today(), 1, Days),
        assignments:   "rachel@alfains.com",
        category2:     true                  // Red label = brand #C8102E cue
    }
)
```

**Mark complete / reopen** (no dedicated action):

```jsonc
"parameters": { "id": "@{outputs('Create_a_task')?['body/id']}", "percentComplete": "100" }
```

**Missing capabilities (not native to Planner connector):**

- "List tasks in a bucket" — use `ListTasks_V3` then `Filter array` on `bucketId`.
- "List plan members" — use **Office 365 Groups** connector `ListGroupMembers` with same `groupId`.

**Response schema highlights (`GetTask_Response_V2`):** `id`, `planId`, `bucketId`, `title`, `percentComplete`, `startDateTime`, `dueDateTime`, `completedDateTime`, `createdBy.user.{id,displayName}`, `_assignments[].userId`, `appliedCategories.category1..25`.

---

## 2.4 Microsoft Forms

**Used by:** Inbound "Request a Quote" web form → Leads list bridge flow.

**Canvas availability:** ❌ Not supported in Power Apps — Forms is a Power Automate / Logic Apps / Copilot Studio connector only. Surface form data into the canvas app via the SharePoint `Leads` list once Power Automate has written it.

**Auth:** Organizational accounts only. Throttle: 300 / 60 s.

### The canonical 2-step pattern

```text
[Trigger]  CreateFormWebhook                   → outputs body/resourceData/responseId
[Action]   GetFormResponseById (form_id, response_id)   → dynamic schema of answers
[Action]   SharePoint PostItem (Leads list)
[Action]   Planner CreateTask_V3
```

### Trigger — `CreateFormWebhook`

**Display name:** When a new response is submitted
**Input:** `form_id` (✅, string — the substring after `FormId=` on the form edit URL)
**Output body:**

```json
{ "value": [ { "resourceData": { "responseId": <integer> } } ] }
```

```jsonc
"When_a_new_response_is_submitted": {
  "type": "OpenApiConnectionWebhook",
  "inputs": {
    "host": { "connectionName": "shared_microsoftforms", "operationId": "CreateFormWebhook" },
    "parameters": { "form_id": "AbCdEf12345-RequestAQuote-AdamsCosby" }
  }
}
```

> Group forms don't appear in the dropdown — paste the Form Id manually.

### Action — `GetFormResponseById`

**Display name:** Get response details
**Inputs:** `form_id` (✅), `response_id` (✅).
**Output:** **dynamic** — each property keyed by Forms internal question id (e.g. `r1234567abc`); multi-select returns JSON-stringified array; system fields `responder` and `submitDate` are always present.

```jsonc
"Get_response_details": {
  "type": "OpenApiConnection",
  "inputs": {
    "host": { "connectionName": "shared_microsoftforms", "operationId": "GetFormResponseById" },
    "parameters": {
      "form_id":     "AbCdEf12345-RequestAQuote-AdamsCosby",
      "response_id": "@{triggerOutputs()?['body/resourceData/responseId']}"
    }
  },
  "runAfter": { "When_a_new_response_is_submitted": [ "Succeeded" ] }
}
```

**Referencing answer fields downstream:**

```text
@{outputs('Get_response_details')?['body/r1234567abc']}   // First Name
@{outputs('Get_response_details')?['body/rabcdef98765']}  // Last Name
@{outputs('Get_response_details')?['body/rfedcba00001']}  // Email
@{outputs('Get_response_details')?['body/r9999zzzz888']}  // Coverage Type
@{outputs('Get_response_details')?['body/responder']}     // Submitter email
@{outputs('Get_response_details')?['body/submitDate']}    // Submission timestamp
```

**Other action:** `GetFormDetailsById` (form_id) → `{ title, modifiedDate, createdDate, status, createdBy }`.

---

## 2.5 Office 365 Users (Power Automate)

Mirrors the canvas surface. **No triggers.** Throttle 1000 / 60 s.

| Display name | Operation ID |
|---|---|
| Get my profile (V2) | `MyProfile_V2` |
| Get user profile (V2) | `UserProfile_V2` |
| Get manager (V2) | `Manager_V2` |
| Get direct reports (V2) | `DirectReports_V2` |
| Search for users (V2) | `SearchUserV2` |
| Get user photo (V2) | `UserPhoto_V2` |
| Get user photo metadata | `UserPhotoMetadata` |
| Get my trending documents / Get trending documents | `MyTrendingDocuments` / `TrendingDocuments` |
| Get relevant people | `RelevantPeople` |
| Update my profile / Update my profile photo | `UpdateMyProfile` / `UpdateMyPhoto` |
| Send an HTTP request (Graph passthrough, scoped) | `HttpRequest` |

`UserProfile_V2` input: `id` (✅, UPN or AAD id), `$select` (optional). Returns `GraphUser_V1`.

---

## 2.6 Microsoft To-Do (Business) — **available, not yet wired**

**Purpose (planned):** Per-agent personal follow-up tasks on lead events. Per-user connections required — the connector cannot impersonate other users. Throttle 100 / 60 s; trigger poll 120 s. Not available in GCC High / DoD / China.

### Triggers (current V2; V1 deprecated)

| Display name | Operation ID |
|---|---|
| When a new to-do in a specific folder is created (V2) | `OnNewToDoInFolderV2` |
| When a to-do in a specific folder is updated (V2) | `OnUpdateToDoInFolderV2` |

Each takes `folderId` (✅). Output is `ToDo_V2`.

> **Not exposed by the connector** (despite being in Graph): "When a task is completed", "When a new list is created", "Mark as completed" action, linked resources, checklist items. Workarounds: use `OnUpdateToDoInFolderV2` + `status=='completed'` condition; for checklist items / linkedResources use the **HTTP with Microsoft Entra ID** connector against `https://graph.microsoft.com/v1.0/me/todo/lists/{listId}/tasks/{taskId}/checklistItems`.

### Actions (current V2/V3; V1 deprecated)

| Display name | Operation ID |
|---|---|
| Add a to-do (V3) | `CreateToDoV3` |
| Get a to-do (V3) | `GetToDoV3` |
| Update to-do (V2) | `UpdateToDoV2` |
| Delete to-do (V2) | `DeleteToDoV2` |
| List to-do's by folder (V2) | `ListToDosByFolderV2` |
| List all to-do lists (V2) | `GetAllTodoListsV2` |
| Get a to-do list (V2) | `GetToDoListV2` |
| Create a to-do list (V2) | `CreateToDoListV2` |
| Update a to-do list | `UpdateToDoList` |
| Delete a to-do list | `DeleteToDoList` |

**`CreateToDoV3` parameters:**

| Key | Required | Type | Notes |
|---|---|---|---|
| `folderId` | ✅ | string | Task list id |
| `title` | ✅ | string | |
| `dueDateTime` | | date-time (ISO local) | server stores UTC |
| `reminderDateTime` | | date-time | |
| `importance` | | string | `low` / `normal` / `high` |
| `status` | | string | `notStarted`/`inProgress`/`completed`/`waitingOnOthers`/`deferred` |
| `content` | | html | body |
| `isReminderOn` | | boolean | |

```jsonc
"Create_personal_followup": {
  "type": "OpenApiConnection",
  "inputs": {
    "host": { "connectionName": "shared_todo", "operationId": "CreateToDoV3" },
    "parameters": {
      "folderId":         "@{first(body('Get_lists')?['value'])?['id']}",
      "title":            "Call John Smith - $250k Term Life Quote",
      "dueDateTime":      "2026-05-11T14:00:00",
      "reminderDateTime": "2026-05-11T13:30:00",
      "importance":       "high",
      "status":           "notStarted",
      "isReminderOn":     true,
      "content":          "<p>Lead source: Web form. Quoted $250k 20-yr term.</p>"
    }
  }
}
```

**"Mark complete" workaround** — `UpdateToDoV2` with `{"status":"completed"}`.

### Graph `dateTimeTimeZone` shape (when calling Graph directly for richer fields)

```json
{
  "title": "Call John Smith — $250k Term Life Quote",
  "importance": "high",
  "isReminderOn": true,
  "dueDateTime":      { "dateTime": "2026-05-11T10:00:00", "timeZone": "Eastern Standard Time" },
  "reminderDateTime": { "dateTime": "2026-05-11T09:30:00", "timeZone": "Eastern Standard Time" },
  "body": { "content": "Lead from web form.", "contentType": "html" }
}
```

Valid `timeZone` values: `UTC`, `Eastern Standard Time`, `Central Standard Time`, IANA names like `America/New_York`.

### `TodoList_V2` and `ToDo_V2` shapes

**`TodoList_V2`:** `id`, `displayName`, `wellknownListName` (`none`/`defaultList`/`flaggedEmails`), `isOwner`, `isShared`.

**`ToDo_V2`:** `id`, `title`, `status`, `importance`, `isReminderOn`, `body.{contentType,content}`, `bodyLastModifiedDateTime`, `createdDateTime`, `lastModifiedDateTime`, `dueDateTime.dateTime`, `reminderDateTime.dateTime`, `completedDateTime.dateTime`.

### Planned CRM recipes (when wired)

```text
[High-priority lead → personal To-Do]
1. SharePoint OnNewOrUpdatedItems on Leads
2. Condition: Priority/Value == 'High'
3. GetAllTodoListsV2 (under assigned agent's connection ref)
4. Filter array → list where displayName == 'CRM Follow-ups'
5. CreateToDoV3 (title, due tomorrow, importance=high, reminder on)
6. PatchItem Leads → store body('CreateToDoV3')?['id'] in ToDoTaskId column

[Close-the-loop: completed To-Do → Lead status update]
1. OnUpdateToDoInFolderV2 on agent's CRM list
2. Condition: status == 'completed'
3. GetItems Leads where ToDoTaskId eq triggerBody()?['id']
4. PatchItem → Status='Contacted', LastContacted=utcNow()
```

---

# Part 3 — Conventions, deprecations, and pitfalls

## 3.1 "Wired up now" vs "available but unused"

| Capability | Status |
|---|---|
| SharePoint list CRUD from canvas + flows | **Wired up** |
| `OnNewItems` / `OnNewOrUpdatedItems` triggers on Leads | **Wired up** |
| Office 365 Outlook `SendEmailV2` w/ ReplyTo=`teamac@alfains.com`, brand `#C8102E` | **Wired up** |
| Office 365 Outlook `GetEventsCalendarViewV3` + `dropdownCalendarSelection3` | **Wired up** (V2 retired) |
| Office 365 Users `MyProfileV2`, `SearchUserV2`, `UserPhotoV2` | **Wired up** |
| Planner `CreateTask_V3` for new-lead follow-ups | **Wired up** |
| Microsoft Forms `CreateFormWebhook` + `GetFormResponseById` → Leads list | **Wired up** (flow only — no Canvas support) |
| Microsoft To-Do (Business) — full surface | **Available, not yet wired** |
| Office 365 Outlook calendar **create/update/delete events** (`V4CalendarPostItem`, etc.) | Available, not yet wired |
| Office 365 Outlook `OnUpcomingEventsV3` pre-meeting briefing | Available, not yet wired |
| SharePoint `HttpRequest` for deep `$select` projections | Available, not yet wired |

## 3.2 Version currency (always prefer current GA)

| Connector — capability | Current GA | Avoid |
|---|---|---|
| Outlook send | `SendEmailV2` | `SendEmail`, `SendHtmlEmail` |
| Outlook calendar view | `GetEventsCalendarViewV3` | `GetEventsCalendarViewV2` (retired) |
| Outlook create event | `V4CalendarPostItem` | V1–V3 |
| Outlook get email/reply/flag | `GetEmailV2` / `ReplyToV3` / `Flag_V2` / `MarkAsRead_V3` | V1 |
| Office 365 Users | `*_V2` (camelCase output) | V1 (PascalCase) |
| Planner create task | `CreateTask_V3` (V4 Preview adds `priority`) | `CreateTask_V2`, `CreateTask` |
| Planner update task | `UpdateTask_V2` (V3 Preview adds bucket/categories) | `UpdateTask` |
| Planner list tasks/buckets | `ListTasks_V3` / `ListBuckets_V3` | V2, V1 |
| Forms trigger | `CreateFormWebhook` (webhook) | `GetFormResponses` (polling) |
| To-Do add/get/update | `CreateToDoV3` / `GetToDoV3` / `UpdateToDoV2` | V1 |

## 3.3 Tenant-specific and project-specific notes

1. **`Office365Outlook`** — no `_1` suffix in this tenant. If formulas show `Office365Outlook_1`, delete the duplicate connection and re-add.
2. **`dropdownCalendarSelection3.Default = Blank()`** — required so OnChange fires on every pick (otherwise Default re-binds and suppresses the event when the user re-selects the same calendar).
3. **Reply-To** on all customer mail: `teamac@alfains.com` (not SC1047). Case-sensitive `ReplyTo`.
4. **Brand red `#C8102E`** must live in **inline `style="..."`** attributes — Outlook strips `<style>` blocks.
5. **`From` field** on `SendEmailV2` requires Send-As permission on the mailbox; for `teamac@alfains.com` send-as scenarios prefer `SharedMailboxSendEmailV2`.
6. **SharePoint `OnNewOrUpdatedItems`** has no built-in previous-value comparison — store `PreviousStatus` in a column or use `GetItemChanges` against the trigger window tokens (`x-ms-workflow-triggerwindowstarttoken` / `…endtoken`). Requires list **Versioning ON**.
7. **`OnItemDeleted` / `OnFileDeleted`** require a **site collection administrator** connection to return item properties — otherwise only `ID` is returned.
8. **SharePoint delegation:** `=`, `<>`, `<`, `<=`, `>`, `>=`, `And`, `Or`, `StartsWith` delegable. Replace `IsBlank(X)` with `X = Blank()` to stay delegable.
9. **Planner labels** are a fixed palette of 25 colors. Use `category2: true` (Red) as the brand-red cue — Planner cannot accept arbitrary hex.
10. **Microsoft Forms is Power Automate-only.** Canvas reads form data indirectly via the SharePoint Leads list.
11. **Microsoft To-Do (Business)** cannot create tasks in another user's To-Do. Use per-user connection references or a child flow with "Run only users" permissions.
12. **Throttles to mind for digest/reminder fan-out:** Outlook 300/60s, Forms 300/60s, Office 365 Users 1000/60s, Planner 100/60s, To-Do 100/60s.

## 3.4 Conclusion

The Adams Cosby CRM rides on a tight 5-connector spine — **SharePoint** for state, **Office 365 Outlook** for branded customer/team communication and the calendar view, **Office 365 Users** for identity/photos, **Planner** for shared follow-up tasks, and **Microsoft Forms** for inbound web leads. All five are pinned to current GA versions (V2/V3/V4 where applicable), with `GetEventsCalendarViewV3` and `CreateTask_V3` being the two most version-sensitive choices. **Microsoft To-Do (Business)** is fully documented here and ready to drop into Pass I as the per-agent personal follow-up layer once each team member's connection reference is provisioned — the chief design constraint being that To-Do tasks are always created in the *connection owner's* mailbox, so fan-out flows must run under per-user identities. Use this document as the canonical lookup whenever a new flow, button, or screen needs to call into Microsoft 365 from the CRM.
