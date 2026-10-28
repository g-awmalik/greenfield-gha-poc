# ==============================================================================
# 7. PUB/SUB ASYNCHRONOUS EVENT BUS
# ==============================================================================

resource "google_pubsub_topic" "dead_letter" {
  name    = "app-events-dead-letter"
  project = var.project_id
}

module "pubsub" {
  source  = "terraform-google-modules/pubsub/google"
  version = "~> 6.0"

  project_id = var.project_id
  topic      = "app-domain-events"

  grant_token_creator = false

  push_subscriptions = [
    {
      name                 = "cloudrun-events-push"
      push_endpoint        = "https://example-app.a.run.app/events"
      ack_deadline_seconds = 10
      expiration_policy    = ""
    }
  ]

  pull_subscriptions = [
    {
      name                 = "audit-worker-pull"
      ack_deadline_seconds = 20
    }
  ]
}
