metadata description = 'GA26 Demo: Azure App Service with Infrastructure as Code using Bicep'

@description('The name of the application')
param appName string

@description('Environment name (dev, staging, prod)')
param environment string

@description('Location for all resources')
param location string = resourceGroup().location

@description('SKU for App Service Plan')
param appServicePlanSku string = 'B1'

@description('Demo value to be displayed in the application')
param demoValue string = 'Deployed via Bicep IaC'

@description('Enable Application Insights')
param enableApplicationInsights bool = true

@description('Tags for all resources')
param tags object = {
  environment: environment
  createdBy: 'Bicep'
  project: 'GA26Demo'
}

// Generate unique suffix for storage account (must be globally unique)
var uniqueSuffix = substring(uniqueString(resourceGroup().id), 0, 8)

// Resource names
var appServicePlanName = '${appName}-${environment}-plan'
var appServiceName = '${appName}-${environment}-app'
var applicationInsightsName = '${appName}-${environment}-ai'
var storageAccountName = 'sa${appName}${environment}${uniqueSuffix}'

// App Service Plan
resource appServicePlan 'Microsoft.Web/serverfarms@2023-01-01' = {
  name: appServicePlanName
  location: location
  tags: tags
  sku: {
    name: appServicePlanSku
    capacity: 1
  }
  kind: 'linux'
  properties: {
    reserved: true
  }
}

// Application Insights
resource applicationInsights 'Microsoft.Insights/components@2020-02-02' = if (enableApplicationInsights) {
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

// App Service
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
      defaultDocuments: [
        'index.html'
      ]
      appSettings: [
        {
          name: 'ASPNETCORE_ENVIRONMENT'
          value: environment
        }
        {
          name: 'APP_NAME'
          value: '${appName} - ${environment}'
        }
        {
          name: 'DEMO_VALUE'
          value: demoValue
        }
        {
          name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
          value: enableApplicationInsights ? applicationInsights!.properties.ConnectionString : ''
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
      connectionStrings: []
    }
  }

  // Web app settings
  resource webConfig 'config@2023-01-01' = {
    name: 'web'
    properties: {
      numberOfWorkers: 1
      requestTracingEnabled: false
      remoteDebuggingEnabled: false
      httpLoggingEnabled: true
      detailedErrorLoggingEnabled: true
      publishingUsername: appService.name
    }
  }
}

// Storage Account for diagnostics (optional)
resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: storageAccountName
  location: location
  tags: tags
  kind: 'StorageV2'
  sku: {
    name: 'Standard_LRS'
  }
  properties: {
    accessTier: 'Hot'
    allowBlobPublicAccess: false
    minimumTlsVersion: 'TLS1_2'
  }

  // Blob services for diagnostics
  resource blobServices 'blobServices@2023-01-01' = {
    name: 'default'
    resource diagnosticsContainer 'containers' = {
      name: 'appservice-logs'
      properties: {
        publicAccess: 'None'
      }
    }
  }
}

// Diagnostic Settings for App Service
resource appServiceDiagnostics 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (enableApplicationInsights) {
  name: 'appservice-diagnostics'
  scope: appService
  properties: {
    storageAccountId: storageAccount.id
    logs: [
      {
        category: 'AppServiceHTTPLogs'
        enabled: true
      }
      {
        category: 'AppServiceConsoleLogs'
        enabled: true
      }
    ]
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
      }
    ]
  }
}

@description('App Service ID')
output appServiceId string = appService.id

@description('App Service default hostname')
output appServiceHostname string = appService.properties.defaultHostName

@description('App Service URL')
output appServiceUrl string = 'https://${appService.properties.defaultHostName}'

@description('Application Insights Instrumentation Key')
output applicationInsightsKey string = enableApplicationInsights ? applicationInsights!.properties.InstrumentationKey : ''

@description('Application Insights Connection String')
output applicationInsightsConnectionString string = enableApplicationInsights ? applicationInsights!.properties.ConnectionString : ''

@description('Resource Group ID')
output resourceGroupId string = resourceGroup().id

@description('Storage Account ID')
output storageAccountId string = storageAccount.id
