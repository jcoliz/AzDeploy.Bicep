//
// Deploys a role assignment for the Key Vault Secrets Officer
//    on an existing Key Vault instance
//

@description('Existing Key vault resource name')
param keyVaultName string

@description('The id that will be given data owner permission for the resource')
param principalId string

@description('The type of the given principal id')
param principalType string

// Azure RBAC Guid Source: https://docs.microsoft.com/en-us/azure/role-based-access-control/built-in-roles
var azureRbacKeyVaultSecretsOfficer = 'b86a8fe4-44ce-4948-aee5-eccb2c155cd7'

// Get Key Vault resource
resource kv 'Microsoft.KeyVault/vaults@2021-04-01-preview' existing = {
  name: keyVaultName
}

// Assigns the given principal id input data owner of Key Vault resource
resource givenIdToKeyVaultRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  scope: kv
  name: guid(kv.id, principalId, azureRbacKeyVaultSecretsOfficer)
  properties: {
    principalId: principalId
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', azureRbacKeyVaultSecretsOfficer)
    principalType: principalType
  }
}

output roleAssignmentName string = givenIdToKeyVaultRoleAssignment.name
