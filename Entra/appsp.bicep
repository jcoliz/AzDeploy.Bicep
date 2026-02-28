//
// Creates an Entra ID application and service principal
//
// See: https://learn.microsoft.com/en-us/graph/templates/bicep/reference/overview?view=graph-bicep-1.0
//
// NOTE: This template creates the application and service principal WITHOUT a client secret
// to avoid creating new secrets on every deployment. To create a client secret, you can use 
// the Azure CLI after deployment:
//
//   az ad app credential reset --id <APPLICATION_ID> --display-name "MySecret" --years 1
//

@description('Display name for the application')
param appDisplayName string

@description('Description of the application')
param appDescription string = ''

// Use Microsoft Graph extension configured in bicepconfig.json
extension microsoftGraphV1

// Create the Entra ID Application
resource app 'Microsoft.Graph/applications@v1.0' = {
  uniqueName: appDisplayName
  displayName: appDisplayName
  description: appDescription
  signInAudience: 'AzureADMyOrg'
  
  // Client secrets should be created separately after deployment (see header comments)
}

// Create the Service Principal
resource servicePrincipal 'Microsoft.Graph/servicePrincipals@v1.0' = {
  appId: app.appId
}

@description('The application (client) ID')
output applicationId string = app.appId

@description('The object ID of the application')
output applicationObjectId string = app.id

@description('The object ID of the service principal')
output servicePrincipalId string = servicePrincipal.id
