param environmentName string 
param location string = resourceGroup().location
param containerImage string
param containerPort int = 5501
param isExternalIngress bool = true 
param env array = []
param minReplicas int = 0
param resourceToken string = toLower(uniqueString(subscription().id, environmentName, location))
param managedIdentityName string 


@allowed([
  'multiple'
  'single'
])
param revisionMode string = 'multiple'

var cpu = json('0.5')
var memory = '1Gi'
var appName = '${environmentName}api'


resource containerRegistry 'Microsoft.ContainerRegistry/registries@2022-02-01-preview' existing = {
  name: 'acr${resourceToken}'
}

resource cae 'Microsoft.App/managedEnvironments@2022-01-01-preview' existing = {
  name: 'env-${resourceToken}'
}

resource managedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2022-01-31-preview' existing = {
  name: managedIdentityName
}

resource api 'Microsoft.App/containerApps@2022-06-01-preview' = {
  name: appName
  location: location
  tags: {
    'azd-env-name': environmentName
  }
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${managedIdentity.id}' : {}
    }    
  }
  properties: {
    managedEnvironmentId: cae.id
    configuration: {
      activeRevisionsMode: revisionMode
      ingress: {
        external: isExternalIngress
        targetPort: containerPort
        transport: 'auto'
      }
      dapr: {
        enabled: true
        appPort: containerPort
        appProtocol: 'grpc'
        appId: appName
      }
      secrets: [
        {
          name: 'registry-password'
          value: containerRegistry.listCredentials().passwords[0].value
        }
      ]
      registries: [
        {
          server: '${containerRegistry.name}.azurecr.io'
          username: containerRegistry.name
          passwordSecretRef: 'registry-password'
        }
      ]
    }
    template: {
      containers: [
        {
          image: containerImage
          name: appName
          env: env
          resources: {
             cpu: cpu
             memory: memory
          }
        }
      ]
      scale: {
        minReplicas: minReplicas
        maxReplicas: 10
      }
    }
  }
}

output API_URI string = 'https://${api.properties.configuration.ingress.fqdn}'
