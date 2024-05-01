#
# Assign the role of Owner to the devops agent.
# This is necessary because the bicep in deploy-ServiceBusSimpleSendReceive.bicep that is executed by the devops runner assigns the role of azure-service-bus-data-receiver to the azure function.
#
# sheintze-devopsdemoproject001-acc26051-92a5-4ed1-a226-64a187bc27db is the display name that the devops web UI created for me.
# For some reason there was two of them and I added Owner to both since I don't know which one it was using
# Note array index for the --query.
#
$accountInfo = az account show
$accountInfoObject = $accountInfo | ConvertFrom-Json
$subscriptionId  = $accountInfoObject.id
$appid=(az ad sp list --display-name "sheintze-devopsdemoproject001-$subscriptionId" --query "[0].appId" --output tsv)
write-output "appid=$appid"
az role assignment create --role "Owner" --assignee $appid --scope "/subscriptions/$subscriptionId/resourceGroups/rg_ServiceBusSimpleSendReceive"
$appid=(az ad sp list --display-name "sheintze-devopsdemoproject001-$subscriptionId" --query "[1].appId" --output tsv)
write-output "appid=$appid"
az role assignment create --role "Owner" --assignee $appid --scope "/subscriptions/$subscriptionId/resourceGroups/rg_ServiceBusSimpleSendReceive"
