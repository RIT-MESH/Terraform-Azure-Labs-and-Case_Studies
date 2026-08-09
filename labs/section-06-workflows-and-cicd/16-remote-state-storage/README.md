# 16 — Azure Storage for the state file

Two parts, run in order:

## Part A — bootstrap the backend (run once)

```bash
cd bootstrap
terraform init
terraform apply   # creates rg, storage account, container, locks down TLS
```

Outputs give you the `resource_group_name`, `storage_account_name`, `container_name`.

## Part B — point a config at the backend

Edit `backend.tf` in the `app/` folder with the values from Part A, then:

```bash
cd app
terraform init -backend-config="resource_group_name=..." \
              -backend-config="storage_account_name=..." \
              -backend-config="container_name=..." \
              -backend-config="key=app.tfstate"
```

Now state lives in Azure, with locking and team sharing built in.
