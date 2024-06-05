/*
   Begin common prolog commands
   $env:subscriptionId=(az account show --query id --output tsv | tr -d '\r')
   $noManagedIdentity=($env:subscriptionId -eq "13c9725f-d20a-4c99-8ef4-d7bb78f98cff")
   write-output "noManagedIdentity= $($noManagedIdentity)"
   $env:name=$(If ($noManagedIdentity) { "siegfriedServiceBusSimpleSendReceive"} Else {"ServiceBusSimpleSendReceive"} )
   $env:rg="rg_$env:name"
   write-output "resource group=$env:rg"
   $env:random=$(If ($noManagedIdentity) {"l2ydjsjlzxaoe"} Else { "aryxbqmevvg3e" })
   $env:loc="westus2"
   $env:funcLoc=$(If ($noManagedIdentity) {"eastus2"} Else { $env:loc })
   $env:functionAppName="$($env:random)-func"
   write-output "func=$env:functionAppName"
   End common prolog commands
   
   emacs F10
   Begin commands to deploy this file using Azure CLI with PowerShell
   cd ..
   write-output "az deployment group create --name $env:name --resource-group $env:rg   --template-file  infrastructure/deploy-ServiceBusSimpleSendReceive.bicep"
   az deployment group create --name $env:name --resource-group $env:rg  --template-file  infrastructure/deploy-ServiceBusSimpleSendReceive.bicep --parameters "{'funcLoc': {'value': 'eastus2'}}" "{'noManagedIdentity': {'value': $noManagedIdentity}}" 
   write-output "end deploy"
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
   Begin commands to deploy this file using Azure CLI with PowerShell
   write-output "step 4 delete resource group"
   write-output "az group delete -n $env:rg --yes"
   az group delete  -n $env:rg --yes
   End commands to deploy this file using Azure CLI with PowerShell

   emacs ESC 5 F10
   Begin commands to deploy this file using Azure CLI with PowerShell
   write-output "step 5 Publish"
   write-output "dotnet publish ../SimplerServiceBusSenderReceiver.csproj   --configuration Release  --output ./publish-functionapp"
   dotnet publish ../SimplerServiceBusSenderReceiver.csproj  --configuration Release  --output ./publish-functionapp
   End commands to deploy this file using Azure CLI with PowerShell

   emacs ESC 6 F10
   Begin commands to deploy this file using Azure CLI with PowerShell
   write-output "step 6 zip"
   pushd ./publish-functionapp
   write-output "Compress-Archive -Path .\* -DestinationPath ../publish-functionapp.zip -Force"
   Compress-Archive -Path .\* -DestinationPath ../publish-functionapp.zip -Force
   popd
   End commands to deploy this file using Azure CLI with PowerShell

   https://learn.microsoft.com/en-us/azure/azure-functions/dotnet-isolated-process-guide?tabs=windows

   emacs ESC 7 F10
   Begin commands to deploy this file using Azure CLI with PowerShell
   write-output "step 7 configure function app"
   write-output "az functionapp config appsettings set -g $env:rg -n $env:functionAppName --settings 'WEBSITE_USE_PLACEHOLDER_DOTNETISOLATED=1'"
   az functionapp config appsettings set -g $env:rg -n $env:functionAppName --settings WEBSITE_USE_PLACEHOLDER_DOTNETISOLATED=1
   write-output "az functionapp config set -g $env:rg -n $env:functionAppName --net-framework-version 'v8.0'"
   az functionapp config set -g $env:rg -n $env:functionAppName --net-framework-version v8.0
   write-output "az functionapp config set -g $env:rg -n $env:functionAppName --use-32bit-worker-process false"
   az functionapp config set -g $env:rg -n $env:functionAppName --use-32bit-worker-process false
   write-output "az functionapp config appsettings set --name $env:functionAppName --resource-group $env:rg --settings FUNCTIONS_EXTENSION_VERSION=~4"
   az functionapp config appsettings set --name $env:functionAppName --resource-group $env:rg --settings FUNCTIONS_EXTENSION_VERSION=~4
   End commands to deploy this file using Azure CLI with PowerShell

   emacs ESC 8 F10
   Begin commands to deploy this file using Azure CLI with PowerShell
   write-output "step 8 deploy compiled #C code deployment to azure resource"
   write-output "az functionapp deployment source config-zip -g $env:rg -n $env:functionAppName --src ./publish-functionapp.zip"
   az functionapp deployment source config-zip -g $env:rg -n $env:functionAppName --src ./publish-functionapp.zip
   End commands to deploy this file using Azure CLI with PowerShell

   emacs ESC 9 F10
   Begin commands to deploy this file using Azure CLI with PowerShell
   write-output "step 9 get the logs"
   write-output "curl -X GET 'https://$($env:random)-func.scm.azurewebsites.net/api/dump'"
   curl  "https://$($env:random)-func.scm.azurewebsites.net/api/dump"
   dir
   End commands to deploy this file using Azure CLI with PowerShell

   Begin common epilog commands
   az resource list -g $env:rg --query "[?resourceGroup=='$env:rg'].{ name: name, flavor: kind, resourceType: type, region: location }" --output table  | ForEach-Object { $_ -replace "`r", ""}
   write-output "all done $(Get-Date)"
   End common epilog commands


 */

param queueName string = 'mainqueue001'
param loc string = resourceGroup().location
param funcLoc string = loc
param noManagedIdentity bool = false
param name string = uniqueString(resourceGroup().id)
param sbdemo001NS_name string = '${name}-servicebus'


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
output noManagedIdentityoutput bool = noManagedIdentity


param ServiceBusSenderReceiverPlans string = '${name}-func'
resource functionPlan 'Microsoft.Web/serverfarms@2023-01-01' = {
  name: '${name}-func-plan'
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
          connectionString: noManagedIdentity? serviceBusConnection : serviceBusConnectionViaMSI
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


module  assignRoleToFunctionApp 'assignRbacRoleToFunctionApp.bicep' = if (!noManagedIdentity) {
  name: 'assign-role-to-functionApp'
  params: {
	roleScope: resourceGroup().id
	functionAppName: ServiceBusSenderReceiverFunctions.name
    functionPrincipalId: ServiceBusSenderReceiverFunctions.identity.principalId
  }
}



