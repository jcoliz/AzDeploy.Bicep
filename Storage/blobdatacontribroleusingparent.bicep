//
// Deploys a role assignment for the Storage Blob Data Contributor role
//    on an existing storage container
//

@description('Existing storage account name')
param storageAccountName string

@description('Existing storage container name')
param containerName string

@description('The id that will be given data owner permission for the Digital Twins resource')
param principalId string

@description('The type of the given principal id')
param principalType string

// Azure RBAC Guid Source: https://docs.microsoft.com/en-us/azure/role-based-access-control/built-in-roles
var azureRbacStorageBlobDataContributor = 'ba92f5b4-2d11-453d-a403-e96b0029c9fe'

resource storageAccount 'Microsoft.Storage/storageAccounts@2024-01-01' existing = {
  name: storageAccountName
}

resource blobService 'Microsoft.Storage/storageAccounts/blobServices@2024-01-01' existing = {
  name: 'default'
  parent: storageAccount
}

// Gets Container resource
resource container 'Microsoft.Storage/storageAccounts/blobServices/containers@2022-09-01' existing = {
  name: containerName
  parent: blobService
}

// Assigns the given principal id input data owner of Digital Twins resource
resource givenIdToBlobContributorRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  scope: container
  name: guid(container.id, principalId, azureRbacStorageBlobDataContributor)
  properties: {
    principalId: principalId
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', azureRbacStorageBlobDataContributor)
    principalType: principalType
  }
}
