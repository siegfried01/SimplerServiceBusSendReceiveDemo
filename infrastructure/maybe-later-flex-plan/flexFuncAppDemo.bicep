/*
   From a (cygwin) bash prompt, use this perl one-liner to extract the powershell script fragments and exeucte them. This example shows how to execute steps 2 (shutdown) and steps 4-13 and skipping steps 7,8,9 because they don't work (yet). Adjust that list of steps according to your needs.

   powershell -executionPolicy unrestricted -Command - <<EOF
   `perl -lne 'sub range {$b=shift; $e=shift; $r=""; for(($b..$e)){ $r=$r."," if $r; $r=$r.$_;} $r } BEGIN {  $_ = shift; s/([0-9]+)-([0-9]+)/range($1,$2)/e; @idx=split ","; $c=0; $x=0; $f=0; $s=[] } $c++ if /^\s*Begin/; if (/^\s*End/) {$c--;$s[$f++]=""}; if ($x+$c>1) { $s->[$f]=$s->[$f].$_."\n"  } $x=$c; END { push(@idx, $#s); unshift @idx,0; for (@idx) { $p=$s->[$_]; chomp $p; print $p } }' "2,4-6,10-13" < "flexFuncAppDemo.bicep"  `
EOF

   Begin common prolog commands
   $env:subscriptionId=(az account show --query id --output tsv | ForEach-Object { $_ -replace "`r", ""})
   $StartTime = $(get-date)
   $env:name='flexFuncAppDemo'
   $env:rg="rg_$($env:name)"
   $env:sp="spad_$env:name"
   $env:location=If ($env:AZ_DEFAULT_LOC) { $env:AZ_DEFAULT_LOC} Else {'eastus2'}
   $env:uniquePrefix="$(If ($env:USERNAME -eq "v-richardsi") {"qsvzy"} ElseIf ($env:USERNAME -eq "v-paperry") { "orihx" } ElseIf ($env:USERNAME -eq "hein") {"fpstz"} Else { "yuftn" } )"
   End common prolog commands

   emacs F10
   Begin commands to deploy this file using Azure CLI with PowerShell
   az deployment group create --name $env:name --resource-group $env:rg --mode Incremental --template-file  "flexFuncAppDemo.bicep" --parameters "{'uniquePrefix': {'value': '$env:uniquePrefix'}}" "{'location': {'value': '$env:location'}}" | ForEach-Object { $_ -replace "`r", ""}
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

param sites_deletethisfunction000app_name string = 'deletethisfunction000app'
param serverfarms_ASP_rgSBusSndRcv_db1a_name string = 'ASP-rgSBusSndRcv-db1a'
param storageAccounts_deletethis000stg_name string = 'deletethis000stg'
param components_deletethisfunction000app_name string = 'deletethisfunction000app'
param workspaces_DefaultWorkspace_acc26051_92a5_4ed1_a226_64a187bc27db_WUS2_externalid string = '/subscriptions/acc26051-92a5-4ed1-a226-64a187bc27db/resourceGroups/DefaultResourceGroup-WUS2/providers/Microsoft.OperationalInsights/workspaces/DefaultWorkspace-acc26051-92a5-4ed1-a226-64a187bc27db-WUS2'

resource components_deletethisfunction000app_name_resource 'microsoft.insights/components@2020-02-02' = {
  name: components_deletethisfunction000app_name
  location: 'westus2'
  kind: 'web'
  properties: {
    Application_Type: 'web'
    RetentionInDays: 90
    WorkspaceResourceId: workspaces_DefaultWorkspace_acc26051_92a5_4ed1_a226_64a187bc27db_WUS2_externalid
    IngestionMode: 'LogAnalytics'
    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Enabled'
  }
}

resource storageAccounts_deletethis000stg_name_resource 'Microsoft.Storage/storageAccounts@2023-04-01' = {
  name: storageAccounts_deletethis000stg_name
  location: 'westus2'
  sku: {
    name: 'Standard_LRS'
    tier: 'Standard'
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
}

resource serverfarms_ASP_rgSBusSndRcv_db1a_name_resource 'Microsoft.Web/serverfarms@2023-12-01' = {
  name: serverfarms_ASP_rgSBusSndRcv_db1a_name
  location: 'West US 2'
  sku: {
    name: 'FC1'
    tier: 'FlexConsumption'
    size: 'FC1'
    family: 'FC'
    capacity: 0
  }
  kind: 'functionapp'
  properties: {
    perSiteScaling: false
    elasticScaleEnabled: false
    maximumElasticWorkerCount: 1
    isSpot: false
    reserved: true
    isXenon: false
    hyperV: false
    targetWorkerCount: 0
    targetWorkerSizeId: 0
    zoneRedundant: false
  }
}

resource components_deletethisfunction000app_name_degradationindependencyduration 'microsoft.insights/components/ProactiveDetectionConfigs@2018-05-01-preview' = {
  parent: components_deletethisfunction000app_name_resource
  name: 'degradationindependencyduration'
  location: 'westus2'
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

resource components_deletethisfunction000app_name_degradationinserverresponsetime 'microsoft.insights/components/ProactiveDetectionConfigs@2018-05-01-preview' = {
  parent: components_deletethisfunction000app_name_resource
  name: 'degradationinserverresponsetime'
  location: 'westus2'
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

resource components_deletethisfunction000app_name_digestMailConfiguration 'microsoft.insights/components/ProactiveDetectionConfigs@2018-05-01-preview' = {
  parent: components_deletethisfunction000app_name_resource
  name: 'digestMailConfiguration'
  location: 'westus2'
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

resource components_deletethisfunction000app_name_extension_billingdatavolumedailyspikeextension 'microsoft.insights/components/ProactiveDetectionConfigs@2018-05-01-preview' = {
  parent: components_deletethisfunction000app_name_resource
  name: 'extension_billingdatavolumedailyspikeextension'
  location: 'westus2'
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

resource components_deletethisfunction000app_name_extension_canaryextension 'microsoft.insights/components/ProactiveDetectionConfigs@2018-05-01-preview' = {
  parent: components_deletethisfunction000app_name_resource
  name: 'extension_canaryextension'
  location: 'westus2'
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

resource components_deletethisfunction000app_name_extension_exceptionchangeextension 'microsoft.insights/components/ProactiveDetectionConfigs@2018-05-01-preview' = {
  parent: components_deletethisfunction000app_name_resource
  name: 'extension_exceptionchangeextension'
  location: 'westus2'
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

resource components_deletethisfunction000app_name_extension_memoryleakextension 'microsoft.insights/components/ProactiveDetectionConfigs@2018-05-01-preview' = {
  parent: components_deletethisfunction000app_name_resource
  name: 'extension_memoryleakextension'
  location: 'westus2'
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

resource components_deletethisfunction000app_name_extension_securityextensionspackage 'microsoft.insights/components/ProactiveDetectionConfigs@2018-05-01-preview' = {
  parent: components_deletethisfunction000app_name_resource
  name: 'extension_securityextensionspackage'
  location: 'westus2'
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

resource components_deletethisfunction000app_name_extension_traceseveritydetector 'microsoft.insights/components/ProactiveDetectionConfigs@2018-05-01-preview' = {
  parent: components_deletethisfunction000app_name_resource
  name: 'extension_traceseveritydetector'
  location: 'westus2'
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

resource components_deletethisfunction000app_name_longdependencyduration 'microsoft.insights/components/ProactiveDetectionConfigs@2018-05-01-preview' = {
  parent: components_deletethisfunction000app_name_resource
  name: 'longdependencyduration'
  location: 'westus2'
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

resource components_deletethisfunction000app_name_migrationToAlertRulesCompleted 'microsoft.insights/components/ProactiveDetectionConfigs@2018-05-01-preview' = {
  parent: components_deletethisfunction000app_name_resource
  name: 'migrationToAlertRulesCompleted'
  location: 'westus2'
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

resource components_deletethisfunction000app_name_slowpageloadtime 'microsoft.insights/components/ProactiveDetectionConfigs@2018-05-01-preview' = {
  parent: components_deletethisfunction000app_name_resource
  name: 'slowpageloadtime'
  location: 'westus2'
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

resource components_deletethisfunction000app_name_slowserverresponsetime 'microsoft.insights/components/ProactiveDetectionConfigs@2018-05-01-preview' = {
  parent: components_deletethisfunction000app_name_resource
  name: 'slowserverresponsetime'
  location: 'westus2'
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

resource storageAccounts_deletethis000stg_name_default 'Microsoft.Storage/storageAccounts/blobServices@2023-04-01' = {
  parent: storageAccounts_deletethis000stg_name_resource
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

resource Microsoft_Storage_storageAccounts_fileServices_storageAccounts_deletethis000stg_name_default 'Microsoft.Storage/storageAccounts/fileServices@2023-04-01' = {
  parent: storageAccounts_deletethis000stg_name_resource
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

resource Microsoft_Storage_storageAccounts_queueServices_storageAccounts_deletethis000stg_name_default 'Microsoft.Storage/storageAccounts/queueServices@2023-04-01' = {
  parent: storageAccounts_deletethis000stg_name_resource
  name: 'default'
  properties: {
    cors: {
      corsRules: []
    }
  }
}

resource Microsoft_Storage_storageAccounts_tableServices_storageAccounts_deletethis000stg_name_default 'Microsoft.Storage/storageAccounts/tableServices@2023-04-01' = {
  parent: storageAccounts_deletethis000stg_name_resource
  name: 'default'
  properties: {
    cors: {
      corsRules: []
    }
  }
}

resource sites_deletethisfunction000app_name_ftp 'Microsoft.Web/sites/basicPublishingCredentialsPolicies@2023-12-01' = {
  parent: sites_deletethisfunction000app_name_resource
  name: 'ftp'
  location: 'West US 2'
  properties: {
    allow: true
  }
}

resource sites_deletethisfunction000app_name_scm 'Microsoft.Web/sites/basicPublishingCredentialsPolicies@2023-12-01' = {
  parent: sites_deletethisfunction000app_name_resource
  name: 'scm'
  location: 'West US 2'
  properties: {
    allow: true
  }
}

resource sites_deletethisfunction000app_name_web 'Microsoft.Web/sites/config@2023-12-01' = {
  parent: sites_deletethisfunction000app_name_resource
  name: 'web'
  location: 'West US 2'
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
    publishingUsername: '$deletethisfunction000app'
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
    functionAppScaleLimit: 100
    functionsRuntimeScaleMonitoringEnabled: false
    minimumElasticInstanceCount: 0
    azureStorageAccounts: {}
  }
}

resource sites_deletethisfunction000app_name_sites_deletethisfunction000app_name_azurewebsites_net 'Microsoft.Web/sites/hostNameBindings@2023-12-01' = {
  parent: sites_deletethisfunction000app_name_resource
  name: '${sites_deletethisfunction000app_name}.azurewebsites.net'
  location: 'West US 2'
  properties: {
    siteName: 'deletethisfunction000app'
    hostNameType: 'Verified'
  }
}

resource storageAccounts_deletethis000stg_name_default_app_package_deletethisfunction000app_8607483 'Microsoft.Storage/storageAccounts/blobServices/containers@2023-04-01' = {
  parent: storageAccounts_deletethis000stg_name_default
  name: 'app-package-deletethisfunction000app-8607483'
  properties: {
    immutableStorageWithVersioning: {
      enabled: false
    }
    defaultEncryptionScope: '$account-encryption-key'
    denyEncryptionScopeOverride: false
    publicAccess: 'None'
  }
  dependsOn: [
    storageAccounts_deletethis000stg_name_resource
  ]
}

resource sites_deletethisfunction000app_name_resource 'Microsoft.Web/sites@2023-12-01' = {
  name: sites_deletethisfunction000app_name
  location: 'West US 2'
  kind: 'functionapp,linux'
  properties: {
    enabled: true
    hostNameSslStates: [
      {
        name: '${sites_deletethisfunction000app_name}.azurewebsites.net'
        sslState: 'Disabled'
        hostType: 'Standard'
      }
      {
        name: '${sites_deletethisfunction000app_name}.scm.azurewebsites.net'
        sslState: 'Disabled'
        hostType: 'Repository'
      }
    ]
    serverFarmId: serverfarms_ASP_rgSBusSndRcv_db1a_name_resource.id
    reserved: true
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
      functionAppScaleLimit: 100
      minimumElasticInstanceCount: 0
    }
    functionAppConfig: {
      deployment: {
        storage: {
          type: 'blobContainer'
          value: 'https://${storageAccounts_deletethis000stg_name}.blob.core.windows.net/app-package-${sites_deletethisfunction000app_name}-8607483'
          authentication: {
            type: 'StorageAccountConnectionString'
            storageAccountConnectionStringName: 'DEPLOYMENT_STORAGE_CONNECTION_STRING'
          }
        }
      }
      runtime: {
        name: 'dotnet-isolated'
        version: '8.0'
      }
      scaleAndConcurrency: {
        alwaysReady: []
        maximumInstanceCount: 100
        instanceMemoryMB: 2048
      }
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
  dependsOn: [
    storageAccounts_deletethis000stg_name_resource
  ]
}

// WARNING: C:\Users\shein\source\repos\Siegfried Samples\SimplerServiceBusSendReceiveDemo\infrastructure\maybe-later-flex-plan\flexFuncAppDemo.bicep(73,7) : Warning no-unused-params: Parameter "location" is declared but never used. [https://aka.ms/bicep/linter/no-unused-params]
// C:\Users\shein\source\repos\Siegfried Samples\SimplerServiceBusSendReceiveDemo\infrastructure\maybe-later-flex-plan\flexFuncAppDemo.bicep(74,7) : Warning no-unused-params: Parameter "uniquePrefix" is declared but never used. [https://aka.ms/bicep/linter/no-unused-params]
// C:\Users\shein\source\repos\Siegfried Samples\SimplerServiceBusSendReceiveDemo\infrastructure\maybe-later-flex-plan\flexFuncAppDemo.bicep(101,5) : Warning BCP073: The property "tier" is read-only. Expressions cannot be assigned to read-only properties. If this is an inaccuracy in the documentation, please report it to the Bicep Team. [https://aka.ms/bicep-type-issues]
// C:\Users\shein\source\repos\Siegfried Samples\SimplerServiceBusSendReceiveDemo\infrastructure\maybe-later-flex-plan\flexFuncAppDemo.bicep(433,3) : Warning BCP073: The property "sku" is read-only. Expressions cannot be assigned to read-only properties. If this is an inaccuracy in the documentation, please report it to the Bicep Team. [https://aka.ms/bicep-type-issues]
// C:\Users\shein\source\repos\Siegfried Samples\SimplerServiceBusSendReceiveDemo\infrastructure\maybe-later-flex-plan\flexFuncAppDemo.bicep(451,3) : Warning BCP073: The property "sku" is read-only. Expressions cannot be assigned to read-only properties. If this is an inaccuracy in the documentation, please report it to the Bicep Team. [https://aka.ms/bicep-type-issues]
// C:\Users\shein\source\repos\Siegfried Samples\SimplerServiceBusSendReceiveDemo\infrastructure\maybe-later-flex-plan\flexFuncAppDemo.bicep(492,3) : Warning BCP187: The property "location" does not exist in the resource or type definition, although it might still be valid. If this is an inaccuracy in the documentation, please report it to the Bicep Team. [https://aka.ms/bicep-type-issues]
// C:\Users\shein\source\repos\Siegfried Samples\SimplerServiceBusSendReceiveDemo\infrastructure\maybe-later-flex-plan\flexFuncAppDemo.bicep(501,3) : Warning BCP187: The property "location" does not exist in the resource or type definition, although it might still be valid. If this is an inaccuracy in the documentation, please report it to the Bicep Team. [https://aka.ms/bicep-type-issues]
// C:\Users\shein\source\repos\Siegfried Samples\SimplerServiceBusSendReceiveDemo\infrastructure\maybe-later-flex-plan\flexFuncAppDemo.bicep(510,3) : Warning BCP187: The property "location" does not exist in the resource or type definition, although it might still be valid. If this is an inaccuracy in the documentation, please report it to the Bicep Team. [https://aka.ms/bicep-type-issues]
// C:\Users\shein\source\repos\Siegfried Samples\SimplerServiceBusSendReceiveDemo\infrastructure\maybe-later-flex-plan\flexFuncAppDemo.bicep(585,3) : Warning BCP187: The property "location" does not exist in the resource or type definition, although it might still be valid. If this is an inaccuracy in the documentation, please report it to the Bicep Team. [https://aka.ms/bicep-type-issues]
// C:\Users\shein\source\repos\Siegfried Samples\SimplerServiceBusSendReceiveDemo\infrastructure\maybe-later-flex-plan\flexFuncAppDemo.bicep(604,5) : Warning no-unnecessary-dependson: Remove unnecessary dependsOn entry 'storageAccounts_deletethis000stg_name_resource'. [https://aka.ms/bicep/linter/no-unnecessary-dependson]
// C:\Users\shein\source\repos\Siegfried Samples\SimplerServiceBusSendReceiveDemo\infrastructure\maybe-later-flex-plan\flexFuncAppDemo.bicep(646,73) : Warning no-hardcoded-env-urls: Environment URLs should not be hardcoded. Use the environment() function to ensure compatibility across clouds. Found this disallowed host: "core.windows.net" [https://aka.ms/bicep/linter/no-hardcoded-env-urls]

// {
//   "id": "/subscriptions/acc26051-92a5-4ed1-a226-64a187bc27db/resourceGroups/rg_flexFuncAppDemo/providers/Microsoft.Resources/deployments/flexFuncAppDemo",
//   "location": null,
//   "name": "flexFuncAppDemo",
//   "properties": {
//     "correlationId": "5aefd5b4-72e0-4d9a-9f2c-dea9a1a2e588",
//     "debugSetting": null,
//     "dependencies": [
//       {
//         "dependsOn": [
//           {
//             "id": "/subscriptions/acc26051-92a5-4ed1-a226-64a187bc27db/resourceGroups/rg_flexFuncAppDemo/providers/Microsoft.Insights/components/deletethisfunction000app",
//             "resourceGroup": "rg_flexFuncAppDemo",
//             "resourceName": "deletethisfunction000app",
//             "resourceType": "Microsoft.Insights/components"
//           }
//         ],
//         "id": "/subscriptions/acc26051-92a5-4ed1-a226-64a187bc27db/resourceGroups/rg_flexFuncAppDemo/providers/Microsoft.Insights/components/deletethisfunction000app/ProactiveDetectionConfigs/degradationindependencyduration",
//         "resourceGroup": "rg_flexFuncAppDemo",
//         "resourceName": "deletethisfunction000app/degradationindependencyduration",
//         "resourceType": "Microsoft.Insights/components/ProactiveDetectionConfigs"
//       },
//       {
//         "dependsOn": [
//           {
//             "id": "/subscriptions/acc26051-92a5-4ed1-a226-64a187bc27db/resourceGroups/rg_flexFuncAppDemo/providers/Microsoft.Insights/components/deletethisfunction000app",
//             "resourceGroup": "rg_flexFuncAppDemo",
//             "resourceName": "deletethisfunction000app",
//             "resourceType": "Microsoft.Insights/components"
//           }
//         ],
//         "id": "/subscriptions/acc26051-92a5-4ed1-a226-64a187bc27db/resourceGroups/rg_flexFuncAppDemo/providers/Microsoft.Insights/components/deletethisfunction000app/ProactiveDetectionConfigs/degradationinserverresponsetime",
//         "resourceGroup": "rg_flexFuncAppDemo",
//         "resourceName": "deletethisfunction000app/degradationinserverresponsetime",
//         "resourceType": "Microsoft.Insights/components/ProactiveDetectionConfigs"
//       },
//       {
//         "dependsOn": [
//           {
//             "id": "/subscriptions/acc26051-92a5-4ed1-a226-64a187bc27db/resourceGroups/rg_flexFuncAppDemo/providers/Microsoft.Insights/components/deletethisfunction000app",
//             "resourceGroup": "rg_flexFuncAppDemo",
//             "resourceName": "deletethisfunction000app",
//             "resourceType": "Microsoft.Insights/components"
//           }
//         ],
//         "id": "/subscriptions/acc26051-92a5-4ed1-a226-64a187bc27db/resourceGroups/rg_flexFuncAppDemo/providers/Microsoft.Insights/components/deletethisfunction000app/ProactiveDetectionConfigs/digestMailConfiguration",
//         "resourceGroup": "rg_flexFuncAppDemo",
//         "resourceName": "deletethisfunction000app/digestMailConfiguration",
//         "resourceType": "Microsoft.Insights/components/ProactiveDetectionConfigs"
//       },
//       {
//         "dependsOn": [
//           {
//             "id": "/subscriptions/acc26051-92a5-4ed1-a226-64a187bc27db/resourceGroups/rg_flexFuncAppDemo/providers/Microsoft.Insights/components/deletethisfunction000app",
//             "resourceGroup": "rg_flexFuncAppDemo",
//             "resourceName": "deletethisfunction000app",
//             "resourceType": "Microsoft.Insights/components"
//           }
//         ],
//         "id": "/subscriptions/acc26051-92a5-4ed1-a226-64a187bc27db/resourceGroups/rg_flexFuncAppDemo/providers/Microsoft.Insights/components/deletethisfunction000app/ProactiveDetectionConfigs/extension_billingdatavolumedailyspikeextension",
//         "resourceGroup": "rg_flexFuncAppDemo",
//         "resourceName": "deletethisfunction000app/extension_billingdatavolumedailyspikeextension",
//         "resourceType": "Microsoft.Insights/components/ProactiveDetectionConfigs"
//       },
//       {
//         "dependsOn": [
//           {
//             "id": "/subscriptions/acc26051-92a5-4ed1-a226-64a187bc27db/resourceGroups/rg_flexFuncAppDemo/providers/Microsoft.Insights/components/deletethisfunction000app",
//             "resourceGroup": "rg_flexFuncAppDemo",
//             "resourceName": "deletethisfunction000app",
//             "resourceType": "Microsoft.Insights/components"
//           }
//         ],
//         "id": "/subscriptions/acc26051-92a5-4ed1-a226-64a187bc27db/resourceGroups/rg_flexFuncAppDemo/providers/Microsoft.Insights/components/deletethisfunction000app/ProactiveDetectionConfigs/extension_canaryextension",
//         "resourceGroup": "rg_flexFuncAppDemo",
//         "resourceName": "deletethisfunction000app/extension_canaryextension",
//         "resourceType": "Microsoft.Insights/components/ProactiveDetectionConfigs"
//       },
//       {
//         "dependsOn": [
//           {
//             "id": "/subscriptions/acc26051-92a5-4ed1-a226-64a187bc27db/resourceGroups/rg_flexFuncAppDemo/providers/Microsoft.Insights/components/deletethisfunction000app",
//             "resourceGroup": "rg_flexFuncAppDemo",
//             "resourceName": "deletethisfunction000app",
//             "resourceType": "Microsoft.Insights/components"
//           }
//         ],
//         "id": "/subscriptions/acc26051-92a5-4ed1-a226-64a187bc27db/resourceGroups/rg_flexFuncAppDemo/providers/Microsoft.Insights/components/deletethisfunction000app/ProactiveDetectionConfigs/extension_exceptionchangeextension",
//         "resourceGroup": "rg_flexFuncAppDemo",
//         "resourceName": "deletethisfunction000app/extension_exceptionchangeextension",
//         "resourceType": "Microsoft.Insights/components/ProactiveDetectionConfigs"
//       },
//       {
//         "dependsOn": [
//           {
//             "id": "/subscriptions/acc26051-92a5-4ed1-a226-64a187bc27db/resourceGroups/rg_flexFuncAppDemo/providers/Microsoft.Insights/components/deletethisfunction000app",
//             "resourceGroup": "rg_flexFuncAppDemo",
//             "resourceName": "deletethisfunction000app",
//             "resourceType": "Microsoft.Insights/components"
//           }
//         ],
//         "id": "/subscriptions/acc26051-92a5-4ed1-a226-64a187bc27db/resourceGroups/rg_flexFuncAppDemo/providers/Microsoft.Insights/components/deletethisfunction000app/ProactiveDetectionConfigs/extension_memoryleakextension",
//         "resourceGroup": "rg_flexFuncAppDemo",
//         "resourceName": "deletethisfunction000app/extension_memoryleakextension",
//         "resourceType": "Microsoft.Insights/components/ProactiveDetectionConfigs"
//       },
//       {
//         "dependsOn": [
//           {
//             "id": "/subscriptions/acc26051-92a5-4ed1-a226-64a187bc27db/resourceGroups/rg_flexFuncAppDemo/providers/Microsoft.Insights/components/deletethisfunction000app",
//             "resourceGroup": "rg_flexFuncAppDemo",
//             "resourceName": "deletethisfunction000app",
//             "resourceType": "Microsoft.Insights/components"
//           }
//         ],
//         "id": "/subscriptions/acc26051-92a5-4ed1-a226-64a187bc27db/resourceGroups/rg_flexFuncAppDemo/providers/Microsoft.Insights/components/deletethisfunction000app/ProactiveDetectionConfigs/extension_securityextensionspackage",
//         "resourceGroup": "rg_flexFuncAppDemo",
//         "resourceName": "deletethisfunction000app/extension_securityextensionspackage",
//         "resourceType": "Microsoft.Insights/components/ProactiveDetectionConfigs"
//       },
//       {
//         "dependsOn": [
//           {
//             "id": "/subscriptions/acc26051-92a5-4ed1-a226-64a187bc27db/resourceGroups/rg_flexFuncAppDemo/providers/Microsoft.Insights/components/deletethisfunction000app",
//             "resourceGroup": "rg_flexFuncAppDemo",
//             "resourceName": "deletethisfunction000app",
//             "resourceType": "Microsoft.Insights/components"
//           }
//         ],
//         "id": "/subscriptions/acc26051-92a5-4ed1-a226-64a187bc27db/resourceGroups/rg_flexFuncAppDemo/providers/Microsoft.Insights/components/deletethisfunction000app/ProactiveDetectionConfigs/extension_traceseveritydetector",
//         "resourceGroup": "rg_flexFuncAppDemo",
//         "resourceName": "deletethisfunction000app/extension_traceseveritydetector",
//         "resourceType": "Microsoft.Insights/components/ProactiveDetectionConfigs"
//       },
//       {
//         "dependsOn": [
//           {
//             "id": "/subscriptions/acc26051-92a5-4ed1-a226-64a187bc27db/resourceGroups/rg_flexFuncAppDemo/providers/Microsoft.Insights/components/deletethisfunction000app",
//             "resourceGroup": "rg_flexFuncAppDemo",
//             "resourceName": "deletethisfunction000app",
//             "resourceType": "Microsoft.Insights/components"
//           }
//         ],
//         "id": "/subscriptions/acc26051-92a5-4ed1-a226-64a187bc27db/resourceGroups/rg_flexFuncAppDemo/providers/Microsoft.Insights/components/deletethisfunction000app/ProactiveDetectionConfigs/longdependencyduration",
//         "resourceGroup": "rg_flexFuncAppDemo",
//         "resourceName": "deletethisfunction000app/longdependencyduration",
//         "resourceType": "Microsoft.Insights/components/ProactiveDetectionConfigs"
//       },
//       {
//         "dependsOn": [
//           {
//             "id": "/subscriptions/acc26051-92a5-4ed1-a226-64a187bc27db/resourceGroups/rg_flexFuncAppDemo/providers/Microsoft.Insights/components/deletethisfunction000app",
//             "resourceGroup": "rg_flexFuncAppDemo",
//             "resourceName": "deletethisfunction000app",
//             "resourceType": "Microsoft.Insights/components"
//           }
//         ],
//         "id": "/subscriptions/acc26051-92a5-4ed1-a226-64a187bc27db/resourceGroups/rg_flexFuncAppDemo/providers/Microsoft.Insights/components/deletethisfunction000app/ProactiveDetectionConfigs/migrationToAlertRulesCompleted",
//         "resourceGroup": "rg_flexFuncAppDemo",
//         "resourceName": "deletethisfunction000app/migrationToAlertRulesCompleted",
//         "resourceType": "Microsoft.Insights/components/ProactiveDetectionConfigs"
//       },
//       {
//         "dependsOn": [
//           {
//             "id": "/subscriptions/acc26051-92a5-4ed1-a226-64a187bc27db/resourceGroups/rg_flexFuncAppDemo/providers/Microsoft.Insights/components/deletethisfunction000app",
//             "resourceGroup": "rg_flexFuncAppDemo",
//             "resourceName": "deletethisfunction000app",
//             "resourceType": "Microsoft.Insights/components"
//           }
//         ],
//         "id": "/subscriptions/acc26051-92a5-4ed1-a226-64a187bc27db/resourceGroups/rg_flexFuncAppDemo/providers/Microsoft.Insights/components/deletethisfunction000app/ProactiveDetectionConfigs/slowpageloadtime",
//         "resourceGroup": "rg_flexFuncAppDemo",
//         "resourceName": "deletethisfunction000app/slowpageloadtime",
//         "resourceType": "Microsoft.Insights/components/ProactiveDetectionConfigs"
//       },
//       {
//         "dependsOn": [
//           {
//             "id": "/subscriptions/acc26051-92a5-4ed1-a226-64a187bc27db/resourceGroups/rg_flexFuncAppDemo/providers/Microsoft.Insights/components/deletethisfunction000app",
//             "resourceGroup": "rg_flexFuncAppDemo",
//             "resourceName": "deletethisfunction000app",
//             "resourceType": "Microsoft.Insights/components"
//           }
//         ],
//         "id": "/subscriptions/acc26051-92a5-4ed1-a226-64a187bc27db/resourceGroups/rg_flexFuncAppDemo/providers/Microsoft.Insights/components/deletethisfunction000app/ProactiveDetectionConfigs/slowserverresponsetime",
//         "resourceGroup": "rg_flexFuncAppDemo",
//         "resourceName": "deletethisfunction000app/slowserverresponsetime",
//         "resourceType": "Microsoft.Insights/components/ProactiveDetectionConfigs"
//       },
//       {
//         "dependsOn": [
//           {
//             "id": "/subscriptions/acc26051-92a5-4ed1-a226-64a187bc27db/resourceGroups/rg_flexFuncAppDemo/providers/Microsoft.Storage/storageAccounts/deletethis000stg",
//             "resourceGroup": "rg_flexFuncAppDemo",
//             "resourceName": "deletethis000stg",
//             "resourceType": "Microsoft.Storage/storageAccounts"
//           }
//         ],
//         "id": "/subscriptions/acc26051-92a5-4ed1-a226-64a187bc27db/resourceGroups/rg_flexFuncAppDemo/providers/Microsoft.Storage/storageAccounts/deletethis000stg/blobServices/default",
//         "resourceGroup": "rg_flexFuncAppDemo",
//         "resourceName": "deletethis000stg/default",
//         "resourceType": "Microsoft.Storage/storageAccounts/blobServices"
//       },
//       {
//         "dependsOn": [
//           {
//             "id": "/subscriptions/acc26051-92a5-4ed1-a226-64a187bc27db/resourceGroups/rg_flexFuncAppDemo/providers/Microsoft.Storage/storageAccounts/deletethis000stg",
//             "resourceGroup": "rg_flexFuncAppDemo",
//             "resourceName": "deletethis000stg",
//             "resourceType": "Microsoft.Storage/storageAccounts"
//           }
//         ],
//         "id": "/subscriptions/acc26051-92a5-4ed1-a226-64a187bc27db/resourceGroups/rg_flexFuncAppDemo/providers/Microsoft.Storage/storageAccounts/deletethis000stg/fileServices/default",
//         "resourceGroup": "rg_flexFuncAppDemo",
//         "resourceName": "deletethis000stg/default",
//         "resourceType": "Microsoft.Storage/storageAccounts/fileServices"
//       },
//       {
//         "dependsOn": [
//           {
//             "id": "/subscriptions/acc26051-92a5-4ed1-a226-64a187bc27db/resourceGroups/rg_flexFuncAppDemo/providers/Microsoft.Storage/storageAccounts/deletethis000stg",
//             "resourceGroup": "rg_flexFuncAppDemo",
//             "resourceName": "deletethis000stg",
//             "resourceType": "Microsoft.Storage/storageAccounts"
//           }
//         ],
//         "id": "/subscriptions/acc26051-92a5-4ed1-a226-64a187bc27db/resourceGroups/rg_flexFuncAppDemo/providers/Microsoft.Storage/storageAccounts/deletethis000stg/queueServices/default",
//         "resourceGroup": "rg_flexFuncAppDemo",
//         "resourceName": "deletethis000stg/default",
//         "resourceType": "Microsoft.Storage/storageAccounts/queueServices"
//       },
//       {
//         "dependsOn": [
//           {
//             "id": "/subscriptions/acc26051-92a5-4ed1-a226-64a187bc27db/resourceGroups/rg_flexFuncAppDemo/providers/Microsoft.Storage/storageAccounts/deletethis000stg",
//             "resourceGroup": "rg_flexFuncAppDemo",
//             "resourceName": "deletethis000stg",
//             "resourceType": "Microsoft.Storage/storageAccounts"
//           }
//         ],
//         "id": "/subscriptions/acc26051-92a5-4ed1-a226-64a187bc27db/resourceGroups/rg_flexFuncAppDemo/providers/Microsoft.Storage/storageAccounts/deletethis000stg/tableServices/default",
//         "resourceGroup": "rg_flexFuncAppDemo",
//         "resourceName": "deletethis000stg/default",
//         "resourceType": "Microsoft.Storage/storageAccounts/tableServices"
//       },
//       {
//         "dependsOn": [
//           {
//             "id": "/subscriptions/acc26051-92a5-4ed1-a226-64a187bc27db/resourceGroups/rg_flexFuncAppDemo/providers/Microsoft.Web/sites/deletethisfunction000app",
//             "resourceGroup": "rg_flexFuncAppDemo",
//             "resourceName": "deletethisfunction000app",
//             "resourceType": "Microsoft.Web/sites"
//           }
//         ],
//         "id": "/subscriptions/acc26051-92a5-4ed1-a226-64a187bc27db/resourceGroups/rg_flexFuncAppDemo/providers/Microsoft.Web/sites/deletethisfunction000app/basicPublishingCredentialsPolicies/ftp",
//         "resourceGroup": "rg_flexFuncAppDemo",
//         "resourceName": "deletethisfunction000app/ftp",
//         "resourceType": "Microsoft.Web/sites/basicPublishingCredentialsPolicies"
//       },
//       {
//         "dependsOn": [
//           {
//             "id": "/subscriptions/acc26051-92a5-4ed1-a226-64a187bc27db/resourceGroups/rg_flexFuncAppDemo/providers/Microsoft.Web/sites/deletethisfunction000app",
//             "resourceGroup": "rg_flexFuncAppDemo",
//             "resourceName": "deletethisfunction000app",
//             "resourceType": "Microsoft.Web/sites"
//           }
//         ],
//         "id": "/subscriptions/acc26051-92a5-4ed1-a226-64a187bc27db/resourceGroups/rg_flexFuncAppDemo/providers/Microsoft.Web/sites/deletethisfunction000app/basicPublishingCredentialsPolicies/scm",
//         "resourceGroup": "rg_flexFuncAppDemo",
//         "resourceName": "deletethisfunction000app/scm",
//         "resourceType": "Microsoft.Web/sites/basicPublishingCredentialsPolicies"
//       },
//       {
//         "dependsOn": [
//           {
//             "id": "/subscriptions/acc26051-92a5-4ed1-a226-64a187bc27db/resourceGroups/rg_flexFuncAppDemo/providers/Microsoft.Web/sites/deletethisfunction000app",
//             "resourceGroup": "rg_flexFuncAppDemo",
//             "resourceName": "deletethisfunction000app",
//             "resourceType": "Microsoft.Web/sites"
//           }
//         ],
//         "id": "/subscriptions/acc26051-92a5-4ed1-a226-64a187bc27db/resourceGroups/rg_flexFuncAppDemo/providers/Microsoft.Web/sites/deletethisfunction000app/config/web",
//         "resourceGroup": "rg_flexFuncAppDemo",
//         "resourceName": "deletethisfunction000app/web",
//         "resourceType": "Microsoft.Web/sites/config"
//       },
//       {
//         "dependsOn": [
//           {
//             "id": "/subscriptions/acc26051-92a5-4ed1-a226-64a187bc27db/resourceGroups/rg_flexFuncAppDemo/providers/Microsoft.Web/sites/deletethisfunction000app",
//             "resourceGroup": "rg_flexFuncAppDemo",
//             "resourceName": "deletethisfunction000app",
//             "resourceType": "Microsoft.Web/sites"
//           }
//         ],
//         "id": "/subscriptions/acc26051-92a5-4ed1-a226-64a187bc27db/resourceGroups/rg_flexFuncAppDemo/providers/Microsoft.Web/sites/deletethisfunction000app/hostNameBindings/deletethisfunction000app.azurewebsites.net",
//         "resourceGroup": "rg_flexFuncAppDemo",
//         "resourceName": "deletethisfunction000app/deletethisfunction000app.azurewebsites.net",
//         "resourceType": "Microsoft.Web/sites/hostNameBindings"
//       },
//       {
//         "dependsOn": [
//           {
//             "id": "/subscriptions/acc26051-92a5-4ed1-a226-64a187bc27db/resourceGroups/rg_flexFuncAppDemo/providers/Microsoft.Storage/storageAccounts/deletethis000stg/blobServices/default",
//             "resourceGroup": "rg_flexFuncAppDemo",
//             "resourceName": "deletethis000stg/default",
//             "resourceType": "Microsoft.Storage/storageAccounts/blobServices"
//           }
//         ],
//         "id": "/subscriptions/acc26051-92a5-4ed1-a226-64a187bc27db/resourceGroups/rg_flexFuncAppDemo/providers/Microsoft.Storage/storageAccounts/deletethis000stg/blobServices/default/containers/app-package-deletethisfunction000app-8607483",
//         "resourceGroup": "rg_flexFuncAppDemo",
//         "resourceName": "deletethis000stg/default/app-package-deletethisfunction000app-8607483",
//         "resourceType": "Microsoft.Storage/storageAccounts/blobServices/containers"
//       },
//       {
//         "dependsOn": [
//           {
//             "id": "/subscriptions/acc26051-92a5-4ed1-a226-64a187bc27db/resourceGroups/rg_flexFuncAppDemo/providers/Microsoft.Web/serverfarms/ASP-rgSBusSndRcv-db1a",
//             "resourceGroup": "rg_flexFuncAppDemo",
//             "resourceName": "ASP-rgSBusSndRcv-db1a",
//             "resourceType": "Microsoft.Web/serverfarms"
//           },
//           {
//             "id": "/subscriptions/acc26051-92a5-4ed1-a226-64a187bc27db/resourceGroups/rg_flexFuncAppDemo/providers/Microsoft.Storage/storageAccounts/deletethis000stg",
//             "resourceGroup": "rg_flexFuncAppDemo",
//             "resourceName": "deletethis000stg",
//             "resourceType": "Microsoft.Storage/storageAccounts"
//           }
//         ],
//         "id": "/subscriptions/acc26051-92a5-4ed1-a226-64a187bc27db/resourceGroups/rg_flexFuncAppDemo/providers/Microsoft.Web/sites/deletethisfunction000app",
//         "resourceGroup": "rg_flexFuncAppDemo",
//         "resourceName": "deletethisfunction000app",
//         "resourceType": "Microsoft.Web/sites"
//       }
//     ],
//     "duration": "PT44.296762S",
//     "error": null,
//     "mode": "Incremental",
//     "onErrorDeployment": null,
//     "outputResources": [
//       {
//         "id": "/subscriptions/acc26051-92a5-4ed1-a226-64a187bc27db/resourceGroups/rg_flexFuncAppDemo/providers/Microsoft.Insights/components/deletethisfunction000app",
//         "resourceGroup": "rg_flexFuncAppDemo"
//       },
//       {
//         "id": "/subscriptions/acc26051-92a5-4ed1-a226-64a187bc27db/resourceGroups/rg_flexFuncAppDemo/providers/Microsoft.Insights/components/deletethisfunction000app/ProactiveDetectionConfigs/degradationindependencyduration",
//         "resourceGroup": "rg_flexFuncAppDemo"
//       },
//       {
//         "id": "/subscriptions/acc26051-92a5-4ed1-a226-64a187bc27db/resourceGroups/rg_flexFuncAppDemo/providers/Microsoft.Insights/components/deletethisfunction000app/ProactiveDetectionConfigs/degradationinserverresponsetime",
//         "resourceGroup": "rg_flexFuncAppDemo"
//       },
//       {
//         "id": "/subscriptions/acc26051-92a5-4ed1-a226-64a187bc27db/resourceGroups/rg_flexFuncAppDemo/providers/Microsoft.Insights/components/deletethisfunction000app/ProactiveDetectionConfigs/digestMailConfiguration",
//         "resourceGroup": "rg_flexFuncAppDemo"
//       },
//       {
//         "id": "/subscriptions/acc26051-92a5-4ed1-a226-64a187bc27db/resourceGroups/rg_flexFuncAppDemo/providers/Microsoft.Insights/components/deletethisfunction000app/ProactiveDetectionConfigs/extension_billingdatavolumedailyspikeextension",
//         "resourceGroup": "rg_flexFuncAppDemo"
//       },
//       {
//         "id": "/subscriptions/acc26051-92a5-4ed1-a226-64a187bc27db/resourceGroups/rg_flexFuncAppDemo/providers/Microsoft.Insights/components/deletethisfunction000app/ProactiveDetectionConfigs/extension_canaryextension",
//         "resourceGroup": "rg_flexFuncAppDemo"
//       },
//       {
//         "id": "/subscriptions/acc26051-92a5-4ed1-a226-64a187bc27db/resourceGroups/rg_flexFuncAppDemo/providers/Microsoft.Insights/components/deletethisfunction000app/ProactiveDetectionConfigs/extension_exceptionchangeextension",
//         "resourceGroup": "rg_flexFuncAppDemo"
//       },
//       {
//         "id": "/subscriptions/acc26051-92a5-4ed1-a226-64a187bc27db/resourceGroups/rg_flexFuncAppDemo/providers/Microsoft.Insights/components/deletethisfunction000app/ProactiveDetectionConfigs/extension_memoryleakextension",
//         "resourceGroup": "rg_flexFuncAppDemo"
//       },
//       {
//         "id": "/subscriptions/acc26051-92a5-4ed1-a226-64a187bc27db/resourceGroups/rg_flexFuncAppDemo/providers/Microsoft.Insights/components/deletethisfunction000app/ProactiveDetectionConfigs/extension_securityextensionspackage",
//         "resourceGroup": "rg_flexFuncAppDemo"
//       },
//       {
//         "id": "/subscriptions/acc26051-92a5-4ed1-a226-64a187bc27db/resourceGroups/rg_flexFuncAppDemo/providers/Microsoft.Insights/components/deletethisfunction000app/ProactiveDetectionConfigs/extension_traceseveritydetector",
//         "resourceGroup": "rg_flexFuncAppDemo"
//       },
//       {
//         "id": "/subscriptions/acc26051-92a5-4ed1-a226-64a187bc27db/resourceGroups/rg_flexFuncAppDemo/providers/Microsoft.Insights/components/deletethisfunction000app/ProactiveDetectionConfigs/longdependencyduration",
//         "resourceGroup": "rg_flexFuncAppDemo"
//       },
//       {
//         "id": "/subscriptions/acc26051-92a5-4ed1-a226-64a187bc27db/resourceGroups/rg_flexFuncAppDemo/providers/Microsoft.Insights/components/deletethisfunction000app/ProactiveDetectionConfigs/migrationToAlertRulesCompleted",
//         "resourceGroup": "rg_flexFuncAppDemo"
//       },
//       {
//         "id": "/subscriptions/acc26051-92a5-4ed1-a226-64a187bc27db/resourceGroups/rg_flexFuncAppDemo/providers/Microsoft.Insights/components/deletethisfunction000app/ProactiveDetectionConfigs/slowpageloadtime",
//         "resourceGroup": "rg_flexFuncAppDemo"
//       },
//       {
//         "id": "/subscriptions/acc26051-92a5-4ed1-a226-64a187bc27db/resourceGroups/rg_flexFuncAppDemo/providers/Microsoft.Insights/components/deletethisfunction000app/ProactiveDetectionConfigs/slowserverresponsetime",
//         "resourceGroup": "rg_flexFuncAppDemo"
//       },
//       {
//         "id": "/subscriptions/acc26051-92a5-4ed1-a226-64a187bc27db/resourceGroups/rg_flexFuncAppDemo/providers/Microsoft.Storage/storageAccounts/deletethis000stg",
//         "resourceGroup": "rg_flexFuncAppDemo"
//       },
//       {
//         "id": "/subscriptions/acc26051-92a5-4ed1-a226-64a187bc27db/resourceGroups/rg_flexFuncAppDemo/providers/Microsoft.Storage/storageAccounts/deletethis000stg/blobServices/default",
//         "resourceGroup": "rg_flexFuncAppDemo"
//       },
//       {
//         "id": "/subscriptions/acc26051-92a5-4ed1-a226-64a187bc27db/resourceGroups/rg_flexFuncAppDemo/providers/Microsoft.Storage/storageAccounts/deletethis000stg/blobServices/default/containers/app-package-deletethisfunction000app-8607483",
//         "resourceGroup": "rg_flexFuncAppDemo"
//       },
//       {
//         "id": "/subscriptions/acc26051-92a5-4ed1-a226-64a187bc27db/resourceGroups/rg_flexFuncAppDemo/providers/Microsoft.Storage/storageAccounts/deletethis000stg/fileServices/default",
//         "resourceGroup": "rg_flexFuncAppDemo"
//       },
//       {
//         "id": "/subscriptions/acc26051-92a5-4ed1-a226-64a187bc27db/resourceGroups/rg_flexFuncAppDemo/providers/Microsoft.Storage/storageAccounts/deletethis000stg/queueServices/default",
//         "resourceGroup": "rg_flexFuncAppDemo"
//       },
//       {
//         "id": "/subscriptions/acc26051-92a5-4ed1-a226-64a187bc27db/resourceGroups/rg_flexFuncAppDemo/providers/Microsoft.Storage/storageAccounts/deletethis000stg/tableServices/default",
//         "resourceGroup": "rg_flexFuncAppDemo"
//       },
//       {
//         "id": "/subscriptions/acc26051-92a5-4ed1-a226-64a187bc27db/resourceGroups/rg_flexFuncAppDemo/providers/Microsoft.Web/serverfarms/ASP-rgSBusSndRcv-db1a",
//         "resourceGroup": "rg_flexFuncAppDemo"
//       },
//       {
//         "id": "/subscriptions/acc26051-92a5-4ed1-a226-64a187bc27db/resourceGroups/rg_flexFuncAppDemo/providers/Microsoft.Web/sites/deletethisfunction000app",
//         "resourceGroup": "rg_flexFuncAppDemo"
//       },
//       {
//         "id": "/subscriptions/acc26051-92a5-4ed1-a226-64a187bc27db/resourceGroups/rg_flexFuncAppDemo/providers/Microsoft.Web/sites/deletethisfunction000app/basicPublishingCredentialsPolicies/ftp",
//         "resourceGroup": "rg_flexFuncAppDemo"
//       },
//       {
//         "id": "/subscriptions/acc26051-92a5-4ed1-a226-64a187bc27db/resourceGroups/rg_flexFuncAppDemo/providers/Microsoft.Web/sites/deletethisfunction000app/basicPublishingCredentialsPolicies/scm",
//         "resourceGroup": "rg_flexFuncAppDemo"
//       },
//       {
//         "id": "/subscriptions/acc26051-92a5-4ed1-a226-64a187bc27db/resourceGroups/rg_flexFuncAppDemo/providers/Microsoft.Web/sites/deletethisfunction000app/config/web",
//         "resourceGroup": "rg_flexFuncAppDemo"
//       },
//       {
//         "id": "/subscriptions/acc26051-92a5-4ed1-a226-64a187bc27db/resourceGroups/rg_flexFuncAppDemo/providers/Microsoft.Web/sites/deletethisfunction000app/hostNameBindings/deletethisfunction000app.azurewebsites.net",
//         "resourceGroup": "rg_flexFuncAppDemo"
//       }
//     ],
//     "outputs": null,
//     "parameters": {
//       "components_deletethisfunction000app_name": {
//         "type": "String",
//         "value": "deletethisfunction000app"
//       },
//       "location": {
//         "type": "String",
//         "value": "westus2"
//       },
//       "serverfarms_ASP_rgSBusSndRcv_db1a_name": {
//         "type": "String",
//         "value": "ASP-rgSBusSndRcv-db1a"
//       },
//       "sites_deletethisfunction000app_name": {
//         "type": "String",
//         "value": "deletethisfunction000app"
//       },
//       "storageAccounts_deletethis000stg_name": {
//         "type": "String",
//         "value": "deletethis000stg"
//       },
//       "uniquePrefix": {
//         "type": "String",
//         "value": "yuftn"
//       },
//       "workspaces_DefaultWorkspace_acc26051_92a5_4ed1_a226_64a187bc27db_WUS2_externalid": {
//         "type": "String",
//         "value": "/subscriptions/acc26051-92a5-4ed1-a226-64a187bc27db/resourceGroups/DefaultResourceGroup-WUS2/providers/Microsoft.OperationalInsights/workspaces/DefaultWorkspace-acc26051-92a5-4ed1-a226-64a187bc27db-WUS2"
//       }
//     },
//     "parametersLink": null,
//     "providers": [
//       {
//         "id": null,
//         "namespace": "Microsoft.Insights",
//         "providerAuthorizationConsentState": null,
//         "registrationPolicy": null,
//         "registrationState": null,
//         "resourceTypes": [
//           {
//             "aliases": null,
//             "apiProfiles": null,
//             "apiVersions": null,
//             "capabilities": null,
//             "defaultApiVersion": null,
//             "locationMappings": null,
//             "locations": [
//               "westus2"
//             ],
//             "properties": null,
//             "resourceType": "components",
//             "zoneMappings": null
//           },
//           {
//             "aliases": null,
//             "apiProfiles": null,
//             "apiVersions": null,
//             "capabilities": null,
//             "defaultApiVersion": null,
//             "locationMappings": null,
//             "locations": [
//               "westus2"
//             ],
//             "properties": null,
//             "resourceType": "components/ProactiveDetectionConfigs",
//             "zoneMappings": null
//           }
//         ]
//       },
//       {
//         "id": null,
//         "namespace": "Microsoft.Storage",
//         "providerAuthorizationConsentState": null,
//         "registrationPolicy": null,
//         "registrationState": null,
//         "resourceTypes": [
//           {
//             "aliases": null,
//             "apiProfiles": null,
//             "apiVersions": null,
//             "capabilities": null,
//             "defaultApiVersion": null,
//             "locationMappings": null,
//             "locations": [
//               "westus2"
//             ],
//             "properties": null,
//             "resourceType": "storageAccounts",
//             "zoneMappings": null
//           },
//           {
//             "aliases": null,
//             "apiProfiles": null,
//             "apiVersions": null,
//             "capabilities": null,
//             "defaultApiVersion": null,
//             "locationMappings": null,
//             "locations": [
//               null
//             ],
//             "properties": null,
//             "resourceType": "storageAccounts/blobServices",
//             "zoneMappings": null
//           },
//           {
//             "aliases": null,
//             "apiProfiles": null,
//             "apiVersions": null,
//             "capabilities": null,
//             "defaultApiVersion": null,
//             "locationMappings": null,
//             "locations": [
//               null
//             ],
//             "properties": null,
//             "resourceType": "storageAccounts/fileServices",
//             "zoneMappings": null
//           },
//           {
//             "aliases": null,
//             "apiProfiles": null,
//             "apiVersions": null,
//             "capabilities": null,
//             "defaultApiVersion": null,
//             "locationMappings": null,
//             "locations": [
//               null
//             ],
//             "properties": null,
//             "resourceType": "storageAccounts/queueServices",
//             "zoneMappings": null
//           },
//           {
//             "aliases": null,
//             "apiProfiles": null,
//             "apiVersions": null,
//             "capabilities": null,
//             "defaultApiVersion": null,
//             "locationMappings": null,
//             "locations": [
//               null
//             ],
//             "properties": null,
//             "resourceType": "storageAccounts/tableServices",
//             "zoneMappings": null
//           },
//           {
//             "aliases": null,
//             "apiProfiles": null,
//             "apiVersions": null,
//             "capabilities": null,
//             "defaultApiVersion": null,
//             "locationMappings": null,
//             "locations": [
//               null
//             ],
//             "properties": null,
//             "resourceType": "storageAccounts/blobServices/containers",
//             "zoneMappings": null
//           }
//         ]
//       },
//       {
//         "id": null,
//         "namespace": "Microsoft.Web",
//         "providerAuthorizationConsentState": null,
//         "registrationPolicy": null,
//         "registrationState": null,
//         "resourceTypes": [
//           {
//             "aliases": null,
//             "apiProfiles": null,
//             "apiVersions": null,
//             "capabilities": null,
//             "defaultApiVersion": null,
//             "locationMappings": null,
//             "locations": [
//               "westus2"
//             ],
//             "properties": null,
//             "resourceType": "serverfarms",
//             "zoneMappings": null
//           },
//           {
//             "aliases": null,
//             "apiProfiles": null,
//             "apiVersions": null,
//             "capabilities": null,
//             "defaultApiVersion": null,
//             "locationMappings": null,
//             "locations": [
//               "westus2"
//             ],
//             "properties": null,
//             "resourceType": "sites/basicPublishingCredentialsPolicies",
//             "zoneMappings": null
//           },
//           {
//             "aliases": null,
//             "apiProfiles": null,
//             "apiVersions": null,
//             "capabilities": null,
//             "defaultApiVersion": null,
//             "locationMappings": null,
//             "locations": [
//               "westus2"
//             ],
//             "properties": null,
//             "resourceType": "sites/config",
//             "zoneMappings": null
//           },
//           {
//             "aliases": null,
//             "apiProfiles": null,
//             "apiVersions": null,
//             "capabilities": null,
//             "defaultApiVersion": null,
//             "locationMappings": null,
//             "locations": [
//               "westus2"
//             ],
//             "properties": null,
//             "resourceType": "sites/hostNameBindings",
//             "zoneMappings": null
//           },
//           {
//             "aliases": null,
//             "apiProfiles": null,
//             "apiVersions": null,
//             "capabilities": null,
//             "defaultApiVersion": null,
//             "locationMappings": null,
//             "locations": [
//               "westus2"
//             ],
//             "properties": null,
//             "resourceType": "sites",
//             "zoneMappings": null
//           }
//         ]
//       }
//     ],
//     "provisioningState": "Succeeded",
//     "templateHash": "13200210494375995767",
//     "templateLink": null,
//     "timestamp": "2024-06-24T16:31:52.982715+00:00",
//     "validatedResources": null
//   },
//   "resourceGroup": "rg_flexFuncAppDemo",
//   "tags": null,
//   "type": "Microsoft.Resources/deployments"
// }
// end deploy 06/24/2024 09:32:09
// Name                      Flavor             ResourceType                       Region
// ------------------------  -----------------  ---------------------------------  --------
// deletethisfunction000app  web                Microsoft.Insights/components      westus2
// deletethis000stg          StorageV2          Microsoft.Storage/storageAccounts  westus2
// ASP-rgSBusSndRcv-db1a     functionapp        Microsoft.Web/serverFarms          westus2
// deletethisfunction000app  functionapp,linux  Microsoft.Web/sites                westus2
// all done 06/24/2024 09:32:13 elapse time = 00:01:14 

// Process compilation finished
