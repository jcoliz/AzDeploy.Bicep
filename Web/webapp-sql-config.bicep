//
// Deploys connection strings on a web app
//

@description('Name of required web app resource')
param webAppName string

@description('Name of required sql server resource')
param sqlServerName string

@description('Name of required sql db resource')
param sqlDbName string

param administratorLogin string
@secure()
param administratorLoginPassword string

@description('(Optional) Name of storage resource')
param storageName string = ''

resource storage 'Microsoft.Storage/storageAccounts@2023-05-01' existing = if (!empty(storageName)) {
  name: storageName
}

var cstr_storage = (!empty(storageName)) ? 'DefaultEndpointsProtocol=https;AccountName=${storageName};AccountKey=${storage.listKeys().keys[0].value};EndpointSuffix=${environment().suffixes.storage}' : ''

resource server 'Microsoft.Sql/servers@2021-05-01-preview' existing = {
  name: sqlServerName
}

var cstr = 'Server=tcp:${server.properties.fullyQualifiedDomainName},1433;Initial Catalog=${sqlDbName};Persist Security Info=False;User ID=${administratorLogin};Password=${administratorLoginPassword};MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;'

resource webapp 'Microsoft.Web/sites@2022-03-01' existing = {
  name: webAppName
}

resource config 'Microsoft.Web/sites/config@2023-01-01' = {
  parent: webapp
  name: 'connectionstrings'
  properties: {
    DefaultConnection : {
      value: cstr
      type: 'SQLAzure'
    }
    StorageConnection : {
      value: cstr_storage
      type: 'Custom'
    }
  }
}
