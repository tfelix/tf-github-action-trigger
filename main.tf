resource "null_resource" "create_provisioner" {

  # Triggers store the values in the state
  triggers = {
    github_token               = var.github_token
    github_repo                = var.github_repo
    github_owner               = var.github_owner
    workflow_branch            = var.workflow_branch
    workflow_destroy_file_name = var.workflow_destroy_file_name
    building_block_run_b64     = var.building_block_run_b64
  }

  provisioner "local-exec" {
    when = create
    command = <<EOT
      set -e
      curl --fail-with-body -X POST \
        -H "Accept: application/vnd.github.v3+json" \
        -H "Authorization: token ${var.github_token}" \
        https://api.github.com/repos/${var.github_owner}/${var.github_repo}/actions/workflows/${var.workflow_create_file_name}/dispatches \
        -d '{"ref":"${var.workflow_branch}", "inputs": {"bb-run":"${var.building_block_run_b64}"}}'
    EOT
  }

  provisioner "local-exec" {
    when = destroy
    command = <<EOT
      set -e
      curl --fail-with-body -X POST \
        -H "Accept: application/vnd.github.v3+json" \
        -H "Authorization: token ${self.triggers.github_token}" \
        https://api.github.com/repos/${self.triggers.github_owner}/${self.triggers.github_repo}/actions/workflows/${self.triggers.workflow_destroy_file_name}/dispatches \
        -d '{"ref":"${self.triggers.workflow_branch}", "inputs": {"bb-run":"${self.triggers.building_block_run_b64}"}}'
    EOT
  }
}
