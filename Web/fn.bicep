//
// Deploys an Azure Functions app
// https://learn.microsoft.com/en-us/azure/azure-functions/
//

@description('Descriptor for this resource')
param prefix string = 'fn'

@description('Unique suffix for all resources in this deployment')
param suffix string = uniqueString(resourceGroup().id)

@description('Location for all resources.')
param location string = resourceGroup().location

@description('Hosting plan SKU.')
param sku string = 'Y1'

@description('Hosting plan tier.')
param tier string = 'Dynamic'

@description('The language worker runtime to load in the function app.')
@allowed([
  'node'
  'dotnet'
  'dotnet-isolated'
  'java'
  'powershell'
  'python'
  'custom'
])
param fnRuntime string = 'dotnet-isolated'

@description('Name of required storage resource')
param storageName string

@description('Optional application settings environment vars')
param configuration array = []

resource hostingPlan 'Microsoft.Web/serverfarms@2022-03-01' = {
  name: 'farm-${suffix}'
  location: location
  sku: {
    name: sku
    tier: tier
  }
}

// Retrieve needed details out of storage resource
resource storage 'Microsoft.Storage/storageAccounts@2023-05-01' existing = {
  name: storageName
}

var storcstr = 'DefaultEndpointsProtocol=https;AccountName=${storage.name};EndpointSuffix=${environment().suffixes.storage};AccountKey=${storage.listKeys().keys[0].value}'

var functionAppName = toLower('${prefix}-${suffix}')

// Set standard app settings
// https://learn.microsoft.com/en-us/azure/azure-functions/functions-app-settings
var appsettings = concat(
  [
    {
      name: 'AzureWebJobsStorage'
      value: storcstr
    }
    {
      name: 'WEBSITE_CONTENTAZUREFILECONNECTIONSTRING'
      value: storcstr
    }
    {
      name: 'WEBSITE_CONTENTSHARE'
      value: functionAppName
    }
    {
      name: 'FUNCTIONS_EXTENSION_VERSION'
      value: '~4'
    }
    {
      name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
      value: applicationInsights.properties.InstrumentationKey
    }
    {
      name: 'FUNCTIONS_WORKER_RUNTIME'
      value: fnRuntime
    }
  ],
  configuration
)

resource functionApp 'Microsoft.Web/sites@2022-03-01' = {
  name: functionAppName
  location: location
  kind: 'functionapp'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    serverFarmId: hostingPlan.id
    siteConfig: {
      appSettings: appsettings
      ftpsState: 'FtpsOnly'
      minTlsVersion: '1.2'
    }
    httpsOnly: true
  }
}

resource applicationInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: 'insight-${suffix}'
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
    Request_Source: 'rest'
  }
}

output result object = {
  name: functionApp.name
  id: functionApp.id
  principal: functionApp.identity.principalId
}
