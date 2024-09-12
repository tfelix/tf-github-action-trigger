resource "null_resource" "trigger_github_action" {
  # Use triggers to force re-run
  triggers = {
    always_run = timestamp()  # This changes every time you run `terraform apply`
  }

  provisioner "local-exec" {
    command = <<EOT
      curl -X POST \
      -H "Accept: application/vnd.github.v3+json" \
      -H "Authorization: token ${var.github_token}" \
      https://api.github.com/repos/${var.github_owner}/${var.github_repo}/actions/workflows/${var.workflow_file_name}/dispatches \
      -d '{"ref":"main", "inputs": {"key1":"value1","key2":"value2"}}'
    EOT
  }
}