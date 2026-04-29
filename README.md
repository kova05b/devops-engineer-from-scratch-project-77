### Hexlet tests and linter status:
[![Actions Status](https://github.com/kova05b/devops-engineer-from-scratch-project-77/actions/workflows/hexlet-check.yml/badge.svg)](https://github.com/kova05b/devops-engineer-from-scratch-project-77/actions)

## Task 1 bootstrap

Project structure for the first task:

- `terraform/` - Terraform infrastructure files
- `ansible/` - Ansible files and vault secrets

Implemented requirements:

- Provider settings are in `terraform/provider.tf`
- Backend settings are in `terraform/backend.tf`
- Sensitive values are expected from external variables (`terraform.tfvars` or env vars)
- Terraform local state files are ignored by git