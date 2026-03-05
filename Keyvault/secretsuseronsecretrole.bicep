//
// Deploys a role assignment for the Key Vault Secrets User
//    on a single key in a Key Vault instance
//
// Cribbed from https://github.com/Azure/azure-quickstart-templates/blob/master/quickstarts/microsoft.digitaltwins/digitaltwins-with-function-time-series-database-connection/modules/roleassignment.bicep
//

@description('Existing Key vault resource name')
param keyVaultName string

@description('The name of the key for which to assign permissions')
param keyName string

@description('The id that will be given data owner permission for the resource')
param principalId string

@description('The type of the given principal id')
param principalType string = 'ServicePrincipal' // Default to service principal, but can be set to 'User' or 'Group' as well

// Azure RBAC Guid Source: https://docs.microsoft.com/en-us/azure/role-based-access-control/built-in-roles
var azureRbacKeyVaultSecretsUser = '4633458b-17de-408a-b874-0445c86b69e6'

// Get Key Vault resource
resource kv 'Microsoft.KeyVault/vaults@2021-04-01-preview' existing = {
  name: keyVaultName
}

// Get secret resoure
resource secret 'Microsoft.KeyVault/vaults/secrets@2024-11-01' existing = {
  parent: kv
  name: keyName
}

// Assigns the given principal id input data owner of Key Vault resource
resource givenIdToKeyVaultRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  scope: secret
  name: guid(secret.id, principalId, azureRbacKeyVaultSecretsUser)
  properties: {
    principalId: principalId
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', azureRbacKeyVaultSecretsUser)
    principalType: principalType
  }
}

output roleAssignmentName string = givenIdToKeyVaultRoleAssignment.name
