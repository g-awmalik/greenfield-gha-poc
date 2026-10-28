# ==============================================================================
# 7. CLOUD KMS KEYRING AND CRYPTO KEYS
# ==============================================================================

module "kms" {
  source  = "terraform-google-modules/kms/google"
  version = "~> 2.2"

  project_id           = var.project_id
  location             = var.spanner_region
  keyring              = "app-encryption-keyring"
  key_rotation_period  = "31536000s"
  keys                 = ["storage-encryption-key", "spanner-backup-key"]
  prevent_destroy      = false

  set_owners_for = ["storage-encryption-key", "spanner-backup-key"]
  owners = [
    "serviceAccount:${module.service_account.email}",
    "serviceAccount:${module.service_account.email}"
  ]
}
