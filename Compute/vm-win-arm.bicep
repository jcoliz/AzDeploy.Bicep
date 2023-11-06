//
// Deploys a Standard_D2ps_v5 (Arm64) virtual machine running Windows 11 Professional
// https://learn.microsoft.com/en-us/azure/virtual-machines/dpsv5-dpdsv5-series
//

@description('Unique suffix for all resources in this deployment')
param suffix string = uniqueString(resourceGroup().id)

@description('Location for all resources.')
param location string = resourceGroup().location

@description('Username of machine administrator')
param adminUsername string

@description('Password of machine administrator')
@secure()
param adminPassword string

module nicall '../Network/network-interface-all.bicep' = {
  name: 'nicall'
  params: {
    suffix: suffix
    location: location
  }    
}

module vm 'vm.bicep' = {
  name: 'vm'
  params: {
    suffix: suffix
    location: location
    adminPassword: adminPassword
    adminUsername: adminUsername
    networkInterfaceName: nicall.outputs.name
    osDiskType: 'StandardSSD_LRS'
    virtualMachineSize: 'Standard_D2ps_v5'
    imageReference: {
      publisher: 'microsoftwindowsdesktop'
      offer: 'windows11preview-arm64'
      sku: 'win11-21h2-pro'
      version: 'latest'
    }
  }    
}

output ipaddr string = nicall.outputs.ipaddr
