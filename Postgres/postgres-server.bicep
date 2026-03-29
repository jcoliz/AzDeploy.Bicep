//
// Deploys an Azure Database for PostgreSQL Flexible Server
// https://learn.microsoft.com/en-us/azure/postgresql/flexible-server/
//
// Entra-only authentication (no password auth).
// Designed to be created once and shared by multiple databases/apps/environments.
//

@minLength(2)
@description('Descriptor for this resource')
param prefix string = 'postgres'

@minLength(2)
@description('Unique suffix for all resources in this deployment')
param suffix string = uniqueString(resourceGroup().id)

@description('Location for all resources.')
param location string = resourceGroup().location

@description('Object ID of the Entra admin principal')
param entraAdminPrincipalId string

@description('UPN or display name of the Entra admin principal (required by the Azure API)')
param entraAdminPrincipalName string

@description('Type of the Entra admin principal')
@allowed([
  'User'
  'Group'
  'ServicePrincipal'
])
param entraAdminPrincipalType string = 'User'

var skuName = 'Standard_B1ms'
var skuTier = 'Burstable'
var postgresVersion = '17'
var storageSizeGB = 32

resource server 'Microsoft.DBforPostgreSQL/flexibleServers@2024-08-01' = {
  name: '${prefix}-${suffix}'
  location: location
  sku: {
    name: skuName
    tier: skuTier
  }
  properties: {
    version: postgresVersion
    storage: {
      storageSizeGB: storageSizeGB
    }
    authConfig: {
      activeDirectoryAuth: 'Enabled'
      passwordAuth: 'Disabled'
    }
    highAvailability: {
      mode: 'Disabled'
    }
  }
}

// Allow connections from Azure services
resource firewallAllowAzure 'Microsoft.DBforPostgreSQL/flexibleServers/firewallRules@2024-08-01' = {
  parent: server
  name: 'AllowAllAzureServicesAndResourcesWithinAzureIps'
  properties: {
    startIpAddress: '0.0.0.0'
    endIpAddress: '0.0.0.0'
  }
}

// Entra admin assignment
resource admin 'Microsoft.DBforPostgreSQL/flexibleServers/administrators@2024-08-01' = {
  parent: server
  name: entraAdminPrincipalId
  properties: {
    principalName: entraAdminPrincipalName
    principalType: entraAdminPrincipalType
    tenantId: subscription().tenantId
  }
  dependsOn: [
    firewallAllowAzure
  ]
}

output serverName string = server.name
output serverFqdn string = server.properties.fullyQualifiedDomainName
