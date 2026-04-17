# GA26 Demo - Architecture & Components

## Application Architecture

```
┌─────────────────────────────────────────────────────────────────────┐
│                          AZURE CLOUD                                 │
├─────────────────────────────────────────────────────────────────────┤
│                                                                       │
│  ┌──────────────────────────────────────────────────────────────┐   │
│  │                   App Service Plan                           │   │
│  │  ┌────────────────────────────────────────────────────────┐  │   │
│  │  │              App Service (Linux)                       │  │   │
│  │  │  ┌──────────────────────────────────────────────────┐  │  │   │
│  │  │  │   GA26Demo (.NET 8 Application)                 │  │  │   │
│  │  │  │                                                   │  │  │   │
│  │  │  │  • Program.cs (Main entry point)                │  │  │   │
│  │  │  │  • Controllers (HomeController)                 │  │  │   │
│  │  │  │  • Views (Razor, Bootstrap UI)                  │  │  │   │
│  │  │  │  • API endpoints (/api/config, /health)        │  │  │   │
│  │  │  │                                                   │  │  │   │
│  │  │  │  Environment Variables (from Bicep):            │  │  │   │
│  │  │  │  • ASPNETCORE_ENVIRONMENT                       │  │  │   │
│  │  │  │  • APP_NAME                                     │  │  │   │
│  │  │  │  • DEMO_VALUE  ← Main showcase value           │  │  │   │
│  │  │  └──────────────────────────────────────────────────┘  │  │   │
│  │  └────────────────────────────────────────────────────────┘  │   │
│  │                                                                │   │
│  │  SKU: B1 (Dev), P1V2 (Prod)                                   │   │
│  │  Runtime: .NET 8 on Linux                                     │   │
│  │  HTTPS: Enabled                                               │   │
│  │  Managed Identity: Enabled                                    │   │
│  └──────────────────────────────────────────────────────────────┘   │
│                                                                       │
│  ┌──────────────────────────────────────────────────────────────┐   │
│  │          Application Insights (Monitoring)                   │   │
│  │  • Telemetry collection from app                            │   │
│  │  • Performance metrics                                       │   │
│  │  • Requests and dependencies                                │   │
│  │  • Logs and exceptions                                      │   │
│  │  • Real User Monitoring (RUM)                               │   │
│  │  • 30-day retention                                          │   │
│  └──────────────────────────────────────────────────────────────┘   │
│                                                                       │
│  ┌──────────────────────────────────────────────────────────────┐   │
│  │       Storage Account (Diagnostics & Logs)                  │   │
│  │  • App Service diagnostics logs                              │   │
│  │  • HTTP logs for troubleshooting                             │   │
│  │  • Console logs                                              │   │
│  │  • Blob container: appservice-logs                           │   │
│  └──────────────────────────────────────────────────────────────┘   │
│                                                                       │
└─────────────────────────────────────────────────────────────────────┘
         │
         │ HTTPS
         ↓
    ┌─────────────┐
    │   Browser   │
    │  (You!)     │
    └─────────────┘
```

## Data Flow

```
USER
  │
  ├─→ https://app.azurewebsites.net/  (GET Home Page)
  │        │
  │        ├→ HomeController.Index()
  │        ├→ Reads config: APP_NAME, DEMO_VALUE, ENVIRONMENT
  │        ├→ Log to Application Insights
  │        └→ Render Index.cshtml with values
  │                │
  │                └→ Display on UI with Bootstrap styling
  │
  ├─→ clicks "Load from API"
  │        │
  │        ├→ /api/config (JSON REST API)
  │        ├→ Program.cs: MapGet endpoint
  │        ├→ Collect: AppName, DemoValue, Environment, Timestamp
  │        ├→ Log to Application Insights with trace
  │        └→ Return JSON response
  │                │
  │                └→ Display as formatted JSON in modal
  │
  └─→ https://app.azurewebsites.net/health  (Health Check)
           │
           ├→ Results.Ok({ status: "healthy" })
           └→ Used by load balancers, monitoring tools
```

## Infrastructure as Code (Bicep)

```
parameters.dev.bicepparam  ─────┐
                                 ├──→ main.bicep ──→ Azure Resources
parameters.prod.bicepparam ─────┘

Key Parameters:
┌─────────────────────────────────────────────────────┐
│ • appName: "ga26demo"                              │
│ • environment: "dev" or "prod"                     │
│ • location: "eastus" or other regions             │
│ • appServicePlanSku: "B1" (dev) or "P1V2" (prod) │
│ • demoValue: Display text (MAIN SHOWCASE!)        │
│ • enableApplicationInsights: true                   │
│ • tags: Metadata for organization                  │
└─────────────────────────────────────────────────────┘

Bicep Template generates:
┌─────────────────────────────────────────────────────┐
│ Azure Resources:                                    │
│ ├─ App Service Plan                               │
│ ├─ App Service                                    │
│ │  └─ Configuration (env vars, connection strings)│
│ ├─ Application Insights                           │
│ ├─ Storage Account                                │
│ └─ Diagnostic Settings                            │
│                                                    │
│ Outputs:                                           │
│ ├─ appServiceUrl                                  │
│ ├─ appServiceId                                   │
│ ├─ applicationInsightsKey                         │
│ └─ resourceGroupId                                │
└─────────────────────────────────────────────────────┘
```

## Deployment Process

```
┌──────────────────────────────────────────────────────────────┐
│ Step 1: Initialize                                           │
│ • Check Azure CLI login                                      │
│ • Verify subscriptions                                       │
│ • Create resource group                                      │
└──────────────────────────────────────────────────────────────┘
                              ↓
┌──────────────────────────────────────────────────────────────┐
│ Step 2: Build .NET Application                              │
│ • dotnet build (compile code)                               │
│ • dotnet publish -c Release (prepare for Azure)             │
│ • Output: src/publish/ folder                               │
└──────────────────────────────────────────────────────────────┘
                              ↓
┌──────────────────────────────────────────────────────────────┐
│ Step 3: Deploy Infrastructure (Bicep)                       │
│ • az deployment group create ...                            │
│ • Bicep template processed                                  │
│ • Azure resources created                                   │
│ • Configuration variables set                               │
│ • Application Insights connected                            │
│ • Diagnostics enabled                                       │
│ • Typically: 5-15 minutes                                   │
└──────────────────────────────────────────────────────────────┘
                              ↓
┌──────────────────────────────────────────────────────────────┐
│ Step 4: Application Startup                                 │
│ • App Service restarts                                      │
│ • .NET 8 runtime boots                                      │
│ • Program.cs executes                                       │
│ • Reads environment variables from Bicep                    │
│ • Application Insights SDK initializes                      │
│ • Typically: 1-2 minutes                                    │
└──────────────────────────────────────────────────────────────┘
                              ↓
                   ✅ Ready to Demo!
```

## Configuration Flow

```
┌─────────────────────────────────────────────────────────────────┐
│ Bicep Parameter Files                                           │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│ parameters.dev.bicepparam:                                      │
│ ┌────────────────────────────────────────────────────────────┐  │
│ │ param appName = "ga26demo"                                │  │
│ │ param environment = "dev"                                 │  │
│ │ param appServicePlanSku = "B1"                            │  │
│ │ param demoValue = "Dev Environment - Via Bicep" ← KEY   │  │
│ │ param location = "eastus"                                │  │
│ │ param tags = { environment: "dev", ... }                │  │
│ └────────────────────────────────────────────────────────────┘  │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│ Bicep Template Processing                                       │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│ main.bicep receives parameters and:                             │
│ • Generates resource names                                      │
│ • Creates App Service with configuration                        │
│ • Passes environment variables:                                 │
│   - ASPNETCORE_ENVIRONMENT = "dev"                             │
│   - APP_NAME = "ga26demo - dev"                                │
│   - DEMO_VALUE = "Dev Environment - Via Bicep"  ← DISPLAYED  │
│   - APPLICATIONINSIGHTS_CONNECTION_STRING = (auto)            │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│ Azure App Service Configuration                                 │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│ App Service "ga26demo-dev-app":                                 │
│ ├─ Application Settings (from Bicep):                           │
│ │  ├─ ASPNETCORE_ENVIRONMENT = "dev"                           │
│ │  ├─ APP_NAME = "... - dev"                                   │
│ │  ├─ DEMO_VALUE = "Dev Environment - Via Bicep"              │
│ │  └─ APPLICATIONINSIGHTS_CONNECTION_STRING = "..."            │
│ └─ Connection Strings (if configured)                          │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│ .NET Application Runtime                                        │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│ Program.cs & Runtime:                                           │
│ • IConfiguration automatically loads Azure env vars             │
│ • HomeController reads: config["DEMO_VALUE"]                    │
│ • Passes to View: ViewData["DemoValue"]                        │
│ • Displayed in UI: Shows the Bicep-configured value           │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│ User Interface                                                  │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│ Index.cshtml displays:                                          │
│ ┌─────────────────────────────────────────────────────────────┐│
│ │ Configuration Values *                                     ││
│ ├─────────────────────────────────────────────────────────────┤│
│ │ Application Name: ga26demo - dev                           ││
│ │ Environment: dev                                            ││
│ │ Demo Value (env var): Dev Environment - Via Bicep ← HERE ││
│ └─────────────────────────────────────────────────────────────┘│
│                                                                  │
│ * Click "Load from API" to see full JSON config               │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

## Multi-Environment Architecture

```
Same Application Code + Different Infrastructure Configuration:

CODE: src/ (GA26Demo .NET application)
  │
  ├──────────────┬──────────────┐
  │              │              │
  ↓              ↓              ↓
Local         Dev             Prod
Development   Environment     Environment

LOCAL:
  • appsettings.json (local defaults)
  • dotnet run (local machine)
  • localhost:5001

DEV (Azure):
  • infra/parameters.dev.bicepparam
  • main.bicep + parameters
  • App Service Plan: B1 (cheap)
  • DEMO_VALUE: "Development"
  • Monitor via Application Insights

PROD (Azure):
  • infra/parameters.prod.bicepparam
  • main.bicep + parameters
  • App Service Plan: P1V2 (fast)
  • DEMO_VALUE: "Production"
  • Enhanced monitoring
  • Better performance
  • All resource identical setup pattern
```

## Key Messaging Points

```
┌─────────────────────────────────────────────────────────────────┐
│ "This is Infrastructure as Code in Action"                     │
│                                                                  │
│ • Same .NET application code                                    │
│ • Same Bicep infrastructure template                            │
│ • Different parameters → different Azure resources              │
│ • This DEMO_VALUE changes easily by updating parameter         │
│ • No manual Azure Portal clicking → fully automated             │
│ • Version controlled ✓                                          │
│ • Reproducible ✓                                                │
│ • Environment parity ✓                                          │
│ • Enterprise ready ✓                                            │
└─────────────────────────────────────────────────────────────────┘
```

## Resource Group Post-Deployment

```
Resource Group: rg-ga26demo-dev

├─ App Service Plan "ga26demo-dev-plan"
│  └─ Status: Active
│
├─ App Service "ga26demo-dev-app"
│  ├─ Configuration Settings (set by Bicep)
│  ├─ Environment Variables
│  ├─ System Assigned Identity
│  └─ Status: Running
│
├─ Application Insights "ga26demo-dev-ai"
│  ├─ Instrumentation Key: (auto-generated)
│  ├─ Retention: 30 days
│  └─ Monitoring: Enabled
│
└─ Storage Account "sag26demdedevelop...."
   ├─ Blob Containers
   │  └─ appservice-logs/
   │     ├─ Console logs
   │     ├─ HTTP logs
   │     └─ HTTP trace logs
   └─ Diagnostic Settings: Enabled
```

---

This architecture ensures a professional, scalable, and demonstrable solution for showcasing Azure App Services and IaC with Bicep!
