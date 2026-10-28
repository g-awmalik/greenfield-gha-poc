# ==============================================================================
# 7. ARTIFACT REGISTRY & CLOUD BUILD CI/CD PIPELINE
# ==============================================================================

module "artifact_registry" {
  source     = "GoogleCloudPlatform/artifact-registry/google"
  project_id = var.project_id
  location   = var.spanner_region
  format     = "DOCKER"
  repository_id = "app-containers"
  description   = "Container image registry for multi-regional Cloud Run services"
  immutable_tags = false
}

resource "google_cloudbuild_trigger" "main_branch_deploy" {
  name        = "deploy-on-main-push"
  project     = var.project_id
  location    = var.spanner_region
  description = "Build and deploy container image on push to main"

  github {
    owner = "g-awmalik"
    name  = "greenfield-gha-poc"
    push {
      branch = "^main$"
    }
  }

  build {
    step {
      name = "gcr.io/cloud-builders/docker"
      args = ["build", "-t", "${var.spanner_region}-docker.pkg.dev/${var.project_id}/app-containers/app:$SHORT_SHA", "."]
    }
    images = ["${var.spanner_region}-docker.pkg.dev/${var.project_id}/app-containers/app:$SHORT_SHA"]
  }
}
