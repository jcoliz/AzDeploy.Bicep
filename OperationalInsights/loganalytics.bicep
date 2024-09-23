@description('Descriptor for this resource')
@minLength(2)
param prefix string = 'logs'

@description('Unique suffix for all resources in this deployment')
@minLength(5)
param suffix string = uniqueString(resourceGroup().id)

@description('Location for all resources.')
param location string = resourceGroup().location

@description('SKU name.')
param sku string = 'pergb2018'

resource logs 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
  name: '${prefix}-${suffix}'
  location: location
  properties: {
    sku: {
      name: sku
    }
  }
}

output result object = {
  name: logs.name
  id: logs.id
}
output logAnalyticsName string = logs.name
output name string = logs.name
