//
// Deploys a single custom table into a log analytics workspace
//

@description('Name of required log analytics resource')
param logAnalyticsName string

@description('Schema of table in log workspace')
param tableSchema object

resource logs 'Microsoft.OperationalInsights/workspaces@2020-08-01' existing = {
  name: logAnalyticsName
}

resource table 'Microsoft.OperationalInsights/workspaces/tables@2022-10-01' = {
  parent: logs
  name: tableSchema.name
  properties: {
    totalRetentionInDays: 30
    retentionInDays: 30
    plan: 'Analytics'
    schema: tableSchema
  }
}
