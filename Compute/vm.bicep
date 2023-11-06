
//
// Deploys a Virtual Machine
// https://learn.microsoft.com/en-us/azure/virtual-machines/
//

@description('Descriptor for this resource')
param prefix string = 'vm'

@description('Unique suffix for all resources in this deployment')
param suffix string = uniqueString(resourceGroup().id)

@description('Location for all resources.')
param location string = resourceGroup().location

param imageReference object
param virtualMachineSize string
param osDiskType string
param adminUsername string
@secure()
param adminPassword string

param patchMode string = 'AutomaticByOS'
param enableHotpatching bool = false
param nicDeleteOption string = 'Delete'
param osDiskDeleteOption string = 'Delete'

@description('Name of required network interface resource')
param networkInterfaceName string
resource netIfc 'Microsoft.Network/networkInterfaces@2023-05-01' existing = {
  name: networkInterfaceName
}

resource virtualMachine 'Microsoft.Compute/virtualMachines@2022-11-01' = {
  name: '${prefix}-${suffix}'
  location: location
  properties: {
    hardwareProfile: {
      vmSize: virtualMachineSize
    }
    storageProfile: {
      osDisk: {
        createOption: 'fromImage'
        managedDisk: {
          storageAccountType: osDiskType
        }
        deleteOption: osDiskDeleteOption
      }
      imageReference: imageReference
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: netIfc.id
          properties: {
            deleteOption: nicDeleteOption
          }
        }
      ]
    }
    additionalCapabilities: {
      hibernationEnabled: false
    }
    osProfile: {
      computerName: '${suffix}-1'
      adminUsername: adminUsername
      adminPassword: adminPassword
      windowsConfiguration: {
        enableAutomaticUpdates: true
        provisionVMAgent: true
        patchSettings: {
          enableHotpatching: enableHotpatching
          patchMode: patchMode
        }
      }
    }
    licenseType: 'Windows_Client'
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: true
      }
    }
  }
}

output name string = virtualMachine.name
