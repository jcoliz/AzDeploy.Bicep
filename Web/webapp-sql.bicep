//
// Deploys a Linux-based App Service
// https://learn.microsoft.com/en-us/azure/app-service/
//
// With a connected Sql Server database
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

@description('Optional name of key vault resource')
param keyVaultName string = ''

@description('Optional name of resource group containing key vault resource, required if key vault resource supplied')
param keyVaultGroup string = ''

param administratorLogin string
@secure()
param administratorLoginPassword string

@description('Optional flag whether we should also deploy associated storage (default false)')
param includeStorage bool = false

resource kv 'Microsoft.KeyVault/vaults@2023-07-01' existing = if (!empty(keyVaultName)) {
  scope: resourceGroup(keyVaultGroup)
  name: keyVaultName
}

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

var kvconfiguration = empty(keyVaultName) ? [] : [
  {
    name: 'KEYVAULTENDPOINT'
    value: kv.properties.vaultUri
  }
]

var mergedconfiguration = concat(
  configuration,
  kvconfiguration
)

module sql '../Sql/sql.bicep' = {
  name: 'sql'
  params: {
    suffix: suffix
    location: location
    administratorLogin: administratorLogin
    administratorLoginPassword: administratorLoginPassword
  }
}

module web './webapp.bicep' = {
  name: 'web'
  params: {
    suffix: suffix
    location: location
    sku: sku
    customDomainVerificationId: customDomainVerificationId
    configuration: mergedconfiguration
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

// Deploy 'Key Vault Secrets User' role onto the KeyVault for this web app
module kvrole 'webapp-kv-role.bicep' = if (!empty(keyVaultName)) {
  name: 'kvrole'
  params: {
    webAppName: web.outputs.webAppName
    keyVaultName: keyVaultName
    keyVaultGroup: keyVaultGroup
  }
}

module storage '../Storage/storage.bicep' = if (includeStorage) {
  name: 'storage'
  params: {
    suffix: suffix
    location: location
  }
}

module webSqlConfig './webapp-sql-config.bicep' = {
  name: 'sqlconfig'
  params: {
    sqlServerName: sql.outputs.serverName
    sqlDbName: sql.outputs.dbName
    storageName: includeStorage ? storage.outputs.storageName : ''
    webAppName: web.outputs.webAppName
    administratorLogin: administratorLogin
    administratorLoginPassword: administratorLoginPassword
  }
}

output sqlServerName string = sql.outputs.serverName
output sqlDbName string = sql.outputs.dbName
output webAppName string = web.outputs.webAppName
output storageName string = storage.outputs.storageName
output readerRoleAssignmentName string = !empty(keyVaultName) ? kvrole.outputs.readerRoleAssignmentName : ''
output userRoleAssignmentName string = !empty(keyVaultName) ? kvrole.outputs.userRoleAssignmentName : ''
