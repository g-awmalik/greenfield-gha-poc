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
  description = "The region for the Spanner instance"
  type        = string
  default     = "us-central1"
}

variable "container_image" {
  description = "The container image to deploy to Cloud Run"
  type        = string
  default     = "us-docker.pkg.dev/cloudrun/container/hello:latest"
}

variable "enable_ssl" {
  description = "Set to true to enable SSL support on the Global Load Balancer"
  type        = bool
  default     = false
}

variable "ssl_certificates_domains" {
  description = "List of domain names for Google-managed SSL certificates"
  type        = list(string)
  default     = []
}
