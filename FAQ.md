# GA26 Demo - Frequently Asked Questions (FAQ)

## General Questions

### What is this demo about?

This demo showcases deploying a .NET application to Azure App Services using Infrastructure as Code (Bicep). It demonstrates:
- Azure App Services capabilities
- Infrastructure as Code best practices
- Environment-based configuration
- Easy deployment automation
- Application monitoring with Application Insights

### Who is this demo for?

- Architects and developers learning Azure App Services
- Teams adopting Infrastructure as Code
- People interested in Bicep and IaC
- .NET developers deploying to Azure
- Anyone wanting a complete, production-ready example

### How long does deployment take?

Typical deployment times:
- First deployment: 5-15 minutes (Azure resources being created)
- App startup: 1-2 minutes after deployment
- Subsequent deployments: 3-8 minutes
- Cold start (first request): 15-30 seconds

During the demo, grab coffee during the deployment phase!

## Technical Questions

### What version of .NET is used?

.NET 8 (latest LTS). You can change this in:
- `src/GA26Demo.csproj` (TargetFramework)
- `infra/main.bicep` (linuxFxVersion)

### Can I use Windows for development?

Yes! The app runs cross-platform. Only requirement is .NET 8 SDK.

The Bicep template deploys to Linux App Service, not Windows. To use Windows:
- Change `kind` from `linux` to `windows` in Bicep
- Change `linuxFxVersion` to `windowsFxVersion` with appropriate value

### Why use Bicep instead of ARM templates or Terraform?

Bicep advantages for this demo:
- Native Azure language (simpler syntax than JSON)
- No external DSL to learn
- Supports all Azure resources
- Easy parameters and reuse
- Great for enterprises using Azure

### Can I add a database to this demo?

Yes! The `main.advanced.bicep` template shows how to:
1. Add database connection string parameter
2. Pass it to app as configuration
3. Use it in the application

Just modify `appsettings.json` to read the connection string.

### How do I use a custom domain?

1. Register domain in Azure or elsewhere
2. Add custom domain in App Service settings (Azure Portal)
3. Configure DNS CNAME record: `app → {appname}.azurewebsites.net`
4. Update Bicep template with domain configuration (optional)

### Can I scale the application?

Two ways:

**1. Manual scaling** (change SKU):
```bash
# Edit Bicep parameter in parameters.dev.bicepparam
param appServicePlanSku = 'S1'  # Change from B1

# Redeploy
./deploy.sh dev
```

**2. Auto-scaling** (use advanced template):
```bash
az deployment group create \
  --resource-group rg-ga26demo-dev \
  --template-file infra/main.advanced.bicep \
  --parameters infra/parameters.dev.bicepparam
```

## Configuration Questions

### How do I change the DEMO_VALUE?

1. The DEMO_VALUE is set in Bicep parameter files:
   ```bicepparam
   param demoValue = 'Your custom value here'
   ```

2. Three places to edit:
   - `infra/parameters.dev.bicepparam` (development)
   - `infra/parameters.prod.bicepparam` (production)
   - `src/appsettings.json` (local only)

3. Redeploy after changing:
   ```bash
   ./deploy.sh dev  # For development
   ```

### Can environment variables be changed after deployment?

Yes, directly in Azure Portal:
1. Go to App Service
2. Settings → Configuration
3. Edit application settings (App settings section)
4. Save changes (app will restart)

But the IaC advantage is: next deployment will revert to Bicep values!

### How do I add more environment variables?

In `infra/main.bicep`, find the `appSettings` array:
```bicep
appSettings: [
  ...existing settings...
  {
    name: 'MY_NEW_VAR'
    value: 'my value'
  }
]
```

Then in `src/Program.cs`:
```csharp
var myValue = config["MY_NEW_VAR"];
```

## Deployment Questions

### What if deployment fails?

1. Check the error message carefully
2. Common issues:
   - Not logged in to Azure: `az login`
   - Wrong subscription: `az account set --subscription "name"`
   - Resource group exists: Creates are idempotent, should retry
   - Permission denied: Need Contributor role

3. Debug deployment:
   ```bash
   az deployment group show --resource-group rg-ga26demo-dev \
     -n <deployment-name> \
     --query "properties.error"
   ```

### Can I deploy to different regions?

Yes, pass as parameter:
```bash
./deploy.sh dev westeurope   # Deploy to Europe
./deploy.sh prod eastus      # Deploy to US East
```

Or edit the region in parameter file:
```bicepparam
param location = 'westeurope'
```

### How do I delete all resources?

One command:
```bash
az group delete --name rg-ga26demo-dev --yes  # Delete and confirm
```

This deletes the resource group and everything in it.

### Can I rename the application?

Yes, edit the `appName` parameter:

1. In `deploy.sh`:
   ```bash
   az deployment group create \
     --parameters appName='myappname' ...
   ```

2. Or in parameter files:
   ```bicepparam
   param appName = 'myappname'
   ```

**Note**: App names must be globally unique (Azure requirement).

## Monitoring Questions

### Where do I see application logs?

1. **Real-time logs**:
   ```bash
   az webapp log tail --resource-group rg-ga26demo-dev \
     --name ga26demo-dev-app
   ```

2. **Application Insights**:
   - Portal → Resource Group → Application Insights resource
   - View: Failures, Performance, Logs, etc.

3. **Storage logs** (if enabled):
   - Portal → Resource Group → Storage Account → Blob containers

### How do I see the API requests?

**Application Insights**:
1. Open Azure Portal
2. Resource Group → Application Insights resource
3. Click "Failures" or "Performance"
4. See all requests, response times, dependencies

### How do I monitor costs?

1. Azure Portal → Subscriptions → Cost Management
2. Resource Group → Cost Analysis
3. Typical costs: $0.41/day (dev), $0.70/day (prod)

**Save money**:
- Delete resources when not using
- Use B1/B2 for non-production
- Set up budget alerts

## Development Questions

### Can I run locally without Docker?

Yes! Requirements are just:
- .NET 8 SDK
- (Optional) Azure CLI for deployment

Then:
```bash
cd src
dotnet run
```

Access at `https://localhost:5001`

### Can I use VS Code for development?

Yes, it's perfect! Use these extensions:
- C# Dev Kit
- Bicep (official Azure extension)
- Azure Tools
- REST Client

### Can I add authentication to the app?

Yes! Add authentication middleware to `src/Program.cs`:
```csharp
builder.Services.AddAuthentication(/* options */);
app.UseAuthentication();
```

Common options:
- Azure AD / Entra ID
- OAuth 2.0
- OpenID Connect
- API Keys

### How do I add a database?

1. Create database in Azure (SQL Database, Cosmos DB, PostgreSQL, etc.)
2. Add connection string to Bicep template
3. Pass to app as configuration
4. Update `appsettings.json` to use it
5. Update `Program.cs` to connect

Example included in `main.advanced.bicep`.

## Security Questions

### How do I secure the application?

Multiple layers:
1. **HTTPS enforcement** (already configured)
2. **Managed Identity** (already configured)
3. **Network security**:
   - VNet integration (configure in Bicep)
   - Private endpoints
   - Service endpoints
4. **Data encryption**:
   - TLS 1.2+ (enforced)
   - At-rest encryption in storage
5. **Application security**:
   - Input validation
   - Output encoding
   - CORS policy

See `main.advanced.bicep` for VNet integration example.

### How do I use Key Vault for secrets?

1. Create Key Vault in Azure
2. Add secrets to Key Vault
3. Grant app Managed Identity access (done in `main.advanced.bicep`)
4. Read secrets in app:
   ```csharp
   var client = new SecretClient(vaultUri, credential);
   var secret = await client.GetSecretAsync("SecretName");
   ```

### Should the connection string be in Bicep?

**No!** For production:
1. Create secret in Key Vault
2. Grant app Managed Identity access
3. App reads from Key Vault at runtime

The Bicep file shows the pattern but avoid hardcoding secrets!

## Troubleshooting Questions

### App deployed but gives 500 error

Check Application Insights:
1. Portal → Resource Group → Application Insights
2. Click "Failures"
3. See exception details
4. Common causes:
   - Missing environment variable
   - Connection string error
   - Missing dependency

### API endpoint returns 404

Check routing in `src/Program.cs`:
- Make sure `app.MapGet("/api/config", ...)` is defined
- No routing middleware interfering
- Check logs in Application Insights

### Deployment succeeds but app won't load in browser

1. App may be starting (can take 1-2 min)
2. Check if app service is running:
   ```bash
   az resource show --ids /subscriptions/{sub}/resourceGroups/{rg}/providers/Microsoft.Web/sites/{app}
   ```
3. Check Application Insights for startup errors

### Performance is slow

1. Check Application Insights metrics
2. Possible causes:
   - Cold start (first request, 15-30 sec)
   - Underpowered SKU (scale up)
   - Database query slow (optimize)
   - Dependency timeout
3. Solution: Scale up SKU or optimize code

## Cost Questions

### How much will this cost?

Approximate monthly costs:

**Development**:
- App Service Plan B1: ~$12
- Application Insights: ~$10
- Storage: ~$2
- **Total: ~$24/month**

**Production**:
- App Service Plan P1V2: ~$100
- Application Insights: ~$10
- Storage: ~$2
- **Total: ~$112/month**

### How can I save money?

1. Delete resources when not using
2. Use App Service Free tier for testing (has limitations)
3. Use B-series for non-production
4. Consolidate monitoring
5. Use Azure Reserved Instances for long-term

### Why am I being charged for unused resources?

Azure charges for:
- App Service Plan (even if app isn't used)
- Application Insights (30 days retention costs)
- Storage account (minimum charges)

**Solution**: Always `az group delete` when done demoing!

## Questions About Features

### Does the app support real databases?

Yes! It's designed to be extended:
- Add EF Core to `.csproj`
- Configure DbContext in `Program.cs`
- Connect to SQL Database, PostgreSQL, etc.
- Bicep supports all database types

### Can it support WebSockets?

Yes, App Service supports WebSockets. Add to `Program.cs`:
```csharp
app.UseWebSockets();
```

### Can I containerize this app?

Yes! Create a `Dockerfile`:
```dockerfile
FROM mcr.microsoft.com/dotnet/aspnet:8.0
COPY src/publish /app
WORKDIR /app
ENTRYPOINT ["dotnet", "GA26Demo.dll"]
```

Then deploy to:
- Container Instances
- App Service (Docker)
- AKS (Kubernetes)

### Can I add APIs for different purposes?

Yes! Add more endpoints to `src/Program.cs`:
```csharp
app.MapGet("/api/users", ...)
app.MapPost("/api/users", ...)
app.MapGet("/api/orders", ...)
```

Each parameter file can set different config per environment.

## More Questions?

Check these resources:
- [Azure App Service FAQ](https://learn.microsoft.com/en-us/azure/app-service/app-service-web-get-started-dotnet)
- [Bicep Docs](https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/)
- [.NET Documentation](https://learn.microsoft.com/en-us/dotnet/)
- [Application Insights Docs](https://learn.microsoft.com/en-us/azure/azure-monitor/app/app-insights-overview)

Or reach out to the Azure community!
