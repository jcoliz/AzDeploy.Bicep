//
// Deploys an Azure Event Hub namespace
//    with associated Event Hub
//    with associated sending key
// https://learn.microsoft.com/en-us/azure/event-hubs/
//

@description('Descriptor for the parent namespace resource')
@minLength(3)
param prefix string = 'ehubns'

@description('Descriptor for the hub resource')
param hubname string = 'ehub'

@description('Name of sending key')
param sendkeyname string = 'SendKey'

@description('Name of listening key')
param listenkeyname string = 'ListenKey'

@description('Unique suffix for all resources in this deployment')
@minLength(3)
param suffix string = uniqueString(resourceGroup().id)

@description('Location for all resources.')
param location string = resourceGroup().location

@description('SKU name.')
param sku string = 'Basic'

@description('Number of provisioned units.')
param capacity int = 1

resource namespace 'Microsoft.EventHub/namespaces@2022-10-01-preview' = {
  name: '${prefix}-${suffix}'
  location: location
  sku: {
    name: sku
    tier: sku
    capacity: capacity
  }
  properties: {
    minimumTlsVersion: '1.2'
    publicNetworkAccess: 'Enabled'
    disableLocalAuth: false
    zoneRedundant: true
    isAutoInflateEnabled: false
    maximumThroughputUnits: 0
    kafkaEnabled: false
  }
}

resource sendkey 'Microsoft.EventHub/namespaces/authorizationrules@2022-10-01-preview' = {
  parent: namespace
  name: sendkeyname
  properties: {
    rights: [
      'Send'
    ]
  }
}

resource listenkey 'Microsoft.EventHub/namespaces/authorizationrules@2022-10-01-preview' = {
  parent: namespace
  name: sendkeyname
  properties: {
    rights: [
      'Listen'
    ]
  }
}

resource ehub 'Microsoft.EventHub/namespaces/eventhubs@2022-10-01-preview' = {
  parent: namespace
  name: hubname
  properties: {
    retentionDescription: {
      cleanupPolicy: 'Delete'
      retentionTimeInHours: 1
    }
    messageRetentionInDays: 1
    partitionCount: 2
    status: 'Active'
  }
}

output result object = {
  namespace: namespace.name
  key: sendkey.name
  hub: ehub.name
}

output namespace string = namespace.name
output id string = namespace.id
output sendkey string = sendkey.name
output hub string = ehub.name
output listenkey string = listenkeyname
