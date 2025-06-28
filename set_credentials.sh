#!/bin/bash

# Script to set environment variables for Terraform Azure provider authentication

echo "Setting environment variables for Terraform Azure authentication..."

export ARM_SUBSCRIPTION_ID="a7f2e16b-6d0b-4d7e-b212-a5c52a05f775"
export ARM_TENANT_ID="0e9350a6-7f34-4f29-9465-b84e94877a4f"
export ARM_CLIENT_ID="a773781d-e548-42bb-9d43-ecea3b527e79"
export ARM_CLIENT_SECRET="YOUR_CLIENT_SECRET_HERE"

echo "Environment variables set. Please ensure ARM_CLIENT_SECRET is updated with the correct value before running Terraform commands."

# Uncomment the following lines if you want to verify the settings
# echo "Subscription ID: $ARM_SUBSCRIPTION_ID"
# echo "Tenant ID: $ARM_TENANT_ID"
# echo "Client ID: $ARM_CLIENT_ID"
