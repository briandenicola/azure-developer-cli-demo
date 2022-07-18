param containerAppName string
param location string = resourceGroup().location
param environmentId string
param containerImage string
param resourceToken string 
param containerPort int
param isExternalIngress bool
param env array = []
param minReplicas int = 0

@allowed([
  'multiple'
  'single'
])
param revisionMode string = 'multiple'

var cpu = json('0.5')
var memory = '1Gi'

resource containerRegistry 'Microsoft.ContainerRegistry/registries@2022-02-01-preview' existing = {
  name: 'acr${resourceToken}'
}

resource containerApp 'Microsoft.App/containerApps@2022-01-01-preview' = {
  name: containerAppName
  location: location
  properties: {
    managedEnvironmentId: environmentId
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
        appId: containerAppName
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
          name: containerAppName
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

output fqdn string = containerApp.properties.configuration.ingress.fqdn
