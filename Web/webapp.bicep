//
// Deploys a Linux-based App Service
// https://learn.microsoft.com/en-us/azure/app-service/
//

@description('Descriptor for this resource')
param prefix string = 'web'

@description('Unique suffix for all resources in this deployment')
param suffix string = uniqueString(resourceGroup().id)

@description('Location for all resources.')
param location string = resourceGroup().location

@description('Hosting plan SKU.')
param sku string = 'B1'

@description('Hosting plan tier.')
param tier string = 'Basic'

@description('Optional application settings environment vars')
param configuration array = []

resource hostingPlan 'Microsoft.Web/serverfarms@2022-03-01' = {
  name: 'farm-${suffix}'
  location: location
  kind: 'linux'
  properties: {
    reserved: true
  }
  sku: {
    name: sku
    tier: tier
  }
}

// Set standard app settings
var appsettings = concat(
  [
    {
      name: 'ASPNETCORE_ENVIRONMENT'
      value: 'Production'
    }
  ],
  configuration
)

resource webapp 'Microsoft.Web/sites@2022-03-01' = {
  name: '${prefix}-${suffix}'
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    serverFarmId: hostingPlan.id
    siteConfig: {
      linuxFxVersion: 'DOTNETCORE|8.0'
      appSettings: appsettings
      minTlsVersion: '1.2'
    }
    httpsOnly: false
  }
}

output webAppName string = webapp.name
