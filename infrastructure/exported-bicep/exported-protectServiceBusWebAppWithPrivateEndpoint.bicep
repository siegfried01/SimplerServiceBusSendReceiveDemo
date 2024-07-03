/*
   From a (cygwin) bash prompt, use this perl one-liner to extract the powershell script fragments and exeucte them. This example shows how to execute steps 2 (shutdown) and steps 4-13 and skipping steps 7,8,9 because they don't work (yet). Adjust that list of steps according to your needs.

   powershell -executionPolicy unrestricted -Command - <<EOF
   `perl -lne 'sub range {$b=shift; $e=shift; $r=""; for(($b..$e)){ $r=$r."," if $r; $r=$r.$_;} $r } BEGIN {  $_ = shift; s/([0-9]+)-([0-9]+)/range($1,$2)/e; @idx=split ","; $c=0; $x=0; $f=0; $s=[] } $c++ if /^\s*Begin/; if (/^\s*End/) {$c--;$s[$f++]=""}; if ($x+$c>1) { $s->[$f]=$s->[$f].$_."\n"  } $x=$c; END { push(@idx, $#s); unshift @idx,0; for (@idx) { $p=$s->[$_]; chomp $p; print $p } }' "2,4-6,10-13" < "exported-protectServiceBusWebAppWithPrivateEndpoint.bicep"  `
EOF

   Begin common prolog commands
   $env:subscriptionId=(az account show --query id --output tsv | ForEach-Object { $_ -replace "`r", ""})
   $StartTime = $(get-date)
   $env:name=If ($env:USERNAME -eq "shein") { "SBusSndRcv" } Else { "SBusSndRcv_$($env:USERNAME)" }
   $env:rg="rg_$($env:name)"
   $env:sp="spad_$env:name"
   $env:location=If ($env:AZ_DEFAULT_LOC) { $env:AZ_DEFAULT_LOC} Else {'eastus2'}
   $env:uniquePrefix="$(If ($env:USERNAME -eq "v-richardsi") {"eizdf"} ElseIf ($env:USERNAME -eq "v-paperry") { "iucpl" } ElseIf ($env:USERNAME -eq "shein") {"iqa5jvm"} Else { "jyzwg" } )"
   End common prolog commands

   emacs F10
   Begin commands to deploy this file using Azure CLI with PowerShell
   az deployment group create --name $env:name --resource-group $env:rg --mode Incremental --template-file  "exported-protectServiceBusWebAppWithPrivateEndpoint.bicep" --parameters "{'uniquePrefix': {'value': '$env:uniquePrefix'}}" "{'location': {'value': '$env:location'}}" | ForEach-Object { $_ -replace "`r", ""}
   write-output "end deploy $(Get-Date)"
   End commands to deploy this file using Azure CLI with PowerShell

   emacs ESC 2 F10
   Begin commands to shut down this deployment using Azure CLI with PowerShell
   write-output "begin shutdown $env:rg $(Get-Date)"
   If (![string]::IsNullOrEmpty($kv)) {
     write-output "keyvault=$kv"
     write-output "az keyvault delete --name '$($env:uniquePrefix)-kv' -g '$env:rg'"
     az keyvault delete --name "$($env:uniquePrefix)-kv" -g "$env:rg"
     write-output "az keyvault purge --name `"$($env:uniquePrefix)-kv`" --location $env:location"
     az keyvault purge --name "$($env:uniquePrefix)-kv" --location $env:location 
   } Else {
     write-output "No key vault to delete & purge"
   }
   az deployment group create --mode complete --template-file ./clear-resources.json --resource-group $env:rg  | ForEach-Object { $_ -replace "`r", ""}
   write-output "showdown is complete $env:rg $(Get-Date)" 
   End commands to shut down this deployment using Azure CLI with PowerShell

   emacs ESC 3 F10
   Begin commands to shut down this deployment using Azure CLI with PowerShell
   write-output "Step 3: begin shutdown delete resource group $env:rg and associated service principal $(Get-Date)"
   #write-output "az ad sp list --display-name $env:sp"
   #az ad sp list --display-name $env:sp
   #write-output "az ad sp list --filter `"displayname eq '$env:sp'`" --output json"
   #$env:spId=(az ad sp list --filter "displayname eq '$env:sp'" --query "[].id" --output tsv)
   #write-output "az ad sp delete --id $env:spId"
   #az ad sp delete --id $env:spId
   write-output "az group delete -n $env:rg"
   az group delete -n $env:rg --yes
   write-output "showdown is complete $env:rg $(Get-Date)"
   End commands to shut down this deployment using Azure CLI with PowerShell

   emacs ESC 4 F10
   Begin commands for one time initializations using Azure CLI with PowerShell
   az group create -l $env:location -n $env:rg
   $env:id=(az group show --name $env:rg --query 'id' --output tsv)
   write-output "id=$env:id"
   #az ad sp create-for-rbac --name $env:sp --json-auth --role contributor --scopes $env:id
   #write-output "go to github settings->secrets and create a secret called AZURE_CREDENTIALS with the above output"
   write-output "{`n`"`$schema`": `"https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#`",`n `"contentVersion`": `"1.0.0.0`",`n `"resources`": [] `n}" | Out-File -FilePath clear-resources.json
   End commands for one time initializations using Azure CLI with PowerShell

   Begin common epilog commands
   az resource list -g $env:rg --query "[?resourceGroup=='$env:rg'].{ name: name, flavor: kind, resourceType: type, region: location }" --output table  | ForEach-Object { $_ -replace "`r", ""}
   $elapsedTime = $(get-date) - $StartTime
   $totalTime = "{0:HH:mm:ss}" -f ([datetime]$elapsedTime.Ticks)
   write-output "all done $(Get-Date) elapse time = $totalTime "
   End common epilog commands

 */

param location string = resourceGroup().location
param uniquePrefix string = uniqueString(resourceGroup().id)

param sites_eizdf_func_name string = 'eizdf-func'
param sites_eizdf_webapp_name string = 'eizdf-webapp'
param components_eizdf_func_name string = 'eizdf-func'
param virtualMachines_eizdfvm_name string = 'eizdfvm'
param serverfarms_eizdf_plan_func_name string = 'eizdf-plan-func'
param components_eizdf_appins_name string = 'eizdf-appins'
param serverfarms_eizdf_plan_webapp_name string = 'eizdf-plan-webapp'
param serverfarms_kimwg_plan_webapp_name string = 'kimwg-plan-webapp'
param virtualNetworks_eizdf_vnet_name string = 'eizdf-vnet'
param actionGroups_eizdf_detector_name string = 'eizdf-detector'
param storageAccounts_eizdffuncstg_name string = 'eizdffuncstg'
param networkInterfaces_eizdfvmVMNic_name string = 'eizdfvmVMNic'
param namespaces_eizdf_servicebus_name string = 'eizdf-servicebus'
param networkSecurityGroups_eizdfvmNSG_name string = 'eizdfvmNSG'
param publicIPAddresses_eizdfvmPublicIP_name string = 'eizdfvmPublicIP'
param storageAccounts_aztblogsv12u2gzyv3w2zong_name string = 'aztblogsv12u2gzyv3w2zong'
param publicIPAddresses_eizdf_function_public_ip_name string = 'eizdf-function-public-ip'
param privateEndpoints_eizdf_web_private_end_point_name string = 'eizdf-web-private-end-point'
param privateDnsZones_privatelink_azurewebsites_net_name string = 'privatelink.azurewebsites.net'
param privateEndpoints_eizdf_func_private_end_point_name string = 'eizdf-func-private-end-point'
param networkSecurityGroups_eizdf_vnet_subnet_Bastion_nsg_name string = 'eizdf-vnet-subnet-Bastion-nsg'
param smartdetectoralertrules_eizdf_failure_anomalies_name string = 'eizdf-failure anomalies'
param smartdetectoralertrules_failure_anomalies_eizdf_func_name string = 'failure anomalies - eizdf-func'
param actiongroups_application_insights_smart_detection_externalid string = '/subscriptions/13c9725f-d20a-4c99-8ef4-d7bb78f98cff/resourceGroups/rg-vivek-test/providers/microsoft.insights/actiongroups/application insights smart detection'
param workspaces_defaultworkspace_13c9725f_d20a_4c99_8ef4_d7bb78f98cff_wus2_externalid string = '/subscriptions/13c9725f-d20a-4c99-8ef4-d7bb78f98cff/resourceGroups/defaultresourcegroup-wus2/providers/microsoft.operationalinsights/workspaces/defaultworkspace-13c9725f-d20a-4c99-8ef4-d7bb78f98cff-wus2'
param workspaces_DefaultWorkspace_13c9725f_d20a_4c99_8ef4_d7bb78f98cff_EUS2_externalid string = '/subscriptions/13c9725f-d20a-4c99-8ef4-d7bb78f98cff/resourceGroups/DefaultResourceGroup-EUS2/providers/Microsoft.OperationalInsights/workspaces/DefaultWorkspace-13c9725f-d20a-4c99-8ef4-d7bb78f98cff-EUS2'

resource actionGroups_eizdf_detector_name_resource 'microsoft.insights/actionGroups@2023-09-01-preview' = {
  name: actionGroups_eizdf_detector_name
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

resource components_eizdf_appins_name_resource 'microsoft.insights/components@2020-02-02' = {
  name: components_eizdf_appins_name
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
    RetentionInDays: 90
    WorkspaceResourceId: workspaces_defaultworkspace_13c9725f_d20a_4c99_8ef4_d7bb78f98cff_wus2_externalid
    IngestionMode: 'LogAnalytics'
    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Enabled'
  }
}

resource components_eizdf_func_name_resource 'microsoft.insights/components@2020-02-02' = {
  name: components_eizdf_func_name
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
    Flow_Type: 'Redfield'
    Request_Source: 'IbizaAIExtensionEnablementBlade'
    RetentionInDays: 90
    WorkspaceResourceId: workspaces_DefaultWorkspace_13c9725f_d20a_4c99_8ef4_d7bb78f98cff_EUS2_externalid
    IngestionMode: 'LogAnalytics'
    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Enabled'
  }
}

resource networkSecurityGroups_eizdfvmNSG_name_resource 'Microsoft.Network/networkSecurityGroups@2023-11-01' = {
  name: networkSecurityGroups_eizdfvmNSG_name
  location: location
  properties: {
    securityRules: [
      {
        name: 'rdp'
        id: networkSecurityGroups_eizdfvmNSG_name_rdp.id
        type: 'Microsoft.Network/networkSecurityGroups/securityRules'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '3389'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 1000
          direction: 'Inbound'
          sourcePortRanges: []
          destinationPortRanges: []
          sourceAddressPrefixes: []
          destinationAddressPrefixes: []
        }
      }
    ]
  }
}

resource networkSecurityGroups_eizdf_vnet_subnet_Bastion_nsg_name_resource 'Microsoft.Network/networkSecurityGroups@2023-11-01' = {
  name: networkSecurityGroups_eizdf_vnet_subnet_Bastion_nsg_name
  location: location
  tags: {
    Creator: 'Automatically added by CloudGov Azure Policy'
    'CloudGov-Info': 'http://aka.ms/cssbaselinesecurity'
  }
  properties: {
    securityRules: []
  }
}

resource privateDnsZones_privatelink_azurewebsites_net_name_resource 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: privateDnsZones_privatelink_azurewebsites_net_name
  location: 'global'
  properties: {}
}

resource publicIPAddresses_eizdf_function_public_ip_name_resource 'Microsoft.Network/publicIPAddresses@2023-11-01' = {
  name: publicIPAddresses_eizdf_function_public_ip_name
  location: location
  sku: {
    name: 'Standard'
    tier: 'Regional'
  }
  zones: [
    '1'
    '2'
    '3'
  ]
  properties: {
    ipAddress: '4.153.130.161'
    publicIPAddressVersion: 'IPv4'
    publicIPAllocationMethod: 'Static'
    idleTimeoutInMinutes: 4
    ipTags: []
    ddosSettings: {
      protectionMode: 'VirtualNetworkInherited'
    }
  }
}

resource publicIPAddresses_eizdfvmPublicIP_name_resource 'Microsoft.Network/publicIPAddresses@2023-11-01' = {
  name: publicIPAddresses_eizdfvmPublicIP_name
  location: location
  sku: {
    name: 'Standard'
    tier: 'Regional'
  }
  properties: {
    ipAddress: '40.79.17.152'
    publicIPAddressVersion: 'IPv4'
    publicIPAllocationMethod: 'Static'
    idleTimeoutInMinutes: 4
    ipTags: []
  }
}

resource namespaces_eizdf_servicebus_name_resource 'Microsoft.ServiceBus/namespaces@2022-10-01-preview' = {
  name: namespaces_eizdf_servicebus_name
  location: location
  sku: {
    name: 'Premium'
    tier: 'Premium'
    capacity: 1
  }
  properties: {
    premiumMessagingPartitions: 1
    minimumTlsVersion: '1.2'
    publicNetworkAccess: 'Enabled'
    disableLocalAuth: false
    zoneRedundant: false
  }
}

resource storageAccounts_aztblogsv12u2gzyv3w2zong_name_resource 'Microsoft.Storage/storageAccounts@2023-05-01' = {
  name: storageAccounts_aztblogsv12u2gzyv3w2zong_name
  location: location
  sku: {
    name: 'Standard_LRS'
    tier: 'Standard'
  }
  kind: 'StorageV2'
  properties: {
    allowCrossTenantReplication: false
    isLocalUserEnabled: false
    minimumTlsVersion: 'TLS1_2'
    allowBlobPublicAccess: false
    allowSharedKeyAccess: false
    networkAcls: {
      bypass: 'AzureServices'
      virtualNetworkRules: []
      ipRules: []
      defaultAction: 'Deny'
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
    accessTier: 'Hot'
  }
}

resource storageAccounts_eizdffuncstg_name_resource 'Microsoft.Storage/storageAccounts@2023-05-01' = {
  name: storageAccounts_eizdffuncstg_name
  location: location
  sku: {
    name: 'Standard_LRS'
    tier: 'Standard'
  }
  kind: 'StorageV2'
  properties: {
    allowCrossTenantReplication: false
    minimumTlsVersion: 'TLS1_2'
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
}

resource serverfarms_eizdf_plan_func_name_resource 'Microsoft.Web/serverfarms@2023-12-01' = {
  name: serverfarms_eizdf_plan_func_name
  location: location
  sku: {
    name: 'P1v2'
    tier: 'PremiumV2'
    size: 'P1v2'
    family: 'Pv2'
    capacity: 1
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

resource serverfarms_eizdf_plan_webapp_name_resource 'Microsoft.Web/serverfarms@2023-12-01' = {
  name: serverfarms_eizdf_plan_webapp_name
  location: location
  sku: {
    name: 'B1'
    tier: 'Basic'
    size: 'B1'
    family: 'B'
    capacity: 1
  }
  kind: 'app'
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

resource serverfarms_kimwg_plan_webapp_name_resource 'Microsoft.Web/serverfarms@2023-12-01' = {
  name: serverfarms_kimwg_plan_webapp_name
  location: location
  sku: {
    name: 'B1'
    tier: 'Basic'
    size: 'B1'
    family: 'B'
    capacity: 1
  }
  kind: 'app'
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

resource smartdetectoralertrules_failure_anomalies_eizdf_func_name_resource 'microsoft.alertsmanagement/smartdetectoralertrules@2021-04-01' = {
  name: smartdetectoralertrules_failure_anomalies_eizdf_func_name
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
      components_eizdf_func_name_resource.id
    ]
    actionGroups: {
      groupIds: [
        actiongroups_application_insights_smart_detection_externalid
      ]
    }
  }
}


resource components_eizdf_appins_name_degradationindependencyduration 'microsoft.insights/components/ProactiveDetectionConfigs@2018-05-01-preview' = {
  parent: components_eizdf_appins_name_resource
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

resource components_eizdf_func_name_degradationindependencyduration 'microsoft.insights/components/ProactiveDetectionConfigs@2018-05-01-preview' = {
  parent: components_eizdf_func_name_resource
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

resource components_eizdf_appins_name_degradationinserverresponsetime 'microsoft.insights/components/ProactiveDetectionConfigs@2018-05-01-preview' = {
  parent: components_eizdf_appins_name_resource
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

resource components_eizdf_func_name_degradationinserverresponsetime 'microsoft.insights/components/ProactiveDetectionConfigs@2018-05-01-preview' = {
  parent: components_eizdf_func_name_resource
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

resource components_eizdf_appins_name_digestMailConfiguration 'microsoft.insights/components/ProactiveDetectionConfigs@2018-05-01-preview' = {
  parent: components_eizdf_appins_name_resource
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

resource components_eizdf_func_name_digestMailConfiguration 'microsoft.insights/components/ProactiveDetectionConfigs@2018-05-01-preview' = {
  parent: components_eizdf_func_name_resource
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

resource components_eizdf_appins_name_extension_billingdatavolumedailyspikeextension 'microsoft.insights/components/ProactiveDetectionConfigs@2018-05-01-preview' = {
  parent: components_eizdf_appins_name_resource
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

resource components_eizdf_func_name_extension_billingdatavolumedailyspikeextension 'microsoft.insights/components/ProactiveDetectionConfigs@2018-05-01-preview' = {
  parent: components_eizdf_func_name_resource
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

resource components_eizdf_appins_name_extension_canaryextension 'microsoft.insights/components/ProactiveDetectionConfigs@2018-05-01-preview' = {
  parent: components_eizdf_appins_name_resource
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

resource components_eizdf_func_name_extension_canaryextension 'microsoft.insights/components/ProactiveDetectionConfigs@2018-05-01-preview' = {
  parent: components_eizdf_func_name_resource
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

resource components_eizdf_appins_name_extension_exceptionchangeextension 'microsoft.insights/components/ProactiveDetectionConfigs@2018-05-01-preview' = {
  parent: components_eizdf_appins_name_resource
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

resource components_eizdf_func_name_extension_exceptionchangeextension 'microsoft.insights/components/ProactiveDetectionConfigs@2018-05-01-preview' = {
  parent: components_eizdf_func_name_resource
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

resource components_eizdf_appins_name_extension_memoryleakextension 'microsoft.insights/components/ProactiveDetectionConfigs@2018-05-01-preview' = {
  parent: components_eizdf_appins_name_resource
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

resource components_eizdf_func_name_extension_memoryleakextension 'microsoft.insights/components/ProactiveDetectionConfigs@2018-05-01-preview' = {
  parent: components_eizdf_func_name_resource
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

resource components_eizdf_appins_name_extension_securityextensionspackage 'microsoft.insights/components/ProactiveDetectionConfigs@2018-05-01-preview' = {
  parent: components_eizdf_appins_name_resource
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

resource components_eizdf_func_name_extension_securityextensionspackage 'microsoft.insights/components/ProactiveDetectionConfigs@2018-05-01-preview' = {
  parent: components_eizdf_func_name_resource
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

resource components_eizdf_appins_name_extension_traceseveritydetector 'microsoft.insights/components/ProactiveDetectionConfigs@2018-05-01-preview' = {
  parent: components_eizdf_appins_name_resource
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

resource components_eizdf_func_name_extension_traceseveritydetector 'microsoft.insights/components/ProactiveDetectionConfigs@2018-05-01-preview' = {
  parent: components_eizdf_func_name_resource
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

resource components_eizdf_appins_name_longdependencyduration 'microsoft.insights/components/ProactiveDetectionConfigs@2018-05-01-preview' = {
  parent: components_eizdf_appins_name_resource
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

resource components_eizdf_func_name_longdependencyduration 'microsoft.insights/components/ProactiveDetectionConfigs@2018-05-01-preview' = {
  parent: components_eizdf_func_name_resource
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

resource components_eizdf_appins_name_migrationToAlertRulesCompleted 'microsoft.insights/components/ProactiveDetectionConfigs@2018-05-01-preview' = {
  parent: components_eizdf_appins_name_resource
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

resource components_eizdf_func_name_migrationToAlertRulesCompleted 'microsoft.insights/components/ProactiveDetectionConfigs@2018-05-01-preview' = {
  parent: components_eizdf_func_name_resource
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

resource components_eizdf_appins_name_slowpageloadtime 'microsoft.insights/components/ProactiveDetectionConfigs@2018-05-01-preview' = {
  parent: components_eizdf_appins_name_resource
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

resource components_eizdf_func_name_slowpageloadtime 'microsoft.insights/components/ProactiveDetectionConfigs@2018-05-01-preview' = {
  parent: components_eizdf_func_name_resource
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

resource components_eizdf_appins_name_slowserverresponsetime 'microsoft.insights/components/ProactiveDetectionConfigs@2018-05-01-preview' = {
  parent: components_eizdf_appins_name_resource
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

resource components_eizdf_func_name_slowserverresponsetime 'microsoft.insights/components/ProactiveDetectionConfigs@2018-05-01-preview' = {
  parent: components_eizdf_func_name_resource
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

resource networkSecurityGroups_eizdfvmNSG_name_rdp 'Microsoft.Network/networkSecurityGroups/securityRules@2023-11-01' = {
  name: '${networkSecurityGroups_eizdfvmNSG_name}/rdp'
  properties: {
    protocol: 'Tcp'
    sourcePortRange: '*'
    destinationPortRange: '3389'
    sourceAddressPrefix: '*'
    destinationAddressPrefix: '*'
    access: 'Allow'
    priority: 1000
    direction: 'Inbound'
    sourcePortRanges: []
    destinationPortRanges: []
    sourceAddressPrefixes: []
    destinationAddressPrefixes: []
  }
}

resource privateDnsZones_privatelink_azurewebsites_net_name_eizdf_func 'Microsoft.Network/privateDnsZones/A@2020-06-01' = {
  parent: privateDnsZones_privatelink_azurewebsites_net_name_resource
  name: 'eizdf-func'
  properties: {
    metadata: {
      creator: 'created by private endpoint eizdf-func-private-end-point with resource guid 060ea215-2341-4977-b4be-8cd670832c74'
    }
    ttl: 10
    aRecords: [
      {
        ipv4Address: '10.0.1.4'
      }
    ]
  }
}

resource privateDnsZones_privatelink_azurewebsites_net_name_eizdf_func_scm 'Microsoft.Network/privateDnsZones/A@2020-06-01' = {
  parent: privateDnsZones_privatelink_azurewebsites_net_name_resource
  name: 'eizdf-func.scm'
  properties: {
    metadata: {
      creator: 'created by private endpoint eizdf-func-private-end-point with resource guid 060ea215-2341-4977-b4be-8cd670832c74'
    }
    ttl: 10
    aRecords: [
      {
        ipv4Address: '10.0.1.4'
      }
    ]
  }
}

resource privateDnsZones_privatelink_azurewebsites_net_name_eizdf_webapp 'Microsoft.Network/privateDnsZones/A@2020-06-01' = {
  parent: privateDnsZones_privatelink_azurewebsites_net_name_resource
  name: 'eizdf-webapp'
  properties: {
    metadata: {
      creator: 'created by private endpoint eizdf-web-private-end-point with resource guid 6f900642-f875-4562-93a7-93a600584959'
    }
    ttl: 10
    aRecords: [
      {
        ipv4Address: '10.0.1.5'
      }
    ]
  }
}

resource privateDnsZones_privatelink_azurewebsites_net_name_eizdf_webapp_scm 'Microsoft.Network/privateDnsZones/A@2020-06-01' = {
  parent: privateDnsZones_privatelink_azurewebsites_net_name_resource
  name: 'eizdf-webapp.scm'
  properties: {
    metadata: {
      creator: 'created by private endpoint eizdf-web-private-end-point with resource guid 6f900642-f875-4562-93a7-93a600584959'
    }
    ttl: 10
    aRecords: [
      {
        ipv4Address: '10.0.1.5'
      }
    ]
  }
}

resource Microsoft_Network_privateDnsZones_SOA_privateDnsZones_privatelink_azurewebsites_net_name 'Microsoft.Network/privateDnsZones/SOA@2020-06-01' = {
  parent: privateDnsZones_privatelink_azurewebsites_net_name_resource
  name: '@'
  properties: {
    ttl: 3600
    soaRecord: {
      email: 'azureprivatedns-host.microsoft.com'
      expireTime: 2419200
      host: 'azureprivatedns.net'
      minimumTtl: 10
      refreshTime: 3600
      retryTime: 300
      serialNumber: 1
    }
  }
}

resource virtualNetworks_eizdf_vnet_name_resource 'Microsoft.Network/virtualNetworks@2023-11-01' = {
  name: virtualNetworks_eizdf_vnet_name
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/16'
      ]
    }
    subnets: [
      {
        name: 'subnet-Bastion'
        id: virtualNetworks_eizdf_vnet_name_subnet_Bastion.id
        properties: {
          addressPrefix: '10.0.1.0/26'
          networkSecurityGroup: {
            id: networkSecurityGroups_eizdf_vnet_subnet_Bastion_nsg_name_resource.id
          }
          delegations: []
          privateEndpointNetworkPolicies: 'Disabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
        }
        type: 'Microsoft.Network/virtualNetworks/subnets'
      }
    ]
    virtualNetworkPeerings: []
    enableDdosProtection: false
  }
}

resource namespaces_eizdf_servicebus_name_RootManageSharedAccessKey 'Microsoft.ServiceBus/namespaces/authorizationrules@2022-10-01-preview' = {
  parent: namespaces_eizdf_servicebus_name_resource
  name: 'RootManageSharedAccessKey'
  location: location
  properties: {
    rights: [
      'Listen'
      'Manage'
      'Send'
    ]
  }
}

resource namespaces_eizdf_servicebus_name_default 'Microsoft.ServiceBus/namespaces/networkrulesets@2022-10-01-preview' = {
  parent: namespaces_eizdf_servicebus_name_resource
  name: 'default'
  location: location
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
      {
        ipMask: '172.56.107.204'
        action: 'Allow'
      }
    ]
    trustedServiceAccessEnabled: true
  }
}

resource namespaces_eizdf_servicebus_name_mainqueue001 'Microsoft.ServiceBus/namespaces/queues@2022-10-01-preview' = {
  parent: namespaces_eizdf_servicebus_name_resource
  name: 'mainqueue001'
  location: location
  properties: {
    maxMessageSizeInKilobytes: 1024
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
    autoDeleteOnIdle: 'P10675199DT2H48M5.4775807S'
    enablePartitioning: false
    enableExpress: false
  }
}

resource storageAccounts_aztblogsv12u2gzyv3w2zong_name_default 'Microsoft.Storage/storageAccounts/blobServices@2023-05-01' = {
  parent: storageAccounts_aztblogsv12u2gzyv3w2zong_name_resource
  name: 'default'
  sku: {
    name: 'Standard_LRS'
    tier: 'Standard'
  }
  properties: {
    cors: {
      corsRules: []
    }
    deleteRetentionPolicy: {
      allowPermanentDelete: false
      enabled: false
    }
  }
}

resource storageAccounts_eizdffuncstg_name_default 'Microsoft.Storage/storageAccounts/blobServices@2023-05-01' = {
  parent: storageAccounts_eizdffuncstg_name_resource
  name: 'default'
  sku: {
    name: 'Standard_LRS'
    tier: 'Standard'
  }
  properties: {
    cors: {
      corsRules: []
    }
    deleteRetentionPolicy: {
      allowPermanentDelete: false
      enabled: false
    }
  }
}

resource Microsoft_Storage_storageAccounts_fileServices_storageAccounts_aztblogsv12u2gzyv3w2zong_name_default 'Microsoft.Storage/storageAccounts/fileServices@2023-05-01' = {
  parent: storageAccounts_aztblogsv12u2gzyv3w2zong_name_resource
  name: 'default'
  sku: {
    name: 'Standard_LRS'
    tier: 'Standard'
  }
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
}

resource Microsoft_Storage_storageAccounts_fileServices_storageAccounts_eizdffuncstg_name_default 'Microsoft.Storage/storageAccounts/fileServices@2023-05-01' = {
  parent: storageAccounts_eizdffuncstg_name_resource
  name: 'default'
  sku: {
    name: 'Standard_LRS'
    tier: 'Standard'
  }
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
}

resource Microsoft_Storage_storageAccounts_queueServices_storageAccounts_aztblogsv12u2gzyv3w2zong_name_default 'Microsoft.Storage/storageAccounts/queueServices@2023-05-01' = {
  parent: storageAccounts_aztblogsv12u2gzyv3w2zong_name_resource
  name: 'default'
  properties: {
    cors: {
      corsRules: []
    }
  }
}

resource Microsoft_Storage_storageAccounts_queueServices_storageAccounts_eizdffuncstg_name_default 'Microsoft.Storage/storageAccounts/queueServices@2023-05-01' = {
  parent: storageAccounts_eizdffuncstg_name_resource
  name: 'default'
  properties: {
    cors: {
      corsRules: []
    }
  }
}

resource Microsoft_Storage_storageAccounts_tableServices_storageAccounts_aztblogsv12u2gzyv3w2zong_name_default 'Microsoft.Storage/storageAccounts/tableServices@2023-05-01' = {
  parent: storageAccounts_aztblogsv12u2gzyv3w2zong_name_resource
  name: 'default'
  properties: {
    cors: {
      corsRules: []
    }
  }
}

resource Microsoft_Storage_storageAccounts_tableServices_storageAccounts_eizdffuncstg_name_default 'Microsoft.Storage/storageAccounts/tableServices@2023-05-01' = {
  parent: storageAccounts_eizdffuncstg_name_resource
  name: 'default'
  properties: {
    cors: {
      corsRules: []
    }
  }
}

resource sites_eizdf_func_name_resource 'Microsoft.Web/sites@2023-12-01' = {
  name: sites_eizdf_func_name
  location: location
  tags: {
    'hidden-link: /app-insights-resource-id': '/subscriptions/13c9725f-d20a-4c99-8ef4-d7bb78f98cff/resourceGroups/rg_SBusSndRcv_v-richardsi/providers/microsoft.insights/components/eizdf-func'
    'hidden-link: /app-insights-instrumentation-key': '363f69b1-1e17-4f18-afe3-df8ab46f68f4'
    'hidden-link: /app-insights-conn-string': 'InstrumentationKey=363f69b1-1e17-4f18-afe3-df8ab46f68f4;IngestionEndpoint=https://eastus2-3.in.applicationinsights.azure.com/;LiveEndpoint=https://eastus2.livediagnostics.monitor.azure.com/;ApplicationId=6beee441-df52-413f-ad73-56fdcd7d6136'
  }
  kind: 'functionapp'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    enabled: true
    hostNameSslStates: [
      {
        name: '${sites_eizdf_func_name}.azurewebsites.net'
        sslState: 'Disabled'
        hostType: 'Standard'
      }
      {
        name: '${sites_eizdf_func_name}.scm.azurewebsites.net'
        sslState: 'Disabled'
        hostType: 'Repository'
      }
    ]
    serverFarmId: serverfarms_eizdf_plan_func_name_resource.id
    reserved: false
    isXenon: false
    hyperV: false
    dnsConfiguration: {}
    vnetRouteAllEnabled: false
    vnetImagePullEnabled: false
    vnetContentShareEnabled: false
    siteConfig: {
      numberOfWorkers: 1
      acrUseManagedIdentityCreds: false
      alwaysOn: false
      http20Enabled: true
      functionAppScaleLimit: 200
      minimumElasticInstanceCount: 1
    }
    scmSiteAlsoStopped: false
    clientAffinityEnabled: false
    clientCertEnabled: false
    clientCertMode: 'Required'
    hostNamesDisabled: false
    vnetBackupRestoreEnabled: false
    customDomainVerificationId: '601761B423669B426FBA3224672CADEADB619B49AC0996F9DE5EBCE97DAABD8B'
    containerSize: 1536
    dailyMemoryTimeQuota: 0
    httpsOnly: true
    redundancyMode: 'None'
    storageAccountRequired: false
    keyVaultReferenceIdentity: 'SystemAssigned'
  }
}

resource sites_eizdf_webapp_name_resource 'Microsoft.Web/sites@2023-12-01' = {
  name: sites_eizdf_webapp_name
  location: location
  kind: 'app'
  properties: {
    enabled: true
    hostNameSslStates: [
      {
        name: '${sites_eizdf_webapp_name}.azurewebsites.net'
        sslState: 'Disabled'
        hostType: 'Standard'
      }
      {
        name: '${sites_eizdf_webapp_name}.scm.azurewebsites.net'
        sslState: 'Disabled'
        hostType: 'Repository'
      }
    ]
    serverFarmId: serverfarms_eizdf_plan_webapp_name_resource.id
    reserved: false
    isXenon: false
    hyperV: false
    dnsConfiguration: {}
    vnetRouteAllEnabled: false
    vnetImagePullEnabled: false
    vnetContentShareEnabled: false
    siteConfig: {
      numberOfWorkers: 1
      acrUseManagedIdentityCreds: false
      alwaysOn: false
      http20Enabled: true
      functionAppScaleLimit: 0
      minimumElasticInstanceCount: 1
    }
    scmSiteAlsoStopped: false
    clientAffinityEnabled: true
    clientCertEnabled: false
    clientCertMode: 'Required'
    hostNamesDisabled: false
    vnetBackupRestoreEnabled: false
    customDomainVerificationId: '601761B423669B426FBA3224672CADEADB619B49AC0996F9DE5EBCE97DAABD8B'
    containerSize: 0
    dailyMemoryTimeQuota: 0
    httpsOnly: true
    redundancyMode: 'None'
    storageAccountRequired: false
    keyVaultReferenceIdentity: 'SystemAssigned'
  }
}

resource sites_eizdf_func_name_ftp 'Microsoft.Web/sites/basicPublishingCredentialsPolicies@2023-12-01' = {
  parent: sites_eizdf_func_name_resource
  name: 'ftp'
  location: location
  tags: {
    'hidden-link: /app-insights-resource-id': '/subscriptions/13c9725f-d20a-4c99-8ef4-d7bb78f98cff/resourceGroups/rg_SBusSndRcv_v-richardsi/providers/microsoft.insights/components/eizdf-func'
    'hidden-link: /app-insights-instrumentation-key': '363f69b1-1e17-4f18-afe3-df8ab46f68f4'
    'hidden-link: /app-insights-conn-string': 'InstrumentationKey=363f69b1-1e17-4f18-afe3-df8ab46f68f4;IngestionEndpoint=https://eastus2-3.in.applicationinsights.azure.com/;LiveEndpoint=https://eastus2.livediagnostics.monitor.azure.com/;ApplicationId=6beee441-df52-413f-ad73-56fdcd7d6136'
  }
  properties: {
    allow: false
  }
}

resource sites_eizdf_webapp_name_ftp 'Microsoft.Web/sites/basicPublishingCredentialsPolicies@2023-12-01' = {
  parent: sites_eizdf_webapp_name_resource
  name: 'ftp'
  location: location
  properties: {
    allow: false
  }
}

resource sites_eizdf_func_name_scm 'Microsoft.Web/sites/basicPublishingCredentialsPolicies@2023-12-01' = {
  parent: sites_eizdf_func_name_resource
  name: 'scm'
  location: location
  tags: {
    'hidden-link: /app-insights-resource-id': '/subscriptions/13c9725f-d20a-4c99-8ef4-d7bb78f98cff/resourceGroups/rg_SBusSndRcv_v-richardsi/providers/microsoft.insights/components/eizdf-func'
    'hidden-link: /app-insights-instrumentation-key': '363f69b1-1e17-4f18-afe3-df8ab46f68f4'
    'hidden-link: /app-insights-conn-string': 'InstrumentationKey=363f69b1-1e17-4f18-afe3-df8ab46f68f4;IngestionEndpoint=https://eastus2-3.in.applicationinsights.azure.com/;LiveEndpoint=https://eastus2.livediagnostics.monitor.azure.com/;ApplicationId=6beee441-df52-413f-ad73-56fdcd7d6136'
  }
  properties: {
    allow: false
  }
}

resource sites_eizdf_webapp_name_scm 'Microsoft.Web/sites/basicPublishingCredentialsPolicies@2023-12-01' = {
  parent: sites_eizdf_webapp_name_resource
  name: 'scm'
  location: location
  properties: {
    allow: false
  }
}

resource sites_eizdf_func_name_web 'Microsoft.Web/sites/config@2023-12-01' = {
  parent: sites_eizdf_func_name_resource
  name: 'web'
  location: location
  tags: {
    'hidden-link: /app-insights-resource-id': '/subscriptions/13c9725f-d20a-4c99-8ef4-d7bb78f98cff/resourceGroups/rg_SBusSndRcv_v-richardsi/providers/microsoft.insights/components/eizdf-func'
    'hidden-link: /app-insights-instrumentation-key': '363f69b1-1e17-4f18-afe3-df8ab46f68f4'
    'hidden-link: /app-insights-conn-string': 'InstrumentationKey=363f69b1-1e17-4f18-afe3-df8ab46f68f4;IngestionEndpoint=https://eastus2-3.in.applicationinsights.azure.com/;LiveEndpoint=https://eastus2.livediagnostics.monitor.azure.com/;ApplicationId=6beee441-df52-413f-ad73-56fdcd7d6136'
  }
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
    netFrameworkVersion: 'v8.0'
    requestTracingEnabled: false
    remoteDebuggingEnabled: false
    remoteDebuggingVersion: 'VS2019'
    httpLoggingEnabled: false
    acrUseManagedIdentityCreds: false
    logsDirectorySizeLimit: 35
    detailedErrorLoggingEnabled: false
    publishingUsername: 'REDACTED'
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
    cors: {
      allowedOrigins: [
        'https://portal.azure.com'
        'https://ms.portal.azure.com'
        'https://172.56.107.204'
      ]
      supportCredentials: false
    }
    localMySqlEnabled: false
    managedServiceIdentityId: 46616
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
    minimumElasticInstanceCount: 1
    azureStorageAccounts: {}
  }
}

resource sites_eizdf_webapp_name_web 'Microsoft.Web/sites/config@2023-12-01' = {
  parent: sites_eizdf_webapp_name_resource
  name: 'web'
  location: location
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
      'hostingstart.html'
    ]
    netFrameworkVersion: 'v8.0'
    phpVersion: '5.6'
    requestTracingEnabled: false
    remoteDebuggingEnabled: false
    remoteDebuggingVersion: 'VS2019'
    httpLoggingEnabled: false
    acrUseManagedIdentityCreds: false
    logsDirectorySizeLimit: 35
    detailedErrorLoggingEnabled: false
    publishingUsername: 'REDACTED'
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
    http20Enabled: true
    minTlsVersion: '1.2'
    scmMinTlsVersion: '1.2'
    ftpsState: 'FtpsOnly'
    preWarmedInstanceCount: 0
    elasticWebAppScaleLimit: 0
    functionsRuntimeScaleMonitoringEnabled: false
    minimumElasticInstanceCount: 1
    azureStorageAccounts: {}
  }
}

resource sites_eizdf_func_name_2eedc00a943c4d6f887f289f8ab20a8b 'Microsoft.Web/sites/deployments@2023-12-01' = {
  parent: sites_eizdf_func_name_resource
  name: '2eedc00a943c4d6f887f289f8ab20a8b'
  location: location
  properties: {
    status: 4
    author_email: 'N/A'
    author: 'N/A'
    deployer: 'az_cli_functions'
    message: 'Created via a push deployment'
    start_time: '2024-06-28T20:08:42.7276838Z'
    end_time: '2024-06-28T20:08:45.462051Z'
    active: false
  }
}

resource sites_eizdf_func_name_7d593099a23f453da550ba60ad1f77f7 'Microsoft.Web/sites/deployments@2023-12-01' = {
  parent: sites_eizdf_func_name_resource
  name: '7d593099a23f453da550ba60ad1f77f7'
  location: location
  properties: {
    status: 4
    author_email: 'N/A'
    author: 'N/A'
    deployer: 'az_cli_functions'
    message: 'Created via a push deployment'
    start_time: '2024-06-28T20:01:12.6589456Z'
    end_time: '2024-06-28T20:01:26.2211291Z'
    active: false
  }
}

resource sites_eizdf_func_name_f2d15d928ef2440287d45d8235eec7a7 'Microsoft.Web/sites/deployments@2023-12-01' = {
  parent: sites_eizdf_func_name_resource
  name: 'f2d15d928ef2440287d45d8235eec7a7'
  location: location
  properties: {
    status: 4
    author_email: 'N/A'
    author: 'N/A'
    deployer: 'ZipDeploy'
    message: 'Created via a push deployment'
    start_time: '2024-06-28T21:19:57.8282514Z'
    end_time: '2024-06-28T21:19:59.0938715Z'
    active: true
  }
}

resource sites_eizdf_func_name_SimpleServiceBusReceiver 'Microsoft.Web/sites/functions@2023-12-01' = {
  parent: sites_eizdf_func_name_resource
  name: 'SimpleServiceBusReceiver'
  location: location
  properties: {
    script_href: 'https://eizdf-func.azurewebsites.net/admin/vfs/site/wwwroot/SimpleServiceBusSendReceiveAzureFuncs.dll'
    test_data_href: 'https://eizdf-func.azurewebsites.net/admin/vfs/data/Functions/sampledata/SimpleServiceBusReceiver.dat'
    href: 'https://eizdf-func.azurewebsites.net/admin/functions/SimpleServiceBusReceiver'
    config: {
      name: 'SimpleServiceBusReceiver'
      entryPoint: 'SimpleServiceBusSendReceiveAzureFuncs.SimpleServiceBusSenderReceiver.Run'
      scriptFile: 'SimpleServiceBusSendReceiveAzureFuncs.dll'
      language: 'dotnet-isolated'
      bindings: [
        {
          name: 'message'
          direction: 'In'
          type: 'serviceBusTrigger'
          queueName: 'mainqueue001'
          connection: 'ServiceBusConnection'
          cardinality: 'One'
          properties: {
            supportsDeferredBinding: 'True'
          }
        }
      ]
    }
    language: 'dotnet-isolated'
    isDisabled: false
  }
}

resource sites_eizdf_func_name_sites_eizdf_func_name_azurewebsites_net 'Microsoft.Web/sites/hostNameBindings@2023-12-01' = {
  parent: sites_eizdf_func_name_resource
  name: '${sites_eizdf_func_name}.azurewebsites.net'
  location: location
  properties: {
    siteName: 'eizdf-func'
    hostNameType: 'Verified'
  }
}

resource sites_eizdf_webapp_name_sites_eizdf_webapp_name_azurewebsites_net 'Microsoft.Web/sites/hostNameBindings@2023-12-01' = {
  parent: sites_eizdf_webapp_name_resource
  name: '${sites_eizdf_webapp_name}.azurewebsites.net'
  location: location
  properties: {
    siteName: 'eizdf-webapp'
    hostNameType: 'Verified'
  }
}

resource sites_eizdf_func_name_eizdf_peconn_59be4e51_f3bd_4f77_8ea7_8fe05f58be2e 'Microsoft.Web/sites/privateEndpointConnections@2023-12-01' = {
  parent: sites_eizdf_func_name_resource
  name: 'eizdf-peconn-59be4e51-f3bd-4f77-8ea7-8fe05f58be2e'
  location: location
  properties: {
    privateEndpoint: {}
    privateLinkServiceConnectionState: {
      status: 'Approved'
      actionsRequired: 'None'
    }
    ipAddresses: [
      '10.0.1.4'
    ]
  }
}

resource sites_eizdf_webapp_name_eizdf_peconn_df21ce2f_e3b5_4981_a3cc_bb69b7a0597b 'Microsoft.Web/sites/privateEndpointConnections@2023-12-01' = {
  parent: sites_eizdf_webapp_name_resource
  name: 'eizdf-peconn-df21ce2f-e3b5-4981-a3cc-bb69b7a0597b'
  location: location
  properties: {
    privateEndpoint: {}
    privateLinkServiceConnectionState: {
      status: 'Approved'
      actionsRequired: 'None'
    }
    ipAddresses: [
      '10.0.1.5'
    ]
  }
}

resource smartdetectoralertrules_eizdf_failure_anomalies_name_resource 'microsoft.alertsmanagement/smartdetectoralertrules@2021-04-01' = {
  name: smartdetectoralertrules_eizdf_failure_anomalies_name
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
      components_eizdf_appins_name_resource.id
    ]
    actionGroups: {
      groupIds: [
        actionGroups_eizdf_detector_name_resource.id
      ]
    }
  }
}

resource privateDnsZones_privatelink_azurewebsites_net_name_dns_link 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  parent: privateDnsZones_privatelink_azurewebsites_net_name_resource
  name: 'dns-link'
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: virtualNetworks_eizdf_vnet_name_resource.id
    }
  }
}

resource privateEndpoints_eizdf_func_private_end_point_name_resource 'Microsoft.Network/privateEndpoints@2023-11-01' = {
  name: privateEndpoints_eizdf_func_private_end_point_name
  location: location
  properties: {
    privateLinkServiceConnections: [
      {
        name: 'eizdf-peconn'
        id: '${privateEndpoints_eizdf_func_private_end_point_name_resource.id}/privateLinkServiceConnections/eizdf-peconn'
        properties: {
          privateLinkServiceId: sites_eizdf_func_name_resource.id
          groupIds: [
            'sites'
          ]
          privateLinkServiceConnectionState: {
            status: 'Approved'
            actionsRequired: 'None'
          }
        }
      }
    ]
    manualPrivateLinkServiceConnections: []
    subnet: {
      id: virtualNetworks_eizdf_vnet_name_subnet_Bastion.id
    }
    ipConfigurations: []
    customDnsConfigs: []
  }
}

resource privateEndpoints_eizdf_web_private_end_point_name_resource 'Microsoft.Network/privateEndpoints@2023-11-01' = {
  name: privateEndpoints_eizdf_web_private_end_point_name
  location: location
  properties: {
    privateLinkServiceConnections: [
      {
        name: 'eizdf-peconn'
        id: '${privateEndpoints_eizdf_web_private_end_point_name_resource.id}/privateLinkServiceConnections/eizdf-peconn'
        properties: {
          privateLinkServiceId: sites_eizdf_webapp_name_resource.id
          groupIds: [
            'sites'
          ]
          privateLinkServiceConnectionState: {
            status: 'Approved'
            actionsRequired: 'None'
          }
        }
      }
    ]
    manualPrivateLinkServiceConnections: []
    subnet: {
      id: virtualNetworks_eizdf_vnet_name_subnet_Bastion.id
    }
    ipConfigurations: []
    customDnsConfigs: []
  }
}

resource privateEndpoints_eizdf_func_private_end_point_name_zone_group 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2023-11-01' = {
  name: '${privateEndpoints_eizdf_func_private_end_point_name}/zone-group'
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'webapp'
        properties: {
          privateDnsZoneId: privateDnsZones_privatelink_azurewebsites_net_name_resource.id
        }
      }
    ]
  }
  dependsOn: [
    privateEndpoints_eizdf_func_private_end_point_name_resource
  ]
}

resource privateEndpoints_eizdf_web_private_end_point_name_zone_group 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2023-11-01' = {
  name: '${privateEndpoints_eizdf_web_private_end_point_name}/zone-group'
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'webapp'
        properties: {
          privateDnsZoneId: privateDnsZones_privatelink_azurewebsites_net_name_resource.id
        }
      }
    ]
  }
  dependsOn: [
    privateEndpoints_eizdf_web_private_end_point_name_resource
  ]
}

resource virtualNetworks_eizdf_vnet_name_subnet_Bastion 'Microsoft.Network/virtualNetworks/subnets@2023-11-01' = {
  name: '${virtualNetworks_eizdf_vnet_name}/subnet-Bastion'
  properties: {
    addressPrefix: '10.0.1.0/26'
    networkSecurityGroup: {
      id: networkSecurityGroups_eizdf_vnet_subnet_Bastion_nsg_name_resource.id
    }
    delegations: []
    privateEndpointNetworkPolicies: 'Disabled'
    privateLinkServiceNetworkPolicies: 'Enabled'
  }
  dependsOn: [
    virtualNetworks_eizdf_vnet_name_resource
  ]
}

resource storageAccounts_eizdffuncstg_name_default_azure_webjobs_hosts 'Microsoft.Storage/storageAccounts/blobServices/containers@2023-05-01' = {
  parent: storageAccounts_eizdffuncstg_name_default
  name: 'azure-webjobs-hosts'
  properties: {
    immutableStorageWithVersioning: {
      enabled: false
    }
    defaultEncryptionScope: '$account-encryption-key'
    denyEncryptionScopeOverride: false
    publicAccess: 'None'
  }
  dependsOn: [
    storageAccounts_eizdffuncstg_name_resource
  ]
}

resource storageAccounts_eizdffuncstg_name_default_azure_webjobs_secrets 'Microsoft.Storage/storageAccounts/blobServices/containers@2023-05-01' = {
  parent: storageAccounts_eizdffuncstg_name_default
  name: 'azure-webjobs-secrets'
  properties: {
    immutableStorageWithVersioning: {
      enabled: false
    }
    defaultEncryptionScope: '$account-encryption-key'
    denyEncryptionScopeOverride: false
    publicAccess: 'None'
  }
  dependsOn: [
    storageAccounts_eizdffuncstg_name_resource
  ]
}

resource storageAccounts_aztblogsv12u2gzyv3w2zong_name_default_insights_logs_functionapplogs 'Microsoft.Storage/storageAccounts/blobServices/containers@2023-05-01' = {
  parent: storageAccounts_aztblogsv12u2gzyv3w2zong_name_default
  name: 'insights-logs-functionapplogs'
  properties: {
    immutableStorageWithVersioning: {
      enabled: false
    }
    defaultEncryptionScope: '$account-encryption-key'
    denyEncryptionScopeOverride: false
    publicAccess: 'None'
  }
  dependsOn: [
    storageAccounts_aztblogsv12u2gzyv3w2zong_name_resource
  ]
}

resource storageAccounts_aztblogsv12u2gzyv3w2zong_name_default_insights_logs_operationallogs 'Microsoft.Storage/storageAccounts/blobServices/containers@2023-05-01' = {
  parent: storageAccounts_aztblogsv12u2gzyv3w2zong_name_default
  name: 'insights-logs-operationallogs'
  properties: {
    immutableStorageWithVersioning: {
      enabled: false
    }
    defaultEncryptionScope: '$account-encryption-key'
    denyEncryptionScopeOverride: false
    publicAccess: 'None'
  }
  dependsOn: [
    storageAccounts_aztblogsv12u2gzyv3w2zong_name_resource
  ]
}

resource storageAccounts_aztblogsv12u2gzyv3w2zong_name_default_insights_logs_runtimeauditlogs 'Microsoft.Storage/storageAccounts/blobServices/containers@2023-05-01' = {
  parent: storageAccounts_aztblogsv12u2gzyv3w2zong_name_default
  name: 'insights-logs-runtimeauditlogs'
  properties: {
    immutableStorageWithVersioning: {
      enabled: false
    }
    defaultEncryptionScope: '$account-encryption-key'
    denyEncryptionScopeOverride: false
    publicAccess: 'None'
  }
  dependsOn: [
    storageAccounts_aztblogsv12u2gzyv3w2zong_name_resource
  ]
}

resource storageAccounts_aztblogsv12u2gzyv3w2zong_name_default_insights_metrics_pt1m 'Microsoft.Storage/storageAccounts/blobServices/containers@2023-05-01' = {
  parent: storageAccounts_aztblogsv12u2gzyv3w2zong_name_default
  name: 'insights-metrics-pt1m'
  properties: {
    immutableStorageWithVersioning: {
      enabled: false
    }
    defaultEncryptionScope: '$account-encryption-key'
    denyEncryptionScopeOverride: false
    publicAccess: 'None'
  }
  dependsOn: [
    storageAccounts_aztblogsv12u2gzyv3w2zong_name_resource
  ]
}

resource storageAccounts_eizdffuncstg_name_default_eizdf_func_15b15ec4 'Microsoft.Storage/storageAccounts/fileServices/shares@2023-05-01' = {
  parent: Microsoft_Storage_storageAccounts_fileServices_storageAccounts_eizdffuncstg_name_default
  name: 'eizdf-func-15b15ec4'
  properties: {
    accessTier: 'TransactionOptimized'
    shareQuota: 102400
    enabledProtocols: 'SMB'
  }
  dependsOn: [
    storageAccounts_eizdffuncstg_name_resource
  ]
}

resource storageAccounts_eizdffuncstg_name_default_iqa5jvm_func7198c0b0a43b 'Microsoft.Storage/storageAccounts/fileServices/shares@2023-05-01' = {
  parent: Microsoft_Storage_storageAccounts_fileServices_storageAccounts_eizdffuncstg_name_default
  name: 'iqa5jvm-func7198c0b0a43b'
  properties: {
    accessTier: 'TransactionOptimized'
    shareQuota: 102400
    enabledProtocols: 'SMB'
  }
  dependsOn: [
    storageAccounts_eizdffuncstg_name_resource
  ]
}

resource networkInterfaces_eizdfvmVMNic_name_resource 'Microsoft.Network/networkInterfaces@2023-11-01' = {
  name: networkInterfaces_eizdfvmVMNic_name
  location: location
  kind: 'Regular'
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfigeizdfvm'
        id: '${networkInterfaces_eizdfvmVMNic_name_resource.id}/ipConfigurations/ipconfigeizdfvm'
        type: 'Microsoft.Network/networkInterfaces/ipConfigurations'
        properties: {
          privateIPAddress: '10.0.1.6'
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: publicIPAddresses_eizdfvmPublicIP_name_resource.id
          }
          subnet: {
            id: virtualNetworks_eizdf_vnet_name_subnet_Bastion.id
          }
          primary: true
          privateIPAddressVersion: 'IPv4'
        }
      }
    ]
    dnsSettings: {
      dnsServers: []
    }
    enableAcceleratedNetworking: false
    enableIPForwarding: false
    disableTcpStateTracking: false
    networkSecurityGroup: {
      id: networkSecurityGroups_eizdfvmNSG_name_resource.id
    }
    nicType: 'Standard'
    auxiliaryMode: 'None'
    auxiliarySku: 'None'
  }
}
