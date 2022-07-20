resource "google_cloud_run_service" "dash" {
  name     = "dash"
  location = "us-central1"
  project = var.project_id
  template {
    spec {
      containers {
        ports {
          name  = "http1"
          container_port = 3000
        }
        # image = "us-central1-docker.pkg.dev/${var.project_id}/dashboard/dash"
        image = "us-central1-docker.pkg.dev/${var.project_id}/dashboard/dash:first"
      }
      service_account_name = "project-service-account@${var.project_id}.iam.gserviceaccount.com"
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }
  metadata {

  }
  autogenerate_revision_name = true
}

resource "google_cloud_run_service_iam_binding" "dash_noauth" {
  location   = var.region
  project    = var.project_id
  service    = google_cloud_run_service.dash.name
  role       = "roles/run.invoker"
  members    = ["allUsers"]
  depends_on = [google_cloud_run_service.dash]
}

