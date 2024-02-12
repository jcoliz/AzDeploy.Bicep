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

@description('Optional custom domain to assign')
param customDomain string = ''

@description('Optional domain verification ID. Put this as a TXT DNS entry on ASUID.{yourdomain.com}')
param customDomainVerificationId string = ''

@description('Name of optional key vault resource')
param keyVaultName string

@description('Name of resource group containing key vault resource')
param keyVaultGroup string

param administratorLogin string
@secure()
param administratorLoginPassword string

resource kv 'Microsoft.KeyVault/vaults@2023-07-01' existing = if (!empty(keyVaultName)) {
  name: keyVaultName
  scope: resourceGroup(keyVaultGroup)
} 

var configuration = empty(keyVaultName) ? [] : [
  {
    name: 'KEYVAULTENDPOINT'
    value: kv.properties.vaultUri
  }
]

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
    customDomainVerificationId: customDomainVerificationId
    configuration: configuration
  }
}

module webSqlConfig './webapp-sql-config.bicep' = {
  name: 'sqlconfig'
  params: {
    sqlServerName: sql.outputs.serverName
    sqlDbName: sql.outputs.dbName
    webAppName: web.outputs.webAppName
    administratorLogin: administratorLogin
    administratorLoginPassword: administratorLoginPassword
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

output sqlServerName string = sql.outputs.serverName
output sqlDbName string = sql.outputs.dbName
output webAppName string = web.outputs.webAppName
output roleAssignmentName string = kvrole.outputs.roleAssignmentName
