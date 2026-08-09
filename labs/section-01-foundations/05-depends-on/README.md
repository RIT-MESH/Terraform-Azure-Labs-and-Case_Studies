# 05 — `depends_on`

Terraform normally infers dependency order from references. When two resources have no
direct reference but **must** still be ordered, use `depends_on` to make it explicit.

This lab creates a resource group, then a storage account, then a container. The
container has no attribute reference to the storage account beyond its name (which is a
plain string), so we add `depends_on` to guarantee ordering.

> Prefer a real reference over `depends_on` whenever possible — `depends_on` is a code
> smell that says "the graph isn't expressible through data".
