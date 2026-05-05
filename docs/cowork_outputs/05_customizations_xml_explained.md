# Task 5 — Customizations.xml Explained
**Adams Cosby CRM · Plain-English Documentation**
*File: `C:\Users\alec\Desktop\Claude\AdamsCosbyCRM_src\src\Other\Customizations.xml`*
*Documented: 2026-05-03*

---

## 1. TL;DR

This file is a **Dataverse (Power Platform) solution package export** that defines exactly one thing: a custom global picklist called `LineOfBusiness` with three options (P&C, Alfa Agency, Life). It contains no automation, no entities, no workflows, and no business logic of any kind.

---

## 2. Components Defined

| Component Type | Name | Count |
|---------------|------|-------|
| Entities | None | 0 |
| Forms | None | 0 |
| Views | None | 0 |
| Option Sets (global picklists) | `ac_lineofbusiness` | 1 |
| Workflows / Business Process Flows | None | 0 |
| Web Resources | None | 0 |
| Roles | None | 0 |
| Templates | None | 0 |
| Entity Relationships | None | 0 |

The file structure has placeholder XML elements for all of these (`<Entities />`, `<Roles />`, `<Workflows />`, etc.) but every one of them is empty.

---

## 3. Custom Fields

No custom fields are defined at the entity level because no entities are defined. The only custom artifact is the global option set described below.

**`ac_lineofbusiness` — Global Option Set**

| Property | Value |
|----------|-------|
| Schema Name | `ac_lineofbusiness` |
| Display Name | LineOfBusiness |
| Type | Picklist (single-select) |
| Is Global | Yes (can be reused across entities) |
| Is Customizable | Yes |
| Introduced Version | 1.0.0.0 |
| Publisher Prefix | `ac` (Adams Cosby) |
| Option Value Prefix | `12082` |

**Values:**

| Option Value | Label |
|-------------|-------|
| 120820000 | P&C |
| 120820001 | Alfa Agency |
| 120820002 | Life |

The option values follow Dataverse convention: the publisher's option value prefix (12082) followed by a sequential 4-digit suffix (0000, 0001, 0002). This is auto-generated and has no business meaning.

---

## 4. Workflow / Process Flow Definitions

**None.** The `<Workflows />` element is present but empty. No business process flows, classic workflows, or Power Automate cloud flows are defined or referenced in this file.

This is the key finding for the intake automation audit: whatever automation Adams Cosby uses for lead intake is not captured here. It lives outside this solution package — either in Power Automate cloud flows (accessible at flow.microsoft.com) or in SharePoint list automation.

---

## 5. Plugin / Code Assemblies Referenced

**None.** The `<SolutionPluginAssemblies />` element is empty. This is expected for a SharePoint-based CRM — custom .NET plugins are a Dataverse/Dynamics 365 concept and are not used here.

---

## 6. Dependencies

This file assumes the following exist at import time:

| Dependency | Type | Required For |
|-----------|------|-------------|
| Dataverse / Power Platform environment | Platform | The file can only be imported into a Dataverse environment, not into SharePoint directly |
| Publisher `dynamics365agency` with prefix `ac` | Platform metadata | The publisher definition in Solution.xml must be present before the option set can be registered |
| Language 1033 (English US) | Locale | All labels and descriptions are defined in language code 1033 only |

**SharePoint dependency:** None. This file has no connection to the SharePoint lists (Leads, Home Quotes, Activities, etc.) that power the actual CRM. They are separate systems.

---

## 7. Activation Status

**Unknown — likely dormant.** This file is a solution export artifact. It was exported from a Dataverse environment at some point, but whether it has been imported into the current `alfains` Power Platform tenant and activated is not determinable from the file alone.

To check: Go to [make.powerapps.com](https://make.powerapps.com) → Solutions → look for "AdamsCosby CRM" or a solution from publisher "Dynamics 365 Agency." If the solution appears there, the `ac_lineofbusiness` option set is active. If not, it has never been imported or was deleted.

The `ac_lineofbusiness` option set would only be visible in Dataverse, not in SharePoint. Since the current CRM is built on SharePoint lists, this option set is almost certainly not in active use — the SharePoint Leads list would have its own Choice column for coverage type, independent of this Dataverse definition.

---

## 8. Migration Considerations

If Adams Cosby ever migrates from SharePoint to Dataverse (e.g., moving to a full Dynamics 365 or Model-Driven Power App), here is what carries over from this file:

| What Carries Over | Notes |
|-------------------|-------|
| `ac_lineofbusiness` option set | Will import cleanly. P&C, Alfa Agency, Life values would be available for use on any Dataverse entity. |
| Publisher metadata (`dynamics365agency`, prefix `ac`) | Carries over as the solution publisher. |

| What Does NOT Carry Over | Notes |
|--------------------------|-------|
| SharePoint list schemas | Must be rebuilt as Dataverse tables. Column names, types, and relationships would all need to be recreated. |
| Power Apps Canvas app | Canvas apps can connect to Dataverse, but all data source bindings would need to be remapped from SharePoint lists to Dataverse tables. |
| Power Automate flows | Flows using SharePoint connectors would need to be rebuilt using Dataverse connectors. Trigger logic, filter queries, and field references all change. |
| Email Templates list | Would need to be recreated as a Dataverse table. |
| Historical data | All existing leads, activities, and documents would need to be migrated. |

**Bottom line on migration:** The Customizations.xml file gives you a head start of roughly one dropdown definition. The real migration work is in the data layer and flows. This file saves maybe 5 minutes of a multi-day project.
