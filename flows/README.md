# flows

Power Automate flow documentation and export specs for the Adams Cosby CRM.

## Send-As Prerequisite

All outbound email flows use **Send-As** on the shared mailbox `teamac@alfains.com`. Before enabling any email flow in a new environment:

1. Confirm the service account has Send-As permission on `teamac@alfains.com` (Exchange Admin Center → Recipients → Mailboxes → Manage mailbox delegation)
2. Allow up to 60 minutes for permission propagation before testing

## Reply-To Convention

All automated emails set **Reply-To: `teamac@alfains.com`** so client replies land in the shared inbox, not the sending service account. This must be set explicitly in the "Send an email (V2)" action — Power Automate does not inherit Reply-To from the From address.

## Flows

| Flow | Trigger | Purpose |
|------|---------|---------|
| NewLead | List item created | Welcome email + assign owner |
| StatusChanged | List item modified (Status column) | Notify owner of status change |
| DailyDigest | Scheduled (8 AM) | Summary of open leads to team inbox |
| FollowUpReminder | Scheduled | Ping owner on stale leads |

## Documentation

Full flow specs are in `../docs/cowork_outputs/03_flows/`.
