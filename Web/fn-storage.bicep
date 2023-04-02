//
// Deploys Function App with associated storage account
//

@description('Unique suffix for all resources in this deployment')
param suffix string = uniqueString(resourceGroup().id)

@description('Location for all resources.')
param location string = resourceGroup().location

module storage '../Storage/storage.bicep' = {
  name: 'storage'
  params: {
    suffix: suffix
    location: location
  }
}

module fn 'fn.bicep' = {
  name: 'fn'
  params: {
    storage: storage.outputs.result
    suffix: suffix
    location: location
  }  
}

output fn object = {
  name: fn.outputs.result.name
  id: fn.outputs.result.id
}

output storage object = {
  name: storage.outputs.result.name
  id: storage.outputs.result.id
}
