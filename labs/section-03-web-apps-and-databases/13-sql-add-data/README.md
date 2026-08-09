# 13 — Adding data to an Azure SQL database

Terraform doesn't run T-SQL by design. The recommended path is the **`sqlcmd`** CLI or a
migration tool. After lab 08/12, run:

```bash
sqlcmd -S <server>.database.windows.net -U sqladmin -P "$PASSWORD" \
  -d sqldb-app -i section-03/.../11-another-sql-prepare/schema.sql
```

For CI/CD, a release pipeline step would run this `sqlcmd`. This lab keeps the schema
file you'll execute. (See lab 11 for the `.sql`.)
