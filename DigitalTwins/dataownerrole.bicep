//
// Deploys a role assignment for the Azure Digital Twins Data Owner role
//    on an existing Digital Twins instance
//
// Cribbed from https://github.com/Azure/azure-quickstart-templates/blob/master/quickstarts/microsoft.digitaltwins/digitaltwins-with-function-time-series-database-connection/modules/roleassignment.bicep
//

@description('Existing Digital Twin resource name')
param digitalTwinsName string

@description('The id that will be given data owner permission for the Digital Twins resource')
param principalId string

@description('The type of the given principal id')
param principalType string

// Azure RBAC Guid Source: https://docs.microsoft.com/en-us/azure/role-based-access-control/built-in-roles
var azureRbacAzureDigitalTwinsDataOwner = 'bcd981a7-7f74-457b-83e1-cceb9e632ffe'

// Gets Digital Twins resource
resource digitalTwins 'Microsoft.DigitalTwins/digitalTwinsInstances@2022-10-31' existing = {
  name: digitalTwinsName
}

// Assigns the given principal id input data owner of Digital Twins resource
resource givenIdToDigitalTwinsRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(digitalTwins.id, principalId, azureRbacAzureDigitalTwinsDataOwner)
  scope: digitalTwins
  properties: {
    principalId: principalId
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', azureRbacAzureDigitalTwinsDataOwner)
    principalType: principalType
  }
}
