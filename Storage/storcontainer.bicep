//
// Deploys a Blob Container into a Storage Account
// https://learn.microsoft.com/en-us/azure/storage/blobs/storage-blobs-introduction
//

@description('Name of container')
param name string

@description('Name of storage account')
param account string

resource container 'Microsoft.Storage/storageAccounts/blobServices/containers@2022-09-01' = {
  name: '${account}/default/${name}'
  properties: {
    publicAccess: 'None'
  }
}

output result object = {
  name: container.name
  id: container.id
}
output name string = container.name
