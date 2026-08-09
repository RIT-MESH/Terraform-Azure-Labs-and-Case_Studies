# 13 — Custom Azure Policy definition + assignment (advanced)

Lab 12 assigned a **built-in** policy. This lab authors a **custom** policy definition
(`azurerm_policy_definition`) — "deny resource groups without a `costcenter` tag" — and
assigns it at a resource group scope. Custom policies express rules the built-ins don't
cover.

The policy rule uses `policyRule` JSON: a `deny` effect when `tags.costcenter` is missing.
