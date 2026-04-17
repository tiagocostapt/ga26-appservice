# GitHub Actions - Azure Deployment Setup Guide

This guide explains how to set up GitHub Actions to automatically deploy your GA26 demo application to Azure.

## Overview

The workflow automatically:
- ✅ Builds the .NET 10 application
- ✅ Validates Bicep infrastructure templates
- ✅ Deploys to Azure on push to main
- ✅ Supports manual deployment to different environments
- ✅ Generates deployment reports

## Prerequisites

1. **Azure Subscription** with active billing
2. **GitHub Repository** (this one!)
3. **Azure CLI** installed locally (for setup only)
4. **Appropriate permissions**:
   - Azure: Owner or Contributor role
   - GitHub: Repository admin access

## Step 1: Create Azure Service Principal

The GitHub Actions workflow needs credentials to access your Azure subscription. Create a Service Principal:

### Option A: Using Azure CLI (Recommended)

```bash
# Login to Azure
az login

# Set your subscription ID
SUBSCRIPTION_ID=$(az account show --query id -o tsv)
echo "Using subscription: $SUBSCRIPTION_ID"

# Create Service Principal with Contributor role
az ad sp create-for-rbac \
  --name "github-actions-ga26" \
  --role Contributor \
  --scopes /subscriptions/$SUBSCRIPTION_ID \
  --json-auth > credentials.json

# Display the credentials (you'll need these for GitHub)
cat credentials.json
```

This creates output like:
```json
{
  "clientId": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
  "clientSecret": "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx",
  "subscriptionId": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
  "tenantId": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
  "activeDirectoryEndpointUrl": "https://login.microsoftonline.com",
  "resourceManagerEndpointUrl": "https://management.azure.com/",
  "activeDirectoryGraphResourceId": "https://graph.microsoft.com/",
  "sqlManagementEndpointUrl": "https://management.core.windows.net:8443/",
  "galleryEndpointUrl": "https://gallery.azure.com/",
  "managementEndpointUrl": "https://management.core.windows.net/"
}
```

### Option B: Using Azure Portal

1. Go to Azure Portal → Azure Active Directory → App registrations
2. Click "New registration"
3. Name: `github-actions-ga26`
4. Click "Register"
5. Go to "Certificates & secrets"
6. Create a new client secret
7. Go to "Overview" and copy:
   - Application (client) ID
   - Directory (tenant) ID

Then grant Contributor role:
1. Go to Subscriptions → Your subscription
2. Click "Access control (IAM)"
3. Click "Add" → "Add role assignment"
4. Role: Contributor
5. Assign to: Service Principal
6. Select: github-actions-ga26

## Step 2: Add GitHub Secrets

Secrets store sensitive information like Azure credentials.

### Setup in GitHub

1. Go to your GitHub repository
2. Click **Settings** → **Secrets and variables** → **Actions**
3. Click **New repository secret**

### Add These Secrets

**1. AZURE_CREDENTIALS**
- Name: `AZURE_CREDENTIALS`
- Value: Paste the entire JSON from `credentials.json`
  ```json
  {
    "clientId": "...",
    "clientSecret": "...",
    "subscriptionId": "...",
    "tenantId": "..."
  }
  ```

**2. AZURE_REGION**
- Name: `AZURE_REGION`
- Value: Your preferred Azure region
  - Examples: `eastus`, `westus`, `northeurope`, `westeurope`

**3. AZURE_SUBSCRIPTION_ID** (optional, for reference)
- Name: `AZURE_SUBSCRIPTION_ID`
- Value: Your subscription ID

### Screenshot Example

```
Settings → Secrets and variables → Actions
├── New repository secret
│   ├── Name: AZURE_CREDENTIALS
│   └── Value: [entire JSON blob]
├── New repository secret
│   ├── Name: AZURE_REGION
│   └── Value: eastus
└── New repository secret
    ├── Name: AZURE_SUBSCRIPTION_ID
    └── Value: xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
```

## Step 3: Configure Environments (Optional but Recommended)

Environments add protection and require approvals before deployment.

### Create Development Environment

1. Go to **Settings** → **Environments**
2. Click **New environment**
3. Name: `Development`
4. Add deployment branches restriction:
   - Select "Deployment branches"
   - Allow from specific branches: `main`
5. Don't require approvals (dev deploys automatically)

### Create Production Environment

1. Click **New environment**
2. Name: `Production`
3. Add deployment branches restriction (same as above)
4. **Enable required reviewers**:
   - Check "Required reviewers"
   - Add team members who review prod deployments
5. This ensures someone approves before production deployment

## Step 4: Test the Workflow

### Trigger Development Deployment

1. Make a change to the code:
   ```bash
   # Example: Add a comment to src/Program.cs
   echo "// Updated for CI/CD demo" >> src/Program.cs
   git add .
   git commit -m "Test GitHub Actions deployment"
   git push origin main
   ```

2. Go to **Actions** tab in GitHub
3. Click on the running workflow
4. Monitor the build progress
5. Check the deployment results

### Manual Deployment

1. Go to **Actions** tab
2. Click **Deploy to Azure**
3. Click **Run workflow**
4. Select environment: `dev` or `prod`
5. Click **Run workflow**
6. Monitor the deployment

## Workflow Structure

```
Deploy to Azure
├── Validate
│   ├── Checkout
│   ├── Setup .NET 10
│   ├── Build
│   └── Test
│
├── Validate Bicep
│   └── Validate Bicep templates
│
├── Build
│   ├── Build application
│   ├── Publish
│   └── Upload artifact
│
├── Deploy to Development (on push)
│   ├── Login to Azure
│   ├── Create resource group
│   ├── Deploy Bicep template
│   └── Report results
│
└── Deploy to Production (manual only)
    ├── Login to Azure
    ├── Create resource group
    ├── Deploy Bicep template
    └── Report results
```

## Monitoring Deployments

### In GitHub

1. Go to **Actions** tab
2. Click on the workflow run
3. View logs for each job
4. Scroll through the deployment steps

### In Azure Portal

1. Go to your resource group: `rg-ga26demo-dev` or `rg-ga26demo-prod`
2. Click "Deployments" to see deployment history
3. Click on the latest deployment for details
4. View output values for the application URL

### Workflow Artifacts

1. Go to **Actions** tab
2. Click on the workflow run
3. Scroll down to "Artifacts"
4. Download the published application if needed

## Troubleshooting

### Issue: "Login failed" Error

**Cause**: Azure credentials are incorrect or expired

**Solution**:
```bash
# Regenerate Service Principal
az ad sp delete --id $(az ad sp list --display-name github-actions-ga26 --query [0].appId -o tsv)

# Create new one (see Step 1)
az ad sp create-for-rbac --name "github-actions-ga26" ...
```

Then update the `AZURE_CREDENTIALS` secret in GitHub.

### Issue: "Resource group not found"

**Cause**: First deployment failed to create resource group

**Solution**:
1. Go to Azure Portal
2. Create the resource group manually:
   ```bash
   az group create --name rg-ga26demo-dev --location eastus
   ```
3. Re-run the workflow

### Issue: "Bicep validation failed"

**Cause**: Bicep template syntax error

**Solution**:
1. Run locally to test:
   ```bash
   az bicep validate --file infra/main.bicep
   ```
2. Fix any validation errors
3. Push the fix and re-run workflow

### Issue: Workflow not triggering

**Cause**: Event configuration or path filters

**Solution**: Check `.github/workflows/deploy.yml`:
- Workflow is set to trigger on `push` to `main`
- Only triggers on changes to `src/`, `infra/`, or workflow files
- Manual dispatch (`workflow_dispatch`) always works

To trigger manually:
1. Go to **Actions** tab
2. Click **Deploy to Azure**
3. Click **Run workflow**

### Issue: "Artifact not found"

**Cause**: Build job failed or didn't run

**Solution**:
1. Check the "Build" job in the workflow run
2. View logs for build errors
3. Fix errors in the code
4. Push changes to retry

## Secrets Management Best Practices

✅ **Do:**
- Rotate Service Principal credentials periodically
- Use environment-specific credentials if possible
- Review workflow logs for suspicious activity
- Delete old Service Principals when no longer needed
- Use GitHub Environments for approval gates

❌ **Don't:**
- Commit credentials to Git
- Share credentials in logs
- Use overly permissive roles (Owner)
- Reuse credentials across services
- Leave credentials in email or chat

## Advanced Configuration

### Deploy to Multiple Subscriptions

1. Create separate Service Principals for each subscription
2. Create secrets: `AZURE_CREDENTIALS_PROD`, etc.
3. Update workflows to use the appropriate secret

### Deploy to Multiple Regions

1. Update parameter files for each region
2. Modify deployment jobs to loop over regions
3. Use matrix strategy in GitHub Actions

### Add Slack Notifications

```yaml
- name: Notify Slack
  uses: slackapi/slack-github-action@v1
  with:
    payload: |
      {
        "text": "Deployment to ${{ matrix.environment }} completed: ${{ job.status }}"
      }
  env:
    SLACK_WEBHOOK_URL: ${{ secrets.SLACK_WEBHOOK }}
```

### Add Email Notifications

Use GitHub's native notifications or integrate with SendGrid.

## Cleanup

### Stop Deployments

1. Disable the workflow:
   - Go to **Actions**
   - Click workflow name
   - Click menu (⋯)
   - Click "Disable workflow"

2. Or delete the workflow files:
   ```bash
   rm -rf .github/workflows/
   ```

### Delete Azure Resources

```bash
# Delete resource groups created by workflow
az group delete --name rg-ga26demo-dev --yes
az group delete --name rg-ga26demo-prod --yes
```

### Delete Service Principal

```bash
# Find and delete
az ad sp delete --id $(az ad sp list --display-name github-actions-ga26 --query [0].appId -o tsv)
```

### Delete GitHub Secrets

1. Go to **Settings** → **Secrets and variables** → **Actions**
2. Click delete (🗑️) on each secret

## Useful Links

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Azure Login GitHub Action](https://github.com/azure/login)
- [Azure CLI GitHub Action](https://github.com/azure/cli)
- [Azure Bicep Documentation](https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/)
- [GitHub Secrets Documentation](https://docs.github.com/en/actions/security-guides/using-secrets-in-github-actions)

## Next Steps

1. ✅ Create Service Principal (Step 1)
2. ✅ Add GitHub Secrets (Step 2)
3. ✅ (Optional) Configure Environments (Step 3)
4. ✅ Test the workflow (Step 4)
5. ✅ Monitor deployments
6. ✅ Customize as needed

Your workflow is now ready to automatically deploy to Azure! 🚀
