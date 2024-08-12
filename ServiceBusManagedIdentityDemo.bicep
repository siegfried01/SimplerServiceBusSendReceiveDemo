/*
   From a (cygwin) bash prompt, use this perl one-liner to extract the powershell script fragments and exeucte them. This example shows how to execute steps 2 (shutdown) and steps 4-13 and skipping steps 7,8,9 because they don't work (yet). Adjust that list of steps according to your needs.

   powershell -executionPolicy unrestricted -Command - <<EOF
   `perl -lne 'sub range {$b=shift; $e=shift; $r=""; for(($b..$e)){ $r=$r."," if $r; $r=$r.$_;} $r } BEGIN {  $_ = shift; s/([0-9]+)-([0-9]+)/range($1,$2)/e; @idx=split ","; $c=0; $x=0; $f=0; $s=[] } $c++ if /^\s*Begin/; if (/^\s*End/) {$c--;$s[$f++]=""}; if ($x+$c>1) { $s->[$f]=$s->[$f].$_."\n"  } $x=$c; END { push(@idx, $#s); unshift @idx,0; for (@idx) { $p=$s->[$_]; chomp $p; print $p } }' "2,4-6,10-13" < "ServiceBusManagedIdentityDemo.bicep"  `
EOF

   Begin common prolog commands
   $env:subscriptionId=(az account show --query id --output tsv | ForEach-Object { $_ -replace "`r", ""})
   $StartTime = $(get-date)
   $env:name="ServiceBusManagedIdentityDemo"
   $env:rg="rg_$($env:name)"
   $env:sp="spad_$env:name"
   $env:sbn="sbsendrecvdemo"
   $env:queue="main"
   $env:location=If ($env:AZ_DEFAULT_LOC) { $env:AZ_DEFAULT_LOC} Else {'eastus2'}
   $env:uniquePrefix="$(If ($env:USERNAME -eq "v-richardsi") {"dgeqy"} ElseIf ($env:USERNAME -eq "v-paperry") { "kspea" } ElseIf ($env:USERNAME -eq "hein") {"tbend"} Else { "ftdwa" } )"
   write-output "start deploy for resource group = $($env:rg) at $StartTime"
   End common prolog commands

   emacs F10
   Begin commands to deploy this file using Azure CLI with PowerShell
   write-output "`$env:id=(az group show --name $($env:rg) --query 'id' --output tsv)"
   $env:id=(az group show --name $env:rg --query 'id' --output tsv)
   write-output "`$sp = az ad sp create-for-rbac --name $env:sp --json-auth --role contributor --scopes $($env:id)"
   $sp = (az ad sp create-for-rbac --name $env:sp --json-auth --role contributor --scopes $env:id --query "{clientId: appId, clientSecret: password, tenantId: tenant}" --output json) | ConvertFrom-Json
   write-output "sp=$sp"
   $clientId = $sp.clientId
   $clientSecret = $sp.clientSecret
   $subcriptionId=$sp.subscriptionId
   $tenentId = $sp.tenantId
   write-output " clientId=$clientId clientSecret=$clientSecret tenantId=$tenantId"
   write-output "Assign Service Bus Send and Receive roles to the service principal"
   write-output "az role assignment create --assignee $clientId --role `"Azure Service Bus Data Sender`" --scope /subscriptions/$subscriptionId/resourceGroups/$($env:rg)/providers/Microsoft.ServiceBus/namespaces/$($env:sbn)"
   az role assignment create --assignee $clientId --role "Azure Service Bus Data Sender" --scope /subscriptions/$subscriptionId/resourceGroups/$env:rg/providers/Microsoft.ServiceBus/namespaces/$env:sbn
   write-output "az role assignment create --assignee $clientId --role `"Azure Service Bus Data Receiver`" --scope /subscriptions/$subscriptionId/resourceGroups/$env:rg/providers/Microsoft.ServiceBus/namespaces/$env:sbn"
   az role assignment create --assignee $clientId --role "Azure Service Bus Data Receiver" --scope /subscriptions/$subscriptionId/resourceGroups/$env:rg/providers/Microsoft.ServiceBus/namespaces/$env:sbn
   write-output "Create the Service Bus Namespace `"$($env:sbn)`""
   az servicebus namespace create -g $env:rg -n $env:sbn --location $env:location --sku Basic
   write-output "Create the Service Bus Queue = `"$($env:queue)`""
   write-output "az servicebus queue create --resource-group $($env:rg) --namespace-name $($env:sbn) -n $($env:queue)"
   az servicebus queue create -g $env:rg --namespace-name $env:sbn -n $env:queue
   write-output "Send a test message to the Service Bus Queue"
   $sender = $serviceBusClient.CreateSender($serviceBusQueue)
   $sendMessage = [Azure.Messaging.ServiceBus.ServiceBusMessage]::new("Hello, Service Bus!")
   $sender.SendMessageAsync($sendMessage).Wait()
   write-output "Receive a message from the Service Bus Queue"
   $receiver = $serviceBusClient.CreateReceiver($serviceBusQueue)
   $receivedMessage = $receiver.ReceiveMessageAsync().Result
   write-output "Received message: $($receivedMessage.Body.ToString())"
   write-output "Complete the message"
   $receiver.CompleteMessageAsync($receivedMessage).Wait()
   write-output "Close the client"
   $sender.Dispose()
   $receiver.Dispose()
   $serviceBusClient.Dispose()
   End commands to deploy this file using Azure CLI with Powershell

   emacs ESC 2 F10
   Begin commands to shut down this deployment using Azure CLI with PowerShell
   write-output "begin shutdown of $env:rg $(Get-Date)" delete contents only
   az deployment group create --mode complete --template-file ./clear-resources.json --resource-group $env:rg  | ForEach-Object { $_ -replace "`r", ""}
   write-output "showdown is complete $env:rg $(Get-Date)" 
   End commands to shut down this deployment using Azure CLI with PowerShell

   emacs ESC 3 F10
   Begin commands to shut down this deployment using Azure CLI with PowerShell
   write-output "Step 3: begin shutdown delete resource group $env:rg and associated service principal $(Get-Date)"
   write-output "az ad sp list --display-name $env:sp"
   az ad sp list --display-name $env:sp
   write-output "az ad sp list --filter `"displayname eq '$env:sp'`" --output json"
   $env:spId=(az ad sp list --filter "displayname eq '$env:sp'" --query "[].id" --output tsv)
   write-output "az ad sp delete --id $env:spId"
   az ad sp delete --id $env:spId
   write-output "az group delete -n $env:rg"
   az group delete -n $env:rg --yes
   write-output "showdown is complete $env:rg $(Get-Date)"
   End commands to shut down this deployment using Azure CLI with PowerShell

   emacs ESC 4 F10
   Begin commands for one time initializations using Azure CLI with PowerShell
   write-output "Begin one time initializations"
   write-output "az group create -l $env:location -n $env:rg"
   az group create -l $env:location -n $env:rg
   $env:id=(az group show --name $env:rg --query 'id' --output tsv)
   write-output "id=$env:id"
   End commands for one time initializations using Azure CLI with PowerShell

   emacs ESC 7 F10
   Begin commands to deploy this file using Azure CLI with PowerShell
   write-output "Install Azure.Messaging.ServiceBus module if not installed"
   if (-not (Get-Module -ListAvailable -Name Azure.Messaging.ServiceBus)) {
     write-output "Install-Module -Name Azure.Messaging.ServiceBus -Force -AllowClobber"
     Install-Module -Name Azure.Messaging.ServiceBus -Force -AllowClobber
   } else {
     write-output "already installed"     
   }
   End commands to deploy this file using Azure CLI with Powershell

   emacs ESC 9 F10
   Begin commands to deploy this file using Azure CLI with PowerShell
   write-output "Create a Service Bus Client using Azure AD authentication"
   $serviceBusClient = [Azure.Messaging.ServiceBus.ServiceBusClient]::new($serviceBusNamespace, [Azure.Identity.ClientSecretCredential]::new($tenantId, $clientId, $clientSecret))
   End commands to deploy this file using Azure CLI with Powershell

   Begin common epilog commands
   az resource list -g $env:rg --query "[?resourceGroup=='$env:rg'].{ name: name, flavor: kind, resourceType: type, region: location }" --output table  | ForEach-Object { $_ -replace "`r", ""}
   $elapsedTime = $(get-date) - $StartTime
   $totalTime = "{0:HH:mm:ss}" -f ([datetime]$elapsedTime.Ticks)
   write-output "all done $(Get-Date) elapse time = $totalTime "
   End common epilog commands

 */
