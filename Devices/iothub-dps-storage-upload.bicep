//
// Deploys an Azure IoT Hub 
//    with an associated Device Provisioning Service
//    and an associated Storage Account
//    configured for file upload
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

var containername = 'uploads'
module container '../Storage/storcontainer.bicep' = {
  name: containername
  params: {
    name: containername
    account: storage.outputs.result.name
  }
}

module iotHub 'iothub-upload.bicep' = {
  name: 'iotHub'
  params: {
    suffix: suffix
    location: location
    storage: storage.outputs.result
    uploadcontainername: containername
  }
}

module dps 'dps.bicep' = {
  name: 'dps'
  params: {
    suffix: suffix
    location: location
    iotHub: iotHub.outputs.result
  }
}

output HUBNAME string = iotHub.outputs.result.name
output DPSNAME string = dps.outputs.result.name
output IDSCOPE string = dps.outputs.result.scope
output STORNAME string = storage.outputs.result.name
