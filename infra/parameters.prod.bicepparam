using './main.bicep'

param appName = 'ga26demo'
param environment = 'prod'
param location = 'eastus'
param appServicePlanSku = 'P1V2'
param demoValue = 'Production Environment - Deployed via Bicep'
param enableApplicationInsights = true
param tags = {
  environment: 'prod'
  createdBy: 'Bicep'
  project: 'GA26Demo'
  costCenter: 'production'
}
