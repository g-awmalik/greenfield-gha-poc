# ==============================================================================
# 7. VPC NETWORK & SERVERLESS VPC ACCESS CONNECTORS
# ==============================================================================

module "vpc" {
  source  = "terraform-google-modules/network/google"
  version = "~> 9.0"

  project_id   = var.project_id
  network_name = "app-main-vpc"
  routing_mode = "REGIONAL"

  subnets = [
    {
      subnet_name           = "app-subnet-us-central1"
      subnet_ip             = "10.10.1.0/24"
      subnet_region         = "us-central1"
      subnet_private_access = "false"
      subnet_flow_logs      = "false"
    },
    {
      subnet_name           = "app-subnet-us-east1"
      subnet_ip             = "10.10.2.0/24"
      subnet_region         = "us-east1"
      subnet_private_access = "false"
      subnet_flow_logs      = "false"
    }
  ]
}

resource "google_vpc_access_connector" "serverless" {
  for_each      = toset(var.regions)
  name          = "cr-vpc-${each.key}"
  project       = var.project_id
  region        = each.key
  network       = module.vpc.network_name
  ip_cidr_range = each.key == "us-central1" ? "10.8.0.0/28" : "10.8.1.0/28"
  min_throughput = 200
  max_throughput = 300
}
