/*
   From a (cygwin) bash prompt, use this perl one-liner to extract the powershell script fragments and exeucte them. This example shows how to execute steps 2 (shutdown) and steps 4-13 and skipping steps 7,8,9 because they don't work (yet). Adjust that list of steps according to your needs.

   powershell -executionPolicy unrestricted -Command - <<EOF
   `perl -lne 'sub range {$b=shift; $e=shift; $r=""; for(($b..$e)){ $r=$r."," if $r; $r=$r.$_;} $r } BEGIN {  $_ = shift; s/([0-9]+)-([0-9]+)/range($1,$2)/e; @idx=split ","; $c=0; $x=0; $f=0; $s=[] } $c++ if /^\s*Begin/; if (/^\s*End/) {$c--;$s[$f++]=""}; if ($x+$c>1) { $s->[$f]=$s->[$f].$_."\n"  } $x=$c; END { push(@idx, $#s); unshift @idx,0; for (@idx) { $p=$s->[$_]; chomp $p; print $p } }' "2,4-6,10-13" < "deploy-ServiceBusSimpleSendReceive.bicep"  `
EOF

   Begin common prolog commands
   $env:subscriptionId=(az account show --query id --output tsv | ForEach-Object { $_ -replace "`r", ""})
   If ($env:USERNAME -eq "shein") { $env:name='SBusSndRcv' } else { $env:name="SBusSndRcv_$($env:USERNAME)" }
   $env:rg="rg_$($env:name)"
   $env:loc=If ($env:AZ_DEFAULT_LOC) { $env:AZ_DEFAULT_LOC} Else {'eastus2'}
   $env:sp="spad_$env:name"
   $env:uniquePrefix="$(If ($env:USERNAME -eq "v-richardsi") {"eizdf"} ElseIf ($env:USERNAME -eq "v-paperry") { "iucpl" } ElseIf ($env:USERNAME -eq "shein") {"iqa5jvm"} Else { "jyzwg" } )"
   $env:serviceBusQueueName = 'mainqueue001'
   $noManagedIdent=[bool]0
   $useKVForStgConnectionString=[bool]0
   $env:storageAccountName="$($env:uniquePrefix)funcstg"
   $env:functionAppName="$($env:uniquePrefix)-func"
   $env:funcPlanName="$($env:uniquePrefix)-plan-func"
   $env:serviceBusNS="$($env:uniquePrefix)-servicebus"
   $env:logAnalyticsWS= If ($env:USERNAME -eq "shein") { "/subscriptions/acc26051-92a5-4ed1-a226-64a187bc27db/resourceGroups/DefaultResourceGroup-WUS2/providers/Microsoft.OperationalInsights/workspaces/DefaultWorkspace-acc26051-92a5-4ed1-a226-64a187bc27db-WUS2" } else {   "/subscriptions/13c9725f-d20a-4c99-8ef4-d7bb78f98cff/resourceGroups/defaultresourcegroup-wus2/providers/microsoft.operationalinsights/workspaces/defaultworkspace-13c9725f-d20a-4c99-8ef4-d7bb78f98cff-wus2" }
   $StartTime = $(get-date)
   End common prolog commands

   emacs F10
   Begin commands to deploy this file using Azure CLI with PowerShell
   az deployment group create --name $env:name --resource-group $env:rg --mode Incremental   `
     --template-file  "deploy-ServiceBusSimpleSendReceive.bicep"                             `
     --parameters "{'uniquePrefix': {'value': '$env:uniquePrefix'}}"                         `
     "{'location': {'value': '$env:loc'}}"                                                   `
     "{'ownerId': {'value': '$env:AZURE_OBJECTID'}}"                                         `
     "{'noManagedIdent': {'value': $noManagedIdent}}"                                        `
     "{'useKVForStgConnectionString': {'value': $useKVForStgConnectionString}}"              `
     "{'storageAccountName': {'value': '$env:storageAccountName'}}"                          `
     "{'functionAppName': {'value': '$env:functionAppName'}}"                                `
     "{'functionPlanName': {'value': '$env:funcPlanName'}}"                                  `
     "{'serviceBusNS': {'value': '$env:serviceBusNS'}}"                                      `
     "{'serviceBusQueueName': {'value': '$env:serviceBusQueueName'}}"                        `
     "{'logAnalyticsWS': {'value': '$env:logAnalyticsWS'}}"                                  `
   | ForEach-Object { $_ -replace "`r", ""}
   write-output "end deploy $(Get-Date)"
   End commands to deploy this file using Azure CLI with PowerShell

   emacs ESC 2 F10
   Begin commands to shut down this deployment using Azure CLI with PowerShell
   write-output "Step 2: begin shutdown delete (contents only) resource group $env:rg $(Get-Date)"
   $kv=(Get-AzResource -ResourceGroupName $env:rg -ResourceType Microsoft.KeyVault/vaults  |  Select-Object -ExpandProperty Name)
   If (![string]::IsNullOrEmpty($kv)) {
     write-output "keyvault=$kv"
     write-output "az keyvault delete --name '$($env:uniquePrefix)-kv' -g '$env:rg'"
     az keyvault delete --name "$($env:uniquePrefix)-kv" -g "$env:rg"
     write-output "az keyvault purge --name `"$($env:uniquePrefix)-kv`" --location $env:loc"
     az keyvault purge --name "$($env:uniquePrefix)-kv" --location $env:loc 
   } Else {
     write-output "No key vault to delete & purge"
   }
   write-output "az deployment group create --mode complete --template-file ./clear-resources.json --resource-group $env:rg  | ForEach-Object { $_ -replace '`r', ''}"
   az deployment group create --mode complete --template-file ./clear-resources.json --resource-group $env:rg  | ForEach-Object { $_ -replace "`r", ""}
   write-output "showdown is complete $env:rg $(Get-Date)" 
   End commands to shut down this deployment using Azure CLI with PowerShell

   emacs ESC 3 F10
   Begin commands to shut down this deployment using Azure CLI with PowerShell
   write-output "Step 3: begin shutdown delete resource group $env:rg and associated service principal $(Get-Date)"
   write-output "az ad sp list --display-name $env:sp"
   az ad sp list --display-name $env:sp
   write-output "az ad sp list --filter "displayname eq '$env:sp'" --output json"
   $env:spId=(az ad sp list --filter "displayname eq '$env:sp'" --query "[].id" --output tsv)
   write-output "az ad sp delete --id $env:spId"
   az ad sp delete --id $env:spId
   write-output "az group delete -n $env:rg"
   az group delete -n $env:rg --yes
   write-output "showdown is complete $env:rg $(Get-Date)"
   End commands to shut down this deployment using Azure CLI with PowerShell

   emacs ESC 4 F10
   Begin commands for one time initializations using Azure CLI with PowerShell
   write-output "One time initializations: Create resource group and service principal for github workflow"
   write-output "az group create -l $env:loc -n $env:rg"
   az group create -l $env:loc -n $env:rg
   $env:id=(az group show --name $env:rg --query 'id' --output tsv)
   write-output "id=$env:id"
   write-output "Skip creating the service principal for github workflow"
   #write-output "az ad sp create-for-rbac --name $env:sp --json-auth --role contributor --scopes $env:id"
   #az ad sp create-for-rbac --name $env:sp --json-auth --role contributor --scopes $env:id
   #write-output "go to github settings->secrets and create a secret called AZURE_CREDENTIALS with the above output"
   write-output "{`n`"`$schema`": `"https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#`",`n `"contentVersion`": `"1.0.0.0`",`n `"resources`": [] `n}" | Out-File -FilePath clear-resources.json
   End commands for one time initializations using Azure CLI with PowerShell

   emacs ESC 5 F10
   Begin commands for one time initializations using Azure CLI with PowerShell
   write-output "current resource list"
   End commands for one time initializations using Azure CLI with PowerShell

   emacs ESC 6 F10
   Begin commands to deploy this file using Azure CLI with PowerShell
   write-output "step 6 Create Storage Account for Function App"
   write-output "az storage account create --name $env:storageAccountName  --resource-group $env:rg --location $env:loc --sku Standard_LRS --access-tier Cool"
   az storage account create --name $env:storageAccountName  --resource-group $env:rg --location $env:loc --sku Standard_LRS --access-tier Cool
   End commands to deploy this file using Azure CLI with PowerShell

   emacs ESC 7 F10
   Begin commands to deploy this file using Azure CLI with PowerShell
   write-output "step 7 Show Connection strings for storage Storage Account for Function App"
   write-output "az storage account show-connection-string --resource-group $env:rg --name $env:storageAccountName --output TSV"
   az storage account show-connection-string --resource-group $env:rg --name $env:storageAccountName --output TSV
   End commands to deploy this file using Azure CLI with PowerShell

   emacs ESC 8 F10
   Begin commands to deploy this file using Azure CLI with PowerShell
   write-output "step 8 Create Windows Function App"
   write-output "az functionapp create --resource-group $env:rg --consumption-plan-location $env:loc --runtime dotnet-isolated --runtime-version 8 --functions-version 4 --name $env:functionAppName --storage-account $env:storageAccountName"
   az functionapp create --resource-group $env:rg --consumption-plan-location $env:loc --runtime dotnet-isolated --runtime-version 8 --functions-version 4 --name $env:functionAppName --storage-account $env:storageAccountName
   az functionapp config appsettings list -n $env:functionAppName -g $env:rg
   End commands to deploy this file using Azure CLI with PowerShell

   emacs ESC 9 F10
   Begin commands to deploy this file using Azure CLI with PowerShell
   write-output "step 9 create service bus "
   write-output "az servicebus namespace create --resource-group $env:rg --name $env:serviceBusNS --location $env:loc --sku Basic"
   az servicebus namespace create --resource-group $env:rg --name $env:serviceBusNS --location $env:loc --sku Basic
   write-output "az servicebus queue create --resource-group $env:rg --namespace-name $env:serviceBusNS --name $env:serviceBusQueueName"
   az servicebus queue create --resource-group $env:rg --namespace-name $env:serviceBusNS --name $env:serviceBusQueueName
   End commands to deploy this file using Azure CLI with PowerShell
   
   emacs ESC 10 F10
   Begin commands to deploy this file using Azure CLI with PowerShell
   write-output "Step 10 Set the Environment Variables"
   write-output "az servicebus namespace authorization-rule keys list --resource-group $env:rg --namespace-name $env:serviceBusNS --name RootManageSharedAccessKey --query primaryConnectionString --output tsv"
   $env:ServiceBusConnection=(az servicebus namespace authorization-rule keys list --resource-group $env:rg --namespace-name $env:serviceBusNS --name RootManageSharedAccessKey --query primaryConnectionString --output tsv)
   write-output "(list (setenv `"ServiceBusConnection`" `"$($env:ServiceBusConnectionString)`")"
   write-output "(setenv `"busNS`" `"$($env:serviceBusNS)`")"
   write-output "(setenv `"queue`" `"$($env:serviceBusQueueName)`")"
   write-output "(setenv `"RG_WEBSITE_00`" `"$($env:rg)`")"
   write-output "(setenv `"SS_WEBSITE_00`" `"$($env:functionAppName)`"))"
   write-output "az webapp log tail -n `"$($env:functionAppName)`" -g `"$($env:rg)`""
   write-output "az webapp config connection-string set --name $env:functionAppName --resource-group $env:rg --settings ServiceBusConnection=$env:ServiceBusConnection --connection-string-type Custom"
   az webapp config connection-string set --name $env:functionAppName --resource-group $env:rg --settings ServiceBusConnection=$env:ServiceBusConnection --connection-string-type Custom
   End commands to deploy this file using Azure CLI with PowerShell

   emacs ESC 11 F10
   Begin commands to deploy this file using Azure CLI with PowerShell
   write-output "step 11 show service bus add connection string"
   write-output "az functionapp config appsettings set --name $env:functionAppName --resource-group $env:rg --settings busNS=$($env:serviceBusNS)"
   az functionapp config appsettings set --name $env:functionAppName --resource-group $env:rg --settings busNS=$env:serviceBusNS
   write-output "az functionapp config appsettings set --name $env:functionAppName --resource-group $env:rg --settings queue=$env:serviceBusQueueName"
   az functionapp config appsettings set --name $env:functionAppName --resource-group $env:rg --settings queue=$env:serviceBusQueueName
   write-output "az webapp config connection-string list --name $env:functionAppName --resource-group $env:rg"
   az webapp config connection-string list --name $env:functionAppName --resource-group $env:rg
   write-output "az functionapp config appsettings list -n $env:functionAppName -g $env:rg"
   az functionapp config appsettings list -n $env:functionAppName -g $env:rg
   End commands to deploy this file using Azure CLI with PowerShell

   emacs ESC 12 F10
   Begin commands to deploy this file using Azure CLI with PowerShell
   write-output "Step 12: Upddate the built at timestamp in the source code (ala ChatGPT)"
   # Path to your C# source file
   $filePath = "..\SimpleServiceBusSendReceiveAzureFuncs/SimpleServiceBusSenderReceiver.cs"
   # Read the contents of the file
   $content = Get-Content -Path $filePath -Raw
   # Regular expression to match the version number in the format "Version 000000000"
   $versionRegex = 'Version [0-9]+'
   # Regular expression to match the date-time string
   $regex = 'Built at [A-Za-z]{3} +[A-Za-z]{3} +[0-9]{1,2} +[0-9]{1,2}:+[0-9]{1,2}:+[0-9]{1,2} +[0-9]{4}'
   # Initialize flags to check if replacements were made
   $dateUpdated = $false
   $versionUpdated = $false
   if ($content -match $regex) {
     # Get the current date-time in the same format
     $currentDateTime = Get-Date -Format "ddd MMM dd HH:mm:ss yyyy"
     write-output "Replace the old date-time with the current date-time $currentDateTime"
     $updatedContent = [regex]::Replace($content, $regex, "Built at $currentDateTime")
     $dateUpdated = $true
     Write-Output "Date-time string updated successfully."
   } else {
     write-output "Built At timestamp not found"
   }
   # Check if the version regex finds a match
   if ($content -match $versionRegex) {
       # Extract the current version number
       $currentVersion = [regex]::Match($content, $versionRegex).Value
       # Increment the version number by 1
       $versionNumber = [int]($currentVersion -replace '[^0-9]', '')
       write-output "found version $versionNumber"
       $newVersionNumber = $versionNumber + 1
       write-output "increment version $versionNumber"
       $newVersionString = "Version " + $newVersionNumber.ToString("D5")
       write-output "new version string= $newVersionString"
       # Replace the old version number with the new version number
       $content = $content -replace $versionRegex, $newVersionString
       $versionUpdated = $true
   } else {
       Write-Output "No version number found matching the pattern."
   }
   if ($dateUpdated -or $versionUpdated) {
       Set-Content -Path $filePath -Value $content
       Write-Output "File updated successfully in $filePath."
   } else {
      Write-Output "No updates made to the file."
   }   
   End commands to deploy this file using Azure CLI with PowerShell

   emacs ESC 13 F10
   Begin commands to deploy this file using Azure CLI with PowerShell
   write-output "step 13 Publish"
   $path = "publish-functionapp"
   if (Test-Path -LiteralPath $path) {
       write-output "Deleting $path"
       Remove-Item -LiteralPath $path -Recurse
   } else {
      write-output "Path doesn't exist: create $path "
      New-Item -Path "." -Name $Path -ItemType Directory
   }
   write-output "dotnet publish ../SimpleServiceBusSendReceiveAzureFuncs  --configuration Release  -f net8.0  --self-contained --output ./publish-functionapp"
   dotnet publish ../SimpleServiceBusSendReceiveAzureFuncs  --configuration Release  -f net8.0 --self-contained --output ./publish-functionapp
   End commands to deploy this file using Azure CLI with PowerShell

   This code will eventually reside in the pipeline yaml
   emacs ESC 14 F10
   Begin commands to deploy this file using Azure CLI with PowerShell
   write-output "step 14 zip"
   $path = "publish-functionapp.zip"
   if (Test-Path -LiteralPath $path) {
       write-output "Delete $path "
       Remove-Item -LiteralPath $path
   } else {
      write-output "$path doesn't exist: create it"
   }
   pushd ./publish-functionapp
   write-output "Compress-Archive -Path .\* -DestinationPath ../publish-functionapp.zip -Force"
   Compress-Archive -Path .\* -DestinationPath ../publish-functionapp.zip -Force
   popd
   End commands to deploy this file using Azure CLI with PowerShell
   
   Certificate verification failed. This typically happens when using Azure CLI behind a proxy that intercepts traffic with a self-signed certificate. Please add this certificate to the trusted CA bundle. More info: https://docs.microsoft.com/cli/azure/use-cli-effectively#work-behind-a-proxy.
   This code will eventually be replace by EV2 resident JSON ARM template that does zipdeploy
   emacs ESC 15 F10
   Begin commands to deploy this file using Azure CLI with PowerShell
   write-output "step 15 deploy compiled C# code deployment to azure resource. For Linux Func created with azure cli this gives error: ERROR: Runtime  is not supported."
   write-output "az functionapp deployment source config-zip -g $env:rg -n $env:functionAppName --src ./publish-functionapp.zip"
   az functionapp deployment source config-zip -g $env:rg -n $env:functionAppName --src ./publish-functionapp.zip
   End commands to deploy this file using Azure CLI with PowerShell

   emacs ESC 16 F10
   Begin commands to deploy this file using Azure CLI with PowerShell
   write-output "step 16 Delete Function App"
   write-output "az functionapp delete --resource-group $env:rg --name $env:functionAppName --keep-empty-plan"
   az functionapp delete --resource-group $env:rg --name $env:functionAppName --keep-empty-plan
   End commands to deploy this file using Azure CLI with PowerShell

   emacs ESC 17 F10
   Begin commands to deploy this file using Azure CLI with PowerShell
   write-output "step 17 Delete & purge key vault if there are any"
   $kv=(Get-AzResource -ResourceGroupName $env:rg -ResourceType Microsoft.KeyVault/vaults  |  Select-Object -ExpandProperty Name)
   If (![string]::IsNullOrEmpty($kv)) {
     write-output "keyvault=$kv"
     write-output "az keyvault delete --name '$($env:uniquePrefix)-kv' -g '$env:rg'"
     az keyvault delete --name "$($env:uniquePrefix)-kv" -g "$env:rg"
     write-output "az keyvault purge --name `"$($env:uniquePrefix)-kv`" --location $env:loc"
     az keyvault purge --name "$($env:uniquePrefix)-kv" --location $env:loc 
   } Else {
     write-output "No key vault to delete & purge"
   }
   End commands to deploy this file using Azure CLI with PowerShell

   Begin common epilog commands
   az resource list -g $env:rg --query "[?resourceGroup=='$env:rg'].{ name: name, flavor: kind, resourceType: type, region: location }" --output table  | ForEach-Object { $_ -replace "`r", ""}
   $elapsedTime = $(get-date) - $StartTime
   $totalTime = "{0:HH:mm:ss}" -f ([datetime]$elapsedTime.Ticks)
   write-output "all done $(Get-Date) elapse time = $totalTime "
   End common epilog commands

 */
param location string = resourceGroup().location
param uniquePrefix string = uniqueString(resourceGroup().id)
param serviceBusQueueName string = 'mainqueue001'

param serviceBusNS string = '${uniquePrefix}-servicebus'
param functionAppName string = '${uniquePrefix}-func'
param functionPlanName string = '${uniquePrefix}-plan-func'
param appInsightsName string = '${uniquePrefix}-appins'
param storageAccountName string = '${uniquePrefix}stg'

param noManagedIdent bool = false
param ownerId string = '' // objectId of the owner (developer)
param useKVForStgConnectionString bool = true
param actionGroups_Application_Insights_Smart_Detection_name string = '${uniquePrefix}-detector'
param actiongroups_application_insights_smart_detection_externalid string = '/subscriptions/acc26051-92a5-4ed1-a226-64a187bc27db/resourceGroups/rg_generalpurposecosmos/providers/actiongroups/application insights smart detection'
param logAnalyticsWS string = '/subscriptions/acc26051-92a5-4ed1-a226-64a187bc27db/resourceGroups/DefaultResourceGroup-WUS2/providers/Microsoft.OperationalInsights/workspaces/DefaultWorkspace-acc26051-92a5-4ed1-a226-64a187bc27db-WUS2'

resource serviceBus 'Microsoft.ServiceBus/namespaces@2022-10-01-preview' = {
  name: serviceBusNS
  location: location
  sku: {
    name: 'Basic'
    tier: 'Basic'
  }
  properties: {
    premiumMessagingPartitions: 0
    minimumTlsVersion: '1.2'
    publicNetworkAccess: 'Enabled'
    disableLocalAuth: false
    privateEndpointConnections: []
    zoneRedundant: false
  }

  resource serviceBusNS_RootManageSharedAccessKey 'authorizationrules@2022-10-01-preview' = {
    name: 'RootManageSharedAccessKey'
    properties: {
      rights: [
        'Listen'
        'Manage'
        'Send'
      ]
    }
  }

  resource serviceBusNS_default 'networkrulesets@2022-10-01-preview' = {
    name: 'default'
    properties: {
      publicNetworkAccess: 'Enabled'
      defaultAction: 'Allow'
      virtualNetworkRules: []
      ipRules: []
      trustedServiceAccessEnabled: false
    }
  }

  resource serviceBusQueue 'queues@2022-10-01-preview' = {
    name: serviceBusQueueName
    properties: {
      maxMessageSizeInKilobytes: 256
      lockDuration: 'PT1M'
      maxSizeInMegabytes: 1024
      requiresDuplicateDetection: false
      requiresSession: false
      defaultMessageTimeToLive: 'P14D'
      deadLetteringOnMessageExpiration: false
      enableBatchedOperations: true
      duplicateDetectionHistoryTimeWindow: 'PT10M'
      maxDeliveryCount: 10
      status: 'Active'
      enablePartitioning: false
      enableExpress: false
    }
  }
}

resource storageAccountForFuncApp 'Microsoft.Storage/storageAccounts@2023-04-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    allowCrossTenantReplication: false
    minimumTlsVersion: 'TLS1_0'
    allowBlobPublicAccess: false
    networkAcls: {
      bypass: 'AzureServices'
      virtualNetworkRules: []
      ipRules: []
      defaultAction: 'Allow'
    }
    supportsHttpsTrafficOnly: true
    encryption: {
      services: {
        file: {
          keyType: 'Account'
          enabled: true
        }
        blob: {
          keyType: 'Account'
          enabled: true
        }
      }
      keySource: 'Microsoft.Storage'
    }
    accessTier: 'Cool'
  }
  resource storageAccountDefault 'blobServices@2023-04-01' = {
    name: 'default'
    properties: {
      cors: {
        corsRules: []
      }
      deleteRetentionPolicy: {
        allowPermanentDelete: false
        enabled: false
      }
    }
    // ERROR: {"code": "InvalidTemplate", "message": "Deployment template validation failed: 'The template resource '/default/azure-webjobs-hosts' for type 'Microsoft.Storage/storageAccounts/blobServices/containers' at line '130' and column '73' has incorrect segment lengths. A nested resource type must have identical number of segments as its resource name. A root resource type must have segment length one greater than its resource name. Please see https://aka.ms/arm-syntax-resources for usage details.'.", "additionalInfo": [{"type": "TemplateViolation", "info": {"lineNumber": 130, "linePosition": 73, "path": "properties.template.resources[3].type"}}]}
    resource storageAccountDefault_azure_webjobs_hosts 'containers@2023-04-01' = {
      name: 'azure-webjobs-hosts'
      properties: {
        immutableStorageWithVersioning: {
          enabled: false
        }
        defaultEncryptionScope: '$account-encryption-key'
        denyEncryptionScopeOverride: false
        publicAccess: 'None'
      }
    }

    resource storageAccountDefault_azure_webjobs_secrets 'containers@2023-04-01' = {
      name: 'azure-webjobs-secrets'
      properties: {
        immutableStorageWithVersioning: {
          enabled: false
        }
        defaultEncryptionScope: '$account-encryption-key'
        denyEncryptionScopeOverride: false
        publicAccess: 'None'
      }
    }
  }

  resource Microsoft_Storage_storageAccounts_fileServices_storageAccountDefault 'fileServices@2023-04-01' = {
    name: 'default'
    properties: {
      protocolSettings: {
        smb: {}
      }
      cors: {
        corsRules: []
      }
      shareDeleteRetentionPolicy: {
        enabled: true
        days: 7
      }
    }
    resource storageAccountDefaultfunc7198c0b0a43b 'shares@2023-04-01' = {
      name: 'iqa5jvm-func7198c0b0a43b'
      properties: {
        accessTier: 'TransactionOptimized'
        shareQuota: 102400
        enabledProtocols: 'SMB'
      }
    }
  }

  resource Microsoft_Storage_storageAccounts_queueServices_storageAccountDefault 'queueServices@2023-04-01' = {
    name: 'default'
    properties: {
      cors: {
        corsRules: []
      }
    }
  }

  resource Microsoft_Storage_storageAccounts_tableServices_storageAccountDefault 'tableServices@2023-04-01' = {
    name: 'default'
    properties: {
      cors: {
        corsRules: []
      }
    }
  }
}

output outputOwnerId string = ownerId
var storageAccountConnectionString = 'DefaultEndpointsProtocol=https;AccountName=${storageAccountForFuncApp.name};AccountKey=${storageAccountForFuncApp.listKeys().keys[0].value};EndpointSuffix=${environment().suffixes.storage}'
output outStorageAccountConnectionString1 string = storageAccountConnectionString

var storageAccountConnectionStringMSI = 'AzureWebJobsStorage__${storageAccountName}'
output outputStorageAccountConnectionStringMSI string = storageAccountConnectionStringMSI

resource functionPlan 'Microsoft.Web/serverfarms@2023-12-01' = {
  name: functionPlanName
  location: location
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
resource appInsights 'microsoft.insights/components@2020-02-02' = {
  name: appInsightsName
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
    RetentionInDays: 90
    WorkspaceResourceId: logAnalyticsWS
    IngestionMode: 'LogAnalytics'
    publicNetworkAccessForIngestion: 'Enabled'

    publicNetworkAccessForQuery: 'Enabled'
  }

  resource appInsights_DegradationIndependencyDuration 'ProactiveDetectionConfigs@2018-05-01-preview' = {
    name: 'degradationindependencyduration'
    location: location
    properties: {
      RuleDefinitions: {
        Name: 'degradationindependencyduration'
        DisplayName: 'Degradation in dependency duration'
        Description: 'Smart Detection rules notify you of performance anomaly issues.'
        HelpUrl: 'https://docs.microsoft.com/en-us/azure/application-insights/app-insights-proactive-performance-diagnostics'
        IsHidden: false
        IsEnabledByDefault: true
        IsInPreview: false
        SupportsEmailNotifications: true
      }
      Enabled: true
      SendEmailsToSubscriptionOwners: true
      CustomEmails: []
    }
  }

  resource appInsights_DegradationInServerResponseTime 'ProactiveDetectionConfigs@2018-05-01-preview' = {
    name: 'degradationinserverresponsetime'
    location: location
    properties: {
      RuleDefinitions: {
        Name: 'degradationinserverresponsetime'
        DisplayName: 'Degradation in server response time'
        Description: 'Smart Detection rules notify you of performance anomaly issues.'
        HelpUrl: 'https://docs.microsoft.com/en-us/azure/application-insights/app-insights-proactive-performance-diagnostics'
        IsHidden: false
        IsEnabledByDefault: true
        IsInPreview: false
        SupportsEmailNotifications: true
      }
      Enabled: true
      SendEmailsToSubscriptionOwners: true
      CustomEmails: []
    }
  }

  resource appInsight_DigestMailConfiguration 'ProactiveDetectionConfigs@2018-05-01-preview' = {
    name: 'digestMailConfiguration'
    location: location
    properties: {
      RuleDefinitions: {
        Name: 'digestMailConfiguration'
        DisplayName: 'Digest Mail Configuration'
        Description: 'This rule describes the digest mail preferences'
        HelpUrl: 'www.homail.com'
        IsHidden: true
        IsEnabledByDefault: true
        IsInPreview: false
        SupportsEmailNotifications: true
      }
      Enabled: true
      SendEmailsToSubscriptionOwners: true
      CustomEmails: []
    }
  }

  resource appInsights_Extension_BillingDataVolumeDailySpikeExtension 'ProactiveDetectionConfigs@2018-05-01-preview' = {
    name: 'extension_billingdatavolumedailyspikeextension'
    location: location
    properties: {
      RuleDefinitions: {
        Name: 'extension_billingdatavolumedailyspikeextension'
        DisplayName: 'Abnormal rise in daily data volume (preview)'
        Description: 'This detection rule automatically analyzes the billing data generated by your application, and can warn you about an unusual increase in your application\'s billing costs'
        HelpUrl: 'https://github.com/Microsoft/ApplicationInsights-Home/tree/master/SmartDetection/billing-data-volume-daily-spike.md'
        IsHidden: false
        IsEnabledByDefault: true
        IsInPreview: true
        SupportsEmailNotifications: false
      }
      Enabled: true
      SendEmailsToSubscriptionOwners: true
      CustomEmails: []
    }
  }

  resource appInsights_Extension_CanaryExtension 'ProactiveDetectionConfigs@2018-05-01-preview' = {
    name: 'extension_canaryextension'
    location: location
    properties: {
      RuleDefinitions: {
        Name: 'extension_canaryextension'
        DisplayName: 'Canary extension'
        Description: 'Canary extension'
        HelpUrl: 'https://github.com/Microsoft/ApplicationInsights-Home/blob/master/SmartDetection/'
        IsHidden: true
        IsEnabledByDefault: true
        IsInPreview: true
        SupportsEmailNotifications: false
      }
      Enabled: true
      SendEmailsToSubscriptionOwners: true
      CustomEmails: []
    }
  }

  resource appInsights_Extension_ExceptionChangeExtension 'ProactiveDetectionConfigs@2018-05-01-preview' = {
    name: 'extension_exceptionchangeextension'
    location: location
    properties: {
      RuleDefinitions: {
        Name: 'extension_exceptionchangeextension'
        DisplayName: 'Abnormal rise in exception volume (preview)'
        Description: 'This detection rule automatically analyzes the exceptions thrown in your application, and can warn you about unusual patterns in your exception telemetry.'
        HelpUrl: 'https://github.com/Microsoft/ApplicationInsights-Home/blob/master/SmartDetection/abnormal-rise-in-exception-volume.md'
        IsHidden: false
        IsEnabledByDefault: true
        IsInPreview: true
        SupportsEmailNotifications: false
      }
      Enabled: true
      SendEmailsToSubscriptionOwners: true
      CustomEmails: []
    }
  }

  resource appInsights_Extension_MemoryLeakExtension 'ProactiveDetectionConfigs@2018-05-01-preview' = {
    name: 'extension_memoryleakextension'
    location: location
    properties: {
      RuleDefinitions: {
        Name: 'extension_memoryleakextension'
        DisplayName: 'Potential memory leak detected (preview)'
        Description: 'This detection rule automatically analyzes the memory consumption of each process in your application, and can warn you about potential memory leaks or increased memory consumption.'
        HelpUrl: 'https://github.com/Microsoft/ApplicationInsights-Home/tree/master/SmartDetection/memory-leak.md'
        IsHidden: false
        IsEnabledByDefault: true
        IsInPreview: true
        SupportsEmailNotifications: false
      }
      Enabled: true
      SendEmailsToSubscriptionOwners: true
      CustomEmails: []
    }
  }

  resource appInsights_Extension_SecurityExtensionsPackage 'ProactiveDetectionConfigs@2018-05-01-preview' = {
    name: 'extension_securityextensionspackage'
    location: location
    properties: {
      RuleDefinitions: {
        Name: 'extension_securityextensionspackage'
        DisplayName: 'Potential security issue detected (preview)'
        Description: 'This detection rule automatically analyzes the telemetry generated by your application and detects potential security issues.'
        HelpUrl: 'https://github.com/Microsoft/ApplicationInsights-Home/blob/master/SmartDetection/application-security-detection-pack.md'
        IsHidden: false
        IsEnabledByDefault: true
        IsInPreview: true
        SupportsEmailNotifications: false
      }
      Enabled: true
      SendEmailsToSubscriptionOwners: true
      CustomEmails: []
    }
  }

  resource appInsights_Extension_TraceSeverityDetector 'ProactiveDetectionConfigs@2018-05-01-preview' = {
    name: 'extension_traceseveritydetector'
    location: location
    properties: {
      RuleDefinitions: {
        Name: 'extension_traceseveritydetector'
        DisplayName: 'Degradation in trace severity ratio (preview)'
        Description: 'This detection rule automatically analyzes the trace logs emitted from your application, and can warn you about unusual patterns in the severity of your trace telemetry.'
        HelpUrl: 'https://github.com/Microsoft/ApplicationInsights-Home/blob/master/SmartDetection/degradation-in-trace-severity-ratio.md'
        IsHidden: false
        IsEnabledByDefault: true
        IsInPreview: true
        SupportsEmailNotifications: false
      }
      Enabled: true
      SendEmailsToSubscriptionOwners: true
      CustomEmails: []
    }
  }

  resource appInsights_longDependencyDuration 'ProactiveDetectionConfigs@2018-05-01-preview' = {
    name: 'longdependencyduration'
    location: location
    properties: {
      RuleDefinitions: {
        Name: 'longdependencyduration'
        DisplayName: 'Long dependency duration'
        Description: 'Smart Detection rules notify you of performance anomaly issues.'
        HelpUrl: 'https://docs.microsoft.com/en-us/azure/application-insights/app-insights-proactive-performance-diagnostics'
        IsHidden: false
        IsEnabledByDefault: true
        IsInPreview: false
        SupportsEmailNotifications: true
      }
      Enabled: true
      SendEmailsToSubscriptionOwners: true
      CustomEmails: []
    }
  }

  resource appInsights_MigrationToAlertRulesCompleted 'ProactiveDetectionConfigs@2018-05-01-preview' = {
    name: 'migrationToAlertRulesCompleted'
    location: location
    properties: {
      RuleDefinitions: {
        Name: 'migrationToAlertRulesCompleted'
        DisplayName: 'Migration To Alert Rules Completed'
        Description: 'A configuration that controls the migration state of Smart Detection to Smart Alerts'
        HelpUrl: 'https://docs.microsoft.com/en-us/azure/application-insights/app-insights-proactive-performance-diagnostics'
        IsHidden: true
        IsEnabledByDefault: false
        IsInPreview: true
        SupportsEmailNotifications: false
      }
      Enabled: false
      SendEmailsToSubscriptionOwners: true
      CustomEmails: []
    }
  }

  resource appInsights_SlowPageLoadTime 'ProactiveDetectionConfigs@2018-05-01-preview' = {
    name: 'slowpageloadtime'
    location: location
    properties: {
      RuleDefinitions: {
        Name: 'slowpageloadtime'
        DisplayName: 'Slow page load time'
        Description: 'Smart Detection rules notify you of performance anomaly issues.'
        HelpUrl: 'https://docs.microsoft.com/en-us/azure/application-insights/app-insights-proactive-performance-diagnostics'
        IsHidden: false
        IsEnabledByDefault: true
        IsInPreview: false
        SupportsEmailNotifications: true
      }
      Enabled: true
      SendEmailsToSubscriptionOwners: true
      CustomEmails: []
    }
  }

  resource appInsights_SlowServerResponseTime 'ProactiveDetectionConfigs@2018-05-01-preview' = {
    name: 'slowserverresponsetime'
    location: location
    properties: {
      RuleDefinitions: {
        Name: 'slowserverresponsetime'
        DisplayName: 'Slow server response time'
        Description: 'Smart Detection rules notify you of performance anomaly issues.'
        HelpUrl: 'https://docs.microsoft.com/en-us/azure/application-insights/app-insights-proactive-performance-diagnostics'
        IsHidden: false
        IsEnabledByDefault: true
        IsInPreview: false
        SupportsEmailNotifications: true
      }
      Enabled: true
      SendEmailsToSubscriptionOwners: true
      CustomEmails: []
    }
  }
}

resource actionGroups_Application_Insights_Smart_Detection_name_resource 'microsoft.insights/actionGroups@2023-01-01' = {
  name: actionGroups_Application_Insights_Smart_Detection_name
  location: 'Global'
  properties: {
    groupShortName: 'SmartDetect'
    enabled: true
    emailReceivers: []
    smsReceivers: []
    webhookReceivers: []
    eventHubReceivers: []
    itsmReceivers: []
    azureAppPushReceivers: []
    automationRunbookReceivers: []
    voiceReceivers: []
    logicAppReceivers: []
    azureFunctionReceivers: []
    armRoleReceivers: [
      {
        name: 'Monitoring Contributor'
        roleId: '749f88d5-cbae-40b8-bcfc-e573ddc772fa'
        useCommonAlertSchema: true
      }
      {
        name: 'Monitoring Reader'
        roleId: '43d0d8ad-25c7-4714-9337-8ba259a9fe05'
        useCommonAlertSchema: true
      }
    ]
  }
}

resource smartDetectorAlertRulesFailureAnomalies 'microsoft.alertsmanagement/smartdetectoralertrules@2021-04-01' = {
  name: '${uniquePrefix}-failure anomalies'
  location: 'global'
  properties: {
    description: 'Failure Anomalies notifies you of an unusual rise in the rate of failed HTTP requests or dependency calls.'
    state: 'Enabled'
    severity: 'Sev3'
    frequency: 'PT1M'
    detector: {
      id: 'FailureAnomaliesDetector'
    }
    scope: [
      appInsights.id
    ]
    actionGroups: {
      groupIds: [
        actionGroups_Application_Insights_Smart_Detection_name_resource.id
        //actiongroups_application_insights_smart_detection_externalid
      ]
    }
  }
}

output serviceBusEndpoint1 string = serviceBus.properties.serviceBusEndpoint
var serviceBusKeyId = '${serviceBus.id}/AuthorizationRules/RootManageSharedAccessKey'
var serviceBusConnection = listKeys(serviceBusKeyId, serviceBus.apiVersion).primaryConnectionString
// Extract the service bus endpoint from the connection string

// This serviceBusConnectionViaMSI working on May 14 2024. Now I am getting this error after having upgraded the bicep code from in-process .NET 6 function app to isolated Function App .NET 8. 
// WARNING: 2024-06-12T23:03:23.634 [Error] The listener for function 'Functions.SimpleServiceBusReceiver' was unable to start.Microsoft.Azure.WebJobs.Host.Listeners.FunctionListenerException : The listener for function "'Functions.SimpleServiceBusReceiver' was unable to start. ---> System.ArgumentException : The connection string used for an Service Bus client must specify the Service Bus namespace host and either a Shared Access Key (both the name and value) OR a Shared Access Signature to be valid. (Parameter 'connectionString')

// See https://learn.microsoft.com/en-us/azure/azure-functions/functions-identity-based-connections-tutorial-2#connect-to-service-bus-in-your-function-app
var ServiceBusConnection__fullyQualifiedNamespace = '${serviceBus.name}.servicebus.windows.net'
output ServiceBusConnectionManagedIdentity string = ServiceBusConnection__fullyQualifiedNamespace

var serviceBusEndPoint = split(serviceBusConnection, ';')[0]
var serviceBusConnectionViaMSI = '${serviceBusEndPoint};Authentication=ManagedIdentity'
output outputServiceBusEndpoint string = serviceBusEndPoint
output outputServiceBusConnectionViaMSI string = serviceBusConnectionViaMSI
output serviceBusConnectionString string = serviceBusConnection

output busNS string = serviceBusNS
output queue string = serviceBus::serviceBusQueue.name

// I don't know if we need this key vault for the storage account connection string.
// The problem is that we cannot use a managed identity to access the storage account connection string for the app settting WEBSITE_CONTENTAZUREFILECONNECTIONSTRING (as per the documentation).
// This app setting is required for linux & windows for consumption and elastic premium plans (what is an elastic premium plan? It is not in the pricing calculator). 
// Apparenlty, it is not required for dedicated (standard?) plans which we will probably use in production.
//
// I could try to put this in a seperate module and see if that alleviatges the circular dependency.

resource kv 'Microsoft.KeyVault/vaults@2022-02-01-preview'= {
  name: '${uniquePrefix}-kv'
  location: location
  properties: {
    sku: {
      family: 'A'
      name: 'standard'
    }
    enabledForDeployment: true
    enabledForDiskEncryption: true
    enabledForTemplateDeployment: true
    enableRbacAuthorization: true // this allows use to skip the access policy
    tenantId: subscription().tenantId    
  }
}

resource kvaadb2cSecret 'Microsoft.KeyVault/vaults/secrets@2019-09-01' = {
  parent: kv
  name: 'storageAccountConnectionString'
  properties: {
    value: storageAccountConnectionString
  }
}
// https://learn.microsoft.com/en-us/azure/app-service/app-service-key-vault-references?tabs=azure-cli#source-app-settings-from-key-vault
// Source app settings from key vault: https://learn.microsoft.com/en-us/azure/app-service/app-service-key-vault-references?tabs=azure-cli#source-app-settings-from-key-vault
// "Unable to resolve Azure Files Settings from Key Vault. Details: Unable to resolve setting: WEBSITE_CONTENTAZUREFILECONNECTIONSTRING with error: InvalidSyntax."
// @Microsoft.KeyVault(VaultName=myvault;SecretName=mysecret)
var storageAccountConnectionStringKV = '@Microsoft.KeyVault(VaultName=${kv.name};SecretName=storageAccountConnectionString)'
// "Unable to resolve Azure Files Settings from Key Vault. Details: Unable to resolve setting: WEBSITE_CONTENTAZUREFILECONNECTIONSTRING with error: InvalidSyntax."
// @Microsoft.KeyVault(SecretUri=https://myvault.vault.azure.net/secrets/mysecret/)
//var storageAccountConnectionStringKV = '@Microsoft.KeyVault(SecretUri=https://${kv.name}.vault.azure.net/secrets/storageAccountConnectionString/)'


resource functionApp 'Microsoft.Web/sites@2023-12-01' = {
  name: functionAppName
  location: location
  kind: 'functionapp'
  identity: {
    type: 'SystemAssigned'
  }

  properties: {
    enabled: true
    hostNameSslStates: [
      {
        name: '${functionAppName}.azurewebsites.net'
        sslState: 'Disabled'
        hostType: 'Standard'
      }
      {
        name: '${functionAppName}.scm.azurewebsites.net'
        sslState: 'Disabled'
        hostType: 'Repository'
      }
    ]
    serverFarmId: functionPlan.id
    reserved: false
    isXenon: false
    hyperV: false
    dnsConfiguration: {}
    vnetRouteAllEnabled: false
    vnetImagePullEnabled: false
    vnetContentShareEnabled: false
    siteConfig: {
      cors: {
        allowedOrigins: [
          'https://portal.azure.com'
          'https://ms.portal.azure.com'
          'https://172.56.107.163'
        ]
        supportCredentials: false
      }
      numberOfWorkers: 1
      acrUseManagedIdentityCreds: false
      alwaysOn: false
      http20Enabled: true
      functionAppScaleLimit: 200
      minimumElasticInstanceCount: 0
      appSettings: [
        // {
        //   name: 'WEBSITE_RUN_FROM_PACKAGE'
        //   value: '1'
        // }
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
          name: 'AzureWebJobsStorage'
          value: storageAccountConnectionStringMSI //storageAccountConnectionStringKV // storageAccountConnectionStringMSI
        }
        // WEBSITE_CONTENTAZUREFILECONNECTIONSTRING https://learn.microsoft.com/en-us/azure/azure-functions/functions-app-settings#website_contentazurefileconnectionstring
        // This setting is required for Consumption and Elastic Premium plan apps running on both Windows and Linux. It's not required for Dedicated plan apps, which aren't dynamically scaled by Functions.
        // Azure Files doesn't support using managed identity when accessing the file share. For more information, see Azure Files supported authentication scenarios.
        // Share-level permissions for all authenticated identities: https://learn.microsoft.com/en-us/azure/storage/files/storage-files-identity-ad-ds-assign-permissions?tabs=azure-cli#share-level-permissions-for-all-authenticated-identities
        // 
        // Using storageAccountConnectionStringKV causes a circular dependency. Maybe we could just comment this out for production? I cannot find "Elastic Premium plan" in the pricing calculator.
        //
        // ERROR: {"code": "InvalidTemplateDeployment", "message": "The template deployment 'SBusSndRcv' is not valid according to the validation procedure. The tracking id is '1cdc6d7c-ffd6-4c26-821f-8e865fb90ce6'. See inner errors for details."}
        // 
        // Inner Errors: 
        // {"code": "ValidationForResourceFailed", "message": "Validation failed for a resource. Check 'Error.Details[0]' for more information."}
        // 
        // Inner Errors: 
        // {"code": "CouldNotAccessStorageAccount", "message": "No valid combination of connection string and storage account was found."}        
        {
          name: 'WEBSITE_CONTENTAZUREFILECONNECTIONSTRING'
          value: useKVForStgConnectionString?storageAccountConnectionStringKV : storageAccountConnectionString 
          //"The parameter WEBSITE_CONTENTAZUREFILECONNECTIONSTRING has an invalid value."
          //value: reference(resourceId('Microsoft.KeyVault/vaults/secrets', kv.name, kvaadb2cSecret.name), '2016-10-01').secretUri
	      //"Unable to resolve Azure Files Settings from Key Vault. Details: Unable to resolve setting: WEBSITE_CONTENTAZUREFILECONNECTIONSTRING with error: AccessToKeyVaultDenied."
          //value: '@Microsoft.KeyVault(SecretUri=https://${kv.name}.vault.azure.net/secrets/storageAccountConnectionString)'
	  
          //"No valid combination of connection string and storage account was found."
          //value: '@Microsoft.KeyVault(SecretUri=https://${kv.name}.vault.azure.net/secrets/storageAccountConnectionString)'
          //"No valid combination of connection string and storage account was found."
          //value: '@Microsoft.KeyVault(VaultName=${kv.name};SecretName=storageAccountConnectionString)'
          //value: '@Microsoft.KeyVault(VaultName=${kv.name};SecretName=storageAccountConnectionString)'
        }
        {
          name: 'busNS'
          value: serviceBusNS
        }
        {
          name: 'queue'
          value: serviceBusQueueName
        }
        {
          name: 'ServiceBusConnection__fullyQualifiedNamespace'
          value: ServiceBusConnection__fullyQualifiedNamespace
        }
      ]
      // connectionStrings: [
      //   {
      //     type: 'Custom'
      //     connectionString: noManagedIdent? serviceBusConnection : serviceBusConnectionViaMSI
      //     name: 'ServiceBusConnection'
      //   }
      // ]
    }
    scmSiteAlsoStopped: false
    clientAffinityEnabled: false
    clientCertEnabled: false
    clientCertMode: 'Required'
    hostNamesDisabled: false
    vnetBackupRestoreEnabled: false
    customDomainVerificationId: '40BF7B86C2FCFDDFCAF1DB349DF5DEE2661093DBD1F889FA84ED4AAB4DA8B993'
    containerSize: 1536
    dailyMemoryTimeQuota: 0
    httpsOnly: false
    redundancyMode: 'None'
    storageAccountRequired: false
    keyVaultReferenceIdentity: 'SystemAssigned'
  }

  resource sourcecontrol 'sourcecontrols@2020-12-01' = {
    name: 'web'
    properties: {
      repoUrl: 'https://github.com/siegfried01/SimplerServiceBusSendReceiveDemo.git'
      branch: 'azure-source-control-2024-jun-14-13'
      isManualIntegration: false
    }
  }

  resource azurewebsites_net 'hostNameBindings@2023-12-01' = {
    name: '${functionAppName}.azurewebsites.net'

    properties: {
      siteName: functionAppName
      hostNameType: 'Verified'
    }
  }
  resource functionAppFtp 'basicPublishingCredentialsPolicies@2023-12-01' = {
    name: 'ftp'
    properties: {
      allow: true
    }
  }

  resource functionAppScm 'basicPublishingCredentialsPolicies@2023-12-01' = {
    name: 'scm'
    properties: {
      allow: true
    }
  }
}

resource functionAppConfig 'Microsoft.Web/sites/config@2023-12-01' = {
  parent: functionApp
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
    netFrameworkVersion: 'v4.0'
    requestTracingEnabled: false
    remoteDebuggingEnabled: false
    httpLoggingEnabled: false
    acrUseManagedIdentityCreds: false
    logsDirectorySizeLimit: 35
    detailedErrorLoggingEnabled: false
    publishingUsername: '$iqa5jvm-func'
    scmType: 'None'
    use32BitWorkerProcess: false
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
    http20Enabled: true
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

module assignRoleToFunctionApp 'assignRbacRoleToFunctionApp.bicep' = if (!noManagedIdent) {
  name: 'assign-role-to-functionApp'
  params: {
    roleScope: resourceGroup().id
    functionAppName: functionApp.name
    functionPrincipalId: functionApp.identity.principalId
  }
}

module assignRoleToFunctionAppForStorageAccount 'assignRbacRoleToFunctionAppForStorageAccount.bicep' = if (!noManagedIdent) {
  name: 'assign-stg-account-role-to-functionApp'
  params: {
    roleScope: resourceGroup().id
    functionAppName: functionApp.name
    functionPrincipalId: functionApp.identity.principalId
  }
}

module assignRoleToFunctionAppForKV 'assignRbacRoleToFunctionAppForKVAccess.bicep' = if (!noManagedIdent) {
  name: 'assign-key-vault-role-to-functionApp'
  params: {
    roleScope: resourceGroup().id
    functionAppName: functionApp.name
    functionPrincipalId: functionApp.identity.principalId
  }
}
