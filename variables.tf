variable "project_id" {
  description = "The GCP Project ID"
  type        = string
  default     = "g4g-operate-demo"
}

variable "regions" {
  description = "Regions for the multi-regional Cloud Run deployment"
  type        = list(string)
  default     = ["us-central1", "us-east1"]
}

variable "spanner_region" {
  description = "The region for the Spanner instance (deprecated in favor of spanner_instance_config)"
  type        = string
  default     = "us-central1"
}

variable "spanner_instance_config" {
  description = "The instance configuration for the Spanner instance (e.g., 'nam3' multi-region)"
  type        = string
  default     = "nam3"
}

variable "spanner_processing_units" {
  description = "The number of processing units allocated to the Spanner instance (1000 processing units = 1 node)"
  type        = number
  default     = 1000

  validation {
    condition     = var.spanner_processing_units >= 100 && (var.spanner_processing_units < 1000 ? var.spanner_processing_units % 100 == 0 : var.spanner_processing_units % 1000 == 0)
    error_message = "Spanner processing_units must be at least 100, in increments of 100 below 1000, or increments of 1000 for 1000 and above."
  }
}

variable "container_image" {
  description = "The container image to deploy to Cloud Run"
  type        = string
  default     = "us-docker.pkg.dev/cloudrun/container/hello:latest"
}

variable "enable_ssl" {
  description = "Whether to enable SSL and HTTPS redirect on the Global Load Balancer"
  type        = bool
  default     = true
}

variable "ssl_certificates_domains" {
  description = "List of domains for Google-managed SSL certificates on the Global Load Balancer"
  type        = list(string)
  default     = ["app.example.com"]
}
