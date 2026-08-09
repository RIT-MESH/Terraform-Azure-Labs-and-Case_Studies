# 16 — Dynamic blocks

A `dynamic` block generates a repeated nested block from a list/map. Perfect for NSG
rules whose count and content you don't know at authoring time.

Here we build **one** NSG but feed it a variable list of rules. Add a rule to tfvars and
`terraform apply` extends the NSG without code changes.
