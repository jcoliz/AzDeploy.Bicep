//
// Deploys a simple containerized web app with dedicated workspace
//
// Visit the deployed website using https://{fqdn}/, where {fqdn} is the
// output of this deployment.
//

@description('Unique suffix for all resources in this deployment')
@minLength(5)
param suffix string = uniqueString(resourceGroup().id)

@description('Location for all resources.')
param location string = resourceGroup().location

@description('Optional container image name for web app')
param webImageName string = 'nginxdemos/hello:latest'

@description('Optional ingress port for web app')
param ingressPort int = 80

// Deploy Log Anaytics Workspace

module logs '../OperationalInsights/loganalytics.bicep' = {
  name: 'logs'
  params: {
    suffix: suffix
    location: location
  }
}

// Deploy Container App Environment

module cenv './managedEnvironments.bicep' = {
  name: 'cenv'
  params: {
    suffix: suffix
    location: location
    logAnalyticsName: logs.outputs.name
  }
}

// Deploy Web Container App

module cweb './containerApp.bicep' = {
  name: 'c-web'
  params: {
    prefix: 'c-web'
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
      }
    ]
  }
}

output fqdn string = cweb.outputs.fqdn
