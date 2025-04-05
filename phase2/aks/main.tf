provider "azurerm" {
  features {}
  subscription_id = "b661c992-c619-42c7-8765-1d1436365a04"
}


data "azurerm_subnet" "private_servers_subnet" {
  name                 = var.subnet_name
  virtual_network_name = var.vnet_name
  resource_group_name  = var.resource_group
}

resource "azurerm_kubernetes_cluster" "aks" {
  name                = var.aks_name
  location            = var.location
  resource_group_name = var.resource_group
  dns_prefix          = "secureaks"
  kubernetes_version  = var.kubernetes_version

  default_node_pool {
    name           = "agentpool"
    node_count     = var.node_count
    vm_size        = "Standard_D2s_v3"
    vnet_subnet_id = data.azurerm_subnet.private_servers_subnet.id
  }

  identity {
    type = "SystemAssigned"
  }
  network_profile {
    network_plugin = "azure"
    service_cidr   = var.service_cidr
    dns_service_ip = cidrhost(var.service_cidr, 10) 
  }

}
