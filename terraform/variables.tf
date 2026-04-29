variable "network_name" {
  description = "Existing VPC network name to reuse"
  type        = string
  default     = "project-devops-deploy-net"
}

variable "subnet_name" {
  description = "Existing subnet name to reuse"
  type        = string
  default     = "project-devops-deploy-subnet"
}

variable "vm_platform_id" {
  description = "YC compute platform"
  type        = string
  default     = "standard-v3"
}

variable "vm_cores" {
  description = "vCPU count per VM"
  type        = number
  default     = 2
}

variable "vm_memory" {
  description = "RAM in GB per VM"
  type        = number
  default     = 2
}

variable "vm_disk_size" {
  description = "Boot disk size in GB"
  type        = number
  default     = 20
}

variable "vm_image_family" {
  description = "Image family for web servers"
  type        = string
  default     = "ubuntu-2204-lts"
}

variable "vm_user" {
  description = "Default user created on VM"
  type        = string
  default     = "ubuntu"
}

variable "ssh_public_key" {
  description = "SSH public key content"
  type        = string
}

variable "ssh_cidr_blocks" {
  description = "CIDRs allowed to SSH to web VMs"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "project_name" {
  description = "Prefix for all resource names"
  type        = string
  default     = "project-77"
}

variable "lb_domain" {
  description = "Domain name used in self-signed cert"
  type        = string
  default     = "project-77.local"
}

variable "certificate_id" {
  description = "Existing Certificate Manager certificate ID for HTTPS listener"
  type        = string
  default     = "fpqb8dmi010ehoic1cv0"
}

variable "app_domain" {
  description = "Application domain (FQDN) that points to ALB"
  type        = string
}

variable "dns_zone_id" {
  description = "Existing DNS zone ID in Yandex Cloud for app domain"
  type        = string
}

variable "datadog_api_key" {
  description = "Datadog API key"
  type        = string
  sensitive   = true
  default     = ""
}

variable "datadog_app_key" {
  description = "Datadog application key"
  type        = string
  sensitive   = true
  default     = ""
}

variable "datadog_site" {
  description = "Datadog site domain suffix"
  type        = string
  default     = "datadoghq.eu"
}

variable "datadog_monitor_enabled" {
  description = "Create Datadog monitor via Terraform"
  type        = bool
  default     = false
}
