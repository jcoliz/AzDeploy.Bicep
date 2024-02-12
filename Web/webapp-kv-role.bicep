//
// Deploys Key Vault Secrets User role onto a Key Vault for a Web App
//
// NOTE: Deploy this onto the group of the web resource, and supply tne
// separate name of the resource group where the KV resource is deployed
//
// THese are kept in separate RG's, because their lifetime differs. KV
// expected to outlive web resources
//

@description('Existing Key vault resource name')
param keyVaultName string

@description('Name of resource group containing web app resource')
param keyVaultGroup string

@description('Name of required web app resource')
param webAppName string

resource webapp 'Microsoft.Web/sites@2022-03-01' existing = {
  name: webAppName
}

module role '../Keyvault/secretsuserrole.bicep' = {
  name: 'web'
  scope: resourceGroup(keyVaultGroup)
  params: {
    keyVaultName: keyVaultName
    principalId: webapp.identity.principalId
    principalType: 'ServicePrincipal'
  }
}

output roleAssignmentName string = role.outputs.roleAssignmentName
