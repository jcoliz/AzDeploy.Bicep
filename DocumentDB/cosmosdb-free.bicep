//
// Deploys a Free-tier CosmosDB (DocumentDB)
//    https://learn.microsoft.com/en-us/azure/cosmos-db/
//
// This template will create a free-tier Azure Cosmos account for SQL API in 
// a single region, a database with shared throughput of 1000 RU/s and one 
// container. Accounts in free tier will not be billed for usage of 1000 
// RU/s or 50 GB of data or less.
//
// Cribbed from: https://github.com/Azure/azure-quickstart-templates/tree/master/quickstarts/microsoft.documentdb/cosmosdb-free
//

@description('Descriptor for this resource')
param prefix string = 'cosmos'

@description('Unique suffix for all resources in this deployment')
param suffix string = uniqueString(resourceGroup().id)

@description('Location for all resources.')
param location string = resourceGroup().location

@description('The name for the SQL API database')
param databaseName string = 'database'

@description('The name for the SQL API container')
param containerName string = 'container'

// properties/resource is really solution-dependent, so caller should construct a
// complete object
@description('The resource properties for the containr')
param resourceProperties object

resource account 'Microsoft.DocumentDB/databaseAccounts@2023-03-01-preview' = {
  name: '${prefix}-${suffix}'
  location: location
  properties: {
    enableFreeTier: true
    databaseAccountOfferType: 'Standard'
    consistencyPolicy: {
      defaultConsistencyLevel: 'Session'
    }
    locations: [
      {
        locationName: location
      }
    ]
  }
}

resource database 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases@2023-03-01-preview' = {
  parent: account
  name: databaseName
  properties: {
    resource: {
      id: databaseName
    }
    options: {
      throughput: 1000
    }
  }
}

resource container 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers@2023-03-01-preview' = {
  parent: database
  name: containerName
  properties: {
    resource: union(resourceProperties, { id: containerName })      
  }
}

output name string = account.name
