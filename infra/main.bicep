targetScope = 'subscription'

@minLength(1)
@maxLength(64)
@description('Name of the the environment which is used to generate a short unqiue hash used in all resources.')
param name string

@minLength(1)
@description('Primary location for all resources')
param location string

@description('The image name for the web service')
param appImage string = ''

param resourceToken string = '{uniqueString(deployment().name)}'

var appName = 'simple-app'
var defaultAppImage = 'docker.io/bjd145/simple:97a7dd4338986d13d409c43ebb2c9571f6d5b6ed'
var appPort = 5500

resource resourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: '${name}-rg'
  location: location
}

module resources 'resources.bicep' = {
  name: 'resources'
  scope: resourceGroup
  params: {
    resourceToken: resourceToken
    location: location
  }
}

module environment 'environment.bicep' = {
  name: 'container-app-environment'
  scope: resourceGroup
  params: {
    environmentName: 'env-${uniqueString(deployment().name)}'
    location: location
  }
}

module appService 'container-app.bicep' = {
  name: appName
  scope: resourceGroup
  params: {
    location: location
    containerAppName: appName
    resourceToken: resourceToken
    environmentId: environment.outputs.environmentId
    containerImage: appImage != '' ? appImage : defaultAppImage
    containerPort: appPort
    isExternalIngress: true
    minReplicas: 0
  }
}

output fqdn string = appService.outputs.fqdn
