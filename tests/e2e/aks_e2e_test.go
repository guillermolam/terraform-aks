package test

import (
	"testing"
	"time"

	"github.com/gruntwork-io/terratest/modules/azure"
	"github.com/gruntwork-io/terratest/modules/k8s"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

func TestAKSInfrastructureE2EDev(t *testing.T) {
	t.Parallel()

	// Configure Terraform options with Terratest for dev environment
	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../../workspaces/00_dev",
		NoColor:      true,
	})

	// Cleanup resources when test completes using Terratest
	defer terraform.Destroy(t, terraformOptions)

	// Deploy the infrastructure using Terratest
	terraform.InitAndApply(t, terraformOptions)

	// Get kubeconfig using Terratest
	kubeconfig := terraform.Output(t, terraformOptions, "kube_config_raw")
	assert.NotEmpty(t, kubeconfig)

	// Configure kubectl using Terratest k8s module
	options := k8s.NewKubectlOptions("", []byte(kubeconfig), "default")

	// Wait for nodes to be ready using Terratest k8s module
	k8s.WaitUntilAllNodesReady(t, options, 10, 30*time.Second)

	// Verify node count using Terratest k8s module
	nodes := k8s.GetNodes(t, options)
	expectedNodeCount := 1 // Adjust based on your dev setup
	assert.Equal(t, len(nodes), expectedNodeCount, "Node count should match expected value")

	// Verify system services using Terratest k8s module
	services := k8s.ListServices(t, options, "kube-system")
	assert.Contains(t, services, "kube-dns", "KubeDNS service should be running")

	// Verify ingress accessibility
	ingressService := k8s.GetService(t, options, "ingress-nginx", "ingress-nginx-controller")
	assert.NotNil(t, ingressService, "Ingress service should exist")
}

func TestAKSInfrastructureE2ENonProd(t *testing.T) {
	t.Parallel()

	// Configure Terraform options with Terratest for non-prod environment
	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../../workspaces/01_non-prod",
		Vars: map[string]interface{}{
			"client_id":       "${ARM_CLIENT_ID}",
			"client_secret":   "${ARM_CLIENT_SECRET}",
			"subscription_id": "${ARM_SUBSCRIPTION_ID}",
			"tenant_id":       "${ARM_TENANT_ID}",
		},
		NoColor: true,
	})

	// Cleanup resources when test completes using Terratest
	defer terraform.Destroy(t, terraformOptions)

	// Deploy the infrastructure using Terratest
	terraform.InitAndApply(t, terraformOptions)

	// Validate Resource Group using Terratest Azure module
	resourceGroupName := terraform.Output(t, terraformOptions, "resource_group_name")
	assert.NotEmpty(t, resourceGroupName)
	exists := azure.ResourceGroupExists(t, resourceGroupName, "")
	assert.True(t, exists, "Resource group should exist")

	// Get AKS cluster info using Terratest
	clusterName := terraform.Output(t, terraformOptions, "arc_cluster_name")
	assert.NotEmpty(t, clusterName)

	// Get kubeconfig using Terratest
	kubeconfig := terraform.Output(t, terraformOptions, "kube_config_raw")
	assert.NotEmpty(t, kubeconfig)

	// Configure kubectl using Terratest k8s module
	options := k8s.NewKubectlOptions("", []byte(kubeconfig), "default")

	// Wait for nodes to be ready using Terratest k8s module
	k8s.WaitUntilAllNodesReady(t, options, 10, 30*time.Second)

	// Verify node count using Terratest k8s module
	nodes := k8s.GetNodes(t, options)
	expectedNodeCount := 2 // Adjust based on your non-prod setup
	assert.Equal(t, len(nodes), expectedNodeCount, "Node count should match expected value")

	// Verify system services using Terratest k8s module
	services := k8s.ListServices(t, options, "kube-system")
	assert.Contains(t, services, "kube-dns", "KubeDNS service should be running")

	// Verify network configuration using Terratest Azure module
	vnetName := terraform.Output(t, terraformOptions, "vnet_name")
	assert.NotEmpty(t, vnetName)
	vnetExists := azure.VirtualNetworkExists(t, vnetName, resourceGroupName, "")
	assert.True(t, vnetExists, "Virtual network should exist")

	// Verify ingress accessibility
	ingressService := k8s.GetService(t, options, "ingress-nginx", "ingress-nginx-controller")
	assert.NotNil(t, ingressService, "Ingress service should exist")
}

func TestAKSInfrastructureE2EProd(t *testing.T) {
	t.Parallel()

	// Configure Terraform options with Terratest for prod environment
	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../../workspaces/03_prod",
		Vars: map[string]interface{}{
			"client_id":       "${ARM_CLIENT_ID}",
			"client_secret":   "${ARM_CLIENT_SECRET}",
			"subscription_id": "${ARM_SUBSCRIPTION_ID}",
			"tenant_id":       "${ARM_TENANT_ID}",
		},
		NoColor: true,
	})

	// Cleanup resources when test completes using Terratest
	defer terraform.Destroy(t, terraformOptions)

	// Deploy the infrastructure using Terratest
	terraform.InitAndApply(t, terraformOptions)

	// Validate Resource Group using Terratest Azure module
	resourceGroupName := terraform.Output(t, terraformOptions, "resource_group_name")
	assert.NotEmpty(t, resourceGroupName)
	exists := azure.ResourceGroupExists(t, resourceGroupName, "")
	assert.True(t, exists, "Resource group should exist")

	// Get AKS cluster info using Terratest
	clusterName := terraform.Output(t, terraformOptions, "aks_cluster_name")
	assert.NotEmpty(t, clusterName)

	// Get kubeconfig using Terratest
	kubeconfig := terraform.Output(t, terraformOptions, "kube_config_raw")
	assert.NotEmpty(t, kubeconfig)

	// Configure kubectl using Terratest k8s module
	options := k8s.NewKubectlOptions("", []byte(kubeconfig), "default")

	// Wait for nodes to be ready using Terratest k8s module
	k8s.WaitUntilAllNodesReady(t, options, 10, 30*time.Second)

	// Verify node count using Terratest k8s module
	nodes := k8s.GetNodes(t, options)
	expectedNodeCount := 3 // Adjust based on your prod setup
	assert.Equal(t, len(nodes), expectedNodeCount, "Node count should match expected value")

	// Verify system services using Terratest k8s module
	services := k8s.ListServices(t, options, "kube-system")
	assert.Contains(t, services, "kube-dns", "KubeDNS service should be running")

	// Verify network configuration using Terratest Azure module
	vnetName := terraform.Output(t, terraformOptions, "vnet_name")
	assert.NotEmpty(t, vnetName)
	vnetExists := azure.VirtualNetworkExists(t, vnetName, resourceGroupName, "")
	assert.True(t, vnetExists, "Virtual network should exist")

	// Verify ingress accessibility
	ingressService := k8s.GetService(t, options, "ingress-nginx", "ingress-nginx-controller")
	assert.NotNil(t, ingressService, "Ingress service should exist")
}
