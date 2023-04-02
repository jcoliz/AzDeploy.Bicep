//
// Deploys a Consumer Group into an IoT Hub
//

@description('Name of consumer group')
param name string

@description('Name of parent event hub')
param ehub string

resource cg 'Microsoft.Devices/IotHubs/eventHubEndpoints/ConsumerGroups@2021-07-02' = {
  name: '${ehub}/events/${name}'
  properties: {
    name: name
  }
}
