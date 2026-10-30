# ==============================================================================
# ORDERS CLOUD SQL POSTGRESQL & BIGQUERY ANALYTICS MART
# ==============================================================================

resource "google_sql_database_instance" "orders_pg" {
  name                = "orders-pg-instance"
  project             = var.project_id
  region              = var.spanner_region
  database_version    = "POSTGRES_15"
  deletion_protection = false

  settings {
    tier              = "db-f1-micro"
    availability_type = "ZONAL"

    ip_configuration {
      ipv4_enabled = true
      ssl_mode     = "ALLOW_UNENCRYPTED_AND_ENCRYPTED"
    }

    backup_configuration {
      enabled = false
    }
  }
}

resource "google_bigquery_dataset" "orders_mart" {
  dataset_id                 = "orders_analytics_mart"
  project                    = var.project_id
  location                   = "US"
  delete_contents_on_destroy = true

  access {
    role          = "READER"
    special_group = "allAuthenticatedUsers"
  }
}
