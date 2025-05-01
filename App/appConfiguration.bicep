//
// Deploys an App Configuration store
// https://learn.microsoft.com/en-us/azure/azure-app-configuration/quickstart-resource-manager
// https://learn.microsoft.com/en-us/azure/templates/microsoft.appconfiguration/configurationstores?pivots=deployment-language-bicep
//

@description('Descriptor for this resource')
param prefix string = 'appconfig'

@description('Unique suffix for all resources in this deployment')
@minLength(5)
param suffix string = uniqueString(resourceGroup().id)

@description('Location for all resources.')
param location string = resourceGroup().location

resource configuration 'Microsoft.AppConfiguration/configurationStores@2024-05-01' = {
  name: '${prefix}-${suffix}'
  location: location
  sku: {
    name: 'free'
  }
}
