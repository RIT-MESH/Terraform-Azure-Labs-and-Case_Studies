# Contributing

This repository is original educational material. To keep it clean and reproducible:

## Style

- Run `terraform fmt -recursive` before committing.
- Run `terraform validate` in each lab; every lab should pass.
- Pin providers in every `terraform.tf` with `~> 3.70` (or current minor).
- One concern per file: `terraform.tf`, `locals.tf`, `variables.tf`, `main.tf`, `outputs.tf`.

## Lab conventions

- Each lab folder is **self-contained** and independently runnable.
- Use a `README.md` explaining the concept and how to run it.
- Default to `eastus` and the smallest SKUs (`Standard_B1s`, `Basic`, `B1`).
- Never hard-code secrets. Mark them `sensitive = true` and ship a `.tfvars.example`.
- Use random suffixes (`substr(md5(timestamp()), 0, N)`) for globally-unique names so
  labs don't collide.

## Adding a lab

1. Create `labs/section-XX-name/NN-topic/`.
2. Add `terraform.tf`, the resource files, and a `README.md`.
3. Add the lab to the section `README.md` and to `docs/lab-index.md`.
4. Run `terraform fmt` and `terraform validate` from the lab folder.

## Originality

All code must be authored fresh — do not copy from third-party courses or repos. It is
fine to be inspired by concepts, but the implementation should be your own.
