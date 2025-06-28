package test

import (
	"testing"
	"time"

	"github.com/gruntwork-io/terratest/modules/azure"
	"github.com/gruntwork-io/terratest/modules/k8s"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

func TestAKSInfrastructureE2E(t *testing.T) {
	t.Parallel()

	// Configure Terraform options with Terratest
	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../..",
		Vars: map[string]interface{}{
			"environment": "test",
			"location":    "eastus",
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
	expectedNodeCount := 2 
	assert.Equal(t, len(nodes), expectedNodeCount, "Node count should match expected value")

	// Verify system services using Terratest k8s module
	services := k8s.ListServices(t, options, "kube-system")
	assert.Contains(t, services, "kube-dns", "KubeDNS service should be running")

	// Verify network configuration using Terratest Azure module
	vnetName := terraform.Output(t, terraformOptions, "vnet_name")
	assert.NotEmpty(t, vnetName)
	vnetExists := azure.VirtualNetworkExists(t, vnetName, resourceGroupName, "")
	assert.True(t, vnetExists, "Virtual network should exist")

	// Verify Log Analytics workspace using Terratest Azure module
	workspaceName := terraform.Output(t, terraformOptions, "log_analytics_workspace_name")
	assert.NotEmpty(t, workspaceName)
	workspaceExists := azure.LogAnalyticsWorkspaceExists(t, workspaceName, resourceGroupName, "")
	assert.True(t, workspaceExists, "Log Analytics workspace should exist")
}
