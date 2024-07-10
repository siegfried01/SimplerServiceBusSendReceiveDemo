# If it hasn't been done already
# Install-Module -Name Az -AllowClobber -Scope CurrentUser
# Connect-AzAccount


If ($env:USERNAME -eq "shein") { $env:name='SBusSndRcv' } `
    Else { $env:name="SBSSR-$($env:USERNAME)" }
$env:rg="rg-$($env:name)"
$env:loc=If ($env:AZ_DEFAULT_LOC) { $env:AZ_DEFAULT_LOC} `
    Else {'eastus2'}
$env:uniquePrefix="$(If ($env:USERNAME -eq "v-richardsi") {"xizdf"} 
    ElseIf ($env:USERNAME -eq "v-paperry") { "iucpl" } 
    ElseIf ($env:USERNAME -eq "shein") {"iqa5jvm"} 
    Else { "jyzwg" } )"

$env:serviceBusQueueName = 'mainqueue001'
$useServiceBusFireWall=[bool]0
$noManagedIdent=[bool]1
$useSourceControlLoadTestCode=If ($env:USERNAME -eq "shein") { [bool]1 } 
    Else { [bool]0 }

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

# There is no Resource Group called DefaultResourceGroup-WUS2 - Where is this coming from?
# 13c9725f-d20a-4c99-8ef4-d7bb78f98cff is CST - E Demos and POCs
$env:logAnalyticsWS= If ($env:USERNAME -eq "shein") { 
    "/subscriptions/acc26051-92a5-4ed1-a226-64a187bc27db/resourceGroups/DefaultResourceGroup-WUS2/providers/Microsoft.OperationalInsights/workspaces/DefaultWorkspace-acc26051-92a5-4ed1-a226-64a187bc27db-WUS2" } 
    else {   "/subscriptions/13c9725f-d20a-4c99-8ef4-d7bb78f98cff/resourceGroups/defaultresourcegroup-wus2/providers/microsoft.operationalinsights/workspaces/defaultworkspace-13c9725f-d20a-4c99-8ef4-d7bb78f98cff-wus2" }

# Create an Owner tag for resources
$tags = @{"Owner"="Sbox360"}

$StartTime = $(get-date)

# Check to see if the Resource Group exists or not
$resourceGroupExists = Get-AzResourceGroup -Name $env:rg -ErrorAction SilentlyContinue

if ($resourceGroupExists) {
    # Continue
}
else {
    az group create --name $env:rg --location $env:loc
}

# Set the Resource Group tags
Set-AzResourceGroup -Name $env:rg -Tag $tags

# This a Phase 1 deployment - It will deploy a Function App, WebApp (for verification only), Storage Accounts and no VNet and no PEP
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

# Here are the resulting resources:
# aztblogsv12g5jjoo3nvulus
# iucpl-appins
# iucpl-detector
# iucpl-failure anomalies
# iucpl-func - This one takes longer as it is a Function App
# iucpl-plan-func
# iucpl-plan-web
# iucpl-servicebus
# iucpl-webapp
# iucplfuncstg