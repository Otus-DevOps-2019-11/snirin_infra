output "reddit_app_external_ips" {
  value = google_compute_instance.reddit-app[*].network_interface[0].access_config[0].nat_ip
}

output "reddit_app_load_balancing_ip" {
  value = google_compute_forwarding_rule.reddit-app-load-balancer.ip_address
}
