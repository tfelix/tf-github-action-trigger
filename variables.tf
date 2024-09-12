variable "github_token" {
  description = "GitHub Personal Access Token"
  type        = string
  sensitive   = true
}

variable "github_owner" {
  default = "tfelix"
  description = "The owner of the GitHub repo containing the workflow."
  type = string
}

variable "github_repo" {
  default = "tf-github-action-trigger"
  description = "The name of the GitHub repo containing the workflow."
  type = string
}

variable "workflow_create_file_name" {
  default = "deploy.yml"
  description = "The name of the workflow file (e.g. workflow.yml) for deploying the resources."
  type = string
}

variable "workflow_destroy_file_name" {
  default = "destroy.yml"
  description = "The name of the workflow file (e.g. workflow.yml) for destryoing the resources."
  type = string
}

variable "workflow_branch" {
  default = "main"
  description = "The name of the branch in which the workflow files live."
  type = string
}

variable "building_block_run_b64" {
  default = "{}"
  description = "The base64 encoded JSON of the Building Block Run object."
  type = string
}