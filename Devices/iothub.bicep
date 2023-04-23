//
// Deploys an Azure IoT Hub
// https://learn.microsoft.com/en-us/azure/iot-hub/
//

@description('Descriptor for this resource')
param prefix string = 'iothub'

@description('Unique suffix for all resources in this deployment')
param suffix string = uniqueString(resourceGroup().id)

@description('Location for all resources.')
param location string = resourceGroup().location

@description('SKU name.')
param sku string = 'S1'

@description('Number of provisioned units. Restricted to 1 unit for the F1 SKU. Can be set up to maximum number allowed for subscription.')
param capacity int = 1

@description('Optional file upload storage endpoint')
param uploadstorage object = {}

resource iotHub 'Microsoft.Devices/IotHubs@2021-07-02' = {
  name: '${prefix}-${suffix}'
  location: location
  sku: {
    name: sku
    capacity: capacity
  }
  properties: {
    storageEndpoints: uploadstorage
    routing: {
      fallbackRoute: {
        name: '$fallback'
        source: 'DeviceMessages'
        condition: 'true'
        endpointNames: [
          'events'
        ]
        isEnabled: true
      }
    }
  }
}

output result object = {
  name: iotHub.name
  id: iotHub.id
  host: iotHub.properties.hostName
  eventpath: iotHub.properties.eventHubEndpoints.events.path
  eventendpoint: iotHub.properties.eventHubEndpoints.events.endpoint
}
