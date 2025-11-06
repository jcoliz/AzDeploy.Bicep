//
// Enable Diagnostic Settings for Sentinel Workspace
//
// https://learn.microsoft.com/en-us/answers/questions/1406157/how-do-you-deploy-diagnostic-settings-to-sentinel
//

@description('Name of required log analytics resource')
param logAnalyticsName string

resource logs 'Microsoft.OperationalInsights/workspaces@2022-10-01' existing = {
  name: logAnalyticsName
}

resource sentinelSettings 'Microsoft.SecurityInsights/settings@2023-09-01-preview' existing = {
  scope: logs
  name: 'SentinelHealth'
}

resource sentinelDiagnostics 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  scope: sentinelSettings
  name: 'SentinelAllLogs'
  properties: {
    workspaceId: logs.id
    logs: [
      {
        categoryGroup: 'allLogs'
        enabled: true
      }
    ]
  }
}
