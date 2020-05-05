SHELL:= /bin/bash

UNAME_S := $(shell uname -s)
UNAME_S_LOWERCASE := $(shell echo $(UNAME_S) | tr A-Z a-z)

clean:
	-rm -Rf ./tmp ./venv ./terraform

install: | venv terraform
	@echo Creating venv and setting up terraform

terraform:
	@echo Setting up Terraform....
	@( \
	source ./venv/bin/activate; \
	mkdir tmp; \
        python -m wget -o ./tmp https://releases.hashicorp.com/terraform/0.12.23/terraform_0.12.23_$(UNAME_S_LOWERCASE)_amd64.zip; \
	python -m zipfile -e ./tmp/terraform_0.12.23_$(UNAME_S_LOWERCASE)_amd64.zip .; \
	chmod +x ./terraform; \
	)

venv: | virtualenv install-hooks

virtualenv: tox.ini requirements.txt
	@echo Setting up venv....
	tox -e venv

install-hooks: virtualenv
	@echo Adding pre-commit hooks...
	@( \
	venv/bin/pre-commit install -f --install-hooks; \
	venv/bin/pre-commit install -f --install-hooks --hook-type pre-push; \
	)

.terraform:
	@( \
	source ./venv/bin/activate; \
	./terraform init; \
	)

plan: .terraform check-os-env
	@( \
	source ./venv/bin/activate; \
	./terraform plan; \
	)

apply: .terraform
	@( \
	source ./venv/bin/activate; \
	./terraform apply; \
	)

check-os-env:
ifndef OS_PASSWORD
	$(error OS_PASSWORD is not set; have you sourced your openstack creds?)
endif
