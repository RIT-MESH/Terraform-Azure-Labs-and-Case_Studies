# 01 — Inspecting the initial code base

Before refactoring, study what you have. This lab is a copy of section-01's storage
account (lab 02) to serve as the "initial code base". Read `main.tf`, then run:

```bash
terraform init
terraform plan      # see the planned changes
terraform graph     # visualise the dependency graph
```

`terraform graph` outputs DOT; pipe to Graphviz: `terraform graph | dot -Tsvg > graph.svg`.
