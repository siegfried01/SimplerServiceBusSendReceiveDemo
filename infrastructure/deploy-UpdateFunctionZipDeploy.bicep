/*
   From a (cygwin) bash prompt, use this perl one-liner to extract the powershell script fragments and exeucte them. This example shows how to execute steps 2 (shutdown) and steps 4-13 and skipping steps 7,8,9 because they don't work (yet). Adjust that list of steps according to your needs.

  See https://learn.microsoft.com/en-us/answers/questions/1689513/msdeploy-causes-error-failed-to-download-package-s
  zip deploy vs msdeploy https://github.com/projectkudu/kudu/wiki/MSDeploy-VS.-ZipDeploy
  // https://github.com/Azure-Samples/function-app-arm-templates/blob/main/zip-deploy-arm-az-cli/README.md#steps


   powershell -executionPolicy unrestricted -Command - <<EOF
   `perl -lne 'sub range {$b=shift; $e=shift; $r=""; for(($b..$e)){ $r=$r."," if $r; $r=$r.$_;} $r } BEGIN {  $_ = shift; s/([0-9]+)-([0-9]+)/range($1,$2)/e; @idx=split ","; $c=0; $x=0; $f=0; $s=[] } $c++ if /^\s*Begin/; if (/^\s*End/) {$c--;$s[$f++]=""}; if ($x+$c>1) { $s->[$f]=$s->[$f].$_."\n"  } $x=$c; END { push(@idx, $#s); unshift @idx,0; for (@idx) { $p=$s->[$_]; chomp $p; print $p } }' "2,4-6,10-13" < "Az CLI commands for deployment using ARM Template.bicep"  `
EOF

   Begin common prolog commands
   $env:subscriptionId=(az account show --query id --output tsv | ForEach-Object { $_ -replace "`r", ""})
   If ($env:USERNAME -eq "shein") { $env:name='SBusSndRcv' } else { $env:name="SBusSndRcv_$($env:USERNAME)" }
   $env:rg="rg_$($env:name)"
   $env:loc=If ($env:AZ_DEFAULT_LOC) { $env:AZ_DEFAULT_LOC} Else {'eastus2'}
   $env:uniquePrefix="$(If ($env:USERNAME -eq "v-richardsi") {"eizdf"} ElseIf ($env:USERNAME -eq "v-paperry") { "iucpl" } ElseIf ($env:USERNAME -eq "shein") {"iqa5jvm"} Else { "jyzwg" } )"
   $env:deployStorageAccountName="$($env:uniquePrefix)dplystg"
   $env:stgContainer="deployfunc"
   $env:functionAppName="$($env:uniquePrefix)-func"
   $env:funcPlanName="$($env:uniquePrefix)-plan-func"
   $env:serviceBusNS="$($env:uniquePrefix)-servicebus"
   $env:logAnalyticsWS= If ($env:USERNAME -eq "shein") { "/subscriptions/acc26051-92a5-4ed1-a226-64a187bc27db/resourceGroups/DefaultResourceGroup-WUS2/providers/Microsoft.OperationalInsights/workspaces/DefaultWorkspace-acc26051-92a5-4ed1-a226-64a187bc27db-WUS2" } else {   "/subscriptions/13c9725f-d20a-4c99-8ef4-d7bb78f98cff/resourceGroups/defaultresourcegroup-wus2/providers/microsoft.operationalinsights/workspaces/defaultworkspace-13c9725f-d20a-4c99-8ef4-d7bb78f98cff-wus2" }
   $StartTime = $(get-date)
   End common prolog commands

   emacs F10
   Begin commands to deploy this file using Azure CLI with PowerShell
   az deployment group create --name $env:name --resource-group $env:rg --mode Incremental `
     --template-file  "deploy-UpdateFunctionZipDeploy.bicep" `
     --parameters "{'uniquePrefix': {'value': '$env:uniquePrefix'}}" `
     "{'deployStorageAccountName': {'value': '$env:deployStorageAccountName'}}"                          `
     "{'packageUri': {'value': '$env:sasUrl'}}" `
     | ForEach-Object { $_ -replace "`r", ""} `
   write-output "end deploy $(Get-Date)"
   End commands to deploy this file using Azure CLI with PowerShell

   emacs ESC 2 F10
   Begin commands to shut down this deployment using Azure CLI with PowerShell
   write-output "begin shutdown delete (contents only) of $env:rg $(Get-Date)"
   az deployment group create --mode complete --template-file ./clear-resources.json --resource-group $env:rg  | ForEach-Object { $_ -replace "`r", ""}
   write-output "showdown is complete $env:rg $(Get-Date)" 
   End commands to shut down this deployment using Azure CLI with PowerShell

   emacs ESC 3 F10
   Begin commands for one time initializations using Azure CLI with PowerShell
   write-output "Step 3: Create resource group $env:rg $(Get-Date)"
   write-output "az group create -l $env:loc -n $env:rg"
   az group create -l $env:loc -n $env:rg
   End commands for one time initializations using Azure CLI with PowerShell

   emacs ESC 4 F10
   Begin commands to deploy this file using Azure CLI with PowerShell
   write-output "step 4 delete resource group"
   write-output "az group delete -n $env:rg --yes"
   az group delete  -n $env:rg --yes
   End commands to deploy this file using Azure CLI with PowerShell
   
   emacs ESC 5 F10
   Begin commands to deploy this file using Azure CLI with PowerShell
   write-output "Step 5: Upddate the built at timestamp in the source code (ala ChatGPT)"
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
     $content = [regex]::Replace($content, $regex, "Built at $currentDateTime")
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
       write-output $content
       Set-Content -Path $filePath -Value $content
       if ($dateUpdated -and $versionUpdated) {
         write-output "Date and version updated and file saved successfully in $filePath."
       } ElseIf ( $dateUpdated )  {
         write-output "Only Date updated and file saved successfully in $filePath."
       } Else {
         write-output "Only version updated and file saved successfully in $filePath."
       }
   } else {
      Write-Output "No updates made to the file."
   }   
   End commands to deploy this file using Azure CLI with PowerShell

   emacs ESC 6 F10
   Begin commands to deploy this file using Azure CLI with PowerShell
   write-output "step 6 Publish"
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

   emacs ESC 7 F10
   Begin commands to deploy this file using Azure CLI with PowerShell
   write-output "step 7 zip"
   $path = "publish-functionapp.zip"
   if (Test-Path -LiteralPath $path) {
       write-output "Deleting $path"
       Remove-Item -LiteralPath $path
   } else {
      write-output "$path doesn't exist: create it"
   }
   pushd ./publish-functionapp
   write-output "Compress-Archive -Path .\* -DestinationPath ../publish-functionapp.zip -Force"
   Compress-Archive -Path .\* -DestinationPath ../publish-functionapp.zip -Force
   End commands to deploy this file using Azure CLI with PowerShell

   emacs ESC 8 F10
   Begin commands to deploy this file using Azure CLI with PowerShell
   write-output "Step 8 create service principal"
   write-output "az ad sp create-for-rbac --name $env:functionAppName --role contributor --scopes '/subscriptions/$($env:subscriptionId)/resourceGroups/$env:rg' --sdk-auth"
   az ad sp create-for-rbac --name $env:functionAppName --role contributor --scopes "/subscriptions/$($env:subscriptionId)/resourceGroups/$env:rg" --sdk-auth  
   End commands to deploy this file using Azure CLI with PowerShell

   emacs ESC 9 F10
   Begin commands to deploy this file using Azure CLI with PowerShell
   write-output "Step 9 create storage account $env:deployStorageAccountName"
   write-output "az storage account create -n $env:deployStorageAccountName -g $env:rg --access-tier cool --sku Standard_LRS"
   az storage account create -n $env:deployStorageAccountName -g $env:rg   --access-tier cool --sku Standard_LRS
   End commands to deploy this file using Azure CLI with PowerShell

   emacs ESC 10 F10
   Begin commands to deploy this file using Azure CLI with PowerShell
   write-output "Step 10 create storage container $env:stgContainer in account $env:deployStorageAccountName"
   $env:conn=(az storage account show-connection-string --name $env:deployStorageAccountName --resource-group $env:rg | jq '.connectionString')
   write-output "az storage container create -n $env:stgContainer --account-name $env:deployStorageAccountName"
   az storage container create -n $env:stgContainer --account-name $env:deployStorageAccountName  --connection-string $env:conn
   End commands to deploy this file using Azure CLI with PowerShell

   emacs ESC 11 F10
   Begin commands to deploy this file using Azure CLI with PowerShell
   write-output "Step 11 confirm container has been created"
   $env:conn=(az storage account show-connection-string --name $env:deployStorageAccountName --resource-group $env:rg | jq '.connectionString')
   write-output "az storage container list --account-name $env:deployStorageAccountName  --connection-string $env:conn --output table"
   az storage container list --account-name $env:deployStorageAccountName  --connection-string $env:conn --output table
   write-output "az storage container show --account-name $env:deployStorageAccountName  --connection-string $env:conn -n $env:stgContainer"
   az storage container show --account-name $env:deployStorageAccountName  --connection-string $env:conn -n $env:stgContainer
   write-output "az storage container show-permission --account-name $env:deployStorageAccountName  --connection-string $env:conn -n $env:stgContainer"
   az storage container show-permission --account-name $env:deployStorageAccountName  --connection-string $env:conn -n $env:stgContainer
   End commands to deploy this file using Azure CLI with PowerShell

   emacs ESC 12 F10
   Begin commands to deploy this file using Azure CLI with PowerShell
   write-output "Step 12 upload zip to blob"
   $env:conn=(az storage account show-connection-string --name $env:deployStorageAccountName --resource-group $env:rg | jq '.connectionString')
   write-output "conn=$($env:conn)"
   write-output "az storage blob upload -f publish-functionapp.zip --account-name $env:deployStorageAccountName  -c $env:stgContainer -n "package_zip" --overwrite true  --connection-string $env:conn"
   az storage blob upload -f publish-functionapp.zip --account-name $env:deployStorageAccountName  -c $env:stgContainer -n "package_zip" --overwrite true  --connection-string $env:conn
   End commands to deploy this file using Azure CLI with PowerShell

   Run your functions from a package file in Azure https://learn.microsoft.com/en-us/azure/azure-functions/run-functions-from-deployment-package#enable-functions-to-run-from-a-package
   Integration with zip deployment https://learn.microsoft.com/en-us/azure/azure-functions/run-functions-from-deployment-package#integration-with-zip-deployment
   Zip deployment for Azure Functions https://learn.microsoft.com/en-us/azure/azure-functions/deployment-zip-push
   emacs ESC 13 F10
   Begin commands to deploy this file using Azure CLI with PowerShell
   write-output "Step 13 update appsettings WEBSITE_RUN_FROM_PACKAGE=1"
   write-output "az functionapp config appsettings set -n $env:functionAppName -g $env:rg --settings 'WEBSITE_RUN_FROM_PACKAGE=1'"
   az functionapp config appsettings set -n $env:functionAppName -g $env:rg --settings "WEBSITE_RUN_FROM_PACKAGE=1"
   End commands to deploy this file using Azure CLI with PowerShell

   emacs ESC 14 F10
   Begin commands to deploy this file using Azure CLI with PowerShell
   write-output "Step 14 generate blob SAS and deploy"
   $env:conn=(az storage account show-connection-string --name $env:deployStorageAccountName --resource-group $env:rg | jq '.connectionString')
   write-output "az storage blob generate-sas --full-uri --permissions acdeimrtwx --expiry (get-date).AddMinutes(60).ToString('yyyy-MM-ddTHH:mm:ssZ') --account-name $env:deployStorageAccountName -c $env:stgContainer -n package_zip --https-only --output tsv"
   $env:sasUrl=(az storage blob generate-sas --full-uri --permissions acdeimrtwx --expiry (get-date).AddMinutes(60).ToString("yyyy-MM-ddTHH:mm:ssZ") --account-name $env:deployStorageAccountName -c $env:stgContainer -n package_zip  --connection-string $env:conn --https-only --output tsv)
   write-output "sasUrl=$($env:sasUrl)"
   $path = "downloaded.zip"
   if (Test-Path -LiteralPath $path) {
       write-output "Deleting $path"
       Remove-Item -LiteralPath $path
   } else {
      write-output "$path doesn't exist: create it"
   }
   write-output "az storage blob download --account-name $env:deployStorageAccountName -n $env:stgContainer -f $path --blob-url `$env:sasUrl"
   az storage blob download --account-name $env:deployStorageAccountName -n $env:stgContainer -f downloaded.zip --blob-url $env:sasUrl
   write-output "Get-ChildItem"
   Get-ChildItem
   $env:sasUrl =  $env:sasUrl -replace '&', '%26'
   write-output "escaped sasUrl=$($env:sasUrl)"
   az deployment group create --name $env:name --resource-group $env:rg --mode Incremental --template-file  "deploy-UpdateFunctionZipDeploy.bicep" --parameters "{'blobSASUri': {'value': '$env:sasUrl'}}" "{'functionAppName': {'value': '$env:functionAppName'}}" | ForEach-Object { $_ -replace "`r", ""}
   End commands to deploy this file using Azure CLI with PowerShell


   ERROR: {
     "status": "Failed",
     "error": {
       "code": "DeploymentFailed",
       "target": "/subscriptions/acc26051-92a5-4ed1-a226-64a187bc27db/resourceGroups/rg_UpdateFunctionZipDeploy_shein/providers/Microsoft.Resources/deployments/UpdateFunctionZipDeploy_shein",
       "message": "At least one resource deployment operation failed. Please list deployment operations for details. Please see https://aka.ms/arm-deployment-operations for usage details.",
       "details": [
         {
           "code": "ResourceDeploymentFailure",
           "target": "/subscriptions/acc26051-92a5-4ed1-a226-64a187bc27db/resourceGroups/rg_UpdateFunctionZipDeploy_shein/providers/Microsoft.Web/sites/zipdeployhttpfunc20240529150920/extensions/ZipDeploy",
           "message": "The resource write operation failed to complete successfully, because it reached terminal provisioning state 'Failed'."
         }
       ]
     }
   }


   emacs ESC 15 F10
   Begin commands to deploy this file using Azure CLI with PowerShell
   write-output "Step 15 confirm containers."
   $env:conn=(az storage account show-connection-string --name $env:deployStorageAccountName --resource-group $env:rg | jq '.connectionString')
   write-output "az storage container list  --account-name $env:deployStorageAccountName"
   az storage container list --account-name $env:deployStorageAccountName  --connection-string $env:conn
   End commands to deploy this file using Azure CLI with PowerShell

   emacs ESC 16 F10
   Begin commands to deploy this file using Azure CLI with PowerShell
   write-output "Step 16 manual deploy, this prompts for a passwoprd and does not work."
   write-output "curl -X POST -u sheintze https://zipdeployhttpfunc20240529150920.scm.azurewebsites.net/api/zipdeploy -T publish-functionapp.zip"
   curl -X POST -u sheintze https://zipdeployhttpfunc20240529150920.scm.azurewebsites.net/api/zipdeploy -T publish-functionapp.zip
   End commands to deploy this file using Azure CLI with PowerShell

   emacs ESC 17 F10
   Begin commands to deploy this file using Azure CLI with PowerShell
   write-output "Step 17 manual deploy"
   $publishUrl = "https://zipdeployhttpfunc20240529150920.scm.azurewebsites.net/msdeploy.axd?site=<yourappname>"
   $zipPath = "publish-functionapp.zip"
   $deployUser = "sheintze@hotmail.com"
   $deployPassword = "\"
   "C:\Program Files (x86)\IIS\Microsoft Web Deploy V3\msdeploy.exe" -verb:sync -source:package="$zipPath" -dest:auto,computerName="$publishUrl",userName="$deployUser",password="$deployPassword",authtype="Basic"
   End commands to deploy this file using Azure CLI with PowerShell

   emacs ESC 18 F10
   Begin commands to deploy this file using Azure CLI with PowerShell
   write-output "curl -X GET 'https://zipdeployhttpfunc20240529150920.azurewebsites.net/api/zipdeployhttpfunc?code=n4uvzuVpQ5iOuEMSSROOSKMD-oW7wBPKfYoEMdA9TQh5AzFuvby8Bg%3D%3D&name=siegfried'"
   curl -X GET "https://zipdeployhttpfunc20240529150920.azurewebsites.net/api/zipdeployhttpfunc?code=n4uvzuVpQ5iOuEMSSROOSKMD-oW7wBPKfYoEMdA9TQh5AzFuvby8Bg%3D%3D&name=siegfried"
   write-output "Built at Fri May 31 05:52:32 2024 Hello, siegfried. This HTTP triggered function executed successfully.2024 Jun 03 12:45:03.216 AM (+00:00)Name   "
   End commands to deploy this file using Azure CLI with PowerShell

   emacs ESC 19 F10
   Begin commands to deploy this file using Azure CLI with PowerShell
   write-output "Step 19 delete storage account"
   write-output "az storage account delete -n $env:deployStorageAccountName -g $env:rg --yes"
   az storage account delete -n $env:deployStorageAccountName -g $env:rg --yes
   End commands to deploy this file using Azure CLI with PowerShell

   Begin common epilog commands
   az resource list -g $env:rg --query "[?resourceGroup=='$env:rg'].{ name: name, flavor: kind, resourceType: type, region: location }" --output table  | ForEach-Object { $_ -replace "`r", ""}
   $elapsedTime = $(get-date) - $StartTime
   $totalTime = "{0:HH:mm:ss}" -f ([datetime]$elapsedTime.Ticks)
   write-output "all done $(Get-Date) elapse time = $totalTime "
   End common epilog commands

 */


//    See https://github.com/Azure-Samples/function-app-arm-templates/blob/main/zip-deploy-arm-az-cli/README.md#steps
// see zip-deploy-arm-az-cli/README.md


@description('The name of the Azure Function app.')
param functionAppName string 

@description('The zip content url.')
param blobSASUri string 

output outblobSASUri string = blobSASUri
var unescapedBlobSASUri = replace(blobSASUri, '%26', '&')
output outputUnescapedBlobSASUri string = unescapedBlobSASUri
output outfunctionAppName string = functionAppName

// https://github.com/projectkudu/kudu/wiki/MSDeploy-VS.-ZipDeploy#zipdeploy MSDeploy does not work with WEBSITE_RUN_FROM_PACKAGE=1.

resource functionAppName_ZipDeploy 'Microsoft.Web/sites/extensions@2021-02-01' = {
  name: '${functionAppName}/ZipDeploy'
  properties: {
    packageUri: unescapedBlobSASUri
  }
}
