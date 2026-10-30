output "spanner_instance_id" {
  description = "The ID of the provisioned Spanner instance"
  value       = module.spanner.spanner_instance_id
}

output "cloud_run_service_urls" {
  description = "A map of regions to their directly accessible public Cloud Run URLs"
  value = {
    for region, cr in module.cloud_run : region => cr.service_uri
  }
}
