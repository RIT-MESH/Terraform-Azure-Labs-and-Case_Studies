# 24 — Application Gateway — SSL termination via Key Vault (advanced)

Terminate HTTPS on the gateway with a **self-signed certificate stored in Key Vault**.
App Gateway fetches the cert from the vault using a **user-assigned managed identity** —
the cert never sits in the repo.

Steps in code:
1. Key Vault (with an access policy).
2. A self-signed cert generated **by Key Vault** (`issuer { name = "Self" }`) and stored as
   a PFX secret.
3. A user-assigned identity, granted `Get` on the cert secret in the vault.
4. App Gateway v2 with that identity, an HTTPS listener on 443, and an
   `ssl_certificate` pointing at `key_vault_secret_id`.

Addressing: VNet `172.25.0.0/20`; gateway subnet `172.25.0.0/26`; backend subnet
`172.25.0.64/26`.

> Browsers will warn about the self-signed cert — that's expected; it's a learning lab.
