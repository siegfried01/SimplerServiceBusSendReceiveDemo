param namespace_name string = 'mypremiumnamespace'

resource namespace_name_resource 'Microsoft.ServiceBus/namespaces@2022-10-01-preview' = {
  name: namespace_name
  location: 'East US'
  sku: {
    name: 'Premium'
    tier: 'Premium'
    capacity: 1
  }
  properties: {
    premiumMessagingPartitions: 1
    minimumTlsVersion: '1.2'
    publicNetworkAccess: 'Enabled'
    disableLocalAuth: false
    zoneRedundant: true
  }
}

resource namespace_name_default 'Microsoft.ServiceBus/namespaces/networkRuleSets@2022-10-01-preview' = {
  parent: namespace_name_resource
  name: 'default'
  location: 'East US'
  properties: {
    publicNetworkAccess: 'Enabled'
    defaultAction: 'Deny'
    virtualNetworkRules: []
    ipRules: [
      {
        ipMask: '10.1.1.1'
        action: 'Allow'
      }
      {
        ipMask: '11.0.0.0/24'
        action: 'Allow'
      }
    ]
  }
}
