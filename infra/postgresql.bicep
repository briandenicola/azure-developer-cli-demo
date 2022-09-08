param location string = resourceGroup().location
param sqlName string
param administratorLogin string = 'manager'
@secure()
param administratorLoginPassword string

var skuSizeGB = 32
var skuVersion = '13'

resource postgresql 'Microsoft.DBforPostgreSQL/flexibleServers@2022-01-20-preview' = {
  name: sqlName
  location: location
  sku: {
    name: 'Standard_D2ds_v4'
    tier: 'GeneralPurpose'
  }
  properties: {
    version: skuVersion
    administratorLogin: administratorLogin
    administratorLoginPassword: administratorLoginPassword
    highAvailability: {
      mode: 'Disabled'
    }
    storage: {
      storageSizeGB: skuSizeGB
    }
  }

  resource database 'databases@2022-01-20-preview' = {
    name: 'todo'
  }

  resource all 'firewallRules@2022-01-20-preview' = {
    name: 'all'
    properties: {
      startIpAddress: '0.0.0.0'
      endIpAddress: '255.255.255.255'
    }
  }
}


