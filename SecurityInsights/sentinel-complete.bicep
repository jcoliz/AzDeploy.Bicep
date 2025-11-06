//
// Creates a Sentinel Solution with underlying Log Analytics Workspace
//

@description('Descriptor for this resource')
@minLength(2)
param prefix string = 'sentinel'

@description('Unique suffix for all resources in this deployment')
@minLength(5)
param suffix string = uniqueString(resourceGroup().id)

@description('Location for all resources.')
param location string = resourceGroup().location

@description('SKU name.')
param sku string = 'pergb2018'

module logs '../OperationalInsights/loganalytics.bicep' = {
  name: 'logs'
  params: {
    prefix: prefix
    suffix: suffix
    location: location
    sku: sku
  }
}

module sentinel './sentinel-onboarding.bicep' = {
  name: 'sentinel'
  params: {
    logAnalyticsName: logs.outputs.name
  }
}

module diagnostics './sentinel-diagnostics.bicep' = {
  name: 'diagnostics'
  dependsOn: [
    sentinel
  ]
  params: {
    logAnalyticsName: logs.outputs.name
  }
}

output logAnalyticsName string = logs.outputs.logAnalyticsName
output logAnalyticsWorkspaceId string = logs.outputs.workspaceId
output sentinelId string = sentinel.outputs.sentinelId
