TF_DIR=terraform
TF=terraform
ANSIBLE_DIR=ansible
ANSIBLE_PLAYBOOK=playbook.yml
ANSIBLE_ENV=ANSIBLE_HOST_KEY_CHECKING=False
ANSIBLE_SSH_KEY=/home/administrator/.ssh/id_ed25519
ANSIBLE_VAULT_ARGS=

.PHONY: init fmt validate plan apply destroy output ansible-install ansible-inventory ansible-ping ansible-prepare ansible-deploy ansible-monitoring

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

ansible-install:
	cd $(ANSIBLE_DIR) && ansible-galaxy role install -r requirements.yml && ansible-galaxy collection install -r requirements.yml

ansible-inventory:
	printf "[web]\nweb-1 ansible_host=%s ansible_user=ubuntu ansible_ssh_private_key_file=%s\nweb-2 ansible_host=%s ansible_user=ubuntu ansible_ssh_private_key_file=%s ansible_ssh_common_args='-o ProxyJump=ubuntu@%s -o StrictHostKeyChecking=no'\n" "$$(cd $(TF_DIR) && $(TF) output -raw web_1_public_ip)" "$(ANSIBLE_SSH_KEY)" "$$(cd $(TF_DIR) && $(TF) output -raw web_2_private_ip)" "$(ANSIBLE_SSH_KEY)" "$$(cd $(TF_DIR) && $(TF) output -raw web_1_public_ip)" > $(ANSIBLE_DIR)/inventory.ini

ansible-ping:
	cd $(ANSIBLE_DIR) && $(ANSIBLE_ENV) ansible -i inventory.ini web -m ping

ansible-prepare:
	cd $(ANSIBLE_DIR) && $(ANSIBLE_ENV) ansible-playbook -i inventory.ini $(ANSIBLE_PLAYBOOK) --tags prepare $(ANSIBLE_VAULT_ARGS)

ansible-deploy:
	cd $(ANSIBLE_DIR) && $(ANSIBLE_ENV) ansible-playbook -i inventory.ini $(ANSIBLE_PLAYBOOK) --tags deploy $(ANSIBLE_VAULT_ARGS)

ansible-monitoring:
	cd $(ANSIBLE_DIR) && DATADOG_API_KEY="$$(python3 -c "import re; t=open('../terraform/terraform.tfvars', encoding='utf-8').read(); m=re.search(r'^datadog_api_key\\s*=\\s*\\\"([^\\\"]+)\\\"', t, re.M); print(m.group(1) if m else '')")" $(ANSIBLE_ENV) ansible-playbook -i inventory.ini $(ANSIBLE_PLAYBOOK) --tags monitoring --extra-vars "datadog_api_key=$$DATADOG_API_KEY" $(ANSIBLE_VAULT_ARGS)
