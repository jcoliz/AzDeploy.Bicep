//
// Deploys an Azure Front Door instance
// https://learn.microsoft.com/en-us/azure/frontdoor/
//
// Source: https://github.com/Azure/azure-quickstart-templates/blob/master/quickstarts/microsoft.cdn/front-door-standard-premium-storage-static-website/modules/front-door.bicep
//

@description('Descriptor for this resource')
param prefix string = 'fd'

@description('Unique suffix for all resources in this deployment')
param suffix string = uniqueString(resourceGroup().id)

@description('The name of the SKU to use when creating the Front Door profile. If you use Private Link this must be set to `Premium_AzureFrontDoor`.')
@allowed([
  'Standard_AzureFrontDoor'
  'Premium_AzureFrontDoor'
])
param skuName string = 'Standard_AzureFrontDoor'

@description('The host name that should be used when connecting to the origin.')
param originHostName string

@description('The custom domain name to associate with your Front Door endpoint, if any')
param customDomainName string = ''

var customDomainResourceName = replace(customDomainName, '.', '-')
var profileName = 'TheFrontDoor'
var originGroupName = 'TheOriginGroup'
var originName = 'TheOrigin'
var routeName = 'TheRoute'

resource profile 'Microsoft.Cdn/profiles@2021-06-01' = {
  name: profileName
  location: 'global'
  sku: {
    name: skuName
  }
}

resource endpoint 'Microsoft.Cdn/profiles/afdEndpoints@2021-06-01' = {
  parent: profile
  name: '${prefix}-${suffix}'
  location: 'global'
  properties: {
    enabledState: 'Enabled'
  }
}

resource originGroup 'Microsoft.Cdn/profiles/originGroups@2021-06-01' = {
  parent: profile
  name: originGroupName
  properties: {
    loadBalancingSettings: {
      sampleSize: 4
      successfulSamplesRequired: 3
    }
    healthProbeSettings: {
      probePath: '/'
      probeRequestType: 'HEAD'
      probeProtocol: 'Http'
      probeIntervalInSeconds: 100
    }
  }
}

resource origin 'Microsoft.Cdn/profiles/originGroups/origins@2021-06-01' = {
  parent: originGroup
  name: originName
  properties: {
    hostName: originHostName
    httpPort: 80
    httpsPort: 443
    originHostHeader: originHostName
    priority: 1
    weight: 1000
  }
}

resource customDomain 'Microsoft.Cdn/profiles/customDomains@2020-09-01' = if (! empty(customDomainName)) {
  parent: profile
  name: customDomainResourceName
  properties: {
    hostName: customDomainName
    tlsSettings: {
      certificateType: 'ManagedCertificate'
      minimumTlsVersion: 'TLS12'
    }
  }
}

resource route 'Microsoft.Cdn/profiles/afdEndpoints/routes@2021-06-01' = {
  parent: endpoint
  name: routeName
  dependsOn: [
    origin // This explicit dependency is required to ensure that the origin group is not empty when the route is created.
  ]
  properties: {
    originGroup: {
      id: originGroup.id
    }
    customDomains: (!empty(customDomainName)) ? [] : [
      {
        id: customDomain.id
      }
    ]
    supportedProtocols: [
      'Http'
      'Https'
    ]
    patternsToMatch: [
      '/*'
    ]
    forwardingProtocol: 'HttpsOnly'
    linkToDefaultDomain: 'Enabled'
    httpsRedirect: 'Enabled'
  }
}

output frontDoorEndpointHostName string = endpoint.properties.hostName
output customDomainValidationDnsTxtRecordName string = '_dnsauth.${customDomain.properties.hostName}'
output customDomainValidationDnsTxtRecordValue string = customDomain.properties.validationProperties.validationToken
output customDomainValidationExpiry string = customDomain.properties.validationProperties.expirationDate
