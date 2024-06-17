
// see https://github.com/siegfried01/ms-identity-blazor-server/blob/main/WebApp-your-API/B2C/Client/cosmosRole.bicep
// https://github.com/siegfried01/ms-identity-blazor-server/blob/main/WebApp-your-API/B2C/Client/deploy.bicep    

// The "Storage Blob Data Owner" role covers the basic needs of Functions host storage - the runtime needs both read and write access to blobs and the ability to create containers.

param roleScope string = 'sbdemo001NS'
param functionAppName string = 'SimpleServiceBusReceiverAzureFuncs'
// Get the principalId of the Azure Function's managed identity
resource functionApp 'Microsoft.Web/sites@2021-01-15' existing = {
  name: functionAppName
}
param functionPrincipalId string


resource roleAssignment 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid(functionPrincipalId, 'Storage Blob Data Owner', roleScope)
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'b7e6dc6d-f1e8-4753-8033-0f276bb0955b')
    principalId: functionApp.identity.principalId
    scope: roleScope
  }
}
