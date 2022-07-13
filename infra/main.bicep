param location string = resourceGroup().location
param environmentName string = 'env-${uniqueString(resourceGroup().id)}'

var appName = 'simple-app'
var appImage = 'docker.io/bjd145/simple:97a7dd4338986d13d409c43ebb2c9571f6d5b6ed'
var appPort = 5500

module environment 'environment.bicep' = {
  name: 'container-app-environment'
  params: {
    environmentName: environmentName
    location: location
  }
}

module appService 'container-app.bicep' = {
  name: appName
  params: {
    location: location
    containerAppName: appName
    environmentId: environment.outputs.environmentId
    containerImage: appImage
    containerPort: appPort
    isExternalIngress: true
    minReplicas: 0
  }
}

output fqdn string = appService.outputs.fqdn
