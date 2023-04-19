//
// Deploys an Azure Digital Twins instance
// https://learn.microsoft.com/en-us/azure/digital-twins/
//
// Cribbed from: https://github.com/Azure/azure-quickstart-templates/blob/master/quickstarts/microsoft.digitaltwins/digitaltwins-with-function-time-series-database-connection/modules/digitaltwins.bicep
//

@description('Descriptor for this resource')
param prefix string = 'dtwin'

@description('Unique suffix for all resources in this deployment')
param suffix string = uniqueString(resourceGroup().id)

@description('Location for all resources.')
@allowed([
  'westcentralus'
  'westus2'
  'westus3'
  'northeurope'
  'australiaeast'
  'westeurope'
  'eastus'
  'southcentralus'
  'southeastasia'
  'uksouth'
  'eastus2'
])
param location string

// Creates Digital Twins instance
resource digitalTwins 'Microsoft.DigitalTwins/digitalTwinsInstances@2023-01-31' = {
  name: '${prefix}-${suffix}'
  location: location
  identity: {
    type: 'SystemAssigned'
  }
}

output result object = {
  name: digitalTwins.name
  id: digitalTwins.id
  host: digitalTwins.properties.hostName
  principal: digitalTwins.identity.principalId
  tenant: digitalTwins.identity.tenantId
}
