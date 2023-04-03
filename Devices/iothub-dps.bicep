//
// Deploys an Azure IoT Hub with an associated Device Provisioning Service
//

@description('Unique suffix for all resources in this deployment')
param suffix string = uniqueString(resourceGroup().id)

@description('Location for all resources.')
param location string = resourceGroup().location

module iotHub 'iothub.bicep' = {
  name: 'iotHub'
  params: {
    suffix: suffix
    location: location
  }  
}

module dps 'dps.bicep' = {
  name: 'dps'
  params: {
    suffix: suffix
    location: location
    iotHubName: iotHub.outputs.result.name
  }
}

output HUBNAME string = iotHub.outputs.result.name
output DPSNAME string = dps.outputs.result.name
output IDSCOPE string = dps.outputs.result.scope
