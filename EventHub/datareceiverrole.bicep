//
// Assign 'Azure Event Hubs Data Receiver' for the given principal
//    on an existing Event Hubs instance
//

@description('Existing Event Hub namespace name')
param eventHubNamespaceName string

@description('Existing Event Hub instance name')
param eventHubName string

@description('The id that will be given data owner permission for the Event Hubs instance')
param principalId string

@description('The type of the given principal id')
@allowed([ 'User', 'Group', 'ServicePrincipal'])
param principalType string = 'ServicePrincipal'

// Azure RBAC Guid Source: https://docs.microsoft.com/en-us/azure/role-based-access-control/built-in-roles
var azureRbacAzureEventHubsDataReceiver = 'a638d3c7-ab3a-418d-83e6-5f17a39d4fde'

// Gets Event Hubs namespace
resource eventHubNamespace 'Microsoft.EventHub/namespaces@2024-01-01' existing = {
  name: eventHubNamespaceName
}

// Gets Event Hubs instance
resource eventHubInstance 'Microsoft.EventHub/namespaces/eventhubs@2024-01-01' existing = {
  name: eventHubName
  parent: eventHubNamespace
}

// Assigns the given principal id to data receiver of Event Hub instance
resource givenIdToEventHubsRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(eventHubInstance.id, principalId, azureRbacAzureEventHubsDataReceiver)
  scope: eventHubInstance
  properties: {
    principalId: principalId
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', azureRbacAzureEventHubsDataReceiver)
    principalType: principalType
  }
}
