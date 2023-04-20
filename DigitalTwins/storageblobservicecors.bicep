//
// Deploys a blob services service
//    Onto an existing storage account
//    And wires up CORS for https://explorer.digitaltwins.azure.net
//
// See: https://learn.microsoft.com/en-us/azure/digital-twins/how-to-use-3d-scenes-studio
//

@description('Name of storage account')
param account string

resource blobdefault 'Microsoft.Storage/storageAccounts/blobServices@2022-09-01' = {
  name: '${account}/default'
  properties: {
    cors: {
      corsRules: [
        {
          allowedOrigins: [
            'https://explorer.digitaltwins.azure.net'
          ]
          allowedMethods: [
            'GET'
            'OPTIONS'
            'POST'
            'PUT'
          ]
          maxAgeInSeconds: 0
          exposedHeaders: [
            ''
          ]
          allowedHeaders: [
            'Authorization'
            'x-ms-version'
            'x-ms-blob-type'
          ]
        }
      ]
    }
    deleteRetentionPolicy: {
      allowPermanentDelete: false
      enabled: false
    }
  }
}
