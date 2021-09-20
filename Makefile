repo     := $(shell git rev-parse --show-toplevel)
cur_dir  := $(shell pwd)
tfplan   = /tmp/az.tfplan
authfile = ../creds.tfvars

help:
	@echo "\n\tAvailable make Targets:\n"
	@grep PHONY: Makefile | cut -d: -f2 | sed '1d;s/^/make/'

show:
	echo ${repo};
	echo ${cur_dir};

.PHONY: purge # delete tfstate and .terrform dir
purge:
	find ${repo} -type f -name \*.tfstate* -exec rm {} \;
	find ${repo} -type f -name \*.tfplan -exec rm {} \;
	find ${repo} -type d -name .terraform | xargs rm -rf {} \;
	find ${repo} -type f -name .terraform.lock.hcl -exec rm {} \;
	find ${repo} -type f -name .DS_Store -exec rm {} \;

.PHONY: acl # chmod to 644
acl:
	find ${repo} -name \*.tf -exec chmod 644 {} \;
	find ${repo} -name \*.tfvars -exec chmod 644 {} \;
	find ${repo} -name \*.txt -exec chmod 644 {} \;

.PHONY: azlogout # logout of Azure
azlogout:
	az logout; \
	rm -rf ~/.azure ;\


playbooks = az_rg_stacct.yml ca509.yml
.PHONY: remotestate # create storage account, container for remote state
remotestate:
	cd ${cur_dir}/ansible; \
	ansible-playbook ${playbooks}

.PHONY: packer_build
packer_build:
	cd ${cur_dir}/packer; \
	pwd; \
	packer build -var-file variables.pkrvars.hcl .

.PHONY: init
init:
	terraform init

.PHONY: fmt
fmt:
	terraform fmt -recursive

.PHONY: plan
plan:
	terraform plan -out ${tfplan}

.PHONY: apply
apply:
	terraform apply ${tfplan}

.PHONY: refresh
refresh:
	terraform apply -refresh -auto-approve

.PHONY: destroy
destroy:
	terraform destroy -auto-approve

.PHONY: tf_all
tf_all: remotestate packer_build init plan apply

.PHONY: clean
clean: fmt acl purge
