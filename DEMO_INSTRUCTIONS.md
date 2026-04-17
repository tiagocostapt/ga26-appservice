# GA26 Demo Instructions

This file contains step-by-step instructions for demonstrating the GA26 Azure App Services with Bicep IaC demo.

## Pre-Demo Checklist

- [ ] Have Azure subscription with budget available (~$20-50 for demo resources)
- [ ] Azure CLI installed and configured (`az login`)
- [ ] .NET 8 SDK installed
- [ ] Script dependencies: Bash/PowerShell shells with execution rights
- [ ] Network: Good internet connection for live deployment
- [ ] Credentials: Azure account with Contributor role on subscription

## Demo Flow (Estimated Time: 15-20 minutes)

### Part 1: Code Overview (3 minutes)

1. **Show the project structure**
   ```bash
   tree -L 2 --gitignore
   ```
   
2. **Highlight key files:**
   - Point to `src/Program.cs` - Application entry point with
     - App configuration
     - API endpoint setup (/api/config)
     - Health check endpoint
   
   - Show `src/Views/Home/Index.cshtml` - UI that displays demo values
   
   - Point to `src/Controllers/HomeController.cs` - Reading environment variables

3. **Key talking points:**
   - "The app is simple on purpose - it's designed to showcase configuration"
   - "Notice how it reads from environment variables: APP_NAME, DEMO_VALUE"
   - "No hardcoded values - everything comes from configuration"

### Part 2: Local Run (3 minutes)

1. **Build the application**
   ```bash
   cd src
   dotnet build
   ```

2. **Run locally**
   ```bash
   dotnet run
   ```

3. **Access the application**
   - Open browser to `https://localhost:5001`
   - Show the default configuration values
   - Click "Load from API" button to show the `/api/config` endpoint
   - Point out how the values match what's shown on the page

4. **Key talking points:**
   - "This is running locally, using local configuration"
   - "The app has two ways to view config: UI and REST API"
   - "Ready to show how this runs in Azure"

### Part 3: Bicep Infrastructure (4 minutes)

1. **Open `infra/main.bicep` and walk through:**

   ```bicep
   # Top section - Metadata and Parameters
   - metadata description      # What this template does
   - @param appName           # Application name (parameterized)
   - @param environment       # Environment (dev/prod - parameterized)
   - @param demoValue         # THIS IS THE KEY DEMO VALUE
   ```

   **Key talking points:**
   - "Bicep is declarative - we describe WHAT we want, not HOW"
   - "Everything is parameterized - same template for dev, staging, prod"
   - "The demoValue parameter comes from our parameter files"

2. **Point out main resources:**
   - App Service Plan (Linux, .NET 8)
   - App Service (HTTPS, managed identity)
   - Application Insights (monitoring)
   - Storage Account (diagnostics)

3. **Show how configuration is passed:**
   - Scroll to `appSettings` array in App Service resource
   - Show `DEMO_VALUE` being set from parameter
   - Show `APP_NAME` and `ASPNETCORE_ENVIRONMENT` being set

4. **Compare parameter files**
   ```bash
   # Show dev vs prod configurations
   diff infra/parameters.dev.bicepparam infra/parameters.prod.bicepparam
   ```
   
   **Key talking points:**
   - "Same infrastructure template, different parameters"
   - "Dev uses B1 (cheap), Prod uses P1V2 (fast)"
   - "Configuration values are specific to each environment"

### Part 4: Deployment (6-7 minutes)

1. **Login to Azure (if needed)**
   ```bash
   az login
   ```

2. **Start the deployment**
   ```bash
   # For Linux/Mac:
   chmod +x deploy.sh
   ./deploy.sh dev

   # For Windows PowerShell:
   .\deploy.ps1 -Environment dev
   ```

   **During deployment, explain what's happening:**
   - "Building the .NET application for release"
   - "Publishing it for deployment"
   - "Creating resource group in Azure"
   - "Deploying Bicep template (5-10 min typically)"

3. **While waiting, you can:**
   - Open Azure Portal in another tab
   - Show resource group being created
   - Show resources appearing as they're deployed

4. **When deployment completes:**
   - Note the App Service URL from the output
   - Copy the URL

### Part 5: Live Application (2-3 minutes)

1. **Navigate to the deployed app**
   - Paste the URL from deployment output
   - Show the application is running in App Service
   - Show the configuration values (now from ENVIRONMENT variables)
   - Show the DEMO_VALUE specifically: "Development Environment - Deployed via Bicep"

2. **Test the API endpoint**
   - Click "Load from API" button
   - Show JSON response with full configuration
   - Highlight DEMO_VALUE in the response

3. **Check Health endpoint**
   ```bash
   curl https://{app-url}/health
   ```

4. **Key talking points:**
   - "Same code, but now config comes from Azure App Service"
   - "The DEMO_VALUE is set by our Bicep template"
   - "This shows how to easily pass environment-specific config"

### Part 6: Monitoring (2 minutes)

1. **Open Azure Portal**
   - Navigate to the Resource Group
   - Show all resources created:
     - App Service Plan
     - App Service
     - Application Insights
     - Storage Account

2. **Click on Application Insights**
   - Show Application map
   - Show recent requests
   - Show performance metrics
   - Mention automatic instrumentation
   - Show that DEMO_VALUE change would require IaC update

3. **Optional: Show Activity Log**
   - Display deployment history
   - Show resources created

### Part 7: Key Takeaway - IaC Flexibility (1 minute)

1. **Demonstrate IaC value:**
   ```bash
   # Would show this if time allowed:
   # 1. Edit infra/parameters.dev.bicepparam
   # 2. Change: param demoValue = 'My Custom Demo Value'
   # 3. Re-run: ./deploy.sh dev
   # 4. Refresh app - new value appears
   # 5. SAME CODE, just configuration changed via IaC
   ```

2. **Talking points:**
   - "Infrastructure and configuration as code"
   - "Reproducible deployments"
   - "Version controlled"
   - "Environment parity"
   - "Easy to add new environments"

## Cleanup

At the end of demo:

```bash
# Remove development environment
az group delete --name rg-ga26demo-dev --yes

# Or for PowerShell:
Remove-AzResourceGroup -Name rg-ga26demo-dev -Force
```

## Troubleshooting During Demo

| Issue | Solution |
|-------|----------|
| Deployment fails | Check `az account show`, retry deployment |
| App doesn't load | Wait 2-3 min, may need to restart app service |
| API endpoint 500 | Check Application Insights for errors |
| Slow deployment | Normal (5-15 min), grab coffee |
| Can't see resources | May need portal refresh |

## Demo Script Summary

```
"Let me show you how to deploy a .NET app to Azure using Infrastructure as Code.

We have a simple ASP.NET Core application that reads configuration from environment variables. 
You can see it displays DEMO_VALUE - this is what we'll showcase.

The real magic is in our Bicep template. It's got all the infrastructure defined: 
App Service Plan, App Service with specific configuration, Application Insights for monitoring.

Notice the DEMO_VALUE is a parameter - can be different for dev, staging, production.

Let me deploy this to Azure... [run deploy script]

And there we go! Our app is now running in Azure App Services. You can see it's using 
the DEMO_VALUE from our Bicep parameters. 

This is Infrastructure as Code in action: same template, different parameters, 
reproducible deployments, completely version controlled."
```

## Tips for Great Demo

1. **Practice beforehand** - Run through locally at least once
2. **Have a backup plan** - If network is slow, show recorded demo video
3. **Highlight the value** - IaC means no manual Azure Portal clicking
4. **Show multi-environment** - This is huge value of Bicep
5. **Keep focus on demo value** - Simple is better than complex features
6. **Have Q&A ready** - Know answers about cost, scaling, security
7. **Mention what's NOT shown** - Database connections, Key Vault, VNet integration
8. **Show Application Insights** - Monitoring is important for production

## Post-Demo Follow-up

- Share the GitHub repo link
- Provide parameter examples
- Show how to add Key Vault integration
- Discuss cost optimization
- Talk about CI/CD pipeline integration
