//
// Deploys a Container App Environment and a Web Container App
// This module accepts an existing Log Analytics workspace name
//

@description('Unique suffix for all resources in this deployment')
param suffix string = uniqueString(resourceGroup().id)

@description('Location for all resources.')
param location string = resourceGroup().location

@description('Name of existing log analytics resource')
param logAnalyticsName string

@description('Optional container image name for web app')
param webImageName string = 'nginxdemos/hello:latest'

@description('Optional ingress port for web app')
param ingressPort int?

@description('Array of environment variables for the container')
@metadata({
  example: [
    {
      name: 'ENVIRONMENT_VAR_NAME'
      value: 'value'
    }
    {
      name: 'SECRET_VAR_NAME'
      secretRef: 'secret-name'
    }
  ]
  definition: 'https://learn.microsoft.com/en-us/azure/templates/microsoft.app/containerapps?pivots=deployment-language-bicep#environmentvar'
})
param env array = []

@description('Prefix for web container app')
param webPrefix string = 'c-web'

// Deploy Container App Environment

module cenv './managedEnvironments.bicep' = {
  name: 'cenv'
  params: {
    suffix: suffix
    location: location
    logAnalyticsName: logAnalyticsName
  }
}

// Deploy Web Container App

module cweb './containerApp.bicep' = {
  name: 'c-web'
  params: {
    prefix: webPrefix
    suffix: suffix
    location: location
    containerAppEnvName: cenv.outputs.name
    ingressPort: ingressPort
    containers: [
      {
        name: 'web'
        image: webImageName
        resources: {
          cpu: json('0.25')
          memory: '.5Gi'
        }
        env: env
      }
    ]
  }
}

output fqdn string = cweb.outputs.fqdn
output principal string = cweb.outputs.principal
output containerAppEnvName string = cenv.outputs.name
