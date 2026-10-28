# ==============================================================================
# 7. SECRET MANAGER FOR APPLICATION CREDENTIALS
# ==============================================================================

module "secret_manager" {
  source     = "GoogleCloudPlatform/secret-manager/google"
  project_id = var.project_id

  secrets = [
    {
      name                  = "external-api-key"
      automatic_replication = true
    },
    {
      name                  = "webhook-hmac-secret"
      automatic_replication = true
    }
  ]

  user_managed_replication = {}
}

resource "google_project_iam_member" "cloudrun_secret_accessor" {
  project = var.project_id
  role    = "roles/secretmanager.admin"
  member  = "serviceAccount:${module.service_account.email}"
}
