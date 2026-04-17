# GA26 Demo: Azure App Services with Infrastructure as Code (Bicep)

A comprehensive demonstration of deploying a .NET application to Azure App Services using Infrastructure as Code with Bicep.

## 🎯 Overview

This demo showcases:

- **Azure App Services** - Hosting a .NET application on Linux
- **Infrastructure as Code** - Bicep templates for reproducible deployments
- **Environment-based Configuration** - Easy demo value display using environment variables
- **Application Insights** - Built-in monitoring and diagnostics
- **Multiple Environments** - Dev and Production configurations
- **Automated Deployment** - Scripts for easy deployment

## 📁 Project Structure

```
ga26-appservice/
├── src/                          # .NET Application
│   ├── GA26Demo.csproj          # Project file
│   ├── Program.cs               # Main application setup
│   ├── Controllers/
│   │   └── HomeController.cs    # Home page controller
│   ├── Views/
│   │   ├── Home/
│   │   │   └── Index.cshtml     # Home page view
│   │   └── Shared/
│   │       ├── _Layout.cshtml   # Master layout
│   │       ├── _ViewStart.cshtml
│   │       └── _ViewImports.cshtml
│   ├── appsettings.json         # Default configuration
│   └── appsettings.Production.json
│
├── infra/                        # Bicep Infrastructure
│   ├── main.bicep               # Main infrastructure template
│   ├── parameters.dev.bicepparam    # Development parameters
│   └── parameters.prod.bicepparam   # Production parameters
│
├── deploy.sh                     # Bash deployment script
├── deploy.ps1                    # PowerShell deployment script
└── README.md                     # This file
```

## 🚀 Quick Start

### Prerequisites

- **Azure Account** with an active subscription
- **Azure CLI** installed ([Install Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli))
- **.NET 8 SDK** installed ([Download .NET](https://dotnet.microsoft.com/en-us/download/dotnet/8.0))
- **Bash** or **PowerShell** (for running deployment scripts)

### Local Development

1. **Clone and navigate to the repository**
   ```bash
   cd /workspaces/ga26-appservice
   ```

2. **Build the application**
   ```bash
   cd src
   dotnet build
   ```

3. **Run locally**
   ```bash
   dotnet run
   ```
   The application will be available at `https://localhost:5001`

4. **View the demo**
   - Navigate to the home page to see the default demo values
   - Click "Load from API" button to see configuration from `/api/config` endpoint
   - Check the health endpoint at `/health`

### Deploy to Azure

#### Using Bash Script

```bash
# Deploy to development environment
./deploy.sh dev eastus

# Deploy to production environment
./deploy.sh prod eastus
```

#### Using PowerShell Script

```powershell
# Deploy to development environment
.\deploy.ps1 -Environment dev

# Deploy to production environment
.\deploy.ps1 -Environment prod -Location westus
```

#### Manual Deployment with Azure CLI

```bash
# Login to Azure
az login

# Create resource group
az group create --name rg-ga26demo-dev --location eastus

# Deploy Bicep template
az deployment group create \
  --resource-group rg-ga26demo-dev \
  --template-file infra/main.bicep \
  --parameters infra/parameters.dev.bicepparam
```

## 📋 Environment Variables

The application reads configuration from environment variables set by Azure App Service:

| Variable | Description | Example |
|----------|-------------|---------|
| `ASPNETCORE_ENVIRONMENT` | ASP.NET Core environment | `Production`, `Development` |
| `APP_NAME` | Application name | `GA26 Demo Application - dev` |
| `DEMO_VALUE` | Custom value to showcase | `Development Environment - Deployed via Bicep` |
| `APPLICATIONINSIGHTS_CONNECTION_STRING` | Application Insights connection | (Auto-set) |

These are configured in the Bicep template and can be customized per environment.

## 🏗️ Bicep Infrastructure

### What Gets Deployed

The `main.bicep` template deploys:

1. **App Service Plan** - Linux-based compute resource
   - Dev: B1 (Basic)
   - Prod: P1V2 (Premium)

2. **App Service** - Hosts the .NET application
   - HTTPS enforcement
   - .NET 8 runtime
   - System-assigned managed identity
   - Application Insights integration

3. **Application Insights** - Monitoring and diagnostics
   - 30-day retention
   - Real User Monitoring (RUM)
   - Dependency tracking

4. **Storage Account** - Logs and diagnostics
   - Premium LRS storage
   - Blob container for logs
   - Diagnostic settings for App Service

### Parameterization

Different parameter files for different environments:

**Development** (`parameters.dev.bicepparam`):
- App Service Plan: B1 (cost-effective)
- Auto-scaling: Single instance
- Region: eastus

**Production** (`parameters.prod.bicepparam`):
- App Service Plan: P1V2 (high-performance)
- Custom demo value for prod environment
- Same regions for compliance

## 📊 Demonstrating the Application

The demo app is designed to easily showcase Azure App Services:

### Home Page Features

1. **Configuration Display** - Shows environment-based values
2. **API Endpoint** - Button to fetch full configuration from `/api/config`
3. **Health Check** - Endpoint at `/health` for monitoring
4. **Bootstrap UI** - Modern, responsive interface

### Key Showcase Points

1. **Open the app** - Show the home page with configuration values
2. **Click the button** - Fetch configuration from the API endpoint
3. **Show Application Insights** - Navigate to Azure Portal to show monitoring
4. **Change environment variable** - Update `DEMO_VALUE` and redeploy to show IaC flexibility
5. **Review Bicep template** - Show how infrastructure is defined as code

## 🔍 Monitoring

### Azure Portal

After deployment, monitor your application:

1. **Open the Resource Group** - `rg-ga26demo-{env}`
2. **Application Insights** - View metrics, logs, and diagnostics
3. **App Service** - Check performance, quotas, and deployments
4. **Activity Log** - Review deployment history

### Application Insights Queries

Common KQL queries in Application Insights:

```kusto
// Recent requests
requests
| top 100 by timestamp desc

// Failed requests
requests
| where success == false

// Custom events
customEvents
| where name == "Config requested"

// Performance metrics
performanceCounters
| where counterName == "Request Duration"
```

## 🛠️ Customization

### Change the Demo Value

To showcase how environment variables work:

1. Edit `infra/parameters.dev.bicepparam`:
   ```bicepparam
   param demoValue = 'Custom Demo Value Here'
   ```

2. Redeploy:
   ```bash
   ./deploy.sh dev
   ```

3. Visit the application - the new value will be displayed

### Change the Application Behavior

Edit `src/Program.cs` to modify:
- API endpoints
- Configuration display
- Health checks

Then rebuild and redeploy:
```bash
cd src && dotnet publish -c Release -o ./publish
```

### Modify Infrastructure

Edit `infra/main.bicep` to add:
- Additional resources (Database, Key Vault, etc.)
- Custom domains
- VNet integration
- Scaling rules

## 📝 Key Bicep Concepts Demonstrated

This template showcases Bicep best practices:

1. **Metadata** - Description at top of file
2. **Parameters** - Configurable inputs with descriptions
3. **Variables** - Computed values (e.g., resource naming)
4. **Resources** - Declarative resource definitions
5. **Symbolic References** - Using resource IDs without string concatenation
6. **Nested Resources** - Child resources defined within parent
7. **Conditional Deployment** - `if` expressions for optional resources
8. **Output Values** - Return important information for reference
9. **Comments** - Inline documentation

## 🧹 Cleanup

To avoid ongoing charges, delete the resource group:

```bash
# Remove development environment
az group delete --name rg-ga26demo-dev --yes

# Remove production environment
az group delete --name rg-ga26demo-prod --yes
```

## 📚 Learning Resources

- [Azure App Service Documentation](https://learn.microsoft.com/en-us/azure/app-service/)
- [Bicep Language Documentation](https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/overview)
- [Application Insights Documentation](https://learn.microsoft.com/en-us/azure/azure-monitor/app/app-insights-overview)
- [ASP.NET Core on App Service](https://learn.microsoft.com/en-us/azure/app-service/quickstart-dotnetcore)

## 🎓 Demo Script

When demoing this application:

1. **Show the code structure** - Walk through the project layout
2. **Run locally** - `dotnet run` and show the application
3. **Explain the Bicep template** - Walk through `main.bicep`
4. **Deploy** - Run `./deploy.sh dev` to show IaC in action
5. **Access the app** - Show the live application in App Service
6. **Check monitoring** - Show Application Insights
7. **Modify a value** - Update parameter and redeploy to show IaC flexibility
8. **Cleanup** - Delete resources with `az group delete`

## 🤝 Support

For issues or questions:
- Check Azure App Service troubleshooting
- Review Bicep syntax validation
- Check Application Insights logs for runtime errors

## 📄 License

This demo is provided as-is for educational purposes.
