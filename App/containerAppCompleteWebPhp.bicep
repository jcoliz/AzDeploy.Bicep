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
param webImageName string = 'jcoliz/lemp-quickstart-web:0.0.1'

@description('Optional container image name for php component')
param phpImageName string = 'jcoliz/lemp-quickstart-php:0.0.1'

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

// Deploy PHP Container App

module cphp './containerApp.bicep' = {
  name: 'c-php'
  params: {
    prefix: 'c-php'
    suffix: suffix
    location: location
    containerAppEnvName: cenv.outputs.name
    ingressPort: 9000
    external: false
    containers: [
      {        
        name: 'php'
        image: phpImageName
        resources: {
          cpu: json('0.25')
          memory: '.5Gi'
        }
      }
    ]
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
    containers: [
      {        
        name: 'web'
        image: webImageName
        resources: {
          cpu: json('0.25')
          memory: '.5Gi'
        }
        env: [
          {
            name: 'PHP_HOST'
            value: cphp.outputs.name
          }
        ]
      }
    ]
  }
}

output fqdn string = cweb.outputs.fqdn
