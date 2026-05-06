using './main.bicep'

param appName = 'ecs26demo'
param environment = 'prod'
param location = 'eastus'
param appServicePlanSku = 'P1V3'
param demoValue = 'Production Environment - Deployed via Bicep'
param enableApplicationInsights = true
param tags = {
  environment: 'prod'
  createdBy: 'Bicep'
  project: 'ECS26Demo'
  costCenter: 'production'
}
