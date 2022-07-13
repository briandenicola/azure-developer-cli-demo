param containerAppName string
param location string = resourceGroup().location
param environmentId string
param containerImage string
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

resource containerApp 'Microsoft.App/containerApps@2022-01-01-preview' = {
  name: containerAppName
  location: location
  properties: {
    managedEnvironmentId: environmentId
    configuration: {
      activeRevisionsMode: revisionMode
      registries: []
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
