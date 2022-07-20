resource "google_cloud_run_service" "dash" {
  name     = "dash"
  location = "us-central1"
  project  = var.project_id
  template {
    spec {
      containers {
        ports {
          name           = "http1"
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

resource "google_cloudbuild_trigger" "manual_trigger_cloudbuild_yaml" {
  name    = "manual-trigger-cloudbuild-yaml"
  project = var.project_id
  source_to_build {
    uri       = "https://github.com/rogerthatdev/cloudbuild-fio"
    ref       = "refs/heads/terraform"
    repo_type = "GITHUB"
  }

  git_file_source {
    path      = "cloudbuild.yaml"
    uri       = "https://github.com/rogerthatdev/cloudbuild-fio"
    revision  = "refs/heads/terraform"
    repo_type = "GITHUB"
  }

  approval_config {
    approval_required = true
  }
}
# using dockerfile instead
resource "google_cloudbuild_trigger" "manual_trigger_dockerfile" {
  name    = "manual-trigger-dockerfile"
  project = var.project_id
  source_to_build {
    uri       = "https://github.com/rogerthatdev/cloudbuild-fio"
    ref       = "refs/heads/terraform"
    repo_type = "GITHUB"
  }

  build {
    images = [
      "gcr.io/cloudbuild-fio-b549/github.com/rogerthatdev/cloudbuild-fio:$COMMIT_SHA",
    ]
    substitutions = {}
    tags          = []
    step {
      args = [
        "build",
        "-t",
        "gcr.io/cloudbuild-fio-b549/github.com/rogerthatdev/cloudbuild-fio:$COMMIT_SHA",
        ".",
      ]
      dir        = "dashboard"
      env        = []
      name       = "gcr.io/cloud-builders/docker"
      secret_env = []
      wait_for   = []
    }
  }

  approval_config {
    approval_required = true
  }
}


resource "google_cloudbuild_trigger" "manual_trigger_cloudbuild_yaml_inline" {
  name    = "manual-trigger-cloudbuild-yaml-inline"
  project = var.project_id
  source_to_build {
    uri       = "https://github.com/rogerthatdev/cloudbuild-fio"
    ref       = "refs/tags/latest"
    repo_type = "GITHUB"
  }

  build {
        images        = []
        substitutions = {
            "_REGION" = "us-central1"
            "_TAG"    = "latest"
            }
        tags          = []

        step {
            args       = [
                "build",
                "--tag",
                "gcr.io/$PROJECT_ID/fourkeys-grafana-dashboard:${"$"}{_TAG}",
                ".",
                ]
            env        = []
            id         = "build"
            name       = "gcr.io/cloud-builders/docker:latest"
            secret_env = []
            wait_for   = []
            }
        step {
            args       = [
                "push",
                "gcr.io/$PROJECT_ID/fourkeys-grafana-dashboard:${"$"}{_TAG}",
                ]
            env        = []
            id         = "push"
            name       = "gcr.io/cloud-builders/docker"
            secret_env = []
            wait_for   = []
            }
        step {
            args       = [
                "gcloud",
                "run",
                "deploy",
                "fourkeys-grafana-dashboard",
                "--image",
                "gcr.io/$PROJECT_ID/fourkeys-grafana-dashboard:${"$"}{_TAG}",
                "--region",
                "${"$"}{_REGION}",
                "--platform",
                "managed",
                "--port",
                "3000",
                "--allow-unauthenticated",
                ]
            env        = []
            id         = "deploy"
            name       = "google/cloud-sdk"
            secret_env = []
            wait_for   = []
            }
        }

  approval_config {
    approval_required = true
  }
}