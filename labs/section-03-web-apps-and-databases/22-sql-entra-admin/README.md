# 22 — Azure SQL with Microsoft Entra ID admin (advanced)

SQL logins are passwords. Entra ID (Azure AD) admin lets you sign in with an identity —
no shared password, better audit, and you can scope who's a DB admin by group membership.
This lab sets the SQL server's Entra admin to the current signed-in principal via
`azuread_administrator`.

> Also demonstrates `identity { type = "SystemAssigned" }` so the server can later use
> managed identity to connect to other resources.
