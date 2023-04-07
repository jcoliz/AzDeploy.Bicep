//
// Deploys an Azure Container Registry
// https://learn.microsoft.com/en-us/azure/container-registry/
//

@description('Descriptor for this resource')
param prefix string = 'acr'

@description('Unique suffix for all resources in this deployment')
param suffix string = uniqueString(resourceGroup().id)

@description('Location for all resources.')
param location string = resourceGroup().location

@description('SKU name.')
param sku string = 'Basic'

resource acr 'Microsoft.ContainerRegistry/registries@2022-12-01' = {
  name: '${prefix}000${suffix}'
  location: location
  sku: {
    name: sku
  }
  properties: {
    adminUserEnabled: true
  }
}

output result object = {
  name: acr.name
  id: acr.id
  server: acr.properties.loginServer
  username: acr.listCredentials().username
  password: acr.listCredentials().passwords[0].value
}
