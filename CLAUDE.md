# Adams Cosby CRM — Project Context

## Working state
- Folder: C:\Users\alec\Desktop\MSAPP\ADAMSCOSBY_CLEAN
- Source format: .fx.yaml v0.24 (deprecated `pac canvas unpack`)
- Original .msapp: C:\Users\alec\AdamsCosbyCRM.msapp
- Last working .msapp: C:\Users\alec\Desktop\MSAPP\listscreen_pill_test.msapp

## Pack/test command
pac canvas pack --sources "C:\Users\alec\Desktop\MSAPP\ADAMSCOSBY_CLEAN" --msapp "C:\Users\alec\Desktop\MSAPP\test.msapp"

Expected: source format version: 0.24, only PA2001 checksum warning.
ANY "Error PA####" line = revert immediately.

## Two-screen architecture (do not break)
- LeadsScreen.fx.yaml (672 KB) = auto-generated Home Quotes detail form. Working. DO NOT EDIT.
- LeadsListScreen.fx.yaml = dashboard, bound to Leads SharePoint list. THIS is the build target.
- SettingsScreen.fx.yaml = empty placeholder.

## Working pattern (proven across 7 pack cycles)
1. Discovery first — read files, no edits, report findings
2. ONE additive edit per pack cycle
3. Pack immediately after each save
4. On any pack error: revert to last-good state, report error verbatim, do not retry without instruction
5. Use existing-file patterns as syntax reference, never invent

## v0.24 YAML rules (LEARNED THE HARD WAY)
- Top-level: "Name As Type:" syntax (NOT ComponentDefinitions:/Screens:)
- Indent: 4 spaces per level
- All values =-prefixed even literal numbers (=68, =0, =true)
- Multi-line OnStart: `OnStart: |` header with leading `=` on first content line
- NEVER use `|=` for multi-line (that's same-line shortcut, single-line only)
- No blank lines inside `|` block scalars (PA3003)
- Statements ;-chained, no separators
- Schema URL https://go.microsoft.com/fwlink/?linkid=2304907 in headers (v3.0 schema, but emission is v0.24 — different)

## Control naming rules
- Names are GLOBALLY unique across entire app (NOT per-screen)
- LeadsScreen owns: HeaderBar, HeaderTitle, ScreenLayout, BodyContainer1, NewRecordAddIcon1, NewRecordLabel1, SearchBox, EditIcon, DeleteIcon, LeadsGallery, Title1, Subtitle1, Body1, NextArrow1, Separator1, Rectangle1, plus ~200 form data cards
- Naming convention for new controls: prefix with screen role (Dashboard*, Settings*, etc.)
- PA3008 = symbol collision. Error reports the location of the new conflict; pre-existing definition is NOT named in the error — grep the workspace.

## Theme variables (in App.fx.yaml OnStart, single-line `=` form)
BrandRed, BrandRedDark, BrandSoft, BgCream, BgCream2, TextPrimary, TextSecondary, BorderSoft,
StatusActive, StatusWorking, StatusBound, StatusLost, AgentAlec, AgentRachel, AgentJM,
CurrentAgent, SharedInbox, SharedInboxAlias

Note: AgentJM still defined despite Jessica not being an agent. Cosmetic; clean up later.

## SharePoint Leads list (Items: =Leads in galleries)
Internal field names that matter:
- Title (display: Name)
- Phone_x0020_Number (note _x0020_ for space)
- Email
- Status (Choice — use Status.Value)
- Agent (Person/Group — use Agent.DisplayName, Agent.Email, Agent.Picture)
- Source, SourceDetail (Choice/MultiChoice)
- Products (MultiChoice)
- Notes, Risk_x0020_Address, CurrentCarriers, etc.
- 6 fake test rows present (Agent values cleared during Choice→Person/Group conversion)

## Other SharePoint lists wired (11 total in app)
Production: Home Quotes (76 fields), Leads, Quote Documents (5 PDFs), Audit Log (kept for compliance)
Created May 2: Activities, Email Templates (7 seeded rows), Calendar Events
Extras kept: Document Library, Documents, Rotation Intake, Rotation Log

## Email Templates encoding gotcha
SharePoint Enhanced Rich Text strips `<<>>` as malformed HTML.
Body field stores `&lt;&lt;Token&gt;&gt;` wrapped in `<div>` tags.
Power Apps merge function must Substitute() BOTH encoded and plain forms.
Outlook send: use IsHtml: true so <div> tags render as line breaks.

## Tokens used
<<FirstName>>, <<LastName>>, <<AgentName>>, <<AgentPhone>>, <<AgentEmail>>,
<<AgencyPhone>>, <<QuotePremium>>

## Build status (as of last session)
- Phase 2: Fill = BgCream on LeadsListScreen ✅
- Phase 3a: DashboardHeader red label ✅
- Phase 3b: DashboardCardActive ✅
- Phase 3c: Working / Bound / Lost stat cards ✅
- Phase 3d: DashboardLeadsGallery (Items: =Leads, name + status text) ✅
- Phase 3e: DashboardLeadStatusPill + label with Switch() over Status.Value ✅
- Phase 3f: App.StartScreen = LeadsListScreen ⏸ pending
- Phase 3g: Gallery OnSelect → Navigate to LeadsScreen ⏸ queued

## What NEVER to touch
- /Other/Src/* — sidecar editor metadata
- /Entropy/* — auto-regenerated
- /Src/EditorState/* — auto-regenerated
- *.json sidecars next to *.fx.yaml in /Src/Components — auto-regenerated
- LeadsScreen.fx.yaml — working Home Quotes form, do not modify
- The 5 cmp* component shells in /Src/Components — not instantiated, polishing them produces nothing visible

## Walls hit (don't retry)
- HTML hosting in SharePoint blocked by Intune Conditional Access
- Vibe (image-to-app) blocked — no Copilot license on tenant
- Graph Explorer admin consent — tenant policy blocks third-party app consent
- SPFx web parts — need tenant admin to upload .sppkg
- v3.0 ComponentDefinitions: schema — wrong format for this project (v0.24 only)

## Walls cleared
- SharePoint REST API via cookie auth (works for read AND write, including bulk seed of 7 Email Templates rows)
- Power Apps Studio web sign-in
- Power Apps Plan Designer (no Copilot needed)
- pac CLI from personal computer — auth confirmed working
- VS Code with code on PATH (after restart)
- Claude Code extension in VS Code

## Team mapping
- Alec Adams (abadams@alfains.com) — licensed agent, owner
- Rachel Cosby (rcosby@alfains.com) — licensed agent
- Jessica Adams (jmadams@alfains.com) — input/support, not licensed
- Tammy Dennis (tdennis@alfains.com) — input/support
- Leigh Marsh (lmarsh@alfains.com) — input/support

## Next moves (queued)
1. Phase 3f: set App.StartScreen
2. Phase 3g: gallery OnSelect navigation to LeadsScreen
3. Import .msapp back to Studio, see live preview
4. Decide: keep polishing in YAML, or do remaining work in Studio
5. Phase 4: lead → "Quote this lead" creates pre-filled Home Quote
6. Power Automate flow stubs (NewLead, StatusChanged, DailyDigest, BoundCelebration)
7. Exchange permissions ticket (Send-As + Full Access for 3 agents on teamac@/SC1047@ mailboxes)