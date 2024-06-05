param serverfarms_jqo0osm3qxqr_func_plan_name string = 'jqo0osm3qxqr-func-plan'

resource serverfarms_jqo0osm3qxqr_func_plan_name_resource 'Microsoft.Web/serverfarms@2023-01-01' = {
  name: serverfarms_jqo0osm3qxqr_func_plan_name
  location: 'East US 2'
  sku: {
    name: 'EP1'
    tier: 'ElasticPremium'
    size: 'EP1'
    family: 'EP'
    capacity: 1
  }
  kind: 'elastic'
  properties: {
    perSiteScaling: false
    elasticScaleEnabled: true
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
