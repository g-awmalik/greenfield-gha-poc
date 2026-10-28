# ==============================================================================
# 7. MEMORYSTORE FOR REDIS CACHE
# ==============================================================================

resource "google_redis_instance" "app_cache" {
  name           = "app-session-cache"
  project        = var.project_id
  region         = var.spanner_region
  tier           = "BASIC"
  memory_size_gb = 2
  redis_version  = "REDIS_7_0"
  display_name   = "Application Session Cache"

  maintenance_policy {
    weekly_maintenance_window {
      day = "SUNDAY"
      start_time {
        hours   = 3
        minutes = 0
      }
    }
  }
}
