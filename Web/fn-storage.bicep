//
// Deploys an Azure Functions app
//    with associated storage account
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
    storageName: storage.outputs.result.name
    suffix: suffix
    location: location
  }  
}

output fn object = fn.outputs.result
output storage object = storage.outputs.result
