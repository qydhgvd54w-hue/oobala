# Adams Cosby Insurance Agency CRM

A small-team CRM for Adams Cosby Insurance Agency. Used by 5 people: Alec, Rachel Cosby, Jessica Adams, Tammy Dennis, Leigh Marsh.

## Stack
- Power Apps Canvas (the UI, packed/unpacked as .msapp)
- SharePoint Online (data backend, alfains.sharepoint.com/teams/1047889-ADAMSCOSBY/)
- Power Automate (email automation, follow-up reminders, daily digest)

## Repo Layout
- canvas-app/ADAMSCOSBY_CLEAN/Src/   <- canvas source YAML, this is what you edit
- canvas-app/foundations/USE_THIS_G.msapp   <- foundation .msapp to start from
- passes/pass-N-summary.md   <- spec for the current pass
- scripts/pack-msapp.ps1   <- packs Src/ back into a .msapp
- archive/msapp-history/   <- where packed .msapps go, one per pass

## Workflow - Branch Per Pass
1. Read passes/pass-N-summary.md for scope
2. Create branch pass-N-<short-label>
3. Edit YAML under canvas-app/ADAMSCOSBY_CLEAN/Src/
4. Pack: pwsh scripts/pack-msapp.ps1 -Label passN
5. Confirm output in archive/msapp-history/
6. Commit and push the branch
7. STOP. Alec imports into Power Apps Studio for visual QA.

Do not merge to main. Do not open PRs.

## Hard Constraints
- Reply-To on customer emails = teamac@alfains.com (never SC1047@alfains.com - Send-As pending)
- Office365Outlook connector has NO _1 suffix in this tenant
- Use GetEventsCalendarViewV3 (V2 retired)
- dropdownCalendarSelection3.Default must be =Blank() so any pick fires OnChange
- Never commit EditorState/ or Entropy/
- BrandRed = #C8102E

## Current State
- Pass G: complete
- Pass H: committed at fd3ef41 on branch pass-h-templates-fix
- Pass I (in flight): visual polish, fix templates filter regression, remove expanded section duplicates, drawer height 1000 -> 720

## Done = 
- All pass scope items addressed
- .msapp packed in archive/msapp-history/
- Branch pushed to origin
- Commit references pass number
- Short summary of changes in final message

## Skip
- Refactors outside pass scope
- New SharePoint columns or flows unless in spec
- Auto-format on untouched files
- Trying to open Power Apps Studio (no tenant access)
