//
// Deploys a Network security group for a Virtual Network
// https://learn.microsoft.com/en-us/azure/virtual-network/network-security-groups-overview
//
@description('Descriptor for this resource')
param prefix string = 'sg'

@description('Unique suffix for all resources in this deployment')
param suffix string = uniqueString(resourceGroup().id)

@description('Location for all resources.')
param location string = resourceGroup().location

@description('Details of network security group rules')
param rules array

resource networkSecurityGroup 'Microsoft.Network/networkSecurityGroups@2019-02-01' = {
  name: '${prefix}-${suffix}'
  location: location
  properties: {
    securityRules: rules
  }
}

output name string = networkSecurityGroup.name
