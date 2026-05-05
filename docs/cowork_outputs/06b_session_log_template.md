# Adams Cosby CRM — Build Session Log Template
*Copy this file for each build session. Rename as: `session_log_YYYY-MM-DD_PhaseN.md`*

---

## Session Overview

| Field | Value |
|-------|-------|
| **Date** | YYYY-MM-DD |
| **Duration** | e.g., 45 minutes |
| **Phase Name** | e.g., Phase A3 — Email Panel |
| **Session Goal** | One sentence: what were you trying to accomplish? |
| **Claude Session Context** | Paste the first message you sent to Claude this session, or summarize the starting state |

---

## Backup

| Field | Value |
|-------|-------|
| **Backup Created?** | Yes / No |
| **Backup Folder Name** | e.g., `ADAMSCOSBY_CLEAN_backup_phaseA3` |
| **Backup Location** | e.g., `C:\Users\alec\Desktop\MSAPP\` |
| **Backup Timestamp** | e.g., 2026-05-03 at 9:15 AM |

> Always back up before starting. If no backup was created, note why.

---

## Edits Made

List every file that was changed this session. Be specific — future-you will thank you.

| File | What Changed | Line(s) |
|------|-------------|---------|
| `Src/App.fx.yaml` | Added EmailPanelVisible variable | ~line 12 |
| `Src/LeadsScreen.fx.yaml` | Added Send Email button to gallery | ~line 340 |
| *(add rows as needed)* | | |

**New files created this session:**
- *(list any new .fx.yaml or other files added)*

---

## Pack Result

| Field | Value |
|-------|-------|
| **Pack Command Used** | e.g., `pac canvas pack --sources ADAMSCOSBY_CLEAN --msapp output.msapp` |
| **Result** | ✅ Success / ❌ Error |
| **Output File** | e.g., `AdamsCosbyCRM_6.msapp` |
| **Error Message (if any)** | Paste full error text here |

---

## Studio Import Result

| Field | Value |
|-------|-------|
| **Imported to Power Apps Studio?** | Yes / No |
| **Import Method** | e.g., Open in Power Apps Studio → Open → Browse |
| **Result** | ✅ Opened successfully / ❌ Error |
| **Error on Import (if any)** | Paste full error text here |

---

## Visual Verification

Did the change look right when you tested it in the app?

| Check | Result |
|-------|--------|
| App loaded without errors | ✅ / ❌ |
| Target feature rendered correctly | ✅ / ❌ |
| No unintended visual regressions spotted | ✅ / ❌ |
| Tested on: | Desktop / Mobile |

**Screenshot:**
*(Paste screenshot here, or note: "Screenshot saved as session_screenshot_YYYY-MM-DD.png")*

---

## Errors Encountered

| Error | Where It Appeared | Resolution |
|-------|------------------|------------|
| *(describe the error)* | Pack / Studio / App | *(how you fixed it, or "unresolved — see Next Phase")* |

---

## Notes & Decisions Made This Session

*(Free-form. Capture any decisions that affect future phases — e.g., "Decided to use a global variable for panel visibility instead of a component property because...")*

---

## Next Phase Queued

| Field | Value |
|-------|-------|
| **Next Phase Name** | e.g., Phase A4 — Flow Integration |
| **Goal** | One sentence |
| **Starting Point** | Which backup folder / msapp version to start from |
| **First Action** | The exact first thing to do next session |
| **Open Questions to Resolve** | Any blockers or decisions needed before starting |

---

*Log saved to: `C:\Users\alec\Desktop\MSAPP\COWORK_OUTPUTS\session_logs\session_log_YYYY-MM-DD_PhaseN.md`*
