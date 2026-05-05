# lists

SharePoint / Microsoft Lists column schema and configuration files for the Adams Cosby CRM data layer.

## Applying JSON Formatting

Each List has a corresponding JSON file in this folder. To apply:

1. Open the List in SharePoint
2. Select the column → **Column settings** → **Format this column**
3. Paste the JSON from the corresponding file
4. Click **Save**

For view-level formatting (gallery/board views):

1. Open the view → **Format current view**
2. Paste the JSON → **Save**

## Files

| File | List / Column | Purpose |
|------|---------------|---------|
| *(add files here as schemas are exported)* | | |

## Naming Convention

`{ListName}_{ColumnOrView}.json` — e.g., `Leads_Status.json`, `Leads_GalleryView.json`
