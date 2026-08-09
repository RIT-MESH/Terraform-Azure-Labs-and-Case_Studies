# 21 — App Service source control (advanced deploy)

Wire a web app to a Git repository so Azure builds and deploys on every push.
`azurerm_linux_web_app` accepts a `source_control` block — give it a repo URL and branch.

> Azure needs credentials to read a private repo (a PAT). For a public repo you can use
> a dummy token. This lab points at a public sample repo; change `repo_url` to yours.
