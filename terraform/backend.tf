terraform {
  backend "s3" {
    endpoint   = "storage.yandexcloud.net"
    bucket     = "projectdevopsdeploy"
    key        = "project-77/terraform.tfstate"
    region     = "ru-central1"
    use_path_style = true

    skip_region_validation      = true
    skip_credentials_validation = true
  }
}
