@description('Name of required log analytics resource')
param logAnalyticsName string

resource logs 'Microsoft.OperationalInsights/workspaces@2022-10-01' existing = {
  name: logAnalyticsName
}

resource sentinel 'Microsoft.SecurityInsights/onboardingStates@2024-10-01-preview' = {
  scope: logs
  name: 'default'
}

output sentinelId string = sentinel.id
