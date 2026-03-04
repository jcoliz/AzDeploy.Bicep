//
// Deploys a role assignment for the Storage Blob Data Reader role
//    on an existing storage account (applies to all containers in the storage account)
//

@description('Existing storage account full resource name')
param storageAccountName string

@description('The id that will be given data reader permission for the Storage account')
param principalId string

@description('The type of the given principal id')
param principalType string

// Azure RBAC Guid Source: https://docs.microsoft.com/en-us/azure/role-based-access-control/built-in-roles
var azureRbacStorageBlobDataReader = '2a2b9908-6ea1-4ae2-8e65-a410df84e7d1'

// Gets Storage account resource
resource storageAccount 'Microsoft.Storage/storageAccounts@2022-09-01' existing = {
  name: storageAccountName
}

// Assigns the given principal id input data owner of Storage account resource
resource givenIdToBlobDataReaderRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  scope: storageAccount
  name: guid(storageAccount.id, principalId, azureRbacStorageBlobDataReader)
  properties: {
    principalId: principalId
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', azureRbacStorageBlobDataReader)
    principalType: principalType
  }
}
