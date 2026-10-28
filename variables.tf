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

variable "cloud_run_min_instances" {
  description = "Minimum number of instances for each regional Cloud Run service"
  type        = number
  default     = 1
}

variable "cloud_run_max_instances" {
  description = "Maximum number of instances for each regional Cloud Run service"
  type        = number
  default     = 10
}

variable "cloud_run_cpu" {
  description = "CPU limit for the Cloud Run container"
  type        = string
  default     = "1000m"
}

variable "cloud_run_memory" {
  description = "Memory limit for the Cloud Run container"
  type        = string
  default     = "512Mi"
}

variable "enable_ssl" {
  description = "Enable SSL on the Global Load Balancer"
  type        = bool
  default     = false
}

variable "ssl_certificates_domains" {
  description = "Domains for managed SSL certificates on the Global Load Balancer"
  type        = list(string)
  default     = []
}
