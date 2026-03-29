//
// Deploys a PostgreSQL connection string on an existing Web App
//
// For use with Entra-only authentication (no password in the connection string).
// The application acquires Entra tokens at runtime via ManagedIdentityCredential.
//

@description('Name of the existing Web App resource')
param webAppName string

@description('Fully qualified domain name of the PostgreSQL Flexible Server')
param serverFqdn string

@description('Name of the database')
param databaseName string

var connectionString = 'Host=${serverFqdn};Database=${databaseName};Port=5432;Username=${webAppName};Ssl Mode=Require;Trust Server Certificate=true'

resource webapp 'Microsoft.Web/sites@2023-01-01' existing = {
  name: webAppName
}

resource config 'Microsoft.Web/sites/config@2023-01-01' = {
  parent: webapp
  name: 'connectionstrings'
  properties: {
    DefaultConnection: {
      value: connectionString
      type: 'PostgreSQL'
    }
  }
}
