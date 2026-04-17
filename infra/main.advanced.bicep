// GA26 Demo Advanced - Azure App Services with Bicep IaC
// This is an advanced example showing additional features:
// - Key Vault integration
// - Virtual Network integration
// - Custom domain
// - Auto-scaling
// - Database configuration

metadata description = 'GA26 Demo Advanced: Azure App Service with additional features'

@description('The name of the application')
param appName string

@description('Environment name (dev, staging, prod)')
param environment string

@description('Location for all resources')
param location string = resourceGroup().location

@description('SKU for App Service Plan')
param appServicePlanSku string = 'P1V2'

@description('Enable auto-scaling')
param enableAutoScaling bool = true

@description('Minimum instances for auto-scaling')
param minInstances int = 1

@description('Maximum instances for auto-scaling')
param maxInstances int = 3

@description('Database connection string')
param databaseConnectionString string = ''

@description('Key Vault resource ID for managed identity access')
param keyVaultResourceId string = ''

@description('Subnet ID for VNet integration')
param subnetId string = ''

@description('Tags for all resources')
param tags object = {
  environment: environment
  createdBy: 'Bicep'
  project: 'GA26Demo'
}

var uniqueSuffix = uniqueString(resourceGroup().id)
var appServicePlanName = '${appName}-${environment}-plan'
var appServiceName = '${appName}-${environment}-app'
var applicationInsightsName = '${appName}-${environment}-ai'
var autoscaleName = '${appName}-${environment}-autoscale'

// App Service Plan (with auto-scale capable SKU)
resource appServicePlan 'Microsoft.Web/serverfarms@2023-01-01' = {
  name: appServicePlanName
  location: location
  tags: tags
  sku: {
    name: appServicePlanSku
    capacity: minInstances
  }
  kind: 'linux'
  properties: {
    reserved: true
  }
}

// Application Insights
resource applicationInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: applicationInsightsName
  location: location
  tags: tags
  kind: 'web'
  properties: {
    Application_Type: 'web'
    RetentionInDays: 30
    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Enabled'
  }
}

// App Service with advanced configuration
resource appService 'Microsoft.Web/sites@2023-01-01' = {
  name: appServiceName
  location: location
  tags: tags
  kind: 'app,linux'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    serverFarmId: appServicePlan.id
    httpsOnly: true
    siteConfig: {
      alwaysOn: true
      linuxFxVersion: 'DOTNETCORE|10.0'
      http20Enabled: true
      minTlsVersion: '1.2'
      appSettings: [
        {
          name: 'ASPNETCORE_ENVIRONMENT'
          value: environment
        }
        {
          name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
          value: applicationInsights.properties.ConnectionString
        }
        {
          name: 'ApplicationInsightsAgent_EXTENSION_VERSION'
          value: '~3'
        }
        {
          name: 'XDT_MicrosoftApplicationInsights_Mode'
          value: 'recommended'
        }
      ]
      connectionStrings: !empty(databaseConnectionString) ? [
        {
          name: 'DefaultConnection'
          connectionString: databaseConnectionString
          type: 'SQLAzure'
        }
      ] : []
    }
  }

  // VNet integration (if subnet provided)
  resource vnetConfig 'config@2023-01-01' = if (!empty(subnetId)) {
    name: 'virtualNetwork'
    properties: {
      subnetResourceId: subnetId
    }
  }
}

// Auto-scaling settings
resource autoscaleSettings 'Microsoft.Insights/autoscalesettings@2015-04-01' = if (enableAutoScaling) {
  name: autoscaleName
  location: location
  properties: {
    profiles: [
      {
        name: 'auto scale based on cpu'
        capacity: {
          minimum: string(minInstances)
          maximum: string(maxInstances)
          default: string(minInstances)
        }
        rules: [
          {
            metricTrigger: {
              metricName: 'CpuPercentage'
              metricResourceUri: appServicePlan.id
              timeGrain: 'PT1M'
              statistic: 'Average'
              timeWindow: 'PT5M'
              timeAggregation: 'Average'
              operator: 'GreaterThan'
              threshold: 70
            }
            scaleAction: {
              direction: 'Increase'
              type: 'ChangeCount'
              value: '1'
              cooldown: 'PT5M'
            }
          }
          {
            metricTrigger: {
              metricName: 'CpuPercentage'
              metricResourceUri: appServicePlan.id
              timeGrain: 'PT1M'
              statistic: 'Average'
              timeWindow: 'PT5M'
              timeAggregation: 'Average'
              operator: 'LessThan'
              threshold: 30
            }
            scaleAction: {
              direction: 'Decrease'
              type: 'ChangeCount'
              value: '1'
              cooldown: 'PT15M'
            }
          }
        ]
      }
    ]
    enabled: true
    targetResourceUri: appServicePlan.id
  }
}

// Grant managed identity access to Key Vault (if provided)
resource keyVaultAccessPolicy 'Microsoft.KeyVault/vaults/accessPolicies@2023-02-01' = if (!empty(keyVaultResourceId)) {
  name: '${last(split(keyVaultResourceId, '/'))}/add'
  properties: {
    accessPolicies: [
      {
        tenantId: subscription().tenantId
        objectId: appService.identity.principalId
        permissions: {
          keys: ['get', 'list']
          secrets: ['get', 'list']
          certificates: ['get', 'list']
        }
      }
    ]
  }
}

@description('App Service ID')
output appServiceId string = appService.id

@description('App Service URL')
output appServiceUrl string = 'https://${appService.properties.defaultHostName}'

@description('App Service Managed Identity Principal ID')
output managedIdentityPrincipalId string = appService.identity.principalId

@description('Application Insights Instrumentation Key')
output applicationInsightsKey string = applicationInsights.properties.InstrumentationKey
