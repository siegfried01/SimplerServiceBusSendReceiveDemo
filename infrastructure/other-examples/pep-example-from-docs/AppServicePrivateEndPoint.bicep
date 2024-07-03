/*
   From a (cygwin) bash prompt, use this perl one-liner to extract the powershell script fragments and exeucte them. This example shows how to execute steps 2 (shutdown) and steps 4-13 and skipping steps 7,8,9 because they don't work (yet). Adjust that list of steps according to your needs.

   powershell -executionPolicy unrestricted -Command - <<EOF
   `perl -lne 'sub range {$b=shift; $e=shift; $r=""; for(($b..$e)){ $r=$r."," if $r; $r=$r.$_;} $r } BEGIN {  $_ = shift; s/([0-9]+)-([0-9]+)/range($1,$2)/e; @idx=split ","; $c=0; $x=0; $f=0; $s=[] } $c++ if /^\s*Begin/; if (/^\s*End/) {$c--;$s[$f++]=""}; if ($x+$c>1) { $s->[$f]=$s->[$f].$_."\n"  } $x=$c; END { push(@idx, $#s); unshift @idx,0; for (@idx) { $p=$s->[$_]; chomp $p; print $p } }' "2,4-6,10-13" < "AppServicePrivateEndPoint.bicep"  `
EOF

   Begin common prolog commands
   $env:subscriptionId=(az account show --query id --output tsv | ForEach-Object { $_ -replace "`r", ""})
   $StartTime = $(get-date)
   $env:name=If ($env:USERNAME -eq "shein") { "AppServicePrivateEndPoint" } Else { "AppServicePrivateEndPoint_$($env:USERNAME)" }
   $env:rg="rg_$($env:name)"
   $env:location=If ($env:AZ_DEFAULT_LOC) { $env:AZ_DEFAULT_LOC} Else {'eastus2'}
   $env:uniquePrefix="$(If ($env:USERNAME -eq "v-richardsi") {"qaolr"} ElseIf ($env:USERNAME -eq "v-paperry") { "hqoga" } ElseIf ($env:USERNAME -eq "hein") {"wdfso"} Else { "lbaxn" } )"
   End common prolog commands

   emacs F10
   Begin commands to deploy this file using Azure CLI with PowerShell
   az deployment group create --name $env:name --resource-group $env:rg --mode Incremental --template-file  "AppServicePrivateEndPoint.bicep" --parameters "{'uniquePrefix': {'value': '$env:uniquePrefix'}}" "{'location': {'value': '$env:location'}}" | ForEach-Object { $_ -replace "`r", ""}
   write-output "end deploy $(Get-Date)"
   End commands to deploy this file using Azure CLI with PowerShell

   emacs ESC 2 F10
   Begin commands to shut down this deployment using Azure CLI with PowerShell
   write-output "begin shutdown $env:rg $(Get-Date)"
   az deployment group create --mode complete --template-file ./clear-resources.json --resource-group $env:rg  | ForEach-Object { $_ -replace "`r", ""}
   write-output "showdown is complete $env:rg $(Get-Date)" 
   End commands to shut down this deployment using Azure CLI with PowerShell

   emacs ESC 3 F10
   Begin commands to shut down this deployment using Azure CLI with PowerShell
   write-output "Step 3: begin shutdown delete resource group $env:rg and associated service principal $(Get-Date)"
   write-output "az group delete -n $env:rg"
   az group delete -n $env:rg --yes
   write-output "showdown is complete $env:rg $(Get-Date)"
   End commands to shut down this deployment using Azure CLI with PowerShell

   emacs ESC 4 F10
   Begin commands for one time initializations using Azure CLI with PowerShell
   write-output "az group create -l $($env:location) -n $($env:rg)"
   az group create -l $env:location -n $env:rg
   $env:id=(az group show --name $env:rg --query 'id' --output tsv)
   write-output "id=$env:id"
   write-output "{`n`"`$schema`": `"https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#`",`n `"contentVersion`": `"1.0.0.0`",`n `"resources`": [] `n}" | Out-File -FilePath clear-resources.json
   End commands for one time initializations using Azure CLI with PowerShell

   Begin common epilog commands
   az resource list -g $env:rg --query "[?resourceGroup=='$env:rg'].{ name: name, flavor: kind, resourceType: type, region: location }" --output table  | ForEach-Object { $_ -replace "`r", ""}
   $elapsedTime = $(get-date) - $StartTime
   $totalTime = "{0:HH:mm:ss}" -f ([datetime]$elapsedTime.Ticks)
   write-output "all done $(Get-Date) elapse time = $totalTime "
   End common epilog commands

 */
// https://learn.microsoft.com/en-us/azure/app-service/scripts/template-deploy-private-endpoint
param uniquePrefix string = uniqueString(resourceGroup().id)

@description('Name of the VNet')
param virtualNetwork_name string = '${uniquePrefix}-vnet'

@description('Name of the Web Farm')
param serverFarm_name string = '${uniquePrefix}-plan'

@description('Web App name must be unique DNS name worldwide')
param site_name string = '${uniquePrefix}-webapp'

@description('CIDR of your VNet')
param virtualNetwork_CIDR string = '10.200.0.0/16'

@description('Name of the Subnet')
param subnet1_name string = '${uniquePrefix}-subnet'

@description('CIDR of your subnet')
param subnet1_CIDR string = '10.200.1.0/24'

@description('Location for all resources.')
param location string = resourceGroup().location

@description('SKU name, must be minimum P1v2')
param SKU_name string = 'P1v2'

@description('SKU tier, must be Premium')
param SKU_tier string = 'PremiumV2'

@description('SKU size, must be minimum P1v2')
param SKU_size string = 'P1v2'

@description('SKU family, must be minimum P1v2')
param SKU_family string = 'P1v2'

@description('Name of your Private Endpoint')
param privateEndpoint_name string = '${uniquePrefix}-pep-webapp'

@description('Link name between your Private Endpoint and your Web App')
param privateLinkConnection_name string = 'privateLink'

@description('Name must be privatelink.azurewebsites.net')
param privateDNSZone_name string = 'privatelink.azurewebsites.net'

@description('Name must be privatelink.azurewebsites.net')
param webapp_dns_name string = '.azurewebsites.net'

resource virtualNetwork_name_resource 'Microsoft.Network/virtualNetworks@2020-04-01' = {
  name: virtualNetwork_name
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        virtualNetwork_CIDR
      ]
    }
  }
}

resource virtualNetwork_name_subnet1_name 'Microsoft.Network/virtualNetworks/subnets@2020-04-01' = {
  parent: virtualNetwork_name_resource
  name: subnet1_name
  properties: {
    addressPrefix: subnet1_CIDR
    privateEndpointNetworkPolicies: 'Disabled'
  }
}

resource serverFarm_name_resource 'Microsoft.Web/serverfarms@2019-08-01' = {
  name: serverFarm_name
  location: location
  sku: {
    name: SKU_name
    tier: SKU_tier
    size: SKU_size
    family: SKU_family
    capacity: 1
  }
  kind: 'app'
}

resource site_name_resource 'Microsoft.Web/sites@2019-08-01' = {
  name: site_name
  location: location
  kind: 'app'
  properties: {
    enabled: true
    hostNameSslStates: [
      {
        name: concat(site_name, webapp_dns_name)
        sslState: 'Disabled'
        hostType: 'Standard'
      }
      {
        name: '${site_name}.scm${webapp_dns_name}'
        sslState: 'Disabled'
        hostType: 'Repository'
      }
    ]
    serverFarmId: serverFarm_name_resource.id
  }
}

resource site_name_web 'Microsoft.Web/sites/config@2019-08-01' = {
  parent: site_name_resource
  name: 'web'
  location: location
  properties: {
    ftpsState: 'AllAllowed'
  }
}

resource site_name_site_name_webapp_dns_name 'Microsoft.Web/sites/hostNameBindings@2019-08-01' = {
  parent: site_name_resource
  name: '${site_name}${webapp_dns_name}'
  location: location
  properties: {
    siteName: site_name
    hostNameType: 'Verified'
  }
}

resource privateEndpoint_name_resource 'Microsoft.Network/privateEndpoints@2019-04-01' = {
  name: privateEndpoint_name
  location: location
  properties: {
    subnet: {
      id: virtualNetwork_name_subnet1_name.id
    }
    privateLinkServiceConnections: [
      {
        name: privateLinkConnection_name
        properties: {
          privateLinkServiceId: site_name_resource.id
          groupIds: [
            'sites'
          ]
        }
      }
    ]
  }
}

resource privateDNSZone_name_resource 'Microsoft.Network/privateDnsZones@2018-09-01' = {
  name: privateDNSZone_name
  location: 'global'
  dependsOn: [
    virtualNetwork_name_resource
  ]
}

resource privateDNSZone_name_privateDNSZone_name_link 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2018-09-01' = {
  parent: privateDNSZone_name_resource
  name: '${privateDNSZone_name}-link'
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: virtualNetwork_name_resource.id
    }
  }
}

resource privateEndpoint_name_dnsgroupname 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2020-03-01' = {
  parent: privateEndpoint_name_resource
  name: 'dnsgroupname'
  location: location
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'config1'
        properties: {
          privateDnsZoneId: privateDNSZone_name_resource.id
        }
      }
    ]
  }
}
