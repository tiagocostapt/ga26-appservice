# GitHub Actions Workflows - Overview

This directory contains GitHub Actions workflows for automated CI/CD of the GA26 demo application.

## Workflow Files

### 1. `.github/workflows/deploy.yml` - Main Deployment Pipeline

**Triggers:**
- Push to `main` branch (auto-deploy to dev)
- Pull requests to `main` (validation only)
- Manual dispatch (workflow_dispatch) - choose env
- Path-based triggers: changes to `src/`, `infra/`, or workflow files

**Jobs:**

| Job | Purpose | Trigger | Environment |
|-----|---------|---------|-------------|
| `validate` | Build & test .NET code | Always | Ubuntu |
| `validate-bicep` | Validate infrastructure templates | Always | Ubuntu |
| `build` | Publish application artifact | After validate | Ubuntu |
| `deploy-dev` | Deploy to development | Push to main | GitHub Env |
| `deploy-prod` | Deploy to production | Manual only | GitHub Env |

**Deployment Flow:**

```
Push to main/PR/Manual
        ↓
    ┌─────────────────────────────────┐
    │ Parallel: Validate + ValidBicep │
    └──────────────┬──────────────────┘
                   ↓
              Build (.NET app)
                   ↓
        ┌──────────────────────┐
        ↓                      ↓
   Deploy-Dev           Deploy-Prod
(auto on push)        (manual only)
```

### 2. `.github/workflows/pr-validation.yml` - Pull Request Checks

**Triggers:**
- Pull requests to `main`
- Path-based: changes to `src/`, `infra/`, or workflow files

**Jobs:**

| Job | Purpose |
|-----|---------|
| `code-analysis` | Compile and test .NET code |
| `bicep-analysis` | Validate and build Bicep templates |
| `publish-artifact` | Create build artifact |
| `comment-on-pr` | Post status comment on PR |

**Purpose:**
- Catch issues before merging
- Validate infrastructure changes
- Build security: no secrets in PRs
- No deployment from PRs (only push to main)

## Required Secrets

These GitHub secrets must be configured for workflows to work:

```
AZURE_CREDENTIALS       - Service Principal credentials (JSON)
AZURE_REGION           - Azure region for deployment (e.g., "eastus")
AZURE_SUBSCRIPTION_ID  - Subscription ID (optional, for reference)
```

See [GITHUB_ACTIONS_SETUP.md](../GITHUB_ACTIONS_SETUP.md) for setup instructions.

## Environment Setup

### Development Environment
- **Branch**: main
- **Deployment**: Automatic on push
- **Approvals**: None required
- **Resource Group**: `rg-ga26demo-dev`
- **SKU**: B1 (cost-effective)

### Production Environment
- **Branch**: main (manual trigger only)
- **Deployment**: Manual only
- **Approvals**: Required (if enabled)
- **Resource Group**: `rg-ga26demo-prod`
- **SKU**: P1V2 (high-performance)

## Key Features

### 1. **Parallel Validation**
- Code and Bicep validation run in parallel
- Faster feedback loop
- Independent failure reporting

### 2. **Artifact Management**
- Build artifacts retained for 5 days
- Can be downloaded for debugging
- Automatic cleanup

### 3. **Deployment Safety**
- Always validates before deploying
- Separate dev/prod deployments
- Environment protection rules
- Approval gates (optional)

### 4. **Deployment Reporting**
- Job summaries in GitHub UI
- Application URLs in summary
- API endpoint information
- Health check endpoints

### 5. **Smart Triggers**
- Path-based filtering (only deploy on relevant changes)
- Manual dispatch for on-demand deployments
- PR validation without deployment
- Scheduled runs not configured (can be added)

## Workflow Architecture

```
.github/workflows/
├── deploy.yml                    # Main CI/CD pipeline
└── pr-validation.yml             # Pull request checks

Usage:
├── On push to main
│   ├── Run all validation jobs
│   ├── Build application
│   └── Auto-deploy to development
│
├── On pull request
│   └── Run validation jobs only (no deploy)
│
└── Manual trigger
    ├── Select environment (dev/prod)
    └── Deploy to selected environment
```

## Deployment Sequence

### Automatic Deployment (Push to Main)

```
1. GitHub detects push to main
   ├─ Run validate job
   ├─ Run validate-bicep job
   └─ Wait for both to complete (or fail)

2. If both pass, run build job
   └─ Publish application

3. If build succeeds, run deploy-dev
   ├─ Login to Azure
   ├─ Create/verify resource group
   ├─ Deploy Bicep template
   ├─ Get App Service URL
   └─ Report results

4. Deployment complete
   └─ View in Actions tab and Azure Portal
```

### Manual Deployment (Production)

```
1. User navigates to Actions tab
   └─ Clicks "Deploy to Azure"

2. User selects "Run workflow"
   ├─ Chooses environment: prod
   └─ Clicks "Run workflow"

3. All validation jobs run
   └─ Then run deploy-prod job

4. Production deployment complete
   └─ Approval required before actual deployment
      (if environment has required reviewers)
```

## Job Details

### `validate` Job

```yaml
Runs on: ubuntu-latest
Steps:
1. Checkout repository
2. Setup .NET 10 SDK
3. Restore NuGet packages
4. Build application (Release)
5. Run tests (continue-on-error)
Time: ~2-3 minutes
```

### `validate-bicep` Job

```yaml
Runs on: ubuntu-latest
Steps:
1. Checkout repository
2. Azure CLI: Validate main.bicep
3. Azure CLI: Validate main.advanced.bicep
4. Report validation results
Time: ~1 minute
```

### `build` Job

```yaml
Runs on: ubuntu-latest
Needs: validate
Steps:
1. Checkout repository
2. Setup .NET 10 SDK
3. Restore NuGet packages
4. Build application (Release)
5. Publish application
6. Upload artifact (5-day retention)
Time: ~2-3 minutes
```

### `deploy-dev` Job

```yaml
Runs on: ubuntu-latest
Needs: [validate, build, validate-bicep]
Triggers: Push to main OR manual with env=dev
Steps:
1. Checkout repository
2. Download build artifacts
3. Login to Azure (using AZURE_CREDENTIALS)
4. Create resource group (rg-ga26demo-dev)
5. Deploy Bicep: infra/parameters.dev.bicepparam
6. Query App Service URL
7. Create deployment summary
Environment: GitHub Environment "Development"
Time: ~5-10 minutes
```

### `deploy-prod` Job

```yaml
Runs on: ubuntu-latest
Needs: [validate, build, validate-bicep]
Triggers: Manual only with env=prod
Steps:
1-7. Same as deploy-dev, but for production
Environment: GitHub Environment "Production"
Approvals: Optional (if configured)
Time: ~5-10 minutes
```

## Environment Variables

**Available in all jobs:**
- `github.event_name` - Trigger type (push, pull_request, etc.)
- `github.ref` - Branch reference
- `github.actor` - Who triggered the workflow
- `GITHUB_WORKSPACE` - Working directory

**Set by workflows:**
- `app_url` - Application URL (deployment jobs)

**From GitHub Secrets:**
- `AZURE_CREDENTIALS` - Azure login credentials
- `AZURE_REGION` - Deployment region

## Monitoring & Debugging

### View Workflow Logs

1. Go to **Actions** tab in GitHub
2. Click on the workflow run
3. Click on a job to expand
4. Click a step to view logs
5. Search logs with browser find (Ctrl+F)

### Common Log Messages

```
✓ Bicep template is valid
  → Template syntax is correct

Running: dotnet build ...
  → Application building

Deploy Bicep template...
  → Infrastructure being created

✓ App deployed to: https://...
  → Deployment successful
```

### Troubleshooting Logs

```
ERROR: Login failed
  → Check AZURE_CREDENTIALS secret

ERROR: Resource not found
  → First deployment, resource group needs creation

ERROR: Bicep syntax error
  → Fix template and retry

ERROR: Build failed
  → Check .NET code compilation errors
```

## Best Practices

✅ **Do:**
- Test locally before pushing
  ```bash
  dotnet build
  az bicep validate --file infra/main.bicep
  ```
- Use descriptive commit messages
  ```bash
  git commit -m "Update DEMO_VALUE in dev environment"
  ```
- Monitor deployments in Actions tab
- Review workflow logs for any issues
- Keep secrets secure and rotated

❌ **Don't:**
- Commit to main without testing
- Modify secrets in workflow files
- Disable validation checks
- Deploy to prod without PR review
- Leave workflows disabled unnecessarily

## Customization

### Adding New Deployment Targets

1. Create parameter file: `infra/parameters.staging.bicepparam`
2. Add job to `deploy.yml`:
   ```yaml
   deploy-staging:
     name: Deploy to Staging
     runs-on: ubuntu-latest
     needs: [validate, build, validate-bicep]
     if: github.event_name == 'workflow_dispatch' && github.event.inputs.environment == 'staging'
     environment:
       name: Staging
   ```
3. Update workflow_dispatch inputs

### Adding Email Notifications

Use GitHub's native email or integrate with:
- SendGrid
- Azure Service Bus
- Slack (via webhook)
- Custom webhook

### Adding Slack Integration

```yaml
- name: Notify Slack
  uses: slackapi/slack-github-action@v1
  with:
    webhook-url: ${{ secrets.SLACK_WEBHOOK }}
```

## Costs

**GitHub Actions:**
- Free for public repos
- Ubuntu runners: 2,000 free minutes/month (private)
- Standard rate: ~$0.005 per minute

**Azure:**
- Depends on resources deployed
- Dev: ~$12/month (B1 SKU)
- Prod: ~$100/month (P1V2 SKU)

## Resources

- [GitHub Actions Docs](https://docs.github.com/en/actions)
- [Azure CLI Action](https://github.com/azure/cli)
- [Azure Login Action](https://github.com/azure/login)
- [Bicep Docs](https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/)
- [.NET Build Action](https://github.com/actions/setup-dotnet)

## Next Steps

1. Review [GITHUB_ACTIONS_SETUP.md](../GITHUB_ACTIONS_SETUP.md)
2. Create Service Principal and secrets
3. Test workflow with a push to main
4. Monitor the deployment in Actions tab
5. Customize workflows as needed
