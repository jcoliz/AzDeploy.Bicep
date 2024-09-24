@description('Descriptor for this resource')
@minLength(2)
param prefix string = 'dcep'

@description('Unique suffix for all resources in this deployment')
@minLength(5)
param suffix string = uniqueString(resourceGroup().id)

@description('Location for all resources.')
param location string = resourceGroup().location

resource endpoint 'Microsoft.Insights/dataCollectionEndpoints@2023-03-11' = {
  name: '${prefix}-${suffix}'
  location: location
  properties: {
    networkAcls: {
      publicNetworkAccess: 'Enabled'
    }
  }
}

output name string = endpoint.name
output id string = endpoint.id
output EndpointUri string = endpoint.properties.logsIngestion.endpoint
