//
// Deploys Key Vault Secrets User role onto a Key Vault for a Web App
//


@description('Existing Key vault resource name')
param keyVaultName string

@description('Name of required web app resource')
param webAppName string

@description('Name of resource group containing web app resource')
param webAppGroup string

resource webapp 'Microsoft.Web/sites@2022-03-01' existing = {
  name: webAppName
  scope: resourceGroup(webAppGroup)
}

module role '..//Keyvault/secretsuserrole.bicep' = {
  name: 'web'
  params: {
    keyVaultName: keyVaultName
    principalId: webapp.identity.principalId
    principalType: 'ServicePrincipal'
  }
}
