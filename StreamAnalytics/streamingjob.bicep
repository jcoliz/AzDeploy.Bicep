@description('Descriptor for this resource')
param prefix string = 'stream'

@description('Unique suffix for all resources in this deployment')
param suffix string = uniqueString(resourceGroup().id)

@description('Location for all resources.')
param location string = resourceGroup().location

@description('Hosting plan SKU.')
param sku string = 'StandardV2'

@description('Inputs for the streaming job')
param inputs array

@description('Outputs for the streaming job')
param outputs array

@description('Query for the streaming job transformation')
param query string

@description('The name of the user assigned managed identity to use for the streaming job. If left empty, the streaming job will use a system assigned identity.')
param identityName string = ''

resource identity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' existing = if (identityName != '') {
  name: identityName
}

var streamingJobIdentity = identityName != '' ? {
  type: 'UserAssigned'
  userAssignedIdentities: {
    '${identity.id}': {}
  }
} : {
  type: 'SystemAssigned'
}

resource streamingJob 'Microsoft.StreamAnalytics/StreamingJobs@2021-10-01-preview' = {
  name: '${prefix}-${suffix}'
  location: location
  identity: streamingJobIdentity
  properties: {
    sku: {
      name: sku
    }
    outputStartMode: 'JobStartTime'
    eventsOutOfOrderPolicy: 'Adjust'
    outputErrorPolicy: 'Drop'
    eventsOutOfOrderMaxDelayInSeconds: 0
    eventsLateArrivalMaxDelayInSeconds: 5
    dataLocale: 'en-US'
    compatibilityLevel: '1.2'
    contentStoragePolicy: 'SystemAccount'
    transformation: {
      name: 'Transformation'
      properties: {
        streamingUnits: 10
        query: query
      }
    }
    inputs: inputs    
    outputs: outputs
    jobType: 'Cloud'
  }
}
