@description('Descriptor for this resource')
@minLength(2)
param prefix string = 'insights'

@description('Unique suffix for all resources in this deployment')
@minLength(5)
param suffix string = uniqueString(resourceGroup().id)

@description('Location for all resources.')
param location string = resourceGroup().location

@description('Name of required log analytics resource')
param logAnalyticsName string

resource logs 'Microsoft.OperationalInsights/workspaces@2020-08-01' existing = {
  name: logAnalyticsName
}

resource insights 'microsoft.insights/components@2020-02-02-preview' = {
  name: '${prefix}-${suffix}'
  location: location
  kind: 'web'
  properties: {
    Flow_Type: 'Redfield'
    Application_Type: 'web'
    WorkspaceResourceId: logs.id
  }
}

output name string = insights.name
output instrumentationKey string = insights.properties.InstrumentationKey
output connectionString string = insights.properties.ConnectionString
