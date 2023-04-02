//
// Deploys an Azure Storage Account
// https://learn.microsoft.com/en-us/azure/storage/
//

@description('Descriptor for this resource')
param prefix string = 'storage'

@description('Unique suffix for all resources in this deployment')
param suffix string = uniqueString(resourceGroup().id)

@description('Location for all resources.')
param location string = resourceGroup().location

@description('SKU name.')
param sku string = 'Standard_LRS'

resource storage 'Microsoft.Storage/storageAccounts@2022-09-01' = {
  name: '${prefix}000${suffix}'
  location: location
  sku: {
    name: sku
  }
  kind: 'Storage'
}

output result object = {
  name: storage.name
  id: storage.id
}
