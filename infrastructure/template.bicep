param sites_aryxbqmevvg3e_func_name string = 'aryxbqmevvg3e-func'
param components_aryxbqmevvg3e_func_name string = 'aryxbqmevvg3e-func'
param serverfarms_aryxbqmevvg3e_func_plan_name string = 'aryxbqmevvg3e-func-plan'
param namespaces_aryxbqmevvg3e_servicebus_name string = 'aryxbqmevvg3e-servicebus'
param smartdetectoralertrules_failure_anomalies_aryxbqmevvg3e_func_name string = 'failure anomalies - aryxbqmevvg3e-func'
param actiongroups_application_insights_smart_detection_externalid string = '/subscriptions/acc26051-92a5-4ed1-a226-64a187bc27db/resourceGroups/rg_generalpurposecosmos/providers/microsoft.insights/actiongroups/application insights smart detection'
param workspaces_DefaultWorkspace_acc26051_92a5_4ed1_a226_64a187bc27db_WUS2_externalid string = '/subscriptions/acc26051-92a5-4ed1-a226-64a187bc27db/resourceGroups/DefaultResourceGroup-WUS2/providers/Microsoft.OperationalInsights/workspaces/DefaultWorkspace-acc26051-92a5-4ed1-a226-64a187bc27db-WUS2'

resource components_aryxbqmevvg3e_func_name_resource 'microsoft.insights/components@2020-02-02' = {
  name: components_aryxbqmevvg3e_func_name
  location: 'westus2'
  kind: 'web'
  properties: {
    Application_Type: 'web'
    Flow_Type: 'Redfield'
    Request_Source: 'IbizaAIExtensionEnablementBlade'
    RetentionInDays: 90
    WorkspaceResourceId: workspaces_DefaultWorkspace_acc26051_92a5_4ed1_a226_64a187bc27db_WUS2_externalid
    IngestionMode: 'LogAnalytics'
    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Enabled'
  }
}

resource namespaces_aryxbqmevvg3e_servicebus_name_resource 'Microsoft.ServiceBus/namespaces@2022-10-01-preview' = {
  name: namespaces_aryxbqmevvg3e_servicebus_name
  location: 'westus2'
  sku: {
    name: 'Standard'
    tier: 'Standard'
  }
  properties: {
    premiumMessagingPartitions: 0
    minimumTlsVersion: '1.0'
    publicNetworkAccess: 'Enabled'
    disableLocalAuth: false
    privateEndpointConnections: []
    zoneRedundant: false
  }
}

resource serverfarms_aryxbqmevvg3e_func_plan_name_resource 'Microsoft.Web/serverfarms@2023-01-01' = {
  name: serverfarms_aryxbqmevvg3e_func_plan_name
  location: 'West US 2'
  sku: {
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

resource smartdetectoralertrules_failure_anomalies_aryxbqmevvg3e_func_name_resource 'microsoft.alertsmanagement/smartdetectoralertrules@2021-04-01' = {
  name: smartdetectoralertrules_failure_anomalies_aryxbqmevvg3e_func_name
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
      components_aryxbqmevvg3e_func_name_resource.id
    ]
    actionGroups: {
      groupIds: [
        actiongroups_application_insights_smart_detection_externalid
      ]
    }
  }
}

resource components_aryxbqmevvg3e_func_name_degradationindependencyduration 'microsoft.insights/components/ProactiveDetectionConfigs@2018-05-01-preview' = {
  parent: components_aryxbqmevvg3e_func_name_resource
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

resource components_aryxbqmevvg3e_func_name_degradationinserverresponsetime 'microsoft.insights/components/ProactiveDetectionConfigs@2018-05-01-preview' = {
  parent: components_aryxbqmevvg3e_func_name_resource
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

resource components_aryxbqmevvg3e_func_name_digestMailConfiguration 'microsoft.insights/components/ProactiveDetectionConfigs@2018-05-01-preview' = {
  parent: components_aryxbqmevvg3e_func_name_resource
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

resource components_aryxbqmevvg3e_func_name_extension_billingdatavolumedailyspikeextension 'microsoft.insights/components/ProactiveDetectionConfigs@2018-05-01-preview' = {
  parent: components_aryxbqmevvg3e_func_name_resource
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

resource components_aryxbqmevvg3e_func_name_extension_canaryextension 'microsoft.insights/components/ProactiveDetectionConfigs@2018-05-01-preview' = {
  parent: components_aryxbqmevvg3e_func_name_resource
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

resource components_aryxbqmevvg3e_func_name_extension_exceptionchangeextension 'microsoft.insights/components/ProactiveDetectionConfigs@2018-05-01-preview' = {
  parent: components_aryxbqmevvg3e_func_name_resource
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

resource components_aryxbqmevvg3e_func_name_extension_memoryleakextension 'microsoft.insights/components/ProactiveDetectionConfigs@2018-05-01-preview' = {
  parent: components_aryxbqmevvg3e_func_name_resource
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

resource components_aryxbqmevvg3e_func_name_extension_securityextensionspackage 'microsoft.insights/components/ProactiveDetectionConfigs@2018-05-01-preview' = {
  parent: components_aryxbqmevvg3e_func_name_resource
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

resource components_aryxbqmevvg3e_func_name_extension_traceseveritydetector 'microsoft.insights/components/ProactiveDetectionConfigs@2018-05-01-preview' = {
  parent: components_aryxbqmevvg3e_func_name_resource
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

resource components_aryxbqmevvg3e_func_name_longdependencyduration 'microsoft.insights/components/ProactiveDetectionConfigs@2018-05-01-preview' = {
  parent: components_aryxbqmevvg3e_func_name_resource
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

resource components_aryxbqmevvg3e_func_name_migrationToAlertRulesCompleted 'microsoft.insights/components/ProactiveDetectionConfigs@2018-05-01-preview' = {
  parent: components_aryxbqmevvg3e_func_name_resource
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

resource components_aryxbqmevvg3e_func_name_slowpageloadtime 'microsoft.insights/components/ProactiveDetectionConfigs@2018-05-01-preview' = {
  parent: components_aryxbqmevvg3e_func_name_resource
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

resource components_aryxbqmevvg3e_func_name_slowserverresponsetime 'microsoft.insights/components/ProactiveDetectionConfigs@2018-05-01-preview' = {
  parent: components_aryxbqmevvg3e_func_name_resource
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

resource namespaces_aryxbqmevvg3e_servicebus_name_RootManageSharedAccessKey 'Microsoft.ServiceBus/namespaces/authorizationrules@2022-10-01-preview' = {
  parent: namespaces_aryxbqmevvg3e_servicebus_name_resource
  name: 'RootManageSharedAccessKey'
  location: 'westus2'
  properties: {
    rights: [
      'Listen'
      'Manage'
      'Send'
    ]
  }
}

resource namespaces_aryxbqmevvg3e_servicebus_name_default 'Microsoft.ServiceBus/namespaces/networkrulesets@2022-10-01-preview' = {
  parent: namespaces_aryxbqmevvg3e_servicebus_name_resource
  name: 'default'
  location: 'westus2'
  properties: {
    publicNetworkAccess: 'Enabled'
    defaultAction: 'Allow'
    virtualNetworkRules: []
    ipRules: []
    trustedServiceAccessEnabled: false
  }
}

resource namespaces_aryxbqmevvg3e_servicebus_name_mainqueue001 'Microsoft.ServiceBus/namespaces/queues@2022-10-01-preview' = {
  parent: namespaces_aryxbqmevvg3e_servicebus_name_resource
  name: 'mainqueue001'
  location: 'westus2'
  properties: {
    maxMessageSizeInKilobytes: 256
    lockDuration: 'PT1M'
    maxSizeInMegabytes: 1024
    requiresDuplicateDetection: false
    requiresSession: false
    defaultMessageTimeToLive: 'P10675199DT2H48M5.477S'
    deadLetteringOnMessageExpiration: false
    enableBatchedOperations: true
    duplicateDetectionHistoryTimeWindow: 'PT10M'
    maxDeliveryCount: 10
    status: 'Active'
    autoDeleteOnIdle: 'P10675199DT2H48M5.477S'
    enablePartitioning: false
    enableExpress: false
  }
}

resource sites_aryxbqmevvg3e_func_name_resource 'Microsoft.Web/sites@2023-01-01' = {
  name: sites_aryxbqmevvg3e_func_name
  location: 'West US 2'
  tags: {
    'hidden-link: /app-insights-resource-id': '/subscriptions/acc26051-92a5-4ed1-a226-64a187bc27db/resourceGroups/rg_ServiceBusSimpleSendReceive/providers/microsoft.insights/components/aryxbqmevvg3e-func'
    'hidden-link: /app-insights-instrumentation-key': '3e689f42-a1be-4faa-96b6-8cc9686d93cf'
  }
  kind: 'functionapp'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    enabled: true
    hostNameSslStates: [
      {
        name: '${sites_aryxbqmevvg3e_func_name}.azurewebsites.net'
        sslState: 'Disabled'
        hostType: 'Standard'
      }
      {
        name: '${sites_aryxbqmevvg3e_func_name}.scm.azurewebsites.net'
        sslState: 'Disabled'
        hostType: 'Repository'
      }
    ]
    serverFarmId: serverfarms_aryxbqmevvg3e_func_plan_name_resource.id
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
}

resource sites_aryxbqmevvg3e_func_name_ftp 'Microsoft.Web/sites/basicPublishingCredentialsPolicies@2023-01-01' = {
  parent: sites_aryxbqmevvg3e_func_name_resource
  name: 'ftp'
  location: 'West US 2'
  tags: {
    'hidden-link: /app-insights-resource-id': '/subscriptions/acc26051-92a5-4ed1-a226-64a187bc27db/resourceGroups/rg_ServiceBusSimpleSendReceive/providers/microsoft.insights/components/aryxbqmevvg3e-func'
    'hidden-link: /app-insights-instrumentation-key': '3e689f42-a1be-4faa-96b6-8cc9686d93cf'
  }
  properties: {
    allow: true
  }
}

resource sites_aryxbqmevvg3e_func_name_scm 'Microsoft.Web/sites/basicPublishingCredentialsPolicies@2023-01-01' = {
  parent: sites_aryxbqmevvg3e_func_name_resource
  name: 'scm'
  location: 'West US 2'
  tags: {
    'hidden-link: /app-insights-resource-id': '/subscriptions/acc26051-92a5-4ed1-a226-64a187bc27db/resourceGroups/rg_ServiceBusSimpleSendReceive/providers/microsoft.insights/components/aryxbqmevvg3e-func'
    'hidden-link: /app-insights-instrumentation-key': '3e689f42-a1be-4faa-96b6-8cc9686d93cf'
  }
  properties: {
    allow: true
  }
}

resource sites_aryxbqmevvg3e_func_name_web 'Microsoft.Web/sites/config@2023-01-01' = {
  parent: sites_aryxbqmevvg3e_func_name_resource
  name: 'web'
  location: 'West US 2'
  tags: {
    'hidden-link: /app-insights-resource-id': '/subscriptions/acc26051-92a5-4ed1-a226-64a187bc27db/resourceGroups/rg_ServiceBusSimpleSendReceive/providers/microsoft.insights/components/aryxbqmevvg3e-func'
    'hidden-link: /app-insights-instrumentation-key': '3e689f42-a1be-4faa-96b6-8cc9686d93cf'
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
    netFrameworkVersion: 'v6.0'
    requestTracingEnabled: false
    remoteDebuggingEnabled: false
    remoteDebuggingVersion: 'VS2019'
    httpLoggingEnabled: false
    acrUseManagedIdentityCreds: false
    logsDirectorySizeLimit: 35
    detailedErrorLoggingEnabled: false
    publishingUsername: '$aryxbqmevvg3e-func'
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
    managedServiceIdentityId: 19611
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

resource sites_aryxbqmevvg3e_func_name_73236288f08d4694a60c7016deb6b26b 'Microsoft.Web/sites/deployments@2023-01-01' = {
  parent: sites_aryxbqmevvg3e_func_name_resource
  name: '73236288f08d4694a60c7016deb6b26b'
  location: 'West US 2'
  properties: {
    status: 4
    author_email: 'N/A'
    author: 'N/A'
    deployer: 'ZipDeploy'
    message: 'Created via a push deployment'
    start_time: '2024-03-30T01:22:47.93242Z'
    end_time: '2024-03-30T01:22:53.4664969Z'
    active: false
  }
}

resource sites_aryxbqmevvg3e_func_name_adc1af3945174553b789d22c5bcf3645 'Microsoft.Web/sites/deployments@2023-01-01' = {
  parent: sites_aryxbqmevvg3e_func_name_resource
  name: 'adc1af3945174553b789d22c5bcf3645'
  location: 'West US 2'
  properties: {
    status: 4
    author_email: 'N/A'
    author: 'N/A'
    deployer: 'ZipDeploy'
    message: 'Created via a push deployment'
    start_time: '2024-04-30T17:02:02.0695833Z'
    end_time: '2024-04-30T17:02:02.4133381Z'
    active: true
  }
}

resource sites_aryxbqmevvg3e_func_name_SimpleServiceBusReceiver 'Microsoft.Web/sites/functions@2023-01-01' = {
  parent: sites_aryxbqmevvg3e_func_name_resource
  name: 'SimpleServiceBusReceiver'
  location: 'West US 2'
  properties: {
    script_root_path_href: 'https://aryxbqmevvg3e-func.azurewebsites.net/admin/vfs/site/wwwroot/SimpleServiceBusReceiver/'
    script_href: 'https://aryxbqmevvg3e-func.azurewebsites.net/admin/vfs/site/wwwroot/bin/SimpleServiceBusSendReceiveAzureFuncs.dll'
    config_href: 'https://aryxbqmevvg3e-func.azurewebsites.net/admin/vfs/site/wwwroot/SimpleServiceBusReceiver/function.json'
    test_data_href: 'https://aryxbqmevvg3e-func.azurewebsites.net/admin/vfs/data/Functions/sampledata/SimpleServiceBusReceiver.dat'
    href: 'https://aryxbqmevvg3e-func.azurewebsites.net/admin/functions/SimpleServiceBusReceiver'
    config: {}
    language: 'DotNetAssembly'
    isDisabled: false
  }
}

resource sites_aryxbqmevvg3e_func_name_sites_aryxbqmevvg3e_func_name_azurewebsites_net 'Microsoft.Web/sites/hostNameBindings@2023-01-01' = {
  parent: sites_aryxbqmevvg3e_func_name_resource
  name: '${sites_aryxbqmevvg3e_func_name}.azurewebsites.net'
  location: 'West US 2'
  properties: {
    siteName: 'aryxbqmevvg3e-func'
    hostNameType: 'Verified'
  }
}
