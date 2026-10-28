# ==============================================================================
# 7. CLOUD TASKS QUEUE & CLOUD SCHEDULER CRON JOB
# ==============================================================================

resource "google_cloud_tasks_queue" "background_tasks" {
  name     = "app-background-work-queue"
  project  = var.project_id
  location = var.spanner_region

  rate_limits {
    max_concurrent_dispatches = 500
    max_dispatches_per_second = 100
  }

  retry_config {
    max_attempts       = -1
    min_backoff        = "0.100s"
    max_backoff        = "3600s"
    max_doublings      = 16
  }
}

resource "google_cloud_scheduler_job" "nightly_compaction" {
  name             = "nightly-spanner-compaction"
  project          = var.project_id
  region           = var.spanner_region
  description      = "Triggers nightly background maintenance endpoint on Cloud Run"
  schedule         = "0 2 * * *"
  time_zone        = "Etc/UTC"
  attempt_deadline = "320s"

  http_target {
    http_method = "POST"
    uri         = "https://${module.lb-http.external_ip}/tasks/compact"
    body        = base64encode("{\"action\":\"compact\"}")
  }
}
