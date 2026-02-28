//
// Deploys a role assignment for the Azure Event Hubs Data Sender role
//    on an existing Event Hubs namespace
//

@description('Existing Event Hub namespace name')
param eventHubName string

@description('The id that will be given data sender permission for the Event Hubs namespace')
param principalId string

@description('The type of the given principal id')
param principalType string

// Azure RBAC Guid Source: https://docs.microsoft.com/en-us/azure/role-based-access-control/built-in-roles
var azureRbacAzureEventHubsDataSender = '2b629674-e913-4c01-ae53-ef4638d8f975'

// Gets Event Hubs namespace
resource eventHubNamespace'Microsoft.EventHub/namespaces@2024-01-01' existing = {
  name: eventHubName
}

// Assigns the given principal id input data sender of Event Hubs namespace
resource givenIdToEventHubsRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  scope: eventHubNamespace
  name: guid(eventHubNamespace.id, principalId, azureRbacAzureEventHubsDataSender)
  properties: {
    principalId: principalId
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', azureRbacAzureEventHubsDataSender)
    principalType: principalType
  }
}
