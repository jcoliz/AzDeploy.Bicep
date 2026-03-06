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

@description('Array of environment vars')
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

// Deploy Log Analytics Workspace

module applogs '../OperationalInsights/loganalytics.bicep' = {
  name: 'applogs'
  params: {
    prefix: 'applogs'
    suffix: suffix
    location: location
  }
}

// Deploy Container App Environment and Web Container App

module containerAppWithEnv './containerAppWithEnvironment.bicep' = {
  name: 'containerAppWithEnv'
  params: {
    suffix: suffix
    location: location
    logAnalyticsName: applogs.outputs.name
    webImageName: webImageName
    ingressPort: ingressPort
    env: env
  }
}

output fqdn string = containerAppWithEnv.outputs.fqdn
output principal string = containerAppWithEnv.outputs.principal
