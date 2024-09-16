variable "github_token" {
  description = "GitHub Personal Access Token"
  type        = string
  sensitive   = true
}

variable "github_owner" {
  description = "The owner of the GitHub repo containing the workflow."
  type = string
}

variable "github_repo" {
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

variable "user_permissions" {
  default = []
  description = "List with objects of user permissions which are assigned on the project."
  type = list(object({
    meshIdentifier = string
    username    = string
    firstName = string
    lastName = string
    email = string
    euid = string
    roles = list(string)
  }))
}