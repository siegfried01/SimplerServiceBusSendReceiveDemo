/*

   powershell -executionPolicy unrestricted -Command - <<EOF
   `perl -lne 'sub range {$b=shift; $e=shift; $r=""; for(($b..$e)){ $r=$r."," if $r; $r=$r.$_;} $r } BEGIN {  $_ = shift; s/([0-9]+)-([0-9]+)/range($1,$2)/e; @idx=split ","; $c=0; $x=0; $f=0; $s=[] } $c++ if /^\s*Begin/; if (/^\s*End/) {$c--;$s[$f++]=""}; if ($x+$c>1) { $s->[$f]=$s->[$f].$_."\n"  } $x=$c; END { push(@idx, $#s); unshift @idx,0; for (@idx) { $p=$s->[$_]; chomp $p; print $p } }' "2,3,1,4-7" < "deploy-ServiceBusSimpleSendReceive.bicep"  `
EOF

   Errors from CorpNet:
   ERROR: The command failed with an unexpected error. Here is the traceback:
   ERROR: Unable to find wstrust endpoint from MEX. This typically happens when attempting MSA accounts. More details available here. https://github.com/AzureAD/microsoft-authentication-library-for-python/wiki/Username-Password-Authentication
   ServiceBusConnection=Endpoint=sb://iqa5jvm-servicebus.servicebus.windows.net/;Authentication=ManagedIdentity

   Wed Jun 05 10:09 2024 errors on Siegfried's personal account:
   Microsoft.Azure.WebJobs.Host.Listeners.FunctionListenerException : The listener for function 'Functions.SimpleServiceBusReceiver' was unable to start. ---> System.ArgumentException : The connection string used for an Service Bus client must specify the Service Bus namespace host and either a Shared Access Key (both the name and value) OR a Shared Access Signature to be valid. (Parameter 'connectionString')
      at Azure.Messaging.ServiceBus.ServiceBusConnection.ValidateConnectionStringProperties(ServiceBusConnectionStringProperties connectionStringProperties,String connectionStringArgumentName)



   Begin common prolog commands
   #az login --user $env:AZ_USERNAME --password $env:AZ_PASSWORD
   $env:subscriptionId=(az account show --query id --output tsv | ForEach-Object { $_ -replace "`r", ""})
   $noManagedIdent=[bool]1
   $env:name="SBusSndRcv_$($env:USERNAME)"
   $env:name="SBusSndRcv"
   $env:rg="rg_$env:name"
   write-output "resource group=$env:rg"
   $env:uniquePrefix="$(If ($env:USERNAME -eq "v-richardsi") {"u2gzyv3"} Else { "iqa5jvm" })"
   $env:loc=If ($env:AZ_DEFAULT_LOC) { $env:AZ_DEFAULT_LOC } Else { "eastus2" }
   $env:funcLoc=$env:loc
   $env:functionAppName="$($env:uniquePrefix)-func"
   write-output "starting $(Get-Date) noManagedIdent=$($noManagedIdent)"
   End common prolog commands
   
   emacs F10
   Begin commands to deploy this file using Azure CLI with PowerShell
   write-output "Step 1"
   pushd ..
   write-output "az deployment group create --name $env:name --resource-group $env:rg --template-file  infrastructure/deploy-ServiceBusSimpleSendReceive.bicep"
   az deployment group create --name $env:name --resource-group $env:rg  --template-file  infrastructure/deploy-ServiceBusSimpleSendReceive.bicep --parameters "{'funcLoc': {'value': '$env:loc'}}" "{'noManagedIdent': {'value': $noManagedIdent}}" "{'uniquePrefix': {'value': '$env:uniquePrefix'}}"
   write-output "end deploy"
   popd
   End commands to deploy this file using Azure CLI with PowerShell

   New-AzResourceGroupDeployment -name "ServiceBusSimpleSendReceive" -Mode "Incremental"  -TemplateFile deploy-ServiceBusSimpleSendReceive.bicep

   emacs ESC 2 F10
   Begin commands to shut down this deployment using Azure CLI with PowerShell
   write-output "step 2"
   write-output "begin shutdown"
   write-output "az deployment group create --mode complete --template-file ./clear-resources.json --resource-group $env:rg"
   az deployment group create --mode complete --template-file ./clear-resources.json --resource-group $env:rg
   write-output "showdown is complete"
   End commands to shut down this deployment using Azure CLI with PowerShell

   emacs ESC 3 F10
   Begin commands for one time initializations using Azure CLI with PowerShell
   write-output "step 3"
   write-output "az group create -l $env:loc -n $env:rg"
   az group create -l $env:loc -n $env:rg
   write-output "{`n`"`$schema`": `"https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#`",`n `"contentVersion`": `"1.0.0.0`",`n `"resources`": [] `n}" | Out-File -FilePath clear-resources.json
   End commands for one time initializations using Azure CLI with PowerShell

   emacs ESC 4 F10
   Begin commands for one time initializations using Azure CLI with PowerShell
   write-output "step 4 delete resource group"
   write-output "az group delete -n $env:rg --yes"
   az group delete -n $env:rg --yes
   End commands for one time initializations using Azure CLI with PowerShell

   This code will eventually reside in the pipeline yaml
   emacs ESC 5 F10
   Begin commands to deploy this file using Azure CLI with PowerShell
   write-output "step 5 Publish"
   write-output "dotnet publish ../SimpleServiceBusSendReceiveAzureFuncs  --configuration Release  -f net8.0  --self-contained --output ./publish-functionapp"
   dotnet publish ../SimpleServiceBusSendReceiveAzureFuncs  --configuration Release  -f net8.0 --self-contained --output ./publish-functionapp
   End commands to deploy this file using Azure CLI with PowerShell

   This code will eventually reside in the pipeline yaml
   emacs ESC 6 F10
   Begin commands to deploy this file using Azure CLI with PowerShell
   write-output "step 6 zip"
   pushd ./publish-functionapp
   write-output "Compress-Archive -Path .\* -DestinationPath ../publish-functionapp.zip -Force"
   Compress-Archive -Path .\* -DestinationPath ../publish-functionapp.zip -Force
   popd
   End commands to deploy this file using Azure CLI with PowerShell
   
   https://learn.microsoft.com/en-us/azure/azure-functions/dotnet-isolated-process-guide?tabs=windows

   This warning only occurs on my personal account for all three of the commands below.
   step 7 configure function app
   az functionapp config appsettings set --name iqa5jvm-func --resource-group rg_SBusSndRcv --settings FUNCTIONS_WORKER_RUNTIME=dotnet-isolated DOTNET_VERSION=8
   WARNING: Invalid version:  for runtime dotnet-isolated and os windows. Supported versions for runtime dotnet-isolated and os windows are: ['8', '7', '6', '.4.8']. Run 'az functionapp list-runtimes' for more details on supported runtimes. 
   WARNING: App settings have been redacted. Use `az webapp/logicapp/functionapp config appsettings list` to view.
   [
     {
       "name": "busNS",
       "slotSetting": false,
       "value": null
     },
     {
       "name": "queue",
       "slotSetting": false,
       "value": null
     },
     {
       "name": "FUNCTIONS_EXTENSION_VERSION",
       "slotSetting": false,
       "value": null
     },
     {
       "name": "FUNCTIONS_WORKER_RUNTIME",
       "slotSetting": false,
       "value": null
     },
     {
       "name": "WEBSITE_USE_PLACEHOLDER_DOTNETISOLATED",
       "slotSetting": false,
       "value": null
     },
     {
       "name": "DOTNET_VERSION",
       "slotSetting": false,
       "value": null
     }
   ]
   az functionapp config appsettings set -n iqa5jvm-func -g rg_SBusSndRcv --settings 'FUNCTIONS_WORKER_RUNTIME=dotnet-isolated'
   WARNING: Invalid version:  for runtime dotnet-isolated and os windows. Supported versions for runtime dotnet-isolated and os windows are: ['8', '7', '6', '.4.8']. Run 'az functionapp list-runtimes' for more details on supported runtimes. 
   WARNING: App settings have been redacted. Use `az webapp/logicapp/functionapp config appsettings list` to view.
   [
     {
       "name": "busNS",
       "slotSetting": false,
       "value": null
     },
     {
       "name": "queue",
       "slotSetting": false,
       "value": null
     },
     {
       "name": "FUNCTIONS_EXTENSION_VERSION",
       "slotSetting": false,
       "value": null
     },
     {
       "name": "FUNCTIONS_WORKER_RUNTIME",
       "slotSetting": false,
       "value": null
     },
     {
       "name": "WEBSITE_USE_PLACEHOLDER_DOTNETISOLATED",
       "slotSetting": false,
       "value": null
     },
     {
       "name": "DOTNET_VERSION",
       "slotSetting": false,
       "value": null
     }
   ]
   az functionapp config appsettings set -g rg_SBusSndRcv -n iqa5jvm-func --settings 'WEBSITE_USE_PLACEHOLDER_DOTNETISOLATED=1'
   WARNING: Invalid version:  for runtime dotnet-isolated and os windows. Supported versions for runtime dotnet-isolated and os windows are: ['8', '7', '6', '.4.8']. Run 'az functionapp list-runtimes' for more details on supported runtimes. 
   WARNING: App settings have been redacted. Use `az webapp/logicapp/functionapp config appsettings list` to view.
   [
     {
       "name": "busNS",
       "slotSetting": false,
       "value": null
     },
     {
       "name": "queue",
       "slotSetting": false,
       "value": null
     },
     {
       "name": "FUNCTIONS_EXTENSION_VERSION",
       "slotSetting": false,
       "value": null
     },
     {
       "name": "FUNCTIONS_WORKER_RUNTIME",
       "slotSetting": false,
       "value": null
     },
     {
       "name": "WEBSITE_USE_PLACEHOLDER_DOTNETISOLATED",
       "slotSetting": false,
       "value": null
     },
     {
       "name": "DOTNET_VERSION",
       "slotSetting": false,
       "value": null
     }
   ]
   az functionapp config set -g rg_SBusSndRcv -n iqa5jvm-func --net-framework-version 'v8.0'
   WARNING: Invalid version:  for runtime dotnet-isolated and os windows. Supported versions for runtime dotnet-isolated and os windows are: ['8', '7', '6', '.4.8']. Run 'az functionapp list-runtimes' for more details on supported runtimes. 
   {
     "acrUseManagedIdentityCreds": false,
     "acrUserManagedIdentityId": null,
     "alwaysOn": false,
     "apiDefinition": null,
     "apiManagementConfig": null,
     "appCommandLine": "",
     "appSettings": null,
     "autoHealEnabled": false,
     "autoHealRules": null,
     "autoSwapSlotName": null,
     "azureStorageAccounts": {},
     "connectionStrings": null,
     "cors": null,
     "defaultDocuments": [
       "Default.htm",
       "Default.html",
       "Default.asp",
       "index.htm",
       "index.html",
       "iisstart.htm",
       "default.aspx",
       "index.php"
     ],
     "detailedErrorLoggingEnabled": false,
     "documentRoot": null,
     "elasticWebAppScaleLimit": null,
     "experiments": {
       "rampUpRules": []
     },
     "ftpsState": "FtpsOnly",
     "functionAppScaleLimit": 200,
     "functionsRuntimeScaleMonitoringEnabled": false,
     "handlerMappings": null,
     "healthCheckPath": null,
     "http20Enabled": false,
     "httpLoggingEnabled": false,
     "id": "/subscriptions/acc26051-92a5-4ed1-a226-64a187bc27db/resourceGroups/rg_SBusSndRcv/providers/Microsoft.Web/sites/iqa5jvm-func",
     "ipSecurityRestrictions": [
       {
         "action": "Allow",
         "description": "Allow all access",
         "headers": null,
         "ipAddress": "Any",
         "name": "Allow all",
         "priority": 2147483647,
         "subnetMask": null,
         "subnetTrafficTag": null,
         "tag": null,
         "vnetSubnetResourceId": null,
         "vnetTrafficTag": null
       }
     ],
     "ipSecurityRestrictionsDefaultAction": null,
     "javaContainer": null,
     "javaContainerVersion": null,
     "javaVersion": null,
     "keyVaultReferenceIdentity": null,
     "kind": null,
     "limits": null,
     "linuxFxVersion": "",
     "loadBalancing": "LeastRequests",
     "localMySqlEnabled": false,
     "location": "West US 2",
     "logsDirectorySizeLimit": 35,
     "machineKey": null,
     "managedPipelineMode": "Integrated",
     "managedServiceIdentityId": 22859,
     "metadata": null,
     "minTlsCipherSuite": null,
     "minTlsVersion": "1.2",
     "minimumElasticInstanceCount": 1,
     "name": "iqa5jvm-func",
     "netFrameworkVersion": "v8.0",
     "nodeVersion": "",
     "numberOfWorkers": 1,
     "phpVersion": "",
     "powerShellVersion": "",
     "preWarmedInstanceCount": 0,
     "publicNetworkAccess": null,
     "publishingUsername": "$iqa5jvm-func",
     "push": null,
     "pythonVersion": "",
     "remoteDebuggingEnabled": false,
     "remoteDebuggingVersion": "VS2019",
     "requestTracingEnabled": false,
     "requestTracingExpirationTime": null,
     "resourceGroup": "rg_SBusSndRcv",
     "scmIpSecurityRestrictions": [
       {
         "action": "Allow",
         "description": "Allow all access",
         "headers": null,
         "ipAddress": "Any",
         "name": "Allow all",
         "priority": 2147483647,
         "subnetMask": null,
         "subnetTrafficTag": null,
         "tag": null,
         "vnetSubnetResourceId": null,
         "vnetTrafficTag": null
       }
     ],
     "scmIpSecurityRestrictionsDefaultAction": null,
     "scmIpSecurityRestrictionsUseMain": false,
     "scmMinTlsVersion": "1.2",
     "scmType": "None",
     "tracingOptions": null,
     "type": "Microsoft.Web/sites",
     "use32BitWorkerProcess": true,
     "virtualApplications": [
       {
         "physicalPath": "site\\wwwroot",
         "preloadEnabled": false,
         "virtualDirectories": null,
         "virtualPath": "/"
       }
     ],
     "vnetName": "",
     "vnetPrivatePortsCount": 0,
     "vnetRouteAllEnabled": false,
     "webSocketsEnabled": false,
     "websiteTimeZone": null,
     "windowsFxVersion": null,
     "xManagedServiceIdentityId": null
   }
   az functionapp config set -g rg_SBusSndRcv -n iqa5jvm-func --use-32bit-worker-process false
   WARNING: Invalid version:  for runtime dotnet-isolated and os windows. Supported versions for runtime dotnet-isolated and os windows are: ['8', '7', '6', '.4.8']. Run 'az functionapp list-runtimes' for more details on supported runtimes. 
   {
     "acrUseManagedIdentityCreds": false,
     "acrUserManagedIdentityId": null,
     "alwaysOn": false,
     "apiDefinition": null,
     "apiManagementConfig": null,
     "appCommandLine": "",
     "appSettings": null,
     "autoHealEnabled": false,
     "autoHealRules": null,
     "autoSwapSlotName": null,
     "azureStorageAccounts": {},
     "connectionStrings": null,
     "cors": null,
     "defaultDocuments": [
       "Default.htm",
       "Default.html",
       "Default.asp",
       "index.htm",
       "index.html",
       "iisstart.htm",
       "default.aspx",
       "index.php"
     ],
     "detailedErrorLoggingEnabled": false,
     "documentRoot": null,
     "elasticWebAppScaleLimit": null,
     "experiments": {
       "rampUpRules": []
     },
     "ftpsState": "FtpsOnly",
     "functionAppScaleLimit": 200,
     "functionsRuntimeScaleMonitoringEnabled": false,
     "handlerMappings": null,
     "healthCheckPath": null,
     "http20Enabled": false,
     "httpLoggingEnabled": false,
     "id": "/subscriptions/acc26051-92a5-4ed1-a226-64a187bc27db/resourceGroups/rg_SBusSndRcv/providers/Microsoft.Web/sites/iqa5jvm-func",
     "ipSecurityRestrictions": [
       {
         "action": "Allow",
         "description": "Allow all access",
         "headers": null,
         "ipAddress": "Any",
         "name": "Allow all",
         "priority": 2147483647,
         "subnetMask": null,
         "subnetTrafficTag": null,
         "tag": null,
         "vnetSubnetResourceId": null,
         "vnetTrafficTag": null
       }
     ],
     "ipSecurityRestrictionsDefaultAction": null,
     "javaContainer": null,
     "javaContainerVersion": null,
     "javaVersion": null,
     "keyVaultReferenceIdentity": null,
     "kind": null,
     "limits": null,
     "linuxFxVersion": "",
     "loadBalancing": "LeastRequests",
     "localMySqlEnabled": false,
     "location": "West US 2",
     "logsDirectorySizeLimit": 35,
     "machineKey": null,
     "managedPipelineMode": "Integrated",
     "managedServiceIdentityId": 22859,
     "metadata": null,
     "minTlsCipherSuite": null,
     "minTlsVersion": "1.2",
     "minimumElasticInstanceCount": 1,
     "name": "iqa5jvm-func",
     "netFrameworkVersion": "v8.0",
     "nodeVersion": "",
     "numberOfWorkers": 1,
     "phpVersion": "",
     "powerShellVersion": "",
     "preWarmedInstanceCount": 0,
     "publicNetworkAccess": null,
     "publishingUsername": "$iqa5jvm-func",
     "push": null,
     "pythonVersion": "",
     "remoteDebuggingEnabled": false,
     "remoteDebuggingVersion": "VS2019",
     "requestTracingEnabled": false,
     "requestTracingExpirationTime": null,
     "resourceGroup": "rg_SBusSndRcv",
     "scmIpSecurityRestrictions": [
       {
         "action": "Allow",
         "description": "Allow all access",
         "headers": null,
         "ipAddress": "Any",
         "name": "Allow all",
         "priority": 2147483647,
         "subnetMask": null,
         "subnetTrafficTag": null,
         "tag": null,
         "vnetSubnetResourceId": null,
         "vnetTrafficTag": null
       }
     ],
     "scmIpSecurityRestrictionsDefaultAction": null,
     "scmIpSecurityRestrictionsUseMain": false,
     "scmMinTlsVersion": "1.2",
     "scmType": "None",
     "tracingOptions": null,
     "type": "Microsoft.Web/sites",
     "use32BitWorkerProcess": true,
     "virtualApplications": [
       {
         "physicalPath": "site\\wwwroot",
         "preloadEnabled": false,
         "virtualDirectories": null,
         "virtualPath": "/"
       }
     ],
     "vnetName": "",
     "vnetPrivatePortsCount": 0,
     "vnetRouteAllEnabled": false,
     "webSocketsEnabled": false,
     "websiteTimeZone": null,
     "windowsFxVersion": null,
     "xManagedServiceIdentityId": null
   }
   az functionapp config appsettings set --name iqa5jvm-func --resource-group rg_SBusSndRcv --settings FUNCTIONS_EXTENSION_VERSION=~4
   WARNING: Invalid version:  for runtime dotnet-isolated and os windows. Supported versions for runtime dotnet-isolated and os windows are: ['8', '7', '6', '.4.8']. Run 'az functionapp list-runtimes' for more details on supported runtimes. 
   WARNING: App settings have been redacted. Use `az webapp/logicapp/functionapp config appsettings list` to view.
   [
     {
       "name": "busNS",
       "slotSetting": false,
       "value": null
     },
     {
       "name": "queue",
       "slotSetting": false,
       "value": null
     },
     {
       "name": "FUNCTIONS_EXTENSION_VERSION",
       "slotSetting": false,
       "value": null
     },
     {
       "name": "FUNCTIONS_WORKER_RUNTIME",
       "slotSetting": false,
       "value": null
     },
     {
       "name": "WEBSITE_USE_PLACEHOLDER_DOTNETISOLATED",
       "slotSetting": false,
       "value": null
     },
     {
       "name": "DOTNET_VERSION",
       "slotSetting": false,
       "value": null
     }
   ]
   az functionapp config appsettings list -n iqa5jvm-func -r rg_SBusSndRcv
   ERROR: unrecognized arguments: -r rg_SBusSndRcv
   
   Examples from AI knowledge base:
   az functionapp config appsettings list --name MyWebapp --resource-group MyResourceGroup
   Show settings for a function app. (autogenerated)
   
   az functionapp config appsettings list --name MyWebapp --resource-group MyResourceGroup --slot staging
   Show settings for a function app. (autogenerated)
   
   https://docs.microsoft.com/en-US/cli/azure/functionapp/config/appsettings#az_functionapp_config_appsettings_list
Read more about the command in reference docs

   This code will eventually reside in the pipeline yaml
   emacs ESC 7 F10
   Begin commands to deploy this file using Azure CLI with PowerShell
   write-output "step 7 configure function app"
   write-output "az functionapp config appsettings set --name $env:functionAppName --resource-group $env:rg --settings FUNCTIONS_WORKER_RUNTIME=dotnet-isolated DOTNET_VERSION=8"
   az functionapp config appsettings set --name $env:functionAppName --resource-group $env:rg --settings FUNCTIONS_WORKER_RUNTIME=dotnet-isolated DOTNET_VERSION=8
   write-output "az functionapp config appsettings set -n $env:functionAppName -g $env:rg --settings 'FUNCTIONS_WORKER_RUNTIME=dotnet-isolated'"
   az functionapp config appsettings set -n $env:functionAppName -g $env:rg --settings "FUNCTIONS_WORKER_RUNTIME=dotnet-isolated"
   write-output "az functionapp config appsettings set -g $env:rg -n $env:functionAppName --settings 'WEBSITE_USE_PLACEHOLDER_DOTNETISOLATED=1'"
   az functionapp config appsettings set -g $env:rg -n $env:functionAppName --settings WEBSITE_USE_PLACEHOLDER_DOTNETISOLATED=1
   write-output "az functionapp config set -g $env:rg -n $env:functionAppName --net-framework-version 'v8.0'"
   az functionapp config set -g $env:rg -n $env:functionAppName --net-framework-version v8.0
   write-output "az functionapp config set -g $env:rg -n $env:functionAppName --use-32bit-worker-process false"
   az functionapp config set -g $env:rg -n $env:functionAppName --use-32bit-worker-process false
   write-output "az functionapp config appsettings set --name $env:functionAppName --resource-group $env:rg --settings FUNCTIONS_EXTENSION_VERSION=~4"
   az functionapp config appsettings set --name $env:functionAppName --resource-group $env:rg --settings FUNCTIONS_EXTENSION_VERSION=~4
   write-output "az functionapp config appsettings list -n $env:functionAppName -r $env:rg"
   az functionapp config appsettings list -n $env:functionAppName -r $env:rg
   End commands to deploy this file using Azure CLI with PowerShell


   This code will eventually be replace by EV2 resident JSON ARM template that does zipdeploy
   emacs ESC 8 F10
   Begin commands to deploy this file using Azure CLI with PowerShell
   write-output "step 8 deploy compiled C# code deployment to azure resource"
   write-output "az functionapp deployment source config-zip -g $env:rg -n $env:functionAppName --src ./publish-functionapp.zip"
   az functionapp deployment source config-zip -g $env:rg -n $env:functionAppName --src ./publish-functionapp.zip
   End commands to deploy this file using Azure CLI with PowerShell

   emacs ESC 9 F10
   Begin commands to deploy this file using Azure CLI with PowerShell
   write-output "step 9 webapp tail logs"
   write-output "az webapp log tail -g $env:rg -n $env:functionAppName"
   az webapp log tail -g $env:rg -n $env:functionAppName
   End commands to deploy this file using Azure CLI with PowerShell

   emacs ESC 10 F10
   Begin commands to deploy this file using Azure CLI with PowerShell
   write-output "step 10 get the logs This is not working and I don't now why"
   write-output "curl -X GET 'https://$($env:uniquePrefix)-func.scm.azurewebsites.net/api/dump'"
   curl  "https://$($env:uniquePrefix)-func.scm.azurewebsites.net/api/dump"
   dir
   End commands to deploy this file using Azure CLI with PowerShell

   Begin common epilog commands
   #Get-AzResource -ResourceGroupName $env:rg | ft
   az resource list -g $env:rg --query "[?resourceGroup=='$env:rg'].{ name: name, flavor: kind, resourceType: type, region: location }" --output table  | tr '\r' -d
   write-output "all done $(Get-Date)"
   End common epilog commands


 */

param queueName string = 'mainqueue001'
param loc string = resourceGroup().location
param funcLoc string = loc
param noManagedIdent bool = false
param uniquePrefix string = uniqueString(resourceGroup().id)
param sbdemo001NS_name string = '${uniquePrefix}-servicebus'




resource sbnsSimpleSendReceiveDemo 'Microsoft.ServiceBus/namespaces@2022-01-01-preview' = {
  name: sbdemo001NS_name
  location: loc
  sku: {
    name: 'Standard'
    tier: 'Standard'
  }
  properties: {
    minimumTlsVersion: '1.0'
    publicNetworkAccess: 'Enabled'
    disableLocalAuth: false
    zoneRedundant: false
  }
}

resource sbnsauthFilterDemo001RootManageSharedAccessKey 'Microsoft.ServiceBus/namespaces/authorizationrules@2022-01-01-preview' = {
  parent: sbnsSimpleSendReceiveDemo
  name: 'RootManageSharedAccessKey'
  properties: {
    rights: [
      'Listen'
      'Manage'
      'Send'
    ]
  }
}

resource sbnsnwrSendReceiveDemo 'Microsoft.ServiceBus/namespaces/networkRuleSets@2022-01-01-preview' = {
  parent: sbnsSimpleSendReceiveDemo
  name: 'default'
  properties: {
    publicNetworkAccess: 'Enabled'
    defaultAction: 'Allow'
    virtualNetworkRules: []
    ipRules: []
  }
}

resource sbQueue 'Microsoft.ServiceBus/namespaces/queues@2022-01-01-preview' = {
  parent: sbnsSimpleSendReceiveDemo
  name: queueName
  properties: {
    maxMessageSizeInKilobytes: 256
    lockDuration: 'PT1M'
    maxSizeInMegabytes: 1024
    requiresDuplicateDetection: false
    requiresSession: false
    defaultMessageTimeToLive: 'P10675199DT2H48M5.4775807S'
    deadLetteringOnMessageExpiration: false
    enableBatchedOperations: true
    duplicateDetectionHistoryTimeWindow: 'PT10M'
    maxDeliveryCount: 10
    status: 'Active'
    autoDeleteOnIdle: 'P10675199DT2H48M5.4775807S'
    enablePartitioning: false
    enableExpress: false
  }
}

// https://stackoverflow.com/questions/68404000/get-the-service-bus-sharedaccesskey-programatically-using-bicep
output serviceBusEndpoint1 string = sbnsSimpleSendReceiveDemo.properties.serviceBusEndpoint
var serviceBusKeyId = '${sbnsSimpleSendReceiveDemo.id}/AuthorizationRules/RootManageSharedAccessKey'
var serviceBusConnection = listKeys(serviceBusKeyId, sbnsSimpleSendReceiveDemo.apiVersion).primaryConnectionString
// Extract the service bus endpoint from the connection string
var serviceBusEndPoint = split(serviceBusConnection,';')[0]
var serviceBusConnectionViaMSI= '${serviceBusEndPoint};Authentication=ManagedIdentity'
output outputServiceBusEndpoint string = serviceBusEndPoint
output outputServiceBusConnectionViaMSI string = serviceBusConnectionViaMSI
output serviceBusConnectionString string = serviceBusConnection
output busNS string = sbdemo001NS_name
output queue string = sbQueue.name
output noManagedIdentoutput bool = noManagedIdent


param ServiceBusSenderReceiverPlans string = '${uniquePrefix}-func'
resource functionPlan 'Microsoft.Web/serverfarms@2023-01-01' = {
  name: '${uniquePrefix}-func-plan'
  location: funcLoc
  sku: {
    name: 'Y1'
    tier: 'Dynamic'
    size: 'Y1'
    family: 'Y'
    capacity: 0
  }
  kind: 'functionapp'
  properties: {
    perSiteScaling: false
    elasticScaleEnabled: false
    maximumElasticWorkerCount: 1
    isSpot: false
    reserved: false
    isXenon: false
    hyperV: false
    targetWorkerCount: 0
    targetWorkerSizeId: 0
    zoneRedundant: false
  }
}

resource ServiceBusSenderReceiverFunctions 'Microsoft.Web/sites@2023-01-01' = {
  name: ServiceBusSenderReceiverPlans
  location: funcLoc
  kind: 'functionapp'
  identity:{
    type: 'SystemAssigned'
  }
  properties: {
    enabled: true
    hostNameSslStates: [
      {
        name: 'simpleservicebusreceiverazurefuncs.azurewebsites.net'
        sslState: 'Disabled'
        hostType: 'Standard'
      }
      {
        name: 'simpleservicebusreceiverazurefuncs.scm.azurewebsites.net'
        sslState: 'Disabled'
        hostType: 'Repository'
      }
    ]
    serverFarmId: functionPlan.id
    reserved: false
    isXenon: false
    hyperV: false
    vnetRouteAllEnabled: false
    vnetImagePullEnabled: false
    vnetContentShareEnabled: false
    siteConfig: {
      numberOfWorkers: 1
      acrUseManagedIdentityCreds: false
      alwaysOn: false
      http20Enabled: false
      functionAppScaleLimit: 200
      minimumElasticInstanceCount: 0
      appSettings: [
        {
          name: 'busNS'
          value: sbdemo001NS_name
        }
        {
          name: 'queue'
          value: queueName
        }
      ]
      connectionStrings: [
        {
          type: 'Custom'
          connectionString: noManagedIdent? serviceBusConnection : serviceBusConnectionViaMSI
          name: 'ServiceBusConnection'
        }
      ]
    }
    scmSiteAlsoStopped: false
    clientAffinityEnabled: false
    clientCertEnabled: false
    clientCertMode: 'Required'
    hostNamesDisabled: false
    customDomainVerificationId: '40BF7B86C2FCFDDFCAF1DB349DF5DEE2661093DBD1F889FA84ED4AAB4DA8B993'
    containerSize: 1536
    dailyMemoryTimeQuota: 0
    httpsOnly: true
    redundancyMode: 'None'
    storageAccountRequired: false
    keyVaultReferenceIdentity: 'SystemAssigned'
  }
  
}

resource ServiceBusSenderReceiverFunctionsFtp 'Microsoft.Web/sites/basicPublishingCredentialsPolicies@2023-01-01' = {
  parent: ServiceBusSenderReceiverFunctions
  name: 'ftp'
  properties: {
    allow: true
  }
}

resource ServiceBusSenderReceiverFunctionsScm 'Microsoft.Web/sites/basicPublishingCredentialsPolicies@2023-01-01' = {
  parent: ServiceBusSenderReceiverFunctions
  name: 'scm'
  properties: {
    allow: true
  }
}

resource ServiceBusSenderReceiverFunctionsWebConfig 'Microsoft.Web/sites/config@2023-01-01' = {
  parent: ServiceBusSenderReceiverFunctions
  name: 'web'
  properties: {
    numberOfWorkers: 1
    defaultDocuments: [
      'Default.htm'
      'Default.html'
      'Default.asp'
      'index.htm'
      'index.html'
      'iisstart.htm'
      'default.aspx'
      'index.php'
    ]
    netFrameworkVersion: 'v6.0'
    requestTracingEnabled: false
    remoteDebuggingEnabled: false
    remoteDebuggingVersion: 'VS2019'
    httpLoggingEnabled: false
    acrUseManagedIdentityCreds: false
    logsDirectorySizeLimit: 35
    detailedErrorLoggingEnabled: false
    publishingUsername: '$SimpleServiceBusReceiverAzureFuncs'
    scmType: 'None'
    use32BitWorkerProcess: true
    webSocketsEnabled: false
    alwaysOn: false
    managedPipelineMode: 'Integrated'
    virtualApplications: [
      {
        virtualPath: '/'
        physicalPath: 'site\\wwwroot'
        preloadEnabled: false
      }
    ]
    loadBalancing: 'LeastRequests'
    experiments: {
      rampUpRules: []
    }
    autoHealEnabled: false
    vnetRouteAllEnabled: false
    vnetPrivatePortsCount: 0
    localMySqlEnabled: false
    ipSecurityRestrictions: [
      {
        ipAddress: 'Any'
        action: 'Allow'
        priority: 2147483647
        name: 'Allow all'
        description: 'Allow all access'
      }
    ]
    scmIpSecurityRestrictions: [
      {
        ipAddress: 'Any'
        action: 'Allow'
        priority: 2147483647
        name: 'Allow all'
        description: 'Allow all access'
      }
    ]
    scmIpSecurityRestrictionsUseMain: false
    http20Enabled: false
    minTlsVersion: '1.2'
    scmMinTlsVersion: '1.2'
    ftpsState: 'FtpsOnly'
    preWarmedInstanceCount: 0
    functionAppScaleLimit: 200
    functionsRuntimeScaleMonitoringEnabled: false
    minimumElasticInstanceCount: 0
    azureStorageAccounts: {}
  }
}

resource sites_SimpleServiceBusReceiverAzureFuncs_name_73236288f08d4694a60c7016deb6b26b 'Microsoft.Web/sites/deployments@2023-01-01' = {
  parent: ServiceBusSenderReceiverFunctions
  name: '73236288f08d4694a60c7016deb6b26b'
  properties: {
    status: 4
    author_email: 'N/A'
    author: 'N/A'
    deployer: 'ZipDeploy'
    message: 'Created via a push deployment'
    start_time: '2024-03-30T01:22:47.93242Z'
    end_time: '2024-03-30T01:22:53.4664969Z'
    active: true
  }
}

resource sites_SimpleServiceBusReceiverAzureFuncs_name_SimpleServiceBusReceiver 'Microsoft.Web/sites/functions@2023-01-01' = {
  parent: ServiceBusSenderReceiverFunctions
  name: 'SimpleServiceBusReceiver'
  properties: {
    script_root_path_href: 'https://simpleservicebusreceiverazurefuncs.azurewebsites.net/admin/vfs/site/wwwroot/SimpleServiceBusReceiver/'
    script_href: 'https://simpleservicebusreceiverazurefuncs.azurewebsites.net/admin/vfs/site/wwwroot/bin/SimpleServiceBusSendReceiveAzureFuncs.dll'
    config_href: 'https://simpleservicebusreceiverazurefuncs.azurewebsites.net/admin/vfs/site/wwwroot/SimpleServiceBusReceiver/function.json'
    test_data_href: 'https://simpleservicebusreceiverazurefuncs.azurewebsites.net/admin/vfs/data/Functions/sampledata/SimpleServiceBusReceiver.dat'
    href: 'https://simpleservicebusreceiverazurefuncs.azurewebsites.net/admin/functions/SimpleServiceBusReceiver'
    config: {}
    language: 'DotNetAssembly'
    isDisabled: false
  }
}

resource sites_SimpleServiceBusReceiverAzureFuncs_name_sites_SimpleServiceBusReceiverAzureFuncs_name_azurewebsites_net 'Microsoft.Web/sites/hostNameBindings@2023-01-01' = {
  parent: ServiceBusSenderReceiverFunctions
  name: '${ServiceBusSenderReceiverPlans}.azurewebsites.net'
  properties: {
    siteName: 'SimpleServiceBusReceiverAzureFuncs'
    hostNameType: 'Verified'
  }
}


module  assignRoleToFunctionApp 'assignRbacRoleToFunctionApp.bicep' = if (!noManagedIdent) {
  name: 'assign-role-to-functionApp'
  params: {
	roleScope: resourceGroup().id
	functionAppName: ServiceBusSenderReceiverFunctions.name
    functionPrincipalId: ServiceBusSenderReceiverFunctions.identity.principalId
  }
}



/*
log from persaonl account.
az webapp log tail -g rg_SBusSndRcv -n iqa5jvm-func
WARNING: 2024-06-05T20:16:13  Welcome, you are now connected to log-streaming service. The default timeout is 2 hours. Change the timeout with the App Setting SCM_LOGSTREAM_TIMEOUT (in seconds). 
WARNING: 2024-06-05T20:16:48.968 [Information] Host lock lease acquired by instance ID '48dc960434dad156bbc4e40f6f8e23ba'.
WARNING: 2024-06-05T20:16:56.559 [Error] Unhandled exception. System.IO.FileNotFoundException: Could not load file or assembly 'Microsoft.Extensions.Diagnostics, Version=8.0.0.0, Culture=neutral, PublicKeyToken=adb9793829ddae60'. The system cannot find the file specified.
WARNING: 2024-06-05T20:16:56.559 [Information] File name: 'Microsoft.Extensions.Diagnostics, Version=8.0.0.0, Culture=neutral, PublicKeyToken=adb9793829ddae60'
2024-06-05T20:16:56.559 [Information] at Microsoft.Extensions.Hosting.HostBuilder.PopulateServiceCollection(IServiceCollection services, HostBuilderContext hostBuilderContext, HostingEnvironment hostingEnvironment, PhysicalFileProvider defaultFileProvider, IConfiguration appConfiguration, Func`1 serviceProviderGetter)
WARNING: 2024-06-05T20:16:56.559 [Information] at Microsoft.Extensions.Hosting.HostBuilder.InitializeServiceProvider()
WARNING: 2024-06-05T20:16:56.559 [Information] at Microsoft.Extensions.Hosting.HostBuilder.Build()
2024-06-05T20:16:56.559 [Information] at Program.<Main>$(String[] args) in C:\Users\shein\source\repos\SimplerServiceBusSendReceiveDemo\SimpleServiceBusSendReceiveAzureFuncs\SimpleServiceBusSenderReceiverMainProgram.cs:line 3
2024-06-05T20:16:56.575 [Error] Exceeded language worker restart retry count for runtime:dotnet-isolated. Shutting down and proactively recycling the Functions Host to recover
2024-06-05T20:16:56.634 [Information] Stopping JobHost
2024-06-05T20:16:56.638 [Information] Stopping the listener 'Microsoft.Azure.WebJobs.ServiceBus.Listeners.ServiceBusListener' for function 'SimpleServiceBusReceiver'
2024-06-05T20:16:56.696 [Information] Stopping the listener 'Microsoft.Azure.WebJobs.ServiceBus.Listeners.ServiceBusListener' for function 'SimpleServiceBusSenderReceiver'
WARNING: 2024-06-05T20:17:17.666 [Error] Unhandled exception. System.IO.FileNotFoundException: Could not load file or assembly 'Microsoft.Extensions.Diagnostics, Version=8.0.0.0, Culture=neutral, PublicKeyToken=adb9793829ddae60'. The system cannot find the file specified.
WARNING: 2024-06-05T20:17:17.666 [Information] File name: 'Microsoft.Extensions.Diagnostics, Version=8.0.0.0, Culture=neutral, PublicKeyToken=adb9793829ddae60'
2024-06-05T20:17:17.667 [Information] at Microsoft.Extensions.Hosting.HostBuilder.PopulateServiceCollection(IServiceCollection services, HostBuilderContext hostBuilderContext, HostingEnvironment hostingEnvironment, PhysicalFileProvider defaultFileProvider, IConfiguration appConfiguration, Func`1 serviceProviderGetter)
2024-06-05T20:17:17.667 [Information] at Microsoft.Extensions.Hosting.HostBuilder.InitializeServiceProvider()
2024-06-05T20:17:17.667 [Information] at Microsoft.Extensions.Hosting.HostBuilder.Build()
2024-06-05T20:17:17.667 [Information] at Program.<Main>$(String[] args) in C:\Users\shein\source\repos\SimplerServiceBusSendReceiveDemo\SimpleServiceBusSendReceiveAzureFuncs\SimpleServiceBusSenderReceiverMainProgram.cs:line 3
2024-06-05T20:17:17.716 [Error] Failed to start a new language worker for runtime: dotnet-isolated.
System.Threading.Tasks.TaskCanceledException : A task was canceled.
   at async Microsoft.Azure.WebJobs.Script.Grpc.GrpcWorkerChannel.StartWorkerProcessAsync(CancellationToken cancellationToken) at /_/src/WebJobs.Script.Grpc/Channel/GrpcWorkerChannel.cs : 377
   at System.Runtime.ExceptionServices.ExceptionDispatchInfo.Throw()
   at async Microsoft.Azure.WebJobs.Script.Workers.Rpc.RpcFunctionInvocationDispatcher.InitializeJobhostLanguageWorkerChannelAsync(??) at /_/src/WebJobs.Script/Workers/Rpc/FunctionRegistration/RpcFunctionInvocationDispatcher.cs : 156
   at System.Runtime.ExceptionServices.ExceptionDispatchInfo.Throw()
   at async Microsoft.Azure.WebJobs.Script.Workers.Rpc.RpcFunctionInvocationDispatcher.InitializeJobhostLanguageWorkerChannelAsync(??) at /_/src/WebJobs.Script/Workers/Rpc/FunctionRegistration/RpcFunctionInvocationDispatcher.cs : 148
WARNING:    at System.Runtime.ExceptionServices.ExceptionDispatchInfo.Throw()
WARNING:    at async Microsoft.Azure.WebJobs.Script.Workers.Rpc.RpcFunctionInvocationDispatcher.InitializeJobhostLanguageWorkerChannelAsync(??) at /_/src/WebJobs.Script/Workers/Rpc/FunctionRegistration/RpcFunctionInvocationDispatcher.cs : 139
   at System.Runtime.ExceptionServices.ExceptionDispatchInfo.Throw()
   at async Microsoft.Azure.WebJobs.Script.Workers.Rpc.RpcFunctionInvocationDispatcher.<>c__DisplayClass56_0.<StartWorkerProcesses>b__0(??) at /_/src/WebJobs.Script/Workers/Rpc/FunctionRegistration/RpcFunctionInvocationDispatcher.cs : 219
2024-06-05T20:17:17.871 [Error] Unhandled exception. System.IO.FileNotFoundException: Could not load file or assembly 'Microsoft.Extensions.Diagnostics, Version=8.0.0.0, Culture=neutral, PublicKeyToken=adb9793829ddae60'. The system cannot find the file specified.
WARNING: 2024-06-05T20:17:17.871 [Information] File name: 'Microsoft.Extensions.Diagnostics, Version=8.0.0.0, Culture=neutral, PublicKeyToken=adb9793829ddae60'
WARNING: 2024-06-05T20:17:17.871 [Information] at Microsoft.Extensions.Hosting.HostBuilder.PopulateServiceCollection(IServiceCollection services, HostBuilderContext hostBuilderContext, HostingEnvironment hostingEnvironment, PhysicalFileProvider defaultFileProvider, IConfiguration appConfiguration, Func`1 serviceProviderGetter)
2024-06-05T20:17:17.871 [Information] at Microsoft.Extensions.Hosting.HostBuilder.InitializeServiceProvider()
2024-06-05T20:17:17.871 [Information] at Microsoft.Extensions.Hosting.HostBuilder.Build()
2024-06-05T20:17:17.871 [Information] at Program.<Main>$(String[] args) in C:\Users\shein\source\repos\SimplerServiceBusSendReceiveDemo\SimpleServiceBusSendReceiveAzureFuncs\SimpleServiceBusSenderReceiverMainProgram.cs:line 3
WARNING: 2024-06-05T20:17:19.295 [Information] Host lock lease acquired by instance ID '48dc960434dad156bbc4e40f6f8e23ba'.
WARNING: 2024-06-05T20:17:28.113 [Error] Unhandled exception. System.IO.FileNotFoundException: Could not load file or assembly 'Microsoft.Extensions.Diagnostics, Version=8.0.0.0, Culture=neutral, PublicKeyToken=adb9793829ddae60'. The system cannot find the file specified.
WARNING: 2024-06-05T20:17:28.113 [Information] File name: 'Microsoft.Extensions.Diagnostics, Version=8.0.0.0, Culture=neutral, PublicKeyToken=adb9793829ddae60'
2024-06-05T20:17:28.113 [Information] at Microsoft.Extensions.Hosting.HostBuilder.PopulateServiceCollection(IServiceCollection services, HostBuilderContext hostBuilderContext, HostingEnvironment hostingEnvironment, PhysicalFileProvider defaultFileProvider, IConfiguration appConfiguration, Func`1 serviceProviderGetter)
2024-06-05T20:17:28.113 [Information] at Microsoft.Extensions.Hosting.HostBuilder.InitializeServiceProvider()
2024-06-05T20:17:28.113 [Information] at Microsoft.Extensions.Hosting.HostBuilder.Build()
WARNING: 2024-06-05T20:17:28.113 [Information] at Program.<Main>$(String[] args) in C:\Users\shein\source\repos\SimplerServiceBusSendReceiveDemo\SimpleServiceBusSendReceiveAzureFuncs\SimpleServiceBusSenderReceiverMainProgram.cs:line 3
WARNING: 2024-06-05T20:17:28.136 [Error] Exceeded language worker restart retry count for runtime:dotnet-isolated. Shutting down and proactively recycling the Functions Host to recover
2024-06-05T20:17:28.192 [Information] Stopping JobHost
2024-06-05T20:17:28.195 [Information] Stopping the listener 'Microsoft.Azure.WebJobs.ServiceBus.Listeners.ServiceBusListener' for function 'SimpleServiceBusReceiver'
2024-06-05T20:17:28.280 [Information] Stopping the listener 'Microsoft.Azure.WebJobs.ServiceBus.Listeners.ServiceBusListener' for function 'SimpleServiceBusSenderReceiver'
WARNING: 2024-06-05T20:17:28.310 [Information] Stopped the listener 'Microsoft.Azure.WebJobs.ServiceBus.Listeners.ServiceBusListener' for function 'SimpleServiceBusReceiver'
WARNING: 2024-06-05T20:17:28.332 [Information] Stopped the listener 'Microsoft.Azure.WebJobs.ServiceBus.Listeners.ServiceBusListener' for function 'SimpleServiceBusSenderReceiver'
WARNING: 2024-06-05T20:17:28.338 [Information] Job host stopped
WARNING: 2024-06-05T20:17:34.321 [Information] Host lock lease acquired by instance ID '302437db9243b689321142964e6dc164'.
WARNING: 2024-06-05T20:17:35.879 [Information] Stopping JobHost
WARNING: 2024-06-05T20:17:35.880 [Information] Stopping the listener 'Microsoft.Azure.WebJobs.ServiceBus.Listeners.ServiceBusListener' for function 'SimpleServiceBusReceiver'
WARNING: 2024-06-05T20:17:35.966 [Information] Stopping the listener 'Microsoft.Azure.WebJobs.ServiceBus.Listeners.ServiceBusListener' for function 'SimpleServiceBusSenderReceiver'
WARNING: 2024-06-05T20:17:35.998 [Information] Stopped the listener 'Microsoft.Azure.WebJobs.ServiceBus.Listeners.ServiceBusListener' for function 'SimpleServiceBusReceiver'
2024-06-05T20:17:36.019 [Information] Stopped the listener 'Microsoft.Azure.WebJobs.ServiceBus.Listeners.ServiceBusListener' for function 'SimpleServiceBusSenderReceiver'
2024-06-05T20:17:36.025 [Information] Job host stopped
WARNING: 2024-06-05T20:17:40.519 [Information] Host lock lease acquired by instance ID '48dc960434dad156bbc4e40f6f8e23ba'.
WARNING: 2024-06-05T20:17:45.413 [Information] Executing 'Functions.SimpleServiceBusSenderReceiver' (Reason='(null)', Id=6e0d511c-5c6f-442b-9ae9-d2eab7ffe32a)
WARNING: 2024-06-05T20:17:45.413 [Information] Executing 'Functions.SimpleServiceBusSenderReceiver' (Reason='(null)', Id=2f5feebe-3a8e-4e67-8956-9baae0c46987)
2024-06-05T20:17:45.413 [Information] Executing 'Functions.SimpleServiceBusSenderReceiver' (Reason='(null)', Id=d4705cec-b58e-4b69-945c-96ad59e5dbae)
2024-06-05T20:17:45.413 [Information] Executing 'Functions.SimpleServiceBusSenderReceiver' (Reason='(null)', Id=558b0d8e-b2ec-48d8-ae3f-fae965f8674e)
2024-06-05T20:17:45.413 [Information] Executing 'Functions.SimpleServiceBusSenderReceiver' (Reason='(null)', Id=f1624b1d-1042-447e-aa4a-2860d3a00c2c)
2024-06-05T20:17:45.413 [Information] Executing 'Functions.SimpleServiceBusSenderReceiver' (Reason='(null)', Id=8f2565b0-09ac-4b53-972f-ea465c845268)
2024-06-05T20:17:45.414 [Information] Executing 'Functions.SimpleServiceBusSenderReceiver' (Reason='(null)', Id=14388d82-2e80-40fa-bf09-b433890a4aba)
WARNING: 2024-06-05T20:17:45.414 [Information] Executing 'Functions.SimpleServiceBusSenderReceiver' (Reason='(null)', Id=044693b7-33c0-4a8e-8d2b-d414b5fce720)
WARNING: 2024-06-05T20:17:45.414 [Information] Executing 'Functions.SimpleServiceBusSenderReceiver' (Reason='(null)', Id=9b2bb5b4-c618-4db7-9a4e-224e87973279)
WARNING: 2024-06-05T20:17:45.414 [Information] Executing 'Functions.SimpleServiceBusSenderReceiver' (Reason='(null)', Id=9e94e20c-a142-4468-ad57-4dbee2a6f46a)
2024-06-05T20:17:45.417 [Information] Trigger Details: MessageId: f3069b2886b64b69a979a8cbed034857, SequenceNumber: 6, DeliveryCount: 2, EnqueuedTimeUtc: 2024-06-05T20:16:40.2160000+00:00, LockedUntilUtc: 2024-06-05T20:18:45.2800000+00:00, SessionId: (null)
2024-06-05T20:17:45.418 [Information] Trigger Details: MessageId: 011ab8d040964b9d8692799274d204e7, SequenceNumber: 9, DeliveryCount: 2, EnqueuedTimeUtc: 2024-06-05T20:16:42.2010000+00:00, LockedUntilUtc: 2024-06-05T20:18:45.2650000+00:00, SessionId: (null)
2024-06-05T20:17:45.418 [Information] Trigger Details: MessageId: cb42c500c771421f9fa00b8e9eacb82f, SequenceNumber: 13, DeliveryCount: 2, EnqueuedTimeUtc: 2024-06-05T20:16:44.2320000+00:00, LockedUntilUtc: 2024-06-05T20:18:45.2650000+00:00, SessionId: (null)
2024-06-05T20:17:45.418 [Information] Trigger Details: MessageId: 909a5f4048e74eb79e4376d572567353, SequenceNumber: 8, DeliveryCount: 2, EnqueuedTimeUtc: 2024-06-05T20:16:40.2160000+00:00, LockedUntilUtc: 2024-06-05T20:18:45.2800000+00:00, SessionId: (null)
2024-06-05T20:17:45.418 [Information] Trigger Details: MessageId: 565aff3e44ff48c28766eb5eeeec24ce, SequenceNumber: 5, DeliveryCount: 2, EnqueuedTimeUtc: 2024-06-05T20:16:40.2160000+00:00, LockedUntilUtc: 2024-06-05T20:18:45.2650000+00:00, SessionId: (null)
2024-06-05T20:17:45.418 [Information] Trigger Details: MessageId: a90319fe92124910a05446dd6e9041d3, SequenceNumber: 12, DeliveryCount: 2, EnqueuedTimeUtc: 2024-06-05T20:16:42.2010000+00:00, LockedUntilUtc: 2024-06-05T20:18:45.2650000+00:00, SessionId: (null)
2024-06-05T20:17:45.418 [Information] Trigger Details: MessageId: eb7955308e6c483ea6e180e39da173c1, SequenceNumber: 2, DeliveryCount: 2, EnqueuedTimeUtc: 2024-06-05T20:16:38.1070000+00:00, LockedUntilUtc: 2024-06-05T20:18:45.2800000+00:00, SessionId: (null)
WARNING: 2024-06-05T20:17:45.418 [Information] Trigger Details: MessageId: 7cce0ea9604e441788d7f893dd0058dc, SequenceNumber: 15, DeliveryCount: 2, EnqueuedTimeUtc: 2024-06-05T20:16:44.2320000+00:00, LockedUntilUtc: 2024-06-05T20:18:45.2650000+00:00, SessionId: (null)
WARNING: 2024-06-05T20:17:45.418 [Information] Trigger Details: MessageId: 567e260c09434401a81ab485715c9bf7, SequenceNumber: 4, DeliveryCount: 2, EnqueuedTimeUtc: 2024-06-05T20:16:38.1070000+00:00, LockedUntilUtc: 2024-06-05T20:18:45.2800000+00:00, SessionId: (null)
WARNING: 2024-06-05T20:17:45.418 [Information] Trigger Details: MessageId: 9420c51d13b144ed983bbdca761b1ab2, SequenceNumber: 10, DeliveryCount: 2, EnqueuedTimeUtc: 2024-06-05T20:16:42.2010000+00:00, LockedUntilUtc: 2024-06-05T20:18:45.2800000+00:00, SessionId: (null)
WARNING: 2024-06-05T20:17:45.440 [Information] Executing 'Functions.SimpleServiceBusSenderReceiver' (Reason='(null)', Id=0f069007-0e12-41c8-af94-f1a4c180c577)
2024-06-05T20:17:45.440 [Information] Executing 'Functions.SimpleServiceBusSenderReceiver' (Reason='(null)', Id=b097b75f-52aa-42d0-93e5-80bd3390f15c)
2024-06-05T20:17:45.440 [Information] Trigger Details: MessageId: 8419bbfc1da04a56be732c730ffa45aa, SequenceNumber: 14, DeliveryCount: 2, EnqueuedTimeUtc: 2024-06-05T20:16:44.2320000+00:00, LockedUntilUtc: 2024-06-05T20:18:45.2800000+00:00, SessionId: (null)
2024-06-05T20:17:45.440 [Information] Trigger Details: MessageId: 7242a62173f04512b533160ba466a81a, SequenceNumber: 16, DeliveryCount: 2, EnqueuedTimeUtc: 2024-06-05T20:16:44.2320000+00:00, LockedUntilUtc: 2024-06-05T20:18:45.2800000+00:00, SessionId: (null)
WARNING: 2024-06-05T20:17:45.413 [Information] Executing 'Functions.SimpleServiceBusReceiver' (Reason='(null)', Id=7ba544d9-e077-4c75-a3f8-c1f491cac291)
WARNING: 2024-06-05T20:17:45.413 [Information] Executing 'Functions.SimpleServiceBusReceiver' (Reason='(null)', Id=040398c3-9b78-4b92-b5e1-7ced4aa9ecaa)
2024-06-05T20:17:45.414 [Information] Executing 'Functions.SimpleServiceBusReceiver' (Reason='(null)', Id=911e07d0-edfe-4599-99fe-e93754ecad9f)
WARNING: 2024-06-05T20:17:45.417 [Information] Trigger Details: MessageId: ade10a8e06a6472c8e1bca58ae13d0c4, SequenceNumber: 11, DeliveryCount: 2, EnqueuedTimeUtc: 2024-06-05T20:16:42.2010000+00:00, LockedUntilUtc: 2024-06-05T20:18:45.2800000+00:00, SessionId: (null)
WARNING: 2024-06-05T20:17:45.418 [Information] Trigger Details: MessageId: 6481460d80164c02912948ef9f3d28b1, SequenceNumber: 1, DeliveryCount: 2, EnqueuedTimeUtc: 2024-06-05T20:16:38.1070000+00:00, LockedUntilUtc: 2024-06-05T20:18:45.2650000+00:00, SessionId: (null)
2024-06-05T20:17:45.418 [Information] Trigger Details: MessageId: 73c073484cac46d5a7941ce9cc1ecdf5, SequenceNumber: 3, DeliveryCount: 2, EnqueuedTimeUtc: 2024-06-05T20:16:38.1070000+00:00, LockedUntilUtc: 2024-06-05T20:18:45.2800000+00:00, SessionId: (null)
2024-06-05T20:17:45.440 [Information] Executing 'Functions.SimpleServiceBusReceiver' (Reason='(null)', Id=7848e6a7-16bc-4c43-97e9-25852ddb3cee)
2024-06-05T20:17:45.440 [Information] Trigger Details: MessageId: ae9289783ce94244bfd86ed7a3090993, SequenceNumber: 7, DeliveryCount: 2, EnqueuedTimeUtc: 2024-06-05T20:16:40.2160000+00:00, LockedUntilUtc: 2024-06-05T20:18:45.2800000+00:00, SessionId: (null)
WARNING: 2024-06-05T20:17:45.413 [Information] Executing 'Functions.SimpleServiceBusSenderReceiver' (Reason='(null)', Id=6e0d511c-5c6f-442b-9ae9-d2eab7ffe32a)
WARNING: 2024-06-05T20:17:45.413 [Information] Executing 'Functions.SimpleServiceBusReceiver' (Reason='(null)', Id=7ba544d9-e077-4c75-a3f8-c1f491cac291)
2024-06-05T20:17:45.413 [Information] Executing 'Functions.SimpleServiceBusSenderReceiver' (Reason='(null)', Id=2f5feebe-3a8e-4e67-8956-9baae0c46987)
2024-06-05T20:17:45.413 [Information] Executing 'Functions.SimpleServiceBusReceiver' (Reason='(null)', Id=040398c3-9b78-4b92-b5e1-7ced4aa9ecaa)
2024-06-05T20:17:45.413 [Information] Executing 'Functions.SimpleServiceBusSenderReceiver' (Reason='(null)', Id=d4705cec-b58e-4b69-945c-96ad59e5dbae)
2024-06-05T20:17:45.413 [Information] Executing 'Functions.SimpleServiceBusSenderReceiver' (Reason='(null)', Id=558b0d8e-b2ec-48d8-ae3f-fae965f8674e)
2024-06-05T20:17:45.413 [Information] Executing 'Functions.SimpleServiceBusSenderReceiver' (Reason='(null)', Id=f1624b1d-1042-447e-aa4a-2860d3a00c2c)
WARNING: 2024-06-05T20:17:45.413 [Information] Executing 'Functions.SimpleServiceBusSenderReceiver' (Reason='(null)', Id=8f2565b0-09ac-4b53-972f-ea465c845268)
WARNING: 2024-06-05T20:17:45.413 [Information] Executing 'Functions.SimpleServiceBusReceiver' (Reason='(null)', Id=911e07d0-edfe-4599-99fe-e93754ecad9f)
WARNING: 2024-06-05T20:17:45.414 [Information] Executing 'Functions.SimpleServiceBusSenderReceiver' (Reason='(null)', Id=14388d82-2e80-40fa-bf09-b433890a4aba)
WARNING: 2024-06-05T20:17:45.414 [Information] Executing 'Functions.SimpleServiceBusSenderReceiver' (Reason='(null)', Id=044693b7-33c0-4a8e-8d2b-d414b5fce720)
2024-06-05T20:17:45.414 [Information] Executing 'Functions.SimpleServiceBusSenderReceiver' (Reason='(null)', Id=9b2bb5b4-c618-4db7-9a4e-224e87973279)
2024-06-05T20:17:45.414 [Information] Executing 'Functions.SimpleServiceBusSenderReceiver' (Reason='(null)', Id=9e94e20c-a142-4468-ad57-4dbee2a6f46a)
2024-06-05T20:17:45.417 [Information] Trigger Details: MessageId: f3069b2886b64b69a979a8cbed034857, SequenceNumber: 6, DeliveryCount: 2, EnqueuedTimeUtc: 2024-06-05T20:16:40.2160000+00:00, LockedUntilUtc: 2024-06-05T20:18:45.2800000+00:00, SessionId: (null)
2024-06-05T20:17:45.417 [Information] Trigger Details: MessageId: ade10a8e06a6472c8e1bca58ae13d0c4, SequenceNumber: 11, DeliveryCount: 2, EnqueuedTimeUtc: 2024-06-05T20:16:42.2010000+00:00, LockedUntilUtc: 2024-06-05T20:18:45.2800000+00:00, SessionId: (null)
2024-06-05T20:17:45.418 [Information] Trigger Details: MessageId: 6481460d80164c02912948ef9f3d28b1, SequenceNumber: 1, DeliveryCount: 2, EnqueuedTimeUtc: 2024-06-05T20:16:38.1070000+00:00, LockedUntilUtc: 2024-06-05T20:18:45.2650000+00:00, SessionId: (null)
2024-06-05T20:17:45.418 [Information] Trigger Details: MessageId: 011ab8d040964b9d8692799274d204e7, SequenceNumber: 9, DeliveryCount: 2, EnqueuedTimeUtc: 2024-06-05T20:16:42.2010000+00:00, LockedUntilUtc: 2024-06-05T20:18:45.2650000+00:00, SessionId: (null)
2024-06-05T20:17:45.418 [Information] Trigger Details: MessageId: cb42c500c771421f9fa00b8e9eacb82f, SequenceNumber: 13, DeliveryCount: 2, EnqueuedTimeUtc: 2024-06-05T20:16:44.2320000+00:00, LockedUntilUtc: 2024-06-05T20:18:45.2650000+00:00, SessionId: (null)
2024-06-05T20:17:45.418 [Information] Trigger Details: MessageId: 909a5f4048e74eb79e4376d572567353, SequenceNumber: 8, DeliveryCount: 2, EnqueuedTimeUtc: 2024-06-05T20:16:40.2160000+00:00, LockedUntilUtc: 2024-06-05T20:18:45.2800000+00:00, SessionId: (null)
WARNING: 2024-06-05T20:17:45.418 [Information] Trigger Details: MessageId: 565aff3e44ff48c28766eb5eeeec24ce, SequenceNumber: 5, DeliveryCount: 2, EnqueuedTimeUtc: 2024-06-05T20:16:40.2160000+00:00, LockedUntilUtc: 2024-06-05T20:18:45.2650000+00:00, SessionId: (null)
WARNING: 2024-06-05T20:17:45.418 [Information] Trigger Details: MessageId: a90319fe92124910a05446dd6e9041d3, SequenceNumber: 12, DeliveryCount: 2, EnqueuedTimeUtc: 2024-06-05T20:16:42.2010000+00:00, LockedUntilUtc: 2024-06-05T20:18:45.2650000+00:00, SessionId: (null)
WARNING: 2024-06-05T20:17:45.418 [Information] Trigger Details: MessageId: 73c073484cac46d5a7941ce9cc1ecdf5, SequenceNumber: 3, DeliveryCount: 2, EnqueuedTimeUtc: 2024-06-05T20:16:38.1070000+00:00, LockedUntilUtc: 2024-06-05T20:18:45.2800000+00:00, SessionId: (null)
WARNING: 2024-06-05T20:17:45.418 [Information] Trigger Details: MessageId: eb7955308e6c483ea6e180e39da173c1, SequenceNumber: 2, DeliveryCount: 2, EnqueuedTimeUtc: 2024-06-05T20:16:38.1070000+00:00, LockedUntilUtc: 2024-06-05T20:18:45.2800000+00:00, SessionId: (null)
2024-06-05T20:17:45.418 [Information] Trigger Details: MessageId: 7cce0ea9604e441788d7f893dd0058dc, SequenceNumber: 15, DeliveryCount: 2, EnqueuedTimeUtc: 2024-06-05T20:16:44.2320000+00:00, LockedUntilUtc: 2024-06-05T20:18:45.2650000+00:00, SessionId: (null)
2024-06-05T20:17:45.418 [Information] Trigger Details: MessageId: 567e260c09434401a81ab485715c9bf7, SequenceNumber: 4, DeliveryCount: 2, EnqueuedTimeUtc: 2024-06-05T20:16:38.1070000+00:00, LockedUntilUtc: 2024-06-05T20:18:45.2800000+00:00, SessionId: (null)
WARNING: 2024-06-05T20:17:45.418 [Information] Trigger Details: MessageId: 9420c51d13b144ed983bbdca761b1ab2, SequenceNumber: 10, DeliveryCount: 2, EnqueuedTimeUtc: 2024-06-05T20:16:42.2010000+00:00, LockedUntilUtc: 2024-06-05T20:18:45.2800000+00:00, SessionId: (null)
WARNING: 2024-06-05T20:17:45.440 [Information] Executing 'Functions.SimpleServiceBusSenderReceiver' (Reason='(null)', Id=b097b75f-52aa-42d0-93e5-80bd3390f15c)
2024-06-05T20:17:45.440 [Information] Executing 'Functions.SimpleServiceBusSenderReceiver' (Reason='(null)', Id=0f069007-0e12-41c8-af94-f1a4c180c577)
2024-06-05T20:17:45.440 [Information] Trigger Details: MessageId: 8419bbfc1da04a56be732c730ffa45aa, SequenceNumber: 14, DeliveryCount: 2, EnqueuedTimeUtc: 2024-06-05T20:16:44.2320000+00:00, LockedUntilUtc: 2024-06-05T20:18:45.2800000+00:00, SessionId: (null)
2024-06-05T20:17:45.440 [Information] Trigger Details: MessageId: 7242a62173f04512b533160ba466a81a, SequenceNumber: 16, DeliveryCount: 2, EnqueuedTimeUtc: 2024-06-05T20:16:44.2320000+00:00, LockedUntilUtc: 2024-06-05T20:18:45.2800000+00:00, SessionId: (null)
2024-06-05T20:17:45.440 [Information] Executing 'Functions.SimpleServiceBusReceiver' (Reason='(null)', Id=7848e6a7-16bc-4c43-97e9-25852ddb3cee)
2024-06-05T20:17:45.440 [Information] Trigger Details: MessageId: ae9289783ce94244bfd86ed7a3090993, SequenceNumber: 7, DeliveryCount: 2, EnqueuedTimeUtc: 2024-06-05T20:16:40.2160000+00:00, LockedUntilUtc: 2024-06-05T20:18:45.2800000+00:00, SessionId: (null)
WARNING: 2024-06-05T20:17:46.347 [Information] Executing 'Functions.SimpleServiceBusReceiver' (Reason='(null)', Id=276b5c4c-a70b-4795-9bd0-3b8df5eb8145)
WARNING: 2024-06-05T20:17:46.347 [Information] Trigger Details: MessageId: 69573fcca5d04f06b5f6751189ac6548, SequenceNumber: 19, DeliveryCount: 2, EnqueuedTimeUtc: 2024-06-05T20:16:46.4350000+00:00, LockedUntilUtc: 2024-06-05T20:18:46.3580000+00:00, SessionId: (null)
WARNING: 2024-06-05T20:17:46.346 [Information] Executing 'Functions.SimpleServiceBusSenderReceiver' (Reason='(null)', Id=14c3aa92-87f8-4455-8ef6-090230406192)
WARNING: 2024-06-05T20:17:46.346 [Information] Executing 'Functions.SimpleServiceBusSenderReceiver' (Reason='(null)', Id=701a7d52-bb0d-43fe-9267-52a4b6d1c5be)
2024-06-05T20:17:46.347 [Information] Trigger Details: MessageId: 5abf9dded8d04f778007ce1ef4e81063, SequenceNumber: 17, DeliveryCount: 2, EnqueuedTimeUtc: 2024-06-05T20:16:46.4350000+00:00, LockedUntilUtc: 2024-06-05T20:18:46.3580000+00:00, SessionId: (null)
2024-06-05T20:17:46.347 [Information] Trigger Details: MessageId: 1c6e88ea54c249d88f9515f174334e21, SequenceNumber: 18, DeliveryCount: 2, EnqueuedTimeUtc: 2024-06-05T20:16:46.4350000+00:00, LockedUntilUtc: 2024-06-05T20:18:46.3580000+00:00, SessionId: (null)
2024-06-05T20:17:46.347 [Information] Executing 'Functions.SimpleServiceBusSenderReceiver' (Reason='(null)', Id=b5e296ee-13b4-40e0-9bb1-c364492b0887)
2024-06-05T20:17:46.347 [Information] Trigger Details: MessageId: 2f6060c1dd9849d388c3ef93337d1545, SequenceNumber: 20, DeliveryCount: 2, EnqueuedTimeUtc: 2024-06-05T20:16:46.4350000+00:00, LockedUntilUtc: 2024-06-05T20:18:46.3580000+00:00, SessionId: (null)
WARNING: 2024-06-05T20:17:46.346 [Information] Executing 'Functions.SimpleServiceBusSenderReceiver' (Reason='(null)', Id=14c3aa92-87f8-4455-8ef6-090230406192)
WARNING: 2024-06-05T20:17:46.346 [Information] Executing 'Functions.SimpleServiceBusSenderReceiver' (Reason='(null)', Id=701a7d52-bb0d-43fe-9267-52a4b6d1c5be)
2024-06-05T20:17:46.347 [Information] Trigger Details: MessageId: 1c6e88ea54c249d88f9515f174334e21, SequenceNumber: 18, DeliveryCount: 2, EnqueuedTimeUtc: 2024-06-05T20:16:46.4350000+00:00, LockedUntilUtc: 2024-06-05T20:18:46.3580000+00:00, SessionId: (null)
WARNING: 2024-06-05T20:17:46.347 [Information] Trigger Details: MessageId: 5abf9dded8d04f778007ce1ef4e81063, SequenceNumber: 17, DeliveryCount: 2, EnqueuedTimeUtc: 2024-06-05T20:16:46.4350000+00:00, LockedUntilUtc: 2024-06-05T20:18:46.3580000+00:00, SessionId: (null)
WARNING: 2024-06-05T20:17:46.347 [Information] Executing 'Functions.SimpleServiceBusReceiver' (Reason='(null)', Id=276b5c4c-a70b-4795-9bd0-3b8df5eb8145)
2024-06-05T20:17:46.347 [Information] Executing 'Functions.SimpleServiceBusSenderReceiver' (Reason='(null)', Id=b5e296ee-13b4-40e0-9bb1-c364492b0887)
WARNING: 2024-06-05T20:17:46.347 [Information] Trigger Details: MessageId: 2f6060c1dd9849d388c3ef93337d1545, SequenceNumber: 20, DeliveryCount: 2, EnqueuedTimeUtc: 2024-06-05T20:16:46.4350000+00:00, LockedUntilUtc: 2024-06-05T20:18:46.3580000+00:00, SessionId: (null)
WARNING: 2024-06-05T20:17:46.347 [Information] Trigger Details: MessageId: 69573fcca5d04f06b5f6751189ac6548, SequenceNumber: 19, DeliveryCount: 2, EnqueuedTimeUtc: 2024-06-05T20:16:46.4350000+00:00, LockedUntilUtc: 2024-06-05T20:18:46.3580000+00:00, SessionId: (null)
WARNING: 2024-06-05T20:17:46.734 [Error] Unhandled exception. System.IO.FileNotFoundException: Could not load file or assembly 'Microsoft.Extensions.Diagnostics, Version=8.0.0.0, Culture=neutral, PublicKeyToken=adb9793829ddae60'. The system cannot find the file specified.
WARNING: 2024-06-05T20:17:46.735 [Information] File name: 'Microsoft.Extensions.Diagnostics, Version=8.0.0.0, Culture=neutral, PublicKeyToken=adb9793829ddae60'
WARNING: 2024-06-05T20:17:46.735 [Information] at Microsoft.Extensions.Hosting.HostBuilder.PopulateServiceCollection(IServiceCollection services, HostBuilderContext hostBuilderContext, HostingEnvironment hostingEnvironment, PhysicalFileProvider defaultFileProvider, IConfiguration appConfiguration, Func`1 serviceProviderGetter)
WARNING: 2024-06-05T20:17:46.735 [Information] at Microsoft.Extensions.Hosting.HostBuilder.InitializeServiceProvider()
WARNING: 2024-06-05T20:17:46.735 [Information] at Microsoft.Extensions.Hosting.HostBuilder.Build()
2024-06-05T20:17:46.735 [Information] at Program.<Main>$(String[] args) in C:\Users\shein\source\repos\SimplerServiceBusSendReceiveDemo\SimpleServiceBusSendReceiveAzureFuncs\SimpleServiceBusSenderReceiverMainProgram.cs:line 3
2024-06-05T20:17:46.750 [Error] Exceeded language worker restart retry count for runtime:dotnet-isolated. Shutting down and proactively recycling the Functions Host to recover
2024-06-05T20:17:46.808 [Information] Stopping JobHost
2024-06-05T20:17:46.812 [Information] Stopping the listener 'Microsoft.Azure.WebJobs.ServiceBus.Listeners.ServiceBusListener' for function 'SimpleServiceBusReceiver'
2024-06-05T20:17:46.853 [Information] Stopping the listener 'Microsoft.Azure.WebJobs.ServiceBus.Listeners.ServiceBusListener' for function 'SimpleServiceBusSenderReceiver'
WARNING: 2024-06-05T20:17:56.179 [Information] Host lock lease acquired by instance ID '302437db9243b689321142964e6dc164'.
WARNING: 2024-06-05T20:18:02.884 [Error] Unhandled exception. System.IO.FileNotFoundException: Could not load file or assembly 'Microsoft.Extensions.Diagnostics, Version=8.0.0.0, Culture=neutral, PublicKeyToken=adb9793829ddae60'. The system cannot find the file specified.
WARNING: 2024-06-05T20:18:02.884 [Information] File name: 'Microsoft.Extensions.Diagnostics, Version=8.0.0.0, Culture=neutral, PublicKeyToken=adb9793829ddae60'
2024-06-05T20:18:02.884 [Information] at Microsoft.Extensions.Hosting.HostBuilder.PopulateServiceCollection(IServiceCollection services, HostBuilderContext hostBuilderContext, HostingEnvironment hostingEnvironment, PhysicalFileProvider defaultFileProvider, IConfiguration appConfiguration, Func`1 serviceProviderGetter)
2024-06-05T20:18:02.884 [Information] at Microsoft.Extensions.Hosting.HostBuilder.InitializeServiceProvider()
2024-06-05T20:18:02.884 [Information] at Microsoft.Extensions.Hosting.HostBuilder.Build()
2024-06-05T20:18:02.884 [Information] at Program.<Main>$(String[] args) in C:\Users\shein\source\repos\SimplerServiceBusSendReceiveDemo\SimpleServiceBusSendReceiveAzureFuncs\SimpleServiceBusSenderReceiverMainProgram.cs:line 3
2024-06-05T20:18:02.900 [Error] Exceeded language worker restart retry count for runtime:dotnet-isolated. Shutting down and proactively recycling the Functions Host to recover
2024-06-05T20:18:02.946 [Information] Stopping JobHost
2024-06-05T20:18:02.950 [Information] Stopping the listener 'Microsoft.Azure.WebJobs.ServiceBus.Listeners.ServiceBusListener' for function 'SimpleServiceBusReceiver'
2024-06-05T20:18:03.022 [Information] Stopping the listener 'Microsoft.Azure.WebJobs.ServiceBus.Listeners.ServiceBusListener' for function 'SimpleServiceBusSenderReceiver'
2024-06-05T20:18:03.049 [Information] Stopped the listener 'Microsoft.Azure.WebJobs.ServiceBus.Listeners.ServiceBusListener' for function 'SimpleServiceBusReceiver'
WARNING: 2024-06-05T20:18:03.085 [Information] Stopped the listener 'Microsoft.Azure.WebJobs.ServiceBus.Listeners.ServiceBusListener' for function 'SimpleServiceBusSenderReceiver'
WARNING: 2024-06-05T20:18:03.093 [Information] Job host stopped
WARNING: 2024-06-05T20:18:15.016 [Error] Unhandled exception. System.IO.FileNotFoundException: Could not load file or assembly 'Microsoft.Extensions.Diagnostics, Version=8.0.0.0, Culture=neutral, PublicKeyToken=adb9793829ddae60'. The system cannot find the file specified.
WARNING: 2024-06-05T20:18:15.016 [Information] File name: 'Microsoft.Extensions.Diagnostics, Version=8.0.0.0, Culture=neutral, PublicKeyToken=adb9793829ddae60'
2024-06-05T20:18:15.016 [Information] at Microsoft.Extensions.Hosting.HostBuilder.PopulateServiceCollection(IServiceCollection services, HostBuilderContext hostBuilderContext, HostingEnvironment hostingEnvironment, PhysicalFileProvider defaultFileProvider, IConfiguration appConfiguration, Func`1 serviceProviderGetter)
2024-06-05T20:18:15.016 [Information] at Microsoft.Extensions.Hosting.HostBuilder.InitializeServiceProvider()
2024-06-05T20:18:15.016 [Information] at Microsoft.Extensions.Hosting.HostBuilder.Build()
2024-06-05T20:18:15.016 [Information] at Program.<Main>$(String[] args) in C:\Users\shein\source\repos\SimplerServiceBusSendReceiveDemo\SimpleServiceBusSendReceiveAzureFuncs\SimpleServiceBusSenderReceiverMainProgram.cs:line 3
2024-06-05T20:18:15.039 [Information] Host started (866ms)
WARNING: 2024-06-05T20:18:15.039 [Information] Job host started
WARNING: 2024-06-05T20:18:15.040 [Error] The 'SimpleServiceBusReceiver' function is in error: At least one binding must be declared.
WARNING: 2024-06-05T20:18:16.348 [Information] Host lock lease acquired by instance ID '48dc960434dad156bbc4e40f6f8e23ba'.
WARNING: 2024-06-05T20:18:19.171 [Information] Host lock lease acquired by instance ID '302437db9243b689321142964e6dc164'.
WARNING: 2024-06-05T20:18:24.816 [Error] Unhandled exception. System.IO.FileNotFoundException: Could not load file or assembly 'Microsoft.Extensions.Diagnostics, Version=8.0.0.0, Culture=neutral, PublicKeyToken=adb9793829ddae60'. The system cannot find the file specified.
WARNING: 2024-06-05T20:18:24.816 [Information] File name: 'Microsoft.Extensions.Diagnostics, Version=8.0.0.0, Culture=neutral, PublicKeyToken=adb9793829ddae60'
WARNING: 2024-06-05T20:18:24.816 [Information] at Microsoft.Extensions.Hosting.HostBuilder.PopulateServiceCollection(IServiceCollection services, HostBuilderContext hostBuilderContext, HostingEnvironment hostingEnvironment, PhysicalFileProvider defaultFileProvider, IConfiguration appConfiguration, Func`1 serviceProviderGetter)
WARNING: 2024-06-05T20:18:24.816 [Information] at Microsoft.Extensions.Hosting.HostBuilder.InitializeServiceProvider()
2024-06-05T20:18:24.816 [Information] at Microsoft.Extensions.Hosting.HostBuilder.Build()
2024-06-05T20:18:24.816 [Information] at Program.<Main>$(String[] args) in C:\Users\shein\source\repos\SimplerServiceBusSendReceiveDemo\SimpleServiceBusSendReceiveAzureFuncs\SimpleServiceBusSenderReceiverMainProgram.cs:line 3
2024-06-05T20:18:24.831 [Error] Exceeded language worker restart retry count for runtime:dotnet-isolated. Shutting down and proactively recycling the Functions Host to recover
2024-06-05T20:18:24.886 [Information] Stopping JobHost
WARNING: 2024-06-05T20:18:24.890 [Information] Stopping the listener 'Microsoft.Azure.WebJobs.ServiceBus.Listeners.ServiceBusListener' for function 'SimpleServiceBusReceiver'
WARNING: 2024-06-05T20:18:25.011 [Information] Stopping the listener 'Microsoft.Azure.WebJobs.ServiceBus.Listeners.ServiceBusListener' for function 'SimpleServiceBusSenderReceiver'
WARNING: 2024-06-05T20:18:25.046 [Information] Stopped the listener 'Microsoft.Azure.WebJobs.ServiceBus.Listeners.ServiceBusListener' for function 'SimpleServiceBusReceiver'
2024-06-05T20:18:25.103 [Information] Stopped the listener 'Microsoft.Azure.WebJobs.ServiceBus.Listeners.ServiceBusListener' for function 'SimpleServiceBusSenderReceiver'
2024-06-05T20:18:25.111 [Information] Job host stopped
WARNING: 2024-06-05T20:18:25.325 [Error] Unhandled exception. System.IO.FileNotFoundException: Could not load file or assembly 'Microsoft.Extensions.Diagnostics, Version=8.0.0.0, Culture=neutral, PublicKeyToken=adb9793829ddae60'. The system cannot find the file specified.
WARNING: 2024-06-05T20:18:25.325 [Information] File name: 'Microsoft.Extensions.Diagnostics, Version=8.0.0.0, Culture=neutral, PublicKeyToken=adb9793829ddae60'
WARNING: 2024-06-05T20:18:25.325 [Information] at Microsoft.Extensions.Hosting.HostBuilder.PopulateServiceCollection(IServiceCollection services, HostBuilderContext hostBuilderContext, HostingEnvironment hostingEnvironment, PhysicalFileProvider defaultFileProvider, IConfiguration appConfiguration, Func`1 serviceProviderGetter)
2024-06-05T20:18:25.325 [Information] at Microsoft.Extensions.Hosting.HostBuilder.InitializeServiceProvider()
2024-06-05T20:18:25.325 [Information] at Microsoft.Extensions.Hosting.HostBuilder.Build()
2024-06-05T20:18:25.325 [Information] at Program.<Main>$(String[] args) in C:\Users\shein\source\repos\SimplerServiceBusSendReceiveDemo\SimpleServiceBusSendReceiveAzureFuncs\SimpleServiceBusSenderReceiverMainProgram.cs:line 3
WARNING: 2024-06-05T20:18:25.343 [Error] Exceeded language worker restart retry count for runtime:dotnet-isolated. Shutting down and proactively recycling the Functions Host to recover
WARNING: 2024-06-05T20:18:25.392 [Information] Stopping JobHost
2024-06-05T20:18:25.396 [Information] Stopping the listener 'Microsoft.Azure.WebJobs.ServiceBus.Listeners.ServiceBusListener' for function 'SimpleServiceBusReceiver'
2024-06-05T20:18:25.498 [Information] Stopping the listener 'Microsoft.Azure.WebJobs.ServiceBus.Listeners.ServiceBusListener' for function 'SimpleServiceBusSenderReceiver'
2024-06-05T20:18:25.530 [Information] Stopped the listener 'Microsoft.Azure.WebJobs.ServiceBus.Listeners.ServiceBusListener' for function 'SimpleServiceBusReceiver'
2024-06-05T20:18:25.549 [Information] Stopped the listener 'Microsoft.Azure.WebJobs.ServiceBus.Listeners.ServiceBusListener' for function 'SimpleServiceBusSenderReceiver'
WARNING: 2024-06-05T20:18:25.556 [Information] Job host stopped
WARNING: 2024-06-05T20:18:36.798 [Information] Host lock lease acquired by instance ID '48dc960434dad156bbc4e40f6f8e23ba'.
WARNING: 2024-06-05T20:18:40.444 [Information] Host lock lease acquired by instance ID '302437db9243b689321142964e6dc164'.
WARNING: 2024-06-05T20:18:43.946 [Error] Unhandled exception. System.IO.FileNotFoundException: Could not load file or assembly 'Microsoft.Extensions.Diagnostics, Version=8.0.0.0, Culture=neutral, PublicKeyToken=adb9793829ddae60'. The system cannot find the file specified.
WARNING: 2024-06-05T20:18:43.946 [Information] File name: 'Microsoft.Extensions.Diagnostics, Version=8.0.0.0, Culture=neutral, PublicKeyToken=adb9793829ddae60'
2024-06-05T20:18:43.946 [Information] at Microsoft.Extensions.Hosting.HostBuilder.PopulateServiceCollection(IServiceCollection services, HostBuilderContext hostBuilderContext, HostingEnvironment hostingEnvironment, PhysicalFileProvider defaultFileProvider, IConfiguration appConfiguration, Func`1 serviceProviderGetter)
WARNING: 2024-06-05T20:18:43.946 [Information] at Microsoft.Extensions.Hosting.HostBuilder.InitializeServiceProvider()
WARNING: 2024-06-05T20:18:43.946 [Information] at Microsoft.Extensions.Hosting.HostBuilder.Build()
WARNING: 2024-06-05T20:18:43.946 [Information] at Program.<Main>$(String[] args) in C:\Users\shein\source\repos\SimplerServiceBusSendReceiveDemo\SimpleServiceBusSendReceiveAzureFuncs\SimpleServiceBusSenderReceiverMainProgram.cs:line 3
WARNING: 2024-06-05T20:18:43.960 [Error] Exceeded language worker restart retry count for runtime:dotnet-isolated. Shutting down and proactively recycling the Functions Host to recover
WARNING: 2024-06-05T20:18:43.987 [Information] Stopping JobHost
2024-06-05T20:18:43.990 [Information] Stopping the listener 'Microsoft.Azure.WebJobs.ServiceBus.Listeners.ServiceBusListener' for function 'SimpleServiceBusReceiver'
WARNING: 2024-06-05T20:18:44.118 [Information] Stopping the listener 'Microsoft.Azure.WebJobs.ServiceBus.Listeners.ServiceBusListener' for function 'SimpleServiceBusSenderReceiver'
WARNING: 2024-06-05T20:18:44.178 [Information] Stopped the listener 'Microsoft.Azure.WebJobs.ServiceBus.Listeners.ServiceBusListener' for function 'SimpleServiceBusReceiver'
2024-06-05T20:18:44.211 [Information] Stopped the listener 'Microsoft.Azure.WebJobs.ServiceBus.Listeners.ServiceBusListener' for function 'SimpleServiceBusSenderReceiver'
WARNING: 2024-06-05T20:18:44.216 [Information] Job host stopped
WARNING: 2024-06-05T20:18:45.420 [Information] Executing 'Functions.SimpleServiceBusReceiver' (Reason='(null)', Id=b8a323ce-e2df-4b94-8224-fc96339bfc06)
WARNING: 2024-06-05T20:18:45.420 [Information] Executing 'Functions.SimpleServiceBusReceiver' (Reason='(null)', Id=99ed4594-6eb3-4e5b-acc6-077b03802999)
2024-06-05T20:18:45.420 [Information] Executing 'Functions.SimpleServiceBusReceiver' (Reason='(null)', Id=1d6e3f52-c2a0-407e-8f01-0cd4829bac42)
2024-06-05T20:18:45.420 [Information] Executing 'Functions.SimpleServiceBusReceiver' (Reason='(null)', Id=fd0c9f8f-ccef-422f-89b8-6967cae25d45)
2024-06-05T20:18:45.420 [Information] Executing 'Functions.SimpleServiceBusReceiver' (Reason='(null)', Id=7692a908-a96d-464c-8205-aebd04fa7a6b)
2024-06-05T20:18:45.420 [Information] Executing 'Functions.SimpleServiceBusReceiver' (Reason='(null)', Id=b22a76ec-afd7-4ef2-8e4a-9c96435ee940)
2024-06-05T20:18:45.420 [Information] Executing 'Functions.SimpleServiceBusReceiver' (Reason='(null)', Id=5b130b12-98a4-4d73-8447-829278bc37bd)
2024-06-05T20:18:45.420 [Information] Executing 'Functions.SimpleServiceBusReceiver' (Reason='(null)', Id=47f3efa5-de2d-4423-ab8d-7b7ee056154a)
2024-06-05T20:18:45.420 [Information] Executing 'Functions.SimpleServiceBusReceiver' (Reason='(null)', Id=ebb6776e-1e59-495b-b002-9434cd3a13e7)
2024-06-05T20:18:45.420 [Information] Executing 'Functions.SimpleServiceBusReceiver' (Reason='(null)', Id=d48c7413-f233-4ebe-8775-15aacf571b77)
2024-06-05T20:18:45.420 [Information] Executing 'Functions.SimpleServiceBusReceiver' (Reason='(null)', Id=80c2d148-aecd-4c92-a59d-d43de111b995)
2024-06-05T20:18:45.423 [Information] Trigger Details: MessageId: 011ab8d040964b9d8692799274d204e7, SequenceNumber: 9, DeliveryCount: 3, EnqueuedTimeUtc: 2024-06-05T20:16:42.2010000+00:00, LockedUntilUtc: 2024-06-05T20:19:45.2520000+00:00, SessionId: (null)
2024-06-05T20:18:45.423 [Information] Trigger Details: MessageId: 909a5f4048e74eb79e4376d572567353, SequenceNumber: 8, DeliveryCount: 3, EnqueuedTimeUtc: 2024-06-05T20:16:40.2160000+00:00, LockedUntilUtc: 2024-06-05T20:19:45.2680000+00:00, SessionId: (null)
2024-06-05T20:18:45.423 [Information] Trigger Details: MessageId: ade10a8e06a6472c8e1bca58ae13d0c4, SequenceNumber: 11, DeliveryCount: 3, EnqueuedTimeUtc: 2024-06-05T20:16:42.2010000+00:00, LockedUntilUtc: 2024-06-05T20:19:45.2520000+00:00, SessionId: (null)
2024-06-05T20:18:45.423 [Information] Trigger Details: MessageId: 73c073484cac46d5a7941ce9cc1ecdf5, SequenceNumber: 3, DeliveryCount: 3, EnqueuedTimeUtc: 2024-06-05T20:16:38.1070000+00:00, LockedUntilUtc: 2024-06-05T20:19:45.2680000+00:00, SessionId: (null)
2024-06-05T20:18:45.423 [Information] Trigger Details: MessageId: 567e260c09434401a81ab485715c9bf7, SequenceNumber: 4, DeliveryCount: 3, EnqueuedTimeUtc: 2024-06-05T20:16:38.1070000+00:00, LockedUntilUtc: 2024-06-05T20:19:45.2680000+00:00, SessionId: (null)
WARNING: 2024-06-05T20:18:45.423 [Information] Trigger Details: MessageId: f3069b2886b64b69a979a8cbed034857, SequenceNumber: 6, DeliveryCount: 3, EnqueuedTimeUtc: 2024-06-05T20:16:40.2160000+00:00, LockedUntilUtc: 2024-06-05T20:19:45.2680000+00:00, SessionId: (null)
WARNING: 2024-06-05T20:18:45.424 [Information] Trigger Details: MessageId: eb7955308e6c483ea6e180e39da173c1, SequenceNumber: 2, DeliveryCount: 3, EnqueuedTimeUtc: 2024-06-05T20:16:38.1070000+00:00, LockedUntilUtc: 2024-06-05T20:19:45.2680000+00:00, SessionId: (null)
2024-06-05T20:18:45.424 [Information] Trigger Details: MessageId: 7cce0ea9604e441788d7f893dd0058dc, SequenceNumber: 15, DeliveryCount: 3, EnqueuedTimeUtc: 2024-06-05T20:16:44.2320000+00:00, LockedUntilUtc: 2024-06-05T20:19:45.2680000+00:00, SessionId: (null)
2024-06-05T20:18:45.424 [Information] Trigger Details: MessageId: 565aff3e44ff48c28766eb5eeeec24ce, SequenceNumber: 5, DeliveryCount: 3, EnqueuedTimeUtc: 2024-06-05T20:16:40.2160000+00:00, LockedUntilUtc: 2024-06-05T20:19:45.2680000+00:00, SessionId: (null)
2024-06-05T20:18:45.424 [Information] Trigger Details: MessageId: a90319fe92124910a05446dd6e9041d3, SequenceNumber: 12, DeliveryCount: 3, EnqueuedTimeUtc: 2024-06-05T20:16:42.2010000+00:00, LockedUntilUtc: 2024-06-05T20:19:45.2680000+00:00, SessionId: (null)
2024-06-05T20:18:45.424 [Information] Trigger Details: MessageId: ae9289783ce94244bfd86ed7a3090993, SequenceNumber: 7, DeliveryCount: 3, EnqueuedTimeUtc: 2024-06-05T20:16:40.2160000+00:00, LockedUntilUtc: 2024-06-05T20:19:45.2680000+00:00, SessionId: (null)
2024-06-05T20:18:45.460 [Information] Executing 'Functions.SimpleServiceBusReceiver' (Reason='(null)', Id=3e272b32-f651-4575-b8ed-4614dcd0d8e9)
WARNING: 2024-06-05T20:18:45.460 [Information] Executing 'Functions.SimpleServiceBusReceiver' (Reason='(null)', Id=ed01de45-b21f-4246-b56c-b158153b2878)
WARNING: 2024-06-05T20:18:45.460 [Information] Trigger Details: MessageId: 6481460d80164c02912948ef9f3d28b1, SequenceNumber: 1, DeliveryCount: 3, EnqueuedTimeUtc: 2024-06-05T20:16:38.1070000+00:00, LockedUntilUtc: 2024-06-05T20:19:45.2680000+00:00, SessionId: (null)
2024-06-05T20:18:45.460 [Information] Executing 'Functions.SimpleServiceBusReceiver' (Reason='(null)', Id=1ec043a0-21bc-4cc7-881d-8f7c878165f8)
2024-06-05T20:18:45.460 [Information] Trigger Details: MessageId: 9420c51d13b144ed983bbdca761b1ab2, SequenceNumber: 10, DeliveryCount: 3, EnqueuedTimeUtc: 2024-06-05T20:16:42.2010000+00:00, LockedUntilUtc: 2024-06-05T20:19:45.2680000+00:00, SessionId: (null)
2024-06-05T20:18:45.460 [Information] Executing 'Functions.SimpleServiceBusReceiver' (Reason='(null)', Id=32a0b599-10ae-4221-b79c-31a85e9bd38d)
2024-06-05T20:18:45.460 [Information] Trigger Details: MessageId: 8419bbfc1da04a56be732c730ffa45aa, SequenceNumber: 14, DeliveryCount: 3, EnqueuedTimeUtc: 2024-06-05T20:16:44.2320000+00:00, LockedUntilUtc: 2024-06-05T20:19:45.2680000+00:00, SessionId: (null)
2024-06-05T20:18:45.461 [Information] Trigger Details: MessageId: 7242a62173f04512b533160ba466a81a, SequenceNumber: 16, DeliveryCount: 3, EnqueuedTimeUtc: 2024-06-05T20:16:44.2320000+00:00, LockedUntilUtc: 2024-06-05T20:19:45.2680000+00:00, SessionId: (null)
WARNING: 2024-06-05T20:18:45.420 [Information] Executing 'Functions.SimpleServiceBusSenderReceiver' (Reason='(null)', Id=a5268d38-8270-45ba-a76b-d501c95c878e)
WARNING: 2024-06-05T20:18:45.424 [Information] Trigger Details: MessageId: cb42c500c771421f9fa00b8e9eacb82f, SequenceNumber: 13, DeliveryCount: 3, EnqueuedTimeUtc: 2024-06-05T20:16:44.2320000+00:00, LockedUntilUtc: 2024-06-05T20:19:45.2680000+00:00, SessionId: (null)
WARNING: 2024-06-05T20:18:45.420 [Information] Executing 'Functions.SimpleServiceBusReceiver' (Reason='(null)', Id=b8a323ce-e2df-4b94-8224-fc96339bfc06)
WARNING: 2024-06-05T20:18:45.420 [Information] Executing 'Functions.SimpleServiceBusReceiver' (Reason='(null)', Id=99ed4594-6eb3-4e5b-acc6-077b03802999)
2024-06-05T20:18:45.420 [Information] Executing 'Functions.SimpleServiceBusReceiver' (Reason='(null)', Id=1d6e3f52-c2a0-407e-8f01-0cd4829bac42)
2024-06-05T20:18:45.420 [Information] Executing 'Functions.SimpleServiceBusReceiver' (Reason='(null)', Id=fd0c9f8f-ccef-422f-89b8-6967cae25d45)
2024-06-05T20:18:45.420 [Information] Executing 'Functions.SimpleServiceBusReceiver' (Reason='(null)', Id=7692a908-a96d-464c-8205-aebd04fa7a6b)
2024-06-05T20:18:45.420 [Information] Executing 'Functions.SimpleServiceBusReceiver' (Reason='(null)', Id=b22a76ec-afd7-4ef2-8e4a-9c96435ee940)
2024-06-05T20:18:45.420 [Information] Executing 'Functions.SimpleServiceBusReceiver' (Reason='(null)', Id=5b130b12-98a4-4d73-8447-829278bc37bd)
WARNING: 2024-06-05T20:18:45.420 [Information] Executing 'Functions.SimpleServiceBusSenderReceiver' (Reason='(null)', Id=a5268d38-8270-45ba-a76b-d501c95c878e)
WARNING: 2024-06-05T20:18:45.420 [Information] Executing 'Functions.SimpleServiceBusReceiver' (Reason='(null)', Id=47f3efa5-de2d-4423-ab8d-7b7ee056154a)
2024-06-05T20:18:45.420 [Information] Executing 'Functions.SimpleServiceBusReceiver' (Reason='(null)', Id=ebb6776e-1e59-495b-b002-9434cd3a13e7)
2024-06-05T20:18:45.420 [Information] Executing 'Functions.SimpleServiceBusReceiver' (Reason='(null)', Id=d48c7413-f233-4ebe-8775-15aacf571b77)
2024-06-05T20:18:45.420 [Information] Executing 'Functions.SimpleServiceBusReceiver' (Reason='(null)', Id=80c2d148-aecd-4c92-a59d-d43de111b995)
2024-06-05T20:18:45.423 [Information] Trigger Details: MessageId: 011ab8d040964b9d8692799274d204e7, SequenceNumber: 9, DeliveryCount: 3, EnqueuedTimeUtc: 2024-06-05T20:16:42.2010000+00:00, LockedUntilUtc: 2024-06-05T20:19:45.2520000+00:00, SessionId: (null)
2024-06-05T20:18:45.423 [Information] Trigger Details: MessageId: 909a5f4048e74eb79e4376d572567353, SequenceNumber: 8, DeliveryCount: 3, EnqueuedTimeUtc: 2024-06-05T20:16:40.2160000+00:00, LockedUntilUtc: 2024-06-05T20:19:45.2680000+00:00, SessionId: (null)
WARNING: 2024-06-05T20:18:45.423 [Information] Trigger Details: MessageId: ade10a8e06a6472c8e1bca58ae13d0c4, SequenceNumber: 11, DeliveryCount: 3, EnqueuedTimeUtc: 2024-06-05T20:16:42.2010000+00:00, LockedUntilUtc: 2024-06-05T20:19:45.2520000+00:00, SessionId: (null)
WARNING: 2024-06-05T20:18:45.423 [Information] Trigger Details: MessageId: 73c073484cac46d5a7941ce9cc1ecdf5, SequenceNumber: 3, DeliveryCount: 3, EnqueuedTimeUtc: 2024-06-05T20:16:38.1070000+00:00, LockedUntilUtc: 2024-06-05T20:19:45.2680000+00:00, SessionId: (null)
2024-06-05T20:18:45.423 [Information] Trigger Details: MessageId: 567e260c09434401a81ab485715c9bf7, SequenceNumber: 4, DeliveryCount: 3, EnqueuedTimeUtc: 2024-06-05T20:16:38.1070000+00:00, LockedUntilUtc: 2024-06-05T20:19:45.2680000+00:00, SessionId: (null)
2024-06-05T20:18:45.423 [Information] Trigger Details: MessageId: f3069b2886b64b69a979a8cbed034857, SequenceNumber: 6, DeliveryCount: 3, EnqueuedTimeUtc: 2024-06-05T20:16:40.2160000+00:00, LockedUntilUtc: 2024-06-05T20:19:45.2680000+00:00, SessionId: (null)
2024-06-05T20:18:45.424 [Information] Trigger Details: MessageId: eb7955308e6c483ea6e180e39da173c1, SequenceNumber: 2, DeliveryCount: 3, EnqueuedTimeUtc: 2024-06-05T20:16:38.1070000+00:00, LockedUntilUtc: 2024-06-05T20:19:45.2680000+00:00, SessionId: (null)
2024-06-05T20:18:45.424 [Information] Trigger Details: MessageId: cb42c500c771421f9fa00b8e9eacb82f, SequenceNumber: 13, DeliveryCount: 3, EnqueuedTimeUtc: 2024-06-05T20:16:44.2320000+00:00, LockedUntilUtc: 2024-06-05T20:19:45.2680000+00:00, SessionId: (null)
WARNING: 2024-06-05T20:18:45.424 [Information] Trigger Details: MessageId: 7cce0ea9604e441788d7f893dd0058dc, SequenceNumber: 15, DeliveryCount: 3, EnqueuedTimeUtc: 2024-06-05T20:16:44.2320000+00:00, LockedUntilUtc: 2024-06-05T20:19:45.2680000+00:00, SessionId: (null)
WARNING: 2024-06-05T20:18:45.424 [Information] Trigger Details: MessageId: 565aff3e44ff48c28766eb5eeeec24ce, SequenceNumber: 5, DeliveryCount: 3, EnqueuedTimeUtc: 2024-06-05T20:16:40.2160000+00:00, LockedUntilUtc: 2024-06-05T20:19:45.2680000+00:00, SessionId: (null)
2024-06-05T20:18:45.424 [Information] Trigger Details: MessageId: a90319fe92124910a05446dd6e9041d3, SequenceNumber: 12, DeliveryCount: 3, EnqueuedTimeUtc: 2024-06-05T20:16:42.2010000+00:00, LockedUntilUtc: 2024-06-05T20:19:45.2680000+00:00, SessionId: (null)
2024-06-05T20:18:45.424 [Information] Trigger Details: MessageId: ae9289783ce94244bfd86ed7a3090993, SequenceNumber: 7, DeliveryCount: 3, EnqueuedTimeUtc: 2024-06-05T20:16:40.2160000+00:00, LockedUntilUtc: 2024-06-05T20:19:45.2680000+00:00, SessionId: (null)
2024-06-05T20:18:45.460 [Information] Executing 'Functions.SimpleServiceBusReceiver' (Reason='(null)', Id=ed01de45-b21f-4246-b56c-b158153b2878)
2024-06-05T20:18:45.460 [Information] Executing 'Functions.SimpleServiceBusReceiver' (Reason='(null)', Id=3e272b32-f651-4575-b8ed-4614dcd0d8e9)
2024-06-05T20:18:45.460 [Information] Trigger Details: MessageId: 6481460d80164c02912948ef9f3d28b1, SequenceNumber: 1, DeliveryCount: 3, EnqueuedTimeUtc: 2024-06-05T20:16:38.1070000+00:00, LockedUntilUtc: 2024-06-05T20:19:45.2680000+00:00, SessionId: (null)
2024-06-05T20:18:45.460 [Information] Executing 'Functions.SimpleServiceBusReceiver' (Reason='(null)', Id=1ec043a0-21bc-4cc7-881d-8f7c878165f8)
2024-06-05T20:18:45.460 [Information] Trigger Details: MessageId: 9420c51d13b144ed983bbdca761b1ab2, SequenceNumber: 10, DeliveryCount: 3, EnqueuedTimeUtc: 2024-06-05T20:16:42.2010000+00:00, LockedUntilUtc: 2024-06-05T20:19:45.2680000+00:00, SessionId: (null)
2024-06-05T20:18:45.460 [Information] Executing 'Functions.SimpleServiceBusReceiver' (Reason='(null)', Id=32a0b599-10ae-4221-b79c-31a85e9bd38d)
2024-06-05T20:18:45.460 [Information] Trigger Details: MessageId: 8419bbfc1da04a56be732c730ffa45aa, SequenceNumber: 14, DeliveryCount: 3, EnqueuedTimeUtc: 2024-06-05T20:16:44.2320000+00:00, LockedUntilUtc: 2024-06-05T20:19:45.2680000+00:00, SessionId: (null)
2024-06-05T20:18:45.461 [Information] Trigger Details: MessageId: 7242a62173f04512b533160ba466a81a, SequenceNumber: 16, DeliveryCount: 3, EnqueuedTimeUtc: 2024-06-05T20:16:44.2320000+00:00, LockedUntilUtc: 2024-06-05T20:19:45.2680000+00:00, SessionId: (null)
WARNING: 2024-06-05T20:18:46.422 [Information] Executing 'Functions.SimpleServiceBusReceiver' (Reason='(null)', Id=1c33fbf3-4504-41e6-a1eb-05ad4ca9aa8e)
WARNING: 2024-06-05T20:18:46.422 [Information] Trigger Details: MessageId: 1c6e88ea54c249d88f9515f174334e21, SequenceNumber: 18, DeliveryCount: 3, EnqueuedTimeUtc: 2024-06-05T20:16:46.4350000+00:00, LockedUntilUtc: 2024-06-05T20:19:46.3460000+00:00, SessionId: (null)
WARNING: 2024-06-05T20:18:46.424 [Information] Executing 'Functions.SimpleServiceBusSenderReceiver' (Reason='(null)', Id=36e9b51c-7741-4ac3-bbc4-3bbaa07957dd)
WARNING: 2024-06-05T20:18:46.424 [Information] Trigger Details: MessageId: 2f6060c1dd9849d388c3ef93337d1545, SequenceNumber: 20, DeliveryCount: 3, EnqueuedTimeUtc: 2024-06-05T20:16:46.4350000+00:00, LockedUntilUtc: 2024-06-05T20:19:46.3460000+00:00, SessionId: (null)
2024-06-05T20:18:46.426 [Information] Executing 'Functions.SimpleServiceBusSenderReceiver' (Reason='(null)', Id=bec585a9-5b40-4482-8958-fb88fc95754c)
2024-06-05T20:18:46.426 [Information] Trigger Details: MessageId: 69573fcca5d04f06b5f6751189ac6548, SequenceNumber: 19, DeliveryCount: 3, EnqueuedTimeUtc: 2024-06-05T20:16:46.4350000+00:00, LockedUntilUtc: 2024-06-05T20:19:46.3460000+00:00, SessionId: (null)
2024-06-05T20:18:46.426 [Information] Executing 'Functions.SimpleServiceBusSenderReceiver' (Reason='(null)', Id=8bf25c93-bee7-463d-8b28-e16eaef5278c)
2024-06-05T20:18:46.426 [Information] Trigger Details: MessageId: 5abf9dded8d04f778007ce1ef4e81063, SequenceNumber: 17, DeliveryCount: 3, EnqueuedTimeUtc: 2024-06-05T20:16:46.4350000+00:00, LockedUntilUtc: 2024-06-05T20:19:46.3620000+00:00, SessionId: (null)
WARNING: 2024-06-05T20:18:46.422 [Information] Executing 'Functions.SimpleServiceBusReceiver' (Reason='(null)', Id=1c33fbf3-4504-41e6-a1eb-05ad4ca9aa8e)
WARNING: 2024-06-05T20:18:46.422 [Information] Trigger Details: MessageId: 1c6e88ea54c249d88f9515f174334e21, SequenceNumber: 18, DeliveryCount: 3, EnqueuedTimeUtc: 2024-06-05T20:16:46.4350000+00:00, LockedUntilUtc: 2024-06-05T20:19:46.3460000+00:00, SessionId: (null)
WARNING: 2024-06-05T20:18:46.424 [Information] Executing 'Functions.SimpleServiceBusSenderReceiver' (Reason='(null)', Id=36e9b51c-7741-4ac3-bbc4-3bbaa07957dd)
WARNING: 2024-06-05T20:18:46.424 [Information] Trigger Details: MessageId: 2f6060c1dd9849d388c3ef93337d1545, SequenceNumber: 20, DeliveryCount: 3, EnqueuedTimeUtc: 2024-06-05T20:16:46.4350000+00:00, LockedUntilUtc: 2024-06-05T20:19:46.3460000+00:00, SessionId: (null)
2024-06-05T20:18:46.426 [Information] Executing 'Functions.SimpleServiceBusSenderReceiver' (Reason='(null)', Id=bec585a9-5b40-4482-8958-fb88fc95754c)
2024-06-05T20:18:46.426 [Information] Trigger Details: MessageId: 69573fcca5d04f06b5f6751189ac6548, SequenceNumber: 19, DeliveryCount: 3, EnqueuedTimeUtc: 2024-06-05T20:16:46.4350000+00:00, LockedUntilUtc: 2024-06-05T20:19:46.3460000+00:00, SessionId: (null)
WARNING: 2024-06-05T20:18:46.426 [Information] Executing 'Functions.SimpleServiceBusSenderReceiver' (Reason='(null)', Id=8bf25c93-bee7-463d-8b28-e16eaef5278c)
WARNING: 2024-06-05T20:18:46.426 [Information] Trigger Details: MessageId: 5abf9dded8d04f778007ce1ef4e81063, SequenceNumber: 17, DeliveryCount: 3, EnqueuedTimeUtc: 2024-06-05T20:16:46.4350000+00:00, LockedUntilUtc: 2024-06-05T20:19:46.3620000+00:00, SessionId: (null)
WARNING: 2024-06-05T20:18:46.693 [Error] Unhandled exception. System.IO.FileNotFoundException: Could not load file or assembly 'Microsoft.Extensions.Diagnostics, Version=8.0.0.0, Culture=neutral, PublicKeyToken=adb9793829ddae60'. The system cannot find the file specified.
WARNING: 2024-06-05T20:18:46.693 [Information] File name: 'Microsoft.Extensions.Diagnostics, Version=8.0.0.0, Culture=neutral, PublicKeyToken=adb9793829ddae60'
WARNING: 2024-06-05T20:18:46.693 [Information] at Microsoft.Extensions.Hosting.HostBuilder.PopulateServiceCollection(IServiceCollection services, HostBuilderContext hostBuilderContext, HostingEnvironment hostingEnvironment, PhysicalFileProvider defaultFileProvider, IConfiguration appConfiguration, Func`1 serviceProviderGetter)
WARNING: 2024-06-05T20:18:46.693 [Information] at Microsoft.Extensions.Hosting.HostBuilder.InitializeServiceProvider()
2024-06-05T20:18:46.693 [Information] at Microsoft.Extensions.Hosting.HostBuilder.Build()
2024-06-05T20:18:46.693 [Information] at Program.<Main>$(String[] args) in C:\Users\shein\source\repos\SimplerServiceBusSendReceiveDemo\SimpleServiceBusSendReceiveAzureFuncs\SimpleServiceBusSenderReceiverMainProgram.cs:line 3
WARNING: 2024-06-05T20:18:46.709 [Error] Exceeded language worker restart retry count for runtime:dotnet-isolated. Shutting down and proactively recycling the Functions Host to recover
WARNING: 2024-06-05T20:18:46.771 [Information] Stopping JobHost
WARNING: 2024-06-05T20:18:46.774 [Information] Stopping the listener 'Microsoft.Azure.WebJobs.ServiceBus.Listeners.ServiceBusListener' for function 'SimpleServiceBusReceiver'
WARNING: 2024-06-05T20:18:46.799 [Information] Stopping the listener 'Microsoft.Azure.WebJobs.ServiceBus.Listeners.ServiceBusListener' for function 'SimpleServiceBusSenderReceiver'
WARNING: 2024-06-05T20:18:57.780 [Information] Host lock lease acquired by instance ID '48dc960434dad156bbc4e40f6f8e23ba'.
WARNING: 2024-06-05T20:19:04.543 [Error] Unhandled exception. System.IO.FileNotFoundException: Could not load file or assembly 'Microsoft.Extensions.Diagnostics, Version=8.0.0.0, Culture=neutral, PublicKeyToken=adb9793829ddae60'. The system cannot find the file specified.
WARNING: 2024-06-05T20:19:04.543 [Information] File name: 'Microsoft.Extensions.Diagnostics, Version=8.0.0.0, Culture=neutral, PublicKeyToken=adb9793829ddae60'
2024-06-05T20:19:04.543 [Information] at Microsoft.Extensions.Hosting.HostBuilder.PopulateServiceCollection(IServiceCollection services, HostBuilderContext hostBuilderContext, HostingEnvironment hostingEnvironment, PhysicalFileProvider defaultFileProvider, IConfiguration appConfiguration, Func`1 serviceProviderGetter)
2024-06-05T20:19:04.543 [Information] at Microsoft.Extensions.Hosting.HostBuilder.InitializeServiceProvider()
2024-06-05T20:19:04.543 [Information] at Microsoft.Extensions.Hosting.HostBuilder.Build()
2024-06-05T20:19:04.543 [Information] at Program.<Main>$(String[] args) in C:\Users\shein\source\repos\SimplerServiceBusSendReceiveDemo\SimpleServiceBusSendReceiveAzureFuncs\SimpleServiceBusSenderReceiverMainProgram.cs:line 3
2024-06-05T20:19:04.562 [Error] Exceeded language worker restart retry count for runtime:dotnet-isolated. Shutting down and proactively recycling the Functions Host to recover
2024-06-05T20:19:04.623 [Information] Stopping JobHost
2024-06-05T20:19:04.628 [Information] Stopping the listener 'Microsoft.Azure.WebJobs.ServiceBus.Listeners.ServiceBusListener' for function 'SimpleServiceBusReceiver'
2024-06-05T20:19:04.731 [Information] Stopping the listener 'Microsoft.Azure.WebJobs.ServiceBus.Listeners.ServiceBusListener' for function 'SimpleServiceBusSenderReceiver'
2024-06-05T20:19:04.772 [Information] Stopped the listener 'Microsoft.Azure.WebJobs.ServiceBus.Listeners.ServiceBusListener' for function 'SimpleServiceBusReceiver'
2024-06-05T20:19:04.794 [Information] Stopped the listener 'Microsoft.Azure.WebJobs.ServiceBus.Listeners.ServiceBusListener' for function 'SimpleServiceBusSenderReceiver'
2024-06-05T20:19:04.800 [Information] Job host stopped
WARNING: 2024-06-05T20:19:15.658 [Information] Host started (1225ms)
WARNING: 2024-06-05T20:19:15.659 [Information] Job host started
WARNING: 2024-06-05T20:19:15.660 [Error] The 'SimpleServiceBusReceiver' function is in error: At least one binding must be declared.
WARNING: 2024-06-05T20:19:16.339 [Error] Unhandled exception. System.IO.FileNotFoundException: Could not load file or assembly 'Microsoft.Extensions.Diagnostics, Version=8.0.0.0, Culture=neutral, PublicKeyToken=adb9793829ddae60'. The system cannot find the file specified.
2024-06-05T20:19:16.339 [Information] File name: 'Microsoft.Extensions.Diagnostics, Version=8.0.0.0, Culture=neutral, PublicKeyToken=adb9793829ddae60'
2024-06-05T20:19:16.339 [Information] at Microsoft.Extensions.Hosting.HostBuilder.PopulateServiceCollection(IServiceCollection services, HostBuilderContext hostBuilderContext, HostingEnvironment hostingEnvironment, PhysicalFileProvider defaultFileProvider, IConfiguration appConfiguration, Func`1 serviceProviderGetter)
2024-06-05T20:19:16.339 [Information] at Microsoft.Extensions.Hosting.HostBuilder.InitializeServiceProvider()
2024-06-05T20:19:16.339 [Information] at Microsoft.Extensions.Hosting.HostBuilder.Build()
2024-06-05T20:19:16.339 [Information] at Program.<Main>$(String[] args) in C:\Users\shein\source\repos\SimplerServiceBusSendReceiveDemo\SimpleServiceBusSendReceiveAzureFuncs\SimpleServiceBusSenderReceiverMainProgram.cs:line 3
WARNING: 2024-06-05T20:19:16.367 [Error] Failed to start a new language worker for runtime: dotnet-isolated.
WARNING: System.Threading.Tasks.TaskCanceledException : A task was canceled.
   at async Microsoft.Azure.WebJobs.Script.Grpc.GrpcWorkerChannel.StartWorkerProcessAsync(CancellationToken cancellationToken) at /_/src/WebJobs.Script.Grpc/Channel/GrpcWorkerChannel.cs : 377
   at System.Runtime.ExceptionServices.ExceptionDispatchInfo.Throw()
   at async Microsoft.Azure.WebJobs.Script.Workers.Rpc.RpcFunctionInvocationDispatcher.InitializeJobhostLanguageWorkerChannelAsync(??) at /_/src/WebJobs.Script/Workers/Rpc/FunctionRegistration/RpcFunctionInvocationDispatcher.cs : 156
   at System.Runtime.ExceptionServices.ExceptionDispatchInfo.Throw()
   at async Microsoft.Azure.WebJobs.Script.Workers.Rpc.RpcFunctionInvocationDispatcher.InitializeJobhostLanguageWorkerChannelAsync(??) at /_/src/WebJobs.Script/Workers/Rpc/FunctionRegistration/RpcFunctionInvocationDispatcher.cs : 148
   at System.Runtime.ExceptionServices.ExceptionDispatchInfo.Throw()
WARNING:    at async Microsoft.Azure.WebJobs.Script.Workers.Rpc.RpcFunctionInvocationDispatcher.InitializeJobhostLanguageWorkerChannelAsync(??) at /_/src/WebJobs.Script/Workers/Rpc/FunctionRegistration/RpcFunctionInvocationDispatcher.cs : 139
WARNING:    at System.Runtime.ExceptionServices.ExceptionDispatchInfo.Throw()
   at async Microsoft.Azure.WebJobs.Script.Workers.Rpc.RpcFunctionInvocationDispatcher.<>c__DisplayClass56_0.<StartWorkerProcesses>b__0(??) at /_/src/WebJobs.Script/Workers/Rpc/FunctionRegistration/RpcFunctionInvocationDispatcher.cs : 219
2024-06-05T20:19:16.489 [Error] Unhandled exception. System.IO.FileNotFoundException: Could not load file or assembly 'Microsoft.Extensions.Diagnostics, Version=8.0.0.0, Culture=neutral, PublicKeyToken=adb9793829ddae60'. The system cannot find the file specified.
2024-06-05T20:19:16.489 [Information] File name: 'Microsoft.Extensions.Diagnostics, Version=8.0.0.0, Culture=neutral, PublicKeyToken=adb9793829ddae60'
2024-06-05T20:19:16.489 [Information] at Microsoft.Extensions.Hosting.HostBuilder.PopulateServiceCollection(IServiceCollection services, HostBuilderContext hostBuilderContext, HostingEnvironment hostingEnvironment, PhysicalFileProvider defaultFileProvider, IConfiguration appConfiguration, Func`1 serviceProviderGetter)
2024-06-05T20:19:16.489 [Information] at Microsoft.Extensions.Hosting.HostBuilder.InitializeServiceProvider()
2024-06-05T20:19:16.489 [Information] at Microsoft.Extensions.Hosting.HostBuilder.Build()
2024-06-05T20:19:16.489 [Information] at Program.<Main>$(String[] args) in C:\Users\shein\source\repos\SimplerServiceBusSendReceiveDemo\SimpleServiceBusSendReceiveAzureFuncs\SimpleServiceBusSenderReceiverMainProgram.cs:line 3
WARNING: 2024-06-05T20:19:18.262 [Information] Host lock lease acquired by instance ID '48dc960434dad156bbc4e40f6f8e23ba'.
WARNING: 2024-06-05T20:19:19.414 [Information] Host lock lease acquired by instance ID '302437db9243b689321142964e6dc164'.
WARNING: 2024-06-05T20:19:24.715 [Error] Unhandled exception. System.IO.FileNotFoundException: Could not load file or assembly 'Microsoft.Extensions.Diagnostics, Version=8.0.0.0, Culture=neutral, PublicKeyToken=adb9793829ddae60'. The system cannot find the file specified.
WARNING: 2024-06-05T20:19:24.716 [Information] File name: 'Microsoft.Extensions.Diagnostics, Version=8.0.0.0, Culture=neutral, PublicKeyToken=adb9793829ddae60'
2024-06-05T20:19:24.716 [Information] at Microsoft.Extensions.Hosting.HostBuilder.PopulateServiceCollection(IServiceCollection services, HostBuilderContext hostBuilderContext, HostingEnvironment hostingEnvironment, PhysicalFileProvider defaultFileProvider, IConfiguration appConfiguration, Func`1 serviceProviderGetter)
2024-06-05T20:19:24.716 [Information] at Microsoft.Extensions.Hosting.HostBuilder.InitializeServiceProvider()
2024-06-05T20:19:24.716 [Information] at Microsoft.Extensions.Hosting.HostBuilder.Build()
2024-06-05T20:19:24.716 [Information] at Program.<Main>$(String[] args) in C:\Users\shein\source\repos\SimplerServiceBusSendReceiveDemo\SimpleServiceBusSendReceiveAzureFuncs\SimpleServiceBusSenderReceiverMainProgram.cs:line 3
2024-06-05T20:19:24.728 [Error] Exceeded language worker restart retry count for runtime:dotnet-isolated. Shutting down and proactively recycling the Functions Host to recover
WARNING: 2024-06-05T20:19:24.789 [Information] Stopping JobHost
WARNING: 2024-06-05T20:19:24.794 [Information] Stopping the listener 'Microsoft.Azure.WebJobs.ServiceBus.Listeners.ServiceBusListener' for function 'SimpleServiceBusReceiver'
2024-06-05T20:19:24.923 [Information] Stopping the listener 'Microsoft.Azure.WebJobs.ServiceBus.Listeners.ServiceBusListener' for function 'SimpleServiceBusSenderReceiver'
2024-06-05T20:19:24.963 [Information] Stopped the listener 'Microsoft.Azure.WebJobs.ServiceBus.Listeners.ServiceBusListener' for function 'SimpleServiceBusReceiver'
2024-06-05T20:19:24.980 [Information] Stopped the listener 'Microsoft.Azure.WebJobs.ServiceBus.Listeners.ServiceBusListener' for function 'SimpleServiceBusSenderReceiver'
2024-06-05T20:19:24.985 [Information] Job host stopped
WARNING: 2024-06-05T20:19:26.715 [Error] Unhandled exception. System.IO.FileNotFoundException: Could not load file or assembly 'Microsoft.Extensions.Diagnostics, Version=8.0.0.0, Culture=neutral, PublicKeyToken=adb9793829ddae60'. The system cannot find the file specified.
WARNING: 2024-06-05T20:19:26.715 [Information] File name: 'Microsoft.Extensions.Diagnostics, Version=8.0.0.0, Culture=neutral, PublicKeyToken=adb9793829ddae60'
2024-06-05T20:19:26.715 [Information] at Microsoft.Extensions.Hosting.HostBuilder.PopulateServiceCollection(IServiceCollection services, HostBuilderContext hostBuilderContext, HostingEnvironment hostingEnvironment, PhysicalFileProvider defaultFileProvider, IConfiguration appConfiguration, Func`1 serviceProviderGetter)
2024-06-05T20:19:26.715 [Information] at Microsoft.Extensions.Hosting.HostBuilder.InitializeServiceProvider()
2024-06-05T20:19:26.715 [Information] at Microsoft.Extensions.Hosting.HostBuilder.Build()
2024-06-05T20:19:26.715 [Information] at Program.<Main>$(String[] args) in C:\Users\shein\source\repos\SimplerServiceBusSendReceiveDemo\SimpleServiceBusSendReceiveAzureFuncs\SimpleServiceBusSenderReceiverMainProgram.cs:line 3
2024-06-05T20:19:26.731 [Error] Exceeded language worker restart retry count for runtime:dotnet-isolated. Shutting down and proactively recycling the Functions Host to recover
2024-06-05T20:19:26.775 [Information] Stopping JobHost
2024-06-05T20:19:26.777 [Information] Stopping the listener 'Microsoft.Azure.WebJobs.ServiceBus.Listeners.ServiceBusListener' for function 'SimpleServiceBusReceiver'
2024-06-05T20:19:26.846 [Information] Stopping the listener 'Microsoft.Azure.WebJobs.ServiceBus.Listeners.ServiceBusListener' for function 'SimpleServiceBusSenderReceiver'
2024-06-05T20:19:26.870 [Information] Stopped the listener 'Microsoft.Azure.WebJobs.ServiceBus.Listeners.ServiceBusListener' for function 'SimpleServiceBusReceiver'
2024-06-05T20:19:26.886 [Information] Stopped the listener 'Microsoft.Azure.WebJobs.ServiceBus.Listeners.ServiceBusListener' for function 'SimpleServiceBusSenderReceiver'
2024-06-05T20:19:26.890 [Information] Job host stopped
WARNING: 2024-06-05T20:19:38.780 [Information] Host lock lease acquired by instance ID '48dc960434dad156bbc4e40f6f8e23ba'.
WARNING: 2024-06-05T20:19:39.229 [Information] Host lock lease acquired by instance ID '302437db9243b689321142964e6dc164'.
WARNING: 2024-06-05T20:19:44.987 [Error] Unhandled exception. System.IO.FileNotFoundException: Could not load file or assembly 'Microsoft.Extensions.Diagnostics, Version=8.0.0.0, Culture=neutral, PublicKeyToken=adb9793829ddae60'. The system cannot find the file specified.
WARNING: 2024-06-05T20:19:44.988 [Information] File name: 'Microsoft.Extensions.Diagnostics, Version=8.0.0.0, Culture=neutral, PublicKeyToken=adb9793829ddae60'
2024-06-05T20:19:44.988 [Information] at Microsoft.Extensions.Hosting.HostBuilder.PopulateServiceCollection(IServiceCollection services, HostBuilderContext hostBuilderContext, HostingEnvironment hostingEnvironment, PhysicalFileProvider defaultFileProvider, IConfiguration appConfiguration, Func`1 serviceProviderGetter)
2024-06-05T20:19:44.988 [Information] at Microsoft.Extensions.Hosting.HostBuilder.InitializeServiceProvider()
2024-06-05T20:19:44.988 [Information] at Microsoft.Extensions.Hosting.HostBuilder.Build()
2024-06-05T20:19:44.988 [Information] at Program.<Main>$(String[] args) in C:\Users\shein\source\repos\SimplerServiceBusSendReceiveDemo\SimpleServiceBusSendReceiveAzureFuncs\SimpleServiceBusSenderReceiverMainProgram.cs:line 3
2024-06-05T20:19:45.007 [Error] Exceeded language worker restart retry count for runtime:dotnet-isolated. Shutting down and proactively recycling the Functions Host to recover
WARNING: 2024-06-05T20:19:45.043 [Information] Stopping JobHost
WARNING: 2024-06-05T20:19:45.046 [Information] Stopping the listener 'Microsoft.Azure.WebJobs.ServiceBus.Listeners.ServiceBusListener' for function 'SimpleServiceBusReceiver'
WARNING: 2024-06-05T20:19:45.141 [Information] Stopping the listener 'Microsoft.Azure.WebJobs.ServiceBus.Listeners.ServiceBusListener' for function 'SimpleServiceBusSenderReceiver'
WARNING: 2024-06-05T20:19:45.164 [Information] Stopped the listener 'Microsoft.Azure.WebJobs.ServiceBus.Listeners.ServiceBusListener' for function 'SimpleServiceBusReceiver'
2024-06-05T20:19:45.177 [Information] Stopped the listener 'Microsoft.Azure.WebJobs.ServiceBus.Listeners.ServiceBusListener' for function 'SimpleServiceBusSenderReceiver'
2024-06-05T20:19:45.181 [Information] Job host stopped
WARNING: 2024-06-05T20:19:45.453 [Information] Executing 'Functions.SimpleServiceBusReceiver' (Reason='(null)', Id=96733de0-f10f-4187-bd3b-d2ea862914c0)
WARNING: 2024-06-05T20:19:45.453 [Information] Executing 'Functions.SimpleServiceBusReceiver' (Reason='(null)', Id=80256606-ab92-49dc-b81d-b340d1fa5808)
2024-06-05T20:19:45.453 [Information] Executing 'Functions.SimpleServiceBusReceiver' (Reason='(null)', Id=7197da40-ab5d-4406-8779-03b5e62392d5)
WARNING: 2024-06-05T20:19:45.456 [Information] Trigger Details: MessageId: eb7955308e6c483ea6e180e39da173c1, SequenceNumber: 2, DeliveryCount: 4, EnqueuedTimeUtc: 2024-06-05T20:16:38.1070000+00:00, LockedUntilUtc: 2024-06-05T20:20:45.2680000+00:00, SessionId: (null)
WARNING: 2024-06-05T20:19:45.456 [Information] Trigger Details: MessageId: 7242a62173f04512b533160ba466a81a, SequenceNumber: 16, DeliveryCount: 4, EnqueuedTimeUtc: 2024-06-05T20:16:44.2320000+00:00, LockedUntilUtc: 2024-06-05T20:20:45.2680000+00:00, SessionId: (null)
2024-06-05T20:19:45.456 [Information] Trigger Details: MessageId: ade10a8e06a6472c8e1bca58ae13d0c4, SequenceNumber: 11, DeliveryCount: 4, EnqueuedTimeUtc: 2024-06-05T20:16:42.2010000+00:00, LockedUntilUtc: 2024-06-05T20:20:45.2530000+00:00, SessionId: (null)
WARNING: 2024-06-05T20:19:45.453 [Information] Executing 'Functions.SimpleServiceBusSenderReceiver' (Reason='(null)', Id=e8f0e628-8c44-486a-b126-05184eb9678f)
WARNING: 2024-06-05T20:19:45.453 [Information] Executing 'Functions.SimpleServiceBusSenderReceiver' (Reason='(null)', Id=5b91ed64-42e7-412a-b290-afdd5e005950)
2024-06-05T20:19:45.453 [Information] Executing 'Functions.SimpleServiceBusSenderReceiver' (Reason='(null)', Id=ff04a0f5-a8cc-4579-b24a-2118c0dbbc95)
2024-06-05T20:19:45.453 [Information] Executing 'Functions.SimpleServiceBusSenderReceiver' (Reason='(null)', Id=f99fecc3-85f1-4daa-a33f-ac11a90ba484)
2024-06-05T20:19:45.453 [Information] Executing 'Functions.SimpleServiceBusSenderReceiver' (Reason='(null)', Id=bbdab146-b26a-4d76-8902-27d21ae24d46)
2024-06-05T20:19:45.453 [Information] Executing 'Functions.SimpleServiceBusSenderReceiver' (Reason='(null)', Id=6a868eba-42d7-4212-acbc-73c70e8be20d)
2024-06-05T20:19:45.453 [Information] Executing 'Functions.SimpleServiceBusSenderReceiver' (Reason='(null)', Id=c6414d30-e6cc-4f82-995f-39d92aec4d78)
WARNING: 2024-06-05T20:19:45.453 [Information] Executing 'Functions.SimpleServiceBusSenderReceiver' (Reason='(null)', Id=e4a99c6b-c10f-4965-95c9-6562543c48ee)
WARNING: 2024-06-05T20:19:45.453 [Information] Executing 'Functions.SimpleServiceBusSenderReceiver' (Reason='(null)', Id=1a3a6a14-a5e7-45d0-9ff8-6726fffa19ad)
WARNING: 2024-06-05T20:19:45.456 [Information] Trigger Details: MessageId: 9420c51d13b144ed983bbdca761b1ab2, SequenceNumber: 10, DeliveryCount: 4, EnqueuedTimeUtc: 2024-06-05T20:16:42.2010000+00:00, LockedUntilUtc: 2024-06-05T20:20:45.2680000+00:00, SessionId: (null)
2024-06-05T20:19:45.456 [Information] Trigger Details: MessageId: f3069b2886b64b69a979a8cbed034857, SequenceNumber: 6, DeliveryCount: 4, EnqueuedTimeUtc: 2024-06-05T20:16:40.2160000+00:00, LockedUntilUtc: 2024-06-05T20:20:45.2680000+00:00, SessionId: (null)
2024-06-05T20:19:45.456 [Information] Trigger Details: MessageId: 6481460d80164c02912948ef9f3d28b1, SequenceNumber: 1, DeliveryCount: 4, EnqueuedTimeUtc: 2024-06-05T20:16:38.1070000+00:00, LockedUntilUtc: 2024-06-05T20:20:45.2680000+00:00, SessionId: (null)
2024-06-05T20:19:45.456 [Information] Trigger Details: MessageId: 73c073484cac46d5a7941ce9cc1ecdf5, SequenceNumber: 3, DeliveryCount: 4, EnqueuedTimeUtc: 2024-06-05T20:16:38.1070000+00:00, LockedUntilUtc: 2024-06-05T20:20:45.2680000+00:00, SessionId: (null)
WARNING: 2024-06-05T20:19:45.456 [Information] Trigger Details: MessageId: a90319fe92124910a05446dd6e9041d3, SequenceNumber: 12, DeliveryCount: 4, EnqueuedTimeUtc: 2024-06-05T20:16:42.2010000+00:00, LockedUntilUtc: 2024-06-05T20:20:45.2680000+00:00, SessionId: (null)
WARNING: 2024-06-05T20:19:45.457 [Information] Trigger Details: MessageId: 7cce0ea9604e441788d7f893dd0058dc, SequenceNumber: 15, DeliveryCount: 4, EnqueuedTimeUtc: 2024-06-05T20:16:44.2320000+00:00, LockedUntilUtc: 2024-06-05T20:20:45.2680000+00:00, SessionId: (null)
2024-06-05T20:19:45.457 [Information] Trigger Details: MessageId: cb42c500c771421f9fa00b8e9eacb82f, SequenceNumber: 13, DeliveryCount: 4, EnqueuedTimeUtc: 2024-06-05T20:16:44.2320000+00:00, LockedUntilUtc: 2024-06-05T20:20:45.2680000+00:00, SessionId: (null)
WARNING: 2024-06-05T20:19:45.457 [Information] Trigger Details: MessageId: 909a5f4048e74eb79e4376d572567353, SequenceNumber: 8, DeliveryCount: 4, EnqueuedTimeUtc: 2024-06-05T20:16:40.2160000+00:00, LockedUntilUtc: 2024-06-05T20:20:45.2680000+00:00, SessionId: (null)
WARNING: 2024-06-05T20:19:45.457 [Information] Trigger Details: MessageId: 8419bbfc1da04a56be732c730ffa45aa, SequenceNumber: 14, DeliveryCount: 4, EnqueuedTimeUtc: 2024-06-05T20:16:44.2320000+00:00, LockedUntilUtc: 2024-06-05T20:20:45.2680000+00:00, SessionId: (null)
WARNING: 2024-06-05T20:19:45.479 [Information] Executing 'Functions.SimpleServiceBusSenderReceiver' (Reason='(null)', Id=4f890444-1af3-4516-a79b-e70488f743e1)
WARNING: 2024-06-05T20:19:45.479 [Information] Trigger Details: MessageId: 565aff3e44ff48c28766eb5eeeec24ce, SequenceNumber: 5, DeliveryCount: 4, EnqueuedTimeUtc: 2024-06-05T20:16:40.2160000+00:00, LockedUntilUtc: 2024-06-05T20:20:45.2680000+00:00, SessionId: (null)
WARNING: 2024-06-05T20:19:45.452 [Information] Executing 'Functions.SimpleServiceBusSenderReceiver' (Reason='(null)', Id=e8f0e628-8c44-486a-b126-05184eb9678f)
WARNING: 2024-06-05T20:19:45.452 [Information] Executing 'Functions.SimpleServiceBusReceiver' (Reason='(null)', Id=96733de0-f10f-4187-bd3b-d2ea862914c0)
2024-06-05T20:19:45.453 [Information] Executing 'Functions.SimpleServiceBusSenderReceiver' (Reason='(null)', Id=5b91ed64-42e7-412a-b290-afdd5e005950)
2024-06-05T20:19:45.453 [Information] Executing 'Functions.SimpleServiceBusReceiver' (Reason='(null)', Id=80256606-ab92-49dc-b81d-b340d1fa5808)
WARNING: 2024-06-05T20:19:45.453 [Information] Executing 'Functions.SimpleServiceBusReceiver' (Reason='(null)', Id=7197da40-ab5d-4406-8779-03b5e62392d5)
WARNING: 2024-06-05T20:19:45.453 [Information] Executing 'Functions.SimpleServiceBusSenderReceiver' (Reason='(null)', Id=ff04a0f5-a8cc-4579-b24a-2118c0dbbc95)
2024-06-05T20:19:45.453 [Information] Executing 'Functions.SimpleServiceBusSenderReceiver' (Reason='(null)', Id=f99fecc3-85f1-4daa-a33f-ac11a90ba484)
2024-06-05T20:19:45.453 [Information] Executing 'Functions.SimpleServiceBusSenderReceiver' (Reason='(null)', Id=bbdab146-b26a-4d76-8902-27d21ae24d46)
2024-06-05T20:19:45.453 [Information] Executing 'Functions.SimpleServiceBusSenderReceiver' (Reason='(null)', Id=6a868eba-42d7-4212-acbc-73c70e8be20d)
2024-06-05T20:19:45.453 [Information] Executing 'Functions.SimpleServiceBusSenderReceiver' (Reason='(null)', Id=c6414d30-e6cc-4f82-995f-39d92aec4d78)
2024-06-05T20:19:45.453 [Information] Executing 'Functions.SimpleServiceBusSenderReceiver' (Reason='(null)', Id=e4a99c6b-c10f-4965-95c9-6562543c48ee)
2024-06-05T20:19:45.453 [Information] Executing 'Functions.SimpleServiceBusSenderReceiver' (Reason='(null)', Id=1a3a6a14-a5e7-45d0-9ff8-6726fffa19ad)
2024-06-05T20:19:45.456 [Information] Trigger Details: MessageId: f3069b2886b64b69a979a8cbed034857, SequenceNumber: 6, DeliveryCount: 4, EnqueuedTimeUtc: 2024-06-05T20:16:40.2160000+00:00, LockedUntilUtc: 2024-06-05T20:20:45.2680000+00:00, SessionId: (null)
2024-06-05T20:19:45.456 [Information] Trigger Details: MessageId: 9420c51d13b144ed983bbdca761b1ab2, SequenceNumber: 10, DeliveryCount: 4, EnqueuedTimeUtc: 2024-06-05T20:16:42.2010000+00:00, LockedUntilUtc: 2024-06-05T20:20:45.2680000+00:00, SessionId: (null)
2024-06-05T20:19:45.456 [Information] Trigger Details: MessageId: eb7955308e6c483ea6e180e39da173c1, SequenceNumber: 2, DeliveryCount: 4, EnqueuedTimeUtc: 2024-06-05T20:16:38.1070000+00:00, LockedUntilUtc: 2024-06-05T20:20:45.2680000+00:00, SessionId: (null)
2024-06-05T20:19:45.456 [Information] Trigger Details: MessageId: 7242a62173f04512b533160ba466a81a, SequenceNumber: 16, DeliveryCount: 4, EnqueuedTimeUtc: 2024-06-05T20:16:44.2320000+00:00, LockedUntilUtc: 2024-06-05T20:20:45.2680000+00:00, SessionId: (null)
2024-06-05T20:19:45.456 [Information] Trigger Details: MessageId: ade10a8e06a6472c8e1bca58ae13d0c4, SequenceNumber: 11, DeliveryCount: 4, EnqueuedTimeUtc: 2024-06-05T20:16:42.2010000+00:00, LockedUntilUtc: 2024-06-05T20:20:45.2530000+00:00, SessionId: (null)
2024-06-05T20:19:45.456 [Information] Trigger Details: MessageId: 6481460d80164c02912948ef9f3d28b1, SequenceNumber: 1, DeliveryCount: 4, EnqueuedTimeUtc: 2024-06-05T20:16:38.1070000+00:00, LockedUntilUtc: 2024-06-05T20:20:45.2680000+00:00, SessionId: (null)
WARNING: 2024-06-05T20:19:45.456 [Information] Trigger Details: MessageId: 73c073484cac46d5a7941ce9cc1ecdf5, SequenceNumber: 3, DeliveryCount: 4, EnqueuedTimeUtc: 2024-06-05T20:16:38.1070000+00:00, LockedUntilUtc: 2024-06-05T20:20:45.2680000+00:00, SessionId: (null)
WARNING: 2024-06-05T20:19:45.456 [Information] Trigger Details: MessageId: a90319fe92124910a05446dd6e9041d3, SequenceNumber: 12, DeliveryCount: 4, EnqueuedTimeUtc: 2024-06-05T20:16:42.2010000+00:00, LockedUntilUtc: 2024-06-05T20:20:45.2680000+00:00, SessionId: (null)
WARNING: 2024-06-05T20:19:45.457 [Information] Trigger Details: MessageId: 7cce0ea9604e441788d7f893dd0058dc, SequenceNumber: 15, DeliveryCount: 4, EnqueuedTimeUtc: 2024-06-05T20:16:44.2320000+00:00, LockedUntilUtc: 2024-06-05T20:20:45.2680000+00:00, SessionId: (null)
WARNING: 2024-06-05T20:19:45.457 [Information] Trigger Details: MessageId: cb42c500c771421f9fa00b8e9eacb82f, SequenceNumber: 13, DeliveryCount: 4, EnqueuedTimeUtc: 2024-06-05T20:16:44.2320000+00:00, LockedUntilUtc: 2024-06-05T20:20:45.2680000+00:00, SessionId: (null)
WARNING: 2024-06-05T20:19:45.457 [Information] Trigger Details: MessageId: 909a5f4048e74eb79e4376d572567353, SequenceNumber: 8, DeliveryCount: 4, EnqueuedTimeUtc: 2024-06-05T20:16:40.2160000+00:00, LockedUntilUtc: 2024-06-05T20:20:45.2680000+00:00, SessionId: (null)
2024-06-05T20:19:45.457 [Information] Trigger Details: MessageId: 8419bbfc1da04a56be732c730ffa45aa, SequenceNumber: 14, DeliveryCount: 4, EnqueuedTimeUtc: 2024-06-05T20:16:44.2320000+00:00, LockedUntilUtc: 2024-06-05T20:20:45.2680000+00:00, SessionId: (null)
2024-06-05T20:19:45.478 [Information] Executing 'Functions.SimpleServiceBusReceiver' (Reason='(null)', Id=cbf15cc9-d93e-420f-a105-e0456b5abeb2)
2024-06-05T20:19:45.478 [Information] Trigger Details: MessageId: 567e260c09434401a81ab485715c9bf7, SequenceNumber: 4, DeliveryCount: 4, EnqueuedTimeUtc: 2024-06-05T20:16:38.1070000+00:00, LockedUntilUtc: 2024-06-05T20:20:45.2680000+00:00, SessionId: (null)
2024-06-05T20:19:45.479 [Information] Executing 'Functions.SimpleServiceBusReceiver' (Reason='(null)', Id=a60b9c11-ba83-47d7-b945-ac2f810cadd2)
WARNING: 2024-06-05T20:19:45.479 [Information] Trigger Details: MessageId: ae9289783ce94244bfd86ed7a3090993, SequenceNumber: 7, DeliveryCount: 4, EnqueuedTimeUtc: 2024-06-05T20:16:40.2160000+00:00, LockedUntilUtc: 2024-06-05T20:20:45.2680000+00:00, SessionId: (null)
WARNING: 2024-06-05T20:19:45.479 [Information] Executing 'Functions.SimpleServiceBusReceiver' (Reason='(null)', Id=b5738cce-ceeb-400a-84fd-54840e818e6d)
WARNING: 2024-06-05T20:19:45.479 [Information] Trigger Details: MessageId: 011ab8d040964b9d8692799274d204e7, SequenceNumber: 9, DeliveryCount: 4, EnqueuedTimeUtc: 2024-06-05T20:16:42.2010000+00:00, LockedUntilUtc: 2024-06-05T20:20:45.2680000+00:00, SessionId: (null)
2024-06-05T20:19:45.479 [Information] Executing 'Functions.SimpleServiceBusSenderReceiver' (Reason='(null)', Id=4f890444-1af3-4516-a79b-e70488f743e1)
2024-06-05T20:19:45.479 [Information] Trigger Details: MessageId: 565aff3e44ff48c28766eb5eeeec24ce, SequenceNumber: 5, DeliveryCount: 4, EnqueuedTimeUtc: 2024-06-05T20:16:40.2160000+00:00, LockedUntilUtc: 2024-06-05T20:20:45.2680000+00:00, SessionId: (null)
WARNING: 2024-06-05T20:19:45.478 [Information] Executing 'Functions.SimpleServiceBusReceiver' (Reason='(null)', Id=cbf15cc9-d93e-420f-a105-e0456b5abeb2)
WARNING: 2024-06-05T20:19:45.478 [Information] Trigger Details: MessageId: 567e260c09434401a81ab485715c9bf7, SequenceNumber: 4, DeliveryCount: 4, EnqueuedTimeUtc: 2024-06-05T20:16:38.1070000+00:00, LockedUntilUtc: 2024-06-05T20:20:45.2680000+00:00, SessionId: (null)
2024-06-05T20:19:45.479 [Information] Executing 'Functions.SimpleServiceBusReceiver' (Reason='(null)', Id=a60b9c11-ba83-47d7-b945-ac2f810cadd2)
WARNING: 2024-06-05T20:19:45.479 [Information] Trigger Details: MessageId: ae9289783ce94244bfd86ed7a3090993, SequenceNumber: 7, DeliveryCount: 4, EnqueuedTimeUtc: 2024-06-05T20:16:40.2160000+00:00, LockedUntilUtc: 2024-06-05T20:20:45.2680000+00:00, SessionId: (null)
WARNING: 2024-06-05T20:19:45.479 [Information] Executing 'Functions.SimpleServiceBusReceiver' (Reason='(null)', Id=b5738cce-ceeb-400a-84fd-54840e818e6d)
2024-06-05T20:19:45.479 [Information] Trigger Details: MessageId: 011ab8d040964b9d8692799274d204e7, SequenceNumber: 9, DeliveryCount: 4, EnqueuedTimeUtc: 2024-06-05T20:16:42.2010000+00:00, LockedUntilUtc: 2024-06-05T20:20:45.2680000+00:00, SessionId: (null)
WARNING: 2024-06-05T20:19:45.794 [Error] Unhandled exception. System.IO.FileNotFoundException: Could not load file or assembly 'Microsoft.Extensions.Diagnostics, Version=8.0.0.0, Culture=neutral, PublicKeyToken=adb9793829ddae60'. The system cannot find the file specified.
WARNING: 2024-06-05T20:19:45.794 [Information] File name: 'Microsoft.Extensions.Diagnostics, Version=8.0.0.0, Culture=neutral, PublicKeyToken=adb9793829ddae60'
2024-06-05T20:19:45.794 [Information] at Microsoft.Extensions.Hosting.HostBuilder.PopulateServiceCollection(IServiceCollection services, HostBuilderContext hostBuilderContext, HostingEnvironment hostingEnvironment, PhysicalFileProvider defaultFileProvider, IConfiguration appConfiguration, Func`1 serviceProviderGetter)
2024-06-05T20:19:45.794 [Information] at Microsoft.Extensions.Hosting.HostBuilder.InitializeServiceProvider()
WARNING: 2024-06-05T20:19:45.794 [Information] at Microsoft.Extensions.Hosting.HostBuilder.Build()
WARNING: 2024-06-05T20:19:45.794 [Information] at Program.<Main>$(String[] args) in C:\Users\shein\source\repos\SimplerServiceBusSendReceiveDemo\SimpleServiceBusSendReceiveAzureFuncs\SimpleServiceBusSenderReceiverMainProgram.cs:line 3
2024-06-05T20:19:45.810 [Error] Exceeded language worker restart retry count for runtime:dotnet-isolated. Shutting down and proactively recycling the Functions Host to recover
2024-06-05T20:19:45.867 [Information] Stopping JobHost
2024-06-05T20:19:45.871 [Information] Stopping the listener 'Microsoft.Azure.WebJobs.ServiceBus.Listeners.ServiceBusListener' for function 'SimpleServiceBusReceiver'
WARNING: 2024-06-05T20:19:45.918 [Information] Stopping the listener 'Microsoft.Azure.WebJobs.ServiceBus.Listeners.ServiceBusListener' for function 'SimpleServiceBusSenderReceiver'
WARNING: 2024-06-05T20:19:55.600 [Information] Executing 'Functions.SimpleServiceBusSenderReceiver' (Reason='(null)', Id=0600d608-4bb7-4460-bc38-c061242b94e0)
WARNING: 2024-06-05T20:19:55.602 [Information] Executing 'Functions.SimpleServiceBusSenderReceiver' (Reason='(null)', Id=7b5618fb-7fe6-4631-a39d-a6a4d2c7c98a)
WARNING: 2024-06-05T20:19:55.600 [Information] Executing 'Functions.SimpleServiceBusSenderReceiver' (Reason='(null)', Id=5b7c6e32-c9b4-489a-8c88-4a726eb0149d)
2024-06-05T20:19:55.602 [Information] Executing 'Functions.SimpleServiceBusReceiver' (Reason='(null)', Id=82937bfb-148f-4ef0-ae0a-622d8ea3383b)
2024-06-05T20:19:55.609 [Information] Trigger Details: MessageId: 5abf9dded8d04f778007ce1ef4e81063, SequenceNumber: 17, DeliveryCount: 4, EnqueuedTimeUtc: 2024-06-05T20:16:46.4350000+00:00, LockedUntilUtc: 2024-06-05T20:20:55.3480000+00:00, SessionId: (null)
2024-06-05T20:19:55.609 [Information] Trigger Details: MessageId: 2f6060c1dd9849d388c3ef93337d1545, SequenceNumber: 20, DeliveryCount: 4, EnqueuedTimeUtc: 2024-06-05T20:16:46.4350000+00:00, LockedUntilUtc: 2024-06-05T20:20:55.3640000+00:00, SessionId: (null)
2024-06-05T20:19:55.609 [Information] Trigger Details: MessageId: 1c6e88ea54c249d88f9515f174334e21, SequenceNumber: 18, DeliveryCount: 4, EnqueuedTimeUtc: 2024-06-05T20:16:46.4350000+00:00, LockedUntilUtc: 2024-06-05T20:20:55.3640000+00:00, SessionId: (null)
WARNING: 2024-06-05T20:19:55.609 [Information] Trigger Details: MessageId: 69573fcca5d04f06b5f6751189ac6548, SequenceNumber: 19, DeliveryCount: 4, EnqueuedTimeUtc: 2024-06-05T20:16:46.4350000+00:00, LockedUntilUtc: 2024-06-05T20:20:55.3640000+00:00, SessionId: (null)
WARNING: 2024-06-05T20:19:55.602 [Information] Executing 'Functions.SimpleServiceBusReceiver' (Reason='(null)', Id=82937bfb-148f-4ef0-ae0a-622d8ea3383b)
WARNING: 2024-06-05T20:19:55.609 [Information] Trigger Details: MessageId: 1c6e88ea54c249d88f9515f174334e21, SequenceNumber: 18, DeliveryCount: 4, EnqueuedTimeUtc: 2024-06-05T20:16:46.4350000+00:00, LockedUntilUtc: 2024-06-05T20:20:55.3640000+00:00, SessionId: (null)
WARNING: 2024-06-05T20:19:55.602 [Information] Executing 'Functions.SimpleServiceBusSenderReceiver' (Reason='(null)', Id=0600d608-4bb7-4460-bc38-c061242b94e0)
WARNING: 2024-06-05T20:19:55.602 [Information] Executing 'Functions.SimpleServiceBusSenderReceiver' (Reason='(null)', Id=7b5618fb-7fe6-4631-a39d-a6a4d2c7c98a)
2024-06-05T20:19:55.602 [Information] Executing 'Functions.SimpleServiceBusSenderReceiver' (Reason='(null)', Id=5b7c6e32-c9b4-489a-8c88-4a726eb0149d)
2024-06-05T20:19:55.609 [Information] Trigger Details: MessageId: 5abf9dded8d04f778007ce1ef4e81063, SequenceNumber: 17, DeliveryCount: 4, EnqueuedTimeUtc: 2024-06-05T20:16:46.4350000+00:00, LockedUntilUtc: 2024-06-05T20:20:55.3480000+00:00, SessionId: (null)
2024-06-05T20:19:55.609 [Information] Trigger Details: MessageId: 2f6060c1dd9849d388c3ef93337d1545, SequenceNumber: 20, DeliveryCount: 4, EnqueuedTimeUtc: 2024-06-05T20:16:46.4350000+00:00, LockedUntilUtc: 2024-06-05T20:20:55.3640000+00:00, SessionId: (null)
2024-06-05T20:19:55.609 [Information] Trigger Details: MessageId: 69573fcca5d04f06b5f6751189ac6548, SequenceNumber: 19, DeliveryCount: 4, EnqueuedTimeUtc: 2024-06-05T20:16:46.4350000+00:00, LockedUntilUtc: 2024-06-05T20:20:55.3640000+00:00, SessionId: (null)
WARNING: 2024-06-05T20:19:57.292 [Information] Host lock lease acquired by instance ID '48dc960434dad156bbc4e40f6f8e23ba'.
WARNING: 2024-06-05T20:20:03.670 [Error] Unhandled exception. System.IO.FileNotFoundException: Could not load file or assembly 'Microsoft.Extensions.Diagnostics, Version=8.0.0.0, Culture=neutral, PublicKeyToken=adb9793829ddae60'. The system cannot find the file specified.
WARNING: 2024-06-05T20:20:03.670 [Information] File name: 'Microsoft.Extensions.Diagnostics, Version=8.0.0.0, Culture=neutral, PublicKeyToken=adb9793829ddae60'
2024-06-05T20:20:03.670 [Information] at Microsoft.Extensions.Hosting.HostBuilder.PopulateServiceCollection(IServiceCollection services, HostBuilderContext hostBuilderContext, HostingEnvironment hostingEnvironment, PhysicalFileProvider defaultFileProvider, IConfiguration appConfiguration, Func`1 serviceProviderGetter)
2024-06-05T20:20:03.670 [Information] at Microsoft.Extensions.Hosting.HostBuilder.InitializeServiceProvider()
2024-06-05T20:20:03.670 [Information] at Microsoft.Extensions.Hosting.HostBuilder.Build()
2024-06-05T20:20:03.670 [Information] at Program.<Main>$(String[] args) in C:\Users\shein\source\repos\SimplerServiceBusSendReceiveDemo\SimpleServiceBusSendReceiveAzureFuncs\SimpleServiceBusSenderReceiverMainProgram.cs:line 3
2024-06-05T20:20:03.696 [Error] Exceeded language worker restart retry count for runtime:dotnet-isolated. Shutting down and proactively recycling the Functions Host to recover
2024-06-05T20:20:03.748 [Information] Stopping JobHost
2024-06-05T20:20:03.751 [Information] Stopping the listener 'Microsoft.Azure.WebJobs.ServiceBus.Listeners.ServiceBusListener' for function 'SimpleServiceBusReceiver'
2024-06-05T20:20:03.791 [Information] Stopping the listener 'Microsoft.Azure.WebJobs.ServiceBus.Listeners.ServiceBusListener' for function 'SimpleServiceBusSenderReceiver'
WARNING: 2024-06-05T20:20:16.993 [Error] Unhandled exception. System.IO.FileNotFoundException: Could not load file or assembly 'Microsoft.Extensions.Diagnostics, Version=8.0.0.0, Culture=neutral, PublicKeyToken=adb9793829ddae60'. The system cannot find the file specified.
WARNING: 2024-06-05T20:20:16.993 [Information] File name: 'Microsoft.Extensions.Diagnostics, Version=8.0.0.0, Culture=neutral, PublicKeyToken=adb9793829ddae60'
2024-06-05T20:20:16.993 [Information] at Microsoft.Extensions.Hosting.HostBuilder.PopulateServiceCollection(IServiceCollection services, HostBuilderContext hostBuilderContext, HostingEnvironment hostingEnvironment, PhysicalFileProvider defaultFileProvider, IConfiguration appConfiguration, Func`1 serviceProviderGetter)
2024-06-05T20:20:16.993 [Information] at Microsoft.Extensions.Hosting.HostBuilder.InitializeServiceProvider()
2024-06-05T20:20:16.994 [Information] at Microsoft.Extensions.Hosting.HostBuilder.Build()
2024-06-05T20:20:16.994 [Information] at Program.<Main>$(String[] args) in C:\Users\shein\source\repos\SimplerServiceBusSendReceiveDemo\SimpleServiceBusSendReceiveAzureFuncs\SimpleServiceBusSenderReceiverMainProgram.cs:line 3
2024-06-05T20:20:17.023 [Error] Failed to start a new language worker for runtime: dotnet-isolated.
System.Threading.Tasks.TaskCanceledException : A task was canceled.
   at async Microsoft.Azure.WebJobs.Script.Grpc.GrpcWorkerChannel.StartWorkerProcessAsync(CancellationToken cancellationToken) at /_/src/WebJobs.Script.Grpc/Channel/GrpcWorkerChannel.cs : 377
   at System.Runtime.ExceptionServices.ExceptionDispatchInfo.Throw()
   at async Microsoft.Azure.WebJobs.Script.Workers.Rpc.RpcFunctionInvocationDispatcher.InitializeJobhostLanguageWorkerChannelAsync(??) at /_/src/WebJobs.Script/Workers/Rpc/FunctionRegistration/RpcFunctionInvocationDispatcher.cs : 156
   at System.Runtime.ExceptionServices.ExceptionDispatchInfo.Throw()
   at async Microsoft.Azure.WebJobs.Script.Workers.Rpc.RpcFunctionInvocationDispatcher.InitializeJobhostLanguageWorkerChannelAsync(??) at /_/src/WebJobs.Script/Workers/Rpc/FunctionRegistration/RpcFunctionInvocationDispatcher.cs : 148
   at System.Runtime.ExceptionServices.ExceptionDispatchInfo.Throw()
   at async Microsoft.Azure.WebJobs.Script.Workers.Rpc.RpcFunctionInvocationDispatcher.InitializeJobhostLanguageWorkerChannelAsync(??) at /_/src/WebJobs.Script/Workers/Rpc/FunctionRegistration/RpcFunctionInvocationDispatcher.cs : 139
   at System.Runtime.ExceptionServices.ExceptionDispatchInfo.Throw()
   at async Microsoft.Azure.WebJobs.Script.Workers.Rpc.RpcFunctionInvocationDispatcher.<>c__DisplayClass56_0.<StartWorkerProcesses>b__0(??) at /_/src/WebJobs.Script/Workers/Rpc/FunctionRegistration/RpcFunctionInvocationDispatcher.cs : 219
2024-06-05T20:20:17.189 [Error] Unhandled exception. System.IO.FileNotFoundException: Could not load file or assembly 'Microsoft.Extensions.Diagnostics, Version=8.0.0.0, Culture=neutral, PublicKeyToken=adb9793829ddae60'. The system cannot find the file specified.
2024-06-05T20:20:17.189 [Information] File name: 'Microsoft.Extensions.Diagnostics, Version=8.0.0.0, Culture=neutral, PublicKeyToken=adb9793829ddae60'
2024-06-05T20:20:17.189 [Information] at Microsoft.Extensions.Hosting.HostBuilder.PopulateServiceCollection(IServiceCollection services, HostBuilderContext hostBuilderContext, HostingEnvironment hostingEnvironment, PhysicalFileProvider defaultFileProvider, IConfiguration appConfiguration, Func`1 serviceProviderGetter)
2024-06-05T20:20:17.189 [Information] at Microsoft.Extensions.Hosting.HostBuilder.InitializeServiceProvider()
2024-06-05T20:20:17.189 [Information] at Microsoft.Extensions.Hosting.HostBuilder.Build()
2024-06-05T20:20:17.189 [Information] at Program.<Main>$(String[] args) in C:\Users\shein\source\repos\SimplerServiceBusSendReceiveDemo\SimpleServiceBusSendReceiveAzureFuncs\SimpleServiceBusSenderReceiverMainProgram.cs:line 3
WARNING: 2024-06-05T20:20:19.965 [Information] Host lock lease acquired by instance ID '302437db9243b689321142964e6dc164'.
WARNING: 2024-06-05T20:20:27.439 [Error] Unhandled exception. System.IO.FileNotFoundException: Could not load file or assembly 'Microsoft.Extensions.Diagnostics, Version=8.0.0.0, Culture=neutral, PublicKeyToken=adb9793829ddae60'. The system cannot find the file specified.
WARNING: 2024-06-05T20:20:27.439 [Information] File name: 'Microsoft.Extensions.Diagnostics, Version=8.0.0.0, Culture=neutral, PublicKeyToken=adb9793829ddae60'
2024-06-05T20:20:27.439 [Information] at Microsoft.Extensions.Hosting.HostBuilder.PopulateServiceCollection(IServiceCollection services, HostBuilderContext hostBuilderContext, HostingEnvironment hostingEnvironment, PhysicalFileProvider defaultFileProvider, IConfiguration appConfiguration, Func`1 serviceProviderGetter)
2024-06-05T20:20:27.439 [Information] at Microsoft.Extensions.Hosting.HostBuilder.InitializeServiceProvider()
2024-06-05T20:20:27.439 [Information] at Microsoft.Extensions.Hosting.HostBuilder.Build()
2024-06-05T20:20:27.439 [Information] at Program.<Main>$(String[] args) in C:\Users\shein\source\repos\SimplerServiceBusSendReceiveDemo\SimpleServiceBusSendReceiveAzureFuncs\SimpleServiceBusSenderReceiverMainProgram.cs:line 3
2024-06-05T20:20:27.453 [Error] Exceeded language worker restart retry count for runtime:dotnet-isolated. Shutting down and proactively recycling the Functions Host to recover
2024-06-05T20:20:27.506 [Information] Stopping JobHost
2024-06-05T20:20:27.510 [Information] Stopping the listener 'Microsoft.Azure.WebJobs.ServiceBus.Listeners.ServiceBusListener' for function 'SimpleServiceBusReceiver'
2024-06-05T20:20:27.584 [Information] Stopping the listener 'Microsoft.Azure.WebJobs.ServiceBus.Listeners.ServiceBusListener' for function 'SimpleServiceBusSenderReceiver'
2024-06-05T20:20:27.608 [Information] Stopped the listener 'Microsoft.Azure.WebJobs.ServiceBus.Listeners.ServiceBusListener' for function 'SimpleServiceBusReceiver'
WARNING: 2024-06-05T20:20:27.622 [Information] Stopped the listener 'Microsoft.Azure.WebJobs.ServiceBus.Listeners.ServiceBusListener' for function 'SimpleServiceBusSenderReceiver'
WARNING: 2024-06-05T20:20:27.627 [Information] Job host stopped
WARNING: 2024-06-05T20:20:38.375 [Information] Host lock lease acquired by instance ID '48dc960434dad156bbc4e40f6f8e23ba'.
WARNING: 2024-06-05T20:20:38.506 [Error] Unhandled exception. System.IO.FileNotFoundException: Could not load file or assembly 'Microsoft.Extensions.Diagnostics, Version=8.0.0.0, Culture=neutral, PublicKeyToken=adb9793829ddae60'. The system cannot find the file specified.
WARNING: 2024-06-05T20:20:38.507 [Information] File name: 'Microsoft.Extensions.Diagnostics, Version=8.0.0.0, Culture=neutral, PublicKeyToken=adb9793829ddae60'
WARNING: 2024-06-05T20:20:38.507 [Information] at Microsoft.Extensions.Hosting.HostBuilder.PopulateServiceCollection(IServiceCollection services, HostBuilderContext hostBuilderContext, HostingEnvironment hostingEnvironment, PhysicalFileProvider defaultFileProvider, IConfiguration appConfiguration, Func`1 serviceProviderGetter)
2024-06-05T20:20:38.507 [Information] at Microsoft.Extensions.Hosting.HostBuilder.InitializeServiceProvider()
2024-06-05T20:20:38.507 [Information] at Microsoft.Extensions.Hosting.HostBuilder.Build()
2024-06-05T20:20:38.507 [Information] at Program.<Main>$(String[] args) in C:\Users\shein\source\repos\SimplerServiceBusSendReceiveDemo\SimpleServiceBusSendReceiveAzureFuncs\SimpleServiceBusSenderReceiverMainProgram.cs:line 3
2024-06-05T20:20:38.577 [Error] Failed to start a new language worker for runtime: dotnet-isolated.
System.Threading.Tasks.TaskCanceledException : A task was canceled.
WARNING:    at async Microsoft.Azure.WebJobs.Script.Grpc.GrpcWorkerChannel.StartWorkerProcessAsync(CancellationToken cancellationToken) at /_/src/WebJobs.Script.Grpc/Channel/GrpcWorkerChannel.cs : 377
WARNING:    at System.Runtime.ExceptionServices.ExceptionDispatchInfo.Throw()
WARNING:    at async Microsoft.Azure.WebJobs.Script.Workers.Rpc.RpcFunctionInvocationDispatcher.InitializeJobhostLanguageWorkerChannelAsync(??) at /_/src/WebJobs.Script/Workers/Rpc/FunctionRegistration/RpcFunctionInvocationDispatcher.cs : 156
WARNING:    at System.Runtime.ExceptionServices.ExceptionDispatchInfo.Throw()
   at async Microsoft.Azure.WebJobs.Script.Workers.Rpc.RpcFunctionInvocationDispatcher.InitializeJobhostLanguageWorkerChannelAsync(??) at /_/src/WebJobs.Script/Workers/Rpc/FunctionRegistration/RpcFunctionInvocationDispatcher.cs : 148
   at System.Runtime.ExceptionServices.ExceptionDispatchInfo.Throw()
   at async Microsoft.Azure.WebJobs.Script.Workers.Rpc.RpcFunctionInvocationDispatcher.InitializeJobhostLanguageWorkerChannelAsync(??) at /_/src/WebJobs.Script/Workers/Rpc/FunctionRegistration/RpcFunctionInvocationDispatcher.cs : 139
   at System.Runtime.ExceptionServices.ExceptionDispatchInfo.Throw()
   at async Microsoft.Azure.WebJobs.Script.Workers.Rpc.RpcFunctionInvocationDispatcher.<>c__DisplayClass56_0.<StartWorkerProcesses>b__0(??) at /_/src/WebJobs.Script/Workers/Rpc/FunctionRegistration/RpcFunctionInvocationDispatcher.cs : 219
2024-06-05T20:20:38.707 [Error] Unhandled exception. System.IO.FileNotFoundException: Could not load file or assembly 'Microsoft.Extensions.Diagnostics, Version=8.0.0.0, Culture=neutral, PublicKeyToken=adb9793829ddae60'. The system cannot find the file specified.
2024-06-05T20:20:38.707 [Information] File name: 'Microsoft.Extensions.Diagnostics, Version=8.0.0.0, Culture=neutral, PublicKeyToken=adb9793829ddae60'
2024-06-05T20:20:38.707 [Information] at Microsoft.Extensions.Hosting.HostBuilder.PopulateServiceCollection(IServiceCollection services, HostBuilderContext hostBuilderContext, HostingEnvironment hostingEnvironment, PhysicalFileProvider defaultFileProvider, IConfiguration appConfiguration, Func`1 serviceProviderGetter)
2024-06-05T20:20:38.707 [Information] at Microsoft.Extensions.Hosting.HostBuilder.InitializeServiceProvider()
2024-06-05T20:20:38.707 [Information] at Microsoft.Extensions.Hosting.HostBuilder.Build()
2024-06-05T20:20:38.707 [Information] at Program.<Main>$(String[] args) in C:\Users\shein\source\repos\SimplerServiceBusSendReceiveDemo\SimpleServiceBusSendReceiveAzureFuncs\SimpleServiceBusSenderReceiverMainProgram.cs:line 3
WARNING: 2024-06-05T20:20:40.083 [Information] Host lock lease acquired by instance ID '302437db9243b689321142964e6dc164'.
WARNING: 2024-06-05T20:20:45.412 [Information] Executing 'Functions.SimpleServiceBusReceiver' (Reason='(null)', Id=8402b876-bf22-4d63-bdec-9cd804cfb6d5)
WARNING: 2024-06-05T20:20:45.412 [Information] Executing 'Functions.SimpleServiceBusReceiver' (Reason='(null)', Id=688737f1-31a5-4654-bcd0-5e3c4488a757)
WARNING: 2024-06-05T20:20:45.412 [Information] Executing 'Functions.SimpleServiceBusReceiver' (Reason='(null)', Id=31f9cf59-22ee-4158-8a18-5aaf8e979a92)
WARNING: 2024-06-05T20:20:45.412 [Information] Executing 'Functions.SimpleServiceBusReceiver' (Reason='(null)', Id=d55d822d-c00b-49e2-b52a-e27a7bb2210e)
WARNING: 2024-06-05T20:20:45.412 [Information] Executing 'Functions.SimpleServiceBusReceiver' (Reason='(null)', Id=30882325-e853-473d-9353-547292ff0863)
2024-06-05T20:20:45.412 [Information] Executing 'Functions.SimpleServiceBusReceiver' (Reason='(null)', Id=30aa2875-b739-4d7e-9817-5818b7108846)
2024-06-05T20:20:45.412 [Information] Executing 'Functions.SimpleServiceBusReceiver' (Reason='(null)', Id=ca15a517-9dcb-4d72-9ec1-904d3da8c12f)
WARNING: 2024-06-05T20:20:45.412 [Information] Executing 'Functions.SimpleServiceBusReceiver' (Reason='(null)', Id=a0180435-0b41-4fd9-965c-7b934bfb68f8)
WARNING: 2024-06-05T20:20:45.412 [Information] Executing 'Functions.SimpleServiceBusReceiver' (Reason='(null)', Id=443b7c7e-33ed-4435-8e24-b064bd35c78f)
WARNING: 2024-06-05T20:20:45.415 [Information] Trigger Details: MessageId: eb7955308e6c483ea6e180e39da173c1, SequenceNumber: 2, DeliveryCount: 5, EnqueuedTimeUtc: 2024-06-05T20:16:38.1070000+00:00, LockedUntilUtc: 2024-06-05T20:21:45.2540000+00:00, SessionId: (null)
WARNING: 2024-06-05T20:20:45.415 [Information] Trigger Details: MessageId: 73c073484cac46d5a7941ce9cc1ecdf5, SequenceNumber: 3, DeliveryCount: 5, EnqueuedTimeUtc: 2024-06-05T20:16:38.1070000+00:00, LockedUntilUtc: 2024-06-05T20:21:45.2390000+00:00, SessionId: (null)
WARNING: 2024-06-05T20:20:45.416 [Information] Trigger Details: MessageId: 6481460d80164c02912948ef9f3d28b1, SequenceNumber: 1, DeliveryCount: 5, EnqueuedTimeUtc: 2024-06-05T20:16:38.1070000+00:00, LockedUntilUtc: 2024-06-05T20:21:45.2540000+00:00, SessionId: (null)
WARNING: 2024-06-05T20:20:45.416 [Information] Trigger Details: MessageId: 7cce0ea9604e441788d7f893dd0058dc, SequenceNumber: 15, DeliveryCount: 5, EnqueuedTimeUtc: 2024-06-05T20:16:44.2320000+00:00, LockedUntilUtc: 2024-06-05T20:21:45.2540000+00:00, SessionId: (null)
2024-06-05T20:20:45.416 [Information] Trigger Details: MessageId: 909a5f4048e74eb79e4376d572567353, SequenceNumber: 8, DeliveryCount: 5, EnqueuedTimeUtc: 2024-06-05T20:16:40.2160000+00:00, LockedUntilUtc: 2024-06-05T20:21:45.2540000+00:00, SessionId: (null)
2024-06-05T20:20:45.416 [Information] Trigger Details: MessageId: ae9289783ce94244bfd86ed7a3090993, SequenceNumber: 7, DeliveryCount: 5, EnqueuedTimeUtc: 2024-06-05T20:16:40.2160000+00:00, LockedUntilUtc: 2024-06-05T20:21:45.2540000+00:00, SessionId: (null)
WARNING: 2024-06-05T20:20:45.416 [Information] Trigger Details: MessageId: f3069b2886b64b69a979a8cbed034857, SequenceNumber: 6, DeliveryCount: 5, EnqueuedTimeUtc: 2024-06-05T20:16:40.2160000+00:00, LockedUntilUtc: 2024-06-05T20:21:45.2540000+00:00, SessionId: (null)
WARNING: 2024-06-05T20:20:45.416 [Information] Trigger Details: MessageId: 7242a62173f04512b533160ba466a81a, SequenceNumber: 16, DeliveryCount: 5, EnqueuedTimeUtc: 2024-06-05T20:16:44.2320000+00:00, LockedUntilUtc: 2024-06-05T20:21:45.2540000+00:00, SessionId: (null)
WARNING: 2024-06-05T20:20:45.416 [Information] Trigger Details: MessageId: 567e260c09434401a81ab485715c9bf7, SequenceNumber: 4, DeliveryCount: 5, EnqueuedTimeUtc: 2024-06-05T20:16:38.1070000+00:00, LockedUntilUtc: 2024-06-05T20:21:45.2540000+00:00, SessionId: (null)
WARNING: 2024-06-05T20:20:45.412 [Information] Executing 'Functions.SimpleServiceBusSenderReceiver' (Reason='(null)', Id=e227fc82-7d57-42e3-9b07-73aa7ceafe9d)
WARNING: 2024-06-05T20:20:45.412 [Information] Executing 'Functions.SimpleServiceBusSenderReceiver' (Reason='(null)', Id=d1a46d70-1978-4db2-b9cd-5689cd3001c8)
2024-06-05T20:20:45.416 [Information] Trigger Details: MessageId: a90319fe92124910a05446dd6e9041d3, SequenceNumber: 12, DeliveryCount: 5, EnqueuedTimeUtc: 2024-06-05T20:16:42.2010000+00:00, LockedUntilUtc: 2024-06-05T20:21:45.2390000+00:00, SessionId: (null)
2024-06-05T20:20:45.416 [Information] Trigger Details: MessageId: 011ab8d040964b9d8692799274d204e7, SequenceNumber: 9, DeliveryCount: 5, EnqueuedTimeUtc: 2024-06-05T20:16:42.2010000+00:00, LockedUntilUtc: 2024-06-05T20:21:45.2390000+00:00, SessionId: (null)
WARNING: 2024-06-05T20:20:45.412 [Information] Executing 'Functions.SimpleServiceBusReceiver' (Reason='(null)', Id=8402b876-bf22-4d63-bdec-9cd804cfb6d5)
WARNING: 2024-06-05T20:20:45.412 [Information] Executing 'Functions.SimpleServiceBusReceiver' (Reason='(null)', Id=688737f1-31a5-4654-bcd0-5e3c4488a757)
2024-06-05T20:20:45.412 [Information] Executing 'Functions.SimpleServiceBusReceiver' (Reason='(null)', Id=31f9cf59-22ee-4158-8a18-5aaf8e979a92)
2024-06-05T20:20:45.412 [Information] Executing 'Functions.SimpleServiceBusReceiver' (Reason='(null)', Id=d55d822d-c00b-49e2-b52a-e27a7bb2210e)
2024-06-05T20:20:45.412 [Information] Executing 'Functions.SimpleServiceBusSenderReceiver' (Reason='(null)', Id=e227fc82-7d57-42e3-9b07-73aa7ceafe9d)
2024-06-05T20:20:45.412 [Information] Executing 'Functions.SimpleServiceBusReceiver' (Reason='(null)', Id=30882325-e853-473d-9353-547292ff0863)
2024-06-05T20:20:45.412 [Information] Executing 'Functions.SimpleServiceBusReceiver' (Reason='(null)', Id=30aa2875-b739-4d7e-9817-5818b7108846)
2024-06-05T20:20:45.412 [Information] Executing 'Functions.SimpleServiceBusReceiver' (Reason='(null)', Id=ca15a517-9dcb-4d72-9ec1-904d3da8c12f)
2024-06-05T20:20:45.412 [Information] Executing 'Functions.SimpleServiceBusSenderReceiver' (Reason='(null)', Id=d1a46d70-1978-4db2-b9cd-5689cd3001c8)
2024-06-05T20:20:45.412 [Information] Executing 'Functions.SimpleServiceBusReceiver' (Reason='(null)', Id=a0180435-0b41-4fd9-965c-7b934bfb68f8)
2024-06-05T20:20:45.412 [Information] Executing 'Functions.SimpleServiceBusReceiver' (Reason='(null)', Id=443b7c7e-33ed-4435-8e24-b064bd35c78f)
2024-06-05T20:20:45.415 [Information] Trigger Details: MessageId: eb7955308e6c483ea6e180e39da173c1, SequenceNumber: 2, DeliveryCount: 5, EnqueuedTimeUtc: 2024-06-05T20:16:38.1070000+00:00, LockedUntilUtc: 2024-06-05T20:21:45.2540000+00:00, SessionId: (null)
WARNING: 2024-06-05T20:20:45.415 [Information] Trigger Details: MessageId: 73c073484cac46d5a7941ce9cc1ecdf5, SequenceNumber: 3, DeliveryCount: 5, EnqueuedTimeUtc: 2024-06-05T20:16:38.1070000+00:00, LockedUntilUtc: 2024-06-05T20:21:45.2390000+00:00, SessionId: (null)
WARNING: 2024-06-05T20:20:45.416 [Information] Trigger Details: MessageId: 6481460d80164c02912948ef9f3d28b1, SequenceNumber: 1, DeliveryCount: 5, EnqueuedTimeUtc: 2024-06-05T20:16:38.1070000+00:00, LockedUntilUtc: 2024-06-05T20:21:45.2540000+00:00, SessionId: (null)
2024-06-05T20:20:45.416 [Information] Trigger Details: MessageId: 7cce0ea9604e441788d7f893dd0058dc, SequenceNumber: 15, DeliveryCount: 5, EnqueuedTimeUtc: 2024-06-05T20:16:44.2320000+00:00, LockedUntilUtc: 2024-06-05T20:21:45.2540000+00:00, SessionId: (null)
2024-06-05T20:20:45.416 [Information] Trigger Details: MessageId: a90319fe92124910a05446dd6e9041d3, SequenceNumber: 12, DeliveryCount: 5, EnqueuedTimeUtc: 2024-06-05T20:16:42.2010000+00:00, LockedUntilUtc: 2024-06-05T20:21:45.2390000+00:00, SessionId: (null)
2024-06-05T20:20:45.416 [Information] Trigger Details: MessageId: 909a5f4048e74eb79e4376d572567353, SequenceNumber: 8, DeliveryCount: 5, EnqueuedTimeUtc: 2024-06-05T20:16:40.2160000+00:00, LockedUntilUtc: 2024-06-05T20:21:45.2540000+00:00, SessionId: (null)
2024-06-05T20:20:45.416 [Information] Trigger Details: MessageId: ae9289783ce94244bfd86ed7a3090993, SequenceNumber: 7, DeliveryCount: 5, EnqueuedTimeUtc: 2024-06-05T20:16:40.2160000+00:00, LockedUntilUtc: 2024-06-05T20:21:45.2540000+00:00, SessionId: (null)
WARNING: 2024-06-05T20:20:45.416 [Information] Trigger Details: MessageId: f3069b2886b64b69a979a8cbed034857, SequenceNumber: 6, DeliveryCount: 5, EnqueuedTimeUtc: 2024-06-05T20:16:40.2160000+00:00, LockedUntilUtc: 2024-06-05T20:21:45.2540000+00:00, SessionId: (null)
WARNING: 2024-06-05T20:20:45.416 [Information] Trigger Details: MessageId: 011ab8d040964b9d8692799274d204e7, SequenceNumber: 9, DeliveryCount: 5, EnqueuedTimeUtc: 2024-06-05T20:16:42.2010000+00:00, LockedUntilUtc: 2024-06-05T20:21:45.2390000+00:00, SessionId: (null)
2024-06-05T20:20:45.416 [Information] Trigger Details: MessageId: 7242a62173f04512b533160ba466a81a, SequenceNumber: 16, DeliveryCount: 5, EnqueuedTimeUtc: 2024-06-05T20:16:44.2320000+00:00, LockedUntilUtc: 2024-06-05T20:21:45.2540000+00:00, SessionId: (null)
2024-06-05T20:20:45.416 [Information] Trigger Details: MessageId: 567e260c09434401a81ab485715c9bf7, SequenceNumber: 4, DeliveryCount: 5, EnqueuedTimeUtc: 2024-06-05T20:16:38.1070000+00:00, LockedUntilUtc: 2024-06-05T20:21:45.2540000+00:00, SessionId: (null)
WARNING: 2024-06-05T20:20:45.698 [Information] Executing 'Functions.SimpleServiceBusReceiver' (Reason='(null)', Id=c66341fd-d636-4b89-95b6-32dabdf1ae52)
WARNING: 2024-06-05T20:20:45.706 [Information] Trigger Details: MessageId: 9420c51d13b144ed983bbdca761b1ab2, SequenceNumber: 10, DeliveryCount: 5, EnqueuedTimeUtc: 2024-06-05T20:16:42.2010000+00:00, LockedUntilUtc: 2024-06-05T20:21:45.2230000+00:00, SessionId: (null)
WARNING: 2024-06-05T20:20:45.709 [Information] Executing 'Functions.SimpleServiceBusReceiver' (Reason='(null)', Id=e39ca1de-d991-4baa-ac48-e0dbccdeb4f5)
2024-06-05T20:20:45.709 [Information] Trigger Details: MessageId: cb42c500c771421f9fa00b8e9eacb82f, SequenceNumber: 13, DeliveryCount: 5, EnqueuedTimeUtc: 2024-06-05T20:16:44.2320000+00:00, LockedUntilUtc: 2024-06-05T20:21:45.2390000+00:00, SessionId: (null)
2024-06-05T20:20:45.709 [Information] Executing 'Functions.SimpleServiceBusReceiver' (Reason='(null)', Id=7c8b1fd8-17f1-4d43-97cc-619ecc1b1ea7)
2024-06-05T20:20:45.709 [Information] Trigger Details: MessageId: 565aff3e44ff48c28766eb5eeeec24ce, SequenceNumber: 5, DeliveryCount: 5, EnqueuedTimeUtc: 2024-06-05T20:16:40.2160000+00:00, LockedUntilUtc: 2024-06-05T20:21:45.2540000+00:00, SessionId: (null)
WARNING: 2024-06-05T20:20:45.709 [Information] Executing 'Functions.SimpleServiceBusSenderReceiver' (Reason='(null)', Id=f5c65ff2-8836-4dc1-bb5a-e2c079d2f1a8)
WARNING: 2024-06-05T20:20:45.709 [Information] Trigger Details: MessageId: 8419bbfc1da04a56be732c730ffa45aa, SequenceNumber: 14, DeliveryCount: 5, EnqueuedTimeUtc: 2024-06-05T20:16:44.2320000+00:00, LockedUntilUtc: 2024-06-05T20:21:45.2390000+00:00, SessionId: (null)
WARNING: 2024-06-05T20:20:45.709 [Information] Executing 'Functions.SimpleServiceBusSenderReceiver' (Reason='(null)', Id=dc02997a-310f-4417-af75-e0730970ef51)
WARNING: 2024-06-05T20:20:45.709 [Information] Trigger Details: MessageId: ade10a8e06a6472c8e1bca58ae13d0c4, SequenceNumber: 11, DeliveryCount: 5, EnqueuedTimeUtc: 2024-06-05T20:16:42.2010000+00:00, LockedUntilUtc: 2024-06-05T20:21:45.2390000+00:00, SessionId: (null)
WARNING: 2024-06-05T20:20:45.696 [Information] Executing 'Functions.SimpleServiceBusReceiver' (Reason='(null)', Id=c66341fd-d636-4b89-95b6-32dabdf1ae52)
WARNING: 2024-06-05T20:20:45.706 [Information] Trigger Details: MessageId: 9420c51d13b144ed983bbdca761b1ab2, SequenceNumber: 10, DeliveryCount: 5, EnqueuedTimeUtc: 2024-06-05T20:16:42.2010000+00:00, LockedUntilUtc: 2024-06-05T20:21:45.2230000+00:00, SessionId: (null)
2024-06-05T20:20:45.709 [Information] Executing 'Functions.SimpleServiceBusSenderReceiver' (Reason='(null)', Id=f5c65ff2-8836-4dc1-bb5a-e2c079d2f1a8)
2024-06-05T20:20:45.709 [Information] Trigger Details: MessageId: 8419bbfc1da04a56be732c730ffa45aa, SequenceNumber: 14, DeliveryCount: 5, EnqueuedTimeUtc: 2024-06-05T20:16:44.2320000+00:00, LockedUntilUtc: 2024-06-05T20:21:45.2390000+00:00, SessionId: (null)
WARNING: 2024-06-05T20:20:45.709 [Information] Executing 'Functions.SimpleServiceBusReceiver' (Reason='(null)', Id=e39ca1de-d991-4baa-ac48-e0dbccdeb4f5)
WARNING: 2024-06-05T20:20:45.709 [Information] Trigger Details: MessageId: cb42c500c771421f9fa00b8e9eacb82f, SequenceNumber: 13, DeliveryCount: 5, EnqueuedTimeUtc: 2024-06-05T20:16:44.2320000+00:00, LockedUntilUtc: 2024-06-05T20:21:45.2390000+00:00, SessionId: (null)
2024-06-05T20:20:45.709 [Information] Executing 'Functions.SimpleServiceBusSenderReceiver' (Reason='(null)', Id=dc02997a-310f-4417-af75-e0730970ef51)
2024-06-05T20:20:45.709 [Information] Trigger Details: MessageId: ade10a8e06a6472c8e1bca58ae13d0c4, SequenceNumber: 11, DeliveryCount: 5, EnqueuedTimeUtc: 2024-06-05T20:16:42.2010000+00:00, LockedUntilUtc: 2024-06-05T20:21:45.2390000+00:00, SessionId: (null)
2024-06-05T20:20:45.709 [Information] Executing 'Functions.SimpleServiceBusReceiver' (Reason='(null)', Id=7c8b1fd8-17f1-4d43-97cc-619ecc1b1ea7)
2024-06-05T20:20:45.709 [Information] Trigger Details: MessageId: 565aff3e44ff48c28766eb5eeeec24ce, SequenceNumber: 5, DeliveryCount: 5, EnqueuedTimeUtc: 2024-06-05T20:16:40.2160000+00:00, LockedUntilUtc: 2024-06-05T20:21:45.2540000+00:00, SessionId: (null)
2024-06-05T20:20:46.437 [Error] Unhandled exception. System.IO.FileNotFoundException: Could not load file or assembly 'Microsoft.Extensions.Diagnostics, Version=8.0.0.0, Culture=neutral, PublicKeyToken=adb9793829ddae60'. The system cannot find the file specified.
2024-06-05T20:20:46.437 [Information] File name: 'Microsoft.Extensions.Diagnostics, Version=8.0.0.0, Culture=neutral, PublicKeyToken=adb9793829ddae60'
2024-06-05T20:20:46.437 [Information] at Microsoft.Extensions.Hosting.HostBuilder.PopulateServiceCollection(IServiceCollection services, HostBuilderContext hostBuilderContext, HostingEnvironment hostingEnvironment, PhysicalFileProvider defaultFileProvider, IConfiguration appConfiguration, Func`1 serviceProviderGetter)
2024-06-05T20:20:46.437 [Information] at Microsoft.Extensions.Hosting.HostBuilder.InitializeServiceProvider()
2024-06-05T20:20:46.437 [Information] at Microsoft.Extensions.Hosting.HostBuilder.Build()
2024-06-05T20:20:46.437 [Information] at Program.<Main>$(String[] args) in C:\Users\shein\source\repos\SimplerServiceBusSendReceiveDemo\SimpleServiceBusSendReceiveAzureFuncs\SimpleServiceBusSenderReceiverMainProgram.cs:line 3
2024-06-05T20:20:46.457 [Error] Exceeded language worker restart retry count for runtime:dotnet-isolated. Shutting down and proactively recycling the Functions Host to recover
2024-06-05T20:20:46.483 [Information] Stopping JobHost
2024-06-05T20:20:46.487 [Information] Stopping the listener 'Microsoft.Azure.WebJobs.ServiceBus.Listeners.ServiceBusListener' for function 'SimpleServiceBusReceiver'
2024-06-05T20:20:46.555 [Information] Stopping the listener 'Microsoft.Azure.WebJobs.ServiceBus.Listeners.ServiceBusListener' for function 'SimpleServiceBusSenderReceiver'

*/