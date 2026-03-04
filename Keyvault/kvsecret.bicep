//
// Adds a new secret to an existing Key Vault
//

@description('Name of the existing Key Vault to store the client secret')
param keyVaultName string

@description('Name of the secret to create in Key Vault')
param secretName string = 'ClientSecret'

@description('Value of the secret to store in Key Vault')
@secure()
param secretValue string

// Reference the existing Key Vault
resource kv 'Microsoft.KeyVault/vaults@2023-07-01' existing = {
  name: keyVaultName
}

resource secrets 'Microsoft.KeyVault/vaults/secrets@2024-11-01' = {
  parent: kv
  name: secretName
  properties: {
    value: secretValue
  }
}
