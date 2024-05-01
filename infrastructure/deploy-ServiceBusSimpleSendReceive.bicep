/*
   Begin common prolog commands
   export name=ServiceBusSimpleSendReceive
   export rg=rg_${name}
   export random=aryxbqmevvg3e
   export loc=westus2
   export newDeploymentStorage="${random}stg"
   export newDeploymentContainer="${random}cntr"
   export subscriptionId=`az account show --query id --output tsv | tr -d '\r'`
   export functionAppName=aryxbqmevvg3e-func
   End common prolog commands
   
   emacs F10
   Begin commands to deploy this file using Azure CLI with bash
   #echo WaitForBuildComplete
   #WaitForBuildComplete
   #echo "Previous build is complete. Begin deployment build."
   cd ..
   az deployment group create --name $name --resource-group $rg   --template-file  infrastructure/deploy-ServiceBusSimpleSendReceive.bicep
   echo end deploy
   az resource list -g $rg --query "[?resourceGroup=='$rg'].{ name: name, flavor: kind, resourceType: type, region: location }" --output table
   End commands to deploy this file using Azure CLI with bash

   New-AzResourceGroupDeployment -name "ServiceBusSimpleSendReceive" -Mode "Incremental"  -TemplateFile deploy-ServiceBusSimpleSendReceive.bicep

   emacs ESC 2 F10
   Begin commands to shut down this deployment using Azure CLI with bash
   echo step 2
   #echo CreateBuildEvent.exe
   #CreateBuildEvent.exe&
   echo "begin shutdown"
   az deployment group create --mode complete --template-file ./clear-resources.json --resource-group $rg
   #BuildIsComplete.exe
   az resource list -g $rg --query "[?resourceGroup=='$rg'].{ name: name, flavor: kind, resourceType: type, region: location }" --output table
   echo "showdown is complete"
   End commands to shut down this deployment using Azure CLI with bash

   emacs ESC 3 F10
   Begin commands for one time initializations using Azure CLI with bash
   echo step 3
   az group create -l $loc -n $rg
   echo "go to github settings->secrets and create a secret called AZURE_CREDENTIALS with the above output"
   cat >clear-resources.json <<EOF
   {
    "\$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#",
     "contentVersion": "1.0.0.0",
     "resources": [] 
   }
   EOF
   End commands for one time initializations using Azure CLI with bash

   // https://learn.microsoft.com/en-us/azure/developer/github/connect-from-azure?tabs=azure-cli%2Cwindows#use-the-azure-login-action-with-a-service-principal-secret
   emacs ESC 4 F10
   Begin commands for one time initializations using Azure CLI with bash
   echo step 4
   export id=`az group show --name $rg --query 'id' --output tsv`
   echo "id=$id"
   export sp="spad_${name}"
   echo az ad sp create-for-rbac --name $sp  --role contributor --scopes $id --json-auth
   az ad sp create-for-rbac --name $sp  --role contributor --scopes $id --json-auth
   echo "go to github settings->secrets and create a secret called AZURE_CREDENTIALS with the above output"
   End commands for one time initializations using Azure CLI with bash

   emacs ESC 5 F10
   Begin commands to deploy this file using Azure CLI with bash
   echo step 5
   az role assignment list --resource-group rg_ServiceBusSimpleSendReceive
   End commands to deploy this file using Azure CLI with bash

   This seems to work, how to I confirm it?
   emacs ESC 6 F10
   Begin commands to deploy this file using Azure CLI with bash
   echo step 6
   $appid=`az ad sp list --display-name "spad_ServiceBusSimpleSendReceive" --query "[0].appId" --output tsv`
   echo "appid=$appid"
   az role assignment create --role "Contributor" --assignee $appid --scope "/subscriptions/acc26051-92a5-4ed1-a226-64a187bc27db/resourceGroups/rg_ServiceBusSimpleSendReceive"   
   End commands to deploy this file using Azure CLI with bash

   emacs ESC 7 F10
   Begin commands to deploy this file using Azure CLI with bash
   echo step 7
   echo newDeploymentStorage  = $newDeploymentStorage
   echo newDeploymentContainer = $newDeploymentContainer
   echo subscriptionId = $subscriptionId
   echo rg = $rg
   echo az ad sp create-for-rbac --name $functionAppName --role contributor --scopes /subscriptions/$subscriptionId/resourceGroups/$rg --sdk-auth 
   az ad sp create-for-rbac --name aryxbqmevvg3e-func --role contributor --scopes /subscriptions/$subscriptionId/resourceGroups/$rg --sdk-auth 
   End commands to deploy this file using Azure CLI with bash

   emacs ESC 8 F10
   Begin commands to deploy this file using Azure CLI with bash
   echo step 8
   echo dotnet publish ../SimpleServiceBusSendReceiveAzureFuncs  --configuration Release 
   dotnet publish ../SimpleServiceBusSendReceiveAzureFuncs  --configuration Release 
   End commands to deploy this file using Azure CLI with bash

   emacs ESC 9 F10
   Begin commands to deploy this file using Azure CLI with bash
   echo step 9
   pushd ./publish-functionapp
   pushd c:/Users/v-richardsi/source/repos/SimplerServiceBusSendReceiveDemo/SimpleServiceBusSendReceiveAzureFuncs/bin/Release/net6.0
   zip -r  ../../../../infrastructure/publish-functionapp.zip .
   popd
   End commands to deploy this file using Azure CLI with bash

   emacs ESC 10 F10
   Begin commands to deploy this file using Azure CLI with bash
   echo step 10
   echo az functionapp deployment source config-zip -g $rg -n $functionAppName --src ./publish-functionapp.zip
   az functionapp deployment source config-zip -g $rg -n $functionAppName --src ./publish-functionapp.zip
   End commands to deploy this file using Azure CLI with bash

   az functionapp deployment source config-zip -g rg_ServiceBusSimpleSendReceive -n aryxbqmevvg3e-func --src ./publish-functionapp.zip
   WARNING: Getting scm site credentials for zip deployment
   WARNING: Starting zip deployment. This operation can take a while to complete ...
   WARNING: Deployment endpoint responded with status code 202
   {
     "active": true,
     "author": "N/A",
     "author_email": "N/A",
     "complete": true,
     "deployer": "az_cli_functions",
     "end_time": "2024-05-01T17:54:55.0426584Z",
     "id": "5231f5204ffb469fbc107020dab0b232",
     "is_readonly": true,
     "is_temp": false,
     "last_success_end_time": "2024-05-01T17:54:55.0426584Z",
     "log_url": "https://aryxbqmevvg3e-func.scm.azurewebsites.net/api/deployments/latest/log",
     "message": "Created via a push deployment",
     "progress": "",
     "provisioningState": "Succeeded",
     "received_time": "2024-05-01T17:54:54.5740244Z",
     "site_name": "aryxbqmevvg3e-func",
     "start_time": "2024-05-01T17:54:54.7301599Z",
     "status": 4,
     "status_text": "",
     "url": "https://aryxbqmevvg3e-func.scm.azurewebsites.net/api/deployments/latest"
   }


   emacs ESC 11 F10
   Begin commands to deploy this file using Azure CLI with bash
   echo step 11
   az ad sp list  --query "[].{SPname:displayName, SPid:appId, tenant:appOwnerOrganizationId}" --output table | tr -d '\r'
   End commands to deploy this file using Azure CLI with bash

   emacs ESC 12 F10
   Begin commands to deploy this file using Azure CLI with bash
   echo step 12
   echo az ad sp delete --id fa61738f-f3ce-4246-b6f5-aa966dcc162d
   az ad sp delete --id fa61738f-f3ce-4246-b6f5-aa966dcc162d
   End commands to deploy this file using Azure CLI with bash

   emacs ESC 13 F10
   Begin commands to deploy this file using Azure CLI with bash
   echo step 13
   echo az webapp log tail -g $rg -n "${random}-func"
   az webapp log tail -g $rg -n "${random}-func"
   End commands to deploy this file using Azure CLI with bash
   
   Begin common epilog commands
   az resource list -g $rg --query "[?resourceGroup=='$rg'].{ name: name, flavor: kind, resourceType: type, region: location }" --output table | tr -d '\r'
   End common epilog commands


 */



param queueName string = 'mainqueue001'
param loc string = resourceGroup().location
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


param ServiceBusSenderReceiverPlans string = '${name}-func'
resource func_plan 'Microsoft.Web/serverfarms@2023-01-01' = {
  name: '${name}-func-plan'
  location: loc
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
  location: loc
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
    serverFarmId: func_plan.id
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
          connectionString: serviceBusConnectionViaMSI
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

module  assignRoleToFunctionApp 'assignRbacRoleToFunctionApp.bicep' = {

  name: 'assign-role-to-functionApp'
  params: {
	roleScope: '/subscriptions/acc26051-92a5-4ed1-a226-64a187bc27db/resourcegroups/rg_ServiceBusSimpleSendReceive'
	functionAppName: ServiceBusSenderReceiverFunctions.name
    functionPrincipalId: ServiceBusSenderReceiverFunctions.identity.principalId
  }
}

@description('The URL for the GitHub repository that contains the project to deploy.')
param repoURL string = 'https://github.com/siegfried01/SimplerServiceBusSendReceiveDemo.git'

@description('The branch of the GitHub repository to use.')
param branch string = 'master'


// this only works for a single csproj file in the top level of the repo.
// resource siteName_web 'Microsoft.Web/sites/sourcecontrols@2022-09-01' = {    
//   parent: ServiceBusSenderReceiverFunctions
//   name: 'web'
//   properties: {
//       repoUrl: repoURL
//       branch: branch
//       isManualIntegration: false
//   }
// }



