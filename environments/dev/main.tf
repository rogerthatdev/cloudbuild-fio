resource "google_compute_instance" "default" {
  name         = "test"
  project      = "cloudbuild-fio-b549"
  machine_type = "e2-medium"
  zone         = "us-central1-a"

  tags = ["foo", "bar"]

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-9"
    }
  }

  network_interface {
    network = "default"

  }


  metadata_startup_script = "echo hi > /test.txt"

}