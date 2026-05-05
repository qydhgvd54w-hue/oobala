# scripts

PowerShell helpers for packing and unpacking the Adams Cosby CRM canvas app.

## Prerequisites

- **Power Platform CLI** (`pac`) on your PATH
  - Install: `winget install Microsoft.PowerApps.CLI`
  - Verify: `pac --version`
- PowerShell 5.1+ (built into Windows 10)

## pack-msapp.ps1

Packs `canvas-app\ADAMSCOSBY_CLEAN\` into a dated `.msapp` in `archive\msapp-history\`.

```powershell
# Default label = "dev"
.\scripts\pack-msapp.ps1

# Label the build for a specific pass
.\scripts\pack-msapp.ps1 -Label "passH"
```

Output: `archive\msapp-history\dashboard_passH_2026-05-04.msapp`

The output file is **gitignored** (archive/ is excluded). Import the `.msapp` into Power Apps Studio to publish.

## unpack-msapp.ps1

Unpacks a historical `.msapp` from `archive\msapp-history\` into `canvas-app\_staging_unpack\` for diffing against the current source.

```powershell
.\scripts\unpack-msapp.ps1 -Msapp "dashboard_passG_2026-05-04.msapp"
```

The staging folder (`_staging_unpack\`) is gitignored — it is a scratch area for inspection only. Never edit source files there; edit in `ADAMSCOSBY_CLEAN\` instead.
