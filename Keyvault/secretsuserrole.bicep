//
// Deploys a role assignment for the Key Vault Secrets User
//    on an existing Key Vault instance
//
// Cribbed from https://github.com/Azure/azure-quickstart-templates/blob/master/quickstarts/microsoft.digitaltwins/digitaltwins-with-function-time-series-database-connection/modules/roleassignment.bicep
//

@description('Existing Key vault resource name')
param keyVaultName string

@description('The id that will be given data owner permission for the resource')
param principalId string

@description('The type of the given principal id')
param principalType string

// Azure RBAC Guid Source: https://docs.microsoft.com/en-us/azure/role-based-access-control/built-in-roles
var azureRbacKeyVaultSecretsUser = '4633458b-17de-408a-b874-0445c86b69e6'

// Gets Digital Twins resource
resource kv 'Microsoft.KeyVault/vaults@2021-04-01-preview' existing = {
  name: keyVaultName
}

// Assigns the given principal id input data owner of Digital Twins resource
resource givenIdToDigitalTwinsRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(kv.id, principalId, azureRbacKeyVaultSecretsUser)
  scope: kv
  properties: {
    principalId: principalId
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', azureRbacKeyVaultSecretsUser)
    principalType: principalType
  }
}

output roleAssignmentName string = givenIdToDigitalTwinsRoleAssignment.name
