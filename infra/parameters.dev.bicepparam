using './main.bicep'

param appName = 'ecs26demo'
param environment = 'dev'
param location = 'westeurope'
param appServicePlanSku = 'P0V3'
param demoValue = 'Development Environment - Deployed via Bicep'
param enableApplicationInsights = true
param tags = {
  environment: 'dev'
  createdBy: 'Bicep'
  project: 'ECS26Demo'
  costCenter: 'demo'
}
