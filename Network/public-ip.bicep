//
// Creates an Azure public IP address for a virtual network
// https://learn.microsoft.com/en-us/azure/virtual-network/ip-services/virtual-network-public-ip-address
//

@description('Descriptor for this resource')
param prefix string = 'ip'

@description('Unique suffix for all resources in this deployment')
param suffix string = uniqueString(resourceGroup().id)

@description('Location for all resources.')
param location string = resourceGroup().location

param publicIpAddressType string = 'Static'
param publicIpAddressSku string = 'Standard'

resource publicIpAddress 'Microsoft.Network/publicIpAddresses@2020-08-01' = {
  name: '${prefix}-${suffix}'
  location: location
  properties: {
    publicIPAllocationMethod: publicIpAddressType
  }
  sku: {
    name: publicIpAddressSku
  }
}

output name string = publicIpAddress.name
