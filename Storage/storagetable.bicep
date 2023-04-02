//
// Deploys a single Table into a Storage Account
//

@description('Name of table')
param name string

@description('Name of storage account')
param account string

resource storageAccountName_default_storageTable 'Microsoft.Storage/storageAccounts/tableServices/tables@2022-09-01' = {
  name: '${account}/default/${name}'
}
