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

param administratorLogin string
@secure()
param administratorLoginPassword string

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

output sqlServerName string = sql.outputs.serverName
output sqlDbName string = sql.outputs.dbName
output webAppName string = web.outputs.webAppName
