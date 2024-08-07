/*
   From a (cygwin) bash prompt, use this perl one-liner to extract the powershell script fragments and exeucte them. This example shows how to execute steps 2 (shutdown) and steps 4-13 and skipping steps 7,8,9 because they don't work (yet). Adjust that list of steps according to your needs.

   powershell -executionPolicy unrestricted -Command - <<EOF
   `perl -lne 'sub range {$b=shift; $e=shift; $r=""; for(($b..$e)){ $r=$r."," if $r; $r=$r.$_;} $r } BEGIN {  $_ = shift; s/([0-9]+)-([0-9]+)/range($1,$2)/e; @idx=split ","; $c=0; $x=0; $f=0; $s=[] } $c++ if /^\s*Begin/; if (/^\s*End/) {$c--;$s[$f++]=""}; if ($x+$c>1) { $s->[$f]=$s->[$f].$_."\n"  } $x=$c; END { push(@idx, $#s); unshift @idx,0; for (@idx) { $p=$s->[$_]; chomp $p; print $p } }' "2,4-6,10-13" < "deploy-ServiceBusSimpleSendReceive.bicep"  `
EOF

   Begin common prolog commands
   # When USERNAME=="shein" we are running in Siegfried personal azure account
   If ($env:USERNAME -eq "shein") { $env:name='SBusSndRcv' } else { $env:name="SBusSndRcv_$($env:USERNAME)" }
   $env:rg="rg_$($env:name)"
   $env:loc=If ($env:AZ_DEFAULT_LOC) { $env:AZ_DEFAULT_LOC} Else {'eastus2'}
   $env:uniquePrefix="$(If ($env:USERNAME -eq "v-richardsi") {"xizdf"} ElseIf ($env:USERNAME -eq "v-paperry") { "iucpl" } ElseIf ($env:USERNAME -eq "shein") {"iqa5jvm"} Else { "jyzwg" } )"
   $env:serviceBusQueueName = 'mainqueue001'
   $useServiceBusFireWall=[bool]0
   $noManagedIdent=[bool]1
   $useApplicationInsights=[bool]0
   $useSourceControlLoadTestCode=If ($env:USERNAME -eq "shein") { [bool]1 } Else { [bool]0 }
   $useKVForStgConnectionString=[bool]0
   $createVNetForPEP=[bool]0
   $createWebAppTestPEP=[bool]1
   $env:myIPAddress="172.56.105.149"
   $usePremiumServiceBusFunctionApp=If ($env:USERNAME -eq "shein") { [bool]0 } Else { [bool]1 }
   If ( $usePremiumServiceBusFunctionApp ) {
     $env:functionAppSku='P1V2'
     $env:webAppSku='P1V2'
     $env:serviceBusSku='Premium'
     # Basic causes this error: The property 'property name' can't be set when creating a Queue because the namespace 'namespace name' is using the 'Basic' Tier. This operation is only supported in 'Standard' or 'Premium' tier.
     $env:serviceBusSku='Standard'
     $useServiceBusFireWall=[bool]0
   } Else {
     $env:webAppSku==If ($env:USERNAME -eq "shein") { 'F1' } Else { 'B1' }
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
   # Create an Owner tag for resources
   $tags = @{"Owner"="$($env:USERNAME)-test"}
   # Check to see if the Resource Group exists or not
   # Set the Resource Group tags
   write-output "Set-AzResourceGroup -Name $($env:rg) -Tag $tags StatusCode: 403 ReasonPhrase: Forbidden"
   #Set-AzResourceGroup -Name $env:rg -Tag $tags
   write-output "start build for resource group = $($env:rg) at $StartTime"
   End common prolog commands

   emacs F10
   Begin commands to deploy this file using Azure CLI with PowerShell
   $createVNetForPEP=[bool]0
   $createWebAppTestPEP=[bool]1
   write-output "Phase 1 deployment: Create Service Bus queue (tier=$($env:serviceBusSku)), Function App (tier=$($env:functionAppSku)) WebApp=$($createWebAppTestPEP), Storage Accounts and VNet=$createVNetForPEP and no PEP useSourceControlLoadTestCode=$useSourceControlLoadTestCode functionAppSku=$($env:functionAppSku) webAppSku=$($env:webAppSku) useServiceBusFireWall=$useServiceBusFireWall "
   $resourceGroupExists = Get-AzResourceGroup -Name $env:rg -ErrorAction SilentlyContinue
   #if ($resourceGroupExists) {
   #    write-output "$($env:rg) exists, no need to create"
   #}
   #else {
   #    write-output "az group create --name $($env:rg) --location $($env:loc)"
   #    az group create --name $env:rg --location $env:loc
   #}
   write-output "az deployment group create --name $($env:name) --resource-group $($env:rg) --mode Incremental --template-file deploy-ServiceBusSimpleSendReceive.bicep"
   az deployment group create --name $env:name --resource-group $env:rg --mode Incremental   `
     --template-file  "deploy-ServiceBusSimpleSendReceive.bicep"                             `
     --parameters                                                                            `
     "{'uniquePrefix'                   : {'value': '$env:uniquePrefix'}}"                   `
     "{'location'                       : {'value': '$env:loc'}}"                            `
     "{'myIPAddress'                    : {'value': '$env:myIPAddress'}}"                    `
     "{'noManagedIdent'                 : {'value': $noManagedIdent}}"                       `
     "{'useApplicationInsights'         : {'value': $useApplicationInsights}}"               `
     "{'functionAppSku'                 : {'value': '$env:functionAppSku'}}"                 `
     "{'webAppSku'                      : {'value': '$env:functionAppSku'}}"                 `
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
   write-output "Step 3: begin shutdown delete resource group $($env:rg) $(Get-Date)"
   write-output "az group delete -n $env:rg"
   az group delete -n $env:rg --yes
   write-output "shutdown is complete $env:rg $(Get-Date)"
   End commands to shut down this deployment using Azure CLI with PowerShell

   emacs ESC 4 F10
   Begin commands for one time initializations using Azure CLI with PowerShell
   write-output "One time initializations: Create resource group and service principal for github workflow"
   write-output "az group create -l $env:loc -n $env:rg"
   az group create -l $env:loc -n $env:rg
   $env:id=(az group show --name $env:rg --query 'id' --output tsv)
   write-output "id=$env:id"
   write-output "{`n`"`$schema`": `"https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#`",`n `"contentVersion`": `"1.0.0.0`",`n `"resources`": [] `n}" | Out-File -FilePath clear-resources.json
   End commands for one time initializations using Azure CLI with PowerShell


   emacs ESC 5 F10
   Begin commands to deploy this file using Azure CLI with PowerShell
   $createVNetForPEP=[bool]1
   $createWebAppTestPEP=[bool]1
   write-output "Step 5: Phase 2 deployment: VNet=$createVNetForPEP createWebAppTestPEP=$createWebAppTestPEP and use existing FunctionApp, existing WebApp and existing Service Bus"
   az deployment group create --name $env:name --resource-group $env:rg --mode Incremental  --debug  `
     --template-file  "deploy-ServiceBusSimpleSendReceive.bicep"                             `
     --parameters                                                                            `
     "{'uniquePrefix'                   : {'value': '$env:uniquePrefix'}}"                   `
     "{'location'                       : {'value': '$env:loc'}}"                            `
     "{'myIPAddress'                    : {'value': '$env:myIPAddress'}}"                    `
     "{'noManagedIdent'                 : {'value': $noManagedIdent}}"                       `
     "{'useApplicationInsights'         : {'value': $useApplicationInsights}}"               `
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
   Begin commands to execute this file using Azure CLI with PowerShell
   write-output "Step 19: To verify the static IP address and the functionality of the private endpoint, a test virtual machine connected to your virtual network is required."
   write-output "Create the virtual machine with az vm create. $(Get-Date)"
   $env:vnetName="$($env:uniquePrefix)-vnet"
   $env:subnetName="$($env:uniquePrefix)-subnet"
   $env:vmName="$($env:uniquePrefix)-vm"
   $env:VMSize="Standard_B4ms"
   write-output "az vm create --resource-group $env:rg  --name $env:vmName  --image Win2022Datacenter --vnet-name $env:vnetName  --subnet $env:subnetName  --admin-username azureuser --admin-password JxQZEwsTc5y0bSIosT7KGa6 --size $env:VMSize"
   az vm create --resource-group $env:rg  --name $env:vmName  --image Win2022Datacenter --vnet-name $env:vnetName  --subnet $env:subnetName  --admin-username azureuser --admin-password JxQZEwsTc5y0bSIosT7KGa6 --size $env:VMSize
   write-output "Done creating VM $(Get-Date)"
   End commands to execute this file using Azure CLI with PowerShell

   emacs ESC 20 F10
   Begin commands to deploy this file using Azure CLI with PowerShell
   write-output "step 20 Delete Function App"
   write-output "az functionapp delete --resource-group $env:rg --name $env:functionAppName --keep-empty-plan"
   az functionapp delete --resource-group $env:rg --name $env:functionAppName --keep-empty-plan
   End commands to deploy this file using Azure CLI with PowerShell

   Begin common epilog commands
   write-output "resource group = $($env:rg)"
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
param webAppSku string = 'B1'

param webAppSkuName string = 'P1v2'
param webAppSkuTier string = 'PremiumV2'
param webAppSkuSize string = 'P1v2'
param webAppSkuFamily string = 'P1v2'

param webappName string = '${uniquePrefix}-webapp'
param serviceBusSku string = 'Premium'
param appInsightsName string = '${uniquePrefix}-appins'
param storageAccountName string = '${uniquePrefix}stg'
param myIPAddress string
param noManagedIdent bool = false
param useApplicationInsights bool = false
param ownerId string = '' // objectId of the owner (developer)
param usePremiumServiceBusFunctionApp bool = false
param useServiceBusFireWall bool = false
param useKVForStgConnectionString bool = true
param createVNetForPEP bool = false
param createWebAppTestPEP bool = true
param useSourceControlLoadTestCode bool = true
param actionGroups_Application_Insights_Smart_Detection_name string = '${uniquePrefix}-detector'
param logAnalyticsWS string = '/subscriptions/acc26051-92a5-4ed1-a226-64a187bc27db/resourceGroups/DefaultResourceGroup-WUS2/providers/Microsoft.OperationalInsights/workspaces/DefaultWorkspace-acc26051-92a5-4ed1-a226-64a187bc27db-WUS2'

resource serviceBus 'Microsoft.ServiceBus/namespaces@2021-11-01' = if(!createVNetForPEP){
  name: serviceBusNS
  location: location
  sku: {
    name: serviceBusSku
    tier: serviceBusSku
  }
  properties: {
    minimumTlsVersion: '1.2'
    publicNetworkAccess: 'Enabled'
    zoneRedundant: false
  }  
  resource serviceBusQueue 'queues@2021-11-01' = {
    name: serviceBusQueueName
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

resource appInsights 'microsoft.insights/components@2020-02-02' = if(!createVNetForPEP && useApplicationInsights){
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

resource actionGroups_Application_Insights_Smart_Detection_name_resource 'microsoft.insights/actionGroups@2023-01-01' = if(!createVNetForPEP && useApplicationInsights){
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

resource smartDetectorAlertRulesFailureAnomalies 'microsoft.alertsmanagement/smartdetectoralertrules@2021-04-01' = if(!createVNetForPEP && useApplicationInsights){
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

resource privateWebEndpoint_name_resource 'Microsoft.Network/privateEndpoints@2019-04-01' = if(createWebAppTestPEP && createVNetForPEP) {
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

resource privateWebEndpoint_name_dnsgroupname 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2020-03-01' = if(createWebAppTestPEP && createVNetForPEP) {
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
    name: webAppSkuName
    tier: webAppSkuTier
    size: webAppSkuSize
    family: webAppSkuFamily
    capacity: 1
  }
  // properties: {
  //   name: webappPlanName
  // }
    kind: 'app'
}
// is this necessary? Probably not.
resource hostingPlan_existing 'Microsoft.Web/serverfarms@2020-12-01' existing = if (createWebAppTestPEP && createVNetForPEP){
  name: webappPlanName
}

resource webTestSite 'Microsoft.Web/sites@2020-12-01' = if (createWebAppTestPEP && !createVNetForPEP) {
  name: webappName
  location: location
  kind: 'app'
  properties: {
    serverFarmId: hostingPlan.id
    enabled: true
    hostNameSslStates: [
      {
        name: concat(webappName, webapp_dns_name)
        sslState: 'Disabled'
        hostType: 'Standard'
      }
      {
        name: '${webappName}.scm${webapp_dns_name}'
        sslState: 'Disabled'
        hostType: 'Repository'
      }
    ]
    siteConfig: {
      //  webSocketsEnabled: true
      //  netFrameworkVersion: 'v6.0'
      //  metadata: [
      //    {
      //      name: 'CURRENT_STACK'
      //      value: 'dotnet'
      //    }
      //  ]
      appSettings: [
        {
          name: 'busNS'
          value: serviceBusNS
        }
        {
          name: 'queue'
          value: serviceBusQueueName
        }
        {
          name: 'serviceBusConnectionString' 
          value: serviceBusConnection
        }
        // https://learn.microsoft.com/en-us/azure/azure-functions/functions-bindings-service-bus-trigger?tabs=python-v2%2Cisolated-process%2Cnodejs-v4%2Cextensionv5&pivots=programming-language-javascript#connection-string
      ]  
    }
    //httpsOnly: true
  }
  //  resource slot 'slots@2020-06-01' = {
  //    name: 'Production'
  //    location: location
  //    properties: {
  //    }
  //  }
  resource siteName_web 'sourcecontrols@2020-12-01' = if (useSourceControlLoadTestCode && createWebAppTestPEP) {
    name: 'web'
    properties: {
      repoUrl: 'https://github.com/siegfried01/BlazorSvrServiceBusQueueFeeder.git'
      branch: 'master'
      isManualIntegration: true
    }
  }
  resource site_name_web 'config@2019-08-01' = {   
    name: 'web'
    properties: {
      ftpsState: 'AllAllowed'
    }
  }
  resource site_name_site_name_webapp_dns_name 'hostNameBindings@2019-08-01' = {
    name: '${webappName}${webapp_dns_name}'
    properties: {
      siteName: webappName
      hostNameType: 'Verified'
    }
  }
}

resource webTestSite_existing 'Microsoft.Web/sites@2020-12-01' existing = if (createWebAppTestPEP && createVNetForPEP) {
  // This will be run as part of Phase 2
  // The name has to be the current webTestSite
  name: webappName
  // location: location
  // location was throwing an error due to the previous definition in the other webTestSite instance
}
//
//  This causes problems if we are not creating the website
//  output appServiceEndpoint string = 'https://${webTestSite.properties.hostNames[0]}'

// begin failure log


// Set-AzResourceGroup -Name rg_SBusSndRcv_v-richardsi -Tag System.Collections.Hashtable StatusCode: 403 ReasonPhrase: Forbidden
// start build for resource group = rg_SBusSndRcv_v-richardsi at 07/12/2024 09:57:02
// Step 5: Phase 2 deployment: VNet=True createWebAppTestPEP=True and use existing FunctionApp, existing WebApp and existing Service Bus
// WARNING: C:\Users\v-richardsi\source\repos\Architecture\Sbox360\Design\Verification\ServiceBusSimpleSendReceive\infrastructure\assignRbacRoleToFunctionAppForStorageAccount.bicep(21,5) : Warning BCP073: The property "scope" is read-only. Expressions cannot be assigned to read-only properties. If this is an inaccuracy in the documentation, please report it to the Bicep Team. [https://aka.ms/bicep-type-issues]
// C:\Users\v-richardsi\source\repos\Architecture\Sbox360\Design\Verification\ServiceBusSimpleSendReceive\infrastructure\assignRbacRoleToFunctionApp.bicep(21,5) : Warning BCP073: The property "scope" is read-only. Expressions cannot be assigned to read-only properties. If this is an inaccuracy in the documentation, please report it to the Bicep Team. [https://aka.ms/bicep-type-issues]
// C:\Users\v-richardsi\source\repos\Architecture\Sbox360\Design\Verification\ServiceBusSimpleSendReceive\infrastructure\assignRbacRoleToFunctionAppForKVAccess.bicep(23,5) : Warning BCP073: The property "scope" is read-only. Expressions cannot be assigned to read-only properties. If this is an inaccuracy in the documentation, please report it to the Bicep Team. [https://aka.ms/bicep-type-issues]
// C:\Users\v-richardsi\source\repos\Architecture\Sbox360\Design\Verification\ServiceBusSimpleSendReceive\infrastructure\deploy-ServiceBusSimpleSendReceive.bicep(376,7) : Warning no-unused-params: Parameter "webAppSku" is declared but never used. [https://aka.ms/bicep/linter/no-unused-params]
// C:\Users\v-richardsi\source\repos\Architecture\Sbox360\Design\Verification\ServiceBusSimpleSendReceive\infrastructure\deploy-ServiceBusSimpleSendReceive.bicep(581,10) : Warning no-unused-existing-resources: Existing resource "serviceBus_existing" is declared but never used. [https://aka.ms/bicep/linter/no-unused-existing-resources]
// C:\Users\v-richardsi\source\repos\Architecture\Sbox360\Design\Verification\ServiceBusSimpleSendReceive\infrastructure\deploy-ServiceBusSimpleSendReceive.bicep(697,10) : Warning no-unused-existing-resources: Existing resource "storageAccountForFuncApp_existing" is declared but never used. [https://aka.ms/bicep/linter/no-unused-existing-resources]
// C:\Users\v-richardsi\source\repos\Architecture\Sbox360\Design\Verification\ServiceBusSimpleSendReceive\infrastructure\deploy-ServiceBusSimpleSendReceive.bicep(734,10) : Warning no-unused-existing-resources: Existing resource "functionPlan_existing" is declared but never used. [https://aka.ms/bicep/linter/no-unused-existing-resources]
// C:\Users\v-richardsi\source\repos\Architecture\Sbox360\Design\Verification\ServiceBusSimpleSendReceive\infrastructure\deploy-ServiceBusSimpleSendReceive.bicep(1122,10) : Warning no-unused-existing-resources: Existing resource "kvaadb2cSecret_existing" is declared but never used. [https://aka.ms/bicep/linter/no-unused-existing-resources]
// C:\Users\v-richardsi\source\repos\Architecture\Sbox360\Design\Verification\ServiceBusSimpleSendReceive\infrastructure\deploy-ServiceBusSimpleSendReceive.bicep(1528,10) : Warning no-unused-existing-resources: Existing resource "hostingPlan_existing" is declared but never used. [https://aka.ms/bicep/linter/no-unused-existing-resources]
// C:\Users\v-richardsi\source\repos\Architecture\Sbox360\Design\Verification\ServiceBusSimpleSendReceive\infrastructure\deploy-ServiceBusSimpleSendReceive.bicep(1541,15) : Warning prefer-interpolation: Use string interpolation instead of the concat function. [https://aka.ms/bicep/linter/prefer-interpolation]

// ERROR: {
//   "status": "Failed",
//   "error": {
//     "code": "DeploymentFailed",
//     "target": "/subscriptions/13c9725f-d20a-4c99-8ef4-d7bb78f98cff/resourceGroups/rg_SBusSndRcv_v-richardsi/providers/Microsoft.Resources/deployments/SBusSndRcv_v-richardsi",
//     "message": "At least one resource deployment operation failed. Please list deployment operations for details. Please see https://aka.ms/arm-deployment-operations for usage details.",
//     "details": [
//       {
//         "code": "BadRequest",
//         "target": "/subscriptions/13c9725f-d20a-4c99-8ef4-d7bb78f98cff/resourceGroups/rg_SBusSndRcv_v-richardsi/providers/Microsoft.Web/sites/xizdf-webapp",
//         "message": {
//                       "Code": "BadRequest",
//                       "Message": "The parameter properties has an invalid value.",
//                       "Target": null,
//                       "Details": [
//                         {
//                           "Message": "The parameter properties has an invalid value."
//                         },
//                         {
//                           "Code": "BadRequest"
//                         },
//                         {
//                           "ErrorEntity": {
//                             "ExtendedCode": "51008",
//                             "MessageTemplate": "The parameter {0} has an invalid value.",
//                             "Parameters": [
//                               "properties"
//                             ],
//                             "Code": "BadRequest",
//                             "Message": "The parameter properties has an invalid value."
//                           }
//                         }
//                       ],
//                       "Innererror": null
//                     }
//       }
//     ]
//   }
// }

// end deploy 07/12/2024 09:58:55
// resource group = rg_SBusSndRcv_v-richardsi
// Name                                                              Flavor       ResourceType                                           Region
// ----------------------------------------------------------------  -----------  -----------------------------------------------------  --------
// xizdf-plan-func                                                   functionapp  Microsoft.Web/serverFarms                              eastus2
// xizdf-func                                                        functionapp  Microsoft.Web/sites                                    eastus2
// xizdf-appins                                                      web          Microsoft.Insights/components                          eastus2
// xizdf-servicebus                                                               Microsoft.ServiceBus/namespaces                        eastus2
// xizdffuncstg                                                      StorageV2    Microsoft.Storage/storageAccounts                      eastus2
// xizdf-plan-web                                                    app          Microsoft.Web/serverFarms                              eastus2
// xizdf-detector                                                                 Microsoft.Insights/actiongroups                        global
// xizdf-failure anomalies                                                        microsoft.alertsManagement/smartDetectorAlertRules     global
// xizdf-webapp                                                      app          Microsoft.Web/sites                                    eastus2
// aztblogsv12u2gzyv3w2zong                                          StorageV2    microsoft.storage/storageAccounts                      eastus2
// xizdf-vnet                                                                     Microsoft.Network/virtualNetworks                      eastus2
// privatelink.azurewebsites.net                                                  Microsoft.Network/privateDnsZones                      global
// xizdf-pep-funcapp                                                              Microsoft.Network/privateEndpoints                     eastus2
// xizdf-pep-funcapp.nic.d10aab10-6006-498a-9647-93fce436b167                     Microsoft.Network/networkInterfaces                    eastus2
// privatelink.azurewebsites.net/privatelink.azurewebsites.net-link               Microsoft.Network/privateDnsZones/virtualNetworkLinks  global
// all done 07/12/2024 09:58:58 elapse time = 00:01:55 

// Process compilation finished



// Set-AzResourceGroup -Name rg_SBusSndRcv_v-richardsi -Tag System.Collections.Hashtable StatusCode: 403 ReasonPhrase: Forbidden
// start build for resource group = rg_SBusSndRcv_v-richardsi at 07/11/2024 15:57:39
// Step 5: Phase 2 deployment: VNet=True createWebAppTestPEP=True and use existing FunctionApp, existing WebApp and existing Service Bus
// WARNING: C:\Users\v-richardsi\source\repos\Architecture\Sbox360\Design\Verification\ServiceBusSimpleSendReceive\infrastructure\assignRbacRoleToFunctionApp.bicep(21,5) : Warning BCP073: The property "scope" is read-only. Expressions cannot be assigned to read-only properties. If this is an inaccuracy in the documentation, please report it to the Bicep Team. [https://aka.ms/bicep-type-issues]
// C:\Users\v-richardsi\source\repos\Architecture\Sbox360\Design\Verification\ServiceBusSimpleSendReceive\infrastructure\deploy-ServiceBusSimpleSendReceive.bicep(369,7) : Warning no-unused-params: Parameter "webAppSku" is declared but never used. [https://aka.ms/bicep/linter/no-unused-params]
// C:\Users\v-richardsi\source\repos\Architecture\Sbox360\Design\Verification\ServiceBusSimpleSendReceive\infrastructure\deploy-ServiceBusSimpleSendReceive.bicep(574,10) : Warning no-unused-existing-resources: Existing resource "serviceBus_existing" is declared but never used. [https://aka.ms/bicep/linter/no-unused-existing-resources]
// C:\Users\v-richardsi\source\repos\Architecture\Sbox360\Design\Verification\ServiceBusSimpleSendReceive\infrastructure\deploy-ServiceBusSimpleSendReceive.bicep(690,10) : Warning no-unused-existing-resources: Existing resource "storageAccountForFuncApp_existing" is declared but never used. [https://aka.ms/bicep/linter/no-unused-existing-resources]
// C:\Users\v-richardsi\source\repos\Architecture\Sbox360\Design\Verification\ServiceBusSimpleSendReceive\infrastructure\deploy-ServiceBusSimpleSendReceive.bicep(727,10) : Warning no-unused-existing-resources: Existing resource "functionPlan_existing" is declared but never used. [https://aka.ms/bicep/linter/no-unused-existing-resources]
// C:\Users\v-richardsi\source\repos\Architecture\Sbox360\Design\Verification\ServiceBusSimpleSendReceive\infrastructure\deploy-ServiceBusSimpleSendReceive.bicep(1115,10) : Warning no-unused-existing-resources: Existing resource "kvaadb2cSecret_existing" is declared but never used. [https://aka.ms/bicep/linter/no-unused-existing-resources]
// C:\Users\v-richardsi\source\repos\Architecture\Sbox360\Design\Verification\ServiceBusSimpleSendReceive\infrastructure\deploy-ServiceBusSimpleSendReceive.bicep(1521,10) : Warning no-unused-existing-resources: Existing resource "hostingPlan_existing" is declared but never used. [https://aka.ms/bicep/linter/no-unused-existing-resources]
// C:\Users\v-richardsi\source\repos\Architecture\Sbox360\Design\Verification\ServiceBusSimpleSendReceive\infrastructure\deploy-ServiceBusSimpleSendReceive.bicep(1534,15) : Warning prefer-interpolation: Use string interpolation instead of the concat function. [https://aka.ms/bicep/linter/prefer-interpolation]
// C:\Users\v-richardsi\source\repos\Architecture\Sbox360\Design\Verification\ServiceBusSimpleSendReceive\infrastructure\deploy-ServiceBusSimpleSendReceive.bicep(1547,7) : Warning BCP037: The property "metadata" is not allowed on objects of type "SiteConfig". Permissible properties include "acrUseManagedIdentityCreds", "acrUserManagedIdentityID", "alwaysOn", "apiDefinition", "apiManagementConfig", "appCommandLine", "autoHealEnabled", "autoHealRules", "autoSwapSlotName", "azureStorageAccounts", "connectionStrings", "cors", "defaultDocuments", "detailedErrorLoggingEnabled", "documentRoot", "experiments", "ftpsState", "functionAppScaleLimit", "functionsRuntimeScaleMonitoringEnabled", "handlerMappings", "healthCheckPath", "http20Enabled", "httpLoggingEnabled", "ipSecurityRestrictions", "javaContainer", "javaContainerVersion", "javaVersion", "keyVaultReferenceIdentity", "limits", "linuxFxVersion", "loadBalancing", "localMySqlEnabled", "logsDirectorySizeLimit", "managedPipelineMode", "managedServiceIdentityId", "minimumElasticInstanceCount", "minTlsVersion", "nodeVersion", "numberOfWorkers", "phpVersion", "powerShellVersion", "preWarmedInstanceCount", "publicNetworkAccess", "publishingUsername", "push", "pythonVersion", "remoteDebuggingEnabled", "remoteDebuggingVersion", "requestTracingEnabled", "requestTracingExpirationTime", "scmIpSecurityRestrictions", "scmIpSecurityRestrictionsUseMain", "scmMinTlsVersion", "scmType", "tracingOptions", "use32BitWorkerProcess", "virtualApplications", "vnetName", "vnetPrivatePortsCount", "vnetRouteAllEnabled", "websiteTimeZone", "windowsFxVersion", "xManagedServiceIdentityId". If this is an inaccuracy in the documentation, please report it to the Bicep Team. [https://aka.ms/bicep-type-issues]
// C:\Users\v-richardsi\source\repos\Architecture\Sbox360\Design\Verification\ServiceBusSimpleSendReceive\infrastructure\assignRbacRoleToFunctionAppForKVAccess.bicep(23,5) : Warning BCP073: The property "scope" is read-only. Expressions cannot be assigned to read-only properties. If this is an inaccuracy in the documentation, please report it to the Bicep Team. [https://aka.ms/bicep-type-issues]
// C:\Users\v-richardsi\source\repos\Architecture\Sbox360\Design\Verification\ServiceBusSimpleSendReceive\infrastructure\assignRbacRoleToFunctionAppForStorageAccount.bicep(21,5) : Warning BCP073: The property "scope" is read-only. Expressions cannot be assigned to read-only properties. If this is an inaccuracy in the documentation, please report it to the Bicep Team. [https://aka.ms/bicep-type-issues]

// ERROR: {
//   "status": "Failed",
//   "error": {
//     "code": "DeploymentFailed",
//     "target": "/subscriptions/13c9725f-d20a-4c99-8ef4-d7bb78f98cff/resourceGroups/rg_SBusSndRcv_v-richardsi/providers/Microsoft.Resources/deployments/SBusSndRcv_v-richardsi",
//     "message": "At least one resource deployment operation failed. Please list deployment operations for details. Please see https://aka.ms/arm-deployment-operations for usage details.",
//     "details": [
//       {
//         "code": "BadRequest",
//         "target": "/subscriptions/13c9725f-d20a-4c99-8ef4-d7bb78f98cff/resourceGroups/rg_SBusSndRcv_v-richardsi/providers/Microsoft.Web/sites/xizdf-webapp",
//         "message": {
//                       "Code": "BadRequest",
//                       "Message": "The parameter properties has an invalid value.",
//                       "Target": null,
//                       "Details": [
//                         {
//                           "Message": "The parameter properties has an invalid value."
//                         },
//                         {
//                           "Code": "BadRequest"
//                         },
//                         {
//                           "ErrorEntity": {
//                             "ExtendedCode": "51008",
//                             "MessageTemplate": "The parameter {0} has an invalid value.",
//                             "Parameters": [
//                               "properties"
//                             ],
//                             "Code": "BadRequest",
//                             "Message": "The parameter properties has an invalid value."
//                           }
//                         }
//                       ],
//                       "Innererror": null
//                     }
//       }
//     ]
//   }
// }

// end deploy 07/11/2024 15:59:29
// resource group = rg_SBusSndRcv_v-richardsi
// Name                                                              Flavor       ResourceType                                           Region
// ----------------------------------------------------------------  -----------  -----------------------------------------------------  --------
// xizdf-plan-func                                                   functionapp  Microsoft.Web/serverFarms                              eastus2
// xizdf-func                                                        functionapp  Microsoft.Web/sites                                    eastus2
// xizdf-appins                                                      web          Microsoft.Insights/components                          eastus2
// xizdf-servicebus                                                               Microsoft.ServiceBus/namespaces                        eastus2
// xizdffuncstg                                                      StorageV2    Microsoft.Storage/storageAccounts                      eastus2
// xizdf-plan-web                                                    app          Microsoft.Web/serverFarms                              eastus2
// xizdf-detector                                                                 Microsoft.Insights/actiongroups                        global
// xizdf-failure anomalies                                                        microsoft.alertsManagement/smartDetectorAlertRules     global
// xizdf-webapp                                                      app          Microsoft.Web/sites                                    eastus2
// aztblogsv12u2gzyv3w2zong                                          StorageV2    microsoft.storage/storageAccounts                      eastus2
// xizdf-vnet                                                                     Microsoft.Network/virtualNetworks                      eastus2
// privatelink.azurewebsites.net                                                  Microsoft.Network/privateDnsZones                      global
// xizdf-pep-funcapp                                                              Microsoft.Network/privateEndpoints                     eastus2
// xizdf-pep-funcapp.nic.8af606ab-ccf2-4fc6-a810-3a5e27daedc9                     Microsoft.Network/networkInterfaces                    eastus2
// privatelink.azurewebsites.net/privatelink.azurewebsites.net-link               Microsoft.Network/privateDnsZones/virtualNetworkLinks  global
// all done 07/11/2024 15:59:32 elapse time = 00:01:53 

// Process compilation finished


// Set-AzResourceGroup: 
// Line |
//   38 |  Set-AzResourceGroup -Name $env:rg -Tag $tags
//      |  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//      | Operation returned an invalid status code 'Forbidden'
// StatusCode: 403
// ReasonPhrase: Forbidden
// OperationID : aa660b3b-802d-40bf-9ce6-ac10f472ca3b
// start build for resource group = rg_SBusSndRcv_v-richardsi at 07/11/2024 09:27:14
// Phase 1 deployment: Create Service Bus queue (tier=Standard), Function App (tier=P1V2) WebApp=True, Storage Accounts and VNet=False and no PEP
// az group create --name rg_SBusSndRcv_v-richardsi --location eastus2
// {
//   "id": "/subscriptions/13c9725f-d20a-4c99-8ef4-d7bb78f98cff/resourceGroups/rg_SBusSndRcv_v-richardsi",
//   "location": "eastus2",
//   "managedBy": null,
//   "name": "rg_SBusSndRcv_v-richardsi",
//   "properties": {
//     "provisioningState": "Succeeded"
//   },
//   "tags": {
//     "ringValue": "r0"
//   },
//   "type": "Microsoft.Resources/resourceGroups"
// }
// WARNING: C:\Users\v-richardsi\source\repos\Architecture\Sbox360\Design\Verification\ServiceBusSimpleSendReceive\infrastructure\assignRbacRoleToFunctionAppForStorageAccount.bicep(21,5) : Warning BCP073: The property "scope" is read-only. Expressions cannot be assigned to read-only properties. If this is an inaccuracy in the documentation, please report it to the Bicep Team. [https://aka.ms/bicep-type-issues]
// C:\Users\v-richardsi\source\repos\Architecture\Sbox360\Design\Verification\ServiceBusSimpleSendReceive\infrastructure\deploy-ServiceBusSimpleSendReceive.bicep(374,7) : Warning no-unused-params: Parameter "webAppSku" is declared but never used. [https://aka.ms/bicep/linter/no-unused-params]
// C:\Users\v-richardsi\source\repos\Architecture\Sbox360\Design\Verification\ServiceBusSimpleSendReceive\infrastructure\deploy-ServiceBusSimpleSendReceive.bicep(579,10) : Warning no-unused-existing-resources: Existing resource "serviceBus_existing" is declared but never used. [https://aka.ms/bicep/linter/no-unused-existing-resources]
// C:\Users\v-richardsi\source\repos\Architecture\Sbox360\Design\Verification\ServiceBusSimpleSendReceive\infrastructure\deploy-ServiceBusSimpleSendReceive.bicep(695,10) : Warning no-unused-existing-resources: Existing resource "storageAccountForFuncApp_existing" is declared but never used. [https://aka.ms/bicep/linter/no-unused-existing-resources]
// C:\Users\v-richardsi\source\repos\Architecture\Sbox360\Design\Verification\ServiceBusSimpleSendReceive\infrastructure\deploy-ServiceBusSimpleSendReceive.bicep(732,10) : Warning no-unused-existing-resources: Existing resource "functionPlan_existing" is declared but never used. [https://aka.ms/bicep/linter/no-unused-existing-resources]
// C:\Users\v-richardsi\source\repos\Architecture\Sbox360\Design\Verification\ServiceBusSimpleSendReceive\infrastructure\deploy-ServiceBusSimpleSendReceive.bicep(1120,10) : Warning no-unused-existing-resources: Existing resource "kvaadb2cSecret_existing" is declared but never used. [https://aka.ms/bicep/linter/no-unused-existing-resources]
// C:\Users\v-richardsi\source\repos\Architecture\Sbox360\Design\Verification\ServiceBusSimpleSendReceive\infrastructure\deploy-ServiceBusSimpleSendReceive.bicep(1382,7) : Warning no-unused-params: Parameter "webapp_dns_name" is declared but never used. [https://aka.ms/bicep/linter/no-unused-params]
// C:\Users\v-richardsi\source\repos\Architecture\Sbox360\Design\Verification\ServiceBusSimpleSendReceive\infrastructure\deploy-ServiceBusSimpleSendReceive.bicep(1526,10) : Warning no-unused-existing-resources: Existing resource "hostingPlan_existing" is declared but never used. [https://aka.ms/bicep/linter/no-unused-existing-resources]
// C:\Users\v-richardsi\source\repos\Architecture\Sbox360\Design\Verification\ServiceBusSimpleSendReceive\infrastructure\deploy-ServiceBusSimpleSendReceive.bicep(1538,7) : Warning BCP037: The property "metadata" is not allowed on objects of type "SiteConfig". Permissible properties include "acrUseManagedIdentityCreds", "acrUserManagedIdentityID", "alwaysOn", "apiDefinition", "apiManagementConfig", "appCommandLine", "autoHealEnabled", "autoHealRules", "autoSwapSlotName", "azureStorageAccounts", "connectionStrings", "cors", "defaultDocuments", "detailedErrorLoggingEnabled", "documentRoot", "experiments", "ftpsState", "functionAppScaleLimit", "functionsRuntimeScaleMonitoringEnabled", "handlerMappings", "healthCheckPath", "http20Enabled", "httpLoggingEnabled", "ipSecurityRestrictions", "javaContainer", "javaContainerVersion", "javaVersion", "keyVaultReferenceIdentity", "limits", "linuxFxVersion", "loadBalancing", "localMySqlEnabled", "logsDirectorySizeLimit", "managedPipelineMode", "managedServiceIdentityId", "minimumElasticInstanceCount", "minTlsVersion", "nodeVersion", "numberOfWorkers", "phpVersion", "powerShellVersion", "preWarmedInstanceCount", "publicNetworkAccess", "publishingUsername", "push", "pythonVersion", "remoteDebuggingEnabled", "remoteDebuggingVersion", "requestTracingEnabled", "requestTracingExpirationTime", "scmIpSecurityRestrictions", "scmIpSecurityRestrictionsUseMain", "scmMinTlsVersion", "scmType", "tracingOptions", "use32BitWorkerProcess", "virtualApplications", "vnetName", "vnetPrivatePortsCount", "vnetRouteAllEnabled", "websiteTimeZone", "windowsFxVersion", "xManagedServiceIdentityId". If this is an inaccuracy in the documentation, please report it to the Bicep Team. [https://aka.ms/bicep-type-issues]
// C:\Users\v-richardsi\source\repos\Architecture\Sbox360\Design\Verification\ServiceBusSimpleSendReceive\infrastructure\assignRbacRoleToFunctionApp.bicep(21,5) : Warning BCP073: The property "scope" is read-only. Expressions cannot be assigned to read-only properties. If this is an inaccuracy in the documentation, please report it to the Bicep Team. [https://aka.ms/bicep-type-issues]
// C:\Users\v-richardsi\source\repos\Architecture\Sbox360\Design\Verification\ServiceBusSimpleSendReceive\infrastructure\assignRbacRoleToFunctionAppForKVAccess.bicep(23,5) : Warning BCP073: The property "scope" is read-only. Expressions cannot be assigned to read-only properties. If this is an inaccuracy in the documentation, please report it to the Bicep Team. [https://aka.ms/bicep-type-issues]

// ERROR: {"status":"Failed","error":{"code":"DeploymentFailed","target":"/subscriptions/13c9725f-d20a-4c99-8ef4-d7bb78f98cff/resourceGroups/rg_SBusSndRcv_v-richardsi/providers/Microsoft.Resources/deployments/SBusSndRcv_v-richardsi","message":"At least one resource deployment operation failed. Please list deployment operations for details. Please see https://aka.ms/arm-deployment-operations for usage details.","details":[{"code":"ResourceDeploymentFailure","target":"/subscriptions/13c9725f-d20a-4c99-8ef4-d7bb78f98cff/resourceGroups/rg_SBusSndRcv_v-richardsi/providers/Microsoft.ServiceBus/namespaces/xizdf-servicebus","message":"The resource write operation failed to complete successfully, because it reached terminal provisioning state 'Failed'."}]}}
// end deploy 07/11/2024 09:28:41
// resource group = rg_SBusSndRcv_v-richardsi
// Name                     ResourceType                                        Region    Flavor
// -----------------------  --------------------------------------------------  --------  -----------
// xizdf-servicebus         Microsoft.ServiceBus/namespaces                     eastus2
// xizdffuncstg             Microsoft.Storage/storageAccounts                   eastus2   StorageV2
// xizdf-plan-func          Microsoft.Web/serverFarms                           eastus2   functionapp
// xizdf-appins             Microsoft.Insights/components                       eastus2   web
// xizdf-plan-web           Microsoft.Web/serverFarms                           eastus2   app
// xizdf-detector           Microsoft.Insights/actiongroups                     global
// xizdf-failure anomalies  microsoft.alertsManagement/smartDetectorAlertRules  global
// all done 07/11/2024 09:28:44 elapse time = 00:01:30 

// Process compilation finished


// start build for resource group = rg_SBusSndRcv_v-richardsi at 07/11/2024 09:14:07
// Step 3: begin shutdown delete resource group rg_SBusSndRcv_v-richardsi 07/11/2024 09:14:07
// az group delete -n rg_SBusSndRcv_v-richardsi
// shutdown is complete rg_SBusSndRcv_v-richardsi 07/11/2024 09:15:29
// One time initializations: Create resource group and service principal for github workflow
// az group create -l eastus2 -n rg_SBusSndRcv_v-richardsi
// {
//   "id": "/subscriptions/13c9725f-d20a-4c99-8ef4-d7bb78f98cff/resourceGroups/rg_SBusSndRcv_v-richardsi",
//   "location": "eastus2",
//   "managedBy": null,
//   "name": "rg_SBusSndRcv_v-richardsi",
//   "properties": {
//     "provisioningState": "Succeeded"
//   },
//   "tags": {
//     "ringValue": "r0"
//   },
//   "type": "Microsoft.Resources/resourceGroups"
// }
// id=/subscriptions/13c9725f-d20a-4c99-8ef4-d7bb78f98cff/resourceGroups/rg_SBusSndRcv_v-richardsi
// Phase 1 deployment: Create Service Bus queue (tier=Standard), Function App (tier=P1V2) WebApp=True, Storage Accounts and VNet=False and no PEP
// WARNING: C:\Users\v-richardsi\source\repos\Architecture\Sbox360\Design\Verification\ServiceBusSimpleSendReceive\infrastructure\assignRbacRoleToFunctionAppForStorageAccount.bicep(21,5) : Warning BCP073: The property "scope" is read-only. Expressions cannot be assigned to read-only properties. If this is an inaccuracy in the documentation, please report it to the Bicep Team. [https://aka.ms/bicep-type-issues]
// C:\Users\v-richardsi\source\repos\Architecture\Sbox360\Design\Verification\ServiceBusSimpleSendReceive\infrastructure\assignRbacRoleToFunctionApp.bicep(21,5) : Warning BCP073: The property "scope" is read-only. Expressions cannot be assigned to read-only properties. If this is an inaccuracy in the documentation, please report it to the Bicep Team. [https://aka.ms/bicep-type-issues]
// C:\Users\v-richardsi\source\repos\Architecture\Sbox360\Design\Verification\ServiceBusSimpleSendReceive\infrastructure\assignRbacRoleToFunctionAppForKVAccess.bicep(23,5) : Warning BCP073: The property "scope" is read-only. Expressions cannot be assigned to read-only properties. If this is an inaccuracy in the documentation, please report it to the Bicep Team. [https://aka.ms/bicep-type-issues]
// C:\Users\v-richardsi\source\repos\Architecture\Sbox360\Design\Verification\ServiceBusSimpleSendReceive\infrastructure\deploy-ServiceBusSimpleSendReceive.bicep(361,7) : Warning no-unused-params: Parameter "webAppSku" is declared but never used. [https://aka.ms/bicep/linter/no-unused-params]
// C:\Users\v-richardsi\source\repos\Architecture\Sbox360\Design\Verification\ServiceBusSimpleSendReceive\infrastructure\deploy-ServiceBusSimpleSendReceive.bicep(566,10) : Warning no-unused-existing-resources: Existing resource "serviceBus_existing" is declared but never used. [https://aka.ms/bicep/linter/no-unused-existing-resources]
// C:\Users\v-richardsi\source\repos\Architecture\Sbox360\Design\Verification\ServiceBusSimpleSendReceive\infrastructure\deploy-ServiceBusSimpleSendReceive.bicep(682,10) : Warning no-unused-existing-resources: Existing resource "storageAccountForFuncApp_existing" is declared but never used. [https://aka.ms/bicep/linter/no-unused-existing-resources]
// C:\Users\v-richardsi\source\repos\Architecture\Sbox360\Design\Verification\ServiceBusSimpleSendReceive\infrastructure\deploy-ServiceBusSimpleSendReceive.bicep(719,10) : Warning no-unused-existing-resources: Existing resource "functionPlan_existing" is declared but never used. [https://aka.ms/bicep/linter/no-unused-existing-resources]
// C:\Users\v-richardsi\source\repos\Architecture\Sbox360\Design\Verification\ServiceBusSimpleSendReceive\infrastructure\deploy-ServiceBusSimpleSendReceive.bicep(1107,10) : Warning no-unused-existing-resources: Existing resource "kvaadb2cSecret_existing" is declared but never used. [https://aka.ms/bicep/linter/no-unused-existing-resources]
// C:\Users\v-richardsi\source\repos\Architecture\Sbox360\Design\Verification\ServiceBusSimpleSendReceive\infrastructure\deploy-ServiceBusSimpleSendReceive.bicep(1369,7) : Warning no-unused-params: Parameter "webapp_dns_name" is declared but never used. [https://aka.ms/bicep/linter/no-unused-params]
// C:\Users\v-richardsi\source\repos\Architecture\Sbox360\Design\Verification\ServiceBusSimpleSendReceive\infrastructure\deploy-ServiceBusSimpleSendReceive.bicep(1513,10) : Warning no-unused-existing-resources: Existing resource "hostingPlan_existing" is declared but never used. [https://aka.ms/bicep/linter/no-unused-existing-resources]
// C:\Users\v-richardsi\source\repos\Architecture\Sbox360\Design\Verification\ServiceBusSimpleSendReceive\infrastructure\deploy-ServiceBusSimpleSendReceive.bicep(1525,7) : Warning BCP037: The property "metadata" is not allowed on objects of type "SiteConfig". Permissible properties include "acrUseManagedIdentityCreds", "acrUserManagedIdentityID", "alwaysOn", "apiDefinition", "apiManagementConfig", "appCommandLine", "autoHealEnabled", "autoHealRules", "autoSwapSlotName", "azureStorageAccounts", "connectionStrings", "cors", "defaultDocuments", "detailedErrorLoggingEnabled", "documentRoot", "experiments", "ftpsState", "functionAppScaleLimit", "functionsRuntimeScaleMonitoringEnabled", "handlerMappings", "healthCheckPath", "http20Enabled", "httpLoggingEnabled", "ipSecurityRestrictions", "javaContainer", "javaContainerVersion", "javaVersion", "keyVaultReferenceIdentity", "limits", "linuxFxVersion", "loadBalancing", "localMySqlEnabled", "logsDirectorySizeLimit", "managedPipelineMode", "managedServiceIdentityId", "minimumElasticInstanceCount", "minTlsVersion", "nodeVersion", "numberOfWorkers", "phpVersion", "powerShellVersion", "preWarmedInstanceCount", "publicNetworkAccess", "publishingUsername", "push", "pythonVersion", "remoteDebuggingEnabled", "remoteDebuggingVersion", "requestTracingEnabled", "requestTracingExpirationTime", "scmIpSecurityRestrictions", "scmIpSecurityRestrictionsUseMain", "scmMinTlsVersion", "scmType", "tracingOptions", "use32BitWorkerProcess", "virtualApplications", "vnetName", "vnetPrivatePortsCount", "vnetRouteAllEnabled", "websiteTimeZone", "windowsFxVersion", "xManagedServiceIdentityId". If this is an inaccuracy in the documentation, please report it to the Bicep Team. [https://aka.ms/bicep-type-issues]

// ERROR: {"status":"Failed","error":{"code":"DeploymentFailed","target":"/subscriptions/13c9725f-d20a-4c99-8ef4-d7bb78f98cff/resourceGroups/rg_SBusSndRcv_v-richardsi/providers/Microsoft.Resources/deployments/SBusSndRcv_v-richardsi","message":"At least one resource deployment operation failed. Please list deployment operations for details. Please see https://aka.ms/arm-deployment-operations for usage details.","details":[{"code":"ResourceDeploymentFailure","target":"/subscriptions/13c9725f-d20a-4c99-8ef4-d7bb78f98cff/resourceGroups/rg_SBusSndRcv_v-richardsi/providers/Microsoft.ServiceBus/namespaces/xizdf-servicebus","message":"The resource write operation failed to complete successfully, because it reached terminal provisioning state 'Failed'."}]}}
// end deploy 07/11/2024 09:16:53
// resource group = rg_SBusSndRcv_v-richardsi
// Name                     ResourceType                                        Region    Flavor
// -----------------------  --------------------------------------------------  --------  -----------
// xizdf-servicebus         Microsoft.ServiceBus/namespaces                     eastus2
// xizdffuncstg             Microsoft.Storage/storageAccounts                   eastus2   StorageV2
// xizdf-plan-func          Microsoft.Web/serverFarms                           eastus2   functionapp
// xizdf-appins             Microsoft.Insights/components                       eastus2   web
// xizdf-plan-web           Microsoft.Web/serverFarms                           eastus2   app
// xizdf-detector           Microsoft.Insights/actiongroups                     global
// xizdf-failure anomalies  microsoft.alertsManagement/smartDetectorAlertRules  global
// all done 07/11/2024 09:16:56 elapse time = 00:02:49 

// Process compilation finished



// start build for resource group = rg_SBusSndRcv_v-richardsi at 07/10/2024 21:40:08
// Step 3: begin shutdown delete resource group rg_SBusSndRcv_v-richardsi 07/10/2024 21:40:08
// az group delete -n rg_SBusSndRcv_v-richardsi
// shutdown is complete rg_SBusSndRcv_v-richardsi 07/10/2024 21:43:18
// One time initializations: Create resource group and service principal for github workflow
// az group create -l eastus2 -n rg_SBusSndRcv_v-richardsi
// {
//   "id": "/subscriptions/13c9725f-d20a-4c99-8ef4-d7bb78f98cff/resourceGroups/rg_SBusSndRcv_v-richardsi",
//   "location": "eastus2",
//   "managedBy": null,
//   "name": "rg_SBusSndRcv_v-richardsi",
//   "properties": {
//     "provisioningState": "Succeeded"
//   },
//   "tags": {
//     "ringValue": "r0"
//   },
//   "type": "Microsoft.Resources/resourceGroups"
// }
// id=/subscriptions/13c9725f-d20a-4c99-8ef4-d7bb78f98cff/resourceGroups/rg_SBusSndRcv_v-richardsi
// Phase 1 deployment: Create Service Bus queue (tier=Standard), Function App (tier=P1V2) WebApp=True, Storage Accounts and VNet=False and no PEP
// WARNING: C:\Users\v-richardsi\source\repos\Architecture\Sbox360\Design\Verification\ServiceBusSimpleSendReceive\infrastructure\assignRbacRoleToFunctionAppForKVAccess.bicep(23,5) : Warning BCP073: The property "scope" is read-only. Expressions cannot be assigned to read-only properties. If this is an inaccuracy in the documentation, please report it to the Bicep Team. [https://aka.ms/bicep-type-issues]
// C:\Users\v-richardsi\source\repos\Architecture\Sbox360\Design\Verification\ServiceBusSimpleSendReceive\infrastructure\assignRbacRoleToFunctionApp.bicep(21,5) : Warning BCP073: The property "scope" is read-only. Expressions cannot be assigned to read-only properties. If this is an inaccuracy in the documentation, please report it to the Bicep Team. [https://aka.ms/bicep-type-issues]
// C:\Users\v-richardsi\source\repos\Architecture\Sbox360\Design\Verification\ServiceBusSimpleSendReceive\infrastructure\assignRbacRoleToFunctionAppForStorageAccount.bicep(21,5) : Warning BCP073: The property "scope" is read-only. Expressions cannot be assigned to read-only properties. If this is an inaccuracy in the documentation, please report it to the Bicep Team. [https://aka.ms/bicep-type-issues]
// C:\Users\v-richardsi\source\repos\Architecture\Sbox360\Design\Verification\ServiceBusSimpleSendReceive\infrastructure\deploy-ServiceBusSimpleSendReceive.bicep(560,10) : Warning no-unused-existing-resources: Existing resource "serviceBus_existing" is declared but never used. [https://aka.ms/bicep/linter/no-unused-existing-resources]
// C:\Users\v-richardsi\source\repos\Architecture\Sbox360\Design\Verification\ServiceBusSimpleSendReceive\infrastructure\deploy-ServiceBusSimpleSendReceive.bicep(676,10) : Warning no-unused-existing-resources: Existing resource "storageAccountForFuncApp_existing" is declared but never used. [https://aka.ms/bicep/linter/no-unused-existing-resources]
// C:\Users\v-richardsi\source\repos\Architecture\Sbox360\Design\Verification\ServiceBusSimpleSendReceive\infrastructure\deploy-ServiceBusSimpleSendReceive.bicep(713,10) : Warning no-unused-existing-resources: Existing resource "functionPlan_existing" is declared but never used. [https://aka.ms/bicep/linter/no-unused-existing-resources]
// C:\Users\v-richardsi\source\repos\Architecture\Sbox360\Design\Verification\ServiceBusSimpleSendReceive\infrastructure\deploy-ServiceBusSimpleSendReceive.bicep(1101,10) : Warning no-unused-existing-resources: Existing resource "kvaadb2cSecret_existing" is declared but never used. [https://aka.ms/bicep/linter/no-unused-existing-resources]
// C:\Users\v-richardsi\source\repos\Architecture\Sbox360\Design\Verification\ServiceBusSimpleSendReceive\infrastructure\deploy-ServiceBusSimpleSendReceive.bicep(1363,7) : Warning no-unused-params: Parameter "webapp_dns_name" is declared but never used. [https://aka.ms/bicep/linter/no-unused-params]
// C:\Users\v-richardsi\source\repos\Architecture\Sbox360\Design\Verification\ServiceBusSimpleSendReceive\infrastructure\deploy-ServiceBusSimpleSendReceive.bicep(1499,5) : Warning BCP037: The property "name" is not allowed on objects of type "AppServicePlanProperties". Permissible properties include "freeOfferExpirationTime", "hostingEnvironmentProfile", "hyperV", "isSpot", "isXenon", "kubeEnvironmentProfile", "maximumElasticWorkerCount", "perSiteScaling", "reserved", "spotExpirationTime", "targetWorkerCount", "targetWorkerSizeId", "workerTierName". If this is an inaccuracy in the documentation, please report it to the Bicep Team. [https://aka.ms/bicep-type-issues]
// C:\Users\v-richardsi\source\repos\Architecture\Sbox360\Design\Verification\ServiceBusSimpleSendReceive\infrastructure\deploy-ServiceBusSimpleSendReceive.bicep(1503,10) : Warning no-unused-existing-resources: Existing resource "hostingPlan_existing" is declared but never used. [https://aka.ms/bicep/linter/no-unused-existing-resources]
// C:\Users\v-richardsi\source\repos\Architecture\Sbox360\Design\Verification\ServiceBusSimpleSendReceive\infrastructure\deploy-ServiceBusSimpleSendReceive.bicep(1515,7) : Warning BCP037: The property "metadata" is not allowed on objects of type "SiteConfig". Permissible properties include "acrUseManagedIdentityCreds", "acrUserManagedIdentityID", "alwaysOn", "apiDefinition", "apiManagementConfig", "appCommandLine", "autoHealEnabled", "autoHealRules", "autoSwapSlotName", "azureStorageAccounts", "connectionStrings", "cors", "defaultDocuments", "detailedErrorLoggingEnabled", "documentRoot", "experiments", "ftpsState", "functionAppScaleLimit", "functionsRuntimeScaleMonitoringEnabled", "handlerMappings", "healthCheckPath", "http20Enabled", "httpLoggingEnabled", "ipSecurityRestrictions", "javaContainer", "javaContainerVersion", "javaVersion", "keyVaultReferenceIdentity", "limits", "linuxFxVersion", "loadBalancing", "localMySqlEnabled", "logsDirectorySizeLimit", "managedPipelineMode", "managedServiceIdentityId", "minimumElasticInstanceCount", "minTlsVersion", "nodeVersion", "numberOfWorkers", "phpVersion", "powerShellVersion", "preWarmedInstanceCount", "publicNetworkAccess", "publishingUsername", "push", "pythonVersion", "remoteDebuggingEnabled", "remoteDebuggingVersion", "requestTracingEnabled", "requestTracingExpirationTime", "scmIpSecurityRestrictions", "scmIpSecurityRestrictionsUseMain", "scmMinTlsVersion", "scmType", "tracingOptions", "use32BitWorkerProcess", "virtualApplications", "vnetName", "vnetPrivatePortsCount", "vnetRouteAllEnabled", "websiteTimeZone", "windowsFxVersion", "xManagedServiceIdentityId". If this is an inaccuracy in the documentation, please report it to the Bicep Team. [https://aka.ms/bicep-type-issues]

// ERROR: {"status":"Failed","error":{"code":"DeploymentFailed","target":"/subscriptions/13c9725f-d20a-4c99-8ef4-d7bb78f98cff/resourceGroups/rg_SBusSndRcv_v-richardsi/providers/Microsoft.Resources/deployments/SBusSndRcv_v-richardsi","message":"At least one resource deployment operation failed. Please list deployment operations for details. Please see https://aka.ms/arm-deployment-operations for usage details.","details":[{"code":"ResourceDeploymentFailure","target":"/subscriptions/13c9725f-d20a-4c99-8ef4-d7bb78f98cff/resourceGroups/rg_SBusSndRcv_v-richardsi/providers/Microsoft.ServiceBus/namespaces/xizdf-servicebus","message":"The resource write operation failed to complete successfully, because it reached terminal provisioning state 'Failed'."}]}}
// end deploy 07/10/2024 21:44:41
// resource group = rg_SBusSndRcv_v-richardsi
// Name                     ResourceType                                        Region    Flavor
// -----------------------  --------------------------------------------------  --------  -----------
// xizdf-servicebus         Microsoft.ServiceBus/namespaces                     eastus2
// xizdffuncstg             Microsoft.Storage/storageAccounts                   eastus2   StorageV2
// xizdf-plan-func          Microsoft.Web/serverFarms                           eastus2   functionapp
// xizdf-appins             Microsoft.Insights/components                       eastus2   web
// xizdf-plan-web           Microsoft.Web/serverFarms                           eastus2   app
// xizdf-detector           Microsoft.Insights/actiongroups                     global
// xizdf-failure anomalies  microsoft.alertsManagement/smartDetectorAlertRules  global
// all done 07/10/2024 21:44:44 elapse time = 00:04:35 

// Process compilation finished



// start build for resource group = rg_SBusSndRcv_v-richardsi at 07/10/2024 20:52:00
// One time initializations: Create resource group and service principal for github workflow
// az group create -l eastus2 -n rg_SBusSndRcv_v-richardsi
// {
//   "id": "/subscriptions/13c9725f-d20a-4c99-8ef4-d7bb78f98cff/resourceGroups/rg_SBusSndRcv_v-richardsi",
//   "location": "eastus2",
//   "managedBy": null,
//   "name": "rg_SBusSndRcv_v-richardsi",
//   "properties": {
//     "provisioningState": "Succeeded"
//   },
//   "tags": {
//     "ringValue": "r0"
//   },
//   "type": "Microsoft.Resources/resourceGroups"
// }
// id=/subscriptions/13c9725f-d20a-4c99-8ef4-d7bb78f98cff/resourceGroups/rg_SBusSndRcv_v-richardsi
// Phase 1 deployment: Create Service Bus queue (tier=Standard), Function App (tier=P1V2) WebApp=True, Storage Accounts and VNet=False and no PEP
// WARNING: C:\Users\v-richardsi\source\repos\Architecture\Sbox360\Design\Verification\ServiceBusSimpleSendReceive\infrastructure\assignRbacRoleToFunctionAppForKVAccess.bicep(23,5) : Warning BCP073: The property "scope" is read-only. Expressions cannot be assigned to read-only properties. If this is an inaccuracy in the documentation, please report it to the Bicep Team. [https://aka.ms/bicep-type-issues]
// C:\Users\v-richardsi\source\repos\Architecture\Sbox360\Design\Verification\ServiceBusSimpleSendReceive\infrastructure\assignRbacRoleToFunctionAppForStorageAccount.bicep(21,5) : Warning BCP073: The property "scope" is read-only. Expressions cannot be assigned to read-only properties. If this is an inaccuracy in the documentation, please report it to the Bicep Team. [https://aka.ms/bicep-type-issues]
// C:\Users\v-richardsi\source\repos\Architecture\Sbox360\Design\Verification\ServiceBusSimpleSendReceive\infrastructure\deploy-ServiceBusSimpleSendReceive.bicep(560,10) : Warning no-unused-existing-resources: Existing resource "serviceBus_existing" is declared but never used. [https://aka.ms/bicep/linter/no-unused-existing-resources]
// C:\Users\v-richardsi\source\repos\Architecture\Sbox360\Design\Verification\ServiceBusSimpleSendReceive\infrastructure\deploy-ServiceBusSimpleSendReceive.bicep(676,10) : Warning no-unused-existing-resources: Existing resource "storageAccountForFuncApp_existing" is declared but never used. [https://aka.ms/bicep/linter/no-unused-existing-resources]
// C:\Users\v-richardsi\source\repos\Architecture\Sbox360\Design\Verification\ServiceBusSimpleSendReceive\infrastructure\deploy-ServiceBusSimpleSendReceive.bicep(713,10) : Warning no-unused-existing-resources: Existing resource "functionPlan_existing" is declared but never used. [https://aka.ms/bicep/linter/no-unused-existing-resources]
// C:\Users\v-richardsi\source\repos\Architecture\Sbox360\Design\Verification\ServiceBusSimpleSendReceive\infrastructure\deploy-ServiceBusSimpleSendReceive.bicep(1101,10) : Warning no-unused-existing-resources: Existing resource "kvaadb2cSecret_existing" is declared but never used. [https://aka.ms/bicep/linter/no-unused-existing-resources]
// C:\Users\v-richardsi\source\repos\Architecture\Sbox360\Design\Verification\ServiceBusSimpleSendReceive\infrastructure\deploy-ServiceBusSimpleSendReceive.bicep(1363,7) : Warning no-unused-params: Parameter "webapp_dns_name" is declared but never used. [https://aka.ms/bicep/linter/no-unused-params]
// C:\Users\v-richardsi\source\repos\Architecture\Sbox360\Design\Verification\ServiceBusSimpleSendReceive\infrastructure\deploy-ServiceBusSimpleSendReceive.bicep(1499,5) : Warning BCP037: The property "name" is not allowed on objects of type "AppServicePlanProperties". Permissible properties include "freeOfferExpirationTime", "hostingEnvironmentProfile", "hyperV", "isSpot", "isXenon", "kubeEnvironmentProfile", "maximumElasticWorkerCount", "perSiteScaling", "reserved", "spotExpirationTime", "targetWorkerCount", "targetWorkerSizeId", "workerTierName". If this is an inaccuracy in the documentation, please report it to the Bicep Team. [https://aka.ms/bicep-type-issues]
// C:\Users\v-richardsi\source\repos\Architecture\Sbox360\Design\Verification\ServiceBusSimpleSendReceive\infrastructure\deploy-ServiceBusSimpleSendReceive.bicep(1503,10) : Warning no-unused-existing-resources: Existing resource "hostingPlan_existing" is declared but never used. [https://aka.ms/bicep/linter/no-unused-existing-resources]
// C:\Users\v-richardsi\source\repos\Architecture\Sbox360\Design\Verification\ServiceBusSimpleSendReceive\infrastructure\deploy-ServiceBusSimpleSendReceive.bicep(1515,7) : Warning BCP037: The property "metadata" is not allowed on objects of type "SiteConfig". Permissible properties include "acrUseManagedIdentityCreds", "acrUserManagedIdentityID", "alwaysOn", "apiDefinition", "apiManagementConfig", "appCommandLine", "autoHealEnabled", "autoHealRules", "autoSwapSlotName", "azureStorageAccounts", "connectionStrings", "cors", "defaultDocuments", "detailedErrorLoggingEnabled", "documentRoot", "experiments", "ftpsState", "functionAppScaleLimit", "functionsRuntimeScaleMonitoringEnabled", "handlerMappings", "healthCheckPath", "http20Enabled", "httpLoggingEnabled", "ipSecurityRestrictions", "javaContainer", "javaContainerVersion", "javaVersion", "keyVaultReferenceIdentity", "limits", "linuxFxVersion", "loadBalancing", "localMySqlEnabled", "logsDirectorySizeLimit", "managedPipelineMode", "managedServiceIdentityId", "minimumElasticInstanceCount", "minTlsVersion", "nodeVersion", "numberOfWorkers", "phpVersion", "powerShellVersion", "preWarmedInstanceCount", "publicNetworkAccess", "publishingUsername", "push", "pythonVersion", "remoteDebuggingEnabled", "remoteDebuggingVersion", "requestTracingEnabled", "requestTracingExpirationTime", "scmIpSecurityRestrictions", "scmIpSecurityRestrictionsUseMain", "scmMinTlsVersion", "scmType", "tracingOptions", "use32BitWorkerProcess", "virtualApplications", "vnetName", "vnetPrivatePortsCount", "vnetRouteAllEnabled", "websiteTimeZone", "windowsFxVersion", "xManagedServiceIdentityId". If this is an inaccuracy in the documentation, please report it to the Bicep Team. [https://aka.ms/bicep-type-issues]
// C:\Users\v-richardsi\source\repos\Architecture\Sbox360\Design\Verification\ServiceBusSimpleSendReceive\infrastructure\assignRbacRoleToFunctionApp.bicep(21,5) : Warning BCP073: The property "scope" is read-only. Expressions cannot be assigned to read-only properties. If this is an inaccuracy in the documentation, please report it to the Bicep Team. [https://aka.ms/bicep-type-issues]

// ERROR: {"status":"Failed","error":{"code":"DeploymentFailed","target":"/subscriptions/13c9725f-d20a-4c99-8ef4-d7bb78f98cff/resourceGroups/rg_SBusSndRcv_v-richardsi/providers/Microsoft.Resources/deployments/SBusSndRcv_v-richardsi","message":"At least one resource deployment operation failed. Please list deployment operations for details. Please see https://aka.ms/arm-deployment-operations for usage details.","details":[{"code":"ResourceDeploymentFailure","target":"/subscriptions/13c9725f-d20a-4c99-8ef4-d7bb78f98cff/resourceGroups/rg_SBusSndRcv_v-richardsi/providers/Microsoft.ServiceBus/namespaces/xizdf-servicebus","message":"The resource write operation failed to complete successfully, because it reached terminal provisioning state 'Failed'."}]}}
// end deploy 07/10/2024 20:53:20
// resource group = rg_SBusSndRcv_v-richardsi
// Name                     ResourceType                                        Region    Flavor
// -----------------------  --------------------------------------------------  --------  -----------
// xizdf-servicebus         Microsoft.ServiceBus/namespaces                     eastus2
// xizdffuncstg             Microsoft.Storage/storageAccounts                   eastus2   StorageV2
// xizdf-plan-func          Microsoft.Web/serverFarms                           eastus2   functionapp
// xizdf-appins             Microsoft.Insights/components                       eastus2   web
// xizdf-plan-web           Microsoft.Web/serverFarms                           eastus2   app
// xizdf-detector           Microsoft.Insights/actiongroups                     global
// xizdf-failure anomalies  microsoft.alertsManagement/smartDetectorAlertRules  global
// all done 07/10/2024 20:53:22 elapse time = 00:01:22 

// Process compilation finished

// From portal deployment: Message The Resource 'Microsoft.Web/sites/xizdf-webapp' under resource group 'rg_SBusSndRcv_v-richardsi' was not found. For more details please go to https://aka.ms/ARMResourceNotFoundFix
//                         Message Site 'xizdf-webapp' with slot 'Production' not found.
//                         Message Cannot find WebSite with name xizdf-func.
//                         Message Cannot acquire exclusive lock to create, update or delete this site. Retry the request later.


// start build for resource group = rg_SBusSndRcv_v-richardsi at 07/10/2024 20:27:48
// One time initializations: Create resource group and service principal for github workflow
// az group create -l eastus2 -n rg_SBusSndRcv_v-richardsi
// {
//   "id": "/subscriptions/13c9725f-d20a-4c99-8ef4-d7bb78f98cff/resourceGroups/rg_SBusSndRcv_v-richardsi",
//   "location": "eastus2",
//   "managedBy": null,
//   "name": "rg_SBusSndRcv_v-richardsi",
//   "properties": {
//     "provisioningState": "Succeeded"
//   },
//   "tags": {
//     "ringValue": "r0"
//   },
//   "type": "Microsoft.Resources/resourceGroups"
// }
// id=/subscriptions/13c9725f-d20a-4c99-8ef4-d7bb78f98cff/resourceGroups/rg_SBusSndRcv_v-richardsi
// Phase 1 deployment: Create Service Bus queue (tier=Basic), Function App (tier=P1V2) WebApp=True, Storage Accounts and VNet=False and no PEP
// WARNING: C:\Users\v-richardsi\source\repos\Architecture\Sbox360\Design\Verification\ServiceBusSimpleSendReceive\infrastructure\assignRbacRoleToFunctionAppForStorageAccount.bicep(21,5) : Warning BCP073: The property "scope" is read-only. Expressions cannot be assigned to read-only properties. If this is an inaccuracy in the documentation, please report it to the Bicep Team. [https://aka.ms/bicep-type-issues]
// C:\Users\v-richardsi\source\repos\Architecture\Sbox360\Design\Verification\ServiceBusSimpleSendReceive\infrastructure\deploy-ServiceBusSimpleSendReceive.bicep(559,10) : Warning no-unused-existing-resources: Existing resource "serviceBus_existing" is declared but never used. [https://aka.ms/bicep/linter/no-unused-existing-resources]
// C:\Users\v-richardsi\source\repos\Architecture\Sbox360\Design\Verification\ServiceBusSimpleSendReceive\infrastructure\deploy-ServiceBusSimpleSendReceive.bicep(675,10) : Warning no-unused-existing-resources: Existing resource "storageAccountForFuncApp_existing" is declared but never used. [https://aka.ms/bicep/linter/no-unused-existing-resources]
// C:\Users\v-richardsi\source\repos\Architecture\Sbox360\Design\Verification\ServiceBusSimpleSendReceive\infrastructure\deploy-ServiceBusSimpleSendReceive.bicep(712,10) : Warning no-unused-existing-resources: Existing resource "functionPlan_existing" is declared but never used. [https://aka.ms/bicep/linter/no-unused-existing-resources]
// C:\Users\v-richardsi\source\repos\Architecture\Sbox360\Design\Verification\ServiceBusSimpleSendReceive\infrastructure\deploy-ServiceBusSimpleSendReceive.bicep(1100,10) : Warning no-unused-existing-resources: Existing resource "kvaadb2cSecret_existing" is declared but never used. [https://aka.ms/bicep/linter/no-unused-existing-resources]
// C:\Users\v-richardsi\source\repos\Architecture\Sbox360\Design\Verification\ServiceBusSimpleSendReceive\infrastructure\deploy-ServiceBusSimpleSendReceive.bicep(1362,7) : Warning no-unused-params: Parameter "webapp_dns_name" is declared but never used. [https://aka.ms/bicep/linter/no-unused-params]
// C:\Users\v-richardsi\source\repos\Architecture\Sbox360\Design\Verification\ServiceBusSimpleSendReceive\infrastructure\deploy-ServiceBusSimpleSendReceive.bicep(1498,5) : Warning BCP037: The property "name" is not allowed on objects of type "AppServicePlanProperties". Permissible properties include "freeOfferExpirationTime", "hostingEnvironmentProfile", "hyperV", "isSpot", "isXenon", "kubeEnvironmentProfile", "maximumElasticWorkerCount", "perSiteScaling", "reserved", "spotExpirationTime", "targetWorkerCount", "targetWorkerSizeId", "workerTierName". If this is an inaccuracy in the documentation, please report it to the Bicep Team. [https://aka.ms/bicep-type-issues]
// C:\Users\v-richardsi\source\repos\Architecture\Sbox360\Design\Verification\ServiceBusSimpleSendReceive\infrastructure\deploy-ServiceBusSimpleSendReceive.bicep(1502,10) : Warning no-unused-existing-resources: Existing resource "hostingPlan_existing" is declared but never used. [https://aka.ms/bicep/linter/no-unused-existing-resources]
// C:\Users\v-richardsi\source\repos\Architecture\Sbox360\Design\Verification\ServiceBusSimpleSendReceive\infrastructure\deploy-ServiceBusSimpleSendReceive.bicep(1514,7) : Warning BCP037: The property "metadata" is not allowed on objects of type "SiteConfig". Permissible properties include "acrUseManagedIdentityCreds", "acrUserManagedIdentityID", "alwaysOn", "apiDefinition", "apiManagementConfig", "appCommandLine", "autoHealEnabled", "autoHealRules", "autoSwapSlotName", "azureStorageAccounts", "connectionStrings", "cors", "defaultDocuments", "detailedErrorLoggingEnabled", "documentRoot", "experiments", "ftpsState", "functionAppScaleLimit", "functionsRuntimeScaleMonitoringEnabled", "handlerMappings", "healthCheckPath", "http20Enabled", "httpLoggingEnabled", "ipSecurityRestrictions", "javaContainer", "javaContainerVersion", "javaVersion", "keyVaultReferenceIdentity", "limits", "linuxFxVersion", "loadBalancing", "localMySqlEnabled", "logsDirectorySizeLimit", "managedPipelineMode", "managedServiceIdentityId", "minimumElasticInstanceCount", "minTlsVersion", "nodeVersion", "numberOfWorkers", "phpVersion", "powerShellVersion", "preWarmedInstanceCount", "publicNetworkAccess", "publishingUsername", "push", "pythonVersion", "remoteDebuggingEnabled", "remoteDebuggingVersion", "requestTracingEnabled", "requestTracingExpirationTime", "scmIpSecurityRestrictions", "scmIpSecurityRestrictionsUseMain", "scmMinTlsVersion", "scmType", "tracingOptions", "use32BitWorkerProcess", "virtualApplications", "vnetName", "vnetPrivatePortsCount", "vnetRouteAllEnabled", "websiteTimeZone", "windowsFxVersion", "xManagedServiceIdentityId". If this is an inaccuracy in the documentation, please report it to the Bicep Team. [https://aka.ms/bicep-type-issues]
// C:\Users\v-richardsi\source\repos\Architecture\Sbox360\Design\Verification\ServiceBusSimpleSendReceive\infrastructure\assignRbacRoleToFunctionApp.bicep(21,5) : Warning BCP073: The property "scope" is read-only. Expressions cannot be assigned to read-only properties. If this is an inaccuracy in the documentation, please report it to the Bicep Team. [https://aka.ms/bicep-type-issues]
// C:\Users\v-richardsi\source\repos\Architecture\Sbox360\Design\Verification\ServiceBusSimpleSendReceive\infrastructure\assignRbacRoleToFunctionAppForKVAccess.bicep(23,5) : Warning BCP073: The property "scope" is read-only. Expressions cannot be assigned to read-only properties. If this is an inaccuracy in the documentation, please report it to the Bicep Team. [https://aka.ms/bicep-type-issues]

// ERROR: {"status":"Failed","error":{"code":"DeploymentFailed","target":"/subscriptions/13c9725f-d20a-4c99-8ef4-d7bb78f98cff/resourceGroups/rg_SBusSndRcv_v-richardsi/providers/Microsoft.Resources/deployments/SBusSndRcv_v-richardsi","message":"At least one resource deployment operation failed. Please list deployment operations for details. Please see https://aka.ms/arm-deployment-operations for usage details.","details":[{"code":"MessagingGatewayBadRequest","message":"SubCode=40000. Bad Request. To know more visit https://aka.ms/sbResourceMgrExceptions. . TrackingId:563dcb76-ff57-4ff7-b856-ab51d6040a48_G12, SystemTracker:xizdf-servicebus.servicebus.windows.net:mainqueue001, Timestamp:2024-07-11T03:28:31"}]}}
// end deploy 07/10/2024 20:30:43
// resource group = rg_SBusSndRcv_v-richardsi
// Name                     ResourceType                                        Region    Flavor
// -----------------------  --------------------------------------------------  --------  -----------
// xizdf-servicebus         Microsoft.ServiceBus/namespaces                     eastus2
// xizdffuncstg             Microsoft.Storage/storageAccounts                   eastus2   StorageV2
// xizdf-plan-func          Microsoft.Web/serverFarms                           eastus2   functionapp
// xizdf-appins             Microsoft.Insights/components                       eastus2   web
// xizdf-plan-web           Microsoft.Web/serverFarms                           eastus2   app
// xizdf-detector           Microsoft.Insights/actiongroups                     global
// xizdf-failure anomalies  microsoft.alertsManagement/smartDetectorAlertRules  global
// xizdf-webapp             Microsoft.Web/sites                                 eastus2   app
// xizdf-func               Microsoft.Web/sites                                 eastus2   functionapp
// all done 07/10/2024 20:30:46 elapse time = 00:02:57 

// Process compilation finished
// From the portal deployments: SubCode=40000. Bad Request. To know more visit https://aka.ms/sbResourceMgrExceptions. . TrackingId:563dcb76-ff57-4ff7-b856-ab51d6040a48_G12, SystemTracker:xizdf-servicebus.servicebus.windows.net:mainqueue001, Timestamp:2024-07-11T03:28:31



// start build for resource group = rg_SBusSndRcv_v-richardsi at 07/10/2024 20:10:32
// Step 3: begin shutdown delete resource group rg_SBusSndRcv_v-richardsi 07/10/2024 20:10:32
// az group delete -n rg_SBusSndRcv_v-richardsi
// shutdown is complete rg_SBusSndRcv_v-richardsi 07/10/2024 20:12:40
// One time initializations: Create resource group and service principal for github workflow
// az group create -l eastus2 -n rg_SBusSndRcv_v-richardsi
// {
//   "id": "/subscriptions/13c9725f-d20a-4c99-8ef4-d7bb78f98cff/resourceGroups/rg_SBusSndRcv_v-richardsi",
//   "location": "eastus2",
//   "managedBy": null,
//   "name": "rg_SBusSndRcv_v-richardsi",
//   "properties": {
//     "provisioningState": "Succeeded"
//   },
//   "tags": {
//     "ringValue": "r0"
//   },
//   "type": "Microsoft.Resources/resourceGroups"
// }
// id=/subscriptions/13c9725f-d20a-4c99-8ef4-d7bb78f98cff/resourceGroups/rg_SBusSndRcv_v-richardsi
// Phase 1 deployment: Create Service Bus queue (tier=Basic), Function App (tier=P1V2) WebApp=True, Storage Accounts and VNet=False and no PEP
// WARNING: C:\Users\v-richardsi\source\repos\Architecture\Sbox360\Design\Verification\ServiceBusSimpleSendReceive\infrastructure\deploy-ServiceBusSimpleSendReceive.bicep(559,10) : Warning no-unused-existing-resources: Existing resource "serviceBus_existing" is declared but never used. [https://aka.ms/bicep/linter/no-unused-existing-resources]
// C:\Users\v-richardsi\source\repos\Architecture\Sbox360\Design\Verification\ServiceBusSimpleSendReceive\infrastructure\deploy-ServiceBusSimpleSendReceive.bicep(675,10) : Warning no-unused-existing-resources: Existing resource "storageAccountForFuncApp_existing" is declared but never used. [https://aka.ms/bicep/linter/no-unused-existing-resources]
// C:\Users\v-richardsi\source\repos\Architecture\Sbox360\Design\Verification\ServiceBusSimpleSendReceive\infrastructure\deploy-ServiceBusSimpleSendReceive.bicep(712,10) : Warning no-unused-existing-resources: Existing resource "functionPlan_existing" is declared but never used. [https://aka.ms/bicep/linter/no-unused-existing-resources]
// C:\Users\v-richardsi\source\repos\Architecture\Sbox360\Design\Verification\ServiceBusSimpleSendReceive\infrastructure\deploy-ServiceBusSimpleSendReceive.bicep(1100,10) : Warning no-unused-existing-resources: Existing resource "kvaadb2cSecret_existing" is declared but never used. [https://aka.ms/bicep/linter/no-unused-existing-resources]
// C:\Users\v-richardsi\source\repos\Architecture\Sbox360\Design\Verification\ServiceBusSimpleSendReceive\infrastructure\deploy-ServiceBusSimpleSendReceive.bicep(1362,7) : Warning no-unused-params: Parameter "webapp_dns_name" is declared but never used. [https://aka.ms/bicep/linter/no-unused-params]
// C:\Users\v-richardsi\source\repos\Architecture\Sbox360\Design\Verification\ServiceBusSimpleSendReceive\infrastructure\deploy-ServiceBusSimpleSendReceive.bicep(1498,5) : Warning BCP037: The property "name" is not allowed on objects of type "AppServicePlanProperties". Permissible properties include "freeOfferExpirationTime", "hostingEnvironmentProfile", "hyperV", "isSpot", "isXenon", "kubeEnvironmentProfile", "maximumElasticWorkerCount", "perSiteScaling", "reserved", "spotExpirationTime", "targetWorkerCount", "targetWorkerSizeId", "workerTierName". If this is an inaccuracy in the documentation, please report it to the Bicep Team. [https://aka.ms/bicep-type-issues]
// C:\Users\v-richardsi\source\repos\Architecture\Sbox360\Design\Verification\ServiceBusSimpleSendReceive\infrastructure\deploy-ServiceBusSimpleSendReceive.bicep(1502,10) : Warning no-unused-existing-resources: Existing resource "hostingPlan_existing" is declared but never used. [https://aka.ms/bicep/linter/no-unused-existing-resources]
// C:\Users\v-richardsi\source\repos\Architecture\Sbox360\Design\Verification\ServiceBusSimpleSendReceive\infrastructure\deploy-ServiceBusSimpleSendReceive.bicep(1514,7) : Warning BCP037: The property "metadata" is not allowed on objects of type "SiteConfig". Permissible properties include "acrUseManagedIdentityCreds", "acrUserManagedIdentityID", "alwaysOn", "apiDefinition", "apiManagementConfig", "appCommandLine", "autoHealEnabled", "autoHealRules", "autoSwapSlotName", "azureStorageAccounts", "connectionStrings", "cors", "defaultDocuments", "detailedErrorLoggingEnabled", "documentRoot", "experiments", "ftpsState", "functionAppScaleLimit", "functionsRuntimeScaleMonitoringEnabled", "handlerMappings", "healthCheckPath", "http20Enabled", "httpLoggingEnabled", "ipSecurityRestrictions", "javaContainer", "javaContainerVersion", "javaVersion", "keyVaultReferenceIdentity", "limits", "linuxFxVersion", "loadBalancing", "localMySqlEnabled", "logsDirectorySizeLimit", "managedPipelineMode", "managedServiceIdentityId", "minimumElasticInstanceCount", "minTlsVersion", "nodeVersion", "numberOfWorkers", "phpVersion", "powerShellVersion", "preWarmedInstanceCount", "publicNetworkAccess", "publishingUsername", "push", "pythonVersion", "remoteDebuggingEnabled", "remoteDebuggingVersion", "requestTracingEnabled", "requestTracingExpirationTime", "scmIpSecurityRestrictions", "scmIpSecurityRestrictionsUseMain", "scmMinTlsVersion", "scmType", "tracingOptions", "use32BitWorkerProcess", "virtualApplications", "vnetName", "vnetPrivatePortsCount", "vnetRouteAllEnabled", "websiteTimeZone", "windowsFxVersion", "xManagedServiceIdentityId". If this is an inaccuracy in the documentation, please report it to the Bicep Team. [https://aka.ms/bicep-type-issues]
// C:\Users\v-richardsi\source\repos\Architecture\Sbox360\Design\Verification\ServiceBusSimpleSendReceive\infrastructure\assignRbacRoleToFunctionAppForStorageAccount.bicep(21,5) : Warning BCP073: The property "scope" is read-only. Expressions cannot be assigned to read-only properties. If this is an inaccuracy in the documentation, please report it to the Bicep Team. [https://aka.ms/bicep-type-issues]
// C:\Users\v-richardsi\source\repos\Architecture\Sbox360\Design\Verification\ServiceBusSimpleSendReceive\infrastructure\assignRbacRoleToFunctionAppForKVAccess.bicep(23,5) : Warning BCP073: The property "scope" is read-only. Expressions cannot be assigned to read-only properties. If this is an inaccuracy in the documentation, please report it to the Bicep Team. [https://aka.ms/bicep-type-issues]
// C:\Users\v-richardsi\source\repos\Architecture\Sbox360\Design\Verification\ServiceBusSimpleSendReceive\infrastructure\assignRbacRoleToFunctionApp.bicep(21,5) : Warning BCP073: The property "scope" is read-only. Expressions cannot be assigned to read-only properties. If this is an inaccuracy in the documentation, please report it to the Bicep Team. [https://aka.ms/bicep-type-issues]

// ERROR: {"status":"Failed","error":{"code":"DeploymentFailed","target":"/subscriptions/13c9725f-d20a-4c99-8ef4-d7bb78f98cff/resourceGroups/rg_SBusSndRcv_v-richardsi/providers/Microsoft.Resources/deployments/SBusSndRcv_v-richardsi","message":"At least one resource deployment operation failed. Please list deployment operations for details. Please see https://aka.ms/arm-deployment-operations for usage details.","details":[{"code":"ResourceDeploymentFailure","target":"/subscriptions/13c9725f-d20a-4c99-8ef4-d7bb78f98cff/resourceGroups/rg_SBusSndRcv_v-richardsi/providers/Microsoft.ServiceBus/namespaces/xizdf-servicebus","message":"The resource write operation failed to complete successfully, because it reached terminal provisioning state 'Failed'."}]}}
// end deploy 07/10/2024 20:14:01
// resource group = rg_SBusSndRcv_v-richardsi
// Name                     ResourceType                                        Region    Flavor
// -----------------------  --------------------------------------------------  --------  -----------
// xizdf-servicebus         Microsoft.ServiceBus/namespaces                     eastus2
// xizdffuncstg             Microsoft.Storage/storageAccounts                   eastus2   StorageV2
// xizdf-plan-func          Microsoft.Web/serverFarms                           eastus2   functionapp
// xizdf-appins             Microsoft.Insights/components                       eastus2   web
// xizdf-plan-web           Microsoft.Web/serverFarms                           eastus2   app
// xizdf-detector           Microsoft.Insights/actiongroups                     global
// xizdf-failure anomalies  microsoft.alertsManagement/smartDetectorAlertRules  global
// all done 07/10/2024 20:14:04 elapse time = 00:03:31 

// Process compilation finished



// start build for resource group = rg_SBusSndRcv_v-richardsi at 07/10/2024 19:43:15
// Phase 1 deployment: Create Service Bus queue (tier=Basic), Function App (tier=P1V2) WebApp=True, Storage Accounts and VNet=False and no PEP
// WARNING: C:\Users\v-richardsi\source\repos\Architecture\Sbox360\Design\Verification\ServiceBusSimpleSendReceive\infrastructure\assignRbacRoleToFunctionApp.bicep(21,5) : Warning BCP073: The property "scope" is read-only. Expressions cannot be assigned to read-only properties. If this is an inaccuracy in the documentation, please report it to the Bicep Team. [https://aka.ms/bicep-type-issues]
// C:\Users\v-richardsi\source\repos\Architecture\Sbox360\Design\Verification\ServiceBusSimpleSendReceive\infrastructure\deploy-ServiceBusSimpleSendReceive.bicep(559,10) : Warning no-unused-existing-resources: Existing resource "serviceBus_existing" is declared but never used. [https://aka.ms/bicep/linter/no-unused-existing-resources]
// C:\Users\v-richardsi\source\repos\Architecture\Sbox360\Design\Verification\ServiceBusSimpleSendReceive\infrastructure\deploy-ServiceBusSimpleSendReceive.bicep(675,10) : Warning no-unused-existing-resources: Existing resource "storageAccountForFuncApp_existing" is declared but never used. [https://aka.ms/bicep/linter/no-unused-existing-resources]
// C:\Users\v-richardsi\source\repos\Architecture\Sbox360\Design\Verification\ServiceBusSimpleSendReceive\infrastructure\deploy-ServiceBusSimpleSendReceive.bicep(712,10) : Warning no-unused-existing-resources: Existing resource "functionPlan_existing" is declared but never used. [https://aka.ms/bicep/linter/no-unused-existing-resources]
// C:\Users\v-richardsi\source\repos\Architecture\Sbox360\Design\Verification\ServiceBusSimpleSendReceive\infrastructure\deploy-ServiceBusSimpleSendReceive.bicep(1100,10) : Warning no-unused-existing-resources: Existing resource "kvaadb2cSecret_existing" is declared but never used. [https://aka.ms/bicep/linter/no-unused-existing-resources]
// C:\Users\v-richardsi\source\repos\Architecture\Sbox360\Design\Verification\ServiceBusSimpleSendReceive\infrastructure\deploy-ServiceBusSimpleSendReceive.bicep(1362,7) : Warning no-unused-params: Parameter "webapp_dns_name" is declared but never used. [https://aka.ms/bicep/linter/no-unused-params]
// C:\Users\v-richardsi\source\repos\Architecture\Sbox360\Design\Verification\ServiceBusSimpleSendReceive\infrastructure\deploy-ServiceBusSimpleSendReceive.bicep(1498,5) : Warning BCP037: The property "name" is not allowed on objects of type "AppServicePlanProperties". Permissible properties include "freeOfferExpirationTime", "hostingEnvironmentProfile", "hyperV", "isSpot", "isXenon", "kubeEnvironmentProfile", "maximumElasticWorkerCount", "perSiteScaling", "reserved", "spotExpirationTime", "targetWorkerCount", "targetWorkerSizeId", "workerTierName". If this is an inaccuracy in the documentation, please report it to the Bicep Team. [https://aka.ms/bicep-type-issues]
// C:\Users\v-richardsi\source\repos\Architecture\Sbox360\Design\Verification\ServiceBusSimpleSendReceive\infrastructure\deploy-ServiceBusSimpleSendReceive.bicep(1502,10) : Warning no-unused-existing-resources: Existing resource "hostingPlan_existing" is declared but never used. [https://aka.ms/bicep/linter/no-unused-existing-resources]
// C:\Users\v-richardsi\source\repos\Architecture\Sbox360\Design\Verification\ServiceBusSimpleSendReceive\infrastructure\deploy-ServiceBusSimpleSendReceive.bicep(1514,7) : Warning BCP037: The property "metadata" is not allowed on objects of type "SiteConfig". Permissible properties include "acrUseManagedIdentityCreds", "acrUserManagedIdentityID", "alwaysOn", "apiDefinition", "apiManagementConfig", "appCommandLine", "autoHealEnabled", "autoHealRules", "autoSwapSlotName", "azureStorageAccounts", "connectionStrings", "cors", "defaultDocuments", "detailedErrorLoggingEnabled", "documentRoot", "experiments", "ftpsState", "functionAppScaleLimit", "functionsRuntimeScaleMonitoringEnabled", "handlerMappings", "healthCheckPath", "http20Enabled", "httpLoggingEnabled", "ipSecurityRestrictions", "javaContainer", "javaContainerVersion", "javaVersion", "keyVaultReferenceIdentity", "limits", "linuxFxVersion", "loadBalancing", "localMySqlEnabled", "logsDirectorySizeLimit", "managedPipelineMode", "managedServiceIdentityId", "minimumElasticInstanceCount", "minTlsVersion", "nodeVersion", "numberOfWorkers", "phpVersion", "powerShellVersion", "preWarmedInstanceCount", "publicNetworkAccess", "publishingUsername", "push", "pythonVersion", "remoteDebuggingEnabled", "remoteDebuggingVersion", "requestTracingEnabled", "requestTracingExpirationTime", "scmIpSecurityRestrictions", "scmIpSecurityRestrictionsUseMain", "scmMinTlsVersion", "scmType", "tracingOptions", "use32BitWorkerProcess", "virtualApplications", "vnetName", "vnetPrivatePortsCount", "vnetRouteAllEnabled", "websiteTimeZone", "windowsFxVersion", "xManagedServiceIdentityId". If this is an inaccuracy in the documentation, please report it to the Bicep Team. [https://aka.ms/bicep-type-issues]
// C:\Users\v-richardsi\source\repos\Architecture\Sbox360\Design\Verification\ServiceBusSimpleSendReceive\infrastructure\assignRbacRoleToFunctionAppForStorageAccount.bicep(21,5) : Warning BCP073: The property "scope" is read-only. Expressions cannot be assigned to read-only properties. If this is an inaccuracy in the documentation, please report it to the Bicep Team. [https://aka.ms/bicep-type-issues]
// C:\Users\v-richardsi\source\repos\Architecture\Sbox360\Design\Verification\ServiceBusSimpleSendReceive\infrastructure\assignRbacRoleToFunctionAppForKVAccess.bicep(23,5) : Warning BCP073: The property "scope" is read-only. Expressions cannot be assigned to read-only properties. If this is an inaccuracy in the documentation, please report it to the Bicep Team. [https://aka.ms/bicep-type-issues]
// 
// ERROR: {"status":"Failed","error":{"code":"DeploymentFailed","target":"/subscriptions/13c9725f-d20a-4c99-8ef4-d7bb78f98cff/resourceGroups/rg_SBusSndRcv_v-richardsi/providers/Microsoft.Resources/deployments/SBusSndRcv_v-richardsi","message":"At least one resource deployment operation failed. Please list deployment operations for details. Please see https://aka.ms/arm-deployment-operations for usage details.","details":[{"code":"MessagingGatewayBadRequest","message":"SubCode=40000. Bad Request. To know more visit https://aka.ms/sbResourceMgrExceptions. . TrackingId:453a5f4e-61fb-4c7c-8307-7af6fef3aa19_G26, SystemTracker:xizdf-servicebus.servicebus.windows.net:mainqueue001, Timestamp:2024-07-11T02:43:54"}]}}
// end deploy 07/10/2024 19:45:01
// resource group = rg_SBusSndRcv_v-richardsi
// Name                     ResourceType                                        Region    Flavor
// -----------------------  --------------------------------------------------  --------  -----------
// xizdf-servicebus         Microsoft.ServiceBus/namespaces                     eastus2
// xizdffuncstg             Microsoft.Storage/storageAccounts                   eastus2   StorageV2
// xizdf-plan-func          Microsoft.Web/serverFarms                           eastus2   functionapp
// xizdf-appins             Microsoft.Insights/components                       eastus2   web
// xizdf-plan-web           Microsoft.Web/serverFarms                           eastus2   app
// xizdf-detector           Microsoft.Insights/actiongroups                     global
// xizdf-failure anomalies  microsoft.alertsManagement/smartDetectorAlertRules  global
// xizdf-func               Microsoft.Web/sites                                 eastus2   functionapp
// xizdf-webapp             Microsoft.Web/sites                                 eastus2   app
// all done 07/10/2024 19:45:04 elapse time = 00:01:49 
// 
// Process compilation finished
//
// from the portal: Message SubCode=40000. Bad Request. To know more visit https://aka.ms/sbResourceMgrExceptions. . TrackingId:453a5f4e-61fb-4c7c-8307-7af6fef3aa19_G26, SystemTracker:xizdf-servicebus.servicebus.windows.net:mainqueue001, Timestamp:2024-07-11T02:43:54
//


// start build for resource group = rg_SBusSndRcv_v-richardsi at 07/10/2024 18:09:18
// Step 3: begin shutdown delete resource group rg_SBusSndRcv_v-richardsi 07/10/2024 18:09:18
// az group delete -n rg_SBusSndRcv_v-richardsi
// ERROR: (ResourceGroupDeletionTimeout) Deletion of resource group 'rg_SBusSndRcv_v-richardsi' did not finish within the allowed time as resources with identifiers 'Microsoft.Web/serverFarms/Default1yd' could not be deleted. The provisioning state of the resource group will be rolled back. The tracking Id is '1292fd82-4d79-4d04-8509-35adc9774844'. Please check audit logs for more details.
// Code: ResourceGroupDeletionTimeout
// Message: Deletion of resource group 'rg_SBusSndRcv_v-richardsi' did not finish within the allowed time as resources with identifiers 'Microsoft.Web/serverFarms/Default1yd' could not be deleted. The provisioning state of the resource group will be rolled back. The tracking Id is '1292fd82-4d79-4d04-8509-35adc9774844'. Please check audit logs for more details.
// Exception Details:	(None) {"Code":"429","Message":"Cannot acquire exclusive lock to create or update this server farm. Retry the request later.","Target":null,"Details":[{"Message":"Cannot acquire exclusive lock to create or update this server farm. Retry the request later."},{"Code":"429"},{"ErrorEntity":{"ExtendedCode":"59207","MessageTemplate":"Cannot acquire exclusive lock to create or update this server farm. Retry the request later.","Parameters":[],"Code":"429","Message":"Cannot acquire exclusive lock to create or update this server farm. Retry the request later."}}],"Innererror":null}
// 	Code: None
// 	Message: {"Code":"429","Message":"Cannot acquire exclusive lock to create or update this server farm. Retry the request later.","Target":null,"Details":[{"Message":"Cannot acquire exclusive lock to create or update this server farm. Retry the request later."},{"Code":"429"},{"ErrorEntity":{"ExtendedCode":"59207","MessageTemplate":"Cannot acquire exclusive lock to create or update this server farm. Retry the request later.","Parameters":[],"Code":"429","Message":"Cannot acquire exclusive lock to create or update this server farm. Retry the request later."}}],"Innererror":null}
// 	Target: /subscriptions/13c9725f-d20a-4c99-8ef4-d7bb78f98cff/resourceGroups/rg_SBusSndRcv_v-richardsi/providers/Microsoft.Web/serverFarms/Default1yd
// shutdown is complete rg_SBusSndRcv_v-richardsi 07/10/2024 19:13:34
// One time initializations: Create resource group and service principal for github workflow
// az group create -l eastus2 -n rg_SBusSndRcv_v-richardsi
// {
//   "id": "/subscriptions/13c9725f-d20a-4c99-8ef4-d7bb78f98cff/resourceGroups/rg_SBusSndRcv_v-richardsi",
//   "location": "eastus2",
//   "managedBy": null,
//   "name": "rg_SBusSndRcv_v-richardsi",
//   "properties": {
//     "provisioningState": "Succeeded"
//   },
//   "tags": {
//     "ringValue": "r0"
//   },
//   "type": "Microsoft.Resources/resourceGroups"
// }
// id=/subscriptions/13c9725f-d20a-4c99-8ef4-d7bb78f98cff/resourceGroups/rg_SBusSndRcv_v-richardsi
// Phase 1 deployment: Create Service Bus queue (tier=Basic), Function App (tier=) WebApp=True, Storage Accounts and VNet=False and no PEP
// WARNING: C:\Users\v-richardsi\source\repos\Architecture\Sbox360\Design\Verification\ServiceBusSimpleSendReceive\infrastructure\assignRbacRoleToFunctionAppForStorageAccount.bicep(21,5) : Warning BCP073: The property "scope" is read-only. Expressions cannot be assigned to read-only properties. If this is an inaccuracy in the documentation, please report it to the Bicep Team. [https://aka.ms/bicep-type-issues]
// C:\Users\v-richardsi\source\repos\Architecture\Sbox360\Design\Verification\ServiceBusSimpleSendReceive\infrastructure\assignRbacRoleToFunctionApp.bicep(21,5) : Warning BCP073: The property "scope" is read-only. Expressions cannot be assigned to read-only properties. If this is an inaccuracy in the documentation, please report it to the Bicep Team. [https://aka.ms/bicep-type-issues]
// C:\Users\v-richardsi\source\repos\Architecture\Sbox360\Design\Verification\ServiceBusSimpleSendReceive\infrastructure\assignRbacRoleToFunctionAppForKVAccess.bicep(23,5) : Warning BCP073: The property "scope" is read-only. Expressions cannot be assigned to read-only properties. If this is an inaccuracy in the documentation, please report it to the Bicep Team. [https://aka.ms/bicep-type-issues]
// C:\Users\v-richardsi\source\repos\Architecture\Sbox360\Design\Verification\ServiceBusSimpleSendReceive\infrastructure\deploy-ServiceBusSimpleSendReceive.bicep(559,10) : Warning no-unused-existing-resources: Existing resource "serviceBus_existing" is declared but never used. [https://aka.ms/bicep/linter/no-unused-existing-resources]
// C:\Users\v-richardsi\source\repos\Architecture\Sbox360\Design\Verification\ServiceBusSimpleSendReceive\infrastructure\deploy-ServiceBusSimpleSendReceive.bicep(675,10) : Warning no-unused-existing-resources: Existing resource "storageAccountForFuncApp_existing" is declared but never used. [https://aka.ms/bicep/linter/no-unused-existing-resources]
// C:\Users\v-richardsi\source\repos\Architecture\Sbox360\Design\Verification\ServiceBusSimpleSendReceive\infrastructure\deploy-ServiceBusSimpleSendReceive.bicep(712,10) : Warning no-unused-existing-resources: Existing resource "functionPlan_existing" is declared but never used. [https://aka.ms/bicep/linter/no-unused-existing-resources]
// C:\Users\v-richardsi\source\repos\Architecture\Sbox360\Design\Verification\ServiceBusSimpleSendReceive\infrastructure\deploy-ServiceBusSimpleSendReceive.bicep(1100,10) : Warning no-unused-existing-resources: Existing resource "kvaadb2cSecret_existing" is declared but never used. [https://aka.ms/bicep/linter/no-unused-existing-resources]
// C:\Users\v-richardsi\source\repos\Architecture\Sbox360\Design\Verification\ServiceBusSimpleSendReceive\infrastructure\deploy-ServiceBusSimpleSendReceive.bicep(1362,7) : Warning no-unused-params: Parameter "webapp_dns_name" is declared but never used. [https://aka.ms/bicep/linter/no-unused-params]
// C:\Users\v-richardsi\source\repos\Architecture\Sbox360\Design\Verification\ServiceBusSimpleSendReceive\infrastructure\deploy-ServiceBusSimpleSendReceive.bicep(1498,5) : Warning BCP037: The property "name" is not allowed on objects of type "AppServicePlanProperties". Permissible properties include "freeOfferExpirationTime", "hostingEnvironmentProfile", "hyperV", "isSpot", "isXenon", "kubeEnvironmentProfile", "maximumElasticWorkerCount", "perSiteScaling", "reserved", "spotExpirationTime", "targetWorkerCount", "targetWorkerSizeId", "workerTierName". If this is an inaccuracy in the documentation, please report it to the Bicep Team. [https://aka.ms/bicep-type-issues]
// C:\Users\v-richardsi\source\repos\Architecture\Sbox360\Design\Verification\ServiceBusSimpleSendReceive\infrastructure\deploy-ServiceBusSimpleSendReceive.bicep(1502,10) : Warning no-unused-existing-resources: Existing resource "hostingPlan_existing" is declared but never used. [https://aka.ms/bicep/linter/no-unused-existing-resources]
// C:\Users\v-richardsi\source\repos\Architecture\Sbox360\Design\Verification\ServiceBusSimpleSendReceive\infrastructure\deploy-ServiceBusSimpleSendReceive.bicep(1514,7) : Warning BCP037: The property "metadata" is not allowed on objects of type "SiteConfig". Permissible properties include "acrUseManagedIdentityCreds", "acrUserManagedIdentityID", "alwaysOn", "apiDefinition", "apiManagementConfig", "appCommandLine", "autoHealEnabled", "autoHealRules", "autoSwapSlotName", "azureStorageAccounts", "connectionStrings", "cors", "defaultDocuments", "detailedErrorLoggingEnabled", "documentRoot", "experiments", "ftpsState", "functionAppScaleLimit", "functionsRuntimeScaleMonitoringEnabled", "handlerMappings", "healthCheckPath", "http20Enabled", "httpLoggingEnabled", "ipSecurityRestrictions", "javaContainer", "javaContainerVersion", "javaVersion", "keyVaultReferenceIdentity", "limits", "linuxFxVersion", "loadBalancing", "localMySqlEnabled", "logsDirectorySizeLimit", "managedPipelineMode", "managedServiceIdentityId", "minimumElasticInstanceCount", "minTlsVersion", "nodeVersion", "numberOfWorkers", "phpVersion", "powerShellVersion", "preWarmedInstanceCount", "publicNetworkAccess", "publishingUsername", "push", "pythonVersion", "remoteDebuggingEnabled", "remoteDebuggingVersion", "requestTracingEnabled", "requestTracingExpirationTime", "scmIpSecurityRestrictions", "scmIpSecurityRestrictionsUseMain", "scmMinTlsVersion", "scmType", "tracingOptions", "use32BitWorkerProcess", "virtualApplications", "vnetName", "vnetPrivatePortsCount", "vnetRouteAllEnabled", "websiteTimeZone", "windowsFxVersion", "xManagedServiceIdentityId". If this is an inaccuracy in the documentation, please report it to the Bicep Team. [https://aka.ms/bicep-type-issues]
// 
// ERROR: {"status":"Failed","error":{"code":"DeploymentFailed","target":"/subscriptions/13c9725f-d20a-4c99-8ef4-d7bb78f98cff/resourceGroups/rg_SBusSndRcv_v-richardsi/providers/Microsoft.Resources/deployments/SBusSndRcv_v-richardsi","message":"At least one resource deployment operation failed. Please list deployment operations for details. Please see https://aka.ms/arm-deployment-operations for usage details.","details":[{"code":"MessagingGatewayBadRequest","message":"SubCode=40000. Bad Request. To know more visit https://aka.ms/sbResourceMgrExceptions. . TrackingId:db0ad8c8-2ab6-4bc6-bdbd-c414069fb6dc_G5, SystemTracker:xizdf-servicebus.servicebus.windows.net:mainqueue001, Timestamp:2024-07-11T02:14:23"}]}}
// end deploy 07/10/2024 19:15:29
// resource group = rg_SBusSndRcv_v-richardsi
// Name                     ResourceType                                        Region    Flavor
// -----------------------  --------------------------------------------------  --------  -----------
// xizdf-servicebus         Microsoft.ServiceBus/namespaces                     eastus2
// xizdffuncstg             Microsoft.Storage/storageAccounts                   eastus2   StorageV2
// xizdf-plan-func          Microsoft.Web/serverFarms                           eastus2   functionapp
// xizdf-appins             Microsoft.Insights/components                       eastus2   web
// xizdf-plan-web           Microsoft.Web/serverFarms                           eastus2   app
// xizdf-detector           Microsoft.Insights/actiongroups                     global
// xizdf-failure anomalies  microsoft.alertsManagement/smartDetectorAlertRules  global
// xizdf-func               Microsoft.Web/sites                                 eastus2   functionapp
// xizdf-webapp             Microsoft.Web/sites                                 eastus2   app
// all done 07/10/2024 19:15:32 elapse time = 01:06:13 
// 
// Process compilation finished
// 


// start build for resource group = rg_SBusSndRcv_v-richardsi at 07/10/2024 17:54:03
// Step 3: begin shutdown delete resource group rg_SBusSndRcv_v-richardsi 07/10/2024 17:54:03
// az group delete -n rg_SBusSndRcv_v-richardsi
// shutdown is complete rg_SBusSndRcv_v-richardsi 07/10/2024 17:55:24
// One time initializations: Create resource group and service principal for github workflow
// az group create -l eastus2 -n rg_SBusSndRcv_v-richardsi
// {
//   "id": "/subscriptions/13c9725f-d20a-4c99-8ef4-d7bb78f98cff/resourceGroups/rg_SBusSndRcv_v-richardsi",
//   "location": "eastus2",
//   "managedBy": null,
//   "name": "rg_SBusSndRcv_v-richardsi",
//   "properties": {
//     "provisioningState": "Succeeded"
//   },
//   "tags": {
//     "ringValue": "r0"
//   },
//   "type": "Microsoft.Resources/resourceGroups"
// }
// id=/subscriptions/13c9725f-d20a-4c99-8ef4-d7bb78f98cff/resourceGroups/rg_SBusSndRcv_v-richardsi
// Phase 1 deployment: Create Service Bus queue (tier=Basic), Function App (tier=) WebApp=False, Storage Accounts and VNet=False and no PEP
// WARNING: C:\Users\v-richardsi\source\repos\Architecture\Sbox360\Design\Verification\ServiceBusSimpleSendReceive\infrastructure\assignRbacRoleToFunctionAppForStorageAccount.bicep(21,5) : Warning BCP073: The property "scope" is read-only. Expressions cannot be assigned to read-only properties. If this is an inaccuracy in the documentation, please report it to the Bicep Team. [https://aka.ms/bicep-type-issues]
// C:\Users\v-richardsi\source\repos\Architecture\Sbox360\Design\Verification\ServiceBusSimpleSendReceive\infrastructure\assignRbacRoleToFunctionAppForKVAccess.bicep(23,5) : Warning BCP073: The property "scope" is read-only. Expressions cannot be assigned to read-only properties. If this is an inaccuracy in the documentation, please report it to the Bicep Team. [https://aka.ms/bicep-type-issues]
// C:\Users\v-richardsi\source\repos\Architecture\Sbox360\Design\Verification\ServiceBusSimpleSendReceive\infrastructure\assignRbacRoleToFunctionApp.bicep(21,5) : Warning BCP073: The property "scope" is read-only. Expressions cannot be assigned to read-only properties. If this is an inaccuracy in the documentation, please report it to the Bicep Team. [https://aka.ms/bicep-type-issues]
// C:\Users\v-richardsi\source\repos\Architecture\Sbox360\Design\Verification\ServiceBusSimpleSendReceive\infrastructure\deploy-ServiceBusSimpleSendReceive.bicep(558,10) : Warning no-unused-existing-resources: Existing resource "serviceBus_existing" is declared but never used. [https://aka.ms/bicep/linter/no-unused-existing-resources]
// C:\Users\v-richardsi\source\repos\Architecture\Sbox360\Design\Verification\ServiceBusSimpleSendReceive\infrastructure\deploy-ServiceBusSimpleSendReceive.bicep(674,10) : Warning no-unused-existing-resources: Existing resource "storageAccountForFuncApp_existing" is declared but never used. [https://aka.ms/bicep/linter/no-unused-existing-resources]
// C:\Users\v-richardsi\source\repos\Architecture\Sbox360\Design\Verification\ServiceBusSimpleSendReceive\infrastructure\deploy-ServiceBusSimpleSendReceive.bicep(711,10) : Warning no-unused-existing-resources: Existing resource "functionPlan_existing" is declared but never used. [https://aka.ms/bicep/linter/no-unused-existing-resources]
// C:\Users\v-richardsi\source\repos\Architecture\Sbox360\Design\Verification\ServiceBusSimpleSendReceive\infrastructure\deploy-ServiceBusSimpleSendReceive.bicep(1099,10) : Warning no-unused-existing-resources: Existing resource "kvaadb2cSecret_existing" is declared but never used. [https://aka.ms/bicep/linter/no-unused-existing-resources]
// C:\Users\v-richardsi\source\repos\Architecture\Sbox360\Design\Verification\ServiceBusSimpleSendReceive\infrastructure\deploy-ServiceBusSimpleSendReceive.bicep(1361,7) : Warning no-unused-params: Parameter "webapp_dns_name" is declared but never used. [https://aka.ms/bicep/linter/no-unused-params]
// C:\Users\v-richardsi\source\repos\Architecture\Sbox360\Design\Verification\ServiceBusSimpleSendReceive\infrastructure\deploy-ServiceBusSimpleSendReceive.bicep(1497,5) : Warning BCP037: The property "name" is not allowed on objects of type "AppServicePlanProperties". Permissible properties include "freeOfferExpirationTime", "hostingEnvironmentProfile", "hyperV", "isSpot", "isXenon", "kubeEnvironmentProfile", "maximumElasticWorkerCount", "perSiteScaling", "reserved", "spotExpirationTime", "targetWorkerCount", "targetWorkerSizeId", "workerTierName". If this is an inaccuracy in the documentation, please report it to the Bicep Team. [https://aka.ms/bicep-type-issues]
// C:\Users\v-richardsi\source\repos\Architecture\Sbox360\Design\Verification\ServiceBusSimpleSendReceive\infrastructure\deploy-ServiceBusSimpleSendReceive.bicep(1501,10) : Warning no-unused-existing-resources: Existing resource "hostingPlan_existing" is declared but never used. [https://aka.ms/bicep/linter/no-unused-existing-resources]
// C:\Users\v-richardsi\source\repos\Architecture\Sbox360\Design\Verification\ServiceBusSimpleSendReceive\infrastructure\deploy-ServiceBusSimpleSendReceive.bicep(1513,7) : Warning BCP037: The property "metadata" is not allowed on objects of type "SiteConfig". Permissible properties include "acrUseManagedIdentityCreds", "acrUserManagedIdentityID", "alwaysOn", "apiDefinition", "apiManagementConfig", "appCommandLine", "autoHealEnabled", "autoHealRules", "autoSwapSlotName", "azureStorageAccounts", "connectionStrings", "cors", "defaultDocuments", "detailedErrorLoggingEnabled", "documentRoot", "experiments", "ftpsState", "functionAppScaleLimit", "functionsRuntimeScaleMonitoringEnabled", "handlerMappings", "healthCheckPath", "http20Enabled", "httpLoggingEnabled", "ipSecurityRestrictions", "javaContainer", "javaContainerVersion", "javaVersion", "keyVaultReferenceIdentity", "limits", "linuxFxVersion", "loadBalancing", "localMySqlEnabled", "logsDirectorySizeLimit", "managedPipelineMode", "managedServiceIdentityId", "minimumElasticInstanceCount", "minTlsVersion", "nodeVersion", "numberOfWorkers", "phpVersion", "powerShellVersion", "preWarmedInstanceCount", "publicNetworkAccess", "publishingUsername", "push", "pythonVersion", "remoteDebuggingEnabled", "remoteDebuggingVersion", "requestTracingEnabled", "requestTracingExpirationTime", "scmIpSecurityRestrictions", "scmIpSecurityRestrictionsUseMain", "scmMinTlsVersion", "scmType", "tracingOptions", "use32BitWorkerProcess", "virtualApplications", "vnetName", "vnetPrivatePortsCount", "vnetRouteAllEnabled", "websiteTimeZone", "windowsFxVersion", "xManagedServiceIdentityId". If this is an inaccuracy in the documentation, please report it to the Bicep Team. [https://aka.ms/bicep-type-issues]
// 
// ERROR: {"status":"Failed","error":{"code":"DeploymentFailed","target":"/subscriptions/13c9725f-d20a-4c99-8ef4-d7bb78f98cff/resourceGroups/rg_SBusSndRcv_v-richardsi/providers/Microsoft.Resources/deployments/SBusSndRcv_v-richardsi","message":"At least one resource deployment operation failed. Please list deployment operations for details. Please see https://aka.ms/arm-deployment-operations for usage details.","details":[{"code":"MessagingGatewayBadRequest","message":"SubCode=40000. Bad Request. To know more visit https://aka.ms/sbResourceMgrExceptions. . TrackingId:74a6d368-c1e3-4385-8784-84550a84c6a1_G34, SystemTracker:xizdf-servicebus.servicebus.windows.net:mainqueue001, Timestamp:2024-07-11T00:56:07"}]}}
// end deploy 07/10/2024 17:57:16
// resource group = rg_SBusSndRcv_v-richardsi
// Name                     Flavor       ResourceType                                        Region
// -----------------------  -----------  --------------------------------------------------  --------
// xizdffuncstg             StorageV2    Microsoft.Storage/storageAccounts                   eastus2
// xizdf-detector                        Microsoft.Insights/actiongroups                     global
// xizdf-appins             web          Microsoft.Insights/components                       eastus2
// xizdf-servicebus                      Microsoft.ServiceBus/namespaces                     eastus2
// xizdf-plan-func          functionapp  Microsoft.Web/serverFarms                           eastus2
// xizdf-failure anomalies               microsoft.alertsManagement/smartDetectorAlertRules  global
// xizdf-func               functionapp  Microsoft.Web/sites                                 eastus2
// all done 07/10/2024 17:57:19 elapse time = 00:03:15 
// 
// Process compilation finished
// 




// begin 07/10/2024 09:29:51
// ERROR: {
//   "status": "Failed",
//   "error": {
//     "code": "DeploymentFailed",
//     "target": "/subscriptions/13c9725f-d20a-4c99-8ef4-d7bb78f98cff/resourceGroups/rg_SBusSndRcv_v-richardsi/providers/Microsoft.Resources/deployments/SBusSndRcv_v-richardsi",
//     "message": "At least one resource deployment operation failed. Please list deployment operations for details. Please see https://aka.ms/arm-deployment-operations for usage details.",
//     "details": [
//       {
//         "code": "ResourceNotFound",
//         "message": "The Resource 'Microsoft.Web/sites/xizdf-webapp' under resource group 'rg_SBusSndRcv_v-richardsi' was not found. For more details please go to https://aka.ms/ARMResourceNotFoundFix"
//       }
//     ]
//   }
// }
// 
// end deploy 07/10/2024 09:29:47
// resource group = rg_SBusSndRcv_v-richardsi
// Name                     ResourceType                                        Region    Flavor
// -----------------------  --------------------------------------------------  --------  -----------
// xizdf-servicebus         Microsoft.ServiceBus/namespaces                     eastus2
// xizdf-appins             Microsoft.Insights/components                       eastus2   web
// xizdf-plan-func          Microsoft.Web/serverFarms                           eastus2   functionapp
// xizdf-detector           Microsoft.Insights/actiongroups                     global
// xizdffuncstg             Microsoft.Storage/storageAccounts                   eastus2   StorageV2
// xizdf-failure anomalies  microsoft.alertsManagement/smartDetectorAlertRules  global
// xizdf-func               Microsoft.Web/sites                                 eastus2   functionapp
// all done 07/10/2024 09:29:51 elapse time = 00:01:56 
// 



// begin 07/09/2024 13:28:15
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
// end failure log
