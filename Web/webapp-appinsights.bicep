//
// Deploys a Linux-based App Service
// https://learn.microsoft.com/en-us/azure/app-service/
//
// With a connected Applications Insights instance and Log Analytics workspace
//

@description('Unique suffix for all resources in this deployment')
param suffix string = uniqueString(resourceGroup().id)

@description('Location for all resources.')
param location string = resourceGroup().location

@description('Hosting plan SKU.')
param sku string = 'B1'

@description('Optional custom domain to assign')
param customDomain string = ''

@description('Optional domain verification ID. Put this as a TXT DNS entry on ASUID.{yourdomain.com}')
param customDomainVerificationId string = ''

@description('Optional application settings environment vars')
param configuration array = []

module logs '../OperationalInsights/loganalytics.bicep' = {
  name: 'logs'
  params: {
    suffix: suffix
    location: location
  }
}

module insights '../Insights/appinsights.bicep' = {
  name: 'insights'
  params: {
    suffix: suffix
    location: location
    logAnalyticsName: logs.outputs.logAnalyticsName
  }
}

module web './webapp.bicep' = {
  name: 'web'
  params: {
    suffix: suffix
    location: location
    sku: sku
    customDomainVerificationId: customDomainVerificationId
    configuration: configuration
    insightsName: insights.outputs.name
  }
}

module certificate './certificate.bicep' = if (!empty(customDomain))  {
  name: 'certificate'
  params: {
    suffix: suffix
    location: location
    customDomain: customDomain
    webAppName: web.outputs.webAppName
    hostingPlanName: web.outputs.hostingPlanName
  }
}

output webAppName string = web.outputs.webAppName
output logAnalyticsName string = logs.outputs.logAnalyticsName
output appInsightsName string = insights.outputs.name
