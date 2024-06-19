
// see https://github.com/siegfried01/ms-identity-blazor-server/blob/main/WebApp-your-API/B2C/Client/cosmosRole.bicep
// https://github.com/siegfried01/ms-identity-blazor-server/blob/main/WebApp-your-API/B2C/Client/deploy.bicep    

// The "Key Vault Reader" role covers the basic needs of Functions host storage 

param roleScope string = 'sbdemo001NS'
param functionAppName string = 'SimpleServiceBusReceiverAzureFuncs'
// Get the principalId of the Azure Function's managed identity
resource functionApp 'Microsoft.Web/sites@2021-01-15' existing = {
  name: functionAppName
}
param functionPrincipalId string


resource roleAssignment 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
   // name: guid(functionPrincipalId, 'Key Vault Reader', roleScope)
  name: guid(functionPrincipalId, 'Key Vault Secrets User', roleScope)
  properties: {
    // roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '21090545-7ca7-4776-b22c-e363652d74d2')
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '4633458b-17de-408a-b874-0445c86b69e6')
    principalId: functionApp.identity.principalId
    scope: roleScope
  }
}
