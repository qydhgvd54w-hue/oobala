# canvas-app

Contains the unpacked Power Apps canvas source for ADAMSCOSBY_CLEAN.

## Pack / Unpack

Use the repo scripts — never pack/unpack manually:

```powershell
# Pack to archive (requires pac CLI on PATH)
..\scripts\pack-msapp.ps1 -Label "passH"

# Unpack a historical build to _staging_unpack for diffing
..\scripts\unpack-msapp.ps1 -Msapp "dashboard_passG_2026-05-04.msapp"
```

The `pac canvas pack` / `pac canvas unpack` commands are from the **Power Platform CLI** (`pac`). Install via: `winget install Microsoft.PowerApps.CLI`

## Deprecation Note

Microsoft is migrating canvas apps to native **Power Platform Git integration** (Project Aria). When that feature reaches GA for your tenant, the `pac canvas pack/unpack` workflow here will be superseded by the platform's built-in source control. At that point, this folder structure maps cleanly: `Src/` files track 1:1 with what the platform commits.

## Structure

```
ADAMSCOSBY_CLEAN/
  CanvasManifest.json   — app metadata
  Connections/          — connector references
  DataSources/          — data source definitions
  Entropy/              — non-deterministic state (gitignore candidate)
  pkgs/                 — imported packages
  References/           — component library references
  Src/                  — screen .fx.yaml files (the main source)
    App.fx.yaml
    LeadsScreen.fx.yaml
    LeadsListScreen.fx.yaml
    ... (one file per screen)
_staging_unpack/        — gitignored, used by unpack-msapp.ps1 for diffing
```
