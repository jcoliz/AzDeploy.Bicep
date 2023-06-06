//
// Deploys a Free-tier CosmosDB (DocumentDB)
//    https://learn.microsoft.com/en-us/azure/cosmos-db/
//    With configuration for IoT Reference Architecture solution


@description('Unique suffix for all resources in this deployment')
param suffix string = uniqueString(resourceGroup().id)

@description('Location for all resources.')
param location string = resourceGroup().location

module cosmos 'cosmosdb-free.bicep' = {
  name: 'cosmos'
  params: {
    suffix: suffix
    location: location
    resourceProperties: {
      partitionKey: {
        paths: [
          '/__Device'
        ]
        kind: 'Hash'
      }
      indexingPolicy: {
        indexingMode: 'consistent'
        includedPaths: [
          {
            path: '/__Device/?'
          }
          {
            path: '/__Component/?'
          }
          {
            path: '/__Time/?'
          }
        ]
        excludedPaths: [
          {
            path: '/*'
          }
        ]
        compositeIndexes: [
          [
            {
              path: '/__Device'
              order: 'ascending'
            }
            {
              path: '/__Component'
              order: 'ascending'
            }
            {
              path: '/_Time'
              order: 'descending'
            }
          ]
        ]
        spatialIndexes: []
      }
      // One day. Probably fine for this
      defaultTtl: 86400      
    }
  }  
}
