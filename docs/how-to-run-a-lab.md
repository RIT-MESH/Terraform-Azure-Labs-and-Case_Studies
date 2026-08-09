# How to run a lab (for absolute beginners)

Never used Terraform or Azure before? This guide takes you from zero to running real cloud
resources from code — one step at a time. Follow it top to bottom once, and every other
lab in this repo will work the same way.

Goal of this guide: run your first lab successfully, understand what happened, and clean
up so you do not get billed.

---

## 0. The 30-second mental model

- A lab is just a folder that contains a few .tf text files.
- Terraform reads those files, talks to Azure, and creates the resources described in them.
- You run four commands, in order:

  | Command | What it does | When |
  |---|---|---|
  | terraform init   | Downloads the Azure provider (one-time per lab) | First time in a lab |
  | terraform plan   | Shows what it would change, but changes nothing | Before applying |
  | terraform apply  | Actually creates/updates the resources | To build |
  | terraform destroy| Deletes everything this lab created | When you are done |

That is the whole loop. Now let us set up so you can run it.

---

## 1. Install the three tools (one time only)

### a) Terraform
Download from https://developer.hashicorp.com/terraform/downloads and install. Verify:

    terraform -version

You should see a version of 1.5 or higher.

### b) Azure CLI (az)
Download from https://learn.microsoft.com/cli/azure/install-azure-cli. Verify:

    az version

### c) Git (optional, only if you cloned the repo)

    git --version

Windows tip: after installing, close and reopen your terminal so the new commands are on
your PATH.

---

## 2. Sign in to Azure (once per terminal session)

    az login

A browser opens. Pick the account that has your Azure subscription. Back in the terminal
you will see a JSON list of your subscriptions.

If you have more than one, set the one to use:

    az account set --subscription "<your-subscription-id>"

Find the id with:

    az account show --query id -o tsv

That is it — the Terraform Azure provider reuses this login automatically.

---

## 3. Get the lab files on your machine

If you cloned the repo, you already have them. If you downloaded a ZIP, unzip it.

Open a terminal at the repo root (the folder that contains README.md, labs/, etc.).

---

## 4. Pick your first lab

Start with the simplest one — it needs no passwords, no SSH keys, no variables:

    labs/section-01-foundations/02-storage-account

Move into that folder. Everything you do next happens inside the lab folder, not the repo
root:

    cd labs/section-01-foundations/02-storage-account

---

## 5. Understand what is in the folder

A typical lab has a few files. Here is what each is for:

| File | Purpose | Do you edit it? |
|---|---|---|
| README.md | Explains the concept and how to run the lab | Read it first |
| terraform.tf | Pins the Terraform version and the Azure provider | Rarely |
| main.tf | The actual resources (the thing you are learning) | Yes, to practice |
| locals.tf | Derived values, when present | Sometimes |
| variables.tf | Inputs, when present | Sometimes |
| outputs.tf | Values printed after apply, when present | Sometimes |
| terraform.tfvars / .tfvars.example | Values for the variables | For labs that need them |

Open main.tf in a text editor (VS Code is great) and read it. For this lab it creates a
resource group and a storage account. That is all.

---

## 6. Run it — the four commands

### 6a. terraform init (one time per lab)

    terraform init

What it does: downloads the Azure provider and creates a hidden .terraform/ folder. This
is the only command that needs internet for providers.

You will see a green message like: Terraform has been successfully initialized!

The .terraform/ folder is gitignored on purpose — it is local machine stuff, not code.

### 6b. terraform plan (look before you leap)

    terraform plan

What it does: reads your files, checks what already exists in Azure, and prints a preview
of what it would change. Nothing is created yet.

You should see something like:

    Terraform will perform the following actions:
      + azurerm_resource_group.this   ... created
      + azurerm_storage_account.this  ... created
    Plan: 2 to add, 0 to change, 0 to destroy.

The + means will create. A - would mean will delete, ~ means will update.

### 6c. terraform apply (build it)

    terraform apply

Terraform shows the same plan and asks:

    Do you want to perform these actions?
      Only yes will be accepted to approve.
      Enter a value:

Type yes and press Enter. After a minute you will see:

    Apply complete! Resources: 2 added, 0 changed, 0 destroyed.

Plus any output blocks print their values (here, the storage account name and its blob
endpoint).

You just created real Azure resources from code.

### 6d. Verify it worked

- Run terraform output any time to see the outputs again.
- Or open the Azure portal, find your resource group (rg-storage-foundation), and you will
  see the storage account there.

---

## 7. Practice: change something and re-run

The real learning is the change-plan-apply loop.

1. Open main.tf and change the region, for example region = "eastus" to "westus2".
2. Run:

    terraform plan
    terraform apply

3. Read the diff carefully. That is exactly how professionals review changes.

---

## 8. Clean up so you do not get billed

When you are done with a lab, always destroy what it created:

    terraform destroy

It shows a plan of what it will delete and asks yes. After it finishes, your Azure
resource group is gone and your bill goes back to about zero.

Do this every time. Labs use tiny, cheap resources, but leaving 50 labs running adds up.

---

## 9. Try the next lab

Every lab in this repo runs the same way:
1. cd into the lab folder.
2. terraform init
3. terraform plan
4. terraform apply
5. Read the README.md first — some labs need a variable (they ship a
   terraform.tfvars.example you copy to terraform.tfvars and fill in), or an SSH key.

Good next labs, in order of difficulty:
- section-01-foundations/03-upload-blob — same idea, adds a container and a blob.
- section-01-foundations/06-virtual-network — first network resource.
- section-01-foundations/15-public-ip — one resource, no dependencies.

---

## 10. When something goes wrong (common novice errors)

| Error | Fix |
|---|---|
| terraform: command not found | Terraform is not installed or not on PATH. Reopen the terminal after installing. |
| az: command not found | Azure CLI not installed or not on PATH. |
| Error: No Azure subscription was found | Run az login, then az account set --subscription <id>. |
| Error: building account: storage account names must be unique | Rare — the random suffix should avoid this; just apply again. |
| Error: ... already exists | Another lab (or you) used the same name. Pick a different one in main.tf. |
| terraform init fails to download the provider | Check internet/proxy. Try terraform init -upgrade. |
| Plan looks huge / will destroy everything | You are in the wrong folder, or pointing at the wrong state. Re-check your cd. |
| It asks for a variable value | That lab needs terraform.tfvars. Copy terraform.tfvars.example to terraform.tfvars and fill it in. |

When in doubt: read the error message fully — Terraform errors are usually clear and tell
you exactly which file and line.

---

## 11. Quick reference card

    # one-time setup
    az login
    az account set --subscription "<id>"

    # every lab
    cd labs/section-01-foundations/02-storage-account
    terraform init
    terraform plan
    terraform apply          # type yes
    terraform output         # see results
    terraform destroy        # clean up when done (type yes)

---

## 12. The one rule that keeps you safe

Finish a lab, run terraform destroy, then move to the next. Code in a lab is meant to be
temporary practice, not a long-running app.

That is it. You now know enough to run every lab in this repository.
