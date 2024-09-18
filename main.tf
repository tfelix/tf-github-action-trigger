data "github_app_token" "this" {
  app_id          = var.github_app_id
  installation_id = var.github_app_installation_id
  pem_file        = var.github_app_pem_file
}

resource "terraform_data" "replacement" {
  input = {
    github_repo                = var.github_repo
    github_owner               = var.github_owner
    workflow_branch            = var.workflow_branch
    app_id                     = var.github_app_id
    installation_id            = var.github_app_installation_id
    pem_file                   = var.github_app_pem_file
    workflow_destroy_file_name = var.workflow_destroy_file_name
    meshstack_building_block_run_b64 = var.meshstack_building_block_run_b64
  }

  triggers_replace = [
    var.meshstack_building_block_run_b64,
  ]

  provisioner "local-exec" {
    when = create
    environment = {
      run_data = jsondecode(base64decode(var.meshstack_building_block_run_b64)).spec.behavior
    }
    command = <<EOT
      set -e
      if [ "$run_data" = "DESTROY" ]; then
        exit 0
      fi

      curl --fail-with-body -X POST \
        -H "Accept: application/vnd.github.v3+json" \
        -H "Authorization: token ${data.github_app_token.this.token}" \
        https://api.github.com/repos/${var.github_owner}/${var.github_repo}/actions/workflows/${var.workflow_create_file_name}/dispatches \
        -d "{\"ref\":\"${var.workflow_branch}\", \"inputs\": {\"bb-run\":\"${var.meshstack_building_block_run_b64}\"}}"
    EOT
  }

  provisioner "local-exec" {
    when = destroy
    environment = {
      run_data = jsondecode(base64decode(self.input.meshstack_building_block_run_b64)).spec.behavior
    }
    command = <<EOT
      set -e
      echo $run_data
      if [ "$run_data" != "DESTROY" ]; then
        exit 0
      fi

      APP_ID="${self.input.app_id}"
      PEM_FILE_PATH="${self.input.pem_file}"
      INSTALLATION_ID="${self.input.installation_id}"

      # Get current time and set the expiration (10 minutes from now)
      NOW=$(date +%s)
      EXPIRATION=$(($NOW + 600))

      # Create JWT header and payload
      HEADER=$(echo -n '{"alg":"RS256","typ":"JWT"}' | openssl base64 | tr -d '\n' | tr -d '=' | tr '/+' '_-')
      PAYLOAD=$(echo -n "{\"iat\":$NOW,\"exp\":$EXPIRATION,\"iss\":$APP_ID}" | openssl base64 | tr -d '\n' | tr -d '=' | tr '/+' '_-')

      # Combine header and payload
      HEADER_PAYLOAD="$HEADER.$PAYLOAD"

      # Sign the combined header and payload using the PEM file
      SIGNATURE=$(echo -n "$HEADER_PAYLOAD" | openssl dgst -sha256 -sign <(echo "$PEM_FILE") | openssl base64 | tr -d '\n' | tr -d '=' | tr '/+' '_-')

      # Generate the JWT
      JWT="$HEADER_PAYLOAD.$SIGNATURE"

      # Get the installation access token
      INSTALLATION_TOKEN=$(curl -X POST \
        -H "Authorization: Bearer $JWT" \
        -H "Accept: application/vnd.github+json" \
        https://api.github.com/app/installations/$INSTALLATION_ID/access_tokens \
        | jq -r '.token')

      curl --fail-with-body -X POST \
        -H "Accept: application/vnd.github.v3+json" \
        -H "Authorization: token $INSTALLATION_TOKEN" \
        https://api.github.com/repos/${self.input.github_owner}/${self.input.github_repo}/actions/workflows/${self.input.workflow_destroy_file_name}/dispatches \
        -d "{\"ref\":\"${self.input.workflow_branch}\", \"inputs\": {\"bb-run\":\"${self.input.meshstack_building_block_run_b64}\"}}"
    EOT
  }
}