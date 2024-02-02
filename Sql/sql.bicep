@description('Descriptor for this resource')
param prefix string = 'sqlserver'

@description('Unique suffix for all resources in this deployment')
param suffix string = uniqueString(resourceGroup().id)

@description('Location for all resources.')
param location string = resourceGroup().location

@description('The name for the SQL API database')
param databaseName string = 'db'

param administratorLogin string
@secure()
param administratorLoginPassword string
param collation string = 'SQL_Latin1_General_CP1_CI_AS'
param tier string = 'Basic'
param skuName string = 'Basic'
param maxSizeBytes int = 2147483648
param publicNetworkAccess string = 'Enabled'
param minimalTlsVersion string = '1.2'

resource server 'Microsoft.Sql/servers@2021-05-01-preview' = {
  location: location
  name: '${prefix}-${suffix}'
  properties: {
    version: '12.0'
    minimalTlsVersion: minimalTlsVersion
    publicNetworkAccess: publicNetworkAccess
    administratorLogin: administratorLogin
    administratorLoginPassword: administratorLoginPassword
  }
}

resource firewall 'Microsoft.Sql/servers/firewallRules@2014-04-01' = {
  parent: server
  name: 'AllowAllWindowsAzureIps'
  properties: {
    startIpAddress: '0.0.0.0'
    endIpAddress: '0.0.0.0'
  }
}

resource db 'Microsoft.Sql/servers/databases@2023-05-01-preview' = {
  parent: server
  location: location
  name: databaseName
  properties: {
    collation: collation
    maxSizeBytes: maxSizeBytes
  }
  sku: {
    name: skuName
    tier: tier
  }
}

output serverName string = server.name
output dbName string = db.name

