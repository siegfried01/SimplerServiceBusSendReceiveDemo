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
   $env:uniquePrefix="$(If ($env:USERNAME -eq "v-richardsi") {"u2gzyv3"} Else { "jyzwg" })"
   $env:loc=If ($env:AZ_DEFAULT_LOC) { $env:AZ_DEFAULT_LOC } Else { "eastus2" }
   $env:funcLoc=$env:loc
   $env:storageAccountName="$($env:uniquePrefix)stg"
   $env:functionAppName="$($env:uniquePrefix)-func"
   $env:funcPlanName="$($env:uniquePrefix)-plan-func"
   $env:serviceBusNS="$($env:uniquePrefix)-servicebus"
   $env:serviceBusQueue="mainqueue001"
   write-output "starting $(Get-Date) noManagedIdent=$($noManagedIdent)"
   $StartTime = $(get-date)
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

   emacs ESC 5 F10
   Begin commands to deploy this file using Azure CLI with PowerShell
   write-output "step 5 Create Storage Account for Function App"
   write-output "az storage account create --name $env:storageAccountName  --resource-group $env:rg --location $env:loc --sku Standard_LRS --access-tier Cool"
   az storage account create --name $env:storageAccountName  --resource-group $env:rg --location $env:loc --sku Standard_LRS --access-tier Cool
   End commands to deploy this file using Azure CLI with PowerShell

   emacs ESC 6 F10
   Begin commands to deploy this file using Azure CLI with PowerShell
   write-output "step 6 Show Connection strings for storage Storage Account for Function App"
   write-output "az storage account show-connection-string --resource-group $env:rg --name $env:storageAccountName --output TSV"
   az storage account show-connection-string --resource-group $env:rg --name $env:storageAccountName --output TSV
   End commands to deploy this file using Azure CLI with PowerShell

   emacs ESC 7 F10
   Begin commands to deploy this file using Azure CLI with PowerShell
   write-output "step 7 Create Linux  Function App Plan "
   az functionapp plan create --name "$($env:funcPlanName)-linux" --resource-group $env:rg --sku B1 --location $env:loc --is-linux true
   End commands to deploy this file using Azure CLI with PowerShell

   emacs ESC 8 F10
   Begin commands to deploy this file using Azure CLI with PowerShell
   write-output "step 8 Create Function App Windows Plan Skip this because to create a free function app we cannot explicity create a plant"
   write-output "az functionapp plan create --name $env:funcPlanName --resource-group $env:rg --sku F1 --location $env:loc"
   az functionapp plan create --name $env:funcPlanName --resource-group $env:rg --sku F1 --location $env:loc
   End commands to deploy this file using Azure CLI with PowerShell

   emacs ESC 9 F10
   Begin commands to deploy this file using Azure CLI with PowerShell
   write-output "step 9 show Storage Account for Function App"
   write-output "az storage account show-connection-string --resource-group $env:rg --name $env:storageAccountName --output TSV"
   az storage account show-connection-string --resource-group $env:rg --name $env:storageAccountName --output TSV
   az storage account show-connection-string --resource-group $env:rg --name $env:storageAccountName 
   End commands to deploy this file using Azure CLI with PowerShell

   emacs ESC 10 F10
   Begin commands to deploy this file using Azure CLI with PowerShell
   write-output "step 10 Create Windows Function App"
   write-output "az functionapp create --resource-group $env:rg --consumption-plan-location $env:loc --runtime dotnet-isolated --runtime-version 8.0 --functions-version 4 --name $env:functionAppName --storage-account $env:storageAccountName"
   az functionapp create --resource-group $env:rg --consumption-plan-location $env:loc --runtime dotnet-isolated --runtime-version 8.0 --functions-version 4 --name $env:functionAppName --storage-account $env:storageAccountName
   az functionapp config appsettings list -n $env:functionAppName -g $env:rg
   End commands to deploy this file using Azure CLI with PowerShell

   emacs ESC 11 F10
   Begin commands to deploy this file using Azure CLI with PowerShell
   write-output "step 11 create service bus "
   write-output "az servicebus namespace create --resource-group $env:rg --name $env:serviceBusNS --location $env:loc --sku Basic"
   az servicebus namespace create --resource-group $env:rg --name $env:serviceBusNS --location $env:loc --sku Basic
   write-output "az servicebus queue create --resource-group $env:rg --namespace-name $env:serviceBusNS --name $env:serviceBusQueue"
   az servicebus queue create --resource-group $env:rg --namespace-name $env:serviceBusNS --name $env:serviceBusQueue
   write-output "az servicebus namespace authorization-rule keys list --resource-group $env:rg --namespace-name $env:serviceBusNS --name RootManageSharedAccessKey --query primaryConnectionString --output tsv"
   $env:ServiceBusConnection=(az servicebus namespace authorization-rule keys list --resource-group $env:rg --namespace-name $env:serviceBusNS --name RootManageSharedAccessKey --query primaryConnectionString --output tsv)
   write-output "(setenv `"ServiceBusConnection`" `"$($env:ServiceBusConnection)`")"
   write-output "az webapp config connection-string set --name $env:functionAppName --resource-group $env:rg --settings ServiceBusConnection=$env:ServiceBusConnection --connection-string-type Custom"
   az webapp config connection-string set --name $env:functionAppName --resource-group $env:rg --settings ServiceBusConnection=$env:ServiceBusConnection --connection-string-type Custom
   End commands to deploy this file using Azure CLI with PowerShell

   emacs ESC 12 F10
   Begin commands to deploy this file using Azure CLI with PowerShell
   write-output "step 12 show service bus add connection string"
   write-output "az functionapp config appsettings set --name $env:functionAppName --resource-group $env:rg --settings busNS=$($env:serviceBusNS)"
   az functionapp config appsettings set --name $env:functionAppName --resource-group $env:rg --settings busNS=$env:serviceBusNS
   write-output "az functionapp config appsettings set --name $env:functionAppName --resource-group $env:rg --settings queue=$env:serviceBusQueue"
   az functionapp config appsettings set --name $env:functionAppName --resource-group $env:rg --settings queue=$env:serviceBusQueue
   write-output "az webapp config connection-string list --name $env:functionAppName --resource-group $env:rg"
   az webapp config connection-string list --name $env:functionAppName --resource-group $env:rg
   write-output "az functionapp config appsettings list -n $env:functionAppName -g $env:rg"
   az functionapp config appsettings list -n $env:functionAppName -g $env:rg
   End commands to deploy this file using Azure CLI with PowerShell

   emacs ESC 13 F10
   Begin commands to deploy this file using Azure CLI with PowerShell
   write-output "step 13 Create Linux Function App WARNING: dotnet-isolated will reach EOL on 2024-11-12 and will no longer be supported. https://azure.microsoft.com/en-us/updates/dotnet6support/"
   write-output "az functionapp create --resource-group $env:rg --consumption-plan-location $env:loc --runtime dotnet-isolated  --functions-version 4 --name $env:functionAppName --storage-account $env:storageAccountName --runtime dotnet-isolated --runtime-version 8.0 --os-type Linux"
   az functionapp create --resource-group $env:rg --consumption-plan-location $env:loc --runtime dotnet-isolated  --functions-version 4 --name $env:functionAppName --storage-account $env:storageAccountName --runtime dotnet-isolated --runtime-version 8.0 --os-type Linux
   az functionapp config appsettings list -n $env:functionAppName -g $env:rg
   End commands to deploy this file using Azure CLI with PowerShell

   emacs ESC 14 F10
   Begin commands to deploy this file using Azure CLI with PowerShell
   write-output "step 14 Configure Linux Function App: Why does this giv an error: ERROR: Runtime  is not supported."
   az functionapp config appsettings set --name $env:functionAppName --resource-group $env:rg --settings "busNS=$($env:serviceBusNS)"
   az functionapp config appsettings set --name $env:functionAppName --resource-group $env:rg --settings "queue=$($env:serviceBusQueue)"
   az functionapp config appsettings list -n $env:functionAppName -g $env:rg
   End commands to deploy this file using Azure CLI with PowerShell

   emacs ESC 15 F10
   Begin commands to deploy this file using Azure CLI with PowerShell
   write-output "step 15 Delete Function App"
   write-output "az functionapp delete --resource-group $env:rg --name $env:functionAppName --keep-empty-plan"
   az functionapp delete --resource-group $env:rg --name $env:functionAppName --keep-empty-plan
   End commands to deploy this file using Azure CLI with PowerShell

   emacs ESC 16 F10
   Begin commands to deploy this file using Azure CLI with PowerShell
   write-output "step 16 Publish"
   $path = "publish-functionapp"
   if (Test-Path -LiteralPath $path) {
       write-output "Remove-Item -LiteralPath $path  -Recurse"
       Remove-Item -LiteralPath $path -Verbose -Recurse
   } else {
      write-output "Path doesn't exist: $path create it"
      New-Item -Path "." -Name $Path -ItemType Directory
   }
   write-output "dotnet publish ../SimpleServiceBusSendReceiveAzureFuncs  --configuration Release  -f net8.0  --self-contained --output ./publish-functionapp"
   dotnet publish ../SimpleServiceBusSendReceiveAzureFuncs  --configuration Release  -f net8.0 --self-contained --output ./publish-functionapp
   End commands to deploy this file using Azure CLI with PowerShell

   This code will eventually reside in the pipeline yaml
   emacs ESC 17 F10
   Begin commands to deploy this file using Azure CLI with PowerShell
   write-output "step 17 zip"
   $path = "publish-functionapp.zip"
   if (Test-Path -LiteralPath $path) {
       write-output "Remove-Item -LiteralPath $path "
       Remove-Item -LiteralPath $path
   } else {
      write-output "$path doesn't exist"
   }
   pushd ./publish-functionapp
   write-output "Compress-Archive -Path .\* -DestinationPath ../publish-functionapp.zip -Force"
   Compress-Archive -Path .\* -DestinationPath ../publish-functionapp.zip -Force
   popd
   End commands to deploy this file using Azure CLI with PowerShell
   
   https://learn.microsoft.com/en-us/azure/azure-functions/dotnet-isolated-process-guide?tabs=windows
   
   https://docs.microsoft.com/en-US/cli/azure/functionapp/config/appsettings#az_functionapp_config_appsettings_list
Read more about the command in reference docs

   This code will eventually reside in the pipeline yaml
   emacs ESC 18 F10
   Begin commands to deploy this file using Azure CLI with PowerShell
   write-output "step 18 configure windows function app. Skip this because it is no longer necessary since Siegfried updated the bicep from .NET 6  to .NET 8 Isolated"
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
   write-output "az functionapp config appsettings list -n $env:functionAppName -g $env:rg"
   az functionapp config appsettings list -n $env:functionAppName -g $env:rg
   End commands to deploy this file using Azure CLI with PowerShell

   Certificate verification failed. This typically happens when using Azure CLI behind a proxy that intercepts traffic with a self-signed certificate. Please add this certificate to the trusted CA bundle. More info: https://docs.microsoft.com/cli/azure/use-cli-effectively#work-behind-a-proxy.
   This code will eventually be replace by EV2 resident JSON ARM template that does zipdeploy
   emacs ESC 19 F10
   Begin commands to deploy this file using Azure CLI with PowerShell
   write-output "step 19 deploy compiled C# code deployment to azure resource. For Linux Func created with azure cli this gives error: ERROR: Runtime  is not supported."
   write-output "az functionapp deployment source config-zip -g $env:rg -n $env:functionAppName --src ./publish-functionapp.zip"
   az functionapp deployment source config-zip -g $env:rg -n $env:functionAppName --src ./publish-functionapp.zip
   End commands to deploy this file using Azure CLI with PowerShell

   emacs ESC 20 F10
   Begin commands to deploy this file using Azure CLI with PowerShell
   write-output "step 20 webapp tail logs"
   write-output "az webapp log tail -g $env:rg -n $env:functionAppName"
   az webapp log tail -g $env:rg -n $env:functionAppName
   End commands to deploy this file using Azure CLI with PowerShell

   emacs ESC 21 F10
   Begin commands to deploy this file using Azure CLI with PowerShell
   write-output "step 21 get the logs This is not working and I don't now why"
   write-output "curl -X GET 'https://$($env:uniquePrefix)-func.scm.azurewebsites.net/api/dump'"
   curl  "https://$($env:uniquePrefix)-func.scm.azurewebsites.net/api/dump"
   dir
   End commands to deploy this file using Azure CLI with PowerShell

   Begin common epilog commands
   #Get-AzResource -ResourceGroupName $env:rg | ft
   az resource list -g $env:rg --query "[?resourceGroup=='$env:rg'].{ name: name, flavor: kind, resourceType: type, region: location }" --output table | ForEach-Object { $_ -replace "`r", ""}
   $elapsedTime = $(get-date) - $StartTime
   $totalTime = "{0:HH:mm:ss}" -f ([datetime]$elapsedTime.Ticks)
   write-output "all done $(Get-Date) elapse time = $totalTime "
   End common epilog commands
   https://stackoverflow.com/questions/10941756/powershell-show-elapsed-time

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
      //windowsFxVersion: 'pdotnet-isolated|8'
      numberOfWorkers: 1
      acrUseManagedIdentityCreds: false
      alwaysOn: false
      http20Enabled: false
      functionAppScaleLimit: 200
      minimumElasticInstanceCount: 0
      appSettings: [
        {
          name: 'FUNCTIONS_EXTENSION_VERSION'
          value: '~4'
        }
        {
          name: 'WEBSITE_USE_PLACEHOLDER_DOTNETISOLATED'
          value: '1'
        }
        {
          name: 'FUNCTIONS_WORKER_RUNTIME'
          value: 'dotnet-isolated'
        }
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
  // error "This server farm 'jqo0osm3qxqr-func-plan' must contain only Function Apps."
  // error: "The resource write operation failed to complete successfully, because it reached terminal provisioning state 'Failed'.
  // resource sourcecontrol 'sourcecontrols@2020-12-01' = {
  //   name: 'web'
  //   properties: {
  //     repoUrl: 'https://github.com/siegfried01/SimplerServiceBusSendReceiveDemo.git'
  //     branch: 'master'
  //     isManualIntegration: false      
  //   }
  // }  
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
    netFrameworkVersion: 'v8.0'
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
    config: {
      language: 'dotnet-isolated'
      bindings: [
        {
          name: 'message'
          direction: 'In'
          type: 'serviceBusTrigger'
          queueName: 'mainqueue001'
          connection: 'ServiceBusConnection'
          cardinality: 'One'
          properties: {
            supportsDeferredBinding: 'True'
          }
        }
      ]
    }
    language: 'dotnet-isolated'
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

