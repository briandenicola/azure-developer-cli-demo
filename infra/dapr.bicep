param environmentName string 
param location string = resourceGroup().location
param vaultName string
param managedIdentityName string 
param resourceToken string = toLower(uniqueString(subscription().id, environmentName, location))

var tenantId = subscription().tenantId
var keyVaultSecretName = 'postgresql-connectionstring'
var appName = '${environmentName}api'

resource cae 'Microsoft.App/managedEnvironments@2022-01-01-preview' existing = {
  name: 'env-${resourceToken}'
}

resource managedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2022-01-31-preview' existing = {
  name: managedIdentityName
}

resource dapSecretStore 'Microsoft.App/managedEnvironments/daprComponents@2022-06-01-preview' = {
  parent: cae
  name: 'secretstore'
  properties: {
    componentType: 'secretstores.azure.keyvault'
    version: 'v1'
    metadata: [
      {
        name: 'vaultName'
        value: vaultName
      }
      {
        name: 'azureClientId'
        value: managedIdentity.id
      }
      {
        name: 'azureTenantId'
        value: tenantId 
      }
    ]
    scopes: [
      appName
    ]
  }
}

resource daprStateStore 'Microsoft.App/managedEnvironments/daprComponents@2022-06-01-preview' = {
  parent: cae
  name: 'statestore'
  properties: {
    componentType: 'state.postgresql'
    version: 'v1'
    metadata: [
      {
        name: 'connectionString'
        secretRef: keyVaultSecretName
      }
      {
        name: 'actorStateStore'
        value: 'false'
      }
    ]
    secretStoreComponent: 'secretstore'
    scopes: [
      appName
    ]
  }
}
