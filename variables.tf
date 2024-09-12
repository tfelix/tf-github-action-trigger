variable "github_token" {
  description = "GitHub Personal Access Token"
  type        = string
  sensitive   = true
}

variable "github_owner" {
  default = "tfelix"
  type = string
}

variable "github_repo" {
  default = "tf-github-action-trigger"
  type = string
}

variable "workflow_file_name" {
  default = ".github/workflows/workflow.yml"
  description = "The name of the workflow file (e.g. workflow.yml)"
  type = string

}