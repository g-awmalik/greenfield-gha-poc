# ==============================================================================
# 7. CLOUD ARMOR EDGE SECURITY POLICY
# ==============================================================================

resource "google_compute_security_policy" "edge_waf" {
  name        = "global-app-edge-policy"
  project     = var.project_id
  description = "Edge security policy for global HTTP load balancer"

  rule {
    action   = "allow"
    priority = "2147483647"
    match {
      versioned_expr = "SRC_IPS_V1"
      config {
        src_ip_ranges = ["*"]
      }
    }
    description = "Default allow all traffic rule"
  }
}
