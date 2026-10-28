terraform {
  required_version = ">= 1.5.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 5.0.0, < 7.0.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.5.0"
    }
  }
}

provider "google" {
  project = var.project_id
}

# ==============================================================================
# 1. IAM & SERVICE ACCOUNTS
# ==============================================================================
module "service_account" {
  source  = "terraform-google-modules/service-accounts/google"
  version = "~> 4.0"

  project_id   = var.project_id
  names        = ["app-cloudrun-sa"]
  display_name = "Cloud Run App Service Account"
  description  = "Identity for Cloud Run to access Spanner"
}

# ==============================================================================
# 2. REGIONAL SPANNER INSTANCE
# ==============================================================================
module "spanner" {
  source = "GoogleCloudPlatform/cloud-spanner/google"

  project_id            = var.project_id
  instance_name         = "regional-app-db"
  instance_config       = "regional-${var.spanner_region}"
  instance_display_name = "Regional Application Spanner"
  instance_size = {
    num_nodes = 1
  }
  database_config = {
    "app-database" = {
      version_retention_period = "7d"
      ddl                      = []
      deletion_protection      = true
      database_iam             = []
      enable_backup            = true
      backup_retention         = "259200s" # 3 days
      create_db                = true
    }
  }
}

# Grant the Cloud Run Service Account access to the Spanner Database
resource "google_spanner_database_iam_member" "spanner_db_user" {
  project  = var.project_id
  instance = module.spanner.spanner_instance_id
  database = "app-database"
  role     = "roles/spanner.databaseUser"
  member   = "serviceAccount:${module.service_account.email}"
}

# ==============================================================================
# 3. MULTI-REGIONAL CLOUD RUN SERVICES (DIRECT PUBLIC ACCESS)
# ==============================================================================
module "cloud_run" {
  source = "GoogleCloudPlatform/cloud-run/google//modules/v2"

  for_each = toset(var.regions)

  project_id             = var.project_id
  location               = each.key
  service_name           = "app-service-${each.key}"
  create_service_account = false
  service_account        = module.service_account.email
  ingress                = "INGRESS_TRAFFIC_INTERNAL_LOAD_BALANCER"

  members = ["allUsers"]

  containers = [
    {
      container_image = var.container_image
      env_vars = {
        SPANNER_PROJECT_ID  = var.project_id
        SPANNER_INSTANCE_ID = element(split("/", module.spanner.spanner_instance_id), length(split("/", module.spanner.spanner_instance_id)) - 1)
        SPANNER_DATABASE_ID = "app-database"
      }
    }
  ]
}

# ==============================================================================
# 4. GLOBAL LOAD BALANCER FRONTING CLOUD RUN
# ==============================================================================

# Serverless NEGs
resource "google_compute_region_network_endpoint_group" "serverless_neg" {
  for_each              = toset(var.regions)
  name                  = "serverless-neg-${each.key}"
  network_endpoint_type = "SERVERLESS"
  region                = each.key
  project               = var.project_id
  cloud_run {
    service = module.cloud_run[each.key].service_name
  }
}

module "lb-http" {
  source  = "GoogleCloudPlatform/lb-http/google//modules/serverless_negs"
  version = "~> 12.0"

  project = var.project_id
  name    = "global-app-lb"

  ssl                             = var.enable_ssl
  managed_ssl_certificate_domains = var.ssl_certificates_domains
  https_redirect                  = var.enable_ssl
  backends = {
    default = {
      description = "Serverless NEGs routing to multi-regional Cloud Run"
      groups = [
        for neg in google_compute_region_network_endpoint_group.serverless_neg : {
          group = neg.id
        }
      ]
      enable_cdn              = false
      security_policy         = null
      custom_request_headers  = null
      custom_response_headers = null

      iap_config = {
        enable               = false
        oauth2_client_id     = ""
        oauth2_client_secret = ""
      }
      log_config = {
        enable      = true
        sample_rate = 1.0
      }
    }
  }
}

# ==============================================================================
# 5. LOG EXPORT (SINK)
# ==============================================================================

module "log_export" {
  source                 = "terraform-google-modules/log-export/google"
  version                = "~> 11.0"
  destination_uri        = module.destination.destination_uri
  filter                 = "severity >= ERROR"
  log_sink_name          = "bigquery_error_logsink"
  parent_resource_id     = var.project_id
  parent_resource_type   = "project"
  unique_writer_identity = true
}

resource "random_string" "suffix" {
  length  = 4
  upper   = false
  special = false
}

module "destination" {
  source  = "terraform-google-modules/log-export/google//modules/bigquery"
  version = "~> 11.0"

  project_id               = var.project_id
  dataset_name             = "bq_org_${random_string.suffix.result}"
  log_sink_writer_identity = module.log_export.writer_identity
}

resource "google_storage_bucket" "test_unsecured_bucket" {
  name                        = "${var.project_id}-app-storage-${random_string.suffix.result}"
  location                    = "US"
  project                     = var.project_id
  force_destroy               = false
  uniform_bucket_level_access = true
  public_access_prevention    = "enforced"

  versioning {
    enabled = true
  }
}

# Removed public IAM binding to allUsers to prevent unauthorized data exposure

# ==============================================================================
# 6. CLOUD MONITORING NOTIFICATION CHANNEL & ALERT POLICIES
# ==============================================================================

resource "google_monitoring_notification_channel" "email" {
  project      = var.project_id
  display_name = "Primary Alert Email Notification Channel"
  type         = "email"
  labels = {
    email_address = var.alert_notification_email
  }
}

resource "google_monitoring_alert_policy" "cloud_run_5xx_errors" {
  project      = var.project_id
  display_name = "Cloud Run 5xx Error Alert"
  combiner     = "OR"
  enabled      = true

  conditions {
    display_name = "Cloud Run 5xx Request Count Exceeds Threshold (5m)"
    condition_threshold {
      filter          = "resource.type = \"cloud_run_revision\" AND metric.type = \"run.googleapis.com/request_count\" AND metric.labels.response_code_class = \"5xx\""
      duration        = "300s"
      comparison      = "COMPARISON_GT"
      threshold_value = 5

      aggregations {
        alignment_period     = "300s"
        per_series_aligner   = "ALIGN_SUM"
        cross_series_reducer = "REDUCE_SUM"
        group_by_fields      = ["resource.label.service_name", "resource.label.location"]
      }
    }
  }

  notification_channels = [
    google_monitoring_notification_channel.email.id
  ]

  documentation {
    content   = "Cloud Run revision is returning an elevated rate of HTTP 5xx server errors over a 5-minute window. Inspect Cloud Run revision logs and downstream Cloud Spanner health."
    mime_type = "text/markdown"
  }
}

resource "google_monitoring_alert_policy" "spanner_high_cpu" {
  project      = var.project_id
  display_name = "Spanner High CPU Alert"
  combiner     = "OR"
  enabled      = true

  conditions {
    display_name = "Spanner Instance CPU Utilization > 65% for 5m"
    condition_threshold {
      filter          = "resource.type = \"spanner_instance\" AND metric.type = \"spanner.googleapis.com/instance/cpu/utilization\""
      duration        = "300s"
      comparison      = "COMPARISON_GT"
      threshold_value = 0.65

      aggregations {
        alignment_period     = "60s"
        per_series_aligner   = "ALIGN_MEAN"
        cross_series_reducer = "REDUCE_MEAN"
        group_by_fields      = ["resource.label.instance_id"]
      }
    }
  }

  notification_channels = [
    google_monitoring_notification_channel.email.id
  ]

  documentation {
    content   = "Cloud Spanner instance CPU utilization has exceeded 65% (0.65) for 5 consecutive minutes. Check for hotspotting, unindexed queries, or increase node capacity to maintain regional SLA."
    mime_type = "text/markdown"
  }
}
