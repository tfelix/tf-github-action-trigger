resource "terraform_data" "replacement" {

  # This is required in order to use those variables in the destroy part.connection
  # Sadly you can not directly reference var.<NAME> inside the destroy provisioner.
  input = {
    github_token = var.github_token,
    github_repo = var.github_repo,
    github_owner = var.github_owner,
    workflow_branch = var.workflow_branch
    workflow_destroy_file_name = var.workflow_destroy_file_name
    building_block_run = var.building_block_run
  }

  provisioner "local-exec" {
    when = create
    command = <<EOT
      curl -X POST \
      -H "Accept: application/vnd.github.v3+json" \
      -H "Authorization: token ${var.github_token}" \
      https://api.github.com/repos/${var.github_owner}/${var.github_repo}/actions/workflows/${var.workflow_create_file_name}/dispatches \
      -d '{"ref":"${var.workflow_branch}", "inputs": {"bb-run":"${var.building_block_run}"}}'
    EOT
  }

  provisioner "local-exec" {
    when = destroy
    command = <<EOT
      curl -X POST \
      -H "Accept: application/vnd.github.v3+json" \
      -H "Authorization: token ${self.input.github_token}" \
      https://api.github.com/repos/${self.input.github_owner}/${self.input.github_repo}/actions/workflows/${self.input.workflow_destroy_file_name}/dispatches \
      -d '{"ref":"${self.input.workflow_branch}", "inputs": {"bb-run":"${self.input.building_block_run}"}}'
    EOT
  }
}