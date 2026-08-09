# 17 — Linux machine — read a local file

`file()` and `filebase64()` read a file from the lab folder at plan/apply time. Here we
read a public SSH key from `id_rsa.pub` and feed it to the VM. (Create the file or
replace with your own key.)

Also introduces `templatefile()` as the next step for injecting a templated script.
