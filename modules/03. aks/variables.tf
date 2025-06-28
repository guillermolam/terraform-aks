variable "agent_vm_size" {
  description = "The VM size for AKS agent nodes"
  type        = string
}

variable "agent_count" {
  description = "Number of AKS agent nodes"
  type        = number
}

variable "subnets" {
  description = "List of subnet CIDRs"
  type        = list(string)
  default     = ["10.0.1.0/24"]
}
