//
// Creates a database on an existing Azure Database for PostgreSQL Flexible Server
// https://learn.microsoft.com/en-us/azure/postgresql/flexible-server/
//
// Can be called multiple times for different databases on the same server.
//

@minLength(3)
@description('Name of the existing PostgreSQL Flexible Server')
param serverName string

@minLength(2)
@description('Name of the database to create')
param databaseName string = 'db'

resource server 'Microsoft.DBforPostgreSQL/flexibleServers@2024-08-01' existing = {
  name: serverName
}

resource database 'Microsoft.DBforPostgreSQL/flexibleServers/databases@2024-08-01' = {
  parent: server
  name: databaseName
}

output databaseName string = database.name
