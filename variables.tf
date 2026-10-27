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

variable "github_token_secret_id" {
  description = "The Secret Manager secret ID storing the GitHub authentication token for Cloud Run"
  type        = string
  default     = "github-auth-token"
}

variable "github_token_secret_version" {
  description = "The version of the Secret Manager secret holding the GitHub authentication token"
  type        = string
  default     = "latest"
}

variable "env_vars" {
  description = "Additional non-sensitive environment variables to pass to the Cloud Run container"
  type        = map(string)
  default     = {}
}

variable "env_secret_vars" {
  description = "Additional Secret Manager environment variable references (map of env var name to { secret, version }) for the Cloud Run container"
  type = map(object({
    secret  = string
    version = string
  }))
  default = {}
}

variable "enable_ssl" {
  description = "Enable managed SSL certificates and HTTP-to-HTTPS redirect on the Global Load Balancer"
  type        = bool
  default     = true
}

variable "ssl_certificates_domains" {
  description = "List of domains for the Load Balancer managed SSL certificate"
  type        = list(string)
  default     = ["app.example.com"]
}
