//
// Merges additional app settings onto an existing Web App
// without removing settings already configured by other modules.
//
// Uses list() to read current settings at deployment time,
// then union() to merge new settings on top.
//

@description('Name of the existing web app resource')
param webAppName string

@description('Additional application settings to merge (array of {name, value} objects)')
param appSettings array

resource webapp 'Microsoft.Web/sites@2023-01-01' existing = {
  name: webAppName
}

// Read current app settings at deployment time
var existingSettings = list('${webapp.id}/config/appsettings', '2023-01-01').properties

// Convert input array [{name, value}] to object { name: value }
var newSettings = reduce(appSettings, {}, (cur, next) => union(cur, { '${next.name}': next.value }))

// Merge: new settings override existing ones with the same key
var mergedSettings = union(existingSettings, newSettings)

resource config 'Microsoft.Web/sites/config@2023-01-01' = {
  parent: webapp
  name: 'appsettings'
  properties: mergedSettings
}
