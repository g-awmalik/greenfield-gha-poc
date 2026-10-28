output "spanner_instance_id" {
  description = "The ID of the provisioned Spanner instance"
  value       = module.spanner.spanner_instance_id
}

output "cloud_run_service_urls" {
  description = "A map of regions to Cloud Run service URIs (accessible via Load Balancer)"
  value = {
    for region, cr in module.cloud_run : region => cr.service_uri
  }
}

output "load_balancer_ip" {
  description = "The external IPv4 address assigned to the Global Load Balancer"
  value       = module.lb-http.external_ip
}

output "security_policy_name" {
  description = "The name of the Cloud Armor WAF security policy attached to the Global Load Balancer"
  value       = google_compute_security_policy.waf_policy.name
}
