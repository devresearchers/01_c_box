## Firewall Enhancement Proposal

1. **Switch to deny-list**: Replace the current allowlist approach in `build/init-firewall` with a deny-list. The firewall should block only the domains explicitly listed in `/home/DOCKERUSER/.claudebox/denylist`. All other traffic must be allowed by default.
2. **Comprehensive logging**: The firewall needs to log each network event with the following fields:
   - timestamp (date and time)
   - destination domain
   - profile/account used for the connection
   - bytes sent
   - bytes received
   - initiating process name

   Log entries should be appended to `/home/DOCKERUSER/.claudebox/FIREWALL_REPORT.csv` in CSV format.

This update requires rewriting `init-firewall` to implement deny rules and collect the logging information above.
