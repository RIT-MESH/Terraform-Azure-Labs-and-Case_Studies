# 32 — Azure Firewall — application rule

Application rules are Layer-7 (FQDN) allow rules. This one lets the workload reach
`*.ubuntu.com` and `github.com` for apt/package downloads while denying other internet.
