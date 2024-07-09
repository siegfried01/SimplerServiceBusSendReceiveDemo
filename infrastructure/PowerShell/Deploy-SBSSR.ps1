If ($env:USERNAME -eq "shein") { $env:name='SBusSndRcv' } 
    Else { $env:name="SBSSR-$($env:USERNAME)" }
$env:rg="rg-$($env:name)"
$env:loc=If ($env:AZ_DEFAULT_LOC) { $env:AZ_DEFAULT_LOC} 
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
$env:logAnalyticsWS= If ($env:USERNAME -eq "shein") { 
    "/subscriptions/acc26051-92a5-4ed1-a226-64a187bc27db/resourceGroups/DefaultResourceGroup-WUS2/providers/Microsoft.OperationalInsights/workspaces/DefaultWorkspace-acc26051-92a5-4ed1-a226-64a187bc27db-WUS2" } 
    else {   "/subscriptions/13c9725f-d20a-4c99-8ef4-d7bb78f98cff/resourceGroups/defaultresourcegroup-wus2/providers/microsoft.operationalinsights/workspaces/defaultworkspace-13c9725f-d20a-4c99-8ef4-d7bb78f98cff-wus2" }

$StartTime = $(get-date)

