//
// Creates an Azure Key Vault (and secrets)
//
// From: https://github.com/Azure/azure-quickstart-templates/blob/master/quickstarts/microsoft.keyvault/key-vault-secret-create/main.bicep
//

@description('Descriptor for this resource')
param prefix string = 'kv'

@description('Unique suffix for all resources in this deployment')
param suffix string = uniqueString(resourceGroup().id)

@description('Location for all resources.')
param location string = resourceGroup().location

@description('Specifies whether the key vault is a standard vault or a premium vault.')
@allowed([
  'standard'
  'premium'
])
param skuName string = 'standard'

param skuFamily string = 'A'

@description('Specifies whether Azure Virtual Machines are permitted to retrieve certificates stored as secrets from the key vault.')
param enabledForDeployment bool = false

@description('Specifies whether Azure Disk Encryption is permitted to retrieve secrets from the vault and unwrap keys.')
param enabledForDiskEncryption bool = false

@description('Specifies whether Azure Resource Manager is permitted to retrieve secrets from the key vault.')
param enabledForTemplateDeployment bool = false

@description('Specifies the Azure Active Directory tenant ID that should be used for authenticating requests to the key vault. Get it by using Get-AzSubscription cmdlet.')
param tenantId string = subscription().tenantId

@description('Specifies all secrets {"secretName":"","secretValue":""} wrapped in a secure object.')
@secure()
param secretsObject object

resource kv 'Microsoft.KeyVault/vaults@2023-07-01' = {
  name: '${prefix}-${suffix}'
  location: location
  properties: {
    enabledForDeployment: enabledForDeployment
    enabledForTemplateDeployment: enabledForTemplateDeployment
    enabledForDiskEncryption: enabledForDiskEncryption
    tenantId: tenantId
    enableRbacAuthorization: true
    sku: {
      name: skuName
      family: skuFamily
    }
    networkAcls: {
      defaultAction: 'Allow'
      bypass: 'AzureServices'
    }
  }
}

// TODO: This doesn't work.
//
// "InvalidTemplate - Deployment template validation failed: 'The template 'copy' definition at line '1' and column '2949' has an invalid copy count of: '[length(parameters('secretsObject').secrets)]'. The copy count must be a non-negative integer value and cannot exceed '800'. Please see https://aka.ms/arm-resource-loops for usage details.'."
//
//resource secrets 'Microsoft.KeyVault/vaults/secrets@2024-11-01' = [for secret in secretsObject.secrets: {
//  parent: kv
//  name: secret.secretName
//  properties: {
//    value: secret.secretValue
//  }
//}]

output name string = kv.name
output endpoint string = kv.properties.vaultUri

