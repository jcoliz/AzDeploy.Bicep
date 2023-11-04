@description('Descriptor for this resource')
param prefix string = 'vnet'

@description('Unique suffix for all resources in this deployment')
param suffix string = uniqueString(resourceGroup().id)

@description('Location for all resources.')
param location string = resourceGroup().location

param subnets array
param addressPrefixes array

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2021-05-01' = {
  name: '${prefix}-${suffix}'
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: addressPrefixes
    }
    subnets: subnets
  }
}

output name string = virtualNetwork.name
