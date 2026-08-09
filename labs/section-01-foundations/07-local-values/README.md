# 07 — Local values

`locals` centralise derived values so they aren't repeated. This lab reuses the same
VNet from lab 06 but expresses every name and prefix through locals, and builds a common
tags map that every resource shares.

Notice the `merge()` function that combines common tags with resource-specific tags.
