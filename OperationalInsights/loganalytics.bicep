@description('Descriptor for this resource')
param prefix string = 'logs'

@description('Unique suffix for all resources in this deployment')
param suffix string = uniqueString(resourceGroup().id)

@description('Location for all resources.')
param location string = resourceGroup().location

@description('SKU name.')
param sku string = 'Standalone'

resource logs 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
  name: '${prefix}-${suffix}'
  location: location
  properties: {
    sku: {
      name: sku
    }
    retentionInDays: 30
    features: {
      immediatePurgeDataOn30Days: true
    }    
  }
}

output result object = {
  name: logs.name
  id: logs.id
}
