# From https://github.com/Azure-Samples/function-app-arm-templates/blob/main/zip-deploy-arm-az-cli/README.md#steps

$accountInfo = az account show
$accountInfoObject = $accountInfo | ConvertFrom-Json
$subscriptionId  = $accountInfoObject.id

$env:rg="rg_ServiceBusSimpleSendReceive"
$random="aryxbqmevvg3e"
$newDeploymentStorage="${random}stg"
$newDeploymentContainer="${random}cntr"

az ad sp create-for-rbac --name <function-app-name> --role contributor --scopes /subscriptions/$subscriptionId/resourceGroups/$env:rg --sdk-auth  

az storage account create -n $newDeploymentStorage -g $env:rg  

az storage container create -n $newDeploymentContainer --account-name $newDeploymentStorage  

Compress-Archive -Path "..\SimpleServiceBusSendReceiveAzureFuncs\bin\x64\Debug\net6.0" -DestinationPath "."

az storage blob upload -f <local-zip-path> --account-name $newDeploymentStorage -c $newDeploymentContainer -n package.zip --overwrite true  

az storage blob generate-sas --full-uri --permissions r --expiry (get-date).AddMinutes(30).ToString("yyyy-MM-ddTHH:mm:ssZ") --account-name $newDeploymentStorage -c $newDeploymentContainer -n package.zip 
