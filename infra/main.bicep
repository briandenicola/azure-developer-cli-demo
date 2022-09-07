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

param  resourceToken string = toLower(uniqueString(subscription().id, name, location))

var appName = 'todo'
var defaultAppImage = 'docker.io/bjd145/simple:97a7dd4338986d13d409c43ebb2c9571f6d5b6ed'
var sqlPassword =  'strong-Password+${resourceToken}'

resource resourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: '${name}-rg'
  location: location
}

module registry 'registry.bicep' = {
  name: 'registry'
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
    environmentName: 'env-${resourceToken}'
    location: location
  }
}

module sql 'postgresql.bicep' = {
  name: 'azure-postgresql'
  scope: resourceGroup
  params: {
    sqlName: 'sql-${resourceToken}'
    location: location
    administratorLoginPassword: sqlPassword
  }
}

module api 'api.bicep' = {
  name: appName
  scope: resourceGroup
  params: {
    name: name
    location: location
    containerImage: appImage != '' ? appImage : defaultAppImage
    resourceToken: resourceToken
    sqlName: 'sql-${resourceToken}'
    sqlPassword: sqlPassword
  }
  dependsOn: [
    registry
    sql
  ]
}

output AZURE_CONTAINER_REGISTRY_ENDPOINT string = registry.outputs.AZURE_CONTAINER_REGISTRY_ENDPOINT
output AZURE_CONTAINER_REGISTRY_NAME string = registry.outputs.AZURE_CONTAINER_REGISTRY_NAME
output APP_API_BASE_URL string = api.outputs.API_URI
