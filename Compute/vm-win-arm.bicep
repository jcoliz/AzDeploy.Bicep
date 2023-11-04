//
// Deploys an Arm64 virtual machine running Windows 11 Professional
//

@description('Unique suffix for all resources in this deployment')
param suffix string = uniqueString(resourceGroup().id)

@description('Location for all resources.')
param location string = resourceGroup().location

param adminUsername string
@secure()
param adminPassword string

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

module ifc '../Network/network-interface.bicep' = {
  name: 'ifc'
  params: {
    suffix: suffix
    location: location
    networkSecurityGroupName: sg.outputs.name
    publicIpAddressName: ip.outputs.name
    virtualNetworkName: vnet.outputs.name
  }
}

module vm 'vm.bicep' = {
  name: 'vm'
  params: {
    suffix: suffix
    location: location
    adminPassword: adminPassword
    adminUsername: adminUsername
    networkInterfaceName: ifc.outputs.name
    osDiskType: 'StandardSSD_LRS'
    virtualMachineSize: 'Standard_D2ps_v5'
  }    
}
