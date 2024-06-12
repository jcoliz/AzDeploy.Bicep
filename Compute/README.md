# How to deploy a Windows Arm virtual machine using Azure Resource Manager

The Azure CLI is used to create and manage Azure resources from the command line or in scripts. This document shows you how to use the Azure CLI to deploy a virtual machine (VM) in Azure that runs Windows Pro 22H2 on Arm-based hardware. To see your VM in action, you then RDP to the VM .

## Prerequisites

1. Azure subscription: If you don't have an Azure subscription, create a [free account](https://azure.microsoft.com/free/?WT.mc_id=A261C142F) before you begin.
2. Azure CLI: Install the [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli) tools locally on your machine.

## Step 1: Obtain the files here

You'll need the files from this repository on your local computer in order to use them in your deployments.

If you have a git client installed, it's easy. From a terminal window:

```powershell
git clone https://github.com/jcoliz/AzDeploy.Bicep.git
cd AzDeploy.Bicep\Compute
```

Otherwise, you can download the files from GitHub.

1. Navigate to the [AzDeploy.Bicep](https://github.com/jcoliz/AzDeploy.Bicep) home page
1. Open the "<> Code" drop-down
1. Select "Download ZIP"
1. Unzip the files into a directory on your local machine
1. Open a terminal window
1. Change to the directory where you unzipped the files
1. Change into the `Compute` directory under that

## Step 2: Sign into Azure from CLI

Before continuing, you'll need to sign into Azure with the Azure CLI. It's pretty easy:

```powershell
az login
```

For more details, read up at [Sign in interactively with Azure CLI](https://learn.microsoft.com/en-us/cli/azure/authenticate-azure-cli-interactively)

## Step 3: Create a resource group

Create a dedicated resource group for the VM. I like to use environment variables to
avoid mis-typing the resource group later. Choose the location which best suits your needs.

```powershell
$env:RESOURCEGROUP = "arm-vm-bicep"
az group create --name $env:RESOURCEGROUP --location "West US 2"
```

## Step 4: Deploy the VM

Start a deployment from the command line:

```powershell
az deployment group create --name "Deploy-$(Get-Random)" --resource-group $env:RESOURCEGROUP --template-file .\vm-win-arm.bicep
```

When prompted, enter a username and password for the user you'll log in with:

```
Please provide string value for 'adminUsername' (? for help):
Please provide securestring value for 'adminPassword' (? for help):
```

Creating Arm VMs can be flaky. If the deployment takes more than 5 minutes, cancel the deployment,
delete the Resource Group, create another one with a new name, and try deploying
again.

## Step 5: Connect to the VM

When the deployment completes, look for the `outputs`section in the results.

```json
    "outputs": {
      "ipaddr": {
        "type": "String",
        "value": "10.1.2.3"
      },
      "vmname": {
        "type": "String",
        "value": "vm-redacted"
      }
    }
```

You can launch the Remote Desktop Client to interactively create a connection to the IP address
shown in the outputs.

Alternately, you can run the RDP client directly from the terminal:

```powershell
$env:IP = "10.1.2.3"
mstsc /v:$env:IP /prompt
```

## Step 6: Use a parameters file

The previous deployment step asks you to type in the admin password user each time you deploy a VM. You can automate this,
as well as change other default parameters in the deployment by using a parameters file.

``` powershell
{
    "$schema": "https://schema.management.azure.com/schemas/2015-01-01/deploymentParameters.json#",
    "contentVersion": "1.0.0.0",
    "parameters": {
        "adminUsername": {
            "value": ""
        },
        "adminPassword": {
            "value": ""
        },
        "virtualMachineSize": {
            "value": "Standard_D2ps_v5"
        },
        "sku": {
            "value": "win11-23h2-pro"
        }
    }
}
```

1. Copy the file `vm-win-arm.parameters.template.json` to `vm-win-arm.parameters.json`.
2. Edit the file with your desired admin username and password, and potentially other configuration changes you'd like to make. In this example, we're choosing the 23H2 Pro sku instead of the default 22H2.
3. Include the parameters file in your deployment:

```powershell
az deployment group create --name "Deploy-$(Get-Random)" --resource-group $env:RESOURCEGROUP --template-file .\vm-win-arm.bicep --parameters .\azuredeploy.parameters.json
```

## Step 7: Tear down the VM afterward

When you're all done, be sure to tear down the VM to avoid ongoing charges:

```powershell
az group delete --yes --name $env:RESOURCEGROUP
```
