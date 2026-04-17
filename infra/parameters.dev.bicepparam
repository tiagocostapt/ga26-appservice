using './main.bicep'

param appName = 'ga26demo'
param environment = 'dev'
param location = 'eastus'
param appServicePlanSku = 'B1'
param demoValue = 'Development Environment - Deployed via Bicep'
param enableApplicationInsights = true
param tags = {
  environment: 'dev'
  createdBy: 'Bicep'
  project: 'GA26Demo'
  costCenter: 'demo'
}
