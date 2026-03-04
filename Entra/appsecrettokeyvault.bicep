//
// Adds a client secret to an existing Entra ID application and service principal, and stores the secret value in Key Vault
//
// See: https://learn.microsoft.com/en-us/graph/templates/bicep/reference/overview?view=graph-bicep-1.0
//

@description('Name of the existing Entra ID application')
param appDisplayName string

@description('Name of the existing Key Vault to store the client secret')
param keyVaultName string

@description('Name of the secret to create in Key Vault')
param secretName string = '${appDisplayName}-ClientSecret'

@description('The current UTC time, used to calculate secret expiration')
param currentTime string = utcNow()

// Use Microsoft Graph extension configured in bicepconfig.json
extension microsoftGraphV1

// Reference the existing Entra ID Application
resource app 'Microsoft.Graph/applications@v1.0' existing = {
  uniqueName: appDisplayName
}

// Reference the existing Key Vault
resource kv 'Microsoft.KeyVault/vaults@2023-07-01' existing = {
  name: keyVaultName
}

// Update the application with a new client secret that expires in 1 year
resource appWithSecret 'Microsoft.Graph/applications@v1.0' = {
  uniqueName: appDisplayName
  displayName: app.displayName
  description: app.description
  signInAudience: app.signInAudience

  // Add a client secret that expires in 1 year
  passwordCredentials: [
    {
      displayName: currentTime
      endDateTime: dateTimeAdd(currentTime, 'P1Y')
    }
  ]
}

// Store the client secret in Key Vault
resource secret 'Microsoft.KeyVault/vaults/secrets@2023-07-01' = {
  parent: kv
  name: secretName
  properties: {
    value: appWithSecret.passwordCredentials[0].secretText
  }
}

@description('The application (client) ID')
output applicationId string = appWithSecret.appId

@description('The object ID of the application')
output applicationObjectId string = appWithSecret.id

@description('The name of the secret stored in Key Vault')
output secretName string = secret.name

@description('The expiration date of the client secret')
output secretExpirationDate string = appWithSecret.passwordCredentials[0].endDateTime

