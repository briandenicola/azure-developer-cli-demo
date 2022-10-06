param environmentName string 
param location string = resourceGroup().location
param containerImage string
param containerPort int = 8080
param isExternalIngress bool = true 
param env array = []
param minReplicas int = 1
param resourceToken string = toLower(uniqueString(subscription().id, environmentName, location))

@allowed([
  'multiple'
  'single'
])
param revisionMode string = 'multiple'

var cpu = json('0.5')
var memory = '1Gi'
var appName = '${environmentName}ui'

resource containerRegistry 'Microsoft.ContainerRegistry/registries@2022-02-01-preview' existing = {
  name: 'acr${resourceToken}'
}

resource cae 'Microsoft.App/managedEnvironments@2022-03-01' existing = {
  name: 'env-${resourceToken}'
}

resource ui 'Microsoft.App/containerApps@2022-03-01' = {
  name: appName
  location: location
  tags: {
    'azd-env-name': environmentName
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
        enabled: false
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


output UI_URI string = 'https://${ui.properties.configuration.ingress.fqdn}'
