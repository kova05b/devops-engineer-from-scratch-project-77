output "web_vm_public_ips" {
  description = "Public IPs of web VMs"
  value       = { for k, vm in yandex_compute_instance.web : k => vm.network_interface[0].nat_ip_address }
}

output "web_1_public_ip" {
  description = "Public IP of web-1 VM"
  value       = yandex_compute_instance.web["web-1"].network_interface[0].nat_ip_address
}

output "web_2_public_ip" {
  description = "Public IP of web-2 VM"
  value       = yandex_compute_instance.web["web-2"].network_interface[0].nat_ip_address
}

output "web_2_private_ip" {
  description = "Private IP of web-2 VM"
  value       = yandex_compute_instance.web["web-2"].network_interface[0].ip_address
}

output "web_vm_private_ips" {
  description = "Private IPs of web VMs"
  value       = { for k, vm in yandex_compute_instance.web : k => vm.network_interface[0].ip_address }
}

output "alb_public_ip" {
  description = "Public IP of HTTPS load balancer"
  value       = one(yandex_alb_load_balancer.web.listener).endpoint[0].address[0].external_ipv4_address[0].address
}

output "https_url" {
  description = "HTTPS endpoint URL"
  value       = "https://${one(yandex_alb_load_balancer.web.listener).endpoint[0].address[0].external_ipv4_address[0].address}"
}

output "app_domain_url" {
  description = "HTTPS URL of application domain"
  value       = "https://${var.app_domain}"
}

output "datadog_monitor_id" {
  description = "Datadog monitor ID for HTTP health"
  value       = var.datadog_monitor_enabled ? datadog_monitor.app_http_health[0].id : null
}
