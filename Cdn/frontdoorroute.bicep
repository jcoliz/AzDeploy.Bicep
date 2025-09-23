@description('Name of the existing Azure Front Door profile')
param profileName string

@description('Unique suffix for resource naming')
param suffix string

@description('Custom domain name for the endpoint')
param customDomainName string

@description('Subdomain prefix for resource naming')
param subDomain string

@description('Origin hostname (storage account static website endpoint)')
param originHostName string

// Reference to existing Front Door profile
resource profile 'Microsoft.Cdn/profiles@2023-05-01' existing = {
  name: profileName
}

// Create Front Door endpoint
resource endpoint 'Microsoft.Cdn/profiles/afdEndpoints@2023-05-01' = {
  parent: profile
  name: '${subDomain}-${suffix}'
  location: 'Global'
  properties: {
    enabledState: 'Enabled'
  }
}

// Create origin group
resource originGroup 'Microsoft.Cdn/profiles/originGroups@2023-05-01' = {
  parent: profile
  name: '${subDomain}-og-${suffix}'
  properties: {
    loadBalancingSettings: {
      sampleSize: 4
      successfulSamplesRequired: 3
    }
    healthProbeSettings: {
      probePath: '/'
      probeRequestType: 'HEAD'
      probeProtocol: 'Https'
      probeIntervalInSeconds: 100
    }
  }
}

// Create origin pointing to storage account
resource origin 'Microsoft.Cdn/profiles/originGroups/origins@2023-05-01' = {
  parent: originGroup
  name: '${subDomain}-origin-${suffix}'
  properties: {
    hostName: originHostName
    httpPort: 80
    httpsPort: 443
    originHostHeader: originHostName
    priority: 1
    weight: 1000
  }
}

// Create custom domain
resource customDomain 'Microsoft.Cdn/profiles/customDomains@2023-05-01' = {
  parent: profile
  name: replace(customDomainName, '.', '-')
  properties: {
    hostName: customDomainName
    tlsSettings: {
      certificateType: 'ManagedCertificate'
      minimumTlsVersion: 'TLS12'
    }
  }
}

// Create route
resource route 'Microsoft.Cdn/profiles/afdEndpoints/routes@2023-05-01' = {
  parent: endpoint
  name: '${subDomain}-route-${suffix}'
  dependsOn: [
    origin
  ]
  properties: {
    originGroup: {
      id: originGroup.id
    }
    customDomains: [
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
output customDomainValidationDnsTxtRecordName string = '_dnsauth.${subDomain}'
output customDomainValidationDnsTxtRecordValue string = customDomain.properties.validationProperties.validationToken
output customDomainValidationExpiry string = customDomain.properties.validationProperties.expirationDate
