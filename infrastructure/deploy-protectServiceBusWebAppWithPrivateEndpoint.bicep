/*

   powershell -executionPolicy unrestricted -Command - <<EOF
   `perl -lne 'sub range {$b=shift; $e=shift; $r=""; for(($b..$e)){ $r=$r."," if $r; $r=$r.$_;} $r } BEGIN {  $_ = shift; s/([0-9]+)-([0-9]+)/range($1,$2)/e; @idx=split ","; $c=0; $x=0; $f=0; $s=[] } $c++ if /^\s*Begin/; if (/^\s*End/) {$c--;$s[$f++]=""}; if ($x+$c>1) { $s->[$f]=$s->[$f].$_."\n"  } $x=$c; END { push(@idx, $#s); unshift @idx,0; for (@idx) { $p=$s->[$_]; chomp $p; print $p } }' "2,3,1,4-7" < "deploy-protectServiceBusWebAppWithPrivateEndpoint.bicep"  `
EOF

   Begin common prolog commands
   $env:tenandId=(az account show --query tenantId --output tsv)
   $env:subscriptionId=(az account show --query id --output tsv | ForEach-Object { $_ -replace "`r", ""})
   $noManagedIdent=($env:subscriptionId -eq "13c9725f-d20a-4c99-8ef4-d7bb78f98cff")
   $env:name="SBusSndRcvPEP_$($env:USERNAME)"
   $env:rg="rg_$env:name"
   write-output "resource group=$env:rg"
   $env:uniquePrefix="$(If ($env:USERNAME -eq "v-richardsi") {"jqo0osm3qxqr"} Else { "veyf0f1ncz4i" })"
   $env:repoURL="$(If ($env:USERNAME -eq "v-richardsi") {"https://github.com/siegfried01/HelloBlazorSvr.git"} Else { "https://github.com/MSPON-187/HelloBlazorSvr.git" })"
   $env:gitToken="$(If ($env:USERNAME -eq "v-richardsi") {$null} Else { "--git-token ${env:GITHUB_TOKEN}" })"
   $env:gitTokenPath="$(If ($null -ne $env:gitToken) {"--git-token ${env:gitToken}"} )"
   $env:loc="eastus2"
   $env:funcLoc=$env:loc
   $env:functionAppName="$($env:uniquePrefix)-func"
   $env:functionAppPlanName="$($env:uniquePrefix)-func-plan"
   $env:vnetName="$($env:uniquePrefix)-vnet"
   $env:subnetName="subnet-Bastion"
   $env:peConn="$($env:uniquePrefix)-peconn"
   $env:peWebName="$($env:uniquePrefix)-web-private-end-point"
   $env:peFuncName="$($env:uniquePrefix)-func-private-end-point"
   $env:pipName="$($env:uniquePrefix)-public-ip"
   $env:pipFunctionAppName="$($env:uniquePrefix)-function-public-ip"
   $env:serviceBusPEP="$($env:uniquePrefix)-sb-pep"
   $env:serviceBusNS="$($env:uniquePrefix)-servicebus"
   $env:serviceBusQueue="mainqueue001"
   $env:peSBName="$($env:uniquePrefix)-servicebuss-private-end-point"
   $env:vmName="$($env:uniquePrefix)-vm"
   $env:VMSize="Standard_B4ms"
   $env:stgAccount="${env:uniquePrefix}stg"
   $env:keyVaultName="kv-${env:uniquePrefix}"
   $env:uamiName="uami-${env:uniquePrefix}"
   $env:uamiId=""
   $env:samiName="sami-${env:uniquePrefix}"
   $env:appConfigName="appcs-${env:uniquePrefix}"   # Add -new to the end if the initial attempt fails
   $env:samiObjectId=(az webapp identity show --name $env:functionappName --resource-group $env:rg --query principalId --output tsv)
   $env:appConfigEndpoint="${env.uniquePrefix}-dupe.azconfig.io"
   $env:appInsightsName="${env.uniquePrefix}-appins"
   $env:appServiceName="appService-${env.uniquePrefix}"
   write-output "starting $(Get-Date)"
   End common prolog commands
   
   emacs F10
   Begin commands to deploy this file using Azure CLI with PowerShell
   write-output "Step 1: deploy resources in bicep: service bus, functionapp, webapp & plan using Environment Variables"
   pushd ..
   write-output "az deployment group create --name $env:name --resource-group $env:rg --template-file  infrastructure/deploy-protectServiceBusWebAppWithPrivateEndpoint.bicep"
   az deployment group create `
    --name $env:name `
    --resource-group $env:rg  `
    --template-file  infrastructure/deploy-protectServiceBusWebAppWithPrivateEndpoint.bicep `
    --parameters "{'funcLoc': {'value': 'eastus2'}}" `
                 "{'noManagedIdent': {'value': $noManagedIdent}}" `
                 "{'uniquePrefix': {'value': '$env:uniquePrefix'}}" `
                 "{'repoURL': {'value': '$env:repoURL'}}" `
                 "{'gitHubToken': {'value': '$env:gitToken'}}" `
                 "{'managedIdentityName': {'value': '$env:samiName'}}" `
                 "{'orgURI': {'value': '$env:ORGPATH'}}" `
                 "{'serviceBusConnectionString': {'value': '$env:SERVICE_BUS_CONNECTION_STRING'}}" `
                 "{'clientId': {'value': '$env:AzureAd:ClientId'}}" `
                 "{'clientSecret': {'value': '$env:AzureAd:ClientSecret'}}" `
                 "{'targetAreaPath': {'value': '$env:TARGET_AREA_PATH'}}" `
                 "{'tenantId': {'value': '$env:tenantId'}}" `
                 "{'samiObjectId': {'value': '$env:samiObjectId'}}" `
                 "{'appConfigEndpoint': {'value': '$env:appConfigEndpoint'}}"
   write-output "end deploy"
   popd
   End commands to deploy this file using Azure CLI with PowerShell

   New-AzResourceGroupDeployment -name "protectServiceBusWebAppWithPrivateEndpoint" -Mode "Incremental"  -TemplateFile deploy-protectServiceBusWebAppWithPrivateEndpoint.bicep

   emacs ESC 2 F10
   Begin commands to shut down this deployment using Azure CLI with PowerShell
   write-output "Step 2: Begin shutdown delete (contents only) Resource Group $env:rg $(Get-Date)"
   $kv=(Get-AzResource `
    -ResourceGroupName $env:rg `
    -ResourceType Microsoft.KeyVault/vaults  |  `
    Select-Object -ExpandProperty Name)
  If (![string]::IsNullOrEmpty($kv)) {
     write-output "keyvault=$kv"
     write-output "az keyvault delete --name '$($env:uniquePrefix)-kv' -g '$env:rg'"
     az keyvault delete `
      --name "$($env:uniquePrefix)-kv" `
      -g "$env:rg"
     write-output "az keyvault purge --name `"$($env:uniquePrefix)-kv`" --location $env:loc"
     az keyvault purge `
      --name "$($env:uniquePrefix)-kv" `
      --location $env:loc 
   } Else {
     write-output "No key vault to delete & purge"
   }
   write-output "Begin shutdown"
   write-output "az deployment group create --mode complete --template-file ./clear-resources.json --resource-group $env:rg"
   az deployment group create --mode complete --template-file clear-resources.json --resource-group $env:rg
   write-output "showdown is complete"
   End commands to shut down this deployment using Azure CLI with PowerShell

   emacs ESC 3 F10
   Begin commands for one time initializations using Azure CLI with PowerShell
   write-output "step 3"
   write-output "az group create -l $env:loc -n $env:rg"
   az group create -l $env:loc -n $env:rg
   write-output "{`n`"`$schema`": `"https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#`",`n `"contentVersion`": `"1.0.0.0`",`n `"resources`": [] `n}" | Out-File -FilePath clear-resources.json
   End commands for one time initializations using Azure CLI with PowerShell

   az servicebus namespace -n jqo0osm3qxqr-servicebus  -g rg_SBusSndRcvPEP_v-richardsi
   ERROR: 'jqo0osm3qxqr-servicebus' is misspelled or not recognized by the system.

   // skip this step on initial setup! 
   emacs ESC 4 F10
   Begin commands to deploy this file using Azure CLI with PowerShell
   write-output "step 4 delete service bus"
   write-output "Remove-AzServiceBusNamespace -Name $env:serviceBusNS  -ResourceGroupName $env:rg"
   Remove-AzServiceBusNamespace -Name $env:serviceBusNS  -ResourceGroupName $env:rg
   End commands to deploy this file using Azure CLI with PowerShell
   ERROR: 'jqo0osm3qxqr-servicebus' is misspelled or not recognized by the system.

   // Monday May 20 2024 This would be redundant with the bicep if the bicep worked (error: The desired MinimumElasticInstanceCount (0) for the site 'jqo0osm3qxqr-func' must be greater than zero). So this works and is temporary until we can fix the bicep.
   // Tue May 21 10:10 2024 Bicep now works, error resolved.
   // Skip this step. When we use bicep, there is no storage account. I wonder if the bicep needs to create a storage account?
   emacs ESC 5 F10
   Begin commands to deploy this file using Azure CLI with PowerShell
   write-output "step 5 create premium function app"
   write-output "az storage account create --name $env:stgAccount --resource-group $env:rg --location $env:loc --sku Standard_LRS"
   az storage account create --name $env:stgAccount --resource-group $env:rg --location $env:loc --sku "Standard_LRS"
   write-output "az functionapp create --name $env:functionAppName --plan $env:functionAppPlanName --storage-account $env:stgAccount --resource-group $env:rg --runtime 'dotnet-isolated' --runtime-version '6.0' --functions-version '4'"
   az functionapp create --name $env:functionAppName --plan $env:functionAppPlanName --storage-account $env:stgAccount --resource-group $env:rg --runtime "dotnet-isolated" --runtime-version "6.0" --functions-version "4"
   End commands to deploy this file using Azure CLI with PowerShell

   This code will eventually reside in the pipeline yaml
   Tue May 21 10:12 2024: Tried and failed to skip this step with source control in the bicep.
   emacs ESC 6 F10
   Begin commands to deploy this file using Azure CLI with PowerShell
   write-output "step 6 Publish"
   write-output "dotnet publish ../SimpleServiceBusSendReceiveAzureFuncs  --configuration Release  -f net8.0  --self-contained --output ./publish-functionapp"
   dotnet publish ../SimpleServiceBusSendReceiveAzureFuncs  --configuration Release  -f net8.0 --self-contained --output ./publish-functionapp
   End commands to deploy this file using Azure CLI with PowerShell

   This code will eventually reside in the pipeline yaml
   emacs ESC 7 F10
   Begin commands to deploy this file using Azure CLI with PowerShell
   write-output "step 7 zip"
   pushd ./publish-functionapp
   write-output "Compress-Archive -Path .\* -DestinationPath ../publish-functionapp.zip -Force"
   Compress-Archive -Path .\* -DestinationPath ../publish-functionapp.zip -Force
   popd
   End commands to deploy this file using Azure CLI with PowerShell

   https://learn.microsoft.com/en-us/azure/azure-functions/dotnet-isolated-process-guide?tabs=windows

   This code will eventually reside in the pipeline yaml
   emacs ESC 8 F10
   Begin commands to deploy this file using Azure CLI with PowerShell
   write-output "step 8 configure function app"
   # Should we create a Policy Assignment and a Policy Exemption to get past this issue:
   # (RequestDisallowedByPolicy) Resource 'bastion' was disallowed by policy. Policy identifiers: '[{"policyAssignment":
   write-output "az functionapp config appsettings set -g $env:rg -n $env:functionAppName --settings 'WEBSITE_USE_PLACEHOLDER_DOTNETISOLATED=1'"
   az functionapp config appsettings set -g $env:rg -n $env:functionAppName --settings WEBSITE_USE_PLACEHOLDER_DOTNETISOLATED=1
   write-output "az functionapp config set -g $env:rg -n $env:functionAppName --net-framework-version 'v8.0'"
   az functionapp config set -g $env:rg -n $env:functionAppName --net-framework-version v8.0
   write-output "az functionapp config set -g $env:rg -n $env:functionAppName --use-32bit-worker-process false"
   az functionapp config set -g $env:rg -n $env:functionAppName --use-32bit-worker-process false
   write-output "az functionapp config appsettings set --name $env:functionAppName --resource-group $env:rg --settings FUNCTIONS_EXTENSION_VERSION=~4 'APP_CONFIG_ENDPOINT=$env:appConfigEndpoint'"
   az functionapp config appsettings set --name $env:functionAppName --resource-group $env:rg --settings FUNCTIONS_EXTENSION_VERSION=~4 "APP_CONFIG_ENDPOINT=$env:appConfigEndpoint"
   End commands to deploy this file using Azure CLI with PowerShell

  //  emacs ESC Y F10
  //  Write-Output "Step Y - Deploy Function App to a VNet
  //  end commands to set the Function App to be part of a Vnet

   This code will eventually be replace by EV2 resident JSON ARM template that does zipdeploy
   Tue May 21 10:14 2024 This code needs to be executed several times
   emacs ESC 9 F10
   Begin commands to deploy this file using Azure CLI with PowerShell
   write-output "step 9 deploy compiled C# code deployment to azure resource"
   write-output "az functionapp deployment source config-zip -g $env:rg -n $env:functionAppName --src ./publish-functionapp.zip"
   az functionapp deployment source config-zip -g $env:rg -n $env:functionAppName --src ./publish-functionapp.zip
   End commands to deploy this file using Azure CLI with PowerShell

   // this comes from https://learn.microsoft.com/en-us/azure/private-link/create-private-endpoint-cli?toc=%2Fazure%2Fvirtual-network%2Ftoc.json&tabs=dynamic-ip
   emacs ESC 10 F10
   Begin commands to deploy this file using Azure CLI with PowerShell
   write-output "step 10 create a VNET"
   write-output "az network vnet create --resource-group $env:rg --location $env:loc --name $env:vnetName --address-prefixes 10.0.0.0/16 --subnet-name $env:subnetName --subnet-prefixes 10.0.0.0/24"
   az network vnet create --resource-group $env:rg --location $env:loc --name $env:vnetName --address-prefixes 10.0.0.0/16 --subnet-name $env:subnetName --subnet-prefixes 10.0.0.0/24   
   End commands to deploy this file using Azure CLI with PowerShell

   emacs ESC 11 F10
   Begin commands to deploy this file using Azure CLI with PowerShell
   write-output "step 11 create subnet"
   write-output "az network vnet subnet create --resource-group $env:rg --name $env:subnetName --vnet-name $env:vnetName --address-prefixes 10.0.1.0/26"
   az network vnet subnet create --resource-group $env:rg --name $env:subnetName --vnet-name $env:vnetName --address-prefixes 10.0.1.0/26
   End commands to deploy this file using Azure CLI with PowerShell

   Error from Fri May 17 2023 possibly fixed by upgrading azure functionapp from F1 Premium (EP1): ERROR: (BadRequest) Call to Microsoft.Web/sites failed. Error message: SkuCode 'Dynamic' is invalid.
   Tue May 21 10:26 2024: looks like this was fixed with premium function!
   emacs ESC 12 F10
   Begin commands to deploy this file using Azure CLI with PowerShell
   write-output "step 12 get the functionapp and add it to the VNET"
   write-output "az functionapp list --resource-group $env:rg"
   az functionapp list --resource-group $env:rg
   $env:functionapp_id=$(az functionapp list --resource-group $env:rg --query '[].[id]' --output tsv)
   write-output "functionapp=$env:functionapp_id"
   write-output "Use a dynamic IP functionapp id=$($env:functionapp_id)"
   write-output "This takes a while $(Get-Date)"
   write-output "az network private-endpoint create --connection-name $env:peConn --name $env:peFuncName --private-connection-resource-id $env:functionapp_id --resource-group $env:rg --subnet $env:subnetName --group-id sites --vnet-name $env:vnetName"
   az network private-endpoint create --connection-name $env:peConn --name $env:peFuncName --private-connection-resource-id $env:functionapp_id --resource-group $env:rg --subnet $env:subnetName --group-id sites --vnet-name $env:vnetName
   End commands to execute this file using Azure CLI with PowerShell

   Begin next 3 steps are redundant with the bicep code to deploy the diagnostic web app
   emacs ESC 13 F10
   Begin commands to deploy this file using Azure CLI with PowerShell
   write-output "step 13 deploy plan for helloworld .. this is redundant with the bicep code"
   write-output "az appservice plan create -g $env:rg -n $env:uniquePrefix-plan-webapp --sku B1 -l $env:loc"
   az appservice plan create -g $env:rg -n $env:uniquePrefix-plan-webapp --sku B1 -l $env:loc
   End commands to deploy this file using Azure CLI with PowerShell

   emacs ESC 14 F10
   Begin commands to deploy this file using Azure CLI with PowerShell
   write-output "step 14 create webapp helloworld .. this is redundant with the bicep code"
   write-output "az webapp create --name '$($env:uniquePrefix)-webapp' --resource-group $env:rg --plan $env:uniquePrefix-plan-webapp"
   az webapp create --name "$($env:uniquePrefix)-webapp" --resource-group $env:rg --plan $env:uniquePrefix-plan-webapp
   End commands to deploy this file using Azure CLI with PowerShell

   emacs ESC 15 F10
   Begin commands to deploy this file using Azure CLI with PowerShell
   write-output "step 15 deploy webapp helloworld .. this is redundant with the bicep code"
   write-output "az webapp deployment source config --repo-url $env:repoURL --branch master --name '$($env:uniquePrefix)-webapp' --repository-type git --resource-group $env:rg"
   az webapp deployment source config --repo-url $env:repoURL --branch master --name "$($env:uniquePrefix)-webapp" --repository-type git --resource-group $env:rg 
   End commands to deploy this file using Azure CLI with PowerShell
   End 3 steps are redundant with the bicep code to deploy the diagnostic web app

   emacs ESC 16 F10
   Begin commands to deploy this file using Azure CLI with PowerShell
   write-output "step 16 get the webapp and add it to the VNET"
   $env:webapp_id=$(az webapp list --resource-group $env:rg --query '[].[id]' --output tsv)
   write-output "Use a dynamic IP webapp id=$($env:webapp_id)"
   write-output "This takes a while $(Get-Date)"
   write-output "az network private-endpoint create --connection-name $env:peConn --name $env:peWebName --private-connection-resource-id $env:webapp_id --resource-group $env:rg --subnet $env:subnetName --group-id sites --vnet-name $env:vnetName"
   az network private-endpoint create --connection-name $env:peConn --name $env:peWebName --private-connection-resource-id $env:webapp_id --resource-group $env:rg --subnet $env:subnetName --group-id sites --vnet-name $env:vnetName
   End commands to deploy this file using Azure CLI with PowerShell


  //  Begin next 3 steps are redundant with the bicep code to deploy the diagnostic web app
  //  emacs ESC 14 F10
  //  Begin commands to deploy this file using Azure CLI with PowerShell
  //  write-output "step 14 deploy plan for helloworld .. this is redundant with the bicep code"
  //  write-output "az appservice plan create -g $env:rg -n $env:uniquePrefix-plan-webapp --sku B1 -l $env:loc"
  //  az appservice plan create -g $env:rg -n $env:uniquePrefix-plan-webapp --sku B1 -l $env:loc
  //  End commands to deploy this file using Azure CLI with PowerShell

  //  emacs ESC 15 F10
  //  Begin commands to deploy this file using Azure CLI with PowerShell
  //  write-output "step 15 create webapp helloworld .. this is redundant with the bicep code"
  //  write-output "az webapp create --name '$($env:uniquePrefix)-webapp' --resource-group $env:rg --plan $env:uniquePrefix-plan-webapp"
  //  az webapp create --name "$($env:uniquePrefix)-webapp" --resource-group $env:rg --plan $env:uniquePrefix-plan-webapp
  //  End commands to deploy this file using Azure CLI with PowerShell

   emacs ESC X F10
   Begin commands to deploy this file using Azure CLI with PowerShell
   az webapp deployment source config --name '$($env:uniquePrefix)-webapp-helloworld' --resource-group $env:rg --repo-url 'https://github.com/siegfried01/HelloBlazorSvr.git'  --branch master --manual-integration --git-token <your-github-pat>
   End commands to configure the WebApp with GitHub

   emacs ESC 16 F10
   Begin commands to deploy this file using Azure CLI with PowerShell
   # Update - This code needs to specify one person's or a public repo as well as one perosn's token
   write-output "step 16 deploy webapp helloworld .. this is redundant with the bicep code"
   write-output "az webapp deployment source config --repo-url $env:repoURL --branch master --name '$($env:uniquePrefix)-webapp-helloworld' --repository-type git --resource-group $env:rg" 
   az webapp deployment source config --repo-url $env:repoURL --branch master --name "$($env:uniquePrefix)-webapp-helloworld" --repository-type git --resource-group $env:rg
   End commands to deploy this file using Azure CLI with PowerShell
   End 3 steps are redundant with the bicep code to deploy the diagnostic web app

   emacs ESC 17 F10
   Begin commands to deploy this file using Azure CLI with PowerShell
   write-output "step 17 get the webapp and add it to the VNET"
   $env:webapp_id=$(az webapp list --resource-group $env:rg --query '[].[id]' --output tsv)
   write-output "Use a dyanmic IP webapp id=$($env:webapp_id)"
   write-output "This takes a while $(Get-Date)"
   write-output "az network private-endpoint create --connection-name $env:peConn --name $env:peWebName --private-connection-resource-id $env:webapp_id --resource-group $env:rg --subnet $env:subnetName --group-id sites --vnet-name $env:vnetName"
   az network private-endpoint create --connection-name $env:peConn --name $env:peWebName --private-connection-resource-id $env:webapp_id --resource-group $env:rg --subnet $env:subnetName --group-id sites --vnet-name $env:vnetName
   End commands to deploy this file using Azure CLI with PowerShell

   emacs ESC 18 F10
   Begin commands to execute this file using Azure CLI with PowerShell
   write-output "Step 18 does not work on CorpNet"
   write-output "az network bastion create --resource-group $env:rg --name bastion --public-ip-address public-ip --vnet-name $env:vnetName --location $env:loc --allow-preview true"
   az network bastion create --resource-group $env:rg --name bastion --public-ip-address public-ip --vnet-name $env:vnetName --location $env:loc
   End commands to execute this file using Azure CLI with PowerShell

   emacs ESC 19 F10
   Begin commands to execute this file using Azure CLI with PowerShell
   write-output "Step 19 Create private end point for the functionapp"
   write-output "az network public-ip create --resource-group $env:rg --name $env:pipFunctionAppName --sku Standard --zone 1 2 3"
   az network public-ip create --resource-group $env:rg --name $env:pipFunctionAppName --sku Standard --zone 1 2 3
   End commands to execute this file using Azure CLI with PowerShell

   emacs ESC 20 F10
   Begin commands to deploy this file using Azure CLI with PowerShell
   write-output "step 20 get the functionapp and add it to the VNET"
   $env:functionapp_id=$(az functionapp list --resource-group $env:rg --query '[].[id]' --output tsv)
   write-output "Use a dyanmic IP functionapp id=$($env:functionapp_id)"
   write-output "This takes a while $(Get-Date)"
   write-output "az network private-endpoint create --connection-name $env:peConn --name $env:peFuncName --private-connection-resource-id $env:functionapp_id --resource-group $env:rg --subnet $env:subnetName --group-id sites --vnet-name $env:vnetName"
   az network private-endpoint create --connection-name $env:peConn --name $env:peFuncName --private-connection-resource-id $env:functionapp_id --resource-group $env:rg --subnet $env:subnetName --group-id sites --vnet-name $env:vnetName
   End commands to deploy this file using Azure CLI with PowerShell

   emacs ESC 21 F10
   Begin commands to execute this file using Azure CLI with PowerShell
   write-output "Step 21: Create a new private Azure DNS zone with az network private-dns zone create"
   write-output "az network private-dns zone create --resource-group $env:rg --name 'privatelink.azurewebsites.net'"
   az network private-dns zone create --resource-group $env:rg --name "privatelink.azurewebsites.net"
   End commands to execute this file using Azure CLI with PowerShell

   emacs ESC 22 F10
   Begin commands to execute this file using Azure CLI with PowerShell
   write-output "Step 22: Link the DNS zone to the virtual network you created previously with az network private-dns link vnet create."
   write-output "az network private-dns link vnet create  --resource-group $env:rg  --zone-name "privatelink.azurewebsites.net"  --name dns-link  --virtual-network $env:vnetName  --registration-enabled false"
   az network private-dns link vnet create  --resource-group $env:rg  --zone-name "privatelink.azurewebsites.net"  --name dns-link  --virtual-network $env:vnetName  --registration-enabled false
   End commands to execute this file using Azure CLI with PowerShell

   emacs ESC 23 F10
   Begin commands to execute this file using Azure CLI with PowerShell
   write-output "Step 23: Create a DNS zone group with az network private-endpoint dns-zone-group create."
   write-output "az network private-endpoint dns-zone-group create --resource-group $env:rg --endpoint-name $env:peFuncName --name zone-group --private-dns-zone 'privatelink.azurewebsites.net' --zone-name webapp"
   az network private-endpoint dns-zone-group create --resource-group $env:rg --endpoint-name $env:peFuncName --name zone-group --private-dns-zone "privatelink.azurewebsites.net" --zone-name webapp
   End commands to execute this file using Azure CLI with PowerShell

   emacs ESC 24 F10
   Begin commands to execute this file using Azure CLI with PowerShell
   write-output "Step 24: Create a DNS zone group with az network private-endpoint dns-zone-group create."
   write-output "az network private-endpoint dns-zone-group create --resource-group $env:rg --endpoint-name $env:peWebName --name zone-group --private-dns-zone 'privatelink.azurewebsites.net' --zone-name webapp"
   az network private-endpoint dns-zone-group create --resource-group $env:rg --endpoint-name $env:peWebName --name zone-group --private-dns-zone "privatelink.azurewebsites.net" --zone-name webapp
   End commands to execute this file using Azure CLI with PowerShell

   emacs ESC 25 F10
   Begin commands to execute this file using Azure CLI with PowerShell
   write-output "Step 25: To verify the static IP address and the functionality of the private endpoint, a test virtual machine connected to your virtual network is required."
   write-output "Create the virtual machine with az vm create. $(Get-Date)"
   write-output "az vm create --resource-group $env:rg  --name $env:vmName  --image Win2022Datacenter    --vnet-name $env:vnetName  --subnet $env:subnetName  --admin-username azureuser --size $env:VMSize"
   az vm create --resource-group $env:rg  --name $env:vmName  --image Win2022Datacenter --vnet-name $env:vnetName  --subnet $env:subnetName  --admin-username azureuser --admin-password JxQZEwsTc5y0bSIosT7KGa6 --size $env:VMSize
   write-output "Done creating VM $(Get-Date)"
   End commands to execute this file using Azure CLI with PowerShell

   emacs ESC 26 F10
   Begin commands to deploy this file using Azure CLI with PowerShell
   write-output "step 26 webapp tail logs"
   write-output "az webapp log tail -g $env:rg -n $env:functionAppName"
   az webapp log tail -g $env:rg -n $env:functionAppName
   # We should test to see if we get a forbidden message like we should
   End commands to deploy this file using Azure CLI with PowerShell

   emacs ESC 27 F10
   Begin commands to deploy this file using Azure CLI with PowerShell
   write-output "step 27 create premium service bus"
   write-output "az servicebus namespace create --resource-group $env:rg --name $env:serviceBusNS --location $env:loc --sku Premium"
   az servicebus namespace create --resource-group $env:rg --name $env:serviceBusNS --location $env:loc --sku Premium
   End commands to deploy this file using Azure CLI with PowerShell

   emacs ESC 28 F10
   Begin commands to deploy this file using Azure CLI with PowerShell
   write-output "step 28 create service bus queue"
   write-output "az servicebus queue create --resource-group $rg --namespace-name $env:serviceBusNS --name $env:serviceBusQueue"
   az servicebus queue create --resource-group $env:rg --namespace-name $env:serviceBusNS --name $env:serviceBusQueue
   End commands to deploy this file using Azure CLI with PowerShell

   emacs ESC 29 F10
   Begin commands to deploy this file using Azure CLI with PowerShell
   write-output "step 29 create private end point for service bus"
   write-output "az network private-endpoint create --name $env:peWebName --resource-group $env:rg --vnet-name your-vnet-name --subnet $env:subnetName --private-connection-resource-id (az servicebus namespace show --resource-group $env:rg --name $env:serviceBusNS --query id --output tsv) --connection-name $env:peConn"
   az network private-endpoint create --name $env:peWebName --resource-group $env:rg --vnet-name your-vnet-name --subnet $env:subnetName --private-connection-resource-id $(az servicebus namespace show --resource-group $env:rg --name $env:serviceBusNS --query id --output tsv) --connection-name $env:peConn
   End commands to deploy this file using Azure CLI with PowerShell

   emacs ESC 30 F10
   Begin commands to deploy this file using Azure CLI with PowerShell
   write-output "step 30 create private end point for service bus"
   write-output "az network private-endpoint create --name $env:peWebName --resource-group $env:rg --vnet-name your-vnet-name --subnet $env:subnetName --private-connection-resource-id (az servicebus namespace show --resource-group $env:rg --name $env:serviceBusNS --query id --output tsv) --connection-name $env:peConn"
   az network private-endpoint create --name $env:peWebName --resource-group $env:rg --vnet-name your-vnet-name --subnet $env:subnetName --private-connection-resource-id $(az servicebus namespace show --resource-group $env:rg --name $env:serviceBusNS --query id --output tsv) --connection-name $env:peConn
   End commands to deploy this file using Azure CLI with PowerShell

   emacs ESC 31 F10
   Begin commands to deploy this file using Azure CLI with PowerShell
   write-output "step 31 get the logs This is not working and I don't now why"
   write-output "curl -X GET 'https://$($env:uniquePrefix)-func.scm.azurewebsites.net/api/dump'"
   curl  "https://$($env:uniquePrefix)-func.scm.azurewebsites.net/api/dump"
   dir
   End commands to deploy this file using Azure CLI with PowerShell

   emacs ESC 32 F10
   Begin commands to deploy this file using Azure CLI with PowerShell
   write-output "step 32 Create a Key Vault for the Client Secret"
   write-output "az keyvault create --name $env:keyVaultName --resource-group $env:rg --location eastus"
   az keyvault create --name $env:keyVaultName --resource-group $env:rg --location eastus
   End commands to deploy this file using Azure CLI with PowerShell

   Begin common epilog commands
   #Get-AzResource -ResourceGroupName $env:rg | ft
   az resource list -g $env:rg --query "[?resourceGroup=='$env:rg'].{ name: name, flavor: kind, resourceType: type, region: location }" --output table | ForEach-Object { $_ -replace "`r", ""}
   write-output "all done $(Get-Date)"
   End common epilog commands


 */

param queueName string = 'mainqueue001'
param loc string = resourceGroup().location
param funcLoc string = loc
param noManagedIdent bool = false
param uniquePrefix string = uniqueString(resourceGroup().id)
param sbdemo001NS_name string = '${uniquePrefix}-servicebus'
param managedIdentityName string = 'sami-${uniquePrefix}'
param appConfigName string = 'appcs-${uniquePrefix}'    // Add -new to the end if this initial attempt fails
param repoURL string
param gitHubToken string
param keyVaultName string = 'kv-${uniquePrefix}'
param appInsightsName string = '${uniquePrefix}-appins'
param storageAccountName string = '${uniquePrefix}stg'
param appServicePlanName string = 'appService-${uniquePrefix}'
param functionAppName string = '${uniquePrefix}-func'
param applicationInsightsName string = '${uniquePrefix}-appins'
param vnetName string = '${uniquePrefix}-vnet'
param subnetName string = 'subnet-Bastion'

param orgURI string

@secure()
param serviceBusConnectionString string

param appConfigEndpoint string

param targetAreaPath string
param clientId string
param tenantId string

@secure()
param clientSecret string

@description('Specifies the User Assigned Managed Identity ID')
param uamiId string = ''

@description('Specifies the System Assigned Managed Identity name')
param samiId string = ''
param samiObjectId string = ''

// Define tags
param tags object = {
  environment: 'Owner'
  owner: 'Sbox360'
}

@description('A Key Vault to serve AutoS360.')
param objectId string = 'your-object-id'

resource sbnsSimpleSendReceiveDemo 'Microsoft.ServiceBus/namespaces@2022-01-01-preview' = {
  name: sbdemo001NS_name
  location: loc
  sku: {
    name: 'Premium'
    tier: 'Premium'
  }
  properties: {
    minimumTlsVersion: '1.0'
    publicNetworkAccess: 'Enabled'
    disableLocalAuth: false
    zoneRedundant: false
  }
  // scope: resourceGroup()
  tags: tags
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
    ipRules: [
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
    ]
    trustedServiceAccessEnabled: true
  }  
}

@description('Defines a Service Bus Queue')
resource sbQueue 'Microsoft.ServiceBus/namespaces/queues@2022-01-01-preview' = {
  parent: sbnsSimpleSendReceiveDemo
  name: queueName
  properties: {
    maxMessageSizeInKilobytes: 1024
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

@description('Enables a System Managed Identity on a Function App')
resource functionAppIdentity 'Microsoft.Web/sites/identity@2022-03-01' = {
  parent: ServiceBusSenderReceiverFunctions
  name: 'default'
  properties: {
    type: 'SystemAssigned'
  }
}

@description('Retrieves the Principal ID for the Function App\'s System Asssigned Managed Identity')
resource retrieveFunctionApp 'Microsoft.Web/sites@2022-03-01' existing = {
  name: functionAppName
}

@description('Define the Role Assignment')
resource roleAssignment 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  scope: sbnsSimpleSendReceiveDemo
  // name: guid(retrieveFunctionApp.identity.principalId, 'bfae5ec4-568b-4b3b-8784-60d5c47fb7aa') // Generate a GUID for the role assignment
  name: 'Service Bus Data Receiver Role'
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'bfae5ec4-568b-4b3b-8784-60d5c47fb7aa') // Service Bus Data Receiver role ID
    principalId: retrieveFunctionApp.identity.principalId
    principalType: 'ServicePrincipal'
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

// We should check to see if we still need this
// Apparently not. The Service Bus Connection String
// references shall be removed.
output serviceBusConnectionString string = serviceBusConnection

output busNS string = sbdemo001NS_name
output queue string = sbQueue.name
output noManagedIdentoutput bool = noManagedIdent
output serviceBusNamespaceId string = sbnsSimpleSendReceiveDemo.id
output principalId string = retrieveFunctionApp.identity.principalId



param ServiceBusSenderReceiverFuncs string = '${uniquePrefix}-func'

@description('Defines the App Service Plan for the Function App')
resource functionPlan 'Microsoft.Web/serverfarms@2023-01-01' = {
  name: '${uniquePrefix}-func-plan'
  location: funcLoc
  sku: {
    name: 'EP1'  // Elastic Premium
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
  tags: tags
}

@description('Specifies the App Configuration')
resource appConfig 'Microsoft.AppConfiguration/configurationStores@2022-05-01' = {
  name: appConfigName
  location: loc
  sku: {
    name: 'Standard'
  }
  properties: {}
  tags: tags
}

// We have to create the Managed Identity first

@description('Defines the Access Policy for the App Configuration')
resource appConfigAccessPolicy 'Microsoft.AppConfiguration/configurationStores/accessPolicies@2022-05-01' = {
  parent: appConfig
  name: 'appcs-veyf0f1ncz4i-access-policy'
  properties: {
    // principalId: managedIdentity.properties.principalId
    role: 'Reader'
  }
}

@description('Defines the URI for the Azure DevOps Organization')
resource orgUriKeyValue 'Microsoft.AppConfiguration/configurationStores/keyValues@2022-05-01' = {
  parent: appConfig
  name: 'appcs-orgUri'
  properties: {
    value: orgURI // This will need to be passed in from the pipeline
    contentType: 'text/plain'
    tags: {
      // environment: 'production'
    }
  }
}

// Mark this for deletion - We are not using Service Bus Connection Strings anymore
@description('Defines the Service Bus Connection String')
resource sbConnectionStringKeyValue 'Microsoft.AppConfiguration/configurationStores/keyValues@2022-05-01' = {
  parent: appConfig
  name: 'appcs-serviceBusConnectionString'
  properties: {
    value: serviceBusConnectionString
    contentType: 'text/plain'
    tags: {
      
    }
  }
}

@description('Defines the Client ID for the App Registration')
resource clientIdKeyValue 'Microsoft.AppConfiguration/configurationStores/keyValues@2022-05-01' = {
  parent: appConfig
  name: 'appcs-clientId'
  properties: {
    value: clientId
    contentType: 'text/plain'
    tags: {
      
    }
  }
}

@description('Defines the Client Secret for the App Registration')
resource clientSecretKeyValue 'Microsoft.AppConfiguration/configurationStores/keyValues@2022-05-01' = {
  parent: appConfig
  name: 'appcs-clientSecret'
  properties: {
    value: clientSecret
    contentType: 'text/plain'
    tags: {
      
    }
  }
}

@description('Defines the Target Area Path')
resource targetAreaPathKeyValue 'Microsoft.AppConfiguration/configurationStores/keyValues@2022-05-01' = {
  parent: appConfig
  name: 'appcs-targetAreaPath'
  properties: {
    value: targetAreaPath
    contentType: 'text/plain'
    tags: {
      
    }
  }
}

@description('Defines the Tenant ID')
resource tenantIdPathKeyValue 'Microsoft.AppConfiguration/configurationStores/keyValues@2022-05-01' = {
  parent: appConfig
  name: 'appcs-tenantId'
  properties: {
    value: tenantId
    contentType: 'text/plain'
    tags: {
      
    }
  }
}



// The following will be commented out until the Sbox360 user accounts have access
// to perform User Asisgned Identity assignments
@description('Specifies the System Assigned Managed Identity name')
// Why does the MSI have to be existing?
// Apparently, we HAVE to define it before we build our architecture.
// This is possibly due to the rights issue on performing UAMI assignments.
// Which means the Resource Group will have to be defined first.
resource managedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30'  existing = { 
  name: managedIdentityName
}

@description('Defines a Function App')
resource ServiceBusSenderReceiverFunctions 'Microsoft.Web/sites@2023-01-01' = {
  name: ServiceBusSenderReceiverFuncs
  location: funcLoc
  kind: 'functionapp'
  identity:{
    // UserAssigned cannot be used unless userAssignedIdentities has something in it
    // Add UserAssigned when this permission issue is fixed
    type: 'SystemAssigned'  // SystemAssigned may have to be removed
    // We are commenting this line out until the Sbox360 user accounts have access
    // to perform User Asisgned Identity assignments
    // userAssignedIdentities: {
    //   '${managedIdentity.id}': {}
    // }
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
      minimumElasticInstanceCount: 1
      appSettings: [
        {
          name: 'busNS'
          value: sbdemo001NS_name
        }
        {
          name: 'queue'
          value: queueName
        }
        {
          name: 'FUNCTIONS_EXTENSION_VERSION'
          value: '~4'
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
  // resource sourcecontrol 'sourcecontrols@2020-12-01' = {
  //   name: 'web'
  //   properties: {
  //     repoUrl: 'https://github.com/siegfried01/SimplerServiceBusSendReceiveDemo.git'
  //     branch: 'master'
  //     isManualIntegration: false      
  //   }
  // }  
  tags: tags
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
    publishingUsername: '$iqa5jvm-func'
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
    minimumElasticInstanceCount: 1
    azureStorageAccounts: {}
  }
}

// The old hex string was 73236288f08d4694a60c7016deb6b26b
resource sites_SimpleServiceBusReceiverAzureFuncs_name_d63761cb0e724e63d88961595f189b54 'Microsoft.Web/sites/deployments@2023-01-01' = {
  parent: ServiceBusSenderReceiverFunctions
  name: 'd63761cb0e724e63d88961595f189b54'
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
  name: '${ServiceBusSenderReceiverFuncs}.azurewebsites.net'
  properties: {
    siteName: 'SimpleServiceBusReceiverAzureFuncs'
    hostNameType: 'Verified'
  }
}

// Create a Storage Account?
@description('Defines a Storage Account')
resource storageAccount 'Microsoft.Storage/storageAccounts@2021-06-01' = {
  name: storageAccountName
  location: resourceGroup().location
  kind: 'StorageV2'
  sku: {
    name: 'Standard_LRS'
  }
  tags: tags
}

resource blobContainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2021-04-01' = {
  name: '${storageAccount.name}/default/myfunctions'
  dependsOn: [
    storageAccount
  ]
}

@description('Defines the App Service Plan')
resource appServicePlan 'Microsoft.Web/serverfarms@2021-03-01' = {
  name: appServicePlanName
  location: resourceGroup().location
  sku: {
    name: 'P1v2' // This is an example of a Premium v2 tier
    // Y1 is for dynamic (consumption) plans
  }
  properties: {
    reserved: false // Set to true if running on a Linux host
  }
  tags: tags
}

// resource functionApp 'Microsoft.Web/sites@2021-03-01' = {
//   name: functionAppName
//   location: resourceGroup().location
//   kind: 'functionapp'
//   properties: {
//     serverFarmId: appServicePlan.id
//     siteConfig: {
//       appSettings: [
//         {
//           name: 'AzureWebJobsStorage'
//           value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccount.name};AccountKey=${listKeys(storageAccount.id, '2021-06-01').keys[0].value};EndpointSuffix=${environment().suffixes.storage}'
//         }
//         {
//           name: 'FUNCTIONS_WORKER_RUNTIME'
//           value: 'dotnet' // Set this according to your runtime: dotnet, node, python, etc.
//         }
//         {
//           name: 'WEBSITE_RUN_FROM_PACKAGE'
//           value: '1'
//         }
//         {
//           name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
//           value: applicationInsights.properties.ConnectionString
//         }
//       ]
//     }
//   }
// }

@description('Defines the App Insights instance for the Function App')
resource applicationInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: applicationInsightsName
  location: resourceGroup().location
  kind: 'web'
  properties: {
    Application_Type: 'web'
  }
  tags: tags
}

module  assignRoleToFunctionApp 'assignRbacRoleToFunctionApp.bicep' = if (!noManagedIdent) {
  name: 'assign-role-to-functionApp'
  params: {
	roleScope: resourceGroup().id
	functionAppName: ServiceBusSenderReceiverFunctions.name
    functionPrincipalId: ServiceBusSenderReceiverFunctions.identity.principalId
  }
}

// --- temporary webapp to demostrate private end points are working

@description('The name of the web app that you wish to create.')
param siteName string = '${uniquePrefix}-webapp-helloworld'

@description('The name of the App Service plan to use for hosting the Hello World Web App.')
param hostingPlanName string = '${uniquePrefix}-plan-helloworld'

@description('The pricing tier for the hosting plan.')
@allowed([
  'F1'
  'D1'
  'B1'
  'B2'
  'B3'
  'S1'
])
param sku string = 'B1'

//@description('The URL for the GitHub repository that contains the project to deploy.')
//param repoURL string = 'https://github.com/siegfried01/HelloBlazorSvr.git'
// 'https://github.com/Azure-Samples/azure-event-grid-viewer.git'

@description('The branch of the GitHub repository to use.')
param branch string = 'master'

@description('Location for all resources.')
param location string = resourceGroup().location

resource hostingPlan 'Microsoft.Web/serverfarms@2020-12-01' = {
  name: hostingPlanName
  location: location
  sku: {
    name: sku
    capacity: 0
  }
  properties: {
    // name: hostingPlanName
  }
  tags: tags
}

resource site 'Microsoft.Web/sites@2020-12-01' = {
  name: siteName
  location: location
  properties: {
    serverFarmId: hostingPlanName
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
  dependsOn: [
    hostingPlan
  ]
  tags: tags
}

// resource siteName_web 'Microsoft.Web/sites/sourcecontrols@2020-12-01' = {
//   parent: site
//   name: 'web'
//   properties: {
//     repoUrl: repoURL
//     branch: branch
//     isManualIntegration: false
//     // A token is needed for this
//     gitHubActionConfiguration: {
//         token: gitHubToken
//     }
//   }
// }

@description('Describe a Key Vault.')
resource keyVault 'Microsoft.KeyVault/vaults@2021-06-01-preview' = {
  // We need to include dependsOn

  name: keyVaultName
  location: loc
  properties: {
    sku: {
      family: 'A'
      name: 'standard'
    }
    tenantId: tenantId
    accessPolicies: [
      {
        tenantId: tenantId
        objectId: samiObjectId
        permissions: {
          keys: [
            'get'
            'list'
            'create'
            'delete'
            'recover'
            'backup'
            'restore'
            'import'
            'update'
            'sign'
            'verify'
            'wrapKey'
            'unwrapKey'
          ]
          secrets: [
            'get'
            'list'
            'set'
            'delete'
            'recover'
            'backup'
            'restore'
          ]
          certificates: [
            'get'
            'list'
            'delete'
            'create'
            'import'
            'update'
            'managecontacts'
            'getissuers'
            'listissuers'
            'setissuers'
            'deleteissuers'
            'manageissuers'
          ]
        }
      }
      // We need to define web[0] and web[1]
      // Or maybe not, we aren't deploying web apps right now
      {
        tenantId: tenantId
        // We need the Managed Identity Service Principal
        // objectId: principalId
        objectId: samiId
        permissions: {
          // Secrets are referenced by and enumerated in App Configuration so 'list' is not necessary.
          secrets: [
            'get'
          ]
        }
      }
    ]
  }
}

output keyVaultId string = keyVault.id

output appServiceEndpoint string = 'https://${site.properties.hostNames[0]}'
