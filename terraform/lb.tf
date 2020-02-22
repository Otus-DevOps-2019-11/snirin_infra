resource "google_compute_http_health_check" "reddit-app-hc" {
  name               = "reddit-app-hc-checks"
  request_path       = "/"
  port               = 9292
  check_interval_sec = 3
  timeout_sec        = 3
}

resource "google_compute_target_pool" "reddit-app-pool" {
  name = "reddit-app-pool"

  instances = google_compute_instance.reddit-app.*.self_link

  health_checks = [
    google_compute_http_health_check.reddit-app-hc.name
  ]
}

resource "google_compute_forwarding_rule" "reddit-app-load-balancer" {
  name                  = "reddit-app-lb"
  region                = var.region
  target                = google_compute_target_pool.reddit-app-pool.self_link
  port_range            = "9292"
  ip_protocol           = "TCP"
  load_balancing_scheme = "EXTERNAL"
}
