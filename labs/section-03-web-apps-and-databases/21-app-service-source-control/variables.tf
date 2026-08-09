variable "repo_url" {
  type    = string
  default = "https://github.com/Azure-Samples/nodejs-docs-hello-world"
}

variable "branch" { type = string, default = "main" }

variable "deploy_token" {
  type      = string
  sensitive = true
  default   = "placeholder-for-public-repo"
}
