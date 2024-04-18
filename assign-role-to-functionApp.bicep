
// see https://github.com/siegfried01/ms-identity-blazor-server/blob/main/WebApp-your-API/B2C/Client/cosmosRole.bicep
// https://github.com/siegfried01/ms-identity-blazor-server/blob/main/WebApp-your-API/B2C/Client/deploy.bicep    



param sbdemo001NS_name string = 'sbdemo001NS'
param functionAppName string = 'SimpleServiceBusReceiverAzureFuncs'
// Get the principalId of the Azure Function's managed identity
resource functionApp 'Microsoft.Web/sites@2021-01-15' existing = {
  name: functionAppName
}
param principalId string

resource roleAssignment 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid(principalId, 'Azure Service Bus Data Receiver', sbdemo001NS_name)
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '2b629674-e913-4c01-ae53-c6806df3ebe0')
    principalId: functionApp.identity.principalId
    scope: sbdemo001NS_name
  }
}
