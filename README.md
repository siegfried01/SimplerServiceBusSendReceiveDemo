# SimplerServiceBusSendReceiveDemo

## This Project demonstrates several features

1. Grants role of azure-service-bus-data-receiver service bus receiver to azure function and consequently there is no need of a connection string that contains the service bus key (except for debugging or testing)
2. 



## How to run CSX files

We have prepared a Dotnet Script for sending example messages to the Service Bus. It can be executed as follows:

`dotnet-script .\ServiceBusSendSimpleMainProgram.csx`

Be sure to update the script to ensure that the correct connection string is being used.

### Send Messages to the Service Bus

`dotnet-script .\ServiceBusSendSimpleMainProgram.csx`

### Confirm that messages are being sent to the Function App

You can run log streaming form the CLI with this command:

`az webapp log tail --name <FunctionAppName> --resource-group <ResourceGroupName> `
