# AKS CLuster

## Infra as Code

Terraform - Code

Terraform - URL_ADDRESS.terraform.io/

## Linters

Trunk.io
Terrascan
KICS - https://kics.checkmarx.net/

## ** Stacks/Drifting/State **

Terramate - https://cloud.terramate.io/ | https://cloud.terramate.io/o/guillermo-org/home
Spacelift - https://guillermolam.app.spacelift.io/

## ** AI Diagrams **

https://www.eraser.io/ai/terraform-diagram-generator

```bash
terraform init ## initialize working directory and download required modules and providers
terraform init -backend=false ## skip backend initialization and use local state only
terraform init -backend-config="bucket=mybucket" ## set the S3 bucket for remote state storage
terraform init -backend-config="key=state/terraform.tfstate" ## specify the remote state file path
terraform init -backend-config="region=us-west-2" ## configure AWS region for the S3 backend
terraform init -backend-config=backend.hcl ## load backend settings from an HCL file
terraform init -reconfigure ## ignore existing backend config and reinitialize from scratch
terraform init -upgrade ## upgrade all modules and providers to the latest allowed versions
terraform init -get=false ## skip downloading modules (useful if you’ve already fetched them)
terraform init -get=true ## explicitly fetch modules even if they’re present (default behavior)
terraform init -input=false ## disable interactive input prompts (ideal for CI/CD)
terraform init -input=true ## enable interactive prompts (default behavior)
terraform init -plugin-dir=./plugins ## install providers into a custom plugins directory
terraform init -force-copy ## reinitialize even if a .terraform directory already exists
terraform init -verify-plugins=false ## disable provider checksum verification
terraform init -verify-plugins=true ## enable provider checksum verification (default)
terraform init -migrate-state ## automatically migrate state to the latest format if needed
terraform init -lock=false ## do not lock the state file during initialization
terraform init -lock=true ## lock the state file to prevent concurrent operations (default)
terraform init -lock-timeout=2m ## wait up to 2 minutes to acquire the state lock
terraform init -no-color ## disable ANSI color codes in output
terraform init -from-module=./modules/vpc ## pull in a local VPC module at init time
terraform init -from-module=git::https://github.com/terraform-aws-modules/vpc.git ## initialize using a remote Git module
terraform init -get-plugins ## (legacy) force download of provider plugins even if cached
terraform init -backend-config="access_key=AKIA..." ## pass an AWS access key to the backend
terraform init -backend-config="secret_key=SECRET" ## pass an AWS secret key to the backend
terraform init -backend-config="endpoint=https://minio.local" ## set custom S3-compatible endpoint
terraform init -plugin-dir=/opt/terraform/plugins ## specify an absolute path for provider plugins
terraform init -upgrade -reconfigure ## reconfigure backend and upgrade modules/providers in one step
terraform init -reconfigure -no-color ## reinitialize backend quietly without color output
```

```bash
terraform test ## execute all test files in the default “tests” directory :contentReference[oaicite:0]{index=0}
terraform test -filter=tests/validations.tftest.hcl ## run only the specified test file :contentReference[oaicite:1]{index=1}
terraform test -filter='tests/*.tftest.hcl' ## run all tests matching the wildcard pattern :contentReference[oaicite:2]{index=2}
terraform test -test-directory=integration_tests ## search for tests in a custom “integration_tests” directory :contentReference[oaicite:3]{index=3}
terraform test -json ## output test results in machine-readable JSON format :contentReference[oaicite:4]{index=4}
terraform test -junit-xml=./test-report.xml ## save test report in JUnit XML format to “test-report.xml” :contentReference[oaicite:5]{index=5}
terraform test -verbose ## print detailed plan/apply output for each `run` block :contentReference[oaicite:6]{index=6}
terraform test -parallelism=5 ## limit concurrent plan/apply operations within tests to 5 :contentReference[oaicite:7]{index=7}
terraform test -cloud-run=registry.example.com/org/module ## execute tests remotely on Terraform Cloud private registry :contentReference[oaicite:8]{index=8}
terraform test -filter=tests/outputs.tftest.hcl -json ## run a specific test file and output JSON :contentReference[oaicite:9]{index=9}
terraform test -filter=tests/outputs.tftest.hcl -junit-xml=./outputs.xml ## run and export JUnit XML report for the “outputs” tests :contentReference[oaicite:10]{index=10}
terraform test -filter=tests/outputs.tftest.hcl -verbose ## run a specific test with detailed output logs :contentReference[oaicite:11]{index=11}
terraform test -test-directory=specs -parallelism=3 ## use “specs” as test directory with up to 3 concurrent operations :contentReference[oaicite:12]{index=12}
terraform test -test-directory=tests/integration -json ## load tests from “specs” and output JSON :contentReference[oaicite:13]{index=13}
terraform test -test-directory=specs -verbose ## load tests from “specs” with verbose run block output :contentReference[oaicite:14]{index=14}
terraform test -cloud-run=registry.example.com/org/module -json ## remote execution with JSON-formatted results :contentReference[oaicite:15]{index=15}
terraform test -cloud-run=registry.example.com/org/module -junit-xml=remote-report.xml ## remote tests with JUnit XML report :contentReference[oaicite:16]{index=16}
terraform test -cloud-run=registry.example.com/org/module -filter=tests/validations.tftest.hcl ## remote execution of a specific test file :contentReference[oaicite:17]{index=17}
terraform test -json -junit-xml=combined-report.xml ## output both JSON and JUnit XML formats simultaneously :contentReference[oaicite:18]{index=18}
terraform test -filter=tests/validations.tftest.hcl -parallelism=1 ## run a single test file with serialized operations (parallelism=1) :contentReference[oaicite:19]{index=19}

```

```bash
terraform state list ## list all resources in the Terraform state
terraform state list -state=prod.tfstate ## list resources from a specific state file
terraform state list module.database.aws_db_instance.example ## list resources matching a module path
terraform state list -module-depth=1 ## limit listing to top-level modules only
terraform state list -no-color ## disable ANSI color in the output
terraform state list -json ## output the list in JSON format for tooling

terraform state show aws_instance.web ## display detailed state for a specific resource
terraform state show aws_instance.web -state=staging.tfstate ## show resource from an alternate state
terraform state show aws_instance.web -no-color ## remove color codes from the display
terraform state show aws_instance.web -json ## print the resource state in JSON

terraform state mv module.old.aws_s3_bucket.bucket module.new.aws_s3_bucket.bucket ## rename or move a resource
terraform state mv module.old.aws_s3_bucket.bucket module.new.aws_s3_bucket.bucket -state=old.tfstate ## specify input state file
terraform state mv module.old.aws_s3_bucket.bucket module.new.aws_s3_bucket.bucket -state-out=new.tfstate ## write result to a fresh state file
terraform state mv module.old.aws_s3_bucket.bucket module.new.aws_s3_bucket.bucket -lock=false ## skip locking during move
terraform state mv module.old.aws_s3_bucket.bucket module.new.aws_s3_bucket.bucket -lock-timeout=2m ## wait 2 minutes for state lock

terraform state rm aws_instance.temp ## remove a resource from the state
terraform state rm aws_instance.temp -state=dev.tfstate ## drop a resource from a specific state file
terraform state rm aws_instance.temp -lock=false ## disable state locking when removing
terraform state rm aws_instance.temp -lock-timeout=1m ## wait 1 minute for lock to remove
terraform state rm 'module.cache.*' ## bulk-remove all resources in “module.cache”

terraform state pull ## fetch remote state and write to stdout
terraform state pull -state=remote.tfstate ## override default remote state address
terraform state pull -no-color ## pull without ANSI color codes
terraform state pull -lock=false ## skip locking the state during pull
terraform state pull -lock-timeout=30s ## wait 30 seconds to acquire state lock

terraform state push ## upload a local state file to remote
terraform state push --force ## bypass safety checks when pushing
terraform state push -state=local.tfstate ## specify the local state to push
terraform state push -lock=false ## disable state locking during push
terraform state push -lock-timeout=30s ## wait 30 seconds for push lock

terraform state replace-provider registry.terraform.io/old/namespace registry.terraform.io/new/namespace ## swap provider references in state
terraform state replace-provider registry.terraform.io/old/namespace registry.terraform.io/new/namespace -state=prod.tfstate ## target a specific state
terraform state replace-provider registry.terraform.io/old/namespace registry.terraform.io/new/namespace -state-out=updated.tfstate ## output to a new state file
terraform state replace-provider registry.terraform.io/old/namespace registry.terraform.io/new/namespace -lock=false ## skip lock for provider swap
terraform state replace-provider registry.terraform.io/old/namespace registry.terraform.io/new/namespace -lock-timeout=1m ## wait 1 minute for lock

terraform state mv 'module.old.*' 'module.new.*' ## bulk-move multiple resources with wildcards
terraform state show 'aws_instance.web[0]' ## show the first instance in a counted resource
terraform state list 'module.foo' -module-depth=2 ## list resources two levels deep in module foo
terraform state rm 'module.bar.*' ## remove all resources under module bar
terraform state --help ## show help for the “state” subcommands
```

```bash
terraform plan -out=plan.tfplan ## save the execution plan to a file for later apply and review
terraform plan -detailed-exitcode ## exit code 2 if changes present, ideal for CI pipelines
terraform plan -destroy ## generate a plan to destroy all managed resources
terraform plan -var='env=prod' ## override variable “env” on the command line
terraform plan -var-file=prod.tfvars ## load variable definitions from a file
terraform plan -target=module.database ## focus planning on a specific module/resource
terraform plan -refresh=false ## skip refreshing state before planning (faster when safe)
terraform plan -refresh=true ## force state refresh to detect drift before planning
terraform plan -parallelism=10 ## limit concurrent operations (defaults to 10)
terraform plan -parallelism=1 ## serialize all resource operations (for ordering-sensitive changes)
terraform plan -input=false ## disable interactive prompts (for automation)
terraform plan -lock=true ## lock the state file during planning (default behavior)
terraform plan -lock=false ## disable state locking (use with caution)
terraform plan -lock-timeout=5m ## wait up to 5 minutes to acquire state lock
terraform plan -state=custom.tfstate ## use an alternate state file for this plan
terraform plan -state-out=newstate.tfstate ## write updated state to a separate file
terraform plan -compact-warnings ## reduce verbosity of warning messages
terraform plan -no-color ## disable ANSI color codes in output
terraform plan -json ## output the full plan in JSON for tooling
terraform plan -refresh-only ## detect drift without proposing any infrastructure changes
```

```bash
terraform apply plan.tfplan ## apply changes from a previously saved execution plan
terraform apply -auto-approve ## skip interactive approval prompt (use with caution in automation)
terraform apply -target=module.foo ## apply only the specified module or resource
terraform apply -var="env=prod" ## override the “env” variable for this run
terraform apply -var-file=prod.tfvars ## load variable definitions from a file
terraform apply -parallelism=5 ## limit concurrent operations to 5
terraform apply -parallelism=1 ## serialize all operations (useful for ordering-sensitive changes)
terraform apply -refresh-only ## update state to match real infrastructure without making changes :contentReference[oaicite:0]{index=0}
terraform apply -input=false ## disable interactive prompts (ideal for CI/CD)
terraform apply -lock=false ## disable state locking (use only if you know what you’re doing)
terraform apply -lock=true ## ensure the state file is locked during apply (default behavior)
terraform apply -lock-timeout=3m ## wait up to 3 minutes to acquire the state lock
terraform apply -state=custom.tfstate ## use an alternate state file for this apply
terraform apply -state-out=newstate.tfstate ## write the updated state to a separate file
terraform apply -no-color ## disable ANSI color codes in output
terraform apply -compact-warnings ## reduce verbosity of warning messages
terraform apply -backup=backup.tfstate ## specify the path for the state backup file
terraform apply -json ## output the apply result in JSON for external tooling
terraform apply -replace=module.foo.aws_instance.bar ## force the replacement of a specific resource
terraform apply -refresh-only -auto-approve ## non-interactive state-only refresh (alias for deprecated `terraform refresh`) :contentReference[oaicite:1]{index=1}
```

```bash
terraform validate ## validate the configuration for syntax and internal consistency
terraform validate -json ## output validation results in JSON format for tooling
terraform fmt ## rewrite configurations to canonical format
terraform fmt -recursive ## format all .tf files in subdirectories recursively
terraform fmt -check ## detect unformatted files without making changes
terraform fmt -diff ## show diffs of formatting changes without rewriting files
terraform fmt -list="*.tf" ## list files that would be formatted without changing them
terraform version ## display the Terraform CLI version
terraform version -json ## output version information in JSON format
terraform workspace list ## list all existing workspaces
terraform workspace new dev ## create a new workspace named “dev”
terraform workspace select dev ## switch to the “dev” workspace
terraform workspace show ## display the name of the current workspace
terraform workspace delete dev ## delete the “dev” workspace
terraform workspace rename dev prod ## rename workspace “dev” to “prod”
terraform import aws_instance.web i-12345678 ## import an existing AWS EC2 instance into state
terraform import -lock=false aws_instance.web i-12345678 ## import without acquiring a state lock
terraform import -config=prod.conf aws_db_instance.db db-123 ## import using a specific config file
terraform output ## read an output variable from state
terraform output -json ## output all outputs in JSON format
terraform output web_ip ## display the “web_ip” output value
terraform refresh ## update state file with real-world resource attributes
terraform refresh -target=aws_instance.web ## refresh state for a specific resource only
terraform show ## show human-readable state or plan
terraform show -json ## output state or plan in JSON format
terraform show plan.tfplan ## display the contents of a saved plan file
terraform graph ## generate a visual graph of resource relationships (DOT format)
terraform graph -module-depth=1 ## limit graph to top-level modules only
terraform graph -type=plan ## graph only resources in the planned changes
terraform graph -draw-cycles ## include cycle edges in the graph output
terraform taint aws_instance.web ## mark a resource for recreation on next apply
terraform taint -allow-missing aws_instance.web ## taint even if resource is missing from state
terraform untaint aws_instance.web ## remove the “tainted” mark from a resource
terraform force-unlock 1234abcd ## manually unlock state if a lock remains after failure
terraform destroy ## destroy all managed infrastructure
terraform destroy -auto-approve ## destroy without confirmation prompt
terraform destroy -target=aws_instance.web ## destroy only the specified resource
terraform console ## open an interactive console to evaluate Terraform expressions
terraform console -no-color ## launch console without ANSI color codes
terraform login ## authenticate to Terraform Cloud or Enterprise
terraform logout ## remove stored credentials for Terraform Cloud
terraform providers ## list provider dependencies in the configuration
terraform providers mirror ./mirror-dir ## download all providers into a local directory
terraform providers schema aws ## show the resource & data source schema for the “aws” provider
terraform providers schema -json aws ## output the AWS provider schema in JSON
terraform fmt -write=false ## check formatting without writing any changes
terraform fmt -write=true ## explicitly write formatting changes (default behavior)
terraform fmt -pattern="*.tf" ## format only files matching the given glob pattern
terraform workspace list -no-color ## list workspaces without ANSI color codes
terraform login --token="…" ## non-interactive login supplying an API token

``
```
