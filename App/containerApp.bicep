//
// Deploys a single Azure Container App
//

/*
  Most container apps have a single container. In advanced scenarios, an app 
  may also have sidecar and init containers. In a container app definition,
  the main app and its sidecar containers are listed in the containers array 
  in the properties.template section, and init containers are listed in the 
  initContainers array. The following excerpt shows the available 
  configuration options when setting up an app's containers.
*/

@description('Descriptor for this resource')
param prefix string = 'capp'

@description('Unique suffix for all resources in this deployment')
param suffix string = uniqueString(resourceGroup().id)

@description('Location for all resources.')
param location string = resourceGroup().location

@description('Array of container details ')
@metadata({
  definition: 'https://learn.microsoft.com/en-us/azure/templates/microsoft.app/containerapps?pivots=deployment-language-bicep#container-1'
})
param containers array

@description('Specifies the port exposed for external ingress into the application')
param ingressPort int = 80

@description('Minimum number of replicas that will be deployed')
@minValue(0)
@maxValue(25)
param minReplicas int = 1

@description('Maximum number of replicas that will be deployed')
@minValue(0)
@maxValue(25)
param maxReplicas int = 3

@description('Name of required environment resource')
param containerAppEnvName string

param revisionSuffix string = 'r-${uniqueString('${prefix}-${suffix}', utcNow())}'

param external bool = true

var containerAppName = '${prefix}-${suffix}'

resource containerAppEnv 'Microsoft.App/managedEnvironments@2024-03-01' existing = {
  name: containerAppEnvName
}

resource containerApp 'Microsoft.App/containerApps@2022-06-01-preview' = {
  name: containerAppName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    managedEnvironmentId: containerAppEnv.id
    configuration: {
      ingress: external ? {
        external: true
        targetPort: ingressPort
        allowInsecure: false
        traffic: [
          {
            latestRevision: true
            weight: 100
          }
        ]
      } : {
        external: false
        targetPort: ingressPort
        transport: 'tcp'
        traffic: [
          {
            latestRevision: true
            weight: 100
          }
        ]
      }
    }
    template: {
      revisionSuffix: revisionSuffix
      containers: containers
      scale: {
        minReplicas: minReplicas
        maxReplicas: maxReplicas
      }
    }
  }
}

output name string = containerApp.name
output fqdn string = containerApp.properties.configuration.ingress.fqdn
output principal string = containerApp.identity.principalId
