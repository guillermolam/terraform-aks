#!/bin/sh
# install terramate with brew
brew install terramate

terramate create --all-terraform
# install terramate completions
terramate install-completions
terramate cloud login --github
terramate list
terramate run -- terraform init
terramate run --parallel 5 -- terraform plan -out plan.tfplan
terramate run --changed -- terraform apply -auto-approve plan.tfplan

terramate run \
	--sync-drift-status \
	--terraform-plan-file=drift.tfplan \
	--continue-on-error \
	-- \
	terraform plan -detailed-exitcode -out drift.tfplan
