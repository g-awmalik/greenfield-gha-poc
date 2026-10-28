# ==============================================================================
# 7. BIGQUERY ANALYTICS WAREHOUSE & SCHEDULED TRANSFER
# ==============================================================================

module "bigquery_analytics" {
  source  = "terraform-google-modules/bigquery/google"
  version = "~> 8.0"

  dataset_id                  = "app_analytics_mart"
  dataset_name                = "Application Analytics Mart"
  description                 = "Aggregated application telemetry and business events"
  project_id                  = var.project_id
  location                    = "us-central1"
  delete_contents_on_destroy  = true
  default_table_expiration_ms = null

  tables = [
    {
      table_id           = "daily_request_metrics"
      schema             = "[]"
      time_partitioning  = null
      range_partitioning = null
      expiration_time    = null
      clustering         = []
      labels             = {}
    }
  ]
}

resource "google_bigquery_data_transfer_config" "daily_error_rollup" {
  display_name           = "Daily Error Logs Rollup"
  project                = var.project_id
  location               = "us-central1"
  data_source_id         = "scheduled_query"
  schedule               = "every 24 hours"
  destination_dataset_id = module.bigquery_analytics.bigquery_dataset.dataset_id
  params = {
    destination_table_name_template = "daily_request_metrics"
    write_disposition               = "WRITE_APPEND"
    query                           = "SELECT CURRENT_TIMESTAMP() AS run_ts"
  }
}
