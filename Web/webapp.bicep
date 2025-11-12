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

@description('Optional domain verification ID. Put this as a TXT DNS entry on ASUID.{yourdomain.com}')
param customDomainVerificationId string = ''

@description('Name of optional app insights resource')
param insightsName string = ''

var insightsSettings = empty(insightsName) ? [] : [
  {
    name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
    value: insights.properties.ConnectionString
  }
  {
    name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
    value: insights.properties.InstrumentationKey
  }
  {
    name: 'ApplicationInsightsAgent_EXTENSION_VERSION'
    value: '~3'
  }
  {
    name: 'XDT_MicrosoftApplicationInsights_Mode'
    value: 'default'
  }
]

resource insights 'Microsoft.Insights/components@2020-02-02-preview' existing = if (!empty(insightsName)) {
  name: insightsName
}

resource hostingPlan 'Microsoft.Web/serverfarms@2022-03-01' = {
  name: 'farm-${suffix}'
  location: location
  sku: {
    name: sku
    tier: tier
  }
  kind: 'linux'
  properties: {
    reserved: true
  }
}

// Set standard app settings
var appsettings = concat(
  [
    {
      name: 'ASPNETCORE_ENVIRONMENT'
      value: 'Production'
    }
    {
      name: 'WEBSITE_HTTPLOGGING_RETENTION_DAYS'
      value: '5'
    }
  ],
  insightsSettings,
  configuration
)

resource webapp 'Microsoft.Web/sites@2023-01-01' = {
  name: '${prefix}-${suffix}'
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    clientAffinityEnabled: false
    serverFarmId: hostingPlan.id
    httpsOnly: true
    customDomainVerificationId: customDomainVerificationId
    siteConfig: {
      linuxFxVersion: 'DOTNETCORE|10.0'
      appSettings: appsettings
      minTlsVersion: '1.2'
      alwaysOn: (sku == 'F1') ? false : true
      httpLoggingEnabled: true
      logsDirectorySizeLimit: 35
    }
  }
}

resource logs 'Microsoft.Web/sites/config@2023-01-01' = {
  parent: webapp
  name: 'logs'
  properties: {
    applicationLogs: {
      fileSystem: {
        level: 'Information'
      }
    }
    httpLogs: {
      fileSystem: {
        enabled: true
        retentionInDays: 5
        retentionInMb: 35
      }
    }
  }
}

output webAppName string = webapp.name
output webAppDefaultHostName string = webapp.properties.defaultHostName
output hostingPlanName string = hostingPlan.name
output webPrincipal string = webapp.identity.principalId
output webTenant string = webapp.identity.tenantId
