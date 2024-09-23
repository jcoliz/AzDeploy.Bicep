//
// Deploys a role assignment for the Monitoring Metrics Publisher
//    on an existing Data Collection Rule
//

@description('Existing Data Collection Rule name')
param dcrName string

@description('The id that will be given data owner permission for the Data Collection Rule resource')
param principalId string

@description('The type of the given principal id')
param principalType string

// Azure RBAC Guid Source: https://docs.microsoft.com/en-us/azure/role-based-access-control/built-in-roles
var azureRbacMonitoringMetricsPublisher = '3913510d-42f4-4e42-8a64-420c390055eb'

// Gets Data Collection resource
resource dcr 'Microsoft.Insights/dataCollectionRules@2023-03-11' existing = {
  name: dcrName
}

// Assigns the given principal id input data owner of Digital Twins resource
resource givenIdToDigitalTwinsRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(dcr.id, principalId, azureRbacMonitoringMetricsPublisher)
  scope: dcr
  properties: {
    principalId: principalId
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', azureRbacMonitoringMetricsPublisher)
    principalType: principalType
  }
}
