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

@description('Whether to enable hierarchical namespace for the storage account. Required to use storage account as a data lake.')
param isHnsEnabled bool = false

resource storage 'Microsoft.Storage/storageAccounts@2024-01-01' = {
  name: '${prefix}000${suffix}'
  location: location
  sku: {
    name: sku
  }
  kind: 'StorageV2'
  properties: {
    accessTier: 'Hot'
    isHnsEnabled: isHnsEnabled
  }
}

output result object = {
  name: storage.name
  id: storage.id
}

output storageName string = storage.name
output storageEndpoint object = storage.properties.primaryEndpoints
