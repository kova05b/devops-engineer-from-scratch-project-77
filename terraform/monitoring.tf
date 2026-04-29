resource "datadog_monitor" "app_http_health" {
  count = var.datadog_monitor_enabled ? 1 : 0

  name = "project-77 app http health"
  type = "service check"

  message = <<-EOT
  HTTP health check from Datadog Agent failed on one or more hosts.
  Domain: ${var.app_domain}
  EOT

  query = "\"http.can_connect\".over(\"instance:app-local-health\").by(\"host\").last(2).count_by_status()"

  monitor_thresholds {
    critical = 1
    warning  = 1
  }

  include_tags = true
  notify_no_data = true
  no_data_timeframe = 10

  tags = [
    "project:77",
    "service:web",
    "env:dev",
  ]
}
