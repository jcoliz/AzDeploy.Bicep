//
// Deploys an Azure Static Web App with a custom domain
// https://learn.microsoft.com/en-us/azure/static-web-apps/
//

@description('Descriptor for this resource')
param prefix string = 'static'

@description('Unique suffix for all resources in this deployment')
param suffix string = uniqueString(resourceGroup().id)

@description('Location for all resources.')
param location string = resourceGroup().location

@description('Name of the resource SKU.')
param sku string = 'Free'

@description('Service tier of the resource SKU.')
param tier string = 'Free'

@description('Custom domain name')
param customDomain string

resource staticapp 'Microsoft.Web/staticSites@2023-12-01' = {
  name: '${prefix}-${suffix}'
  location: location
  sku: {
    name: sku
    tier: tier
  }
  properties: { 
    enterpriseGradeCdnStatus: 'Disabled' 
    provider: 'None'
    allowConfigFileUpdates: true 
    stagingEnvironmentPolicy: 'Enabled'
  }
}

resource domain 'Microsoft.Web/staticSites/customDomains@2023-12-01' = {  
  parent: staticapp
  name: customDomain
}

output name string = staticapp.name
output defaultHostname string = staticapp.properties.defaultHostname
