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

## Explanation of the Phases

We are breaking out our deployments into phases to prove the functionality, resiliency and security of our application.

These Phases will be run one after the other.

### Phase 1

This will deploy the infrastructure without a VNet

Create the following resources:

* Service Bus Namespace and Queue
* Function App
* Web App
* Storage Account

The full idea is below:

```
Create Service Bus queue (tier=((env:serviceBusSku)), Function App (tier=((env:functionAppSku)) WebApp=((createWebAppTestPEP), Storage Accounts and VNet=createVNetForPEP and no PEP useSourceControlLoadTestCode=createVNetForPEPandnoPEPuseSourceControlLoadTestCode=useSourceControlLoadTestCode"
```

As of 7/12/2024, Phase 1 currently runs successfully.

### Phase 2

Phase 2 is dependent on Phase 1.

This will deploy the infrastructure with a Private Endpoint that will be configured with a Vnet and a WebApp.
