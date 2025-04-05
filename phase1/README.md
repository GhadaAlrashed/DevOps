# Phase 1:

## Create Resource Group:

```bash
az group create --name Test0Group --location eastus
```

## Create Virtual Network (VNet):
```bash
az network vnet create --name test-vnet --resource-group Test0Group --location eastus --address-prefix 10.0.0.0/16
```

## Subnets:
### 1. Public LB Subnet:
Public LB Subnet: PublicLBS


    ```bash
    az network vnet subnet create --vnet-name test-vnet --resource-group Test0Group --name PublicLBS --address-prefix 10.0.1.0/24
    az network nsg create --resource-group Test0Group --name PublicLBNSG
    az network nsg rule create --resource-group Test0Group --nsg-name PublicLBNSG --name Allow-HTTP-HTTPS-from-LoadBalancer --protocol Tcp --direction Inbound --priority 100 --source-address-prefixes '*' --destination-port-ranges 80 443 --access Allow
    ```

### 2. Private DMZ Subnet:
Private DMZ Subnet: PrivateDMZS

    ```bash
    az network vnet subnet create --vnet-name test-vnet --resource-group Test0Group --name PrivateDMZS --address-prefix 10.0.2.0/24
    az network nsg create --resource-group Test0Group --name DMZNSG
    az network nsg rule create --resource-group Test0Group --nsg-name DMZNSG --name Allow-HTTP-HTTPS-DMZ --protocol Tcp --direction Inbound --priority 200 --source-address-prefixes '*' --destination-port-ranges 80 443 --access Allow
    ```

### 3. Private Servers Subnet:
Private Servers Subnet: PrivateServersSubnet

    ```bash
    az network vnet subnet create --vnet-name test-vnet --resource-group Test0Group --name PrivateServersSubnet --address-prefix 10.0.3.0/24
    az network nsg create --resource-group Test0Group --name ServersNSG

    az network nsg rule create --resource-group Test0Group --nsg-name ServersNSG --name Allow-HTTP --protocol Tcp --direction Inbound --priority 100 --source-address-prefixes '*' --destination-port-ranges 80 --access Allow
    az network nsg rule create --resource-group Test0Group --nsg-name ServersNSG --name Allow-HTTPS --protocol Tcp --direction Inbound --priority 110 --source-address-prefixes '*' --destination-port-ranges 443 --access Allow
    az network nsg rule create --resource-group Test0Group --nsg-name ServersNSG --name Allow-SSH --protocol Tcp --direction Inbound --priority 120 --source-address-prefixes '*' --destination-port-ranges 22 --access Allow

    az network nsg rule create --resource-group Test0Group --nsg-name ServersNSG --name Deny-All-Other-Traffic --protocol Tcp --direction Inbound --priority 200 --source-address-prefixes '*' --destination-port-ranges '*' --access Deny
    ```

### 4. Private Database Subnet:
Private Database Subnet: PrivateDBS

    ```bash
    az network vnet subnet create --vnet-name test-vnet --resource-group Test0Group --name PrivateDBS --address-prefix 10.0.4.0/24
    az network nsg create --resource-group Test0Group --name DBNSG
    az network nsg rule create --resource-group Test0Group --nsg-name DBNSG --name Allow-Database-Port
    ```

### 5. Azure Firewall Subnet:
    ```bash
    az network vnet subnet create --vnet-name test-vnet --resource-group Test0Group --name AzureFirewallSubnet --address-prefix 10.0.5.0/24
    az network firewall create --resource-group Test0Group --name myFirewall --location eastus
    az network public-ip create --resource-group Test0Group --name myPublicIP --sku Standard
    az network firewall ip-config create --firewall-name myFirewall --resource-group Test0Group --name myIpConfig --public-ip-address myPublicIP --vnet-name test-vnet --subnet AzureFirewallSubnet
    ```

## Load Balancers:
### 1. Public Load Balancer:
```bash
az network public-ip create --name NewPublicIP --resource-group Test0Group --sku Standard
az network lb create --resource-group Test0Group --name PublicLoadBalancer --sku Standard --frontend-ip-name PublicFrontend --public-ip-address NewPublicIP
```
  - Create Backend Pool and Link to Firewall
```bash
az network lb address-pool create --resource-group Test0Group --lb-name PublicLoadBalancer --name FirewallBackendPool

az network lb address-pool address add --resource-group Test0Group --lb-name PublicLoadBalancer --pool-name FirewallBackendPool --name MyAddress --vnet test-vnet --ip-address 10.0.5.4

az network lb rule create --resource-group Test0Group --lb-name PublicLoadBalancer --name ForwardToFirewallRuleHTTP --protocol Tcp --frontend-port 80 --backend-port 80 --frontend-ip-name PublicFrontend --backend-pool-name FirewallBackendPool

az network lb rule create --resource-group Test0Group --lb-name PublicLoadBalancer --name ForwardToFirewallRuleHTTPS --protocol Tcp --frontend-port 443 --backend-port 443 --frontend-ip-name PublicFrontend --backend-pool-name FirewallBackendPool
```

### 2. Private Load Balancer Servers:
```bash
az network lb create --resource-group Test0Group --name PrivateServersLoadBalancer --sku Standard --frontend-ip-name PrivateFrontend --vnet-name test-vnet --subnet PrivateServersSubnet
```


### 3. Private Load Balancer for DB:
```bash
az network lb create --resource-group Test0Group --name PrivateDatabaseLoadBalancer --sku Standard --frontend-ip-name DBFrontend --vnet-name test-vnet --subnet PrivateDBS
```

### 4. Route External Requests from Public Load Balancer through the Firewall:
```bash
az network route-table create --resource-group Test0Group --name MyRouteTable

az network route-table route create --resource-group Test0Group --route-table-name MyRouteTable --name AllTraffic --address-prefix 0.0.0.0/0 --next-hop-type VirtualAppliance --next-hop-ip-address 10.0.5.4

az network vnet subnet update --resource-group Test0Group --vnet-name test-vnet --name PrivateDMZS --route-table MyRouteTable

az network vnet subnet update --resource-group Test0Group --vnet-name test-vnet --name PrivateDBS --route-table MyRouteTable
```

# Result:
```bash
az network vnet show --name test-vnet --resource-group Test0Group -o table
```

Output:

```nginx
EnableDdosProtection	Location	Name	PrivateEndpointVNetPolicies	ProvisioningState	ResourceGroup	ResourceGuid
False	eastus	test-vnet	Disabled	Succeeded	Test0Group	82f7493b-2633-4150-8dfc-c737105659ed
```

```bash
az network vnet subnet show --vnet-name test-vnet --name PublicLBS --resource-group Test0Group -o table
```

Output:

```nginx
AddressPrefix	Name	PrivateEndpointNetworkPolicies	PrivateLinkServiceNetworkPolicies	ProvisioningState	ResourceGroup
10.0.1.0/24	PublicLBS	Disabled	Enabled	Succeeded	Test0Group
```

```bash
az network vnet subnet show --vnet-name test-vnet --name PrivateDMZS --resource-group Test0Group -o table
```

Output:

```nginx
AddressPrefix	Name	PrivateEndpointNetworkPolicies	PrivateLinkServiceNetworkPolicies	ProvisioningState	ResourceGroup
10.0.2.0/24	PrivateDMZS	Disabled	Enabled	Succeeded	Test0Group
```

```bash
az network vnet subnet show --vnet-name test-vnet --name PrivateServersSubnet --resource-group Test0Group -o table
```


Output:

```nginx
AddressPrefix	Name	PrivateEndpointNetworkPolicies	PrivateLinkServiceNetworkPolicies	ProvisioningState	ResourceGroup
10.0.3.0/24	PrivateServersSubnet	Disabled	Enabled	Succeeded	Test0Group
```

```bash
az network vnet subnet show --vnet-name test-vnet --name PrivateDBS --resource-group Test0Group -o table
```

Output:
```nginx 
AddressPrefix    Name        PrivateEndpointNetworkPolicies    PrivateLinkServiceNetworkPolicies    ProvisioningState    ResourceGroup
10.0.4.0/24      PrivateDBS  Disabled                          Enabled                              Succeeded            Test0Group
```