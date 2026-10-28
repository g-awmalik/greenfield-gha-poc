# ==============================================================================
# 7. CLOUD MONITORING UPTIME CHECKS & ALERT POLICIES
# ==============================================================================

resource "google_monitoring_notification_channel" "ops_email" {
  project      = var.project_id
  display_name = "On-Call Operations Email"
  type         = "email"
  labels = {
    email_address = var.ops_alert_email
  }
}

resource "google_monitoring_uptime_check_config" "lb_http_check" {
  project      = var.project_id
  display_name = "Global Load Balancer Uptime Check"
  timeout      = "10s"
  period       = "60s"

  http_check {
    path         = "/healthz"
    port         = "80"
    use_ssl      = false
    validate_ssl = false
  }

  monitored_resource {
    type = "uptime_url"
    labels = {
      project_id = var.project_id
      host       = module.lb-http.external_ip
    }
  }
}

resource "google_monitoring_alert_policy" "cloud_run_high_latency" {
  project      = var.project_id
  display_name = "Cloud Run High Request Latency"
  combiner     = "OR"

  conditions {
    display_name = "Cloud Run p99 latency > 2000ms"
    condition_threshold {
      filter          = "resource.type = \"cloud_run_revision\" AND metric.type = \"run.googleapis.com/request_latencies\""
      duration        = "60s"
      comparison      = "COMPARISON_GT"
      threshold_value = 2000
      aggregations {
        alignment_period     = "60s"
        per_series_aligner   = "ALIGN_PERCENTILE_99"
        cross_series_reducer = "REDUCE_MAX"
      }
    }
  }

  notification_channels = [google_monitoring_notification_channel.ops_email.name]
}
