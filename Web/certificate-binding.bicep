@description('Name of required host name binding resource')
param hostBindingName string

@description('Name of required certificate resource')
param certificateName string

resource certificate 'Microsoft.Web/certificates@2020-12-01' existing = {
  name: certificateName
}

resource hostBinding_updated 'Microsoft.Web/sites/hostNameBindings@2023-01-01' =  {
  name: hostBindingName
  properties: {
    sslState: 'SniEnabled'
    thumbprint: certificate.properties.thumbprint
    hostNameType: 'Verified'
  }
}
