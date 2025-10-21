//
// Deploys a role assignment for the Key Vault Reader
//    on an existing Key Vault instance
//

@description('Existing Key vault resource name')
param keyVaultName string

@description('The id that will be given reader permission for the resource')
param principalId string

@description('The type of the given principal id')
param principalType string

// Azure RBAC Guid Source: https://docs.microsoft.com/en-us/azure/role-based-access-control/built-in-roles
var azureRbacKeyVaultReader = '21090545-7ca7-4776-b22c-e363652d74d2'

// Get Key Vault resource
resource kv 'Microsoft.KeyVault/vaults@2021-04-01-preview' existing = {
  name: keyVaultName
}

// Assigns the given principal id input data owner of Key Vault resource
resource givenIdToKeyVaultRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  scope: kv
  name: guid(kv.id, principalId, azureRbacKeyVaultReader)
  properties: {
    principalId: principalId
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', azureRbacKeyVaultReader)
    principalType: principalType
  }
}

output roleAssignmentName string = givenIdToKeyVaultRoleAssignment.name
