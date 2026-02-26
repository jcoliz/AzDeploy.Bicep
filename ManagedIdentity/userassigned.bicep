@description('Descriptor for this resource')
param prefix string = 'identity'

@description('Unique suffix for all resources in this deployment')
param suffix string = uniqueString(resourceGroup().id)

@description('Location for all resources.')
param location string = resourceGroup().location

// Create a user-assigned managed identity
resource identity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: '${prefix}-${suffix}'
  location: location
}

output servicePrincipalId string = identity.properties.principalId
output identityName string = identity.name
