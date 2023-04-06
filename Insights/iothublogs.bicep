//
// Adds commonly-used diagnostic log settings to an IoT Hub
//    using the supplied log analytics workspace
//

@description('Name of required IoTHub resource')
param iotHubName string

@description('Name of required Log Analytics Workspace resource')
param logsName string

// Retrieve needed details out of IoTHub resource
resource iotHubResource 'Microsoft.Devices/IotHubs@2021-07-02' existing = {
  name: iotHubName
}

// Retrieve needed details out of log analytics workspace
resource logs 'Microsoft.OperationalInsights/workspaces@2022-10-01' existing = {
  name: logsName
}

resource setting 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  scope: iotHubResource
  name: 'logs'
  properties: {
    workspaceId: logs.id
    logs: [
      {
        categoryGroup: 'allLogs'
        enabled: true
        retentionPolicy: {
          enabled: true
          days: 90
        }
      }
    ]
  }
}
