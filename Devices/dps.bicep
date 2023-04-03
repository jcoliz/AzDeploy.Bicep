//
// Deploys a Device Provisioning Service
// https://learn.microsoft.com/en-us/azure/iot-dps/
//

@description('Descriptor for this resource')
param prefix string = 'dps'

@description('Unique suffix for all resources in this deployment')
param suffix string = uniqueString(resourceGroup().id)

@description('Location for all resources.')
param location string = resourceGroup().location

@description('SKU name.')
param sku string = 'S1'

@description('Number of provisioned units. Restricted to 1 unit for the F1 SKU. Can be set up to maximum number allowed for subscription.')
param capacity int = 1

@description('Details for required IoTHub resource (name/id/host)')
param iotHub object

resource iot 'Microsoft.Devices/IotHubs@2021-07-02' existing = {
  name: iotHub.name
}

var key = iot.listkeys().value[0]
var host = iot.properties.hostName
var HUBCSTR = 'HostName=${host};SharedAccessKeyName=${key.keyName};SharedAccessKey=${key.primaryKey}'

output HUBCSTR string = HUBCSTR

resource dps 'Microsoft.Devices/provisioningServices@2022-12-12' = {
  name: '${prefix}-${suffix}'
  location: location
  sku: {
    name: sku
    capacity: capacity
  }
  properties: {
    iotHubs: [
      {
        connectionString: HUBCSTR
        location: location
      }
    ]
  }
}

output result object = {
  name: dps.name
  id: dps.id
  scope: dps.properties.idScope
}
