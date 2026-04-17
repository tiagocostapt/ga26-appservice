# GA26 Demo - Quick Reference Guide

## 🚀 Quick Start Commands

```bash
# Build locally
cd src && dotnet build

# Run locally
dotnet run

# After running, visit: https://localhost:5001

# Deploy to Azure (dev)
./deploy.sh dev

# Deploy to Azure (prod)
./deploy.sh prod

# Cleanup Azure resources
az group delete --name rg-ga26demo-dev --yes
```

## 📊 Useful Azure CLI Commands

```bash
# Login to Azure
az login

# List all subscriptions
az account list

# Set active subscription
az account set --subscription "subscription-name"

# List resource groups
az group list

# List all resources in a resource group
az resource list --resource-group rg-ga26demo-dev

# Get App Service details
az appservice plan list --resource-group rg-ga26demo-dev
az webapp list --resource-group rg-ga26demo-dev

# Get App Service URL
az webapp show --resource-group rg-ga26demo-dev \
  --name ga26demo-dev-app \
  --query "defaultHostName" --output tsv

# View deployment history
az deployment group list --resource-group rg-ga26demo-dev

# View deployment details
az deployment group show --resource-group rg-ga26demo-dev \
  --name <deployment-name>

# Enable Application Insights
az monitor app-insights component connect-webapp \
  --app <app-service-name> \
  --resource-group <resource-group>
```

## 🔍 Useful URLs After Deployment

Assuming app is deployed as `ga26demo-dev-app`:

- **Main App**: `https://ga26demo-dev-app.azurewebsites.net/`
- **API Config**: `https://ga26demo-dev-app.azurewebsites.net/api/config`
- **Health Check**: `https://ga26demo-dev-app.azurewebsites.net/health`
- **Azure Portal**: `https://portal.azure.com/`
- **Application Insights**: Search for `ga26demo-dev-ai` in Portal

## 📝 Configuration Files Quick Reference

| File | Purpose | Editable Demo Value |
|------|---------|---------------------|
| `infra/parameters.dev.bicepparam` | Dev environment variables | `demoValue` |
| `infra/parameters.prod.bicepparam` | Prod environment variables | `demoValue` |
| `src/appsettings.json` | Local defaults | `DEMO_VALUE` |
| `src/Program.cs` | App configuration & endpoints | API responses |
| `src/Views/Home/Index.cshtml` | UI display | Shown values |

## 🔧 Making a Quick Change to Demo

To change the `DEMO_VALUE` displayed:

1. **Edit parameter file**:
   ```bash
   nano infra/parameters.dev.bicepparam
   # Change: param demoValue = 'New value here'
   ```

2. **Redeploy**:
   ```bash
   ./deploy.sh dev
   ```

3. **Refresh app** - Wait 2-3 min, then refresh browser

## 📊 Monitoring from Azure Portal

1. Navigate to `https://portal.azure.com`
2. Search for resource group: `rg-ga26demo-dev`
3. Click on resource group
4. View resources:
   - **App Service Plan**: Shows compute resources
   - **App Service**: Main application resource
   - **Application Insights**: Monitoring & analytics
   - **Storage Account**: Logs & diagnostics

## 🏃 Performance Tips

- **First deployment**: 5-15 minutes (normal)
- **App startup**: 1-2 minutes after deployment
- **Cold start**: First request slower (app spinup)
- **Scaling up**: Change SKU, then redeploy
- **Debugging**: Check Application Insights → Failures

## 🐛 Common Issues & Solutions

| Issue | Command to Check | Solution |
|-------|-----------------|----------|
| App won't start | `az webapp log tail -g rg-ga26demo-dev -n ga26demo-dev-app` | Check logs for errors |
| Deployment fails | `az deployment group show -g rg-ga26demo-dev -n <deployment>` | Review error details |
| Can't reach app | `curl https://ga26demo-dev-app.azurewebsites.net/health` | Wait 2-3 min, check status |
| API returns 500 | Application Insights Failures tab | Check exception details |
| Old config still showing | Clear browser cache | Cache can hide new values |

## 💰 Cost Estimation

Typical demo costs (per day):

| Component | SKU | Approx Cost/Day |
|-----------|-----|-----------------|
| App Service Plan (dev) | B1 | $0.06 |
| App Service Plan (prod) | P1V2 | $0.35 |
| Application Insights | 1GB/day | $0.30 |
| Storage Account | Standard | $0.05 |
| **Total (dev)** | | **~$0.41/day** |
| **Total (prod)** | | **~$0.70/day** |

**Remember**: Always clean up with `az group delete` when done!

## 📚 File Locations for Reference

```
GA26 Demo Files Location Reference:

Application Code:
  - src/Program.cs ..................... Main app setup
  - src/Controllers/HomeController.cs .. Controller logic
  - src/Views/Home/Index.cshtml ........ Home page UI
  - src/appsettings.json .............. Configuration

Infrastructure Code:
  - infra/main.bicep .................. Bicep template
  - infra/parameters.dev.bicepparam ... Dev parameters
  - infra/parameters.prod.bicepparam .. Prod parameters
  - infra/main.advanced.bicep ......... Advanced example

Deployment & Scripts:
  - deploy.sh ......................... Bash deployment
  - deploy.ps1 ........................ PowerShell deployment
  - validate.sh ....................... Project validation
  - Makefile .......................... Common tasks

Documentation:
  - README.md ......................... Main documentation
  - DEMO_INSTRUCTIONS.md .............. Demo guide
  - QUICK_REFERENCE.md ............... This file
  - FAQ.md ........................... Common questions
```

## 🎯 Key Concepts to Remember

1. **Environment Variables**: Set in Bicep, read by app
2. **Infrastructure as Code**: Bicep templates define infrastructure
3. **Parameters**: Different values for different environments
4. **Managed Identity**: App can access Azure services
5. **Application Insights**: Monitoring built-in
6. **Multi-environment**: Same template, different parameters

## 💡 Pro Tips

1. **Use the Makefile**:
   ```bash
   make help          # See all commands
   make build         # Quick build
   make deploy-dev    # One-command deploy
   ```

2. **Check deployment outputs**:
   ```bash
   # Get app URL from deployment
   az deployment group show -g rg-ga26demo-dev \
     -n <deployment-name> \
     --query properties.outputs.appServiceUrl.value
   ```

3. **Monitor in real-time**:
   ```bash
   # Stream logs
   az webapp log tail -g rg-ga26demo-dev -n ga26demo-dev-app
   ```

4. **Test endpoints**:
   ```bash
   curl https://ga26demo-dev-app.azurewebsites.net/health
   curl https://ga26demo-dev-app.azurewebsites.net/api/config
   ```

## 📞 Support Resources

- [Azure App Service Docs](https://learn.microsoft.com/en-us/azure/app-service/)
- [Bicep Docs](https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/)
- [.NET Documentation](https://learn.microsoft.com/en-us/dotnet/)
- [Application Insights](https://learn.microsoft.com/en-us/azure/azure-monitor/app/app-insights-overview)
