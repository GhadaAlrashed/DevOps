variable "resource_group" {
  default = "Test0Group"
}

variable "location" {
  default = "eastus"
}

variable "vnet_name" {
  default = "test-vnet"
}

variable "subnet_name" {
  default = "PrivateServersSubnet"
}

variable "aks_name" {
  default = "ghada-cluster"
}

variable "node_count" {
  default = 3
}

variable "kubernetes_version" {
  default = "1.29.2"
}
variable "service_cidr" {
  default = "10.0.6.0/24"
}
