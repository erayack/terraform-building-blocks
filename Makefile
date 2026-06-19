.PHONY: fmt validate test clean-local

TERRAFORM_DIRS := \
	01-foundation \
	02-abstraction \
	03-structural \
	04-dynamic \
	05-ecosystem-integration \
	06-operations-platform \
	07-real-world-project-layout/live/dev/network \
	07-real-world-project-layout/live/dev/app \
	07-real-world-project-layout/live/prod/network \
	07-real-world-project-layout/live/prod/app

fmt:
	terraform fmt -recursive

validate:
	@set -e; \
	for dir in $(TERRAFORM_DIRS); do \
		echo "==> $$dir"; \
		(cd $$dir && terraform init -backend=false -input=false >/dev/null && terraform validate); \
	done

test:
	cd 06-operations-platform && terraform test

clean-local:
	find . -type d -name .terraform -prune -exec rm -rf {} +
	find . -name .terraform.lock.hcl -delete
	rm -f plan.out plan.json tfplan *.tfplan
