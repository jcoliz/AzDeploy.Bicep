@description('Descriptor for this resource')
@minLength(2)
param prefix string = 'dcr'

@description('Unique suffix for all resources in this deployment')
@minLength(5)
param suffix string = uniqueString(resourceGroup().id)

@description('Location for all resources.')
param location string = resourceGroup().location

@description('Name of required log analytics resource')
param logAnalyticsName string

@description('Name of required data collection endpoint resource')
param endpointName string

@description('Schema of table in log workspace')
param tableSchema object

@description('KQL query to transform input to putput ')
param transformKql string

@description('Columns of input schema')
param inputColumns array

@description('The id that will be given data owner permission for the Data Collection Rule resource')
param principalId string

@description('The type of the given principal id')
param principalType string = 'ServicePrincipal'

var streamName = 'Custom-${tableSchema.name}'

resource logs 'Microsoft.OperationalInsights/workspaces@2020-08-01' existing = {
  name: logAnalyticsName
}

resource endpoint 'Microsoft.Insights/dataCollectionEndpoints@2023-03-11' existing = {
  name: endpointName
}

// Note that we are creating the table at the same time we create the
// DCR, as they are tightly coupled

resource dcr 'Microsoft.Insights/dataCollectionRules@2023-03-11' = {
  name: '${prefix}-${suffix}'
  location: location
  properties: {
    dataCollectionEndpointId: endpoint.id
    destinations: {
      logAnalytics: [
        {
          workspaceResourceId: logs.id
          name: logs.name
        }
      ]
    }
    dataFlows: [
      {
        streams: [
          streamName
        ]
        destinations: [
          logs.name
        ]
        outputStream: streamName
        transformKql: transformKql
      }
    ]
    streamDeclarations: {
      '${streamName}': {
        columns: inputColumns
      }
    }
  }
}

module publisherRole 'monitoring-metrics-publisher-role.bicep' = {
  name: 'publisherROle'
  params: {
    dcrName: dcr.name
    principalId: principalId
    principalType: principalType
  }
}

output name string = dcr.name
output DcrImmutableId string = dcr.properties.immutableId
output EndpointUri string = endpoint.properties.logsIngestion.endpoint
output Stream string = streamName
