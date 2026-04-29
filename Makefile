TF_DIR=terraform
TF=terraform

.PHONY: init fmt validate plan apply destroy output

init:
	cd $(TF_DIR) && $(TF) init

fmt:
	cd $(TF_DIR) && $(TF) fmt -recursive

validate:
	cd $(TF_DIR) && $(TF) validate

plan:
	cd $(TF_DIR) && $(TF) plan -var-file=terraform.tfvars

apply:
	cd $(TF_DIR) && $(TF) apply -var-file=terraform.tfvars

destroy:
	cd $(TF_DIR) && $(TF) destroy -var-file=terraform.tfvars

output:
	cd $(TF_DIR) && $(TF) output
