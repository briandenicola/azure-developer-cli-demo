param vaultName string
param location string = resourceGroup().location
param managedIdentityName string
param sqlName string
@secure()
param sqlPassword string

var tenantId = subscription().tenantId
var keyVaultSecretsOfficerRoleId = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'b86a8fe4-44ce-4948-aee5-eccb2c155cd7')
var keyVaultSecretName = 'postgresql-connectionstring'

resource sql 'Microsoft.DBforPostgreSQL/flexibleServers@2021-06-01' existing = {
  name: sqlName
}

resource managedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2022-01-31-preview' existing = {
  name: managedIdentityName
}

resource kv 'Microsoft.KeyVault/vaults@2021-11-01-preview' = {
  name: vaultName
  location: location
  properties: {
    tenantId:  tenantId
    enableRbacAuthorization: true
    sku: {
      name: 'premium'
      family: 'A'
    }
  }
}

resource secret 'Microsoft.KeyVault/vaults/secrets@2021-11-01-preview' = {
  parent: kv
  name: keyVaultSecretName
  properties: {
    value: 'host=${sql.properties.fullyQualifiedDomainName} user=${sql.properties.administratorLogin} password=${sqlPassword} port=5432 dbname=todo sslmode=require' 
  }
}

resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(kv.id, keyVaultSecretsOfficerRoleId)
  scope: kv
  properties: {
    roleDefinitionId: keyVaultSecretsOfficerRoleId
    principalId: managedIdentity.properties.principalId
    principalType: 'ServicePrincipal'
  }
}
