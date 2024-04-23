
// see https://github.com/siegfried01/ms-identity-blazor-server/blob/main/WebApp-your-API/B2C/Client/cosmosRole.bicep
// https://github.com/siegfried01/ms-identity-blazor-server/blob/main/WebApp-your-API/B2C/Client/deploy.bicep    



param roleScope string = 'sbdemo001NS'
param functionAppName string = 'SimpleServiceBusReceiverAzureFuncs'
// Get the principalId of the Azure Function's managed identity
resource functionApp 'Microsoft.Web/sites@2021-01-15' existing = {
  name: functionAppName
}
param functionPrincipalId string

// see https://learn.microsoft.com/en-us/azure/role-based-access-control/built-in-roles#azure-service-bus-data-receiver
resource roleAssignment 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid(functionPrincipalId, 'Azure Service Bus Data Receiver', roleScope)
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '4f6d3b9b-027b-4f4c-9142-0e5a2a2247e0')
    principalId: functionApp.identity.principalId
    scope: roleScope
  }
  // see also: Azure Service Bus Data Sender	Allows for send access to Azure Service Bus resources.	69a216fc-b8fb-44d8-bc22-1f3c2cd27a39
}
