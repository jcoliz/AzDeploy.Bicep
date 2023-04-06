//
// Deploys an Azure IoT Hub 
//    with an associated Device Provisioning Service
//    and a log analytics workspace
//    and enables commong logging properties to that workspace
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

module logs '../OperationalInsights/loganalytics.bicep' = {
  name: 'logs'
  params: {
    suffix: suffix
    location: location
  }
}

module setting '../Insights/iothublogs.bicep' = {
  name: 'setting'
  params: {
    iotHubName: iotHub.outputs.result.name
    logsName: logs.outputs.result.name
  }
}

output HUBNAME string = iotHub.outputs.result.name
output DPSNAME string = dps.outputs.result.name
output IDSCOPE string = dps.outputs.result.scope
output LOGNAME string = logs.outputs.result.name
