
param customDomain string = 'www.chompr.net'

@description('Unique suffix for all resources in this deployment')
param suffix string = uniqueString(resourceGroup().id)

@description('Location for all resources.')
param location string = resourceGroup().location

@description('Name of required hosting plan resource')
param hostingPlanName string = 'farm-${suffix}'

@description('Name of required web app resource')
param webAppName string = 'web-${suffix}'

resource hostingPlan 'Microsoft.Web/serverfarms@2022-03-01' existing = {
  name: hostingPlanName
}

resource hostBinding 'Microsoft.Web/sites/hostNameBindings@2023-01-01' = {
  name: '${webAppName}/${customDomain}'
  properties: {
    siteName: webAppName
    hostNameType: 'Verified'
  }
}

// Can't create certificate until host name binding has been initially created
resource certificate 'Microsoft.Web/certificates@2020-12-01' = {
  location: location
  name: '${customDomain}-${suffix}'
  properties: {
    serverFarmId: hostingPlan.id
    canonicalName: customDomain
  }
  dependsOn: [ 
    hostBinding 
  ]
}

// Once we have the certificate, then need to add it to the existing host name binding
module certBinding './certificate-binding.bicep' = {
  name: 'certBinding'
  params: {
    certificateName: certificate.name
    hostBindingName: hostBinding.name
  }
}
