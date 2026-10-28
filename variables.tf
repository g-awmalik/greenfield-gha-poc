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
  description = "Whether to enable SSL/HTTPS on the Global Load Balancer"
  type        = bool
  default     = true
}

variable "ssl_certificates_domains" {
  description = "List of domains for the Google-managed SSL certificate"
  type        = list(string)
  default     = ["app.example.com"]
}

variable "enable_cdn" {
  description = "Whether to enable Cloud CDN on the Global Load Balancer default backend"
  type        = bool
  default     = true
}
