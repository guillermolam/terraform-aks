# Terraform AKS Deployment Usage Guide

This document provides instructions for setting up and managing Azure Kubernetes Service (AKS) clusters using Terraform across different environments (dev, non-prod, prod).

## Prerequisites

- Terraform installed on your system.
- Azure CLI installed and configured (optional, for manual verification).
- Access to the Azure subscription with the necessary permissions.

## Setting Up Credentials

To authenticate Terraform with Azure, you need to set environment variables with the provided credentials. Use the `set_credentials.sh` script to simplify this process.

1. Open a terminal in the root directory of this project.
2. Edit `set_credentials.sh` to update the `ARM_CLIENT_SECRET` with the actual client secret for the service principal.
3. Run the script to set the environment variables:

   ```bash
   source ./set_credentials.sh
   ```

   This will set the following environment variables:
   - `ARM_SUBSCRIPTION_ID`: The Azure subscription ID.
   - `ARM_TENANT_ID`: The Azure Active Directory tenant ID.
   - `ARM_CLIENT_ID`: The Service Principal client ID.
   - `ARM_CLIENT_SECRET`: The Service Principal client secret (ensure this is updated in the script).

## Managing Workspaces

This project is organized into different workspaces for each environment:
- `workspaces/00_dev/`: Development environment for Arc-enabled AKS.
- `workspaces/01_non-prod/`: Non-production environment for AKS.
- `workspaces/03_prod/`: Production environment for AKS.

### Running Terraform Commands

For each workspace, follow these steps to plan, apply, or destroy resources:

1. **Navigate to the Workspace Directory**:
   Change to the directory of the environment you want to manage. For example, for the non-prod environment:

   ```bash
   cd workspaces/01_non-prod
   ```

2. **Initialize Terraform**:
   Initialize the Terraform working directory to download the required providers and modules:

   ```bash
   terraform init
   ```

3. **Plan the Deployment**:
   Create an execution plan to see what resources Terraform will create, update, or destroy:

   ```bash
   terraform plan
   ```

   If you have a `.tfvars` file or want to pass variables manually, you can specify them:
   ```bash
   terraform plan -var-file="non_prod.tfvars"
   ```

4. **Apply the Configuration**:
   Apply the changes to create or update resources in Azure:

   ```bash
   terraform apply
   ```

   Confirm the action by typing `yes` when prompted. To pass variables:
   ```bash
   terraform apply -var-file="non_prod.tfvars"
   ```

5. **Destroy Resources**:
   When you no longer need the resources, destroy them to avoid unnecessary costs:

   ```bash
   terraform destroy
   ```

   Confirm the action by typing `yes` when prompted. To pass variables:
   ```bash
   terraform destroy -var-file="non_prod.tfvars"
   ```

6. **Return to Root Directory**:
   After completing operations in a workspace, return to the root directory:

   ```bash
   cd ../..
   ```

### Notes

- Ensure that the environment variables are set in every new terminal session before running Terraform commands.
- For security, do not commit the `set_credentials.sh` script with the actual client secret to version control. It is recommended to use a secure method to manage secrets, such as Azure Key Vault or a secrets management tool.
- Check the outputs after applying the configuration to get details like cluster names, kubeconfig, and FQDNs for accessing the AKS clusters.

## Troubleshooting

- If you encounter authentication errors, verify that the environment variables are set correctly.
- For module-specific issues, refer to the module documentation in the `modules/` directory.
- Use `terraform validate` to check the syntax and configuration before planning or applying.

## Contact

For any issues or questions regarding this Terraform setup, please contact the DevOps team.
