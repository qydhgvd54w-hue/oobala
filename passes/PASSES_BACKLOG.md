# Adams Cosby Dashboard — Passes Backlog

Cosmetic issues, side effects, deferred polish, and "would-fix-with-more-scope"
notes from prior passes. Each item lists which pass surfaced it.

---

## From Pass G (dashboard_passG.msapp, 2026-05-04)

- **Phase 3 (MarkBound IfError cleanup) DEFERRED.** The current
  DashboardDrawerMarkBoundButton OnSelect has extra logic beyond the
  spec's expected 2-Patch IfError pattern: it also runs `Set(varSelectedLead,
  LookUp(Leads, ID = varSelectedLead.ID))` to refresh the local var
  after Patch. Per spec ("STOP and report. Don't guess"), I left it
  alone. Cleanup TBD: drop the IfError fallback, keep the refresh Set,
  upgrade Activity log per spec text. ~3 lines.

- **Email Templates `IsActive` column showed up in refreshed cache.**
  Could re-enable the IsActive filter dropped in Pass A (Filter('Email
  Templates', IsActive=true && ...)). Noted; not applied this pass to
  avoid scope creep.

- **Calendar Events EventDate is display-name-only.** Internal column
  name is `Start`. All Pass G Phase 1 formulas use ThisItem.Start
  (correct internal name). If Alec ever renames in SP to make internal
  match display, formulas would need updating to ThisItem.EventDate.

- **`User().Email in Concat(AssignedAgents, Email, ";")` filter pattern.**
  pac packed clean. Studio runtime not yet verified. If filter returns
  empty for Alec (unexpected), check that AssignedAgents Email column
  is populated and User().Email matches Alec's logged-in identity.

- **DashboardDrawerOpenDetailButton + NewQuoteButton both Launch
  the same SP NewForm URL.** Both now show "Open in SharePoint" /
  "+ New Quote" but do the same thing. Once Phase 4-style differentiation
  is needed (e.g., NewQuote pre-fills more fields), they'll diverge.

- **SettingsScreen has Set* prefix.** 5 unique screen prefixes now
  (Sidebar/Tpl/Act/Cal/Set). Inconsistent but each globally unique.
  Major rename pass would standardize all to one convention.

- **Templates gallery row: TemplateRowSubject control deleted entirely.**
  Subject text no longer shown in the drawer's send-template list.
  TemplatesScreen's list still shows Subject in its row template (only
  the drawer was simplified). Reasonable — drawer is small (348 wide);
  Templates screen is full-screen.

## From Pass F (dashboard_passF.msapp, 2026-05-04)

- **Phase 1 (CalendarScreen real wiring) DEFERRED to Pass F.1.** Calendar
  Events.json schema cache is stale — only Title/Start/End present, missing
  EventDate/EventType/Lead/Agent/EventLocation that Alec added in SP. Needs
  Studio round-trip (open .msapp → Data → 'Calendar Events' → Refresh →
  Save → re-export).

- **Overflow.Hidden applied to TemplateRowTitle and TemplateRowSubject.**
  pac packed clean. Studio runtime not yet verified — if rejected, drop
  the property; the Height/Y bumps alone may suffice for the visual fix.

- **Email Templates Body field with `<<Token>>` placeholders** — when
  rendered as Text in the gallery row (TemplateRowSubject shows Subject,
  not Body), no token-substitution issue. Will matter for actual send
  wiring in Phase E follow-up.

- **DashboardLeadStatusPill Fill** now nests If(IsBlank, fallback, Switch).
  Power Apps allows If wrapping Switch but the IDE YAML extension treats
  it as a "compact mapping" false-positive. pac is the source of truth.

- **DashboardEmptyState Width** absolute 1380 — won't auto-track if
  gallery widens further. Could swap to =DashboardLeadsGallery.Width
  for safety. Cosmetic.

- **Gallery row data fallbacks** make blank-data rows readable instead
  of empty-cell. "(no phone)" / "(no email)" / "—" fallbacks. The pill
  IsBlank case uses a hardcoded gray RGBA(229,229,229,1) — could
  introduce a `BgEmpty` palette var alongside the others for consistency.

## From Pass E (dashboard_passE.msapp, 2026-05-04)

- **CalendarScreen is placeholder-only.** Calendar Events SP list lacks
  EventDate, EventType, LeadRef, Agent columns (only has Title, Start, End).
  CalendarScreen renders a centered "set up pending" message. Real grid
  view (week-grid showing re-quote events) blocked on:
    1. Add EventDate column to SharePoint Calendar Events list
    2. Add EventType (Choice: Re-Quote / Follow-Up / Renewal / Other)
    3. Add LeadRef (Lookup to Leads)
    4. Add Agent (Person/Group)
    5. Wire Flow 3b (LeadStatusChanged → create Calendar Event for re-quote)
    6. Refresh data sources in Studio
    7. Build week-grid layout in CalendarScreen.fx.yaml
  ALTERNATIVE: use existing Start column instead of EventDate. Items=Filter('Calendar Events', Start >= Today()). Cleaner if Alec doesn't want to rename.

- **ActivitiesScreen Lead lookup display via ThisItem.Lead.Value.** Power Apps
  resolves lookup display through .Value reference; if SharePoint changes the
  lookup column type or target list, this breaks silently (renders blank).

- **ActivitiesScreen ActivityType uses ThisItem.ActivityType.Value** since
  Activities.json registered ActivityType as a Choice column. The Switch
  in ActRowIcon ("Phone Call" / "Text" / etc.) needs to match the actual
  Choice values — verify in Studio against the Choice column options.

- **ActivitiesScreen has no row OnSelect → varSelectedLead navigation.**
  Clicking an activity row currently does nothing. Could wire to:
    Set(varSelectedLead, LookUp(Leads, ID = ThisItem.Lead.Id)); Navigate(LeadsListScreen)
  to jump back to dashboard with that lead selected. Future polish.

- **Drawer middle column 400-wide may overlap right column at X=992.**
  Middle ends at 572+400=972. Right starts at 992. 20px gap. Quick-log labels
  span 582 to 998 (Note button at X=918+W=80=998), which extends 6px PAST the
  middle column right edge AND 6px INTO the right column zone. Since they're
  transparent labels (no Fill), visual overlap is invisible until hover
  (HoverFill BrandSoft would render slightly into the right col).

- **DashboardLeadDrawerType new Alfa-prefix formula** consistency with
  the gallery DashboardLeadType. Studio test: select a lead with Products
  containing both "Auto" and "Home" → drawer should show "Type: Alfa Home + Auto",
  gallery row should also show "Alfa Home + Auto".

## From Pass D (dashboard_passD.msapp, 2026-05-04)

- **Cursor: =Cursor.Hand applied via multi-line replace_all on `Width: =200\n        X: =0`.**
  Hits 22 controls per LeadsListScreen including SidebarBackground and SidebarLogoLabel
  (non-clickable, spec said skip). Visual: hand cursor when hovering over those two
  decorative elements. Harmless but inconsistent. Either remove Cursor explicitly
  on those two, or leave as-is.

- **`in` operator in DashboardLeadType Switch.** Used per spec
  (`"Auto" in p And "Home" in p, "Alfa Home + Auto", ...`). pac packed clean.
  Studio runtime not yet verified — if rejected, swap to `Find("Auto", p) > 0`
  pattern.

- **Pass C `DashboardLastActivity` removed in Pass D.** The `'Modified By'`
  proxy didn't pan out for the wider gallery layout. Real activity wiring
  via Activities table remains a Pass E task.

- **DashboardLeadDrawerCloseButton X=1252** still anchored to old narrow
  panel. Now panel is 1380. Carry-over from Pass C; same story.

- **DashboardEmptyState width=600** — still legacy from before Pass B.
  Carry-over.

- **SharePoint embed iframe height for Phase I.** Canvas now 1180 tall.
  Embed needs to match or content scrolls inside the frame. Document
  expected iframe height when wiring the Power Apps web part.

- **TemplatesScreen DashboardLeadDrawerActivityHeader/Box/Placeholder X=572 W=300**
  via the multi-line replace_all that targeted X=598. None of these are on
  TemplatesScreen — confirmed. But verify the Pass D quick-log X positions
  (572-812) don't overlap the right column at X=892.
  Actually 812 + 56 = 868, and 892 starts the right col → 24px gap. ✅

- **Quick-log labels narrowed Width 80→56** to fit middle column. Text like
  "📨  Email" may truncate at 56px depending on font rendering. Consider
  56→64 if truncation visible in Studio.

- **Action button row at Y=Panel.Y+600, panel ends at Y=Panel.Y+640.**
  Buttons (H=32) at 600 end at 632, panel ends at 640. 8px bottom margin —
  tight but OK.

## From Pass C (dashboard_passC.msapp, 2026-05-04)

- **LeadsScreen rebind from Home Quotes → Leads NOT DONE.** 175 occurrences
  of `'Home Quotes'` across LeadsScreen.fx.yaml — most are individual field
  bindings on auto-form data cards. Per spec, stopped before blanket
  replace_all. Next pass needs a column-by-column schema audit:
    1. List every column referenced in LeadsScreen field cards
    2. Confirm whether each maps to a Leads-list column with the same
       internal name, a renamed column, or has no equivalent (drop the card)
    3. Then rebind DataSource line 612 + Item line 614 + each field card.
  Estimated complexity: high. May be faster to delete LeadsScreen and
  hand-build a smaller quote-detail view.

- **Action button corner radius NOT applied.** Spec said add Radius=8 to
  DashboardDrawerOpenDetailButton, NewQuoteButton, OpenPDFButton,
  MarkBoundButton, CloseButton. Currently they have NO Radius set
  (default Power Apps button rounding). Adding 4 Radius properties to
  each is straightforward; deferred for time. Affects visual polish only.

- **Search box and filter dropdown radius NOT applied.** Spec said
  Radius=6 on DashboardSearchBox (text), DashboardStatusFilter (dropDown),
  DashboardAgentFilter (dropDown). v0.24 may not support Radius properties
  on text/dropDown control types — risky. Need to test on a scratch
  pack before applying broadly.

- **DashboardLeadDrawerActivityBox Radius=6** still mismatches the new
  Templates box (Radius=8). Spec didn't address Activity box; could
  bump for consistency.

- **DashboardDrawerCloseButton X=1252** anchored when panel was 1136.
  Now panel is 1380. Close button still at X=1252, leaving 80px right
  margin (vs the 24px when panel was narrower). Should be either
  X=Parent.Width-100 or X=DashboardLeadDrawerPanel.X + DashboardLeadDrawerPanel.Width - 100.

- **DashboardEmptyState Width=600** (legacy) — should be 1380 to match
  new gallery width. Status: still in backlog from Pass B.

- **DashboardDrawerCloseButton has Radius=undefined** — for consistency
  with new action-button standard (Radius=8 if applied), update.

- **Action button row at Y=Panel.Y+400** with the new wider 1380 panel
  has lots of empty space on the right (buttons end at X=668+140=808;
  panel ends at 1596). Could redistribute for balance.

- **Sidebar add to LeadsScreen** still deferred (was Phase 6 plan).
  Important for navigation consistency with LeadsListScreen + TemplatesScreen
  but high-risk on the auto-form structure.

- **Real Activities timeline** still placeholder ("No activity yet").
  Pass D should wire `Filter(Activities, RelatedLead.Id = varSelectedLead.ID)`
  into the Activity box in the drawer.

- **Phase E template send wiring** still TBD. Currently "Send" buttons
  Notify only.

- **DashboardLastActivity column** uses `'Modified By'` as a poor proxy
  for "had any activity". The Modified date moves whenever any field
  changes, including agent reassignment or status change — which IS
  activity, but doesn't differentiate from the Activities table.
  Better: when Activities table is wired, query
  `LookUp(Activities, LeadID = ThisItem.ID, EventDate)` and show "Last
  call 3d ago" / "Last email yesterday" etc.

- **Status pill new soft-palette + wider gallery** likely shifted some
  pill-text rendering. Verify in Studio that the new transparent
  `_Bg` pill colors don't look washed out on the white row background.

- **Canvas resize 1366 → 1600.** Studio may flag a "your sources don't
  match the saved layout" message on first open after import. CanvasManifest
  was edited in source; SizeBreakpoints in EditorState/App.editorstate.json
  was NOT edited (auto-regen file per CLAUDE.md). If Studio rebuilds
  EditorState from the new manifest dimensions on first save, this is fine.
  If Studio uses EditorState as authoritative and overrides manifest, the
  resize won't take effect.

## From Pass B (dashboard_passB.msapp, 2026-05-04)

- **DashboardEmptyState width** still 600 — should match new gallery 1140.
  File: `Src/LeadsListScreen.fx.yaml`. Width: =600 → =1140.

- **DashboardLeadDrawerTemplatesBox** height 80 leaves only ~1.7 rows visible
  in the new DashboardDrawerTemplatesGallery (TemplateSize=36, gallery
  height=64). Bump box H to 140 + gallery H to 124 for 3 visible rows.
  Currently mitigated with ShowScrollbar=true.

- **DashboardLeadDrawerTemplatesHeader** at Y=Panel.Y+240, gallery at
  Y=Panel.Y+268 — 28px gap with the SEND TEMPLATE caption then 8px box
  padding. Visual is OK; could tighten to Y=Panel.Y+250 / Y=Panel.Y+264
  for a snugger header→content spacing.

- **Control name `DashboardDrawerLogMeetingButton`** keeps "Meeting"
  even though Text was changed to "Meet". Cosmetic only — pac and OnSelect
  Patch references work fine. Rename to `DashboardDrawerLogMeetButton`
  if you want strict naming/text alignment.

- **Sidebar "Leads" Navigate is a no-op** when already on LeadsListScreen
  (Phase 4 wiring). Studio runtime tolerates this but it's dead-click.
  Either disable affordance when on the active screen, or leave as-is for
  consistency with Templates screen pattern.

- **GalleryHeaderUpdated** uses cross-control formula
  `=DashboardLeadsGallery.X + DashboardLeadsGallery.Width - 100` while
  other 5 captions use absolute X values. Inconsistent style. Either
  convert all 5 to formula form (cleaner, auto-tracks) OR convert
  Updated to absolute 1256 (consistent).

- **GalleryHeaderBackground** uses Fill: =RGBA(247, 247, 250, 1) which
  is the same gray as the sidebar. Subtle visual confusion when scrolling
  — gallery row backgrounds (white) sit between two gray strips. Could
  tweak to BgCream2 to match content area, or BorderSoft for a softer
  divider effect.

- **Row template still has DashboardLeadLastActivity-flavored gap** —
  the rename to DashboardLeadEmail moved Y=54 H=16. Below that there's
  no element until the 95px Y of the separator. If Email is blank,
  row visually shows Name + Phone only with empty bottom half. Could
  add an italicized "no email" placeholder or compress row height
  (TemplateSize 96 → 76) when activity-style content isn't shown.

- **Card row right edge** at X=1144 (DashboardCardNegotiating right
  edge). Gallery now spans X=216 to 216+1140=1356. Cards end at 1144,
  gallery ends at 1356 — gallery is 212px wider than the card row.
  Visually the gallery dwarfs the card strip on top. Could either widen
  cards (X step 134→144 with W=130) or narrow gallery to match cards.

## From Pass A (dashboard_passA_templates / dashboard_templates_v2)

- **TplPreviewBody** uses `As label` fallback (HTML renders as raw text
  with visible <div> tags). Phase E follow-up: convert to a real HTML
  viewer once we know the correct v0.24 type name.

- **'Email Templates' IsActive column** dropped from filter — the column
  doesn't exist in the data source cache. Either create the column in
  SharePoint and refresh, or add a `Status` Choice with active/archived,
  or leave as "all rows shown" forever.

- **TemplatesScreen sidebar uses Tpl* prefix** while LeadsListScreen
  uses Sidebar* prefix. Inconsistent. If a third screen is added, pick
  one convention and rename one of the two.

## From earlier passes (carry-over)

- **App.fx.yaml OnStart still defines `AgentJM`** despite Jessica not
  being a licensed agent. Cosmetic — see CLAUDE.md note.

- **5 cmp* component shells in /Src/Components are not instantiated.**
  Either delete them or build them out for v2 reuse.

- **LeadsScreen.fx.yaml is the auto-generated 9k-line Home Quotes form.**
  Phase 4+ will need to either replace this with a hand-built quote
  editor or scope out which fields actually matter for the pipeline.

- **OnVisible 8-record ClearCollect on LeadsListScreen** runs every time
  the screen mounts. Cheap on small datasets but should move to App.OnStart
  if the Leads list grows, or migrate to direct CountRows references.
