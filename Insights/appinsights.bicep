@description('Descriptor for this resource')
@minLength(2)
param prefix string = 'insights'

@description('Unique suffix for all resources in this deployment')
@minLength(5)
param suffix string = uniqueString(resourceGroup().id)

@description('Location for all resources.')
param location string = resourceGroup().location

@description('Name ofrequired log analytics resource')
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

/*
resource name 'Microsoft.Web/sites@2018-11-01' = {
  name: name_param
  location: location
  tags: {}
  properties: {
    name: name_param
    siteConfig: {
      appSettings: [
        {
          name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
          value: reference(
            'microsoft.insights/components/app-logs-test',
            '2015-05-01'
          ).ConnectionString
        }
        {
          name: 'ApplicationInsightsAgent_EXTENSION_VERSION'
          value: '~2'
        }
        {
          name: 'XDT_MicrosoftApplicationInsights_Mode'
          value: 'default'
        }
      ]
      linuxFxVersion: linuxFxVersion
      alwaysOn: alwaysOn
      ftpsState: ftpsState
    }
  }
}
*/
