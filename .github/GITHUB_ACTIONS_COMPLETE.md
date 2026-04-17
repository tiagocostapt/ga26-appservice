# GitHub Actions - Setup Complete! ✅

Your GA26 demo application now has automated CI/CD with GitHub Actions! Here's what was created:

## 📦 Created Files

### Workflow Files (`.github/workflows/`)

```
.github/workflows/
├── deploy.yml                 (212 lines) Main deployment pipeline
├── pr-validation.yml          (109 lines) Pull request checks
└── README.md                  Workflow documentation & guide
```

### Documentation

```
GITHUB_ACTIONS_SETUP.md        (300+ lines) Complete setup instructions
QUICK_REFERENCE.md (updated)   Added GitHub Actions quick commands
README.md (updated)            Added GitHub Actions overview
```

## 🚀 What the Workflows Do

### 1. **deploy.yml** - Automated CI/CD Pipeline

**Triggers:**
- ✅ Automatic deploy on push to `main`
- ✅ Validation on pull requests
- ✅ Manual deployment to dev/prod via GitHub UI

**Pipeline Steps:**
```
Validate Code
    ↓
Validate Bicep Templates
    ↓
Build .NET Application
    ↓
Deploy to Development (auto on main)
    ↓
(Optional) Deploy to Production (manual only)
```

**Jobs:**
- `validate` - Compile and test .NET code
- `validate-bicep` - Validate infrastructure templates
- `build` - Publish application artifact
- `deploy-dev` - Automatic deployment to development
- `deploy-prod` - Manual deployment to production

### 2. **pr-validation.yml** - Pull Request Checks

**Ensures:**
- ✅ Code compiles correctly
- ✅ Bicep templates are valid
- ✅ No breaking changes before merge
- ✅ Build artifacts available for testing

**Jobs:**
- `code-analysis` - Compile and test
- `bicep-analysis` - Validate infrastructure
- `publish-artifact` - Create downloadable artifact
- `comment-on-pr` - Post status on PR

## ⚙️ Required Setup

### Step 1: Create Service Principal (Azure)

```bash
# Get subscription ID
SUBSCRIPTION_ID=$(az account show --query id -o tsv)

# Create Service Principal
az ad sp create-for-rbac \
  --name "github-actions-ga26" \
  --role Contributor \
  --scopes /subscriptions/$SUBSCRIPTION_ID \
  --json-auth > credentials.json

# View credentials (you'll need this in Step 2)
cat credentials.json
```

### Step 2: Add GitHub Secrets

1. Go to: **GitHub Repository → Settings → Secrets and variables → Actions**
2. Click **New repository secret**

**Add these secrets:**

| Secret Name | Value |
|---|---|
| `AZURE_CREDENTIALS` | Entire JSON from `credentials.json` |
| `AZURE_REGION` | Your Azure region (e.g., `eastus`) |

That's it! The workflows are now ready.

## 🎯 Usage

### Automatic Deployment (Push to Main)

```bash
# Make changes to code or infrastructure
git add .
git commit -m "Update application or infrastructure"
git push origin main

# Workflow automatically:
# 1. Validates your changes
# 2. Builds the application
# 3. Deploys to development environment
# 4. Reports results
```

**Check progress:**
- Go to **Actions** tab in GitHub
- Click on the workflow run
- Monitor real-time logs

### Manual Deployment (Production)

1. Go to GitHub → **Actions** tab
2. Click **Deploy to Azure**
3. Click **Run workflow**
4. Select environment: `prod`
5. Click **Run workflow**
6. Approve if required (if environment has approvers)
7. Monitor deployment in Actions tab

### Pull Request Validation

1. Create a pull request to `main`
2. GitHub automatically runs validation
3. All checks must pass to merge
4. Click on failing checks to see logs
5. Fix issues and push again

## 📊 Workflow Architecture

```
GitHub Event
    ↓
┌─────────────────────────────────┐
│ Validate (Parallel)             │
├─────────────────────────────────┤
│ • Code analysis & build         │
│ • Bicep validation              │
│ • Both must pass                │
└────────────┬────────────────────┘
             ↓
      ┌──────────────┐
      │ Build         │
      │ (Needs validate)
      └──────┬───────┘
             ↓
    ┌────────────────────┐
    ↓                    ↓
Deploy-Dev        Deploy-Prod
(auto on push)    (manual only)
```

## 📈 Workflow Details

### Build Times

- **Validation**: ~2-3 minutes
- **Bicep Validation**: ~1 minute
- **Build**: ~2-3 minutes
- **Deployment**: ~5-10 minutes
- **Total**: ~10-20 minutes per run

### Environment Configurations

**Development:**
- Automatic deployment on main push
- No approvals required
- B1 SKU (cost-effective)
- Resource group: `rg-ga26demo-dev`

**Production:**
- Manual deployment only
- Optional approvals (can be configured)
- P1V2 SKU (high-performance)
- Resource group: `rg-ga26demo-prod`

## 🔍 Monitoring

### In GitHub Actions

```
Actions Tab
├── Workflows (list of all runs)
├── Click on a run to see details
├── Click on a job to expand
├── Click on a step to view logs
└── Search logs with Ctrl+F (or Cmd+F)
```

### In Azure Portal

```
Resource Groups
├── rg-ga26demo-dev
│   └── Deployments (shows deployment history)
├── rg-ga26demo-prod
│   └── Deployments
└── Each App Service shows deployment info
```

## 📋 Sample Workflow Runs

### Successful Deployment

```
✓ validate [2m]           All tests passed
✓ validate-bicep [1m]     Templates valid
✓ build [3m]              Artifact created
✓ deploy-dev [8m]         https://ga26demo-dev-app.azurewebsites.net
```

### PR Validation (No Deployment)

```
✓ code-analysis [3m]      Build successful
✓ bicep-analysis [1m]     Templates valid
✓ publish-artifact [2m]   Artifact ready
✓ comment-on-pr [30s]     Comment posted
```

## 🛠️ Customization

### Add More Environments

1. Create parameter file: `infra/parameters.staging.bicepparam`
2. Add new job to `deploy.yml`
3. Update workflow triggers

### Change Trigger Events

Edit `.github/workflows/deploy.yml`:
```yaml
on:
  push:
    branches: [main]          # Deploy on main push
  pull_request:
    branches: [main]          # Validate on PR
  schedule:
    - cron: '0 2 * * *'       # Daily at 2 AM
  workflow_dispatch:          # Manual trigger
```

### Add Notifications

- Slack webhook
- Email (via GitHub)
- Teams notification
- Custom webhook

## 🚨 Troubleshooting

### Common Issues

| Error | Cause | Solution |
|-------|-------|----------|
| Login failed | Invalid credentials | Update `AZURE_CREDENTIALS` secret |
| Bicep validation failed | Template error | Run `az bicep validate` locally |
| Build failed | Code error | Fix errors, push again |
| Resource not found | RG missing | First deployment, auto-created |
| Workflow not triggering | Path filtering | Check file paths in `on.paths` |

### Debug Workflow

1. Go to Actions tab
2. Click on failed workflow
3. Click on failed job
4. Scroll through logs
5. Look for error messages
6. Check recent commits for changes

### Test Workflows Locally

Install `act`:
```bash
# macOS
brew install act

# Linux
curl https://raw.githubusercontent.com/nektos/act/master/install.sh | bash

# Run workflows locally
cd /workspaces/ga26-appservice
act -l              # List workflows
act -j build        # Run build job
```

## ✅ Checklist

Before pushing to GitHub:

- [ ] Service Principal created
- [ ] `AZURE_CREDENTIALS` secret added to GitHub
- [ ] `AZURE_REGION` secret added to GitHub
- [ ] Repository is public (or Actions enabled on private)
- [ ] Workflows are in `.github/workflows/`
- [ ] Initial commit ready to push

## 📚 Documentation

Refer to these files for more information:

- **[GITHUB_ACTIONS_SETUP.md](GITHUB_ACTIONS_SETUP.md)** - Complete setup guide (300+ lines)
- **[.github/workflows/README.md](.github/workflows/README.md)** - Workflow architecture
- **[QUICK_REFERENCE.md](QUICK_REFERENCE.md)** - Quick commands

## 🚀 Next Steps

1. ✅ Read this file (you are here!)
2. ✅ Follow [GITHUB_ACTIONS_SETUP.md](GITHUB_ACTIONS_SETUP.md) steps
3. ✅ Create Service Principal
4. ✅ Add GitHub secrets
5. ✅ Push repository to GitHub
6. ✅ Test deployment with push to main
7. ✅ Monitor in Actions tab
8. ✅ Verify app deployed to Azure

## 💡 Pro Tips

- **Test locally first**: Run `dotnet build` and `az bicep validate` before pushing
- **Use descriptive commits**: Helps identify what triggered deployments
- **Monitor logs early**: Catch errors early in the workflow
- **Keep secrets safe**: Never commit credentials to Git
- **Archive artifacts**: Download build artifacts from Actions tab for history

## 📞 Support

For help with:
- **GitHub Actions**: Check [GitHub Docs](https://docs.github.com/en/actions)
- **Azure Deployment**: See [Azure Docs](https://learn.microsoft.com/en-us/azure-resource-manager/)
- **Bicep Issues**: Review [Bicep Docs](https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/)
- **This Setup**: Read [GITHUB_ACTIONS_SETUP.md](GITHUB_ACTIONS_SETUP.md)

---

**Created**: 2026-04-17  
**Status**: ✅ Ready to Use  
**Version**: 1.0  

Your automated CI/CD pipeline is ready! 🎉
