.PHONY: clean

repo := $(shell git rev-parse --show-toplevel)
cur_dir := $(shell pwd)

show:
	echo ${repo}; 
	echo ${cur_dir};

purge:
	find ${repo} -type f -name \*.tfstate* -exec rm {} \;
	find ${repo} -type f -name \*.tfplan -exec rm {} \;
	find ${repo} -type d -name .terraform | xargs rm -rf {} \;
	find ${repo} -type f -name .terraform.lock.hcl -exec rm {} \;
	find ${repo} -type f -name .DS_Store -exec rm {} \;

acl:
	find ${repo} -name \*.tf -exec chmod 644 {} \;
	find ${repo} -name \*.tfvars -exec chmod 644 {} \;
	find ${repo} -name \*.txt -exec chmod 644 {} \;

tfplan = /tmp/az.tfplan
authfile = ../creds.tfvars

init:
	terraform init
fmt:
	terraform fmt -recursive
plan:
	terraform plan -out ${tfplan} -var-file ${authfile}
apply:
	terraform apply ${tfplan}
refresh:
	terraform apply -refresh -auto-approve -var-file ${authfile}
destroy:
	terraform destroy -auto-approve -var-file ${authfile}

clean: fmt acl purge
