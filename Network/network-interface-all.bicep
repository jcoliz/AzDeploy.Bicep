//
// Creates a network interface (NIC) for a virtual network 
// for use by a virtual machine
// and all pre-requisites
// https://learn.microsoft.com/en-us/azure/virtual-network/virtual-network-network-interface
//

@description('Unique suffix for all resources in this deployment')
param suffix string = uniqueString(resourceGroup().id)

@description('Location for all resources.')
param location string = resourceGroup().location

module sg '../Network/security-group.bicep' = {
  name: 'sg'
  params: {
    suffix: suffix
    location: location
    rules: [
      {
        name: 'RDP'
        properties: {
          priority: 300
          protocol: 'TCP'
          access: 'Allow'
          direction: 'Inbound'
          sourceAddressPrefix: '*'
          sourcePortRange: '*'
          destinationAddressPrefix: '*'
          destinationPortRange: '3389'
        }
      }
    ]
  }
}

module vnet '../Network/virtual-network.bicep' = {
  name: 'vnet'
  params: {
    suffix: suffix
    location: location
    subnets: [
      {
        name: 'default'
        properties: {
          addressPrefix: '10.0.0.0/24'
        }
      }
    ]
    addressPrefixes: [
      '10.0.0.0/16'
    ]
  }
}

module ip '../Network/public-ip.bicep' = {
  name: 'ip'
  params: {
    suffix: suffix
    location: location
  }
}

module nic '../Network/network-interface.bicep' = {
  name: 'nic'
  params: {
    suffix: suffix
    location: location
    networkSecurityGroupName: sg.outputs.name
    publicIpAddressName: ip.outputs.name
    virtualNetworkName: vnet.outputs.name
  }
}

output name string = nic.outputs.name
