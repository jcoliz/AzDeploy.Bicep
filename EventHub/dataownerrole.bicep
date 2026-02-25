//
// Deploys a role assignment for the Azure Event Hubs Data Owner role
//    on an existing Event Hubs namespace
//

@description('Existing Event Hub namespace name')
param eventHubName string

@description('The id that will be given data owner permission for the Event Hubs namespace')
param principalId string

@description('The type of the given principal id')
param principalType string

// Azure RBAC Guid Source: https://docs.microsoft.com/en-us/azure/role-based-access-control/built-in-roles
var azureRbacAzureEventHubsDataOwner = 'f526a384-b230-433a-b45c-95f59c4a2dec'

// Gets Event Hubs namespace
resource eventHubNamespace'Microsoft.EventHub/namespaces@2024-01-01' existing = {
  name: eventHubName
}

// Assigns the given principal id input data owner of Event Hubs namespace
resource givenIdToEventHubsRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(eventHubNamespace.id, principalId, azureRbacAzureEventHubsDataOwner)
  scope: eventHubNamespace
  properties: {
    principalId: principalId
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', azureRbacAzureEventHubsDataOwner)
    principalType: principalType
  }
}
