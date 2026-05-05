# Adams Cosby CRM

Power Platform CRM built for Adams & Cosby (Alfa Insurance). Canvas app with Microsoft Lists backend, Power Automate flows for lead management, and a set of reusable templates.

## Build State

- **Current pass:** G (complete)
- **Canvas app:** v1.1 — preserved in `canvas-app/ADAMSCOSBY_CLEAN/`
- **Next milestone:** Track A pivot — migrating data layer to Microsoft Lists for tomorrow ship

## Team

| Name   | Role |
|--------|------|
| Alec   | Lead developer / architect |
| Rachel | Stakeholder / product |
| Jess   | Stakeholder |
| Tammy  | Stakeholder |
| Leigh  | Stakeholder |

## Folder Map

| Folder | Contents |
|--------|----------|
| `canvas-app/` | Unpacked Power Apps canvas source (ADAMSCOSBY_CLEAN). Pack/unpack with scripts. |
| `lists/` | SharePoint / Microsoft Lists column schema JSON files. |
| `flows/` | Power Automate flow documentation and export specs. |
| `templates/` | Reusable Power Apps component templates. |
| `mockups/` | Design mockups and wireframes. |
| `docs/` | Project documentation, audits, and session notes. |
| `docs/audits/` | Structured audit reports. |
| `passes/` | Per-pass work logs following the 5-section self-critique format. |
| `scripts/` | PowerShell helpers for pack/unpack of the canvas app. |
| `archive/` | Local-only (gitignored). Historical .msapp builds and pre-pass backups. |

## What Git Tracks

Git tracks everything **except** the `archive/` folder and any `.msapp` binary files (see `.gitignore`). The canvas source in `canvas-app/ADAMSCOSBY_CLEAN/` is the single source of truth — compile it to `.msapp` via `scripts/pack-msapp.ps1` when needed.

## Quick Start

```powershell
# Pack canvas source into a dated .msapp for import
.\scripts\pack-msapp.ps1 -Label "passH"

# Unpack a historical build to a staging folder for diffing
.\scripts\unpack-msapp.ps1 -Msapp "dashboard_passG_2026-05-04.msapp"
```
