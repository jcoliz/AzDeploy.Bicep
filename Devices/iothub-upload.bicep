//
// Deploys an Azure IoT Hub
//    with provision for file upload
//

@description('Descriptor for this resource')
param prefix string = 'iothub'

@description('Unique suffix for all resources in this deployment')
param suffix string = uniqueString(resourceGroup().id)

@description('Location for all resources.')
param location string = resourceGroup().location

@description('SKU name.')
param sku string = 'S1'

@description('Number of provisioned units. Restricted to 1 unit for the F1 SKU. Can be set up to maximum number allowed for subscription.')
param capacity int = 1

@description('Details for required storage resource (name/id)')
param storage object

@description('Name of container for file uploads')
param uploadcontainername string = 'uploads'

var storcstr = 'DefaultEndpointsProtocol=https;AccountName=${storage.name};EndpointSuffix=${environment().suffixes.storage};AccountKey=${listKeys(storage.id, '2022-09-01').keys[0].value}'
var uploadstorage = {
  '$default': {
    connectionString: storcstr
    containerName: uploadcontainername
  }
}  

module iotHub 'iothub.bicep' = {
  name: 'iotupload'
  params: {
    prefix: prefix
    suffix: suffix
    location: location
    sku: sku
    capacity: capacity
    uploadstorage: uploadstorage
  }
}

output result object = iotHub.outputs.result
