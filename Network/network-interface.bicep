//
// Creates a network interface (NIC) for a virtual network
// https://learn.microsoft.com/en-us/azure/virtual-network/virtual-network-network-interface
//

@description('Descriptor for this resource')
param prefix string = 'nic'

@description('Unique suffix for all resources in this deployment')
param suffix string = uniqueString(resourceGroup().id)

@description('Location for all resources.')
param location string = resourceGroup().location

param enableAcceleratedNetworking bool = true
param pipDeleteOption string = 'Detach'

@description('Name of required network SG resource')
param networkSecurityGroupName string
resource sg 'Microsoft.Network/networkSecurityGroups@2023-05-01' existing = {
  name: networkSecurityGroupName
}

param virtualNetworkName string
resource vnet 'Microsoft.Network/virtualNetworks@2023-05-01' existing = {
  name: virtualNetworkName
}

param subNetName string = 'default'
resource subnet 'Microsoft.Network/virtualNetworks/subnets@2023-05-01' existing = {
  parent: vnet
  name: subNetName
}

param publicIpAddressName string
resource iprange 'Microsoft.Network/publicIPAddresses@2023-05-01' existing = {
  name: publicIpAddressName
}

resource networkInterface 'Microsoft.Network/networkInterfaces@2022-11-01' = {
  name: '${prefix}-${suffix}'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          subnet: {
            id: subnet.id
          }
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: iprange.id
            properties: {
              deleteOption: pipDeleteOption
            }
          }
        }
      }
    ]
    enableAcceleratedNetworking: enableAcceleratedNetworking
    networkSecurityGroup: {
      id: sg.id
    }
  }
}

output name string = networkInterface.name
