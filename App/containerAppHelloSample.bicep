//
// Deploys a simple sample container app with dedicated workspace
//
// Visit the deployed website using https://{fqdn}/, where {fqdn} is the
// output of this deployment.
//

@description('Unique suffix for all resources in this deployment')
@minLength(5)
param suffix string = uniqueString(resourceGroup().id)

@description('Location for all resources.')
param location string = resourceGroup().location

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
  name: 'web'
  params: {
    prefix: 'web'
    suffix: suffix
    location: location
    containerAppEnvName: cenv.outputs.name
    containers: [
      {        
        name: 'web'
        image: 'nginxdemos/hello:latest'
        resources: {
          cpu: json('0.25')
          memory: '.5Gi'
        }
      }
    ]
  }
}

output fqdn string = cweb.outputs.fqdn
