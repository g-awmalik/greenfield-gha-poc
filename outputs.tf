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

output "app_storage_bucket_name" {
  description = "The name of the application Cloud Storage bucket"
  value       = google_storage_bucket.test_unsecured_bucket.name
}

output "app_storage_bucket_url" {
  description = "The base URL of the application Cloud Storage bucket (gs://<bucket-name>)"
  value       = google_storage_bucket.test_unsecured_bucket.url
}
