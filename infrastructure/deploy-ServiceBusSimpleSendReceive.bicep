/*
   From a (cygwin) bash prompt, use this perl one-liner to extract the powershell script fragments and exeucte them. This example shows how to execute steps 2 (shutdown) and steps 4-13 and skipping steps 7,8,9 because they don't work (yet). Adjust that list of steps according to your needs.

   powershell -executionPolicy unrestricted -Command - <<EOF
   `perl -lne 'sub range {$b=shift; $e=shift; $r=""; for(($b..$e)){ $r=$r."," if $r; $r=$r.$_;} $r } BEGIN {  $_ = shift; s/([0-9]+)-([0-9]+)/range($1,$2)/e; @idx=split ","; $c=0; $x=0; $f=0; $s=[] } $c++ if /^\s*Begin/; if (/^\s*End/) {$c--;$s[$f++]=""}; if ($x+$c>1) { $s->[$f]=$s->[$f].$_."\n"  } $x=$c; END { push(@idx, $#s); unshift @idx,0; for (@idx) { $p=$s->[$_]; chomp $p; print $p } }' "2,4-6,10-13" < "deploy-ServiceBusSimpleSendReceive.bicep"  `
EOF

   Begin common prolog commands
   If ($env:USERNAME -eq "shein") { $env:name='SBusSndRcv' } else { $env:name="SBusSndRcv002_$($env:USERNAME)" }
   $env:rg="rg_$($env:name)"
   $env:loc=If ($env:AZ_DEFAULT_LOC) { $env:AZ_DEFAULT_LOC} Else {'eastus2'}
   $env:uniquePrefix="$(If ($env:USERNAME -eq "v-richardsi") {"xizdf"} ElseIf ($env:USERNAME -eq "v-paperry") { "iucpl" } ElseIf ($env:USERNAME -eq "shein") {"iqa5jvm"} Else { "jyzwg" } )"
   $env:serviceBusQueueName = 'mainqueue001'
   $useServiceBusFireWall=[bool]0
   $noManagedIdent=[bool]1
   $useSourceControlLoadTestCode=If ($env:USERNAME -eq "shein") { [bool]1 } Else { [bool]0 }
   $useKVForStgConnectionString=[bool]0
   $createVNetForPEP=[bool]0
   $createWebAppTestPEP=[bool]1
   $env:myIPAddress="172.56.105.149"
   $usePremiumServiceBusFunctionApp=[bool]0
   If ( $usePremiumServiceBusFunctionApp ) {
     $env:functionAppSku='P1V2'
     $env:serviceBusSku='Premium'
   } Else {
     $env:functionAppSku='Y1'
     $env:serviceBusSku='Basic'
     $useServiceBusFireWall=[bool]0
   }
   $env:storageAccountName="$($env:uniquePrefix)funcstg"
   $env:functionAppName="$($env:uniquePrefix)-func"
   $env:funcPlanName="$($env:uniquePrefix)-plan-func"
   $env:serviceBusNS="$($env:uniquePrefix)-servicebus"
   $env:logAnalyticsWS= If ($env:USERNAME -eq "shein") { "/subscriptions/acc26051-92a5-4ed1-a226-64a187bc27db/resourceGroups/DefaultResourceGroup-WUS2/providers/Microsoft.OperationalInsights/workspaces/DefaultWorkspace-acc26051-92a5-4ed1-a226-64a187bc27db-WUS2" } else {   "/subscriptions/13c9725f-d20a-4c99-8ef4-d7bb78f98cff/resourceGroups/defaultresourcegroup-wus2/providers/microsoft.operationalinsights/workspaces/defaultworkspace-13c9725f-d20a-4c99-8ef4-d7bb78f98cff-wus2" }
   $StartTime = $(get-date)
   End common prolog commands

   emacs F10
   Begin commands to deploy this file using Azure CLI with PowerShell
   $createVNetForPEP=[bool]0
   write-output "Phase 1 deployment: Function App, WebApp (verification only), Storage Accounts and no VNet and no PEP"
   az deployment group create --name $env:name --resource-group $env:rg --mode Incremental   `
     --template-file  "deploy-ServiceBusSimpleSendReceive.bicep"                             `
     --parameters                                                                            `
     "{'uniquePrefix'                   : {'value': '$env:uniquePrefix'}}"                   `
     "{'location'                       : {'value': '$env:loc'}}"                            `
     "{'myIPAddress'                    : {'value': '$env:myIPAddress'}}"                    `
     "{'noManagedIdent'                 : {'value': $noManagedIdent}}"                       `
     "{'functionAppSku'                 : {'value': '$env:functionAppSku'}}"                 `
     "{'serviceBusSku'                  : {'value': '$env:serviceBusSku'}}"                  `
     "{'usePremiumServiceBusFunctionApp': {'value': $usePremiumServiceBusFunctionApp}}"      `
     "{'useServiceBusFireWall'          : {'value': $useServiceBusFireWall}}"                `
     "{'createVNetForPEP'               : {'value': $createVNetForPEP}}"                     `
     "{'createWebAppTestPEP'            : {'value': $createWebAppTestPEP}}"                  `
     "{'useKVForStgConnectionString'    : {'value': $useKVForStgConnectionString}}"          `
     "{'useSourceControlLoadTestCode'   : {'value': $useSourceControlLoadTestCode}}"         `
     "{'storageAccountName'             : {'value': '$env:storageAccountName'}}"             `
     "{'functionAppName'                : {'value': '$env:functionAppName'}}"                `
     "{'functionPlanName'               : {'value': '$env:funcPlanName'}}"                   `
     "{'serviceBusNS'                   : {'value': '$env:serviceBusNS'}}"                   `
     "{'serviceBusQueueName'            : {'value': '$env:serviceBusQueueName'}}"            `
     "{'logAnalyticsWS'                 : {'value': '$env:logAnalyticsWS'}}"                 `
   | ForEach-Object { $_ -replace "`r", ""}
   write-output "end deploy $(Get-Date)"
   End commands to deploy this file using Azure CLI with PowerShell

   emacs ESC 2 F10
   Begin commands to shut down this deployment using Azure CLI with PowerShell
   write-output "Step 2: begin shutdown delete (contents only) resource group $env:rg $(Get-Date)"
   If ($env:USERNAME -eq "shein"){
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
   } Else {
     write-output "Remember to purge the key vault"
   }
   write-output "az deployment group create --mode complete --template-file ./clear-resources.json --resource-group $env:rg  | ForEach-Object { $_ -replace '`r', ''}"
   az deployment group create --mode complete --template-file ./clear-resources.json --resource-group $env:rg  | ForEach-Object { $_ -replace "`r", ""}
   write-output "shutdown is complete $env:rg $(Get-Date)" 
   End commands to shut down this deployment using Azure CLI with PowerShell

   emacs ESC 3 F10
   Begin commands to shut down this deployment using Azure CLI with PowerShell
   write-output "Step 3: begin shutdown delete resource group $env:rg and associated service principal $(Get-Date)"
   #write-output "az ad sp list --display-name $env:sp"
   #az ad sp list --display-name $env:sp
   #write-output "az ad sp list --filter "displayname eq '$env:sp'" --output json"
   #$env:spId=(az ad sp list --filter "displayname eq '$env:sp'" --query "[].id" --output tsv)
   #write-output "az ad sp delete --id $env:spId"
   #az ad sp delete --id $env:spId
   write-output "az group delete -n $env:rg"
   az group delete -n $env:rg --yes
   write-output "az group delete -n $env:rg_old"
   az group delete -n $env:rg_old --yes
   write-output "shutdown is complete $env:rg $(Get-Date)"
   End commands to shut down this deployment using Azure CLI with PowerShell

   emacs ESC 4 F10
   Begin commands for one time initializations using Azure CLI with PowerShell
   write-output "One time initializations: Create resource group and service principal for github workflow"
   write-output "az group create -l $env:loc -n $env:rg"
   az group create -l $env:loc -n $env:rg
   $env:id=(az group show --name $env:rg --query 'id' --output tsv)
   write-output "id=$env:id"
   #write-output "Skip creating the service principal for github workflow"
   #write-output "az ad sp create-for-rbac --name $env:sp --json-auth --role contributor --scopes $env:id"
   #az ad sp create-for-rbac --name $env:sp --json-auth --role contributor --scopes $env:id
   #write-output "go to github settings->secrets and create a secret called AZURE_CREDENTIALS with the above output"
   write-output "{`n`"`$schema`": `"https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#`",`n `"contentVersion`": `"1.0.0.0`",`n `"resources`": [] `n}" | Out-File -FilePath clear-resources.json
   End commands for one time initializations using Azure CLI with PowerShell


   emacs ESC 5 F10
   Begin commands to deploy this file using Azure CLI with PowerShell
   $createVNetForPEP=[bool]1
   write-output "Phase 1 deployment: VNet, PEP for existing Webapp and Functionapp"
   az deployment group create --name $env:name --resource-group $env:rg --mode Incremental   `
     --template-file  "deploy-ServiceBusSimpleSendReceive.bicep"                             `
     --parameters                                                                            `
     "{'uniquePrefix'                   : {'value': '$env:uniquePrefix'}}"                   `
     "{'location'                       : {'value': '$env:loc'}}"                            `
     "{'myIPAddress'                    : {'value': '$env:myIPAddress'}}"                    `
     "{'noManagedIdent'                 : {'value': $noManagedIdent}}"                       `
     "{'functionAppSku'                 : {'value': '$env:functionAppSku'}}"                 `
     "{'serviceBusSku'                  : {'value': '$env:serviceBusSku'}}"                  `
     "{'usePremiumServiceBusFunctionApp': {'value': $usePremiumServiceBusFunctionApp}}"      `
     "{'useServiceBusFireWall'          : {'value': $useServiceBusFireWall}}"                `
     "{'createVNetForPEP'               : {'value': $createVNetForPEP}}"                     `
     "{'createWebAppTestPEP'            : {'value': $createWebAppTestPEP}}"                  `
     "{'useKVForStgConnectionString'    : {'value': $useKVForStgConnectionString}}"          `
     "{'useSourceControlLoadTestCode'   : {'value': $useSourceControlLoadTestCode}}"         `
     "{'storageAccountName'             : {'value': '$env:storageAccountName'}}"             `
     "{'functionAppName'                : {'value': '$env:functionAppName'}}"                `
     "{'functionPlanName'               : {'value': '$env:funcPlanName'}}"                   `
     "{'serviceBusNS'                   : {'value': '$env:serviceBusNS'}}"                   `
     "{'serviceBusQueueName'            : {'value': '$env:serviceBusQueueName'}}"            `
     "{'logAnalyticsWS'                 : {'value': '$env:logAnalyticsWS'}}"                 `
   | ForEach-Object { $_ -replace "`r", ""}
   write-output "end deploy $(Get-Date)"
   End commands to deploy this file using Azure CLI with PowerShell

   Message: The scope '/subscriptions/13c9725f-d20a-4c99-8ef4-d7bb78f98cff/resourcegroups/rg_SBusSndRcv_v-richardsi' cannot perform delete operation because following scope(s) are locked: '/subscriptions/13c9725f-d20a-4c99-8ef4-d7bb78f98cff/resourcegroups/rg_sbussndrcv_v-richardsi/providers/microsoft.storage/storageAccounts/eizdffuncstg'. Please remove the lock and try again.
   emacs ESC 6 F10
   Begin commands for one time initializations using Azure CLI with PowerShell
   write-output "old resource group = $($env:rg_old)"
   az resource list -g $env:rg_old --query "[?resourceGroup=='$env:rg_old'].{ name: name, flavor: kind, resourceType: type, region: location }" --output table  | ForEach-Object { $_ -replace "`r", ""}
   write-output "current resource list"
   End commands for one time initializations using Azure CLI with PowerShell

   emacs ESC 7 F10
   Begin commands to deploy this file using Azure CLI with PowerShell
   write-output "step 7 Create Storage Account for Function App"
   write-output "az storage account create --name $env:storageAccountName  --resource-group $env:rg --location $env:loc --sku Standard_LRS --access-tier Cool"
   az storage account create --name $env:storageAccountName  --resource-group $env:rg --location $env:loc --sku Standard_LRS --access-tier Cool
   End commands to deploy this file using Azure CLI with PowerShell

   emacs ESC 8 F10
   Begin commands to deploy this file using Azure CLI with PowerShell
   write-output "step 8 Show Connection strings for storage Storage Account for Function App"
   write-output "az storage account show-connection-string --resource-group $env:rg --name $env:storageAccountName --output TSV"
   az storage account show-connection-string --resource-group $env:rg --name $env:storageAccountName --output TSV
   End commands to deploy this file using Azure CLI with PowerShell

   emacs ESC 9 F10
   Begin commands to deploy this file using Azure CLI with PowerShell
   write-output "step 9 Create Windows Function App"
   write-output "az functionapp create --resource-group $env:rg --consumption-plan-location $env:loc --runtime dotnet-isolated --runtime-version 8 --functions-version 4 --name $env:functionAppName --storage-account $env:storageAccountName"
   az functionapp create --resource-group $env:rg --consumption-plan-location $env:loc --runtime dotnet-isolated --runtime-version 8 --functions-version 4 --name $env:functionAppName --storage-account $env:storageAccountName
   az functionapp config appsettings list -n $env:functionAppName -g $env:rg
   End commands to deploy this file using Azure CLI with PowerShell

   emacs ESC 10 F10
   Begin commands to deploy this file using Azure CLI with PowerShell
   write-output "step 10 create service bus "
   write-output "az servicebus namespace create --resource-group $env:rg --name $env:serviceBusNS --location $env:loc --sku Basic"
   az servicebus namespace create --resource-group $env:rg --name $env:serviceBusNS --location $env:loc --sku Basic
   write-output "az servicebus queue create --resource-group $env:rg --namespace-name $env:serviceBusNS --name $env:serviceBusQueueName"
   az servicebus queue create --resource-group $env:rg --namespace-name $env:serviceBusNS --name $env:serviceBusQueueName
   End commands to deploy this file using Azure CLI with PowerShell
   
   emacs ESC 11 F10
   Begin commands to deploy this file using Azure CLI with PowerShell
   write-output "Step 11 Set the Environment Variables"
   write-output "az servicebus namespace authorization-rule keys list --resource-group $env:rg --namespace-name $env:serviceBusNS --name RootManageSharedAccessKey --query primaryConnectionString --output tsv"
   $env:ServiceBusConnection=(az servicebus namespace authorization-rule keys list --resource-group $env:rg --namespace-name $env:serviceBusNS --name RootManageSharedAccessKey --query primaryConnectionString --output tsv)
   write-output "(list (setenv `"ServiceBusConnection`" `"$($env:ServiceBusConnectionString)`")"
   write-output "(setenv `"busNS`" `"$($env:serviceBusNS)`")"
   write-output "(setenv `"queue`" `"$($env:serviceBusQueueName)`")"
   write-output "(setenv `"RG_WEBSITE_00`" `"$($env:rg)`")"
   write-output "(setenv `"SS_WEBSITE_00`" `"$($env:functionAppName)`"))"
   write-output "az webapp log tail -n `"$($env:functionAppName)`" -g `"$($env:rg)`""
   #write-output "az webapp config connection-string set --name $env:functionAppName --resource-group $env:rg --settings ServiceBusConnection=$env:ServiceBusConnection --connection-string-type Custom"
   #az webapp config connection-string set --name $env:functionAppName --resource-group $env:rg --settings ServiceBusConnection=$env:ServiceBusConnection --connection-string-type Custom
   write-output "az functionapp config appsettings set --name $env:functionAppName --resource-group $env:rg --settings AzureWebJobsServiceBusConnection=$env:ServiceBusConnection"
   az functionapp config appsettings set --name $env:functionAppName --resource-group $env:rg --settings AzureWebJobsServiceBusConnection=$env:ServiceBusConnection
   End commands to deploy this file using Azure CLI with PowerShell

   emacs ESC 12 F10
   Begin commands to deploy this file using Azure CLI with PowerShell
   write-output "step 12 define environement variables"
   $env:ServiceBusConnection=(az servicebus namespace authorization-rule keys list --resource-group $env:rg --namespace-name $env:serviceBusNS --name RootManageSharedAccessKey --query primaryConnectionString --output tsv)
   #write-output "az webapp config connection-string set --name $env:functionAppName --resource-group $env:rg --settings ServiceBusConnection=$env:ServiceBusConnection --connection-string-type Custom"
   #az webapp config connection-string set --name $env:functionAppName --resource-group $env:rg --settings ServiceBusConnection=$env:ServiceBusConnection --connection-string-type Custom
   write-output "az functionapp config appsettings set --name $env:functionAppName --resource-group $env:rg --settings AzureWebJobsServiceBusConnection=$env:ServiceBusConnection"
   az functionapp config appsettings set --name $env:functionAppName --resource-group $env:rg --settings AzureWebJobsServiceBusConnection=$env:ServiceBusConnection
   write-output "az functionapp config appsettings set --name $env:functionAppName --resource-group $env:rg --settings busNS=$($env:serviceBusNS)"
   az functionapp config appsettings set --name $env:functionAppName --resource-group $env:rg --settings busNS=$env:serviceBusNS
   write-output "az functionapp config appsettings set --name $env:functionAppName --resource-group $env:rg --settings queue=$env:serviceBusQueueName"
   az functionapp config appsettings set --name $env:functionAppName --resource-group $env:rg --settings queue=$env:serviceBusQueueName
   write-output "az webapp config connection-string list --name $env:functionAppName --resource-group $env:rg"
   az webapp config connection-string list --name $env:functionAppName --resource-group $env:rg
   write-output "az functionapp config appsettings list -n $env:functionAppName -g $env:rg"
   az functionapp config appsettings list -n $env:functionAppName -g $env:rg
   End commands to deploy this file using Azure CLI with PowerShell

   emacs ESC 13 F10
   Begin commands to deploy this file using Azure CLI with PowerShell
   write-output "Step 13: Upddate the built at timestamp in the source code (ala ChatGPT)"
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

   emacs ESC 14 F10
   Begin commands to deploy this file using Azure CLI with PowerShell
   write-output "step 14 Publish"
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
   emacs ESC 15 F10
   Begin commands to deploy this file using Azure CLI with PowerShell
   write-output "step 15 zip"
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

   if this step does not work, try zip Deploy
   https://eizdf-func.scm.azurewebsites.net/ZipDeployUI
   emacs ESC 16 F10
   Begin commands to deploy this file using Azure CLI with PowerShell
   write-output "step 16 deploy compiled C# code deployment to azure resource. For Linux Func created with azure cli this gives error: ERROR: Runtime  is not supported."
   write-output "az functionapp deployment source config-zip -g $env:rg -n $env:functionAppName --src ./publish-functionapp.zip"
   az functionapp deployment source config-zip -g $env:rg -n $env:functionAppName --src ./publish-functionapp.zip
   End commands to deploy this file using Azure CLI with PowerShell

   emacs ESC 17 F10
   Begin commands to deploy this file using Azure CLI with PowerShell
   write-output "step 17 deploy compiled C# code deployment to azure resource. For Linux Func created with azure cli this gives error: ERROR: Runtime  is not supported."
   # this worked: 06/26/2024 12:41:15 see *compilation*000003
   # az functionapp deployment source config-zip -g $env:rg -n eizdf-hello-func --src "c:\Users\v-richardsi\source\repos\Siegfried Samples\zipDeployHttpFunc\infrastructure\publish-functionapp.zip"
   az functionapp deployment source config-zip -g $env:rg -n eizdf-func --src "c:\Users\v-richardsi\source\repos\Siegfried Samples\zipDeployHttpFunc\infrastructure\publish-functionapp.zip"
   End commands to deploy this file using Azure CLI with PowerShell

   emacs ESC 18 F10
   Begin commands to deploy this file using Azure CLI with PowerShell
   write-output "step 18 show Function App"
   write-output "az functionapp config appsettings list --resource-group $env:rg --name $env:functionAppName"
   az functionapp config appsettings list --resource-group $env:rg --name $env:functionAppName 
   write-output "az functionapp config show --resource-group $env:rg --name $env:functionAppName"
   az functionapp config show --resource-group $env:rg --name $env:functionAppName 
   write-output "az functionapp show --resource-group $env:rg --name $env:functionAppName"
   az functionapp show --resource-group $env:rg --name $env:functionAppName 
   End commands to deploy this file using Azure CLI with PowerShell

   emacs ESC 19 F10
   Begin commands to deploy this file using Azure CLI with PowerShell
   write-output "step 19 Delete Function App"
   write-output "az functionapp delete --resource-group $env:rg --name $env:functionAppName --keep-empty-plan"
   az functionapp delete --resource-group $env:rg --name $env:functionAppName --keep-empty-plan
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
param functionAppSku string = 'P1V2'
param webappPlanName string = '${uniquePrefix}-plan-web'
param webappSku string = 'B1'
param webappName string = '${uniquePrefix}-webapp'
param serviceBusSku string = 'Premium'
param appInsightsName string = '${uniquePrefix}-appins'
param storageAccountName string = '${uniquePrefix}stg'
param myIPAddress string
param noManagedIdent bool = false
param ownerId string = '' // objectId of the owner (developer)
param usePremiumServiceBusFunctionApp bool = false
param useServiceBusFireWall bool = false
param useKVForStgConnectionString bool = true
param createVNetForPEP bool = false
param createWebAppTestPEP bool = true
param useSourceControlLoadTestCode bool = true
param actionGroups_Application_Insights_Smart_Detection_name string = '${uniquePrefix}-detector'
param logAnalyticsWS string = '/subscriptions/acc26051-92a5-4ed1-a226-64a187bc27db/resourceGroups/DefaultResourceGroup-WUS2/providers/Microsoft.OperationalInsights/workspaces/DefaultWorkspace-acc26051-92a5-4ed1-a226-64a187bc27db-WUS2'

resource serviceBus 'Microsoft.ServiceBus/namespaces@2022-10-01-preview' = if(!createVNetForPEP){
  name: serviceBusNS
  location: location
  sku: {
    name: usePremiumServiceBusFunctionApp ? serviceBusSku : 'Basic'
    tier: usePremiumServiceBusFunctionApp ? serviceBusSku : 'Basic'
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
      ipRules: useServiceBusFireWall ?[
      {
        ipMask: '20.37.194.0/24'
        action: 'Allow'
      }
      {
        ipMask: '20.42.226.0/24'
        action: 'Allow'
      }
      {
        ipMask: '191.235.226.0/24'
        action: 'Allow'
      }
      {
        ipMask: '52.228.82.0/24'
        action: 'Allow'
      }
      {
        ipMask: '20.195.68.0/24'
        action: 'Allow'
      }
      {
        ipMask: '20.41.194.0/24'
        action: 'Allow'
      }
      {
        ipMask: '20.204.197.192/26'
        action: 'Allow'
      }
      {
        ipMask: '20.37.158.0/23'
        action: 'Allow'
      }
      {
        ipMask: '52.150.138.0/24'
        action: 'Allow'
      }
      {
        ipMask: '20.42.5.0/24'
        action: 'Allow'
      }
      {
        ipMask: '20.41.6.0/23'
        action: 'Allow'
      }
      {
        ipMask: '40.80.187.0/24'
        action: 'Allow'
      }
      {
        ipMask: '40.119.10.0/24'
        action: 'Allow'
      }
      {
        ipMask: '40.82.252.0/24'
        action: 'Allow'
      }
      {
        ipMask: '20.42.134.0/23'
        action: 'Allow'
      }
      {
        ipMask: '20.125.155.0/24'
        action: 'Allow'
      }
      {
        ipMask: '40.74.28.0/23'
        action: 'Allow'
      }
      {
        ipMask: '20.166.41.0/24'
        action: 'Allow'
      }
      {
        ipMask: '51.104.26.0/24'
        action: 'Allow'
      }
      {
        ipMask: '174.165.193.226'
        action: 'Allow'
      }
      {
        ipMask: '174.21.173.9'
        action: 'Allow'
      }
      {
        ipMask: '167.220.149.157'
        action: 'Allow'
      }
      {
        ipMask: '131.107.1.233'
        action: 'Allow'
      }
      {
        ipMask: '70.106.212.29'
        action: 'Allow'
      }
      {
        ipMask: '131.107.1.156'
        action: 'Allow'
      }
      {
        ipMask: '20.150.248.0/24'
        action: 'Allow'
      }
      {
        ipMask: '131.107.174.88'
        action: 'Allow'
      }
      {
        ipMask: '167.220.148.16'
        action: 'Allow'
      }      
      {
        ipMask: '172.56.107.163'
        action: 'Allow'
      }
      {
        ipMask: '71.212.18.0'
        action: 'Allow'
      }
      {
        ipMask: myIPAddress
        action: 'Allow'
      }
    ] : []
      trustedServiceAccessEnabled: useServiceBusFireWall? true : false
    }
  }

  resource serviceBusQueue 'queues@2022-10-01-preview' = {
    name: serviceBusQueueName
    properties: {
      maxMessageSizeInKilobytes: usePremiumServiceBusFunctionApp? 1024 : 256
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
resource serviceBus_existing 'Microsoft.ServiceBus/namespaces@2022-10-01-preview' existing = if(createVNetForPEP)  {
      name: serviceBusNS
}

resource storageAccountForFuncApp 'Microsoft.Storage/storageAccounts@2023-04-01' = if(!createVNetForPEP){
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
resource storageAccountForFuncApp_existing 'Microsoft.Storage/storageAccounts@2023-04-01' existing = if(createVNetForPEP) {
      name: storageAccountName
}

output outputOwnerId string = ownerId
var storageAccountConnectionString = 'DefaultEndpointsProtocol=https;AccountName=${storageAccountForFuncApp.name};AccountKey=${storageAccountForFuncApp.listKeys().keys[0].value};EndpointSuffix=${environment().suffixes.storage}'
output outStorageAccountConnectionString1 string = storageAccountConnectionString

var storageAccountConnectionStringMSI = 'AzureWebJobsStorage__${storageAccountName}'
output outputStorageAccountConnectionStringMSI string = storageAccountConnectionStringMSI

resource functionPlan 'Microsoft.Web/serverfarms@2023-12-01' = if(!createVNetForPEP){
  name: functionPlanName
  location: location
  sku: usePremiumServiceBusFunctionApp ? {
    name: functionAppSku  
  } : {
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
resource functionPlan_existing 'Microsoft.Web/serverfarms@2023-12-01' existing = if(createVNetForPEP) {
      name: functionPlanName
}

resource appInsights 'microsoft.insights/components@2020-02-02' = if(!createVNetForPEP){
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

resource actionGroups_Application_Insights_Smart_Detection_name_resource 'microsoft.insights/actionGroups@2023-01-01' = if(!createVNetForPEP){
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

resource smartDetectorAlertRulesFailureAnomalies 'microsoft.alertsmanagement/smartdetectoralertrules@2021-04-01' = if(!createVNetForPEP){
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
output outNoManagedIdent bool = noManagedIdent

// I don't know if we need this key vault for the storage account connection string.
// The problem is that we cannot use a managed identity to access the storage account connection string for the app settting WEBSITE_CONTENTAZUREFILECONNECTIONSTRING (as per the documentation).
// This app setting is required for linux & windows for consumption and elastic premium plans (what is an elastic premium plan? It is not in the pricing calculator). 
// Apparenlty, it is not required for dedicated (standard?) plans which we will probably use in production.
//
// I could try to put this in a seperate module and see if that alleviatges the circular dependency.

resource kv 'Microsoft.KeyVault/vaults@2022-02-01-preview' = if (useKVForStgConnectionString && !createVNetForPEP) {
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
resource kv_existing 'Microsoft.KeyVault/vaults@2022-02-01-preview' existing= if (!useKVForStgConnectionString) {
    name: '${uniquePrefix}-kv'
}

resource kvaadb2cSecret 'Microsoft.KeyVault/vaults/secrets@2019-09-01' =  if (useKVForStgConnectionString && !createVNetForPEP) {
  parent: kv
  name: 'storageAccountConnectionString'
  properties: {
    value: storageAccountConnectionString
  }
}
resource kvaadb2cSecret_existing 'Microsoft.KeyVault/vaults/secrets@2019-09-01' existing= if(createVNetForPEP) {
	parent: kv_existing
	name: 'storageAccountConnectionString'
}
// https://learn.microsoft.com/en-us/azure/app-service/app-service-key-vault-references?tabs=azure-cli#source-app-settings-from-key-vault
// Source app settings from key vault: https://learn.microsoft.com/en-us/azure/app-service/app-service-key-vault-references?tabs=azure-cli#source-app-settings-from-key-vault
// "Unable to resolve Azure Files Settings from Key Vault. Details: Unable to resolve setting: WEBSITE_CONTENTAZUREFILECONNECTIONSTRING with error: InvalidSyntax."
// @Microsoft.KeyVault(VaultName=myvault;SecretName=mysecret)
var storageAccountConnectionStringKV = '@Microsoft.KeyVault(VaultName=${kv.name};SecretName=storageAccountConnectionString)'
// "Unable to resolve Azure Files Settings from Key Vault. Details: Unable to resolve setting: WEBSITE_CONTENTAZUREFILECONNECTIONSTRING with error: InvalidSyntax."
// @Microsoft.KeyVault(SecretUri=https://myvault.vault.azure.net/secrets/mysecret/)
//var storageAccountConnectionStringKV = '@Microsoft.KeyVault(SecretUri=https://${kv.name}.vault.azure.net/secrets/storageAccountConnectionString/)'


resource functionApp 'Microsoft.Web/sites@2023-12-01' = if(!createVNetForPEP){
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
          'https://${myIPAddress}'
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
          value: noManagedIdent? storageAccountConnectionString: storageAccountConnectionStringMSI 
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
          name: noManagedIdent? 'AzureWebJobsServiceBusConnection' : 'ServiceBusConnection__fullyQualifiedNamespace'
          value: noManagedIdent? serviceBusConnection : ServiceBusConnection__fullyQualifiedNamespace
        }
        // https://learn.microsoft.com/en-us/azure/azure-functions/functions-bindings-service-bus-trigger?tabs=python-v2%2Cisolated-process%2Cnodejs-v4%2Cextensionv5&pivots=programming-language-javascript#connection-string
      ]
      // this must be commented out or you will get this error:
      // Microsoft.Azure.WebJobs.Host.Listeners.FunctionListenerException : The listener for function 'Functions.SimpleServiceBusReceiver' was unable to start. ---> System.ArgumentException : The connection string used for an Service Bus client must specify the Service Bus namespace host and either a Shared Access Key (both the name and value) OR a Shared Access Signature to be valid. (Parameter 'connectionString')
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

  resource sourcecontrol 'sourcecontrols@2020-12-01' = if (useSourceControlLoadTestCode) {
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
  resource functionAppConfig 'config@2023-12-01' = {  
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
} 
resource functionApp_existing 'Microsoft.Web/sites@2023-12-01' existing = if(createVNetForPEP){
  name: functionAppName
}
// begin VNet
param virtualNetwork_name string = '${uniquePrefix}-vnet'
param virtualNetwork_CIDR string = '10.200.0.0/16'
param subnet1_name string = '${uniquePrefix}-subnet'
param subnet1_CIDR string = '10.200.1.0/24'
param privateWebEndpoint_name string = '${uniquePrefix}-pep-webapp'
param privateFuncEndpoint_name string = '${uniquePrefix}-pep-funcapp'
param privateLinkConnection_name string = 'privateLink'
param privateDNSZone_name string = 'privatelink.azurewebsites.net'
param webapp_dns_name string = '.azurewebsites.net'

resource virtualNetwork_name_resource 'Microsoft.Network/virtualNetworks@2020-04-01' = if(createVNetForPEP) {
  name: virtualNetwork_name
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        virtualNetwork_CIDR
      ]
    }
  }
}

resource virtualNetwork_name_subnet1_name 'Microsoft.Network/virtualNetworks/subnets@2020-04-01' = if(createVNetForPEP) {
  parent: virtualNetwork_name_resource
  name: subnet1_name
  properties: {
    addressPrefix: subnet1_CIDR
    privateEndpointNetworkPolicies: 'Disabled'
  }
}

resource privateWebEndpoint_name_resource 'Microsoft.Network/privateEndpoints@2019-04-01' = if(createVNetForPEP) {
  name: privateWebEndpoint_name
  location: location
  properties: {
    subnet: {
      id: virtualNetwork_name_subnet1_name.id
    }
    privateLinkServiceConnections: [
      {
        name: privateLinkConnection_name
        properties: {
          privateLinkServiceId: webTestSite_existing.id
          groupIds: [
            'sites'
          ]
        }
      }
    ]
  }
}

resource privateFuncEndpoint_name_resource 'Microsoft.Network/privateEndpoints@2019-04-01' = if(createVNetForPEP) {
  name: privateFuncEndpoint_name
  location: location
  properties: {
    subnet: {
      id: virtualNetwork_name_subnet1_name.id
    }
    privateLinkServiceConnections: [
      {
        name: privateLinkConnection_name
        properties: {
          privateLinkServiceId: functionApp_existing.id
          groupIds: [
            'sites'
          ]
        }
      }
    ]
  }
}

resource privateDNSZone_name_resource 'Microsoft.Network/privateDnsZones@2018-09-01' = if(createVNetForPEP) {
  name: privateDNSZone_name
  location: 'global'
  dependsOn: [
    virtualNetwork_name_resource
  ]
}

resource privateDNSZone_name_privateDNSZone_name_link 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2018-09-01' = if(createVNetForPEP) {
  parent: privateDNSZone_name_resource
  name: '${privateDNSZone_name}-link'
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: virtualNetwork_name_resource.id
    }
  }
}

resource privateWebEndpoint_name_dnsgroupname 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2020-03-01' = if(createVNetForPEP) {
  parent: privateWebEndpoint_name_resource
  name: 'dnsgroupname'
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'config1'
        properties: {
          privateDnsZoneId: privateDNSZone_name_resource.id
        }
      }
    ]
  }
}
// end VNet

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

resource hostingPlan 'Microsoft.Web/serverfarms@2020-12-01' = if (createWebAppTestPEP && !createVNetForPEP){
  name: webappPlanName
  location: location
  sku: {
    name: webappSku
    capacity: 0
  }
  properties: {
    name: webappPlanName
  }
}
// is this necessary? Probably not.
resource hostingPlan_existing 'Microsoft.Web/serverfarms@2020-12-01' existing = if (createWebAppTestPEP && createVNetForPEP){
  name: webappPlanName
}

resource webTestSite 'Microsoft.Web/sites@2020-12-01' = if (createWebAppTestPEP && !createVNetForPEP) {
  name: webappName
  location: location
  properties: {
    serverFarmId: webappPlanName
    siteConfig: {
      webSocketsEnabled: true
      netFrameworkVersion: 'v6.0'
      metadata: [
        {
          name: 'CURRENT_STACK'
          value: 'dotnet'
        }
      ]
    }
    httpsOnly: true
  }

  resource siteName_web 'sourcecontrols@2020-12-01' = if (useSourceControlLoadTestCode && createWebAppTestPEP) {
    name: 'web'
    properties: {
      repoUrl: 'https://github.com/siegfried01/BlazorSvrServiceBusQueueFeeder.git'
      branch: 'master'
      isManualIntegration: true
    }
  }
}

resource webTestSite_existing 'Microsoft.Web/sites@2020-12-01' = if (createWebAppTestPEP && createVNetForPEP) {
  name: webappName
  location: location
}

output appServiceEndpoint string = 'https://${webTestSite.properties.hostNames[0]}'


// One time initializations: Create resource group and service principal for github workflow
// az group create -l eastus2 -n rg_SBusSndRcv002_v-richardsi
// {
//   "id": "/subscriptions/13c9725f-d20a-4c99-8ef4-d7bb78f98cff/resourceGroups/rg_SBusSndRcv002_v-richardsi",
//   "location": "eastus2",
//   "managedBy": null,
//   "name": "rg_SBusSndRcv002_v-richardsi",
//   "properties": {
//     "provisioningState": "Succeeded"
//   },
//   "tags": {
//     "ringValue": "r0"
//   },
//   "type": "Microsoft.Resources/resourceGroups"
// }
// id=/subscriptions/13c9725f-d20a-4c99-8ef4-d7bb78f98cff/resourceGroups/rg_SBusSndRcv002_v-richardsi
// Phase 1 deployment: Function App, WebApp (verification only), Storage Accounts and no VNet and no PEP
// WARNING: C:\Users\v-richardsi\source\repos\Architecture\Sbox360\Design\Verification\ServiceBusSimpleSendReceive\infrastructure\assignRbacRoleToFunctionAppForStorageAccount.bicep(21,5) : Warning BCP073: The property "scope" is read-only. Expressions cannot be assigned to read-only properties. If this is an inaccuracy in the documentation, please report it to the Bicep Team. [https://aka.ms/bicep-type-issues]
// C:\Users\v-richardsi\source\repos\Architecture\Sbox360\Design\Verification\ServiceBusSimpleSendReceive\infrastructure\assignRbacRoleToFunctionApp.bicep(21,5) : Warning BCP073: The property "scope" is read-only. Expressions cannot be assigned to read-only properties. If this is an inaccuracy in the documentation, please report it to the Bicep Team. [https://aka.ms/bicep-type-issues]
// C:\Users\v-richardsi\source\repos\Architecture\Sbox360\Design\Verification\ServiceBusSimpleSendReceive\infrastructure\deploy-ServiceBusSimpleSendReceive.bicep(559,10) : Warning no-unused-existing-resources: Existing resource "serviceBus_existing" is declared but never used. [https://aka.ms/bicep/linter/no-unused-existing-resources]
// C:\Users\v-richardsi\source\repos\Architecture\Sbox360\Design\Verification\ServiceBusSimpleSendReceive\infrastructure\deploy-ServiceBusSimpleSendReceive.bicep(675,10) : Warning no-unused-existing-resources: Existing resource "storageAccountForFuncApp_existing" is declared but never used. [https://aka.ms/bicep/linter/no-unused-existing-resources]
// C:\Users\v-richardsi\source\repos\Architecture\Sbox360\Design\Verification\ServiceBusSimpleSendReceive\infrastructure\deploy-ServiceBusSimpleSendReceive.bicep(712,10) : Warning no-unused-existing-resources: Existing resource "functionPlan_existing" is declared but never used. [https://aka.ms/bicep/linter/no-unused-existing-resources]
// C:\Users\v-richardsi\source\repos\Architecture\Sbox360\Design\Verification\ServiceBusSimpleSendReceive\infrastructure\deploy-ServiceBusSimpleSendReceive.bicep(1100,10) : Warning no-unused-existing-resources: Existing resource "kvaadb2cSecret_existing" is declared but never used. [https://aka.ms/bicep/linter/no-unused-existing-resources]
// C:\Users\v-richardsi\source\repos\Architecture\Sbox360\Design\Verification\ServiceBusSimpleSendReceive\infrastructure\deploy-ServiceBusSimpleSendReceive.bicep(1362,7) : Warning no-unused-params: Parameter "webapp_dns_name" is declared but never used. [https://aka.ms/bicep/linter/no-unused-params]
// C:\Users\v-richardsi\source\repos\Architecture\Sbox360\Design\Verification\ServiceBusSimpleSendReceive\infrastructure\deploy-ServiceBusSimpleSendReceive.bicep(1498,5) : Warning BCP037: The property "name" is not allowed on objects of type "AppServicePlanProperties". Permissible properties include "freeOfferExpirationTime", "hostingEnvironmentProfile", "hyperV", "isSpot", "isXenon", "kubeEnvironmentProfile", "maximumElasticWorkerCount", "perSiteScaling", "reserved", "spotExpirationTime", "targetWorkerCount", "targetWorkerSizeId", "workerTierName". If this is an inaccuracy in the documentation, please report it to the Bicep Team. [https://aka.ms/bicep-type-issues]
// C:\Users\v-richardsi\source\repos\Architecture\Sbox360\Design\Verification\ServiceBusSimpleSendReceive\infrastructure\deploy-ServiceBusSimpleSendReceive.bicep(1502,10) : Warning no-unused-existing-resources: Existing resource "hostingPlan_existing" is declared but never used. [https://aka.ms/bicep/linter/no-unused-existing-resources]
// C:\Users\v-richardsi\source\repos\Architecture\Sbox360\Design\Verification\ServiceBusSimpleSendReceive\infrastructure\deploy-ServiceBusSimpleSendReceive.bicep(1514,7) : Warning BCP037: The property "metadata" is not allowed on objects of type "SiteConfig". Permissible properties include "acrUseManagedIdentityCreds", "acrUserManagedIdentityID", "alwaysOn", "apiDefinition", "apiManagementConfig", "appCommandLine", "appSettings", "autoHealEnabled", "autoHealRules", "autoSwapSlotName", "azureStorageAccounts", "connectionStrings", "cors", "defaultDocuments", "detailedErrorLoggingEnabled", "documentRoot", "experiments", "ftpsState", "functionAppScaleLimit", "functionsRuntimeScaleMonitoringEnabled", "handlerMappings", "healthCheckPath", "http20Enabled", "httpLoggingEnabled", "ipSecurityRestrictions", "javaContainer", "javaContainerVersion", "javaVersion", "keyVaultReferenceIdentity", "limits", "linuxFxVersion", "loadBalancing", "localMySqlEnabled", "logsDirectorySizeLimit", "managedPipelineMode", "managedServiceIdentityId", "minimumElasticInstanceCount", "minTlsVersion", "nodeVersion", "numberOfWorkers", "phpVersion", "powerShellVersion", "preWarmedInstanceCount", "publicNetworkAccess", "publishingUsername", "push", "pythonVersion", "remoteDebuggingEnabled", "remoteDebuggingVersion", "requestTracingEnabled", "requestTracingExpirationTime", "scmIpSecurityRestrictions", "scmIpSecurityRestrictionsUseMain", "scmMinTlsVersion", "scmType", "tracingOptions", "use32BitWorkerProcess", "virtualApplications", "vnetName", "vnetPrivatePortsCount", "vnetRouteAllEnabled", "websiteTimeZone", "windowsFxVersion", "xManagedServiceIdentityId". If this is an inaccuracy in the documentation, please report it to the Bicep Team. [https://aka.ms/bicep-type-issues]
// C:\Users\v-richardsi\source\repos\Architecture\Sbox360\Design\Verification\ServiceBusSimpleSendReceive\infrastructure\assignRbacRoleToFunctionAppForKVAccess.bicep(23,5) : Warning BCP073: The property "scope" is read-only. Expressions cannot be assigned to read-only properties. If this is an inaccuracy in the documentation, please report it to the Bicep Team. [https://aka.ms/bicep-type-issues]
// 
// ERROR: {
//   "status": "Failed",
//   "error": {
//     "code": "DeploymentFailed",
//     "target": "/subscriptions/13c9725f-d20a-4c99-8ef4-d7bb78f98cff/resourceGroups/rg_SBusSndRcv002_v-richardsi/providers/Microsoft.Resources/deployments/SBusSndRcv002_v-richardsi",
//     "message": "At least one resource deployment operation failed. Please list deployment operations for details. Please see https://aka.ms/arm-deployment-operations for usage details.",
//     "details": [
//       {
//         "code": "NotFound",
//         "target": "/subscriptions/13c9725f-d20a-4c99-8ef4-d7bb78f98cff/resourceGroups/rg_SBusSndRcv002_v-richardsi/providers/Microsoft.Web/sites/xizdf-webapp",
//         "message": {
//                       "Code": "NotFound",
//                       "Message": "Cannot find ServerFarm with name xizdf-plan-web.",
//                       "Target": null,
//                       "Details": [
//                         {
//                           "Message": "Cannot find ServerFarm with name xizdf-plan-web."
//                         },
//                         {
//                           "Code": "NotFound"
//                         },
//                         {
//                           "ErrorEntity": {
//                             "ExtendedCode": "51004",
//                             "MessageTemplate": "Cannot find {0} with name {1}.",
//                             "Parameters": [
//                               "ServerFarm",
//                               "xizdf-plan-web"
//                             ],
//                             "Code": "NotFound",
//                             "Message": "Cannot find ServerFarm with name xizdf-plan-web."
//                           }
//                         }
//                       ],
//                       "Innererror": null
//                     }
//       }
//     ]
//   }
// }
// 
// end deploy 07/09/2024 13:28:12
// Name                      Flavor       ResourceType                                        Region
// ------------------------  -----------  --------------------------------------------------  --------
// jwlpu-func                app          Microsoft.Web/sites                                 eastus2
// Default1cj                app          Microsoft.Web/serverFarms                           eastus2
// xizdf-detector                         Microsoft.Insights/actiongroups                     global
// xizdffuncstg              StorageV2    Microsoft.Storage/storageAccounts                   eastus2
// xizdf-plan-func           functionapp  Microsoft.Web/serverFarms                           eastus2
// xizdf-appins              web          Microsoft.Insights/components                       eastus2
// xizdf-servicebus                       Microsoft.ServiceBus/namespaces                     eastus2
// xizdf-plan-web            app          Microsoft.Web/serverFarms                           eastus2
// xizdf-failure anomalies                microsoft.alertsManagement/smartDetectorAlertRules  global
// xizdf-func                functionapp  Microsoft.Web/sites                                 eastus2
// aztblogsv12ldpgrf7o7yoq4  StorageV2    microsoft.storage/storageAccounts                   eastus2
// all done 07/09/2024 13:28:15 elapse time = 00:02:08 
// 
// Process compilation finished
// 
