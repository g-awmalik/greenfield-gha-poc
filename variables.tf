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

variable "vpc_cidr_block" {
  description = "Base IPv4 CIDR block used to derive regional /24 subnetwork ranges"
  type        = string
  default     = "10.10.0.0/16"
}

variable "enable_ssl" {
  description = "Enable SSL and HTTP-to-HTTPS redirect on the Global Load Balancer"
  type        = bool
  default     = true
}

variable "ssl_certificates_domains" {
  description = "List of domains for Google-managed SSL certificates on the Global Load Balancer"
  type        = list(string)
  default     = ["app.example.com"]
}
