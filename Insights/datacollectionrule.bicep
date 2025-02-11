//
// Deploys a Data Collection Rule
//    https://learn.microsoft.com/en-us/azure/templates/microsoft.insights/datacollectionrules
//    https://learn.microsoft.com/en-us/azure/azure-monitor/logs/logs-ingestion-api-overview#data-collection-rule-dcr
//

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

@description('Name of optional data collection endpoint resource. If not specified, will create a direct ingestion rule')
param endpointName string = ''

@description('Name of table in log workspace')
param tableName string

@description('KQL query to transform input to putput ')
param transformKql string

@description('Columns of input schema')
param inputColumns array

var streamName = 'Custom-${tableName}'

var isDirectiIngestion = empty(endpointName)

var dcepProps = !isDirectiIngestion ? {
  dataCollectionEndpointId: endpoint.id
} : {}

resource logs 'Microsoft.OperationalInsights/workspaces@2020-08-01' existing = {
  name: logAnalyticsName
}

resource endpoint 'Microsoft.Insights/dataCollectionEndpoints@2023-03-11' existing = if (!isDirectiIngestion)  {
  name: endpointName
}

resource dcr 'Microsoft.Insights/dataCollectionRules@2023-03-11' = {
  name: '${prefix}-${suffix}'
  location: location  
  kind: isDirectiIngestion ? 'Direct' : 'WorkspaceTransforms' // https://learn.microsoft.com/en-us/azure/azure-monitor/essentials/data-collection-rule-structure#kind
  properties: {
    ...dcepProps
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

output name string = dcr.name
output DcrImmutableId string = dcr.properties.immutableId
output Stream string = streamName
output EndpointUri string = isDirectiIngestion ? dcr.properties.endpoints.logsIngestion : ''
